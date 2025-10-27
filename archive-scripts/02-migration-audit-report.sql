-- ============================================================================
-- Migration Audit Report: restaurant_admin_users -> admin_users
-- ============================================================================
-- Purpose: Comprehensive audit of the migration from legacy to new admin system
-- Validates data integrity and identifies any migration issues
-- ============================================================================

-- Report 1: Migration Completeness Overview
-- ============================================================================
SELECT
    'Migration Overview' as report_section,
    COUNT(*) as total_legacy_admins,
    COUNT(migrated_to_admin_user_id) as successfully_migrated,
    COUNT(*) - COUNT(migrated_to_admin_user_id) as not_migrated,
    ROUND(100.0 * COUNT(migrated_to_admin_user_id) / COUNT(*), 2) as migration_percentage
FROM menuca_v3.restaurant_admin_users;

-- Report 2: Email Consistency Check
-- ============================================================================
-- Verify that emails match between old and new systems
SELECT
    'Email Consistency Check' as report_section,
    COUNT(*) as total_checked,
    COUNT(*) FILTER (WHERE rau.email = au.email) as emails_match,
    COUNT(*) FILTER (WHERE rau.email != au.email) as emails_mismatch
FROM menuca_v3.restaurant_admin_users rau
JOIN menuca_v3.admin_users au ON rau.migrated_to_admin_user_id = au.id;

-- Report 3: Email Mismatches (if any)
-- ============================================================================
SELECT
    'Email Mismatches' as report_section,
    rau.id as old_id,
    rau.email as old_email,
    au.id as new_id,
    au.email as new_email,
    rau.restaurant_id
FROM menuca_v3.restaurant_admin_users rau
JOIN menuca_v3.admin_users au ON rau.migrated_to_admin_user_id = au.id
WHERE rau.email != au.email;

-- Report 4: Restaurant Access Verification
-- ============================================================================
-- Check that migrated admins have access to their original restaurants
SELECT
    'Restaurant Access Verification' as report_section,
    COUNT(*) as total_legacy_admins,
    COUNT(aur.id) as have_restaurant_access,
    COUNT(*) - COUNT(aur.id) as missing_restaurant_access
FROM menuca_v3.restaurant_admin_users rau
LEFT JOIN menuca_v3.admin_user_restaurants aur ON
    rau.migrated_to_admin_user_id = aur.admin_user_id AND
    rau.restaurant_id = aur.restaurant_id;

-- Report 5: Missing Restaurant Access Details
-- ============================================================================
SELECT
    'Missing Restaurant Access' as report_section,
    rau.id as legacy_id,
    rau.email,
    rau.restaurant_id,
    rau.migrated_to_admin_user_id as new_admin_id,
    r.name as restaurant_name
FROM menuca_v3.restaurant_admin_users rau
LEFT JOIN menuca_v3.admin_user_restaurants aur ON
    rau.migrated_to_admin_user_id = aur.admin_user_id AND
    rau.restaurant_id = aur.restaurant_id
LEFT JOIN menuca_v3.restaurants r ON rau.restaurant_id = r.id
WHERE aur.id IS NULL;

-- Report 6: Multi-Restaurant Admins
-- ============================================================================
-- Identify admins who now have access to multiple restaurants (benefit of new system)
SELECT
    'Multi-Restaurant Admins' as report_section,
    au.id,
    au.email,
    COUNT(aur.restaurant_id) as restaurant_count,
    array_agg(aur.restaurant_id ORDER BY aur.restaurant_id) as restaurant_ids
FROM menuca_v3.admin_users au
JOIN menuca_v3.admin_user_restaurants aur ON au.id = aur.admin_user_id
WHERE au.id IN (SELECT migrated_to_admin_user_id FROM menuca_v3.restaurant_admin_users)
GROUP BY au.id, au.email
HAVING COUNT(aur.restaurant_id) > 1
ORDER BY restaurant_count DESC;

-- Report 7: Active Status Comparison
-- ============================================================================
SELECT
    'Active Status Comparison' as report_section,
    COUNT(*) as total_migrated,
    COUNT(*) FILTER (WHERE rau.is_active = true AND au.status = 'active') as both_active,
    COUNT(*) FILTER (WHERE rau.is_active = true AND au.status != 'active') as old_active_new_inactive,
    COUNT(*) FILTER (WHERE rau.is_active = false AND au.status = 'active') as old_inactive_new_active
FROM menuca_v3.restaurant_admin_users rau
JOIN menuca_v3.admin_users au ON rau.migrated_to_admin_user_id = au.id;

-- Report 8: Authentication Status
-- ============================================================================
-- Check if migrated users have Supabase auth accounts
SELECT
    'Authentication Status' as report_section,
    COUNT(*) as total_migrated_admins,
    COUNT(au.auth_user_id) as have_auth_account,
    COUNT(*) - COUNT(au.auth_user_id) as no_auth_account,
    ROUND(100.0 * COUNT(au.auth_user_id) / COUNT(*), 2) as auth_percentage
FROM menuca_v3.restaurant_admin_users rau
JOIN menuca_v3.admin_users au ON rau.migrated_to_admin_user_id = au.id;

-- Report 9: Admins Without Auth Accounts
-- ============================================================================
SELECT
    'Admins Without Auth' as report_section,
    au.id,
    au.email,
    au.status,
    au.created_at,
    rau.last_login_at as legacy_last_login
FROM menuca_v3.restaurant_admin_users rau
JOIN menuca_v3.admin_users au ON rau.migrated_to_admin_user_id = au.id
WHERE au.auth_user_id IS NULL
ORDER BY rau.last_login_at DESC NULLS LAST;

-- Report 10: Migration Date Analysis
-- ============================================================================
SELECT
    'Migration Timeline' as report_section,
    MIN(au.created_at) as first_migration,
    MAX(au.created_at) as last_migration,
    COUNT(DISTINCT DATE(au.created_at)) as migration_days,
    MAX(rau.updated_at) as last_update_to_legacy_table
FROM menuca_v3.restaurant_admin_users rau
JOIN menuca_v3.admin_users au ON rau.migrated_to_admin_user_id = au.id;

-- ============================================================================
-- Audit Report Complete
-- ============================================================================
