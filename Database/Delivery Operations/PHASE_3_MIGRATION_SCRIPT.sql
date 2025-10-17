-- =====================================================
-- DELIVERY OPERATIONS V3 - PHASE 3: SCHEMA OPTIMIZATION
-- =====================================================
-- Entity: Delivery Operations (Priority 8)
-- Phase: 3 of 7 - Schema Optimization & Data Validation
-- Created: January 17, 2025
-- Description: Add enum types, constraints, validation rules, and optimize schema
-- =====================================================

BEGIN;

-- =====================================================
-- SECTION 1: CREATE ENUM TYPES FOR TYPE SAFETY
-- =====================================================

-- Driver status enum
CREATE TYPE menuca_v3.driver_status_type AS ENUM (
    'pending',      -- Application submitted, awaiting approval
    'approved',     -- Background check passed, can activate account
    'active',       -- Currently working deliveries
    'inactive',     -- Temporarily paused (vacation, etc.)
    'suspended',    -- Temporarily banned (performance issues)
    'blocked'       -- Permanently banned
);

COMMENT ON TYPE menuca_v3.driver_status_type IS 
'Driver account status lifecycle: pending → approved → active ↔ inactive, with admin overrides for suspended/blocked';

-- =====================================================

-- Availability status enum
CREATE TYPE menuca_v3.availability_status_type AS ENUM (
    'online',       -- Accepting delivery requests
    'offline',      -- Not working
    'busy',         -- Currently on delivery
    'on_break'      -- Temporarily unavailable
);

COMMENT ON TYPE menuca_v3.availability_status_type IS 
'Real-time driver availability for delivery assignment';

-- =====================================================

-- Delivery status enum
CREATE TYPE menuca_v3.delivery_status_type AS ENUM (
    'pending',              -- Order placed, awaiting driver
    'searching_driver',     -- Actively searching for available driver
    'assigned',            -- Driver assigned, awaiting acceptance
    'accepted',            -- Driver accepted delivery
    'picked_up',           -- Driver picked up food from restaurant
    'in_transit',          -- Driver en route to customer
    'arrived',             -- Driver arrived at customer location
    'delivered',           -- Successfully delivered (terminal)
    'cancelled',           -- Cancelled by customer/driver/restaurant (terminal)
    'failed'               -- Delivery failed (terminal)
);

COMMENT ON TYPE menuca_v3.delivery_status_type IS 
'Delivery status flow: pending → searching → assigned → accepted → picked_up → in_transit → arrived → delivered';

-- =====================================================

-- Vehicle type enum
CREATE TYPE menuca_v3.vehicle_type_enum AS ENUM (
    'car',
    'bike',
    'motorcycle',
    'scooter',
    'bicycle',
    'walk'
);

COMMENT ON TYPE menuca_v3.vehicle_type_enum IS 
'Driver vehicle types for delivery assignments and insurance tracking';

-- =====================================================

-- Zone type enum
CREATE TYPE menuca_v3.zone_type_enum AS ENUM (
    'circle',       -- Center point + radius (most common)
    'polygon',      -- PostGIS polygon boundary
    'radius'        -- Legacy (use circle instead)
);

COMMENT ON TYPE menuca_v3.zone_type_enum IS 
'Delivery zone geometry types for geofencing';

-- =====================================================

-- Payment status enum
CREATE TYPE menuca_v3.payment_status_type AS ENUM (
    'pending',      -- Earned but not yet approved for payout
    'approved',     -- Approved for payout, in batch processing
    'paid',         -- Successfully paid to driver
    'disputed',     -- Payment disputed
    'refunded'      -- Payment refunded/reversed
);

COMMENT ON TYPE menuca_v3.payment_status_type IS 
'Driver earnings payment lifecycle';

-- =====================================================

-- Background check status enum
CREATE TYPE menuca_v3.background_check_status_type AS ENUM (
    'pending',
    'approved',
    'rejected'
);

-- =====================================================

-- Location source enum
CREATE TYPE menuca_v3.location_source_type AS ENUM (
    'gps',
    'network',
    'manual'
);

-- =====================================================
-- SECTION 2: ADD VALIDATION CONSTRAINTS
-- =====================================================

-- Add check constraints for coordinate validation
ALTER TABLE menuca_v3.drivers
    ADD CONSTRAINT chk_drivers_latitude_valid 
        CHECK (current_latitude IS NULL OR (current_latitude >= -90 AND current_latitude <= 90)),
    ADD CONSTRAINT chk_drivers_longitude_valid 
        CHECK (current_longitude IS NULL OR (current_longitude >= -180 AND current_longitude <= 180));

ALTER TABLE menuca_v3.delivery_zones
    ADD CONSTRAINT chk_zones_latitude_valid 
        CHECK (center_latitude IS NULL OR (center_latitude >= -90 AND center_latitude <= 90)),
    ADD CONSTRAINT chk_zones_longitude_valid 
        CHECK (center_longitude IS NULL OR (center_longitude >= -180 AND center_longitude <= 180)),
    ADD CONSTRAINT chk_zones_radius_positive 
        CHECK (radius_km IS NULL OR radius_km > 0);

ALTER TABLE menuca_v3.deliveries
    ADD CONSTRAINT chk_deliveries_pickup_latitude_valid 
        CHECK (pickup_latitude >= -90 AND pickup_latitude <= 90),
    ADD CONSTRAINT chk_deliveries_pickup_longitude_valid 
        CHECK (pickup_longitude >= -180 AND pickup_longitude <= 180),
    ADD CONSTRAINT chk_deliveries_delivery_latitude_valid 
        CHECK (delivery_latitude >= -90 AND delivery_latitude <= 90),
    ADD CONSTRAINT chk_deliveries_delivery_longitude_valid 
        CHECK (delivery_longitude >= -180 AND delivery_longitude <= 180);

-- =====================================================

-- Add check constraints for financial validation
ALTER TABLE menuca_v3.deliveries
    ADD CONSTRAINT chk_deliveries_fees_non_negative 
        CHECK (
            delivery_fee >= 0 
            AND COALESCE(driver_earnings, 0) >= 0 
            AND COALESCE(platform_commission, 0) >= 0 
            AND COALESCE(tip_amount, 0) >= 0
        );

ALTER TABLE menuca_v3.driver_earnings
    ADD CONSTRAINT chk_earnings_components_valid 
        CHECK (
            base_earning >= 0 
            AND COALESCE(distance_earning, 0) >= 0 
            AND COALESCE(time_bonus, 0) >= 0 
            AND COALESCE(tip_amount, 0) >= 0 
            AND COALESCE(surge_bonus, 0) >= 0
            AND total_earning >= 0
            AND net_earning >= 0
            AND COALESCE(platform_commission, 0) >= 0
        ),
    ADD CONSTRAINT chk_earnings_total_matches_components 
        CHECK (
            total_earning = base_earning 
                + COALESCE(distance_earning, 0) 
                + COALESCE(time_bonus, 0) 
                + COALESCE(tip_amount, 0) 
                + COALESCE(surge_bonus, 0)
        ),
    ADD CONSTRAINT chk_earnings_net_matches_total_minus_commission 
        CHECK (
            net_earning = total_earning - COALESCE(platform_commission, 0)
        );

-- =====================================================

-- Add check constraints for rating validation
ALTER TABLE menuca_v3.deliveries
    ADD CONSTRAINT chk_deliveries_customer_rating_valid 
        CHECK (customer_rating IS NULL OR (customer_rating >= 1 AND customer_rating <= 5)),
    ADD CONSTRAINT chk_deliveries_driver_rating_valid 
        CHECK (driver_rating IS NULL OR (driver_rating >= 1 AND driver_rating <= 5));

-- =====================================================

-- Add check constraints for timestamp validation
ALTER TABLE menuca_v3.deliveries
    ADD CONSTRAINT chk_deliveries_assigned_after_created 
        CHECK (assigned_at IS NULL OR assigned_at >= created_at),
    ADD CONSTRAINT chk_deliveries_accepted_after_assigned 
        CHECK (accepted_at IS NULL OR assigned_at IS NULL OR accepted_at >= assigned_at),
    ADD CONSTRAINT chk_deliveries_pickup_after_accepted 
        CHECK (pickup_time IS NULL OR accepted_at IS NULL OR pickup_time >= accepted_at),
    ADD CONSTRAINT chk_deliveries_delivered_after_pickup 
        CHECK (delivered_at IS NULL OR pickup_time IS NULL OR delivered_at >= pickup_time);

-- =====================================================

-- Add check constraints for zone pricing
ALTER TABLE menuca_v3.delivery_zones
    ADD CONSTRAINT chk_zones_pricing_valid 
        CHECK (
            base_delivery_fee >= 0 
            AND COALESCE(per_km_fee, 0) >= 0 
            AND COALESCE(minimum_order_amount, 0) >= 0 
            AND COALESCE(free_delivery_threshold, 0) >= 0
        ),
    ADD CONSTRAINT chk_zones_delivery_time_valid 
        CHECK (
            COALESCE(estimated_delivery_time_minutes, 0) >= 0 
            AND COALESCE(max_delivery_time_minutes, 0) >= 0
            AND (max_delivery_time_minutes IS NULL 
                 OR estimated_delivery_time_minutes IS NULL 
                 OR max_delivery_time_minutes >= estimated_delivery_time_minutes)
        );

-- =====================================================
-- SECTION 3: ADD MISSING INDEXES FOR PERFORMANCE
-- =====================================================

-- Composite indexes for common queries
CREATE INDEX idx_drivers_status_rating ON menuca_v3.drivers(
    driver_status, 
    availability_status, 
    average_rating DESC
) WHERE deleted_at IS NULL;

CREATE INDEX idx_drivers_availability_location ON menuca_v3.drivers(
    availability_status,
    current_latitude,
    current_longitude
) WHERE availability_status = 'online' AND deleted_at IS NULL;

CREATE INDEX idx_deliveries_driver_status_date ON menuca_v3.deliveries(
    driver_id,
    delivery_status,
    created_at DESC
) WHERE deleted_at IS NULL;

CREATE INDEX idx_deliveries_restaurant_status_date ON menuca_v3.deliveries(
    restaurant_id,
    delivery_status,
    created_at DESC
) WHERE deleted_at IS NULL;

CREATE INDEX idx_deliveries_status_created ON menuca_v3.deliveries(
    delivery_status,
    created_at DESC
) WHERE delivery_status IN ('pending', 'searching_driver', 'assigned');

CREATE INDEX idx_driver_earnings_driver_date_status ON menuca_v3.driver_earnings(
    driver_id,
    earned_at DESC,
    payment_status
);

CREATE INDEX idx_driver_earnings_pending_batch ON menuca_v3.driver_earnings(
    payment_status,
    earned_at
) WHERE payment_status = 'pending';

CREATE INDEX idx_driver_locations_driver_time_desc ON menuca_v3.driver_locations(
    driver_id,
    recorded_at DESC
);

CREATE INDEX idx_driver_locations_delivery_time ON menuca_v3.driver_locations(
    delivery_id,
    recorded_at DESC
) WHERE delivery_id IS NOT NULL;

CREATE INDEX idx_delivery_zones_restaurant_active ON menuca_v3.delivery_zones(
    restaurant_id,
    is_active,
    priority DESC
) WHERE deleted_at IS NULL;

-- =====================================================
-- SECTION 4: CREATE VALIDATION FUNCTIONS
-- =====================================================

-- Function: Validate delivery status transition
CREATE OR REPLACE FUNCTION menuca_v3.validate_delivery_status_transition(
    p_current_status VARCHAR,
    p_new_status VARCHAR
)
RETURNS BOOLEAN
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
    -- Valid state transitions
    RETURN CASE
        WHEN p_current_status = 'pending' THEN 
            p_new_status IN ('searching_driver', 'cancelled')
        WHEN p_current_status = 'searching_driver' THEN 
            p_new_status IN ('assigned', 'cancelled')
        WHEN p_current_status = 'assigned' THEN 
            p_new_status IN ('accepted', 'cancelled')
        WHEN p_current_status = 'accepted' THEN 
            p_new_status IN ('picked_up', 'cancelled')
        WHEN p_current_status = 'picked_up' THEN 
            p_new_status = 'in_transit'
        WHEN p_current_status = 'in_transit' THEN 
            p_new_status = 'arrived'
        WHEN p_current_status = 'arrived' THEN 
            p_new_status IN ('delivered', 'failed')
        WHEN p_current_status IN ('delivered', 'cancelled', 'failed') THEN 
            FALSE -- Terminal states
        ELSE FALSE
    END;
END;
$$;

COMMENT ON FUNCTION menuca_v3.validate_delivery_status_transition IS
'Validates delivery status transitions according to business rules. Terminal states: delivered, cancelled, failed.';

GRANT EXECUTE ON FUNCTION menuca_v3.validate_delivery_status_transition TO authenticated;

-- =====================================================

-- Function: Validate driver status transition
CREATE OR REPLACE FUNCTION menuca_v3.validate_driver_status_transition(
    p_current_status VARCHAR,
    p_new_status VARCHAR
)
RETURNS BOOLEAN
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
    -- Valid state transitions
    RETURN CASE
        WHEN p_current_status = 'pending' THEN 
            p_new_status IN ('approved', 'blocked')
        WHEN p_current_status = 'approved' THEN 
            p_new_status IN ('active', 'blocked')
        WHEN p_current_status = 'active' THEN 
            p_new_status IN ('inactive', 'suspended', 'blocked')
        WHEN p_current_status = 'inactive' THEN 
            p_new_status IN ('active', 'blocked')
        WHEN p_current_status = 'suspended' THEN 
            p_new_status IN ('active', 'blocked')
        WHEN p_current_status = 'blocked' THEN 
            FALSE -- Terminal state (can only be unblocked by admin creating new account)
        ELSE FALSE
    END;
END;
$$;

COMMENT ON FUNCTION menuca_v3.validate_driver_status_transition IS
'Validates driver status transitions. Blocked is terminal state.';

GRANT EXECUTE ON FUNCTION menuca_v3.validate_driver_status_transition TO authenticated;

-- =====================================================

-- Function: Calculate driver earnings from delivery
CREATE OR REPLACE FUNCTION menuca_v3.calculate_driver_earnings(
    p_delivery_fee DECIMAL,
    p_distance_km DECIMAL,
    p_duration_minutes INTEGER,
    p_tip_amount DECIMAL DEFAULT 0
)
RETURNS TABLE (
    base_earning DECIMAL,
    distance_earning DECIMAL,
    time_bonus DECIMAL,
    tip_amount DECIMAL,
    surge_bonus DECIMAL,
    total_earning DECIMAL,
    platform_commission DECIMAL,
    net_earning DECIMAL
)
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
    v_base_pay CONSTANT DECIMAL := 5.00;
    v_per_km_rate CONSTANT DECIMAL := 1.50;
    v_per_minute_rate CONSTANT DECIMAL := 0.25;
    v_commission_rate CONSTANT DECIMAL := 0.15; -- 15%
    v_base DECIMAL;
    v_distance DECIMAL;
    v_time DECIMAL;
    v_surge DECIMAL := 0;
    v_total DECIMAL;
    v_commission DECIMAL;
BEGIN
    -- Calculate components
    v_base := v_base_pay;
    v_distance := COALESCE(p_distance_km, 0) * v_per_km_rate;
    v_time := COALESCE(p_duration_minutes, 0) * v_per_minute_rate;
    
    -- TODO: Implement surge pricing logic (based on time of day, demand, etc.)
    v_surge := 0;
    
    -- Calculate total
    v_total := v_base + v_distance + v_time + COALESCE(p_tip_amount, 0) + v_surge;
    v_commission := v_total * v_commission_rate;
    
    RETURN QUERY SELECT
        v_base,
        v_distance,
        v_time,
        COALESCE(p_tip_amount, 0),
        v_surge,
        v_total,
        v_commission,
        v_total - v_commission;
END;
$$;

COMMENT ON FUNCTION menuca_v3.calculate_driver_earnings IS
'Calculate driver earnings breakdown: base pay ($5) + distance ($1.50/km) + time ($0.25/min) + tip - 15% platform commission';

GRANT EXECUTE ON FUNCTION menuca_v3.calculate_driver_earnings TO authenticated, service_role;

-- =====================================================

-- Function: Validate zone configuration
CREATE OR REPLACE FUNCTION menuca_v3.validate_zone_configuration(
    p_zone_type VARCHAR,
    p_center_latitude DECIMAL,
    p_center_longitude DECIMAL,
    p_radius_km DECIMAL,
    p_zone_geometry GEOGRAPHY
)
RETURNS BOOLEAN
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
    -- For circle/radius zones, require center point and radius
    IF p_zone_type IN ('circle', 'radius') THEN
        IF p_center_latitude IS NULL 
           OR p_center_longitude IS NULL 
           OR p_radius_km IS NULL 
           OR p_radius_km <= 0 
        THEN
            RETURN FALSE;
        END IF;
    END IF;
    
    -- For polygon zones, require geometry
    IF p_zone_type = 'polygon' THEN
        IF p_zone_geometry IS NULL THEN
            RETURN FALSE;
        END IF;
    END IF;
    
    RETURN TRUE;
END;
$$;

COMMENT ON FUNCTION menuca_v3.validate_zone_configuration IS
'Validates delivery zone configuration based on zone type. Circle requires center+radius, polygon requires geometry.';

-- =====================================================
-- SECTION 5: CREATE STATISTICS FOR QUERY OPTIMIZER
-- =====================================================

-- Create extended statistics for better query planning
CREATE STATISTICS stats_drivers_status_location ON 
    driver_status, availability_status, current_latitude, current_longitude
FROM menuca_v3.drivers;

CREATE STATISTICS stats_deliveries_status_time ON 
    delivery_status, created_at, assigned_at, delivered_at
FROM menuca_v3.deliveries;

CREATE STATISTICS stats_driver_earnings_driver_status ON 
    driver_id, payment_status, earned_at
FROM menuca_v3.driver_earnings;

-- =====================================================
-- SECTION 6: ADD HELPFUL COMMENTS
-- =====================================================

COMMENT ON COLUMN menuca_v3.drivers.acceptance_rate IS 
'Percentage of delivery requests accepted by driver. Used for driver performance scoring.';

COMMENT ON COLUMN menuca_v3.drivers.completion_rate IS 
'Percentage of accepted deliveries successfully completed. Excludes customer cancellations.';

COMMENT ON COLUMN menuca_v3.drivers.on_time_rate IS 
'Percentage of deliveries completed within estimated time window.';

COMMENT ON COLUMN menuca_v3.delivery_zones.priority IS 
'Priority order for zone matching. Higher values matched first when multiple zones cover same address.';

COMMENT ON COLUMN menuca_v3.deliveries.is_contactless IS 
'Contactless delivery requested (leave at door, no signature required).';

COMMENT ON COLUMN menuca_v3.deliveries.is_priority IS 
'Priority delivery (faster assignment, premium fee).';

COMMENT ON COLUMN menuca_v3.deliveries.is_scheduled IS 
'Scheduled delivery for specific future time (not ASAP).';

COMMENT ON COLUMN menuca_v3.driver_locations.accuracy_meters IS 
'GPS accuracy in meters. Lower values indicate more precise location.';

-- =====================================================
-- SECTION 7: CREATE HELPFUL VIEWS
-- =====================================================

-- View: Driver performance summary
CREATE OR REPLACE VIEW menuca_v3.driver_performance_summary AS
SELECT 
    d.id AS driver_id,
    d.first_name || ' ' || d.last_name AS driver_name,
    d.driver_status,
    d.availability_status,
    d.vehicle_type,
    d.average_rating,
    d.total_deliveries,
    d.completed_deliveries,
    d.cancelled_deliveries,
    d.acceptance_rate,
    d.completion_rate,
    d.on_time_rate,
    d.earnings_total,
    d.earnings_pending,
    d.earnings_paid,
    ROUND(
        CASE 
            WHEN d.total_deliveries > 0 
            THEN d.earnings_total / d.total_deliveries 
            ELSE 0 
        END, 
        2
    ) AS avg_earnings_per_delivery,
    d.created_at AS driver_since,
    d.last_location_update
FROM menuca_v3.drivers d
WHERE d.deleted_at IS NULL;

COMMENT ON VIEW menuca_v3.driver_performance_summary IS
'Driver performance metrics for dashboards and analytics';

GRANT SELECT ON menuca_v3.driver_performance_summary TO authenticated;

-- =====================================================

-- View: Active delivery tracking
CREATE OR REPLACE VIEW menuca_v3.active_delivery_tracking AS
SELECT 
    del.id AS delivery_id,
    del.order_id,
    del.restaurant_id,
    r.name AS restaurant_name,
    del.driver_id,
    dr.first_name || ' ' || dr.last_name AS driver_name,
    dr.phone AS driver_phone,
    del.delivery_status,
    del.delivery_address,
    del.customer_name,
    del.customer_phone,
    del.estimated_duration_minutes,
    del.created_at,
    del.assigned_at,
    del.accepted_at,
    del.pickup_time,
    EXTRACT(EPOCH FROM (NOW() - del.accepted_at))/60 AS minutes_in_progress,
    dr.current_latitude AS driver_latitude,
    dr.current_longitude AS driver_longitude,
    dr.last_location_update,
    del.is_contactless,
    del.is_priority,
    del.delivery_instructions
FROM menuca_v3.deliveries del
LEFT JOIN menuca_v3.drivers dr ON del.driver_id = dr.id
LEFT JOIN menuca_v3.restaurants r ON del.restaurant_id = r.id
WHERE del.delivery_status IN ('assigned', 'accepted', 'picked_up', 'in_transit', 'arrived')
  AND del.deleted_at IS NULL
ORDER BY del.created_at DESC;

COMMENT ON VIEW menuca_v3.active_delivery_tracking IS
'Real-time view of all active deliveries with driver locations';

GRANT SELECT ON menuca_v3.active_delivery_tracking TO authenticated;

-- =====================================================

-- View: Delivery zone coverage summary
CREATE OR REPLACE VIEW menuca_v3.delivery_zone_summary AS
SELECT 
    dz.id AS zone_id,
    dz.restaurant_id,
    r.name AS restaurant_name,
    dz.zone_name,
    dz.zone_code,
    dz.zone_type,
    dz.base_delivery_fee,
    dz.per_km_fee,
    dz.minimum_order_amount,
    dz.free_delivery_threshold,
    dz.radius_km,
    dz.is_active,
    dz.accepts_deliveries,
    dz.estimated_delivery_time_minutes,
    dz.priority,
    COUNT(DISTINCT del.id) AS total_deliveries,
    COUNT(DISTINCT CASE WHEN del.delivery_status = 'delivered' THEN del.id END) AS completed_deliveries,
    ROUND(AVG(del.actual_duration_minutes), 0) AS avg_delivery_time_minutes,
    ROUND(AVG(del.delivery_fee), 2) AS avg_delivery_fee
FROM menuca_v3.delivery_zones dz
LEFT JOIN menuca_v3.restaurants r ON dz.restaurant_id = r.id
LEFT JOIN menuca_v3.deliveries del 
    ON dz.id = del.delivery_zone_id 
    AND del.created_at >= NOW() - INTERVAL '30 days'
WHERE dz.deleted_at IS NULL
GROUP BY dz.id, dz.restaurant_id, r.name, dz.zone_name, dz.zone_code, 
         dz.zone_type, dz.base_delivery_fee, dz.per_km_fee, 
         dz.minimum_order_amount, dz.free_delivery_threshold, 
         dz.radius_km, dz.is_active, dz.accepts_deliveries, 
         dz.estimated_delivery_time_minutes, dz.priority;

COMMENT ON VIEW menuca_v3.delivery_zone_summary IS
'Delivery zone statistics and performance metrics (last 30 days)';

GRANT SELECT ON menuca_v3.delivery_zone_summary TO authenticated;

-- =====================================================
-- SECTION 8: OPTIMIZE EXISTING TABLES
-- =====================================================

-- Analyze all delivery tables for query optimizer
ANALYZE menuca_v3.drivers;
ANALYZE menuca_v3.delivery_zones;
ANALYZE menuca_v3.deliveries;
ANALYZE menuca_v3.driver_locations;
ANALYZE menuca_v3.driver_earnings;

-- =====================================================

COMMIT;

-- =====================================================
-- VALIDATION QUERIES (Run after migration)
-- =====================================================

-- Verify enum types created
SELECT typname, typcategory 
FROM pg_type 
WHERE typnamespace = 'menuca_v3'::regnamespace 
  AND typcategory = 'E'
ORDER BY typname;

-- Verify constraints added
SELECT 
    conname AS constraint_name,
    conrelid::regclass AS table_name,
    contype AS constraint_type
FROM pg_constraint
WHERE connamespace = 'menuca_v3'::regnamespace
  AND contype = 'c' -- check constraints
  AND conrelid::regclass::text LIKE 'menuca_v3.driver%' 
   OR conrelid::regclass::text LIKE 'menuca_v3.deliver%'
ORDER BY table_name, constraint_name;

-- Verify new indexes created
SELECT 
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'menuca_v3'
  AND (tablename LIKE 'driver%' OR tablename LIKE 'deliver%')
  AND indexname LIKE '%_idx_%'
ORDER BY tablename, indexname;

-- Verify views created
SELECT 
    schemaname,
    viewname,
    definition
FROM pg_views
WHERE schemaname = 'menuca_v3'
  AND (viewname LIKE 'driver%' OR viewname LIKE 'delivery%' OR viewname LIKE 'active%')
ORDER BY viewname;

-- =====================================================
-- END OF PHASE 3 MIGRATION
-- =====================================================

