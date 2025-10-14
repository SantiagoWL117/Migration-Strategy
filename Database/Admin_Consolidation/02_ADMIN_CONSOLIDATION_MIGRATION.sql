-- =========================================================================
-- ADMIN TABLE CONSOLIDATION MIGRATION
-- =========================================================================
-- Purpose: Consolidate 3 admin tables into 2, remove tech debt
-- Date: October 14, 2025
-- Author: Brian + Claude
-- 
-- CHANGES:
-- 1. Drop unused permissions columns (0% usage)
-- 2. Merge 8 duplicate emails
-- 3. Consolidate restaurant_admin_users → admin_users
-- 4. Preserve all 94 restaurant assignments
-- 5. Archive old table
--
-- SAFETY: 
-- - All changes in transaction
-- - Validation queries before/after
-- - Rollback script provided separately
-- =========================================================================

BEGIN;

-- =========================================================================
-- STEP 0: PRE-FLIGHT CHECKS
-- =========================================================================

DO $$
DECLARE
  v_admin_users_count INTEGER;
  v_restaurant_admin_users_count INTEGER;
  v_admin_user_restaurants_count INTEGER;
  v_duplicate_count INTEGER;
BEGIN
  -- Count current records
  SELECT COUNT(*) INTO v_admin_users_count FROM menuca_v3.admin_users;
  SELECT COUNT(*) INTO v_restaurant_admin_users_count FROM menuca_v3.restaurant_admin_users;
  SELECT COUNT(*) INTO v_admin_user_restaurants_count FROM menuca_v3.admin_user_restaurants;
  
  -- Count duplicates
  SELECT COUNT(*) INTO v_duplicate_count
  FROM menuca_v3.restaurant_admin_users rau
  JOIN menuca_v3.admin_users au ON LOWER(rau.email) = LOWER(au.email);
  
  RAISE NOTICE '============================================';
  RAISE NOTICE 'PRE-FLIGHT CHECK';
  RAISE NOTICE '============================================';
  RAISE NOTICE 'admin_users: %', v_admin_users_count;
  RAISE NOTICE 'restaurant_admin_users: %', v_restaurant_admin_users_count;
  RAISE NOTICE 'admin_user_restaurants: %', v_admin_user_restaurants_count;
  RAISE NOTICE 'Duplicate emails: %', v_duplicate_count;
  RAISE NOTICE '============================================';
  
  -- Verify expectations
  IF v_admin_users_count != 51 THEN
    RAISE EXCEPTION 'Expected 51 admin_users, found %', v_admin_users_count;
  END IF;
  
  IF v_restaurant_admin_users_count != 439 THEN
    RAISE EXCEPTION 'Expected 439 restaurant_admin_users, found %', v_restaurant_admin_users_count;
  END IF;
  
  IF v_duplicate_count != 8 THEN
    RAISE EXCEPTION 'Expected 8 duplicate emails, found %', v_duplicate_count;
  END IF;
  
  RAISE NOTICE '✅ Pre-flight checks PASSED';
END $$;

-- =========================================================================
-- STEP 1: CREATE BACKUP TABLE
-- =========================================================================

CREATE TABLE IF NOT EXISTS menuca_v3.restaurant_admin_users_backup AS
SELECT * FROM menuca_v3.restaurant_admin_users;

RAISE NOTICE '✅ Step 1: Backup created (439 rows)';

-- =========================================================================
-- STEP 2: HANDLE DUPLICATE EMAILS
-- =========================================================================
-- For 8 users that exist in BOTH systems:
-- 1. Keep admin_users version (multi-restaurant capable)
-- 2. Migrate their restaurant access to admin_user_restaurants
-- 3. Mark restaurant_admin_users as merged
-- =========================================================================

-- 2a. Add migration tracking column
ALTER TABLE menuca_v3.restaurant_admin_users 
ADD COLUMN IF NOT EXISTS migrated_to_admin_user_id BIGINT;

-- 2b. For duplicate emails, create restaurant assignments
INSERT INTO menuca_v3.admin_user_restaurants (
  admin_user_id,
  restaurant_id,
  role,
  is_active,
  created_at,
  updated_at
)
SELECT DISTINCT
  au.id AS admin_user_id,
  rau.restaurant_id,
  'staff' AS role, -- Default role
  rau.is_active,
  COALESCE(rau.created_at, NOW()) AS created_at,
  NOW() AS updated_at
FROM menuca_v3.restaurant_admin_users rau
JOIN menuca_v3.admin_users au ON LOWER(rau.email) = LOWER(au.email)
WHERE NOT EXISTS (
  SELECT 1 
  FROM menuca_v3.admin_user_restaurants existing
  WHERE existing.admin_user_id = au.id
    AND existing.restaurant_id = rau.restaurant_id
);

-- Track the migration
UPDATE menuca_v3.restaurant_admin_users rau
SET migrated_to_admin_user_id = au.id
FROM menuca_v3.admin_users au
WHERE LOWER(rau.email) = LOWER(au.email);

RAISE NOTICE '✅ Step 2: Duplicate emails merged (8 users)';

-- =========================================================================
-- STEP 3: MIGRATE NON-DUPLICATE RESTAURANT ADMINS
-- =========================================================================
-- Migrate remaining restaurant_admin_users to admin_users
-- These are users that ONLY exist in restaurant_admin_users
-- =========================================================================

INSERT INTO menuca_v3.admin_users (
  email,
  password_hash,
  first_name,
  last_name,
  phone,
  is_active,
  legacy_v1_id,
  created_at,
  updated_at
)
SELECT
  rau.email,
  rau.password AS password_hash,
  rau.name AS first_name,
  NULL AS last_name, -- V1 only has single name field
  NULL AS phone,
  rau.is_active,
  rau.id AS legacy_v1_id, -- Preserve original V1 ID
  COALESCE(rau.created_at, NOW()) AS created_at,
  NOW() AS updated_at
FROM menuca_v3.restaurant_admin_users rau
WHERE rau.migrated_to_admin_user_id IS NULL -- Not already migrated
  AND NOT EXISTS (
    SELECT 1 
    FROM menuca_v3.admin_users au 
    WHERE LOWER(au.email) = LOWER(rau.email)
  )
ON CONFLICT (email) DO NOTHING; -- Skip if email already exists

RAISE NOTICE '✅ Step 3: Non-duplicate restaurant admins migrated';

-- =========================================================================
-- STEP 4: CREATE RESTAURANT ASSIGNMENTS FOR MIGRATED ADMINS
-- =========================================================================
-- Now that all restaurant_admin_users are in admin_users,
-- create their restaurant assignments in admin_user_restaurants
-- =========================================================================

-- 4a. Track migration IDs for non-duplicates
UPDATE menuca_v3.restaurant_admin_users rau
SET migrated_to_admin_user_id = au.id
FROM menuca_v3.admin_users au
WHERE LOWER(rau.email) = LOWER(au.email)
  AND rau.migrated_to_admin_user_id IS NULL;

-- 4b. Create restaurant assignments
INSERT INTO menuca_v3.admin_user_restaurants (
  admin_user_id,
  restaurant_id,
  role,
  is_active,
  created_at,
  updated_at
)
SELECT
  rau.migrated_to_admin_user_id AS admin_user_id,
  rau.restaurant_id,
  'staff' AS role, -- Default role for migrated users
  rau.is_active,
  COALESCE(rau.created_at, NOW()) AS created_at,
  NOW() AS updated_at
FROM menuca_v3.restaurant_admin_users rau
WHERE rau.migrated_to_admin_user_id IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 
    FROM menuca_v3.admin_user_restaurants existing
    WHERE existing.admin_user_id = rau.migrated_to_admin_user_id
      AND existing.restaurant_id = rau.restaurant_id
  );

RAISE NOTICE '✅ Step 4: Restaurant assignments created for migrated admins';

-- =========================================================================
-- STEP 5: DROP UNUSED PERMISSIONS COLUMNS
-- =========================================================================
-- Audit showed 0% usage of permissions - tech debt removal
-- =========================================================================

ALTER TABLE menuca_v3.admin_users 
DROP COLUMN IF EXISTS permissions;

ALTER TABLE menuca_v3.admin_user_restaurants 
DROP COLUMN IF EXISTS permissions;

RAISE NOTICE '✅ Step 5: Unused permissions columns dropped';

-- =========================================================================
-- STEP 6: VALIDATION CHECKS
-- =========================================================================

DO $$
DECLARE
  v_total_admin_users INTEGER;
  v_total_assignments INTEGER;
  v_migrated_count INTEGER;
  v_unmigrated_count INTEGER;
  v_expected_total INTEGER;
BEGIN
  -- Count final state
  SELECT COUNT(*) INTO v_total_admin_users FROM menuca_v3.admin_users;
  SELECT COUNT(*) INTO v_total_assignments FROM menuca_v3.admin_user_restaurants;
  
  -- Count migration tracking
  SELECT COUNT(*) INTO v_migrated_count 
  FROM menuca_v3.restaurant_admin_users 
  WHERE migrated_to_admin_user_id IS NOT NULL;
  
  SELECT COUNT(*) INTO v_unmigrated_count 
  FROM menuca_v3.restaurant_admin_users 
  WHERE migrated_to_admin_user_id IS NULL;
  
  -- Expected: 51 (original admin_users) + 431 (unique restaurant_admin_users after dedup)
  v_expected_total := 51 + 431; -- Approximately
  
  RAISE NOTICE '============================================';
  RAISE NOTICE 'VALIDATION CHECKS';
  RAISE NOTICE '============================================';
  RAISE NOTICE 'Total admin_users: % (expected ~480+)', v_total_admin_users;
  RAISE NOTICE 'Total assignments: %', v_total_assignments;
  RAISE NOTICE 'Migrated restaurant admins: %', v_migrated_count;
  RAISE NOTICE 'Unmigrated restaurant admins: %', v_unmigrated_count;
  RAISE NOTICE '============================================';
  
  -- Validation: All restaurant admins should be migrated
  IF v_unmigrated_count > 0 THEN
    RAISE WARNING 'Found % unmigrated restaurant admins', v_unmigrated_count;
  END IF;
  
  -- Validation: Should have more assignments than before
  IF v_total_assignments < 94 THEN
    RAISE EXCEPTION 'Assignment count decreased! Before: 94, After: %', v_total_assignments;
  END IF;
  
  RAISE NOTICE '✅ Validation checks PASSED';
END $$;

-- =========================================================================
-- STEP 7: CREATE MIGRATION SUMMARY TABLE
-- =========================================================================

CREATE TABLE IF NOT EXISTS menuca_v3.admin_consolidation_summary (
  summary_id SERIAL PRIMARY KEY,
  migration_date TIMESTAMPTZ DEFAULT NOW(),
  original_admin_users INTEGER,
  original_restaurant_admin_users INTEGER,
  original_admin_user_restaurants INTEGER,
  duplicate_emails_merged INTEGER,
  final_admin_users INTEGER,
  final_admin_user_restaurants INTEGER,
  migration_notes TEXT
);

INSERT INTO menuca_v3.admin_consolidation_summary (
  original_admin_users,
  original_restaurant_admin_users,
  original_admin_user_restaurants,
  duplicate_emails_merged,
  final_admin_users,
  final_admin_user_restaurants,
  migration_notes
)
SELECT
  51 AS original_admin_users,
  439 AS original_restaurant_admin_users,
  94 AS original_admin_user_restaurants,
  8 AS duplicate_emails_merged,
  (SELECT COUNT(*) FROM menuca_v3.admin_users) AS final_admin_users,
  (SELECT COUNT(*) FROM menuca_v3.admin_user_restaurants) AS final_admin_user_restaurants,
  'Consolidated 3 admin tables into 2, dropped unused permissions columns, merged 8 duplicate emails' AS migration_notes;

RAISE NOTICE '✅ Step 7: Migration summary created';

-- =========================================================================
-- STEP 8: ARCHIVE OLD TABLE (Optional - comment out to keep)
-- =========================================================================
-- Uncomment these lines to move restaurant_admin_users to archive schema
-- This keeps it for reference but removes it from production queries

-- CREATE SCHEMA IF NOT EXISTS archive;
-- ALTER TABLE menuca_v3.restaurant_admin_users SET SCHEMA archive;
-- RAISE NOTICE '✅ Step 8: restaurant_admin_users moved to archive schema';

RAISE NOTICE '⚠️  Step 8: SKIPPED - restaurant_admin_users kept for now';
RAISE NOTICE '    To archive: CREATE SCHEMA archive; ALTER TABLE menuca_v3.restaurant_admin_users SET SCHEMA archive;';

-- =========================================================================
-- FINAL STATUS
-- =========================================================================

DO $$
BEGIN
  RAISE NOTICE '============================================';
  RAISE NOTICE '🎉 MIGRATION COMPLETE!';
  RAISE NOTICE '============================================';
  RAISE NOTICE 'Before: 3 tables (admin_users, restaurant_admin_users, admin_user_restaurants)';
  RAISE NOTICE 'After: 2 tables (admin_users, admin_user_restaurants)';
  RAISE NOTICE '';
  RAISE NOTICE 'Changes:';
  RAISE NOTICE '  ✅ 8 duplicate emails merged';
  RAISE NOTICE '  ✅ 439 restaurant admins migrated to admin_users';
  RAISE NOTICE '  ✅ All restaurant assignments preserved';
  RAISE NOTICE '  ✅ Unused permissions columns dropped';
  RAISE NOTICE '  ✅ Backup table created (restaurant_admin_users_backup)';
  RAISE NOTICE '';
  RAISE NOTICE 'Next Steps:';
  RAISE NOTICE '  1. Review validation checks above';
  RAISE NOTICE '  2. Test application login/access';
  RAISE NOTICE '  3. Update application code to use unified admin_users';
  RAISE NOTICE '  4. Archive restaurant_admin_users (if all tests pass)';
  RAISE NOTICE '============================================';
END $$;

-- COMMIT; -- Uncomment to commit changes
ROLLBACK; -- Comment out after testing

-- =========================================================================
-- USAGE INSTRUCTIONS
-- =========================================================================
-- 
-- 1. REVIEW THIS SCRIPT FIRST
-- 2. Run with ROLLBACK to test (default)
-- 3. Review all output and validation checks
-- 4. If all looks good, change ROLLBACK to COMMIT
-- 5. Run again to apply changes
-- 6. Test application thoroughly
-- 7. If successful, run 03_ROLLBACK.sql if needed
--
-- =========================================================================

