-- ================================================================
-- Task 1.1: Verification Queries
-- ================================================================
-- Run these queries after migration to verify success
-- ================================================================

-- Check 1: Migration Progress
SELECT 
    COUNT(*) as total_users,
    COUNT(auth_user_id) as migrated_to_auth,
    COUNT(*) - COUNT(auth_user_id) as remaining,
    ROUND(COUNT(auth_user_id) * 100.0 / NULLIF(COUNT(*), 0), 2) as migration_progress_pct
FROM menuca_v3.users;

-- Check 2: Verify no orphaned auth links
SELECT 
    u.id, 
    u.email,
    u.auth_user_id,
    'Orphaned: auth_user_id points to non-existent auth.users record' as issue
FROM menuca_v3.users u
LEFT JOIN auth.users au ON au.id = u.auth_user_id
WHERE u.auth_user_id IS NOT NULL 
  AND au.id IS NULL;
-- Expected: 0 rows

-- Check 3: Verify email verification sync
SELECT 
    COUNT(*) as total,
    COUNT(CASE WHEN email_verified = true AND email_verified_at IS NOT NULL THEN 1 END) as verified_synced,
    COUNT(CASE WHEN email_verified = true AND email_verified_at IS NULL THEN 1 END) as verified_not_synced,
    COUNT(CASE WHEN email_verified = false AND email_verified_at IS NOT NULL THEN 1 END) as unverified_with_timestamp
FROM menuca_v3.users;

-- Check 4: Verify index creation
SELECT 
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'menuca_v3'
  AND tablename = 'users'
  AND indexname LIKE '%auth%'
ORDER BY indexname;

-- Check 5: Sample migrated users
SELECT 
    id,
    email,
    auth_user_id,
    auth_provider,
    email_verified_at,
    created_at
FROM menuca_v3.users
WHERE auth_user_id IS NOT NULL
LIMIT 10;

-- Check 6: Users without auth link (should decrease over time)
SELECT 
    id,
    email,
    created_at,
    EXTRACT(EPOCH FROM (NOW() - created_at)) / 86400 as days_since_signup
FROM menuca_v3.users
WHERE auth_user_id IS NULL
ORDER BY created_at DESC
LIMIT 20;

-- Check 7: Verify foreign key constraint
SELECT 
    conname as constraint_name,
    contype as constraint_type,
    pg_get_constraintdef(oid) as constraint_definition
FROM pg_constraint
WHERE conrelid = 'menuca_v3.users'::regclass
  AND conname LIKE '%auth%';


