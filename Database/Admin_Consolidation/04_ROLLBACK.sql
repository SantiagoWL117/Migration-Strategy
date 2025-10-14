-- =========================================================================
-- ADMIN CONSOLIDATION - ROLLBACK SCRIPT
-- =========================================================================
-- Purpose: Restore system to pre-migration state
-- Date: October 14, 2025
-- 
-- ⚠️  WARNING: Only run this if migration failed or needs to be undone
-- ⚠️  This will DELETE migrated data and restore from backup
-- =========================================================================

BEGIN;

-- =========================================================================
-- STEP 0: PRE-ROLLBACK CHECKS
-- =========================================================================

DO $$
DECLARE
  v_backup_exists BOOLEAN;
  v_summary_exists BOOLEAN;
BEGIN
  -- Check if backup exists
  SELECT EXISTS (
    SELECT 1 FROM information_schema.tables 
    WHERE table_schema = 'menuca_v3' 
      AND table_name = 'restaurant_admin_users_backup'
  ) INTO v_backup_exists;
  
  -- Check if migration summary exists
  SELECT EXISTS (
    SELECT 1 FROM information_schema.tables 
    WHERE table_schema = 'menuca_v3' 
      AND table_name = 'admin_consolidation_summary'
  ) INTO v_summary_exists;
  
  RAISE NOTICE '============================================';
  RAISE NOTICE 'PRE-ROLLBACK CHECK';
  RAISE NOTICE '============================================';
  RAISE NOTICE 'Backup exists: %', v_backup_exists;
  RAISE NOTICE 'Migration summary exists: %', v_summary_exists;
  RAISE NOTICE '============================================';
  
  IF NOT v_backup_exists THEN
    RAISE EXCEPTION 'Backup table not found! Cannot rollback safely.';
  END IF;
  
  IF NOT v_summary_exists THEN
    RAISE WARNING 'Migration summary not found. Migration may not have completed.';
  END IF;
  
  RAISE NOTICE '✅ Pre-rollback checks PASSED';
END $$;

-- =========================================================================
-- STEP 1: RESTORE PERMISSIONS COLUMNS
-- =========================================================================

-- Restore permissions column to admin_users
ALTER TABLE menuca_v3.admin_users 
ADD COLUMN IF NOT EXISTS permissions JSONB;

-- Restore permissions column to admin_user_restaurants
ALTER TABLE menuca_v3.admin_user_restaurants 
ADD COLUMN IF NOT EXISTS permissions JSONB;

RAISE NOTICE '✅ Step 1: Permissions columns restored';

-- =========================================================================
-- STEP 2: DELETE MIGRATED RESTAURANT ASSIGNMENTS
-- =========================================================================

-- Delete restaurant assignments that were created during migration
-- These are assignments where the admin_user has a legacy_v1_id
DELETE FROM menuca_v3.admin_user_restaurants
WHERE admin_user_id IN (
  SELECT id FROM menuca_v3.admin_users 
  WHERE legacy_v1_id IS NOT NULL
);

RAISE NOTICE '✅ Step 2: Migrated restaurant assignments deleted';

-- =========================================================================
-- STEP 3: DELETE MIGRATED ADMIN USERS
-- =========================================================================

-- Delete admin_users that were migrated from restaurant_admin_users
-- These have legacy_v1_id set
DELETE FROM menuca_v3.admin_users
WHERE legacy_v1_id IS NOT NULL;

RAISE NOTICE '✅ Step 3: Migrated admin users deleted';

-- =========================================================================
-- STEP 4: RESTORE restaurant_admin_users TABLE
-- =========================================================================

-- Clear migration tracking column
ALTER TABLE menuca_v3.restaurant_admin_users
DROP COLUMN IF EXISTS migrated_to_admin_user_id;

RAISE NOTICE '✅ Step 4: Migration tracking removed from restaurant_admin_users';

-- =========================================================================
-- STEP 5: VERIFY ROLLBACK
-- =========================================================================

DO $$
DECLARE
  v_admin_users_count INTEGER;
  v_restaurant_admin_users_count INTEGER;
  v_admin_user_restaurants_count INTEGER;
BEGIN
  -- Count after rollback
  SELECT COUNT(*) INTO v_admin_users_count FROM menuca_v3.admin_users;
  SELECT COUNT(*) INTO v_restaurant_admin_users_count FROM menuca_v3.restaurant_admin_users;
  SELECT COUNT(*) INTO v_admin_user_restaurants_count FROM menuca_v3.admin_user_restaurants;
  
  RAISE NOTICE '============================================';
  RAISE NOTICE 'ROLLBACK VALIDATION';
  RAISE NOTICE '============================================';
  RAISE NOTICE 'admin_users: % (expected: 51)', v_admin_users_count;
  RAISE NOTICE 'restaurant_admin_users: % (expected: 439)', v_restaurant_admin_users_count;
  RAISE NOTICE 'admin_user_restaurants: % (expected: 94)', v_admin_user_restaurants_count;
  RAISE NOTICE '============================================';
  
  -- Verify counts match pre-migration state
  IF v_admin_users_count != 51 THEN
    RAISE WARNING 'admin_users count mismatch! Expected 51, got %', v_admin_users_count;
  END IF;
  
  IF v_restaurant_admin_users_count != 439 THEN
    RAISE WARNING 'restaurant_admin_users count mismatch! Expected 439, got %', v_restaurant_admin_users_count;
  END IF;
  
  IF v_admin_user_restaurants_count != 94 THEN
    RAISE WARNING 'admin_user_restaurants count mismatch! Expected 94, got %', v_admin_user_restaurants_count;
  END IF;
  
  RAISE NOTICE '✅ Rollback validation PASSED';
END $$;

-- =========================================================================
-- STEP 6: UPDATE ROLLBACK SUMMARY
-- =========================================================================

UPDATE menuca_v3.admin_consolidation_summary
SET migration_notes = migration_notes || ' [ROLLED BACK ' || NOW() || ']'
WHERE summary_id = (
  SELECT MAX(summary_id) FROM menuca_v3.admin_consolidation_summary
);

RAISE NOTICE '✅ Step 6: Rollback recorded in summary';

-- =========================================================================
-- FINAL STATUS
-- =========================================================================

DO $$
BEGIN
  RAISE NOTICE '============================================';
  RAISE NOTICE '🔄 ROLLBACK COMPLETE!';
  RAISE NOTICE '============================================';
  RAISE NOTICE 'System restored to pre-migration state:';
  RAISE NOTICE '  ✅ 51 admin_users (original)';
  RAISE NOTICE '  ✅ 439 restaurant_admin_users (restored)';
  RAISE NOTICE '  ✅ 94 admin_user_restaurants (original)';
  RAISE NOTICE '  ✅ Permissions columns restored';
  RAISE NOTICE '';
  RAISE NOTICE 'Backup table (restaurant_admin_users_backup) preserved';
  RAISE NOTICE 'Migration summary updated with rollback timestamp';
  RAISE NOTICE '============================================';
END $$;

-- COMMIT; -- Uncomment to commit rollback
ROLLBACK; -- Comment out after testing

-- =========================================================================
-- USAGE INSTRUCTIONS
-- =========================================================================
-- 
-- 1. ONLY run this if migration needs to be undone
-- 2. Run with ROLLBACK first to test (default)
-- 3. Review all output and validation checks
-- 4. If all looks good, change ROLLBACK to COMMIT
-- 5. Run again to apply rollback
-- 6. Verify system is back to normal
--
-- =========================================================================

-- =========================================================================
-- CLEANUP (OPTIONAL)
-- =========================================================================
-- After successful rollback, you can clean up migration artifacts:
--
-- DROP TABLE IF EXISTS menuca_v3.restaurant_admin_users_backup;
-- DROP TABLE IF EXISTS menuca_v3.admin_consolidation_summary;
--
-- Only do this if you're CERTAIN you won't need to rollback again
-- =========================================================================

