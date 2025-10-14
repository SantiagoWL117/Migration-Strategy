-- =========================================================================
-- ADMIN CONSOLIDATION - VALIDATION QUERIES
-- =========================================================================
-- Purpose: Verify migration success and data integrity
-- Date: October 14, 2025
-- Run these AFTER migration to confirm everything worked
-- =========================================================================

-- =========================================================================
-- 1. OVERALL COUNTS
-- =========================================================================

SELECT 
  '1. Overall Counts' as check_name,
  (SELECT COUNT(*) FROM menuca_v3.admin_users) as total_admin_users,
  (SELECT COUNT(*) FROM menuca_v3.admin_user_restaurants) as total_restaurant_assignments,
  (SELECT COUNT(*) FROM menuca_v3.restaurant_admin_users) as restaurant_admin_users_remaining,
  (SELECT COUNT(*) FROM menuca_v3.restaurant_admin_users_backup) as backup_count;

-- Expected:
-- - total_admin_users: ~480+ (51 original + 431 migrated)
-- - total_restaurant_assignments: 94+ (original) + 439 (migrated)
-- - restaurant_admin_users_remaining: 439 (still exists, not deleted)
-- - backup_count: 439

-- =========================================================================
-- 2. MIGRATION TRACKING
-- =========================================================================

SELECT 
  '2. Migration Tracking' as check_name,
  COUNT(*) as total_restaurant_admins,
  COUNT(CASE WHEN migrated_to_admin_user_id IS NOT NULL THEN 1 END) as migrated,
  COUNT(CASE WHEN migrated_to_admin_user_id IS NULL THEN 1 END) as not_migrated,
  ROUND(COUNT(CASE WHEN migrated_to_admin_user_id IS NOT NULL THEN 1 END)::numeric / COUNT(*) * 100, 2) as percent_migrated
FROM menuca_v3.restaurant_admin_users;

-- Expected:
-- - migrated: 439 (100%)
-- - not_migrated: 0

-- =========================================================================
-- 3. DUPLICATE EMAILS CHECK
-- =========================================================================

SELECT 
  '3. Duplicate Emails' as check_name,
  COUNT(*) as duplicate_count
FROM menuca_v3.restaurant_admin_users rau
JOIN menuca_v3.admin_users au ON LOWER(rau.email) = LOWER(au.email);

-- Expected: 8 (duplicates still exist in old table, but resolved in new system)

-- =========================================================================
-- 4. EMAIL UNIQUENESS IN ADMIN_USERS
-- =========================================================================

SELECT 
  '4. Email Uniqueness in admin_users' as check_name,
  COUNT(*) as total_emails,
  COUNT(DISTINCT LOWER(email)) as unique_emails,
  COUNT(*) - COUNT(DISTINCT LOWER(email)) as duplicate_emails
FROM menuca_v3.admin_users;

-- Expected: duplicate_emails = 0 (all emails should be unique)

-- =========================================================================
-- 5. RESTAURANT ASSIGNMENTS VALIDATION
-- =========================================================================

SELECT 
  '5. Restaurant Assignments' as check_name,
  COUNT(*) as total_assignments,
  COUNT(DISTINCT admin_user_id) as unique_admins,
  COUNT(DISTINCT restaurant_id) as unique_restaurants,
  AVG(CASE WHEN is_active THEN 1 ELSE 0 END) * 100 as percent_active
FROM menuca_v3.admin_user_restaurants;

-- Expected:
-- - total_assignments: 533+ (94 original + 439 migrated)
-- - unique_admins: should include all migrated users
-- - percent_active: should be reasonable

-- =========================================================================
-- 6. VERIFY NO DATA LOSS
-- =========================================================================

-- All restaurant_admin_users should have corresponding admin_users
SELECT 
  '6. Data Loss Check' as check_name,
  COUNT(*) as restaurant_admins_without_migration
FROM menuca_v3.restaurant_admin_users rau
WHERE rau.migrated_to_admin_user_id IS NULL;

-- Expected: 0 (all should be migrated)

-- =========================================================================
-- 7. VERIFY RESTAURANT ACCESS PRESERVED
-- =========================================================================

-- Every restaurant_admin_user should have access via admin_user_restaurants
SELECT 
  '7. Restaurant Access Check' as check_name,
  COUNT(*) as restaurant_admins_without_access
FROM menuca_v3.restaurant_admin_users rau
WHERE NOT EXISTS (
  SELECT 1 
  FROM menuca_v3.admin_user_restaurants aur
  WHERE aur.admin_user_id = rau.migrated_to_admin_user_id
    AND aur.restaurant_id = rau.restaurant_id
);

-- Expected: 0 (all restaurant access should be preserved)

-- =========================================================================
-- 8. PERMISSIONS COLUMNS DROPPED
-- =========================================================================

-- This will ERROR if columns still exist (which is what we want)
-- Comment out if you want script to complete without errors

-- SELECT permissions FROM menuca_v3.admin_users LIMIT 1;
-- Should ERROR: column "permissions" does not exist

-- SELECT permissions FROM menuca_v3.admin_user_restaurants LIMIT 1;
-- Should ERROR: column "permissions" does not exist

SELECT 
  '8. Permissions Columns' as check_name,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM information_schema.columns 
      WHERE table_schema = 'menuca_v3' 
        AND table_name = 'admin_users' 
        AND column_name = 'permissions'
    ) THEN 'STILL EXISTS'
    ELSE 'DROPPED ✅'
  END as admin_users_permissions,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM information_schema.columns 
      WHERE table_schema = 'menuca_v3' 
        AND table_name = 'admin_user_restaurants' 
        AND column_name = 'permissions'
    ) THEN 'STILL EXISTS'
    ELSE 'DROPPED ✅'
  END as admin_user_restaurants_permissions;

-- Expected: Both should be 'DROPPED ✅'

-- =========================================================================
-- 9. MIGRATION SUMMARY
-- =========================================================================

SELECT * FROM menuca_v3.admin_consolidation_summary
ORDER BY migration_date DESC
LIMIT 1;

-- Shows complete summary of migration

-- =========================================================================
-- 10. SAMPLE MIGRATED USERS
-- =========================================================================

-- Show some examples of migrated users
SELECT 
  au.id,
  au.email,
  au.first_name,
  au.last_name,
  au.legacy_v1_id,
  COUNT(aur.restaurant_id) as restaurant_count,
  ARRAY_AGG(aur.restaurant_id ORDER BY aur.restaurant_id) as restaurant_ids
FROM menuca_v3.admin_users au
LEFT JOIN menuca_v3.admin_user_restaurants aur ON au.id = aur.admin_user_id
WHERE au.legacy_v1_id IS NOT NULL -- These are migrated from restaurant_admin_users
GROUP BY au.id, au.email, au.first_name, au.last_name, au.legacy_v1_id
ORDER BY restaurant_count DESC
LIMIT 10;

-- =========================================================================
-- SUCCESS CRITERIA
-- =========================================================================

-- ALL of the following should be TRUE for successful migration:
-- ✅ Check 2: 100% migration rate
-- ✅ Check 4: 0 duplicate emails in admin_users
-- ✅ Check 5: 533+ total assignments
-- ✅ Check 6: 0 restaurant admins without migration
-- ✅ Check 7: 0 restaurant admins without access
-- ✅ Check 8: Both permissions columns dropped
-- ✅ Check 9: Migration summary exists

-- =========================================================================
-- IF ANY CHECKS FAIL
-- =========================================================================
-- 1. DO NOT COMMIT if testing
-- 2. Run 04_ROLLBACK.sql if already committed
-- 3. Review migration script for issues
-- 4. Contact Brian or Santiago

-- =========================================================================

