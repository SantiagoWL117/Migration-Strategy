-- ============================================================================
-- Restaurant Active Status Correction Script
-- ============================================================================
-- Purpose: Fix restaurants that are active in V1 but incorrectly marked as
--          suspended or pending in V3 due to V2 data overwrite during migration
--
-- Problem: During V1→V2→V3 migration, V2 data overwrote V1 data. However,
--          99% of restaurants remained operational in V1 after an abandoned
--          V2 migration attempt years ago. These were marked inactive in V2,
--          causing them to incorrectly appear with wrong status in V3.
--
-- Solution: Set status='active' where restaurant is active in V1,
--           regardless of V2 status
--
-- Impact: 101 restaurants will be updated
--         - 87 suspended → active
--         - 14 pending → active
--
-- Safety: This script is wrapped in a transaction and can be rolled back
-- ============================================================================

BEGIN;

-- Store current state for audit trail
CREATE TEMP TABLE pre_update_status AS
SELECT 
  r.id,
  r.name,
  r.status as old_status,
  r.suspended_at as old_suspended_at,
  r.updated_at as old_updated_at
FROM menuca_v3.restaurants r
WHERE r.id IN (
  SELECT v3_restaurant_id 
  FROM staging.active_restaurant_corrections
);

-- Show what will be updated
SELECT 
  COUNT(*) as restaurants_to_update,
  COUNT(CASE WHEN old_status = 'suspended' THEN 1 END) as suspended_to_active,
  COUNT(CASE WHEN old_status = 'pending' THEN 1 END) as pending_to_active,
  COUNT(CASE WHEN old_suspended_at IS NOT NULL THEN 1 END) as has_suspended_timestamp
FROM pre_update_status;

-- ============================================================================
-- MAIN UPDATE: Set status to 'active'
-- ============================================================================
UPDATE menuca_v3.restaurants
SET 
  status = 'active',
  suspended_at = NULL,  -- Clear suspended timestamp since now active
  updated_at = now()
WHERE id IN (
  SELECT v3_restaurant_id 
  FROM staging.active_restaurant_corrections 
  WHERE should_be_active = TRUE
);

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Show update summary
SELECT 
  '✅ UPDATE COMPLETE' as status,
  COUNT(*) as total_updated
FROM menuca_v3.restaurants r
WHERE r.id IN (SELECT v3_restaurant_id FROM staging.active_restaurant_corrections)
  AND r.status = 'active';

-- Show before/after comparison
SELECT 
  p.id,
  p.name,
  p.old_status,
  r.status as new_status,
  p.old_suspended_at,
  r.suspended_at as new_suspended_at,
  CASE 
    WHEN p.old_status != r.status::text THEN '✅ Status updated'
    ELSE '⚠️ No change'
  END as change_status
FROM pre_update_status p
JOIN menuca_v3.restaurants r ON r.id = p.id
ORDER BY p.id
LIMIT 25;

-- Verify all corrections were applied
SELECT 
  CASE 
    WHEN COUNT(*) = 0 THEN '✅ All corrections applied successfully'
    ELSE '⚠️ ' || COUNT(*) || ' corrections not applied'
  END as verification_result
FROM staging.active_restaurant_corrections c
JOIN menuca_v3.restaurants r ON r.id = c.v3_restaurant_id
WHERE r.status != 'active';

-- Show final status distribution
SELECT 
  '📊 Final V3 Status Distribution' as info,
  status,
  COUNT(*) as count
FROM menuca_v3.restaurants
GROUP BY status
ORDER BY count DESC;

-- ============================================================================
-- COMMIT OR ROLLBACK
-- ============================================================================
-- Review the verification queries above.
-- If everything looks correct, uncomment the COMMIT line below.
-- If there are issues, uncomment the ROLLBACK line.

-- COMMIT;  -- Uncomment to apply changes
-- ROLLBACK;  -- Uncomment to undo changes

-- ============================================================================
-- AFTER COMMIT: Document the changes
-- ============================================================================
-- Run this query after COMMIT to save a permanent audit trail:
/*
INSERT INTO menuca_v3.migration_audit_log (
  migration_name,
  affected_table,
  records_affected,
  description,
  executed_at
)
SELECT 
  'active_status_correction',
  'restaurants',
  101,
  'Corrected 101 restaurants (87 suspended→active, 14 pending→active) that were active in V1 but incorrectly marked in V3 due to V2 data overwrite',
  now();
*/

-- ============================================================================
-- END OF SCRIPT
-- ============================================================================

