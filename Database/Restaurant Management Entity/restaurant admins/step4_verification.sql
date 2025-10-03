-- ============================================================================
-- Step 4: Migration Verification and Validation
-- ============================================================================
-- Purpose: Comprehensive verification of restaurant_admin_users migration
-- Author: Migration Plan
-- Date: 2025-10-02
-- ============================================================================

\echo '🔍 Running comprehensive migration verification...'
\echo ''

-- A) Source vs Target Record Counts
\echo '📊 A) Source vs Target Record Counts'
\echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'

SELECT 
    'V1 Staging Total' AS source,
    COUNT(*) AS record_count
FROM staging.v1_restaurant_admin_users

UNION ALL

SELECT 
    'V1 Eligible (r type, restaurant>0)' AS source,
    COUNT(*) AS record_count
FROM staging.v1_restaurant_admin_users
WHERE legacy_v1_restaurant_id > 0 
  AND COALESCE(user_type, 'r') = 'r'

UNION ALL

SELECT 
    'V1 Excluded (g type or restaurant=0)' AS source,
    COUNT(*) AS record_count
FROM staging.v1_restaurant_admin_users
WHERE legacy_v1_restaurant_id = 0 
   OR user_type = 'g'

UNION ALL

SELECT 
    'V3 Migrated' AS source,
    COUNT(*) AS record_count
FROM menuca_v3.restaurant_admin_users;

\echo ''

-- B) Check for Broken Foreign Keys in Source
\echo '📊 B) Broken Foreign Keys Analysis'
\echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'

WITH broken_fks AS (
    SELECT 
        s.legacy_admin_id,
        s.legacy_v1_restaurant_id,
        s.email
    FROM staging.v1_restaurant_admin_users s
    LEFT JOIN menuca_v3.restaurants r ON r.legacy_v1_id = s.legacy_v1_restaurant_id
    WHERE s.legacy_v1_restaurant_id > 0
      AND s.user_type = 'r'
      AND r.id IS NULL
)
SELECT 
    COUNT(*) AS broken_fk_count,
    CASE 
        WHEN COUNT(*) = 0 THEN '✅ No broken FKs - all V1 restaurant IDs resolved'
        ELSE '❌ Found ' || COUNT(*) || ' admin users with unresolved restaurant FKs'
    END AS status
FROM broken_fks;

-- Show details of broken FKs if any exist
SELECT 
    s.legacy_admin_id,
    s.legacy_v1_restaurant_id,
    s.email,
    s.fname,
    s.lname
FROM staging.v1_restaurant_admin_users s
LEFT JOIN menuca_v3.restaurants r ON r.legacy_v1_id = s.legacy_v1_restaurant_id
WHERE s.legacy_v1_restaurant_id > 0
  AND s.user_type = 'r'
  AND r.id IS NULL
LIMIT 10;

\echo ''

-- C) Duplicate Detection in Source (Pre-Deduplication Analysis)
\echo '📊 C) Source Duplicate Analysis'
\echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'

WITH src_dupes AS (
    SELECT 
        r.id AS restaurant_id,
        lower(trim(s.email)) AS email,
        COUNT(*) as occurrence_count
    FROM staging.v1_restaurant_admin_users s
    JOIN menuca_v3.restaurants r ON r.legacy_v1_id = s.legacy_v1_restaurant_id
    WHERE s.legacy_v1_restaurant_id > 0 
      AND s.user_type = 'r'
    GROUP BY r.id, lower(trim(s.email))
    HAVING COUNT(*) > 1
)
SELECT 
    COUNT(*) AS duplicate_pairs_in_source,
    COALESCE(SUM(occurrence_count), 0) AS total_duplicate_records,
    CASE 
        WHEN COUNT(*) = 0 THEN '✅ No duplicates in source data'
        ELSE '⚠️  Found ' || COUNT(*) || ' duplicate (restaurant, email) pairs - deduplication applied'
    END AS status
FROM src_dupes;

-- Show duplicate details if any exist
SELECT 
    r.id AS restaurant_id,
    r.name AS restaurant_name,
    lower(trim(s.email)) AS email,
    COUNT(*) as duplicate_count,
    string_agg(s.legacy_admin_id::text || ' (login: ' || COALESCE(s.lastlogin::text, 'never') || ')', ', ' 
               ORDER BY s.lastlogin DESC NULLS LAST) AS admin_ids_and_logins
FROM staging.v1_restaurant_admin_users s
JOIN menuca_v3.restaurants r ON r.legacy_v1_id = s.legacy_v1_restaurant_id
WHERE s.legacy_v1_restaurant_id > 0 
  AND s.user_type = 'r'
GROUP BY r.id, r.name, lower(trim(s.email))
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC
LIMIT 10;

\echo ''

-- D) Verify Target Uniqueness (Should Always Be Zero)
\echo '📊 D) Target Uniqueness Verification'
\echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'

WITH target_dupes AS (
    SELECT restaurant_id, email, COUNT(*) as cnt
    FROM menuca_v3.restaurant_admin_users
    GROUP BY restaurant_id, email
    HAVING COUNT(*) > 1
)
SELECT 
    COUNT(*) AS duplicate_pairs_in_target,
    CASE 
        WHEN COUNT(*) = 0 THEN '✅ Unique constraint enforced - no duplicates in target'
        ELSE '❌ CRITICAL: Found ' || COUNT(*) || ' duplicate pairs in target (constraint failed!)'
    END AS status
FROM target_dupes;

-- Show any duplicates (should never happen)
SELECT restaurant_id, email, COUNT(*) as cnt
FROM menuca_v3.restaurant_admin_users
GROUP BY restaurant_id, email
HAVING COUNT(*) > 1
LIMIT 10;

\echo ''

-- E) Distribution Check
\echo '📊 E) Data Distribution Analysis'
\echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'

SELECT 
    COUNT(*) AS total_admin_users,
    COUNT(CASE WHEN user_type = 'r' THEN 1 END) AS restaurant_type,
    COUNT(CASE WHEN user_type = 'g' THEN 1 END) AS global_type,
    COUNT(CASE WHEN is_active = true THEN 1 END) AS active_users,
    COUNT(CASE WHEN is_active = false THEN 1 END) AS inactive_users,
    COUNT(CASE WHEN send_statement = true THEN 1 END) AS receives_statements,
    COUNT(DISTINCT restaurant_id) AS unique_restaurants_with_admins
FROM menuca_v3.restaurant_admin_users;

\echo ''

-- F) Sample Join to Restaurant Names
\echo '📊 F) Sample Admin Users with Restaurant Details'
\echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'

SELECT 
    au.id,
    au.email,
    au.first_name,
    au.last_name,
    r.name AS restaurant_name,
    r.status AS restaurant_status,
    au.user_type,
    au.is_active,
    au.login_count,
    au.last_login,
    au.send_statement
FROM menuca_v3.restaurant_admin_users au
JOIN menuca_v3.restaurants r ON r.id = au.restaurant_id
ORDER BY r.name, au.email
LIMIT 20;

\echo ''

-- G) Login Activity Summary
\echo '📊 G) Login Activity Summary'
\echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'

SELECT 
    CASE 
        WHEN login_count = 0 THEN '0 (Never logged in)'
        WHEN login_count BETWEEN 1 AND 5 THEN '1-5 (Low activity)'
        WHEN login_count BETWEEN 6 AND 50 THEN '6-50 (Medium activity)'
        WHEN login_count BETWEEN 51 AND 500 THEN '51-500 (High activity)'
        ELSE '500+ (Very high activity)'
    END AS activity_range,
    COUNT(*) AS user_count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM menuca_v3.restaurant_admin_users), 2) AS percentage
FROM menuca_v3.restaurant_admin_users
GROUP BY 
    CASE 
        WHEN login_count = 0 THEN '0 (Never logged in)'
        WHEN login_count BETWEEN 1 AND 5 THEN '1-5 (Low activity)'
        WHEN login_count BETWEEN 6 AND 50 THEN '6-50 (Medium activity)'
        WHEN login_count BETWEEN 51 AND 500 THEN '51-500 (High activity)'
        ELSE '500+ (Very high activity)'
    END
ORDER BY MIN(login_count);

\echo ''

-- H) Top Active Admin Users
\echo '📊 H) Top 10 Most Active Admin Users'
\echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'

SELECT 
    au.email,
    r.name AS restaurant_name,
    au.login_count,
    au.last_login,
    au.is_active,
    CASE 
        WHEN au.last_login > (now() - interval '30 days') THEN '🟢 Recent'
        WHEN au.last_login > (now() - interval '90 days') THEN '🟡 Moderate'
        WHEN au.last_login > (now() - interval '1 year') THEN '🟠 Old'
        ELSE '🔴 Very old'
    END AS recency
FROM menuca_v3.restaurant_admin_users au
JOIN menuca_v3.restaurants r ON r.id = au.restaurant_id
ORDER BY au.login_count DESC
LIMIT 10;

\echo ''

-- I) Restaurants Without Admin Users
\echo '📊 I) Restaurants Without Admin Users (Potential Issue)'
\echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'

WITH restaurants_with_admins AS (
    SELECT DISTINCT restaurant_id
    FROM menuca_v3.restaurant_admin_users
)
SELECT 
    r.id,
    r.name,
    r.status,
    r.legacy_v1_id,
    r.legacy_v2_id,
    CASE 
        WHEN r.status IN ('suspended', 'closed') THEN '⚠️  Inactive restaurant'
        ELSE '❌ Active restaurant without admin'
    END AS issue
FROM menuca_v3.restaurants r
LEFT JOIN restaurants_with_admins rwa ON rwa.restaurant_id = r.id
WHERE rwa.restaurant_id IS NULL
  AND r.legacy_v1_id IS NOT NULL  -- Only check restaurants that were in V1
ORDER BY r.status, r.name
LIMIT 20;

\echo ''
\echo '============================================================================'
\echo '✅ Verification complete!'
\echo ''
\echo '📝 Review Summary:'
\echo '   - Check that eligible source count matches target count'
\echo '   - Verify no broken FKs (should be 0)'
\echo '   - Duplicates in source were automatically deduplicated'
\echo '   - Target should have zero duplicates (unique constraint)'
\echo '   - Review restaurants without admin users'
\echo ''
\echo '📝 Next steps:'
\echo '   - If all checks pass ✅, migration is complete!'
\echo '   - [OPTIONAL] Run step5_multi_restaurant_access.sql for junction table'
\echo '   - Document any excluded records (global admins, broken FKs)'
\echo '============================================================================'




