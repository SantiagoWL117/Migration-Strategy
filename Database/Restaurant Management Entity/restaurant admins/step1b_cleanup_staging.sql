-- ============================================================================
-- Step 1b: Optional Staging Data Cleanup
-- ============================================================================
-- Purpose: Normalize and clean staging data before main migration
-- Author: Migration Plan
-- Date: 2025-10-02
-- ============================================================================

\echo '🧹 Cleaning and normalizing staging data...'
\echo ''

BEGIN;

-- Normalize email addresses (lowercase, trim)
UPDATE staging.v1_restaurant_admin_users
SET email = lower(NULLIF(trim(email), ''));

-- Normalize names (trim, handle empty strings as NULL)
UPDATE staging.v1_restaurant_admin_users
SET fname = NULLIF(trim(fname), ''),
    lname = NULLIF(trim(lname), '');

-- Normalize user_type (default to 'r' if empty/NULL)
UPDATE staging.v1_restaurant_admin_users
SET user_type = COALESCE(NULLIF(trim(user_type), ''), 'r');

-- Report on data quality
\echo '📊 Data Quality Report:'
\echo ''

SELECT 
    COUNT(*) AS total_records,
    COUNT(CASE WHEN legacy_v1_restaurant_id > 0 THEN 1 END) AS valid_restaurant_fk,
    COUNT(CASE WHEN legacy_v1_restaurant_id = 0 THEN 1 END) AS global_admins_restaurant_0,
    COUNT(CASE WHEN user_type = 'r' THEN 1 END) AS restaurant_type,
    COUNT(CASE WHEN user_type = 'g' THEN 1 END) AS global_type,
    COUNT(CASE WHEN email IS NOT NULL THEN 1 END) AS has_email,
    COUNT(CASE WHEN email IS NULL THEN 1 END) AS missing_email,
    COUNT(CASE WHEN active_user = '1' THEN 1 END) AS active_users,
    COUNT(CASE WHEN active_user = '0' THEN 1 END) AS inactive_users
FROM staging.v1_restaurant_admin_users;

\echo ''
\echo '🔍 Records that will be EXCLUDED from migration:'
SELECT 
    COUNT(*) AS excluded_count,
    'Reason: user_type=''g'' (global) OR restaurant=0' AS reason
FROM staging.v1_restaurant_admin_users
WHERE legacy_v1_restaurant_id = 0 OR user_type = 'g';

\echo ''
\echo '✅ Records that will be INCLUDED in migration:'
SELECT 
    COUNT(*) AS included_count,
    'Criteria: user_type=''r'' AND restaurant > 0' AS criteria
FROM staging.v1_restaurant_admin_users
WHERE legacy_v1_restaurant_id > 0 AND user_type = 'r';

\echo ''
\echo '⚠️  Checking for duplicate (restaurant, email) pairs...'
SELECT 
    legacy_v1_restaurant_id,
    email,
    COUNT(*) AS duplicate_count,
    string_agg(legacy_admin_id::text, ', ' ORDER BY lastlogin DESC NULLS LAST) AS admin_ids
FROM staging.v1_restaurant_admin_users
WHERE legacy_v1_restaurant_id > 0 AND user_type = 'r'
GROUP BY legacy_v1_restaurant_id, email
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

COMMIT;

\echo ''
\echo '✅ Staging data cleaned and normalized'
\echo '📝 Review the reports above before proceeding to Step 2'




