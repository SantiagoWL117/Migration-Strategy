-- ========================================
-- DELIVERY ENTITY CLEANUP - PHASE 1
-- Data Consolidation & Migration
-- ========================================
-- Created: 2025-11-25
-- Purpose: Consolidate data from 3 legacy delivery tables into restaurant_delivery_zones
-- Affected Tables: restaurant_delivery_areas, restaurant_delivery_fees, restaurant_delivery_companies
-- ========================================

BEGIN;

-- ========================================
-- STEP 1: Enable Migration Tracking
-- ========================================

-- Add migration tracking columns to source tables
ALTER TABLE restaurant_delivery_areas 
ADD COLUMN IF NOT EXISTS migrated_to_zones_at TIMESTAMP,
ADD COLUMN IF NOT EXISTS migrated_zone_id BIGINT;

ALTER TABLE restaurant_delivery_fees 
ADD COLUMN IF NOT EXISTS migrated_to_zones_at TIMESTAMP,
ADD COLUMN IF NOT EXISTS migrated_zone_id BIGINT;

-- ========================================
-- STEP 2: Migrate Legacy Delivery Areas
-- ========================================

-- Migrate from restaurant_delivery_areas (legacy V2 polygons)
-- Only migrate areas with valid geometry
INSERT INTO restaurant_delivery_zones (
    restaurant_id,
    zone_name,
    zone_geometry,
    delivery_fee_cents,
    minimum_order_cents,
    estimated_delivery_minutes,
    is_active,
    created_at,
    created_by
)
SELECT 
    rda.restaurant_id,
    -- Use display_name if available, fallback to area_name, fallback to generated name
    COALESCE(
        NULLIF(rda.display_name, ''),
        NULLIF(rda.area_name, ''),
        'Zone ' || rda.area_number
    ) AS zone_name,
    rda.geometry AS zone_geometry,
    -- Convert fees from dollars to cents, default to 0 if NULL
    CASE 
        WHEN rda.fee_type = 'free' THEN 0
        WHEN rda.fee_type = 'flat' THEN COALESCE(rda.delivery_fee * 100, 0)
        WHEN rda.fee_type = 'conditional' THEN COALESCE(rda.conditional_fee * 100, 0)
        ELSE 0
    END AS delivery_fee_cents,
    -- Convert minimum order from dollars to cents
    COALESCE(rda.min_order_value * 100, 0) AS minimum_order_cents,
    -- Use default delivery time from service configs (we'll join to get this)
    COALESCE(rsc.delivery_time_minutes, 60) AS estimated_delivery_minutes,
    rda.is_active,
    rda.created_at,
    rda.created_by
FROM restaurant_delivery_areas rda
LEFT JOIN restaurant_service_configs rsc ON rsc.restaurant_id = rda.restaurant_id
WHERE 
    rda.geometry IS NOT NULL
    AND rda.migrated_to_zones_at IS NULL  -- Only migrate unmigrated records
RETURNING id, restaurant_id;

-- Update migration tracking
UPDATE restaurant_delivery_areas rda
SET 
    migrated_to_zones_at = NOW(),
    migrated_zone_id = (
        SELECT rdz.id 
        FROM restaurant_delivery_zones rdz
        WHERE rdz.restaurant_id = rda.restaurant_id
        AND rdz.created_at >= NOW() - INTERVAL '5 minutes'  -- Just created
        ORDER BY rdz.created_at DESC
        LIMIT 1
    )
WHERE rda.migrated_to_zones_at IS NULL
AND rda.geometry IS NOT NULL;

-- ========================================
-- STEP 3: Migrate Fee Tiers to Zones
-- ========================================

-- For restaurants using fee tiers but no existing zones,
-- create a zone based on the first tier
-- This is a simplified migration - assumes tier 1 is the base zone

-- First, create zones for restaurants that have fees but no areas
INSERT INTO restaurant_delivery_zones (
    restaurant_id,
    zone_name,
    zone_geometry,
    center_latitude,
    center_longitude,
    radius_meters,
    delivery_fee_cents,
    minimum_order_cents,
    estimated_delivery_minutes,
    is_active,
    created_at,
    created_by
)
SELECT DISTINCT ON (rdf.restaurant_id)
    rdf.restaurant_id,
    'Primary Delivery Zone' AS zone_name,
    -- Create circular zone from restaurant location
    ST_Buffer(
        ST_SetSRID(
            ST_MakePoint(rl.longitude, rl.latitude),
            4326
        )::geography,
        COALESCE(rdc.delivery_radius_km, 10) * 1000  -- Default 10km if not set
    )::geometry AS zone_geometry,
    rl.latitude AS center_latitude,
    rl.longitude AS center_longitude,
    COALESCE(rdc.delivery_radius_km, 10) * 1000 AS radius_meters,
    -- Use fee from tier 1
    COALESCE(rdf.total_delivery_fee * 100, 0) AS delivery_fee_cents,
    -- Use minimum from service config
    COALESCE(rsc.delivery_min_order * 100, 0) AS minimum_order_cents,
    COALESCE(rsc.delivery_time_minutes, 60) AS estimated_delivery_minutes,
    rdf.is_active,
    NOW() AS created_at,
    1 AS created_by  -- System migration user
FROM restaurant_delivery_fees rdf
INNER JOIN restaurant_locations rl ON rl.restaurant_id = rdf.restaurant_id AND rl.is_primary = TRUE
LEFT JOIN restaurant_delivery_config rdc ON rdc.restaurant_id = rdf.restaurant_id
LEFT JOIN restaurant_service_configs rsc ON rsc.restaurant_id = rdf.restaurant_id
WHERE 
    rdf.tier_value = 1  -- Only migrate first tier
    AND rdf.is_active = TRUE
    AND rdf.migrated_to_zones_at IS NULL
    -- Don't create duplicate zones
    AND NOT EXISTS (
        SELECT 1 
        FROM restaurant_delivery_zones rdz 
        WHERE rdz.restaurant_id = rdf.restaurant_id
    )
ORDER BY rdf.restaurant_id, rdf.tier_value;

-- Update migration tracking for fees
UPDATE restaurant_delivery_fees rdf
SET 
    migrated_to_zones_at = NOW(),
    migrated_zone_id = (
        SELECT rdz.id 
        FROM restaurant_delivery_zones rdz
        WHERE rdz.restaurant_id = rdf.restaurant_id
        AND rdz.created_at >= NOW() - INTERVAL '5 minutes'
        ORDER BY rdz.created_at DESC
        LIMIT 1
    )
WHERE rdf.migrated_to_zones_at IS NULL
AND rdf.tier_value = 1
AND rdf.is_active = TRUE;

-- ========================================
-- STEP 4: Consolidate Delivery Companies
-- ========================================

-- Move delivery company data into active_partners JSONB in restaurant_delivery_config
UPDATE restaurant_delivery_config rdc
SET 
    active_partners = COALESCE(rdc.active_partners, '[]'::jsonb) || (
        SELECT COALESCE(jsonb_agg(
            jsonb_build_object(
                'type', 'third_party_delivery',
                'company_id', rdcomp.id,
                'company_name', rdcomp.company_name,
                'company_email', rdcomp.company_email_id,
                'sends_to_delivery', rdcomp.sends_to_delivery,
                'can_suspend_delivery', rdcomp.can_suspend_delivery,
                'commission_rate', rdcomp.commission,
                'restaurant_pays_driver', rdcomp.restaurant_pays_driver,
                'enabled', rdcomp.is_active,
                'migrated_from', 'restaurant_delivery_companies',
                'migrated_at', NOW()
            )
        ), '[]'::jsonb)
        FROM restaurant_delivery_companies rdcomp
        WHERE rdcomp.restaurant_id = rdc.restaurant_id
    ),
    updated_at = NOW(),
    notes = COALESCE(notes || E'\n\n', '') || 
            'Migrated ' || (
                SELECT COUNT(*)::text 
                FROM restaurant_delivery_companies rdcomp
                WHERE rdcomp.restaurant_id = rdc.restaurant_id
            ) || ' delivery companies to active_partners on ' || NOW()::date
WHERE EXISTS (
    SELECT 1 
    FROM restaurant_delivery_companies rdcomp
    WHERE rdcomp.restaurant_id = rdc.restaurant_id
);

-- ========================================
-- STEP 5: Validation Queries
-- ========================================

-- Create a validation summary
DO $$
DECLARE
    v_areas_migrated INTEGER;
    v_areas_failed INTEGER;
    v_fees_migrated INTEGER;
    v_fees_failed INTEGER;
    v_companies_migrated INTEGER;
    v_new_zones_created INTEGER;
BEGIN
    -- Count migrated areas
    SELECT COUNT(*) INTO v_areas_migrated
    FROM restaurant_delivery_areas
    WHERE migrated_to_zones_at IS NOT NULL;
    
    -- Count failed areas
    SELECT COUNT(*) INTO v_areas_failed
    FROM restaurant_delivery_areas
    WHERE migrated_to_zones_at IS NULL
    AND geometry IS NOT NULL;
    
    -- Count migrated fees
    SELECT COUNT(*) INTO v_fees_migrated
    FROM restaurant_delivery_fees
    WHERE migrated_to_zones_at IS NOT NULL;
    
    -- Count failed fees
    SELECT COUNT(*) INTO v_fees_failed
    FROM restaurant_delivery_fees
    WHERE migrated_to_zones_at IS NULL
    AND tier_value = 1
    AND is_active = TRUE;
    
    -- Count companies migrated
    SELECT COUNT(DISTINCT restaurant_id) INTO v_companies_migrated
    FROM restaurant_delivery_companies;
    
    -- Count new zones created
    SELECT COUNT(*) INTO v_new_zones_created
    FROM restaurant_delivery_zones
    WHERE created_at >= NOW() - INTERVAL '5 minutes';
    
    -- Output results
    RAISE NOTICE '========================================';
    RAISE NOTICE 'MIGRATION PHASE 1 VALIDATION SUMMARY';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Legacy Areas Migrated: % of 16', v_areas_migrated;
    RAISE NOTICE 'Legacy Areas Failed: %', v_areas_failed;
    RAISE NOTICE 'Fee Tiers Migrated: % of 43', v_fees_migrated;
    RAISE NOTICE 'Fee Tiers Failed: %', v_fees_failed;
    RAISE NOTICE 'Companies Migrated: % restaurants', v_companies_migrated;
    RAISE NOTICE 'New Zones Created: %', v_new_zones_created;
    RAISE NOTICE '========================================';
    
    -- Fail if any records didn't migrate
    IF v_areas_failed > 0 OR v_fees_failed > 0 THEN
        RAISE WARNING 'Some records failed to migrate. Check logs for details.';
    END IF;
END $$;

-- ========================================
-- STEP 6: Create Validation Views
-- ========================================

-- Create a view to compare old vs new data
CREATE OR REPLACE VIEW v_delivery_migration_comparison AS
SELECT 
    r.id AS restaurant_id,
    r.name AS restaurant_name,
    -- Old system (areas)
    rda.id AS old_area_id,
    rda.area_name AS old_area_name,
    rda.delivery_fee AS old_area_fee,
    rda.migrated_zone_id,
    -- Old system (fees)
    rdf.id AS old_fee_id,
    rdf.total_delivery_fee AS old_tier_fee,
    -- New system (zones)
    rdz.id AS new_zone_id,
    rdz.zone_name AS new_zone_name,
    rdz.delivery_fee_cents / 100.0 AS new_zone_fee,
    rdz.minimum_order_cents / 100.0 AS new_zone_minimum,
    -- Validation
    CASE 
        WHEN rdz.id IS NOT NULL THEN '✅ Migrated'
        WHEN rda.id IS NULL AND rdf.id IS NULL THEN '⚠️ No Legacy Data'
        ELSE '❌ Not Migrated'
    END AS migration_status
FROM restaurants r
LEFT JOIN restaurant_delivery_areas rda ON rda.restaurant_id = r.id
LEFT JOIN restaurant_delivery_fees rdf ON rdf.restaurant_id = r.id AND rdf.tier_value = 1
LEFT JOIN restaurant_delivery_zones rdz ON rdz.restaurant_id = r.id
WHERE r.status = 'active'
ORDER BY migration_status, r.name;

-- Query the validation view
SELECT 
    migration_status,
    COUNT(*) AS restaurant_count
FROM v_delivery_migration_comparison
GROUP BY migration_status
ORDER BY migration_status;

COMMIT;

-- ========================================
-- ROLLBACK SCRIPT (if needed)
-- ========================================
/*
BEGIN;

-- Delete zones created during migration
DELETE FROM restaurant_delivery_zones
WHERE created_at >= '2025-11-25'  -- Adjust date as needed
AND created_by = 1;  -- System migration user

-- Clear migration tracking
UPDATE restaurant_delivery_areas
SET migrated_to_zones_at = NULL, migrated_zone_id = NULL;

UPDATE restaurant_delivery_fees
SET migrated_to_zones_at = NULL, migrated_zone_id = NULL;

-- Remove consolidated company data from active_partners
UPDATE restaurant_delivery_config
SET 
    active_partners = (
        SELECT jsonb_agg(elem)
        FROM jsonb_array_elements(active_partners) elem
        WHERE elem->>'migrated_from' IS DISTINCT FROM 'restaurant_delivery_companies'
    ),
    notes = regexp_replace(notes, E'\n\nMigrated \\d+ delivery companies.*', '', 'g');

COMMIT;
*/

