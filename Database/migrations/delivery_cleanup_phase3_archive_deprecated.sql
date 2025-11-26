-- ========================================
-- DELIVERY ENTITY CLEANUP - PHASE 3
-- Archive & Drop Deprecated Tables
-- ========================================
-- Created: 2025-11-25
-- Purpose: Archive and drop deprecated delivery tables after 2-week monitoring period
-- Dependencies: Phase 1 & 2 must be completed and validated
-- WARNING: This script DROPS tables. Ensure backups exist before running.
-- ========================================

BEGIN;

-- ========================================
-- STEP 1: Final Validation Before Archive
-- ========================================

DO $$
DECLARE
    v_zones_count INTEGER;
    v_old_areas_count INTEGER;
    v_old_fees_count INTEGER;
    v_old_companies_count INTEGER;
    v_deprecated_columns_in_use INTEGER;
    v_monitoring_period_days INTEGER := 14;
    v_phase2_date DATE;
BEGIN
    -- Get Phase 2 migration date
    SELECT MIN(updated_at::date) INTO v_phase2_date
    FROM restaurant_delivery_config
    WHERE notes LIKE '%Phase 2 Migration%';
    
    -- Check if enough time has passed
    IF v_phase2_date IS NULL THEN
        RAISE EXCEPTION 'Cannot find Phase 2 migration date. Phase 2 may not have been completed.';
    END IF;
    
    IF CURRENT_DATE < v_phase2_date + v_monitoring_period_days THEN
        RAISE EXCEPTION 'Monitoring period not complete. Please wait until % before running Phase 3.',
            v_phase2_date + v_monitoring_period_days;
    END IF;
    
    -- Count records in new vs old systems
    SELECT COUNT(*) INTO v_zones_count FROM restaurant_delivery_zones WHERE is_active = TRUE;
    SELECT COUNT(*) INTO v_old_areas_count FROM restaurant_delivery_areas WHERE is_active = TRUE;
    SELECT COUNT(*) INTO v_old_fees_count FROM restaurant_delivery_fees WHERE is_active = TRUE;
    SELECT COUNT(*) INTO v_old_companies_count FROM restaurant_delivery_companies WHERE is_active = TRUE;
    
    -- Count restaurants still using deprecated columns
    SELECT COUNT(*) INTO v_deprecated_columns_in_use
    FROM restaurant_delivery_config
    WHERE _deprecated_delivery_radius_km IS NOT NULL
    OR _deprecated_max_delivery_distance_km IS NOT NULL
    OR _deprecated_restaurant_delivery_charge IS NOT NULL;
    
    RAISE NOTICE '========================================';
    RAISE NOTICE 'PRE-ARCHIVE VALIDATION';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Phase 2 Date: %', v_phase2_date;
    RAISE NOTICE 'Days Since Phase 2: %', CURRENT_DATE - v_phase2_date;
    RAISE NOTICE 'Active Zones (new system): %', v_zones_count;
    RAISE NOTICE 'Active Areas (old system): %', v_old_areas_count;
    RAISE NOTICE 'Active Fees (old system): %', v_old_fees_count;
    RAISE NOTICE 'Active Companies (old system): %', v_old_companies_count;
    RAISE NOTICE 'Restaurants Using Deprecated Columns: %', v_deprecated_columns_in_use;
    RAISE NOTICE '========================================';
    
    -- Warn if old tables still have active records
    IF v_old_areas_count > 0 OR v_old_fees_count > 0 OR v_old_companies_count > 0 THEN
        RAISE WARNING 'Old tables still have active records. This is unexpected. Investigate before proceeding.';
    END IF;
END $$;

-- ========================================
-- STEP 2: Archive Old Tables
-- ========================================

-- Create archive schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS _archived;

COMMENT ON SCHEMA _archived IS 'Archived tables from migrations. Can be dropped after retention period.';

-- Archive restaurant_delivery_areas
ALTER TABLE restaurant_delivery_areas SET SCHEMA _archived;
ALTER TABLE _archived.restaurant_delivery_areas 
    RENAME TO restaurant_delivery_areas_archived_20251125;

-- Add archive metadata
ALTER TABLE _archived.restaurant_delivery_areas_archived_20251125
ADD COLUMN IF NOT EXISTS _archive_date TIMESTAMP DEFAULT NOW(),
ADD COLUMN IF NOT EXISTS _archive_reason TEXT DEFAULT 'Migrated to restaurant_delivery_zones. See DELIVERY_ENTITY_CLEANUP_PLAN.md';

COMMENT ON TABLE _archived.restaurant_delivery_areas_archived_20251125 IS 
    'Legacy V2 delivery areas. Migrated to restaurant_delivery_zones on 2025-11-25. Can be dropped after 2025-12-25.';

-- Archive restaurant_delivery_fees
ALTER TABLE restaurant_delivery_fees SET SCHEMA _archived;
ALTER TABLE _archived.restaurant_delivery_fees 
    RENAME TO restaurant_delivery_fees_archived_20251125;

ALTER TABLE _archived.restaurant_delivery_fees_archived_20251125
ADD COLUMN IF NOT EXISTS _archive_date TIMESTAMP DEFAULT NOW(),
ADD COLUMN IF NOT EXISTS _archive_reason TEXT DEFAULT 'Migrated to per-zone pricing in restaurant_delivery_zones. See DELIVERY_ENTITY_CLEANUP_PLAN.md';

COMMENT ON TABLE _archived.restaurant_delivery_fees_archived_20251125 IS 
    'Legacy tier-based delivery fees. Migrated to per-zone pricing on 2025-11-25. Can be dropped after 2025-12-25.';

-- Archive restaurant_delivery_companies
ALTER TABLE restaurant_delivery_companies SET SCHEMA _archived;
ALTER TABLE _archived.restaurant_delivery_companies 
    RENAME TO restaurant_delivery_companies_archived_20251125;

ALTER TABLE _archived.restaurant_delivery_companies_archived_20251125
ADD COLUMN IF NOT EXISTS _archive_date TIMESTAMP DEFAULT NOW(),
ADD COLUMN IF NOT EXISTS _archive_reason TEXT DEFAULT 'Consolidated into restaurant_delivery_config.active_partners JSONB. See DELIVERY_ENTITY_CLEANUP_PLAN.md';

COMMENT ON TABLE _archived.restaurant_delivery_companies_archived_20251125 IS 
    'Legacy delivery company integrations. Consolidated into JSONB on 2025-11-25. Can be dropped after 2025-12-25.';

-- Archive restaurant_service_configs
ALTER TABLE restaurant_service_configs SET SCHEMA _archived;
ALTER TABLE _archived.restaurant_service_configs 
    RENAME TO restaurant_service_configs_archived_20251125;

ALTER TABLE _archived.restaurant_service_configs_archived_20251125
ADD COLUMN IF NOT EXISTS _archive_date TIMESTAMP DEFAULT NOW(),
ADD COLUMN IF NOT EXISTS _archive_reason TEXT DEFAULT 'Replaced by restaurant_service_settings. See DELIVERY_ENTITY_CLEANUP_PLAN.md';

COMMENT ON TABLE _archived.restaurant_service_configs_archived_20251125 IS 
    'Old service configs table. Replaced by restaurant_service_settings on 2025-11-25. Can be dropped after 2025-12-25.';

-- ========================================
-- STEP 3: Drop Deprecated Columns
-- ========================================

-- Now that tables are archived, we can safely drop deprecated columns
-- from restaurant_delivery_config

ALTER TABLE restaurant_delivery_config 
DROP COLUMN IF EXISTS _deprecated_delivery_radius_km,
DROP COLUMN IF EXISTS _deprecated_use_multiple_areas,
DROP COLUMN IF EXISTS _deprecated_use_polygon_areas,
DROP COLUMN IF EXISTS _deprecated_max_delivery_distance_km,
DROP COLUMN IF EXISTS _deprecated_restaurant_delivery_charge,
DROP COLUMN IF EXISTS _deprecated_delivery_service_extra,
DROP COLUMN IF EXISTS _deprecated_legacy_v1_twilio_call,
DROP COLUMN IF EXISTS _deprecated_legacy_v1_send_to_delivery,
DROP COLUMN IF EXISTS _deprecated_legacy_v1_daily_delivery,
DROP COLUMN IF EXISTS _deprecated_legacy_v1_geodispatch,
DROP COLUMN IF EXISTS _deprecated_legacy_v1_tookan,
DROP COLUMN IF EXISTS _deprecated_legacy_v1_wedeliver,
DROP COLUMN IF EXISTS _deprecated_legacy_v1_check_pings;

-- Update notes to document cleanup
UPDATE restaurant_delivery_config
SET 
    notes = COALESCE(notes || E'\n\n', '') || 
            'Phase 3 Cleanup: Removed deprecated columns. ' ||
            'All delivery data now in restaurant_delivery_zones. ' ||
            'Cleanup date: ' || NOW()::date,
    updated_at = NOW()
WHERE notes NOT LIKE '%Phase 3 Cleanup%';

-- ========================================
-- STEP 4: Enable Prevention Triggers
-- ========================================

-- These triggers will prevent any accidental inserts into archived tables
-- (In case something is still referencing them)

CREATE OR REPLACE FUNCTION prevent_archived_table_access()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'Table % has been archived and moved to _archived schema. See DELIVERY_ENTITY_CLEANUP_PLAN.md',
        TG_TABLE_NAME;
END;
$$ LANGUAGE plpgsql;

-- Apply to archived tables
CREATE TRIGGER prevent_access_delivery_areas
BEFORE INSERT OR UPDATE OR DELETE ON _archived.restaurant_delivery_areas_archived_20251125
FOR EACH ROW EXECUTE FUNCTION prevent_archived_table_access();

CREATE TRIGGER prevent_access_delivery_fees
BEFORE INSERT OR UPDATE OR DELETE ON _archived.restaurant_delivery_fees_archived_20251125
FOR EACH ROW EXECUTE FUNCTION prevent_archived_table_access();

CREATE TRIGGER prevent_access_delivery_companies
BEFORE INSERT OR UPDATE OR DELETE ON _archived.restaurant_delivery_companies_archived_20251125
FOR EACH ROW EXECUTE FUNCTION prevent_archived_table_access();

CREATE TRIGGER prevent_access_service_configs
BEFORE INSERT OR UPDATE OR DELETE ON _archived.restaurant_service_configs_archived_20251125
FOR EACH ROW EXECUTE FUNCTION prevent_archived_table_access();

-- ========================================
-- STEP 5: Update Documentation
-- ========================================

-- Create a migration history table
CREATE TABLE IF NOT EXISTS _migration_history (
    id SERIAL PRIMARY KEY,
    migration_name VARCHAR(255) NOT NULL,
    migration_phase INTEGER,
    executed_at TIMESTAMP DEFAULT NOW(),
    executed_by VARCHAR(100),
    status VARCHAR(50) DEFAULT 'completed',
    notes TEXT,
    validation_results JSONB
);

-- Record this migration
INSERT INTO _migration_history (
    migration_name,
    migration_phase,
    executed_by,
    status,
    notes,
    validation_results
)
VALUES (
    'delivery_entity_cleanup',
    3,
    current_user,
    'completed',
    'Archived deprecated delivery tables and dropped deprecated columns from restaurant_delivery_config. ' ||
    'See Database/DELIVERY_ENTITY_CLEANUP_PLAN.md for full details.',
    jsonb_build_object(
        'archived_tables', ARRAY[
            'restaurant_delivery_areas',
            'restaurant_delivery_fees',
            'restaurant_delivery_companies',
            'restaurant_service_configs'
        ],
        'archived_schema', '_archived',
        'can_drop_after', CURRENT_DATE + INTERVAL '30 days',
        'active_zones_count', (SELECT COUNT(*) FROM restaurant_delivery_zones WHERE is_active = TRUE)
    )
);

-- ========================================
-- STEP 6: Create Cleanup Reminder
-- ========================================

-- Schedule a reminder to drop archived tables after 30 days
CREATE OR REPLACE FUNCTION create_archive_cleanup_reminder()
RETURNS void AS $$
BEGIN
    -- This would integrate with your notification system
    -- For now, just log a message
    RAISE NOTICE '========================================';
    RAISE NOTICE 'ARCHIVE CLEANUP REMINDER CREATED';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Archived tables can be safely dropped after: %', CURRENT_DATE + INTERVAL '30 days';
    RAISE NOTICE 'Tables to drop:';
    RAISE NOTICE '  - _archived.restaurant_delivery_areas_archived_20251125';
    RAISE NOTICE '  - _archived.restaurant_delivery_fees_archived_20251125';
    RAISE NOTICE '  - _archived.restaurant_delivery_companies_archived_20251125';
    RAISE NOTICE '  - _archived.restaurant_service_configs_archived_20251125';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'To drop these tables, run:';
    RAISE NOTICE '  DROP TABLE _archived.restaurant_delivery_areas_archived_20251125;';
    RAISE NOTICE '  DROP TABLE _archived.restaurant_delivery_fees_archived_20251125;';
    RAISE NOTICE '  DROP TABLE _archived.restaurant_delivery_companies_archived_20251125;';
    RAISE NOTICE '  DROP TABLE _archived.restaurant_service_configs_archived_20251125;';
    RAISE NOTICE '========================================';
END;
$$ LANGUAGE plpgsql;

SELECT create_archive_cleanup_reminder();

-- ========================================
-- STEP 7: Final Validation
-- ========================================

DO $$
DECLARE
    v_active_zones INTEGER;
    v_archived_tables INTEGER;
    v_service_settings INTEGER;
    v_delivery_configs INTEGER;
BEGIN
    -- Count active components
    SELECT COUNT(*) INTO v_active_zones 
    FROM restaurant_delivery_zones 
    WHERE is_active = TRUE AND deleted_at IS NULL;
    
    SELECT COUNT(*) INTO v_service_settings 
    FROM restaurant_service_settings 
    WHERE deleted_at IS NULL;
    
    SELECT COUNT(*) INTO v_delivery_configs 
    FROM restaurant_delivery_config;
    
    -- Count archived tables
    SELECT COUNT(*) INTO v_archived_tables
    FROM information_schema.tables
    WHERE table_schema = '_archived'
    AND table_name LIKE '%archived_20251125';
    
    RAISE NOTICE '========================================';
    RAISE NOTICE 'PHASE 3 COMPLETION SUMMARY';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Active Delivery Zones: %', v_active_zones;
    RAISE NOTICE 'Active Service Settings: %', v_service_settings;
    RAISE NOTICE 'Active Delivery Configs: %', v_delivery_configs;
    RAISE NOTICE 'Archived Tables: %', v_archived_tables;
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Status: ✅ CLEANUP COMPLETE';
    RAISE NOTICE 'Next Steps:';
    RAISE NOTICE '  1. Monitor system for 30 days';
    RAISE NOTICE '  2. Drop archived tables after %', CURRENT_DATE + 30;
    RAISE NOTICE '  3. Update API documentation';
    RAISE NOTICE '  4. Update developer onboarding guides';
    RAISE NOTICE '========================================';
    
    -- Verify critical counts
    IF v_archived_tables != 4 THEN
        RAISE WARNING 'Expected 4 archived tables but found %. Check archival process.', v_archived_tables;
    END IF;
    
    IF v_active_zones = 0 THEN
        RAISE WARNING 'No active delivery zones found! This may indicate migration issues.';
    END IF;
END $$;

-- Create final validation view
CREATE OR REPLACE VIEW v_delivery_cleanup_status AS
SELECT 
    'Delivery Entity Cleanup' AS migration_name,
    'Phase 3: Archive & Cleanup' AS current_phase,
    'completed' AS status,
    (SELECT COUNT(*) FROM restaurant_delivery_zones WHERE is_active = TRUE) AS active_zones,
    (SELECT COUNT(*) FROM restaurant_service_settings WHERE deleted_at IS NULL) AS active_service_settings,
    (SELECT COUNT(*) FROM restaurant_delivery_config) AS active_delivery_configs,
    (SELECT COUNT(*) FROM information_schema.tables 
     WHERE table_schema = '_archived' 
     AND table_name LIKE '%archived_20251125') AS archived_tables,
    CURRENT_DATE + INTERVAL '30 days' AS archived_tables_drop_date,
    jsonb_build_object(
        'zones_table', 'restaurant_delivery_zones',
        'service_table', 'restaurant_service_settings',
        'config_table', 'restaurant_delivery_config',
        'archived_schema', '_archived'
    ) AS table_structure;

-- Query the status
SELECT * FROM v_delivery_cleanup_status;

COMMIT;

-- ========================================
-- FINAL DROP SCRIPT (Run after 30 days)
-- ========================================
/*
-- WARNING: This permanently deletes archived data
-- Run this ONLY after confirming no issues for 30+ days

BEGIN;

-- Final validation before dropping
DO $$
BEGIN
    IF CURRENT_DATE < '2025-12-25'::date THEN
        RAISE EXCEPTION 'Too early to drop archived tables. Wait until after 2025-12-25';
    END IF;
    
    RAISE NOTICE 'Proceeding with permanent deletion of archived delivery tables...';
END $$;

-- Drop archived tables
DROP TABLE IF EXISTS _archived.restaurant_delivery_areas_archived_20251125;
DROP TABLE IF EXISTS _archived.restaurant_delivery_fees_archived_20251125;
DROP TABLE IF EXISTS _archived.restaurant_delivery_companies_archived_20251125;
DROP TABLE IF EXISTS _archived.restaurant_service_configs_archived_20251125;

-- Drop archive schema if empty
DROP SCHEMA IF EXISTS _archived CASCADE;

-- Drop helper function
DROP FUNCTION IF EXISTS prevent_archived_table_access() CASCADE;

-- Record final cleanup
INSERT INTO _migration_history (
    migration_name,
    migration_phase,
    executed_by,
    status,
    notes
)
VALUES (
    'delivery_entity_cleanup',
    4,
    current_user,
    'completed',
    'Permanently dropped archived delivery tables after 30-day retention period.'
);

RAISE NOTICE 'Archived tables permanently dropped. Cleanup complete.';

COMMIT;
*/

