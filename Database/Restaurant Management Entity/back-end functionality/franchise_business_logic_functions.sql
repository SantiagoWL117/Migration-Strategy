-- ========================================================================
-- Franchise/Chain Hierarchy - Business Logic Functions
-- ========================================================================
-- Description: Backend functions for franchise chain management
-- Dependencies: Franchise hierarchy schema must be in place
-- Author: Santiago
-- Date: 2025-10-16
-- Status: Production Ready
-- ========================================================================

-- ========================================================================
-- FUNCTION 1: get_franchise_children()
-- ========================================================================
-- Purpose: Get all child locations for a franchise parent
-- Returns: List of child restaurants with key details
-- Usage: SELECT * FROM menuca_v3.get_franchise_children(986);
-- ========================================================================

CREATE OR REPLACE FUNCTION menuca_v3.get_franchise_children(
    p_parent_id BIGINT
)
RETURNS TABLE (
    child_id BIGINT,
    child_name VARCHAR,
    status menuca_v3.restaurant_status,
    online_ordering_enabled BOOLEAN,
    activated_at TIMESTAMPTZ,
    timezone VARCHAR,
    created_at TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.id,
        r.name,
        r.status,
        r.online_ordering_enabled,
        r.activated_at,
        r.timezone,
        r.created_at
    FROM menuca_v3.restaurants r
    WHERE r.parent_restaurant_id = p_parent_id
      AND r.deleted_at IS NULL
    ORDER BY r.name;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION menuca_v3.get_franchise_children IS 
    'Get all child locations for a franchise parent. Returns empty if parent has no children.';

-- ========================================================================
-- FUNCTION 2: get_franchise_summary()
-- ========================================================================
-- Purpose: Get high-level summary statistics for a franchise chain
-- Returns: Aggregated counts and date ranges
-- Usage: SELECT * FROM menuca_v3.get_franchise_summary(986);
-- ========================================================================

CREATE OR REPLACE FUNCTION menuca_v3.get_franchise_summary(
    p_parent_id BIGINT
)
RETURNS TABLE (
    chain_id BIGINT,
    brand_name VARCHAR,
    total_locations INTEGER,
    active_count INTEGER,
    suspended_count INTEGER,
    pending_count INTEGER,
    inactive_count INTEGER,
    closed_count INTEGER,
    oldest_location_date TIMESTAMPTZ,
    newest_location_date TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p_parent_id,
        p.franchise_brand_name,
        COUNT(c.id)::INTEGER as total_locations,
        COUNT(c.id) FILTER (WHERE c.status = 'active')::INTEGER as active_count,
        COUNT(c.id) FILTER (WHERE c.status = 'suspended')::INTEGER as suspended_count,
        COUNT(c.id) FILTER (WHERE c.status = 'pending')::INTEGER as pending_count,
        COUNT(c.id) FILTER (WHERE c.status = 'inactive')::INTEGER as inactive_count,
        COUNT(c.id) FILTER (WHERE c.status = 'closed')::INTEGER as closed_count,
        MIN(c.activated_at) as oldest_location_date,
        MAX(c.activated_at) as newest_location_date
    FROM menuca_v3.restaurants p
    LEFT JOIN menuca_v3.restaurants c 
        ON c.parent_restaurant_id = p.id
        AND c.deleted_at IS NULL
    WHERE p.id = p_parent_id
      AND p.is_franchise_parent = true
      AND p.deleted_at IS NULL
    GROUP BY p.franchise_brand_name;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION menuca_v3.get_franchise_summary IS 
    'Get high-level summary statistics for a franchise chain.';

-- ========================================================================
-- FUNCTION 3: is_franchise_location()
-- ========================================================================
-- Purpose: Check if a restaurant is part of a franchise chain
-- Returns: Boolean - true if franchise location, false if independent
-- Usage: SELECT menuca_v3.is_franchise_location(3);
-- ========================================================================

CREATE OR REPLACE FUNCTION menuca_v3.is_franchise_location(
    p_restaurant_id BIGINT
)
RETURNS BOOLEAN AS $$
    SELECT parent_restaurant_id IS NOT NULL
    FROM menuca_v3.restaurants
    WHERE id = p_restaurant_id
      AND deleted_at IS NULL;
$$ LANGUAGE SQL STABLE;

COMMENT ON FUNCTION menuca_v3.is_franchise_location IS 
    'Check if a restaurant is part of a franchise chain. Returns FALSE for independent restaurants.';

-- ========================================================================
-- FUNCTION 4: get_franchise_parent()
-- ========================================================================
-- Purpose: Get the parent restaurant details for a franchise location
-- Returns: Parent restaurant record or NULL if independent
-- Usage: SELECT * FROM menuca_v3.get_franchise_parent(624);
-- ========================================================================

CREATE OR REPLACE FUNCTION menuca_v3.get_franchise_parent(
    p_child_id BIGINT
)
RETURNS TABLE (
    parent_id BIGINT,
    brand_name VARCHAR,
    parent_name VARCHAR,
    status menuca_v3.restaurant_status,
    created_at TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id,
        p.franchise_brand_name,
        p.name,
        p.status,
        p.created_at
    FROM menuca_v3.restaurants c
    JOIN menuca_v3.restaurants p 
        ON p.id = c.parent_restaurant_id
        AND p.is_franchise_parent = true
        AND p.deleted_at IS NULL
    WHERE c.id = p_child_id
      AND c.deleted_at IS NULL;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION menuca_v3.get_franchise_parent IS 
    'Get the parent restaurant details for a franchise location. Returns empty if restaurant is independent.';

-- ========================================================================
-- FUNCTION 5: find_nearest_franchise_locations()
-- ========================================================================
-- Purpose: Find nearest franchise locations by geospatial proximity
-- Returns: List of franchise locations sorted by distance
-- Usage: SELECT * FROM menuca_v3.find_nearest_franchise_locations(986, 45.4215, -75.6972, 25, 5);
-- Requires: PostGIS extension
-- ========================================================================

CREATE OR REPLACE FUNCTION menuca_v3.find_nearest_franchise_locations(
    p_parent_id BIGINT,
    p_latitude NUMERIC,
    p_longitude NUMERIC,
    p_max_distance_km NUMERIC DEFAULT 25,
    p_limit INTEGER DEFAULT 5
)
RETURNS TABLE (
    restaurant_id BIGINT,
    restaurant_name VARCHAR,
    distance_km NUMERIC,
    can_deliver BOOLEAN,
    delivery_fee_cents INTEGER,
    estimated_minutes INTEGER,
    status menuca_v3.restaurant_status,
    online_ordering_enabled BOOLEAN
) AS $$
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
            FROM menuca_v3.restaurant_delivery_zones rdz
            WHERE rdz.restaurant_id = r.id
              AND rdz.is_active = true
              AND ST_Contains(
                  rdz.zone_geometry,
                  ST_SetSRID(ST_MakePoint(p_longitude, p_latitude), 4326)
              )
        ) as can_deliver,
        (
            SELECT rdz.delivery_fee_cents
            FROM menuca_v3.restaurant_delivery_zones rdz
            WHERE rdz.restaurant_id = r.id
              AND rdz.is_active = true
              AND ST_Contains(
                  rdz.zone_geometry,
                  ST_SetSRID(ST_MakePoint(p_longitude, p_latitude), 4326)
              )
            ORDER BY rdz.delivery_fee_cents ASC
            LIMIT 1
        ) as delivery_fee_cents,
        (
            SELECT rdz.estimated_delivery_minutes
            FROM menuca_v3.restaurant_delivery_zones rdz
            WHERE rdz.restaurant_id = r.id
              AND rdz.is_active = true
              AND ST_Contains(
                  rdz.zone_geometry,
                  ST_SetSRID(ST_MakePoint(p_longitude, p_latitude), 4326)
              )
            ORDER BY rdz.delivery_fee_cents ASC
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
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION menuca_v3.find_nearest_franchise_locations IS 
    'Find nearest franchise locations within a radius. Includes delivery zone validation.';

-- ========================================================================
-- FUNCTION 6: bulk_update_franchise_feature()
-- ========================================================================
-- Purpose: Enable/disable a feature for all franchise locations
-- Returns: Number of locations updated
-- Usage: SELECT menuca_v3.bulk_update_franchise_feature(986, 'loyalty_program', true);
-- ========================================================================

CREATE OR REPLACE FUNCTION menuca_v3.bulk_update_franchise_feature(
    p_parent_id BIGINT,
    p_feature_key VARCHAR,
    p_is_enabled BOOLEAN,
    p_updated_by BIGINT DEFAULT NULL
)
RETURNS INTEGER AS $$
DECLARE
    v_updated_count INTEGER;
BEGIN
    -- Update or insert feature for all child locations
    WITH child_restaurants AS (
        SELECT id FROM menuca_v3.restaurants
        WHERE parent_restaurant_id = p_parent_id
          AND deleted_at IS NULL
    )
    INSERT INTO menuca_v3.restaurant_features (
        restaurant_id,
        feature_key,
        is_enabled,
        enabled_at,
        enabled_by,
        disabled_at,
        disabled_by
    )
    SELECT 
        cr.id,
        p_feature_key,
        p_is_enabled,
        CASE WHEN p_is_enabled THEN NOW() ELSE NULL END,
        CASE WHEN p_is_enabled THEN p_updated_by ELSE NULL END,
        CASE WHEN NOT p_is_enabled THEN NOW() ELSE NULL END,
        CASE WHEN NOT p_is_enabled THEN p_updated_by ELSE NULL END
    FROM child_restaurants cr
    ON CONFLICT (restaurant_id, feature_key) DO UPDATE
    SET 
        is_enabled = p_is_enabled,
        enabled_at = CASE WHEN p_is_enabled THEN NOW() ELSE restaurant_features.enabled_at END,
        enabled_by = CASE WHEN p_is_enabled THEN p_updated_by ELSE restaurant_features.enabled_by END,
        disabled_at = CASE WHEN NOT p_is_enabled THEN NOW() ELSE restaurant_features.disabled_at END,
        disabled_by = CASE WHEN NOT p_is_enabled THEN p_updated_by ELSE restaurant_features.disabled_by END,
        updated_at = NOW();
    
    GET DIAGNOSTICS v_updated_count = ROW_COUNT;
    RETURN v_updated_count;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION menuca_v3.bulk_update_franchise_feature IS 
    'Enable or disable a feature for all franchise child locations in a single operation.';

-- ========================================================================
-- FUNCTION 7: get_franchise_performance_summary()
-- ========================================================================
-- Purpose: Get aggregated performance metrics for a franchise
-- Returns: Revenue, order counts, ratings (requires orders table)
-- Usage: SELECT * FROM menuca_v3.get_franchise_performance_summary(986, INTERVAL '30 days');
-- Note: This is a template - customize based on your orders schema
-- ========================================================================

CREATE OR REPLACE FUNCTION menuca_v3.get_franchise_performance_summary(
    p_parent_id BIGINT,
    p_period INTERVAL DEFAULT INTERVAL '30 days'
)
RETURNS TABLE (
    chain_id BIGINT,
    brand_name VARCHAR,
    total_locations INTEGER,
    active_locations INTEGER,
    reporting_period VARCHAR,
    total_orders BIGINT,
    total_revenue NUMERIC,
    avg_order_value NUMERIC,
    top_location_id BIGINT,
    top_location_name VARCHAR,
    top_location_revenue NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    WITH franchise_info AS (
        SELECT 
            p.id,
            p.franchise_brand_name,
            COUNT(c.id)::INTEGER as location_count,
            COUNT(c.id) FILTER (WHERE c.status = 'active')::INTEGER as active_count
        FROM menuca_v3.restaurants p
        LEFT JOIN menuca_v3.restaurants c ON c.parent_restaurant_id = p.id
        WHERE p.id = p_parent_id
          AND p.is_franchise_parent = true
          AND p.deleted_at IS NULL
          AND c.deleted_at IS NULL
        GROUP BY p.id, p.franchise_brand_name
    ),
    location_metrics AS (
        SELECT 
            r.id as location_id,
            r.name as location_name,
            COUNT(o.id) as order_count,
            COALESCE(SUM(o.total_amount), 0) as revenue,
            COALESCE(AVG(o.total_amount), 0) as avg_order
        FROM menuca_v3.restaurants r
        LEFT JOIN menuca_v3.orders o 
            ON o.restaurant_id = r.id
            AND o.created_at >= NOW() - p_period
            AND o.order_status = 'delivered'
        WHERE r.parent_restaurant_id = p_parent_id
          AND r.deleted_at IS NULL
        GROUP BY r.id, r.name
    ),
    top_performer AS (
        SELECT location_id, location_name, revenue
        FROM location_metrics
        ORDER BY revenue DESC
        LIMIT 1
    )
    SELECT 
        fi.id,
        fi.franchise_brand_name,
        fi.location_count,
        fi.active_count,
        p_period::TEXT,
        SUM(lm.order_count),
        SUM(lm.revenue),
        AVG(lm.avg_order),
        tp.location_id,
        tp.location_name,
        tp.revenue
    FROM franchise_info fi
    CROSS JOIN location_metrics lm
    CROSS JOIN top_performer tp
    GROUP BY fi.id, fi.franchise_brand_name, fi.location_count, fi.active_count, 
             tp.location_id, tp.location_name, tp.revenue;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION menuca_v3.get_franchise_performance_summary IS 
    'Get aggregated performance metrics for a franchise over a time period. Customize based on your orders schema.';

-- ========================================================================
-- FUNCTION 8: validate_franchise_hierarchy()
-- ========================================================================
-- Purpose: Validate franchise hierarchy integrity (no orphans, no circular refs)
-- Returns: List of validation issues found
-- Usage: SELECT * FROM menuca_v3.validate_franchise_hierarchy();
-- ========================================================================

CREATE OR REPLACE FUNCTION menuca_v3.validate_franchise_hierarchy()
RETURNS TABLE (
    issue_type VARCHAR,
    restaurant_id BIGINT,
    restaurant_name VARCHAR,
    issue_description TEXT
) AS $$
BEGIN
    -- Check 1: Children with non-existent parents
    RETURN QUERY
    SELECT 
        'orphaned_child'::VARCHAR,
        c.id,
        c.name,
        'Child restaurant points to non-existent parent ID: ' || c.parent_restaurant_id::TEXT
    FROM menuca_v3.restaurants c
    LEFT JOIN menuca_v3.restaurants p ON p.id = c.parent_restaurant_id
    WHERE c.parent_restaurant_id IS NOT NULL
      AND c.deleted_at IS NULL
      AND (p.id IS NULL OR p.deleted_at IS NOT NULL);
    
    -- Check 2: Parents without franchise_brand_name
    RETURN QUERY
    SELECT 
        'missing_brand_name'::VARCHAR,
        r.id,
        r.name,
        'Franchise parent missing franchise_brand_name'
    FROM menuca_v3.restaurants r
    WHERE r.is_franchise_parent = true
      AND r.deleted_at IS NULL
      AND (r.franchise_brand_name IS NULL OR TRIM(r.franchise_brand_name) = '');
    
    -- Check 3: Self-references (should be prevented by constraint)
    RETURN QUERY
    SELECT 
        'self_reference'::VARCHAR,
        r.id,
        r.name,
        'Restaurant is its own parent (constraint violation)'
    FROM menuca_v3.restaurants r
    WHERE r.id = r.parent_restaurant_id
      AND r.deleted_at IS NULL;
    
    -- Check 4: Children marked as franchise_parent
    RETURN QUERY
    SELECT 
        'child_marked_as_parent'::VARCHAR,
        r.id,
        r.name,
        'Restaurant has parent_restaurant_id but is marked as franchise parent'
    FROM menuca_v3.restaurants r
    WHERE r.parent_restaurant_id IS NOT NULL
      AND r.is_franchise_parent = true
      AND r.deleted_at IS NULL;
    
    -- Check 5: Multi-level hierarchy (currently not supported)
    RETURN QUERY
    SELECT 
        'multi_level_hierarchy'::VARCHAR,
        c2.id,
        c2.name,
        'Multi-level hierarchy detected: grandchild restaurant'
    FROM menuca_v3.restaurants c2
    JOIN menuca_v3.restaurants c1 ON c2.parent_restaurant_id = c1.id
    WHERE c1.parent_restaurant_id IS NOT NULL
      AND c2.deleted_at IS NULL
      AND c1.deleted_at IS NULL;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION menuca_v3.validate_franchise_hierarchy IS 
    'Validate franchise hierarchy integrity. Returns empty result if no issues found.';

-- ========================================================================
-- VERIFICATION QUERIES
-- ========================================================================

-- Test Query 1: Get Milano Pizza children
-- SELECT * FROM menuca_v3.get_franchise_children(986);

-- Test Query 2: Get Milano Pizza summary
-- SELECT * FROM menuca_v3.get_franchise_summary(986);

-- Test Query 3: Check if restaurant 624 is a franchise location
-- SELECT menuca_v3.is_franchise_location(624);

-- Test Query 4: Get parent for Milano location 624
-- SELECT * FROM menuca_v3.get_franchise_parent(624);

-- Test Query 5: Find nearest Milano locations (requires actual coordinates)
-- SELECT * FROM menuca_v3.find_nearest_franchise_locations(986, 45.4215, -75.6972, 25, 5);

-- Test Query 6: Bulk enable loyalty program for all Milano locations
-- SELECT menuca_v3.bulk_update_franchise_feature(986, 'loyalty_program', true, 1);

-- Test Query 7: Validate hierarchy integrity
-- SELECT * FROM menuca_v3.validate_franchise_hierarchy();

-- Test Query 8: Get performance summary (customize for your orders schema)
-- SELECT * FROM menuca_v3.get_franchise_performance_summary(986, INTERVAL '30 days');

-- ========================================================================
-- END OF FRANCHISE BUSINESS LOGIC FUNCTIONS
-- ========================================================================

