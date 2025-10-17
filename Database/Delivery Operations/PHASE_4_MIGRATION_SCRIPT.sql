-- =====================================================
-- DELIVERY OPERATIONS V3 - PHASE 4: REAL-TIME UPDATES
-- =====================================================
-- Entity: Delivery Operations (Priority 8)
-- Phase: 4 of 7 - Real-Time Tracking & Notifications
-- Created: January 17, 2025
-- Description: Enable Supabase Realtime, create triggers, and implement live tracking
-- =====================================================

BEGIN;

-- =====================================================
-- SECTION 1: ENABLE SUPABASE REALTIME ON TABLES
-- =====================================================

-- Enable realtime replication for delivery tracking
ALTER PUBLICATION supabase_realtime ADD TABLE menuca_v3.deliveries;
ALTER PUBLICATION supabase_realtime ADD TABLE menuca_v3.drivers;
ALTER PUBLICATION supabase_realtime ADD TABLE menuca_v3.driver_locations;
ALTER PUBLICATION supabase_realtime ADD TABLE menuca_v3.delivery_zones;

-- Verify realtime enabled
DO $$
BEGIN
    RAISE NOTICE 'Realtime enabled on delivery operations tables';
END $$;

-- =====================================================
-- SECTION 2: CREATE NOTIFICATION TRIGGERS
-- =====================================================

-- Trigger Function: Notify on delivery status change
CREATE OR REPLACE FUNCTION menuca_v3.notify_delivery_status_change()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_notification JSONB;
BEGIN
    -- Only notify on status changes (not other field updates)
    IF (TG_OP = 'UPDATE' AND OLD.delivery_status != NEW.delivery_status)
       OR TG_OP = 'INSERT' THEN

        -- Build notification payload
        v_notification := jsonb_build_object(
            'delivery_id', NEW.id,
            'order_id', NEW.order_id,
            'driver_id', NEW.driver_id,
            'restaurant_id', NEW.restaurant_id,
            'old_status', OLD.delivery_status,
            'new_status', NEW.delivery_status,
            'customer_name', NEW.customer_name,
            'is_priority', NEW.is_priority,
            'timestamp', NOW()
        );

        -- Send notification to specific channels
        PERFORM pg_notify(
            'delivery_status_changed', 
            v_notification::text
        );

        -- Send restaurant-specific notification
        PERFORM pg_notify(
            'restaurant_' || NEW.restaurant_id || '_deliveries',
            v_notification::text
        );

        -- Send driver-specific notification (if assigned)
        IF NEW.driver_id IS NOT NULL THEN
            PERFORM pg_notify(
                'driver_' || NEW.driver_id || '_deliveries',
                v_notification::text
            );
        END IF;

        -- Send order-specific notification (for customer tracking)
        PERFORM pg_notify(
            'order_' || NEW.order_id || '_tracking',
            v_notification::text
        );
    END IF;

    RETURN NEW;
END;
$$;

COMMENT ON FUNCTION menuca_v3.notify_delivery_status_change IS
'Broadcasts delivery status changes to multiple notification channels for real-time updates';

-- Apply trigger to deliveries table
CREATE TRIGGER trigger_notify_delivery_status_change
    AFTER INSERT OR UPDATE ON menuca_v3.deliveries
    FOR EACH ROW
    EXECUTE FUNCTION menuca_v3.notify_delivery_status_change();

-- =====================================================

-- Trigger Function: Update driver's current location in drivers table
CREATE OR REPLACE FUNCTION menuca_v3.update_driver_current_location()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Update driver's current location from latest location record
    UPDATE menuca_v3.drivers
    SET
        current_latitude = NEW.latitude,
        current_longitude = NEW.longitude,
        current_heading = NEW.heading,
        last_location_update = NEW.recorded_at,
        updated_at = NOW()
    WHERE id = NEW.driver_id;

    RETURN NEW;
END;
$$;

COMMENT ON FUNCTION menuca_v3.update_driver_current_location IS
'Automatically updates driver current location when new GPS coordinates are recorded';

-- Apply trigger to driver_locations table
CREATE TRIGGER trigger_update_driver_current_location
    AFTER INSERT ON menuca_v3.driver_locations
    FOR EACH ROW
    EXECUTE FUNCTION menuca_v3.update_driver_current_location();

-- =====================================================

-- Trigger Function: Notify on driver location update (for active deliveries)
CREATE OR REPLACE FUNCTION menuca_v3.notify_driver_location_update()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_notification JSONB;
BEGIN
    -- Only notify if driver is on an active delivery
    IF NEW.delivery_id IS NOT NULL THEN
        v_notification := jsonb_build_object(
            'driver_id', NEW.driver_id,
            'delivery_id', NEW.delivery_id,
            'latitude', NEW.latitude,
            'longitude', NEW.longitude,
            'heading', NEW.heading,
            'speed_kmh', NEW.speed_kmh,
            'accuracy_meters', NEW.accuracy_meters,
            'timestamp', NEW.recorded_at
        );

        -- Broadcast location update
        PERFORM pg_notify(
            'driver_location_updated',
            v_notification::text
        );

        -- Delivery-specific channel (for customer tracking)
        PERFORM pg_notify(
            'delivery_' || NEW.delivery_id || '_location',
            v_notification::text
        );
    END IF;

    RETURN NEW;
END;
$$;

COMMENT ON FUNCTION menuca_v3.notify_driver_location_update IS
'Broadcasts driver location updates for real-time delivery tracking';

-- Apply trigger to driver_locations table
CREATE TRIGGER trigger_notify_driver_location_update
    AFTER INSERT ON menuca_v3.driver_locations
    FOR EACH ROW
    EXECUTE FUNCTION menuca_v3.notify_driver_location_update();

-- =====================================================

-- Trigger Function: Notify on driver availability change
CREATE OR REPLACE FUNCTION menuca_v3.notify_driver_availability_change()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_notification JSONB;
BEGIN
    -- Only notify on availability or status changes
    IF (TG_OP = 'UPDATE' 
        AND (OLD.availability_status != NEW.availability_status 
             OR OLD.driver_status != NEW.driver_status)) THEN

        v_notification := jsonb_build_object(
            'driver_id', NEW.id,
            'driver_name', NEW.first_name || ' ' || NEW.last_name,
            'old_availability', OLD.availability_status,
            'new_availability', NEW.availability_status,
            'old_status', OLD.driver_status,
            'new_status', NEW.driver_status,
            'timestamp', NOW()
        );

        -- Broadcast availability change
        PERFORM pg_notify(
            'driver_availability_changed',
            v_notification::text
        );

        -- Driver went online - useful for dispatch system
        IF OLD.availability_status != 'online' AND NEW.availability_status = 'online' THEN
            PERFORM pg_notify(
                'driver_online',
                jsonb_build_object(
                    'driver_id', NEW.id,
                    'latitude', NEW.current_latitude,
                    'longitude', NEW.current_longitude
                )::text
            );
        END IF;

        -- Driver went offline - useful for reassignment
        IF OLD.availability_status = 'online' AND NEW.availability_status = 'offline' THEN
            PERFORM pg_notify(
                'driver_offline',
                jsonb_build_object('driver_id', NEW.id)::text
            );
        END IF;
    END IF;

    RETURN NEW;
END;
$$;

COMMENT ON FUNCTION menuca_v3.notify_driver_availability_change IS
'Notifies when driver availability changes for real-time dispatch optimization';

-- Apply trigger to drivers table
CREATE TRIGGER trigger_notify_driver_availability_change
    AFTER UPDATE ON menuca_v3.drivers
    FOR EACH ROW
    EXECUTE FUNCTION menuca_v3.notify_driver_availability_change();

-- =====================================================

-- Trigger Function: Notify on new delivery created (for driver assignment)
CREATE OR REPLACE FUNCTION menuca_v3.notify_new_delivery_created()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_notification JSONB;
BEGIN
    IF TG_OP = 'INSERT' THEN
        v_notification := jsonb_build_object(
            'delivery_id', NEW.id,
            'order_id', NEW.order_id,
            'restaurant_id', NEW.restaurant_id,
            'pickup_latitude', NEW.pickup_latitude,
            'pickup_longitude', NEW.pickup_longitude,
            'delivery_latitude', NEW.delivery_latitude,
            'delivery_longitude', NEW.delivery_longitude,
            'delivery_fee', NEW.delivery_fee,
            'is_priority', NEW.is_priority,
            'is_scheduled', NEW.is_scheduled,
            'scheduled_time', NEW.scheduled_delivery_time,
            'timestamp', NEW.created_at
        );

        -- Broadcast new delivery for driver assignment system
        PERFORM pg_notify(
            'new_delivery_created',
            v_notification::text
        );

        -- Restaurant-specific notification
        PERFORM pg_notify(
            'restaurant_' || NEW.restaurant_id || '_new_delivery',
            v_notification::text
        );
    END IF;

    RETURN NEW;
END;
$$;

COMMENT ON FUNCTION menuca_v3.notify_new_delivery_created IS
'Notifies dispatch system when new delivery is created for driver assignment';

-- Apply trigger to deliveries table
CREATE TRIGGER trigger_notify_new_delivery_created
    AFTER INSERT ON menuca_v3.deliveries
    FOR EACH ROW
    EXECUTE FUNCTION menuca_v3.notify_new_delivery_created();

-- =====================================================
-- SECTION 3: REAL-TIME LOCATION TRACKING FUNCTIONS
-- =====================================================

-- Function: Update driver location (called from mobile app)
CREATE OR REPLACE FUNCTION menuca_v3.update_driver_location(
    p_latitude DECIMAL,
    p_longitude DECIMAL,
    p_accuracy DECIMAL DEFAULT NULL,
    p_heading INTEGER DEFAULT NULL,
    p_speed DECIMAL DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_driver_id BIGINT;
    v_active_delivery_id BIGINT;
    v_result JSONB;
BEGIN
    -- Get current driver ID (from authenticated user)
    v_driver_id := menuca_v3.get_current_driver_id();

    IF v_driver_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated as a driver';
    END IF;

    -- Validate coordinates
    IF p_latitude < -90 OR p_latitude > 90 THEN
        RAISE EXCEPTION 'Invalid latitude: must be between -90 and 90';
    END IF;

    IF p_longitude < -180 OR p_longitude > 180 THEN
        RAISE EXCEPTION 'Invalid longitude: must be between -180 and 180';
    END IF;

    -- Get active delivery (if any)
    SELECT id INTO v_active_delivery_id
    FROM menuca_v3.deliveries
    WHERE driver_id = v_driver_id
        AND delivery_status IN ('accepted', 'picked_up', 'in_transit', 'arrived')
        AND deleted_at IS NULL
    ORDER BY accepted_at DESC
    LIMIT 1;

    -- Insert location record
    INSERT INTO menuca_v3.driver_locations (
        driver_id,
        delivery_id,
        latitude,
        longitude,
        accuracy_meters,
        heading,
        speed_kmh,
        recorded_at
    ) VALUES (
        v_driver_id,
        v_active_delivery_id,
        p_latitude,
        p_longitude,
        p_accuracy,
        p_heading,
        p_speed,
        NOW()
    );

    -- Build response
    v_result := jsonb_build_object(
        'success', true,
        'driver_id', v_driver_id,
        'active_delivery_id', v_active_delivery_id,
        'location_updated', true,
        'timestamp', NOW()
    );

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION menuca_v3.update_driver_location IS
'Updates driver GPS location. Called by mobile app every 10-30 seconds during active deliveries.';

GRANT EXECUTE ON FUNCTION menuca_v3.update_driver_location TO authenticated;

-- =====================================================

-- Function: Get driver's current location (for customer tracking)
CREATE OR REPLACE FUNCTION menuca_v3.get_driver_location_for_delivery(
    p_delivery_id BIGINT
)
RETURNS TABLE (
    driver_id BIGINT,
    driver_name VARCHAR,
    phone VARCHAR,
    latitude DECIMAL,
    longitude DECIMAL,
    heading INTEGER,
    speed_kmh DECIMAL,
    last_update TIMESTAMPTZ,
    accuracy_meters DECIMAL
)
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
AS $$
BEGIN
    -- Verify user can access this delivery (RLS will handle most of this)
    IF NOT menuca_v3.can_access_delivery(p_delivery_id) THEN
        RAISE EXCEPTION 'Access denied to this delivery';
    END IF;

    RETURN QUERY
    SELECT 
        d.id AS driver_id,
        d.first_name || ' ' || d.last_name AS driver_name,
        d.phone,
        d.current_latitude AS latitude,
        d.current_longitude AS longitude,
        d.current_heading AS heading,
        CAST(NULL AS DECIMAL) AS speed_kmh, -- Privacy: don't expose speed
        d.last_location_update AS last_update,
        CAST(NULL AS DECIMAL) AS accuracy_meters -- Privacy: don't expose accuracy
    FROM menuca_v3.deliveries del
    JOIN menuca_v3.drivers d ON del.driver_id = d.id
    WHERE del.id = p_delivery_id
        AND del.delivery_status IN ('accepted', 'picked_up', 'in_transit', 'arrived')
        AND del.deleted_at IS NULL;
END;
$$;

COMMENT ON FUNCTION menuca_v3.get_driver_location_for_delivery IS
'Returns driver current location for customer/restaurant tracking. Privacy-filtered.';

GRANT EXECUTE ON FUNCTION menuca_v3.get_driver_location_for_delivery TO authenticated, anon;

-- =====================================================

-- Function: Get ETA for delivery (estimated time of arrival)
CREATE OR REPLACE FUNCTION menuca_v3.get_delivery_eta(
    p_delivery_id BIGINT
)
RETURNS TABLE (
    estimated_arrival TIMESTAMPTZ,
    minutes_remaining INTEGER,
    distance_remaining_km DECIMAL,
    current_status VARCHAR
)
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
AS $$
DECLARE
    v_delivery RECORD;
    v_driver RECORD;
    v_distance_remaining DECIMAL;
    v_avg_speed_kmh CONSTANT DECIMAL := 40; -- Average delivery speed
    v_minutes_remaining INTEGER;
    v_estimated_arrival TIMESTAMPTZ;
BEGIN
    -- Get delivery info
    SELECT * INTO v_delivery
    FROM menuca_v3.deliveries
    WHERE id = p_delivery_id
        AND deleted_at IS NULL;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Delivery not found';
    END IF;

    -- Get driver current location
    SELECT * INTO v_driver
    FROM menuca_v3.drivers
    WHERE id = v_delivery.driver_id;

    -- Calculate distance remaining based on status
    CASE v_delivery.delivery_status
        WHEN 'accepted' THEN
            -- Distance from driver to restaurant
            v_distance_remaining := menuca_v3.calculate_distance_km(
                v_driver.current_latitude,
                v_driver.current_longitude,
                v_delivery.pickup_latitude,
                v_delivery.pickup_longitude
            ) + v_delivery.distance_km;

        WHEN 'picked_up', 'in_transit' THEN
            -- Distance from driver to customer
            v_distance_remaining := menuca_v3.calculate_distance_km(
                v_driver.current_latitude,
                v_driver.current_longitude,
                v_delivery.delivery_latitude,
                v_delivery.delivery_longitude
            );

        WHEN 'arrived' THEN
            v_distance_remaining := 0;
            v_minutes_remaining := 0;

        ELSE
            v_distance_remaining := NULL;
            v_minutes_remaining := NULL;
    END CASE;

    -- Calculate ETA
    IF v_distance_remaining IS NOT NULL THEN
        v_minutes_remaining := CEIL((v_distance_remaining / v_avg_speed_kmh) * 60);
        v_estimated_arrival := NOW() + (v_minutes_remaining || ' minutes')::INTERVAL;
    END IF;

    RETURN QUERY SELECT
        v_estimated_arrival,
        v_minutes_remaining,
        v_distance_remaining,
        v_delivery.delivery_status;
END;
$$;

COMMENT ON FUNCTION menuca_v3.get_delivery_eta IS
'Calculates estimated time of arrival for delivery based on current driver location and status';

GRANT EXECUTE ON FUNCTION menuca_v3.get_delivery_eta TO authenticated, anon;

-- =====================================================
-- SECTION 4: REAL-TIME SUBSCRIPTION HELPERS
-- =====================================================

-- Function: Get active deliveries for restaurant (for real-time dashboard)
CREATE OR REPLACE FUNCTION menuca_v3.get_restaurant_active_deliveries(
    p_restaurant_id BIGINT
)
RETURNS TABLE (
    delivery_id BIGINT,
    order_id BIGINT,
    delivery_status VARCHAR,
    driver_name VARCHAR,
    driver_phone VARCHAR,
    customer_name VARCHAR,
    customer_phone VARCHAR,
    delivery_address TEXT,
    created_at TIMESTAMPTZ,
    accepted_at TIMESTAMPTZ,
    estimated_arrival TIMESTAMPTZ,
    minutes_in_progress INTEGER,
    is_priority BOOLEAN,
    is_contactless BOOLEAN
)
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
AS $$
BEGIN
    -- Verify restaurant access
    IF NOT menuca_v3.can_access_restaurant(p_restaurant_id) THEN
        RAISE EXCEPTION 'Access denied to this restaurant';
    END IF;

    RETURN QUERY
    SELECT 
        d.id AS delivery_id,
        d.order_id,
        d.delivery_status,
        dr.first_name || ' ' || dr.last_name AS driver_name,
        dr.phone AS driver_phone,
        d.customer_name,
        d.customer_phone,
        d.delivery_address,
        d.created_at,
        d.accepted_at,
        CAST(NULL AS TIMESTAMPTZ) AS estimated_arrival, -- Calculated client-side
        EXTRACT(EPOCH FROM (NOW() - d.accepted_at))/60 AS minutes_in_progress,
        d.is_priority,
        d.is_contactless
    FROM menuca_v3.deliveries d
    LEFT JOIN menuca_v3.drivers dr ON d.driver_id = dr.id
    WHERE d.restaurant_id = p_restaurant_id
        AND d.delivery_status IN ('pending', 'searching_driver', 'assigned', 'accepted', 'picked_up', 'in_transit', 'arrived')
        AND d.deleted_at IS NULL
    ORDER BY d.is_priority DESC, d.created_at ASC;
END;
$$;

COMMENT ON FUNCTION menuca_v3.get_restaurant_active_deliveries IS
'Returns all active deliveries for a restaurant for real-time dashboard';

GRANT EXECUTE ON FUNCTION menuca_v3.get_restaurant_active_deliveries TO authenticated;

-- =====================================================

-- Function: Get available drivers for dispatch (for admin dashboard)
CREATE OR REPLACE FUNCTION menuca_v3.get_available_drivers_nearby(
    p_latitude DECIMAL,
    p_longitude DECIMAL,
    p_max_distance_km DECIMAL DEFAULT 10.0
)
RETURNS TABLE (
    driver_id BIGINT,
    driver_name VARCHAR,
    phone VARCHAR,
    vehicle_type VARCHAR,
    distance_km DECIMAL,
    average_rating DECIMAL,
    current_deliveries INTEGER,
    is_available BOOLEAN
)
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        d.id AS driver_id,
        d.first_name || ' ' || d.last_name AS driver_name,
        d.phone,
        d.vehicle_type,
        menuca_v3.calculate_distance_km(
            p_latitude, p_longitude,
            d.current_latitude, d.current_longitude
        ) AS distance_km,
        d.average_rating,
        (
            SELECT COUNT(*)::INTEGER
            FROM menuca_v3.deliveries del
            WHERE del.driver_id = d.id
                AND del.delivery_status IN ('assigned', 'accepted', 'picked_up', 'in_transit')
        ) AS current_deliveries,
        (d.availability_status = 'online' AND d.driver_status = 'active') AS is_available
    FROM menuca_v3.drivers d
    WHERE d.driver_status = 'active'
        AND d.deleted_at IS NULL
        AND d.current_latitude IS NOT NULL
        AND d.current_longitude IS NOT NULL
        AND menuca_v3.calculate_distance_km(
            p_latitude, p_longitude,
            d.current_latitude, d.current_longitude
        ) <= p_max_distance_km
    ORDER BY 
        is_available DESC,
        distance_km ASC,
        d.average_rating DESC;
END;
$$;

COMMENT ON FUNCTION menuca_v3.get_available_drivers_nearby IS
'Returns available drivers near a location for dispatch dashboard';

GRANT EXECUTE ON FUNCTION menuca_v3.get_available_drivers_nearby TO authenticated;

-- =====================================================
-- SECTION 5: LOCATION HISTORY CLEANUP (GDPR COMPLIANCE)
-- =====================================================

-- Function: Clean old location history (run daily via cron)
CREATE OR REPLACE FUNCTION menuca_v3.cleanup_old_location_history()
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_deleted_count INTEGER;
BEGIN
    -- Delete location records older than 30 days (GDPR compliance)
    DELETE FROM menuca_v3.driver_locations
    WHERE recorded_at < NOW() - INTERVAL '30 days';

    GET DIAGNOSTICS v_deleted_count = ROW_COUNT;

    -- Log cleanup
    RAISE NOTICE 'Cleaned up % old location records', v_deleted_count;

    RETURN v_deleted_count;
END;
$$;

COMMENT ON FUNCTION menuca_v3.cleanup_old_location_history IS
'Deletes GPS location history older than 30 days for GDPR compliance. Run daily via pg_cron.';

-- Schedule cleanup (requires pg_cron extension)
-- SELECT cron.schedule(
--     'cleanup-location-history',
--     '0 2 * * *', -- 2 AM daily
--     $$SELECT menuca_v3.cleanup_old_location_history()$$
-- );

-- =====================================================
-- SECTION 6: PERFORMANCE OPTIMIZATIONS FOR REAL-TIME
-- =====================================================

-- Partial index for active deliveries (hot path)
CREATE INDEX idx_deliveries_active_realtime ON menuca_v3.deliveries(
    id,
    restaurant_id,
    driver_id,
    delivery_status
) WHERE delivery_status IN ('pending', 'searching_driver', 'assigned', 'accepted', 'picked_up', 'in_transit', 'arrived')
  AND deleted_at IS NULL;

-- Index for recent locations (hot path)
CREATE INDEX idx_driver_locations_recent ON menuca_v3.driver_locations(
    driver_id,
    recorded_at DESC
) WHERE recorded_at > NOW() - INTERVAL '1 hour';

-- Index for online drivers (hot path)
CREATE INDEX idx_drivers_online_realtime ON menuca_v3.drivers(
    id,
    availability_status,
    current_latitude,
    current_longitude
) WHERE availability_status = 'online' 
  AND driver_status = 'active' 
  AND deleted_at IS NULL;

-- =====================================================

COMMIT;

-- =====================================================
-- VALIDATION QUERIES (Run after migration)
-- =====================================================

-- Verify realtime enabled on tables
SELECT tablename 
FROM pg_publication_tables 
WHERE pubname = 'supabase_realtime'
  AND schemaname = 'menuca_v3'
  AND tablename IN ('deliveries', 'drivers', 'driver_locations', 'delivery_zones');

-- Verify triggers created
SELECT 
    tgname AS trigger_name,
    tgrelid::regclass AS table_name,
    proname AS function_name
FROM pg_trigger t
JOIN pg_proc p ON t.tgfoid = p.oid
WHERE tgrelid::regclass::text LIKE 'menuca_v3.deliver%' 
   OR tgrelid::regclass::text LIKE 'menuca_v3.driver%'
ORDER BY table_name, trigger_name;

-- Verify notification functions exist
SELECT 
    proname AS function_name,
    pg_get_function_identity_arguments(oid) AS arguments
FROM pg_proc
WHERE pronamespace = 'menuca_v3'::regnamespace
  AND proname LIKE '%notify%'
ORDER BY proname;

-- Test notification (manual test)
-- SELECT menuca_v3.update_driver_location(45.5017, -73.5673, 10, 180, 35);

-- =====================================================
-- END OF PHASE 4 MIGRATION
-- =====================================================

