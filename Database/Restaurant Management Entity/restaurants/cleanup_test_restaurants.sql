-- ============================================================================
-- Test Restaurant Cleanup Script
-- ============================================================================
-- Purpose: Identify and remove test/check restaurants from menuca_v3
-- Date: 2025-10-02
-- Target: menuca_v3.restaurants and menuca_v3.restaurant_locations
-- ============================================================================

-- ============================================================================
-- STEP 1: IDENTIFY TEST RECORDS (Review before deletion)
-- ============================================================================

-- Find restaurants with 'test' or 'check' in the name
SELECT 
  r.id,
  r.uuid,
  r.name,
  r.status,
  r.legacy_v1_id,
  r.legacy_v2_id,
  r.created_at,
  COUNT(rl.id) AS location_count
FROM menuca_v3.restaurants r
LEFT JOIN menuca_v3.restaurant_locations rl ON rl.restaurant_id = r.id
WHERE r.name ILIKE '%test%'
   OR r.name ILIKE '%check%'
GROUP BY r.id, r.uuid, r.name, r.status, r.legacy_v1_id, r.legacy_v2_id, r.created_at
ORDER BY r.name;

-- ============================================================================
-- STEP 2: CHECK FOR RELATED DATA (Understand dependencies)
-- ============================================================================

-- Check what related records will be affected
SELECT 
  'restaurant_locations' AS table_name,
  COUNT(*) AS records_to_delete
FROM menuca_v3.restaurant_locations
WHERE restaurant_id IN (
  SELECT id FROM menuca_v3.restaurants
  WHERE name ILIKE '%test%' OR name ILIKE '%check%'
)

UNION ALL

SELECT 
  'restaurants' AS table_name,
  COUNT(*) AS records_to_delete
FROM menuca_v3.restaurants
WHERE name ILIKE '%test%' OR name ILIKE '%check%';

-- ============================================================================
-- STEP 3: SAFE DELETION (Wrapped in transaction)
-- ============================================================================

BEGIN;

-- Store restaurant IDs to be deleted for verification
CREATE TEMP TABLE temp_restaurants_to_delete AS
SELECT id, name
FROM menuca_v3.restaurants
WHERE name ILIKE '%test%' 
   OR name ILIKE '%check%';

-- Show what will be deleted
SELECT 
  'Will delete ' || COUNT(*) || ' restaurants' AS summary
FROM temp_restaurants_to_delete;

SELECT * FROM temp_restaurants_to_delete ORDER BY name;

-- Delete related location records first (foreign key dependency)
DELETE FROM menuca_v3.restaurant_locations
WHERE restaurant_id IN (SELECT id FROM temp_restaurants_to_delete);

-- Capture deletion count
SELECT 
  'Deleted ' || COUNT(*) || ' location records' AS summary
FROM menuca_v3.restaurant_locations
WHERE restaurant_id IN (SELECT id FROM temp_restaurants_to_delete);

-- Delete restaurant records
DELETE FROM menuca_v3.restaurants
WHERE id IN (SELECT id FROM temp_restaurants_to_delete);

-- Show final counts
SELECT 
  'Deleted restaurants' AS summary,
  COUNT(*) AS deleted_count
FROM temp_restaurants_to_delete;

-- ============================================================================
-- VERIFICATION: Check that records are gone
-- ============================================================================

-- Should return 0
SELECT COUNT(*) AS remaining_test_restaurants
FROM menuca_v3.restaurants
WHERE name ILIKE '%test%' OR name ILIKE '%check%';

-- Should return 0
SELECT COUNT(*) AS orphaned_locations
FROM menuca_v3.restaurant_locations
WHERE restaurant_id IN (SELECT id FROM temp_restaurants_to_delete);

-- ============================================================================
-- COMMIT OR ROLLBACK
-- ============================================================================

-- Review the output above. If everything looks correct:
COMMIT;

-- If you want to undo:
-- ROLLBACK;

-- Clean up temp table
DROP TABLE IF EXISTS temp_restaurants_to_delete;

-- ============================================================================
-- POST-DELETION VERIFICATION
-- ============================================================================

-- Verify remaining restaurant count
SELECT COUNT(*) AS total_restaurants_remaining
FROM menuca_v3.restaurants;

-- Verify remaining location count
SELECT COUNT(*) AS total_locations_remaining
FROM menuca_v3.restaurant_locations;

-- Check for any orphaned locations (should be 0)
SELECT COUNT(*) AS orphaned_locations
FROM menuca_v3.restaurant_locations rl
LEFT JOIN menuca_v3.restaurants r ON r.id = rl.restaurant_id
WHERE r.id IS NULL;

