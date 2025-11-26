-- ========================================
-- DELIVERY ENTITY CLEANUP - PHASE 2
-- Schema Updates & Table Restructuring
-- ========================================
-- Created: 2025-11-25
-- Purpose: Update table schemas to remove duplicates and clarify responsibilities
-- Dependencies: Phase 1 must be completed successfully
-- ========================================

BEGIN;

-- ========================================
-- STEP 1: Create New Service Settings Table
-- ========================================

-- Create restaurant_service_settings (extracted from restaurant_service_configs)
CREATE TABLE IF NOT EXISTS restaurant_service_settings (
    -- Identity
    id BIGSERIAL PRIMARY KEY,
    uuid UUID UNIQUE DEFAULT gen_random_uuid(),
    restaurant_id BIGINT NOT NULL UNIQUE REFERENCES restaurants(id) ON DELETE CASCADE,
    
    -- Delivery Settings
    has_delivery_enabled BOOLEAN DEFAULT FALSE,
    delivery_time_minutes INTEGER DEFAULT 45,
    -- REMOVED: delivery_min_order (now per-zone in delivery_zones)
    -- REMOVED: delivery_max_distance_km (calculated from zones)
    
    -- Takeout Settings
    takeout_enabled BOOLEAN DEFAULT FALSE,
    takeout_time_minutes INTEGER DEFAULT 20,
    takeout_discount_enabled BOOLEAN DEFAULT FALSE,
    takeout_discount_type VARCHAR(20),  -- 'percentage' | 'fixed_amount'
    takeout_discount_value DECIMAL(10, 2),
    
    -- Preorder Settings
    allows_preorders BOOLEAN DEFAULT FALSE,
    preorder_time_frame_hours INTEGER DEFAULT 24,
    
    -- General Settings
    is_bilingual BOOLEAN DEFAULT FALSE,
    default_language VARCHAR(5) DEFAULT 'en',
    accepts_tips BOOLEAN DEFAULT FALSE,
    requires_phone BOOLEAN DEFAULT TRUE,
    
    -- Audit Trail
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    created_by BIGINT REFERENCES admin_users(id),
    updated_at TIMESTAMP DEFAULT NOW(),
    updated_by BIGINT REFERENCES admin_users(id),
    deleted_at TIMESTAMP,
    deleted_by BIGINT REFERENCES admin_users(id),
    
    -- Constraints
    CONSTRAINT positive_delivery_time CHECK (delivery_time_minutes > 0),
    CONSTRAINT positive_takeout_time CHECK (takeout_time_minutes > 0),
    CONSTRAINT positive_preorder_timeframe CHECK (preorder_time_frame_hours > 0),
    CONSTRAINT valid_discount_type CHECK (
        takeout_discount_type IS NULL OR 
        takeout_discount_type IN ('percentage', 'fixed_amount')
    ),
    CONSTRAINT valid_language CHECK (
        default_language IN ('en', 'fr', 'es')
    )
);

-- Create indexes
CREATE INDEX idx_service_settings_restaurant ON restaurant_service_settings(restaurant_id);
CREATE INDEX idx_service_settings_delivery_enabled ON restaurant_service_settings(has_delivery_enabled) 
    WHERE has_delivery_enabled = TRUE;
CREATE INDEX idx_service_settings_takeout_enabled ON restaurant_service_settings(takeout_enabled) 
    WHERE takeout_enabled = TRUE;
CREATE INDEX idx_service_settings_deleted ON restaurant_service_settings(deleted_at) 
    WHERE deleted_at IS NULL;

-- Add comments
COMMENT ON TABLE restaurant_service_settings IS 'Service-level settings for restaurants (delivery, takeout, preorders)';
COMMENT ON COLUMN restaurant_service_settings.has_delivery_enabled IS 'Whether restaurant accepts delivery orders';
COMMENT ON COLUMN restaurant_service_settings.takeout_enabled IS 'Whether restaurant accepts takeout orders';
COMMENT ON COLUMN restaurant_service_settings.allows_preorders IS 'Whether restaurant accepts orders for future dates';
COMMENT ON COLUMN restaurant_service_settings.accepts_tips IS 'Whether restaurant accepts tips through the platform';

-- ========================================
-- STEP 2: Migrate Data to New Table
-- ========================================

-- Migrate data from restaurant_service_configs
INSERT INTO restaurant_service_settings (
    restaurant_id,
    has_delivery_enabled,
    delivery_time_minutes,
    takeout_enabled,
    takeout_time_minutes,
    takeout_discount_enabled,
    takeout_discount_type,
    takeout_discount_value,
    allows_preorders,
    preorder_time_frame_hours,
    is_bilingual,
    default_language,
    accepts_tips,
    requires_phone,
    notes,
    created_at,
    created_by,
    updated_at,
    updated_by,
    deleted_at,
    deleted_by
)
SELECT 
    restaurant_id,
    has_delivery_enabled,
    delivery_time_minutes,
    takeout_enabled,
    takeout_time_minutes,
    takeout_discount_enabled,
    takeout_discount_type,
    takeout_discount_value,
    allows_preorders,
    preorder_time_frame_hours,
    is_bilingual,
    default_language,
    accepts_tips,
    requires_phone,
    COALESCE(notes, '') || E'\n\nMigrated from restaurant_service_configs on ' || NOW()::date,
    created_at,
    created_by,
    updated_at,
    updated_by,
    deleted_at,
    deleted_by
FROM restaurant_service_configs
ON CONFLICT (restaurant_id) DO UPDATE SET
    has_delivery_enabled = EXCLUDED.has_delivery_enabled,
    delivery_time_minutes = EXCLUDED.delivery_time_minutes,
    takeout_enabled = EXCLUDED.takeout_enabled,
    takeout_time_minutes = EXCLUDED.takeout_time_minutes,
    takeout_discount_enabled = EXCLUDED.takeout_discount_enabled,
    takeout_discount_type = EXCLUDED.takeout_discount_type,
    takeout_discount_value = EXCLUDED.takeout_discount_value,
    allows_preorders = EXCLUDED.allows_preorders,
    preorder_time_frame_hours = EXCLUDED.preorder_time_frame_hours,
    is_bilingual = EXCLUDED.is_bilingual,
    default_language = EXCLUDED.default_language,
    accepts_tips = EXCLUDED.accepts_tips,
    requires_phone = EXCLUDED.requires_phone,
    updated_at = NOW();

-- ========================================
-- STEP 3: Update restaurant_delivery_config
-- ========================================

-- Add new columns
ALTER TABLE restaurant_delivery_config 
ADD COLUMN IF NOT EXISTS disable_delivery_reason VARCHAR(255);

-- Update delivery_method enum values
-- First, update existing values to new simplified enum
UPDATE restaurant_delivery_config
SET delivery_method = 'zones'
WHERE delivery_method IN ('radius', 'polygon', 'areas');

-- Change column type to VARCHAR for flexibility
ALTER TABLE restaurant_delivery_config
ALTER COLUMN delivery_method TYPE VARCHAR(20);

-- Add constraint for valid values
ALTER TABLE restaurant_delivery_config
ADD CONSTRAINT valid_delivery_method CHECK (
    delivery_method IN ('zones', 'disabled')
);

-- Drop obsolete columns
-- Note: This will fail if any views or functions reference these columns
-- Update those first, then run this section

-- Track columns to be dropped
ALTER TABLE restaurant_delivery_config 
RENAME COLUMN delivery_radius_km TO _deprecated_delivery_radius_km;

ALTER TABLE restaurant_delivery_config 
RENAME COLUMN use_multiple_areas TO _deprecated_use_multiple_areas;

ALTER TABLE restaurant_delivery_config 
RENAME COLUMN use_polygon_areas TO _deprecated_use_polygon_areas;

ALTER TABLE restaurant_delivery_config 
RENAME COLUMN max_delivery_distance_km TO _deprecated_max_delivery_distance_km;

ALTER TABLE restaurant_delivery_config 
RENAME COLUMN restaurant_delivery_charge TO _deprecated_restaurant_delivery_charge;

ALTER TABLE restaurant_delivery_config 
RENAME COLUMN delivery_service_extra TO _deprecated_delivery_service_extra;

-- Legacy V1 flags
ALTER TABLE restaurant_delivery_config 
RENAME COLUMN legacy_v1_twilio_call TO _deprecated_legacy_v1_twilio_call;

ALTER TABLE restaurant_delivery_config 
RENAME COLUMN legacy_v1_send_to_delivery TO _deprecated_legacy_v1_send_to_delivery;

ALTER TABLE restaurant_delivery_config 
RENAME COLUMN legacy_v1_daily_delivery TO _deprecated_legacy_v1_daily_delivery;

ALTER TABLE restaurant_delivery_config 
RENAME COLUMN legacy_v1_geodispatch TO _deprecated_legacy_v1_geodispatch;

ALTER TABLE restaurant_delivery_config 
RENAME COLUMN legacy_v1_tookan TO _deprecated_legacy_v1_tookan;

ALTER TABLE restaurant_delivery_config 
RENAME COLUMN legacy_v1_wedeliver TO _deprecated_legacy_v1_wedeliver;

ALTER TABLE restaurant_delivery_config 
RENAME COLUMN legacy_v1_check_pings TO _deprecated_legacy_v1_check_pings;

-- Update notes to document changes
UPDATE restaurant_delivery_config
SET 
    notes = COALESCE(notes || E'\n\n', '') || 
            'Phase 2 Migration: Removed duplicate columns and simplified delivery_method. ' ||
            'Deprecated columns renamed with _deprecated_ prefix. ' ||
            'Migration date: ' || NOW()::date,
    updated_at = NOW()
WHERE notes NOT LIKE '%Phase 2 Migration%';

-- ========================================
-- STEP 4: Create Helper Functions
-- ========================================

-- Function to calculate max delivery distance from zones
CREATE OR REPLACE FUNCTION get_restaurant_max_delivery_distance(p_restaurant_id BIGINT)
RETURNS DECIMAL AS $$
DECLARE
    v_max_distance DECIMAL;
BEGIN
    SELECT MAX(
        ST_MaxDistance(
            zone_geometry::geography,
            ST_Centroid(zone_geometry)::geography
        ) / 1000.0  -- Convert to km
    )
    INTO v_max_distance
    FROM restaurant_delivery_zones
    WHERE restaurant_id = p_restaurant_id
    AND is_active = TRUE
    AND deleted_at IS NULL;
    
    RETURN COALESCE(v_max_distance, 0);
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION get_restaurant_max_delivery_distance IS 
    'Calculate maximum delivery distance from all active zones (replaces deprecated max_delivery_distance_km column)';

-- Function to get minimum order for address
CREATE OR REPLACE FUNCTION get_minimum_order_for_address(
    p_restaurant_id BIGINT,
    p_latitude DECIMAL,
    p_longitude DECIMAL
)
RETURNS INTEGER AS $$
DECLARE
    v_minimum_order INTEGER;
BEGIN
    SELECT minimum_order_cents
    INTO v_minimum_order
    FROM restaurant_delivery_zones
    WHERE restaurant_id = p_restaurant_id
    AND ST_Contains(
        zone_geometry,
        ST_SetSRID(ST_MakePoint(p_longitude, p_latitude), 4326)
    )
    AND is_active = TRUE
    AND deleted_at IS NULL
    ORDER BY minimum_order_cents DESC  -- Use highest minimum if multiple zones
    LIMIT 1;
    
    RETURN COALESCE(v_minimum_order, 0);
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION get_minimum_order_for_address IS 
    'Get minimum order requirement for specific address (replaces global delivery_min_order)';

-- ========================================
-- STEP 5: Update Existing Functions
-- ========================================

-- Update is_address_in_delivery_zone to use new structure
CREATE OR REPLACE FUNCTION is_address_in_delivery_zone(
    p_restaurant_id BIGINT,
    p_latitude DECIMAL,
    p_longitude DECIMAL
)
RETURNS TABLE (
    zone_id BIGINT,
    zone_name VARCHAR,
    delivery_fee_cents INTEGER,
    minimum_order_cents INTEGER,
    estimated_delivery_minutes INTEGER,
    in_zone BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        rdz.id,
        rdz.zone_name,
        rdz.delivery_fee_cents,
        rdz.minimum_order_cents,
        rdz.estimated_delivery_minutes,
        TRUE AS in_zone
    FROM restaurant_delivery_zones rdz
    INNER JOIN restaurant_service_settings rss ON rss.restaurant_id = rdz.restaurant_id
    WHERE rdz.restaurant_id = p_restaurant_id
    AND rss.has_delivery_enabled = TRUE
    AND rdz.is_active = TRUE
    AND rdz.deleted_at IS NULL
    AND ST_Contains(
        rdz.zone_geometry,
        ST_SetSRID(ST_MakePoint(p_longitude, p_latitude), 4326)
    )
    ORDER BY rdz.minimum_order_cents DESC  -- Return highest minimum if multiple zones overlap
    LIMIT 1;
END;
$$ LANGUAGE plpgsql STABLE;

-- ========================================
-- STEP 6: Create Migration Triggers
-- ========================================

-- Trigger to prevent new records in old tables
CREATE OR REPLACE FUNCTION prevent_deprecated_table_inserts()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'This table is deprecated. Use restaurant_delivery_zones instead. See DELIVERY_ENTITY_CLEANUP_PLAN.md';
END;
$$ LANGUAGE plpgsql;

-- Apply triggers to deprecated tables (will enable in Phase 3)
-- CREATE TRIGGER prevent_delivery_areas_inserts
-- BEFORE INSERT ON restaurant_delivery_areas
-- FOR EACH ROW EXECUTE FUNCTION prevent_deprecated_table_inserts();

-- CREATE TRIGGER prevent_delivery_fees_inserts
-- BEFORE INSERT ON restaurant_delivery_fees
-- FOR EACH ROW EXECUTE FUNCTION prevent_deprecated_table_inserts();

-- CREATE TRIGGER prevent_delivery_companies_inserts
-- BEFORE INSERT ON restaurant_delivery_companies
-- FOR EACH ROW EXECUTE FUNCTION prevent_deprecated_table_inserts();

-- ========================================
-- STEP 7: Validation Queries
-- ========================================

DO $$
DECLARE
    v_service_settings_count INTEGER;
    v_service_configs_count INTEGER;
    v_deprecated_columns_count INTEGER;
    v_zones_active INTEGER;
BEGIN
    -- Count records in new table
    SELECT COUNT(*) INTO v_service_settings_count
    FROM restaurant_service_settings;
    
    -- Count records in old table
    SELECT COUNT(*) INTO v_service_configs_count
    FROM restaurant_service_configs;
    
    -- Count deprecated columns still in use
    SELECT COUNT(*) INTO v_deprecated_columns_count
    FROM restaurant_delivery_config
    WHERE _deprecated_delivery_radius_km IS NOT NULL
    OR _deprecated_max_delivery_distance_km IS NOT NULL
    OR _deprecated_restaurant_delivery_charge IS NOT NULL;
    
    -- Count active zones
    SELECT COUNT(*) INTO v_zones_active
    FROM restaurant_delivery_zones
    WHERE is_active = TRUE
    AND deleted_at IS NULL;
    
    -- Output results
    RAISE NOTICE '========================================';
    RAISE NOTICE 'MIGRATION PHASE 2 VALIDATION SUMMARY';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Service Settings Records: %', v_service_settings_count;
    RAISE NOTICE 'Service Configs Records (old): %', v_service_configs_count;
    RAISE NOTICE 'Match: %', CASE WHEN v_service_settings_count = v_service_configs_count THEN '✅ YES' ELSE '❌ NO' END;
    RAISE NOTICE 'Restaurants Using Deprecated Columns: %', v_deprecated_columns_count;
    RAISE NOTICE 'Active Delivery Zones: %', v_zones_active;
    RAISE NOTICE '========================================';
    
    -- Fail if counts don't match
    IF v_service_settings_count != v_service_configs_count THEN
        RAISE EXCEPTION 'Service settings count (%) does not match service configs count (%). Data migration incomplete.',
            v_service_settings_count, v_service_configs_count;
    END IF;
END $$;

-- Create validation view
CREATE OR REPLACE VIEW v_delivery_schema_validation AS
SELECT 
    r.id AS restaurant_id,
    r.name AS restaurant_name,
    -- Old system
    rsc.id AS old_service_config_id,
    rsc.has_delivery_enabled AS old_delivery_enabled,
    rsc.delivery_min_order AS old_global_minimum,
    rsc.delivery_max_distance_km AS old_global_distance,
    -- New system
    rss.id AS new_service_settings_id,
    rss.has_delivery_enabled AS new_delivery_enabled,
    rdc.delivery_method AS config_method,
    COUNT(rdz.id) AS zone_count,
    -- Validation
    CASE 
        WHEN rss.id IS NULL THEN '❌ Missing Service Settings'
        WHEN rdc.delivery_method = 'zones' AND COUNT(rdz.id) = 0 THEN '⚠️ Method=zones but no zones'
        WHEN rss.has_delivery_enabled AND COUNT(rdz.id) = 0 THEN '⚠️ Delivery enabled but no zones'
        ELSE '✅ Valid'
    END AS validation_status
FROM restaurants r
LEFT JOIN restaurant_service_configs rsc ON rsc.restaurant_id = r.id
LEFT JOIN restaurant_service_settings rss ON rss.restaurant_id = r.id
LEFT JOIN restaurant_delivery_config rdc ON rdc.restaurant_id = r.id
LEFT JOIN restaurant_delivery_zones rdz ON rdz.restaurant_id = r.id 
    AND rdz.is_active = TRUE 
    AND rdz.deleted_at IS NULL
WHERE r.status = 'active'
GROUP BY r.id, r.name, rsc.id, rss.id, rdc.delivery_method
ORDER BY validation_status, r.name;

-- Query validation view
SELECT 
    validation_status,
    COUNT(*) AS restaurant_count
FROM v_delivery_schema_validation
GROUP BY validation_status
ORDER BY validation_status;

COMMIT;

-- ========================================
-- ROLLBACK SCRIPT (if needed)
-- ========================================
/*
BEGIN;

-- Drop new table
DROP TABLE IF EXISTS restaurant_service_settings CASCADE;

-- Restore delivery_method enum
UPDATE restaurant_delivery_config
SET delivery_method = CASE
    WHEN delivery_method = 'zones' THEN 'areas'
    ELSE delivery_method
END;

-- Restore deprecated columns (rename back)
ALTER TABLE restaurant_delivery_config 
RENAME COLUMN _deprecated_delivery_radius_km TO delivery_radius_km;

-- (Repeat for all deprecated columns)

-- Drop helper functions
DROP FUNCTION IF EXISTS get_restaurant_max_delivery_distance(BIGINT);
DROP FUNCTION IF EXISTS get_minimum_order_for_address(BIGINT, DECIMAL, DECIMAL);

-- Drop validation views
DROP VIEW IF EXISTS v_delivery_schema_validation CASCADE;

COMMIT;
*/

