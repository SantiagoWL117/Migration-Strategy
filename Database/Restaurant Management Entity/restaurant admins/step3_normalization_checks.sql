-- ============================================================================
-- Step 3: Post-Load Normalization and Data Quality Checks
-- ============================================================================
-- Purpose: Verify data quality and identify any issues after migration
-- Author: Migration Plan
-- Date: 2025-10-02
-- ============================================================================

\echo '🔍 Running post-migration normalization checks...'
\echo ''

-- 1. Check for email normalization issues
\echo '1️⃣  Checking email normalization...'
SELECT 
    COUNT(*) AS non_normalized_emails,
    CASE 
        WHEN COUNT(*) = 0 THEN '✅ All emails are lowercase and trimmed'
        ELSE '⚠️  Found ' || COUNT(*) || ' emails that need normalization'
    END AS status
FROM menuca_v3.restaurant_admin_users
WHERE email != lower(trim(email));

-- Show examples if any exist
SELECT 
    id, email, restaurant_id, 
    'Should be: ' || lower(trim(email)) AS suggested_fix
FROM menuca_v3.restaurant_admin_users
WHERE email != lower(trim(email))
LIMIT 10;

\echo ''

-- 2. Check for orphaned admin users (restaurant FK broken)
\echo '2️⃣  Checking for orphaned admin users...'
SELECT 
    COUNT(*) AS orphaned_admin_users,
    CASE 
        WHEN COUNT(*) = 0 THEN '✅ All admin users have valid restaurant links'
        ELSE '❌ Found ' || COUNT(*) || ' admin users with invalid restaurant FK'
    END AS status
FROM menuca_v3.restaurant_admin_users au
LEFT JOIN menuca_v3.restaurants r ON r.id = au.restaurant_id
WHERE r.id IS NULL;

-- Show orphaned records if any exist
SELECT 
    au.id, au.email, au.restaurant_id, au.first_name, au.last_name
FROM menuca_v3.restaurant_admin_users au
LEFT JOIN menuca_v3.restaurants r ON r.id = au.restaurant_id
WHERE r.id IS NULL
LIMIT 10;

\echo ''

-- 3. Check for admin users without email
\echo '3️⃣  Checking for admin users without email...'
SELECT 
    COUNT(*) AS users_without_email,
    CASE 
        WHEN COUNT(*) = 0 THEN '✅ All admin users have email addresses'
        ELSE '⚠️  Found ' || COUNT(*) || ' admin users without email (constraint violation!)'
    END AS status
FROM menuca_v3.restaurant_admin_users
WHERE email IS NULL OR email = '';

\echo ''

-- 4. Check for duplicate (restaurant_id, email) pairs (should be impossible due to unique constraint)
\echo '4️⃣  Checking for duplicate (restaurant_id, email) pairs...'
SELECT 
    COUNT(*) AS duplicate_pairs,
    CASE 
        WHEN COUNT(*) = 0 THEN '✅ No duplicates found (unique constraint working)'
        ELSE '❌ CRITICAL: Found ' || COUNT(*) || ' duplicate pairs (constraint violated!)'
    END AS status
FROM (
    SELECT restaurant_id, email, COUNT(*) as cnt
    FROM menuca_v3.restaurant_admin_users
    GROUP BY restaurant_id, email
    HAVING COUNT(*) > 1
) AS dupes;

-- Show duplicates if any exist (should never happen)
SELECT restaurant_id, email, COUNT(*) as cnt
FROM menuca_v3.restaurant_admin_users
GROUP BY restaurant_id, email
HAVING COUNT(*) > 1
LIMIT 10;

\echo ''

-- 5. Check password hash format (should be bcrypt $2y$10$)
\echo '5️⃣  Checking password hash format...'
SELECT 
    COUNT(*) AS total_users,
    COUNT(password_hash) AS users_with_password,
    COUNT(CASE WHEN password_hash LIKE '$2y$10$%' THEN 1 END) AS bcrypt_format,
    COUNT(CASE WHEN password_hash NOT LIKE '$2y$10$%' AND password_hash IS NOT NULL THEN 1 END) AS non_standard_format,
    CASE 
        WHEN COUNT(CASE WHEN password_hash NOT LIKE '$2y$10$%' AND password_hash IS NOT NULL THEN 1 END) = 0 
        THEN '✅ All passwords use standard bcrypt format'
        ELSE '⚠️  Found non-standard password formats'
    END AS status
FROM menuca_v3.restaurant_admin_users;

-- Show non-standard passwords if any
SELECT id, email, 
       left(password_hash, 10) AS password_prefix,
       length(password_hash) AS hash_length
FROM menuca_v3.restaurant_admin_users
WHERE password_hash NOT LIKE '$2y$10$%' 
  AND password_hash IS NOT NULL
LIMIT 10;

\echo ''

-- 6. Check for inactive users
\echo '6️⃣  Checking active/inactive user distribution...'
SELECT 
    COUNT(CASE WHEN is_active = true THEN 1 END) AS active_users,
    COUNT(CASE WHEN is_active = false THEN 1 END) AS inactive_users,
    ROUND(100.0 * COUNT(CASE WHEN is_active = true THEN 1 END) / COUNT(*), 2) AS active_percentage
FROM menuca_v3.restaurant_admin_users;

\echo ''

-- 7. Check login activity distribution
\echo '7️⃣  Checking login activity distribution...'
SELECT 
    COUNT(CASE WHEN login_count = 0 THEN 1 END) AS never_logged_in,
    COUNT(CASE WHEN login_count BETWEEN 1 AND 10 THEN 1 END) AS low_activity,
    COUNT(CASE WHEN login_count BETWEEN 11 AND 100 THEN 1 END) AS medium_activity,
    COUNT(CASE WHEN login_count > 100 THEN 1 END) AS high_activity,
    MAX(login_count) AS max_login_count,
    ROUND(AVG(login_count), 2) AS avg_login_count
FROM menuca_v3.restaurant_admin_users;

\echo ''

-- 8. Show users who have never logged in
\echo '8️⃣  Users who have never logged in:'
SELECT 
    au.id, au.email, r.name AS restaurant_name,
    au.created_at, au.is_active
FROM menuca_v3.restaurant_admin_users au
JOIN menuca_v3.restaurants r ON r.id = au.restaurant_id
WHERE au.login_count = 0
ORDER BY au.created_at DESC
LIMIT 10;

\echo ''
\echo '============================================================================'
\echo '✅ Normalization checks complete'
\echo '📝 Review any warnings or errors above'
\echo '📝 Next step: Run step4_verification.sql'
\echo '============================================================================'




