-- ============================================================================
-- MenuCA V3 - Combo Fix Rollback Script
-- ============================================================================
-- Purpose: Rollback combo_items migration if issues are found
-- Author: Brian Lapp, Santiago
-- Date: October 10, 2025
-- WARNING: This will DELETE all combo_items created by the migration fix
-- ============================================================================

-- SAFETY CHECK: Require explicit confirmation
DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '╔════════════════════════════════════════════════════╗';
  RAISE NOTICE '║              ⚠️  ROLLBACK WARNING  ⚠️               ║';
  RAISE NOTICE '╠════════════════════════════════════════════════════╣';
  RAISE NOTICE '║ This script will DELETE combo_items created by     ║';
  RAISE NOTICE '║ the migration fix. This action CANNOT be undone.  ║';
  RAISE NOTICE '║                                                    ║';
  RAISE NOTICE '║ To proceed, uncomment the ROLLBACK EXECUTION       ║';
  RAISE NOTICE '║ section at the bottom of this script.             ║';
  RAISE NOTICE '╚════════════════════════════════════════════════════╝';
  RAISE NOTICE '';
END $$;

-- ============================================================================
-- OPTION 1: FULL ROLLBACK (Delete ALL combo_items)
-- ============================================================================

-- Uncomment to execute full rollback
/*
BEGIN;

-- Backup before delete (optional but recommended)
CREATE TABLE IF NOT EXISTS menuca_v3.combo_items_backup_$(date +%Y%m%d_%H%M%S) AS
SELECT * FROM menuca_v3.combo_items;

-- Show pre-rollback state
DO $$
DECLARE
  v_total_items INT;
  v_groups_with_items INT;
BEGIN
  SELECT COUNT(*) INTO v_total_items FROM menuca_v3.combo_items;
  SELECT COUNT(DISTINCT combo_group_id) INTO v_groups_with_items FROM menuca_v3.combo_items;
  
  RAISE NOTICE '=== PRE-ROLLBACK STATE ===';
  RAISE NOTICE 'Total combo_items: %', v_total_items;
  RAISE NOTICE 'Groups with items: %', v_groups_with_items;
  RAISE NOTICE '==========================';
END $$;

-- Delete all combo_items
DELETE FROM menuca_v3.combo_items;

-- Show post-rollback state
DO $$
DECLARE
  v_total_items INT;
BEGIN
  SELECT COUNT(*) INTO v_total_items FROM menuca_v3.combo_items;
  
  RAISE NOTICE '=== POST-ROLLBACK STATE ===';
  RAISE NOTICE 'Total combo_items: %', v_total_items;
  RAISE NOTICE 'All combo items have been deleted.';
  RAISE NOTICE '===========================';
END $$;

-- Update statistics
ANALYZE menuca_v3.combo_items;

COMMIT;
*/

-- ============================================================================
-- OPTION 2: PARTIAL ROLLBACK (Delete only V1 source items)
-- ============================================================================

-- Uncomment to execute partial rollback (V1 only)
/*
BEGIN;

-- Show pre-rollback state
DO $$
DECLARE
  v_total_items INT;
  v_v1_items INT;
  v_v2_items INT;
BEGIN
  SELECT COUNT(*) INTO v_total_items FROM menuca_v3.combo_items;
  SELECT COUNT(*) INTO v_v1_items FROM menuca_v3.combo_items WHERE source_system = 'v1';
  SELECT COUNT(*) INTO v_v2_items FROM menuca_v3.combo_items WHERE source_system = 'v2';
  
  RAISE NOTICE '=== PRE-ROLLBACK STATE ===';
  RAISE NOTICE 'Total combo_items: %', v_total_items;
  RAISE NOTICE 'V1 items: %', v_v1_items;
  RAISE NOTICE 'V2 items: %', v_v2_items;
  RAISE NOTICE '==========================';
END $$;

-- Delete only V1 sourced items
DELETE FROM menuca_v3.combo_items
WHERE source_system = 'v1';

-- Show post-rollback state
DO $$
DECLARE
  v_total_items INT;
  v_deleted INT;
BEGIN
  GET DIAGNOSTICS v_deleted = ROW_COUNT;
  SELECT COUNT(*) INTO v_total_items FROM menuca_v3.combo_items;
  
  RAISE NOTICE '=== POST-ROLLBACK STATE ===';
  RAISE NOTICE 'Deleted V1 items: %', v_deleted;
  RAISE NOTICE 'Remaining items: %', v_total_items;
  RAISE NOTICE '===========================';
END $$;

-- Update statistics
ANALYZE menuca_v3.combo_items;

COMMIT;
*/

-- ============================================================================
-- OPTION 3: TIME-BASED ROLLBACK (Delete items created in last N hours)
-- ============================================================================

-- Uncomment and adjust time window to execute
/*
BEGIN;

-- Configure time window (default: last 1 hour)
DO $$
DECLARE
  v_rollback_window INTERVAL := INTERVAL '1 hour';
  v_cutoff_time TIMESTAMP;
  v_affected_items INT;
  v_remaining_items INT;
BEGIN
  v_cutoff_time := NOW() - v_rollback_window;
  
  -- Count affected items
  SELECT COUNT(*) INTO v_affected_items
  FROM menuca_v3.combo_items
  WHERE created_at >= v_cutoff_time;
  
  RAISE NOTICE '=== TIME-BASED ROLLBACK ===';
  RAISE NOTICE 'Cutoff time: %', v_cutoff_time;
  RAISE NOTICE 'Items to delete: %', v_affected_items;
  
  -- Delete items created after cutoff
  DELETE FROM menuca_v3.combo_items
  WHERE created_at >= v_cutoff_time;
  
  SELECT COUNT(*) INTO v_remaining_items FROM menuca_v3.combo_items;
  
  RAISE NOTICE 'Remaining items: %', v_remaining_items;
  RAISE NOTICE '===========================';
END $$;

-- Update statistics
ANALYZE menuca_v3.combo_items;

COMMIT;
*/

-- ============================================================================
-- OPTION 4: SPECIFIC COMBO GROUP ROLLBACK
-- ============================================================================

-- Uncomment and specify combo_group_ids to rollback specific groups
/*
BEGIN;

-- Delete items for specific combo groups
DELETE FROM menuca_v3.combo_items
WHERE combo_group_id IN (
  -- Add specific combo_group_id values here
  -- Example: 12345, 67890
);

DO $$
DECLARE
  v_deleted INT;
BEGIN
  GET DIAGNOSTICS v_deleted = ROW_COUNT;
  RAISE NOTICE 'Deleted items for % combo groups', v_deleted;
END $$;

COMMIT;
*/

-- ============================================================================
-- VERIFICATION AFTER ROLLBACK
-- ============================================================================

-- Run these queries after rollback to verify state

-- Check current orphan rate
SELECT 
  COUNT(*) as total_groups,
  COUNT(DISTINCT ci.combo_group_id) as groups_with_items,
  COUNT(*) - COUNT(DISTINCT ci.combo_group_id) as orphaned_groups,
  ROUND(
    ((COUNT(*) - COUNT(DISTINCT ci.combo_group_id))::numeric / COUNT(*)::numeric * 100),
    2
  ) as orphan_pct
FROM menuca_v3.combo_groups cg
LEFT JOIN menuca_v3.combo_items ci ON cg.id = ci.combo_group_id;

-- Check remaining combo_items
SELECT 
  source_system,
  COUNT(*) as count
FROM menuca_v3.combo_items
GROUP BY source_system;

-- ============================================================================
-- NOTES
-- ============================================================================

/*
WHEN TO ROLLBACK:
1. Data integrity issues found (null FKs, invalid references)
2. Orphan rate still > 20% after migration
3. Duplicate combo_items created
4. Wrong dishes mapped to wrong combo groups
5. Testing in staging revealed issues

HOW TO RE-RUN MIGRATION AFTER ROLLBACK:
1. Run this rollback script first
2. Investigate root cause of failure
3. Fix issues in fix_combo_items_migration.sql
4. Re-run fix_combo_items_migration.sql
5. Re-run validate_combo_fix.sql

BACKUP RESTORATION:
If backup table was created, restore with:
  
  INSERT INTO menuca_v3.combo_items
  SELECT * FROM menuca_v3.combo_items_backup_YYYYMMDD_HHMMSS;
*/

-- ============================================================================
-- END OF ROLLBACK SCRIPT
-- ============================================================================

