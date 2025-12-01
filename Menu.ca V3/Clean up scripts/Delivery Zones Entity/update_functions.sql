-- =====================================================
-- Phase 2: Update SQL Functions to use restaurant_delivery_areas
-- =====================================================

-- 2.2 Update is_address_in_delivery_zone
CREATE OR REPLACE FUNCTION menuca_v3.is_address_in_delivery_zone(
    p_restaurant_id bigint, 
    p_latitude numeric, 
    p_longitude numeric
)
RETURNS TABLE(
    zone_id bigint, 
    zone_name character varying, 
    delivery_fee_cents integer, 
    minimum_order_cents integer, 
    estimated_delivery_minutes integer
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT
        rda.id,
        rda.area_name,
        CASE 
            WHEN rda.fee_type = 'free' THEN 0
            ELSE COALESCE((rda.delivery_fee * 100)::integer, 0)
        END as delivery_fee_cents,
        COALESCE((rda.min_order_value * 100)::integer, 0) as minimum_order_cents,
        rda.estimated_delivery_minutes
    FROM menuca_v3.restaurant_delivery_areas rda
    WHERE rda.restaurant_id = p_restaurant_id
      AND rda.is_active = true
      AND rda.deleted_at IS NULL
      AND ST_Contains(
          rda.geometry,
          ST_SetSRID(ST_MakePoint(p_longitude, p_latitude), 4326)
      )
    ORDER BY rda.area_number ASC
    LIMIT 1;
END;
$$;

-- 2.3 Update create_delivery_zone (polygon-based, not radius)
CREATE OR REPLACE FUNCTION menuca_v3.create_delivery_zone(
    p_restaurant_id bigint,
    p_zone_name character varying,
    p_polygon_coordinates jsonb,
    p_delivery_fee numeric DEFAULT 0,
    p_min_order_value numeric DEFAULT 0,
    p_estimated_delivery_minutes integer DEFAULT NULL,
    p_fee_type character varying DEFAULT 'flat',
    p_created_by bigint DEFAULT NULL
)
RETURNS TABLE(
    zone_id bigint, 
    zone_name character varying, 
    area_sq_km numeric, 
    delivery_fee numeric, 
    min_order_value numeric, 
    estimated_minutes integer
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_zone_geometry GEOMETRY;
    v_area_sq_km NUMERIC;
    v_zone_id BIGINT;
    v_area_number INTEGER;
    v_coordinates TEXT;
BEGIN
    -- Validate restaurant exists
    IF NOT EXISTS (
        SELECT 1 FROM menuca_v3.restaurants
        WHERE id = p_restaurant_id AND deleted_at IS NULL
    ) THEN
        RAISE EXCEPTION 'Restaurant % does not exist', p_restaurant_id;
    END IF;

    -- Validate fee_type
    IF p_fee_type NOT IN ('free', 'flat', 'conditional') THEN
        RAISE EXCEPTION 'Invalid fee_type: %. Must be free, flat, or conditional', p_fee_type;
    END IF;

    -- Build polygon from coordinates JSON
    -- Expected format: [{"lat": 45.123, "lng": -75.456}, ...]
    WITH coords AS (
        SELECT 
            (elem->>'lng')::numeric as lng,
            (elem->>'lat')::numeric as lat
        FROM jsonb_array_elements(p_polygon_coordinates) elem
    )
    SELECT ST_SetSRID(
        ST_MakePolygon(
            ST_MakeLine(
                ARRAY(SELECT ST_MakePoint(lng, lat) FROM coords)
                || ARRAY[(SELECT ST_MakePoint(lng, lat) FROM coords LIMIT 1)]
            )
        ),
        4326
    ) INTO v_zone_geometry;

    -- Calculate area
    v_area_sq_km := ROUND((ST_Area(v_zone_geometry::geography) / 1000000)::NUMERIC, 2);

    -- Get next area number
    SELECT COALESCE(MAX(area_number), 0) + 1 INTO v_area_number
    FROM menuca_v3.restaurant_delivery_areas
    WHERE restaurant_id = p_restaurant_id;

    -- Convert coordinates to text for backup
    SELECT string_agg(
        (elem->>'lat') || ',' || (elem->>'lng'), '|'
    ) INTO v_coordinates
    FROM jsonb_array_elements(p_polygon_coordinates) elem;

    -- Insert area
    INSERT INTO menuca_v3.restaurant_delivery_areas (
        restaurant_id,
        area_number,
        area_name,
        fee_type,
        delivery_fee,
        min_order_value,
        estimated_delivery_minutes,
        coordinates,
        geometry,
        is_active,
        created_by,
        created_at
    ) VALUES (
        p_restaurant_id,
        v_area_number,
        p_zone_name,
        p_fee_type,
        CASE WHEN p_fee_type = 'free' THEN NULL ELSE p_delivery_fee END,
        p_min_order_value,
        p_estimated_delivery_minutes,
        v_coordinates,
        v_zone_geometry,
        true,
        p_created_by,
        NOW()
    )
    RETURNING id INTO v_zone_id;

    RETURN QUERY
    SELECT
        v_zone_id,
        p_zone_name,
        v_area_sq_km,
        p_delivery_fee,
        p_min_order_value,
        p_estimated_delivery_minutes;
END;
$$;

-- 2.4 Update update_delivery_zone
CREATE OR REPLACE FUNCTION menuca_v3.update_delivery_zone(
    p_zone_id bigint,
    p_zone_name character varying DEFAULT NULL,
    p_delivery_fee_cents integer DEFAULT NULL,
    p_minimum_order_cents integer DEFAULT NULL,
    p_estimated_delivery_minutes integer DEFAULT NULL,
    p_new_radius_meters integer DEFAULT NULL,  -- Ignored, kept for compatibility
    p_is_active boolean DEFAULT NULL,
    p_updated_by bigint DEFAULT NULL
)
RETURNS TABLE(
    zone_id bigint,
    zone_name character varying,
    delivery_fee_cents integer,
    minimum_order_cents integer,
    estimated_minutes integer,
    is_active boolean
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validate zone exists
    IF NOT EXISTS (
        SELECT 1 FROM menuca_v3.restaurant_delivery_areas
        WHERE id = p_zone_id AND deleted_at IS NULL
    ) THEN
        RAISE EXCEPTION 'Delivery zone % does not exist', p_zone_id;
    END IF;

    -- Update the zone
    UPDATE menuca_v3.restaurant_delivery_areas
    SET
        area_name = COALESCE(p_zone_name, area_name),
        delivery_fee = CASE 
            WHEN p_delivery_fee_cents IS NOT NULL THEN p_delivery_fee_cents / 100.0
            ELSE delivery_fee
        END,
        min_order_value = CASE 
            WHEN p_minimum_order_cents IS NOT NULL THEN p_minimum_order_cents / 100.0
            ELSE min_order_value
        END,
        estimated_delivery_minutes = COALESCE(p_estimated_delivery_minutes, estimated_delivery_minutes),
        is_active = COALESCE(p_is_active, is_active),
        updated_by = p_updated_by,
        updated_at = NOW()
    WHERE id = p_zone_id;

    RETURN QUERY
    SELECT
        rda.id,
        rda.area_name,
        COALESCE((rda.delivery_fee * 100)::integer, 0),
        COALESCE((rda.min_order_value * 100)::integer, 0),
        rda.estimated_delivery_minutes,
        rda.is_active
    FROM menuca_v3.restaurant_delivery_areas rda
    WHERE rda.id = p_zone_id;
END;
$$;

-- 2.5 Update soft_delete_delivery_zone
CREATE OR REPLACE FUNCTION menuca_v3.soft_delete_delivery_zone(
    p_zone_id bigint,
    p_deleted_by bigint,
    p_reason text DEFAULT NULL
)
RETURNS boolean
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validate zone exists and is not already deleted
    IF NOT EXISTS (
        SELECT 1 FROM menuca_v3.restaurant_delivery_areas
        WHERE id = p_zone_id AND deleted_at IS NULL
    ) THEN
        RAISE EXCEPTION 'Delivery zone % does not exist or is already deleted', p_zone_id;
    END IF;

    -- Soft delete
    UPDATE menuca_v3.restaurant_delivery_areas
    SET
        deleted_at = NOW(),
        deleted_by = p_deleted_by,
        is_active = false,
        notes = CASE 
            WHEN p_reason IS NOT NULL THEN COALESCE(notes || E'\n', '') || 'Deleted: ' || p_reason
            ELSE notes
        END,
        updated_at = NOW()
    WHERE id = p_zone_id;

    RETURN true;
END;
$$;

-- 2.6 Update restore_delivery_zone
CREATE OR REPLACE FUNCTION menuca_v3.restore_delivery_zone(p_zone_id bigint)
RETURNS boolean
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validate zone exists and is deleted
    IF NOT EXISTS (
        SELECT 1 FROM menuca_v3.restaurant_delivery_areas
        WHERE id = p_zone_id AND deleted_at IS NOT NULL
    ) THEN
        RAISE EXCEPTION 'Delivery zone % does not exist or is not deleted', p_zone_id;
    END IF;

    -- Restore
    UPDATE menuca_v3.restaurant_delivery_areas
    SET
        deleted_at = NULL,
        deleted_by = NULL,
        is_active = true,
        updated_at = NOW()
    WHERE id = p_zone_id;

    RETURN true;
END;
$$;

-- 2.7 Update toggle_delivery_zone_status
CREATE OR REPLACE FUNCTION menuca_v3.toggle_delivery_zone_status(
    p_zone_id bigint,
    p_is_active boolean,
    p_reason text DEFAULT NULL,
    p_updated_by bigint DEFAULT NULL
)
RETURNS boolean
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validate zone exists
    IF NOT EXISTS (
        SELECT 1 FROM menuca_v3.restaurant_delivery_areas
        WHERE id = p_zone_id AND deleted_at IS NULL
    ) THEN
        RAISE EXCEPTION 'Delivery zone % does not exist', p_zone_id;
    END IF;

    -- Toggle status
    UPDATE menuca_v3.restaurant_delivery_areas
    SET
        is_active = p_is_active,
        notes = CASE 
            WHEN p_reason IS NOT NULL THEN COALESCE(notes || E'\n', '') || 
                CASE WHEN p_is_active THEN 'Activated: ' ELSE 'Deactivated: ' END || p_reason
            ELSE notes
        END,
        updated_by = p_updated_by,
        updated_at = NOW()
    WHERE id = p_zone_id;

    RETURN true;
END;
$$;

-- 2.8 Update get_delivery_zone_area_sq_km
CREATE OR REPLACE FUNCTION menuca_v3.get_delivery_zone_area_sq_km(p_zone_id bigint)
RETURNS numeric
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_area_sq_km NUMERIC;
BEGIN
    SELECT ROUND((ST_Area(geometry::geography) / 1000000)::NUMERIC, 2)
    INTO v_area_sq_km
    FROM menuca_v3.restaurant_delivery_areas
    WHERE id = p_zone_id;

    RETURN v_area_sq_km;
END;
$$;

-- 2.9 Update get_restaurant_delivery_summary
CREATE OR REPLACE FUNCTION menuca_v3.get_restaurant_delivery_summary(p_restaurant_id bigint)
RETURNS TABLE(
    zone_id bigint, 
    zone_name character varying, 
    area_sq_km numeric, 
    delivery_fee_cents integer, 
    minimum_order_cents integer, 
    estimated_minutes integer, 
    is_active boolean
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT
        rda.id,
        rda.area_name,
        ROUND((ST_Area(rda.geometry::geography) / 1000000)::NUMERIC, 2) as area_sq_km,
        CASE 
            WHEN rda.fee_type = 'free' THEN 0
            ELSE COALESCE((rda.delivery_fee * 100)::integer, 0)
        END as delivery_fee_cents,
        COALESCE((rda.min_order_value * 100)::integer, 0) as minimum_order_cents,
        rda.estimated_delivery_minutes,
        rda.is_active
    FROM menuca_v3.restaurant_delivery_areas rda
    WHERE rda.restaurant_id = p_restaurant_id
      AND rda.deleted_at IS NULL
    ORDER BY rda.area_number ASC;
END;
$$;

-- 2.10 Update find_nearby_restaurants
CREATE OR REPLACE FUNCTION menuca_v3.find_nearby_restaurants(
    p_latitude numeric, 
    p_longitude numeric, 
    p_radius_km numeric DEFAULT 5, 
    p_limit integer DEFAULT 20
)
RETURNS TABLE(
    restaurant_id bigint, 
    restaurant_name character varying, 
    distance_km numeric, 
    can_deliver boolean
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.id,
        r.name,
        ROUND((ST_Distance(
            rl.location_point::geography,
            ST_SetSRID(ST_MakePoint(p_longitude, p_latitude), 4326)::geography
        ) / 1000)::NUMERIC, 2) as distance_km,
        EXISTS(
            SELECT 1
            FROM menuca_v3.restaurant_delivery_areas rda
            WHERE rda.restaurant_id = r.id
              AND rda.is_active = true
              AND rda.deleted_at IS NULL
              AND ST_Contains(
                  rda.geometry,
                  ST_SetSRID(ST_MakePoint(p_longitude, p_latitude), 4326)
              )
        ) as can_deliver
    FROM menuca_v3.restaurants r
    JOIN menuca_v3.restaurant_locations rl ON r.id = rl.restaurant_id
    WHERE r.status = 'active'
      AND r.deleted_at IS NULL
      AND r.online_ordering_enabled = true
      AND rl.location_point IS NOT NULL
      AND rl.deleted_at IS NULL
      AND ST_DWithin(
          rl.location_point::geography,
          ST_SetSRID(ST_MakePoint(p_longitude, p_latitude), 4326)::geography,
          p_radius_km * 1000
      )
    ORDER BY distance_km ASC
    LIMIT p_limit;
END;
$$;

-- 2.12 Update create_delivery_zone_onboarding (simplified polygon version)
CREATE OR REPLACE FUNCTION menuca_v3.create_delivery_zone_onboarding(
    p_restaurant_id bigint,
    p_zone_name character varying DEFAULT NULL,
    p_center_latitude numeric DEFAULT NULL,
    p_center_longitude numeric DEFAULT NULL,
    p_radius_meters integer DEFAULT NULL,  -- Kept for backward compatibility, creates circular polygon
    p_delivery_fee_cents integer DEFAULT 299,
    p_minimum_order_cents integer DEFAULT 1500,
    p_estimated_delivery_minutes integer DEFAULT NULL,
    p_created_by bigint DEFAULT NULL
)
RETURNS TABLE(
    zone_id bigint, 
    zone_name character varying, 
    area_sq_km numeric, 
    delivery_fee_cents integer, 
    minimum_order_cents integer, 
    estimated_minutes integer
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_zone_geometry GEOMETRY;
    v_area_sq_km NUMERIC;
    v_zone_id BIGINT;
    v_area_number INTEGER;
    v_zone_name VARCHAR;
BEGIN
    -- Validate restaurant exists
    IF NOT EXISTS (
        SELECT 1 FROM menuca_v3.restaurants
        WHERE id = p_restaurant_id AND deleted_at IS NULL
    ) THEN
        RAISE EXCEPTION 'Restaurant % does not exist', p_restaurant_id;
    END IF;

    -- Use restaurant location if center not provided
    IF p_center_latitude IS NULL OR p_center_longitude IS NULL THEN
        SELECT rl.latitude, rl.longitude
        INTO p_center_latitude, p_center_longitude
        FROM menuca_v3.restaurant_locations rl
        WHERE rl.restaurant_id = p_restaurant_id
          AND rl.deleted_at IS NULL
        LIMIT 1;
    END IF;

    -- Default radius if not provided
    IF p_radius_meters IS NULL THEN
        p_radius_meters := 5000; -- 5km default
    END IF;

    -- Create circular polygon from center and radius
    v_zone_geometry := ST_Buffer(
        ST_SetSRID(ST_MakePoint(p_center_longitude, p_center_latitude), 4326)::geography,
        p_radius_meters
    )::geometry;

    -- Calculate area
    v_area_sq_km := ROUND((ST_Area(v_zone_geometry::geography) / 1000000)::NUMERIC, 2);

    -- Get next area number
    SELECT COALESCE(MAX(area_number), 0) + 1 INTO v_area_number
    FROM menuca_v3.restaurant_delivery_areas
    WHERE restaurant_id = p_restaurant_id;

    -- Default zone name
    v_zone_name := COALESCE(p_zone_name, 'Delivery Zone ' || v_area_number);

    -- Insert area
    INSERT INTO menuca_v3.restaurant_delivery_areas (
        restaurant_id,
        area_number,
        area_name,
        fee_type,
        delivery_fee,
        min_order_value,
        estimated_delivery_minutes,
        geometry,
        is_active,
        created_by,
        created_at
    ) VALUES (
        p_restaurant_id,
        v_area_number,
        v_zone_name,
        CASE WHEN p_delivery_fee_cents = 0 THEN 'free' ELSE 'flat' END,
        CASE WHEN p_delivery_fee_cents = 0 THEN NULL ELSE p_delivery_fee_cents / 100.0 END,
        p_minimum_order_cents / 100.0,
        p_estimated_delivery_minutes,
        v_zone_geometry,
        true,
        p_created_by,
        NOW()
    )
    RETURNING id INTO v_zone_id;

    RETURN QUERY
    SELECT
        v_zone_id,
        v_zone_name,
        v_area_sq_km,
        p_delivery_fee_cents,
        p_minimum_order_cents,
        p_estimated_delivery_minutes;
END;
$$;

-- 2.11 Update find_nearest_franchise_locations
CREATE OR REPLACE FUNCTION menuca_v3.find_nearest_franchise_locations(
    p_parent_id bigint, 
    p_latitude numeric, 
    p_longitude numeric, 
    p_max_distance_km numeric DEFAULT 25, 
    p_limit integer DEFAULT 5
)
RETURNS TABLE(
    restaurant_id bigint, 
    restaurant_name character varying, 
    distance_km numeric, 
    can_deliver boolean, 
    delivery_fee_cents integer, 
    estimated_minutes integer, 
    status public.restaurant_status, 
    online_ordering_enabled boolean
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.id,
        r.name,
        ROUND((ST_Distance(
            rl.location_point::geography,
            ST_SetSRID(ST_MakePoint(p_longitude, p_latitude), 4326)::geography
        ) / 1000)::NUMERIC, 2) as distance_km,
        EXISTS(
            SELECT 1
            FROM menuca_v3.restaurant_delivery_areas rda
            WHERE rda.restaurant_id = r.id
              AND rda.is_active = true
              AND rda.deleted_at IS NULL
              AND ST_Contains(
                  rda.geometry,
                  ST_SetSRID(ST_MakePoint(p_longitude, p_latitude), 4326)
              )
        ) as can_deliver,
        (
            SELECT CASE 
                WHEN rda.fee_type = 'free' THEN 0
                ELSE COALESCE((rda.delivery_fee * 100)::integer, 0)
            END
            FROM menuca_v3.restaurant_delivery_areas rda
            WHERE rda.restaurant_id = r.id
              AND rda.is_active = true
              AND rda.deleted_at IS NULL
              AND ST_Contains(
                  rda.geometry,
                  ST_SetSRID(ST_MakePoint(p_longitude, p_latitude), 4326)
              )
            ORDER BY rda.area_number ASC
            LIMIT 1
        ) as delivery_fee_cents,
        (
            SELECT rda.estimated_delivery_minutes
            FROM menuca_v3.restaurant_delivery_areas rda
            WHERE rda.restaurant_id = r.id
              AND rda.is_active = true
              AND rda.deleted_at IS NULL
              AND ST_Contains(
                  rda.geometry,
                  ST_SetSRID(ST_MakePoint(p_longitude, p_latitude), 4326)
              )
            ORDER BY rda.area_number ASC
            LIMIT 1
        ) as estimated_minutes,
        r.status,
        r.online_ordering_enabled
    FROM menuca_v3.restaurants r
    JOIN menuca_v3.restaurant_locations rl ON r.id = rl.restaurant_id
    WHERE r.parent_restaurant_id = p_parent_id
      AND r.status = 'active'
      AND r.deleted_at IS NULL
      AND r.online_ordering_enabled = true
      AND rl.location_point IS NOT NULL
      AND ST_DWithin(
          rl.location_point::geography,
          ST_SetSRID(ST_MakePoint(p_longitude, p_latitude), 4326)::geography,
          p_max_distance_km * 1000
      )
    ORDER BY distance_km ASC
    LIMIT p_limit;
END;
$$;

