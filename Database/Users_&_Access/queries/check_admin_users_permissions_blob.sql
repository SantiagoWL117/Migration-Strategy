-- ================================================================
-- Check admin_users Permissions BLOB Column
-- Purpose: Verify if permissions BLOB contains data or is empty
-- Date: January 7, 2025
-- ================================================================

-- ================================================================
-- QUERY 1: Check if permissions BLOB is populated
-- ================================================================
SELECT 
    COUNT(*) AS total_rows,
    COUNT(CASE WHEN permissions IS NOT NULL THEN 1 END) AS has_permissions_count,
    COUNT(CASE WHEN permissions IS NULL THEN 1 END) AS null_permissions_count,
    COUNT(CASE WHEN permissions IS NOT NULL THEN 1 END) * 100.0 / COUNT(*) AS percentage_with_permissions
FROM menuca_v1.admin_users;

-- Expected: Will show how many of the 23 admin_users have permissions data

-- ================================================================
-- QUERY 2: Sample permissions BLOB data (first 10 rows)
-- ================================================================
SELECT 
    id,
    username,
    email,
    activeUser,
    CASE 
        WHEN permissions IS NULL THEN 'NULL'
        WHEN LENGTH(permissions) = 0 THEN 'EMPTY'
        ELSE CONCAT('HAS DATA (', LENGTH(permissions), ' bytes)')
    END AS permissions_status,
    LEFT(permissions, 100) AS permissions_sample  -- Show first 100 chars if it's text
FROM menuca_v1.admin_users
ORDER BY id
LIMIT 10;

-- ================================================================
-- QUERY 3: Check if V2 has equivalent permissions data
-- ================================================================
-- V2 uses group-based permissions instead of BLOB
-- Note: V2 admin_users doesn't have allow_api_access (V1 only field)
SELECT 
    id,
    email,
    `group` AS permission_group,
    override_restaurants,
    allow_login_to_sites,
    receive_statements,
    active,
    last_activity
FROM menuca_v2.admin_users
ORDER BY id
LIMIT 10;

-- ================================================================
-- QUERY 4: Compare V1 vs V2 Admin Email Overlap
-- ================================================================
-- Check if V1 admin_users were migrated to V2
SELECT 
    'v1_only' AS category,
    COUNT(*) AS count
FROM menuca_v1.admin_users v1
WHERE NOT EXISTS (
    SELECT 1 FROM menuca_v2.admin_users v2 
    WHERE LOWER(TRIM(v2.email)) = LOWER(TRIM(v1.email))
)

UNION ALL

SELECT 
    'v2_only' AS category,
    COUNT(*) AS count
FROM menuca_v2.admin_users v2
WHERE NOT EXISTS (
    SELECT 1 FROM menuca_v1.admin_users v1 
    WHERE LOWER(TRIM(v1.email)) = LOWER(TRIM(v2.email))
)

UNION ALL

SELECT 
    'both_v1_and_v2' AS category,
    COUNT(*) AS count
FROM menuca_v1.admin_users v1
WHERE EXISTS (
    SELECT 1 FROM menuca_v2.admin_users v2 
    WHERE LOWER(TRIM(v2.email)) = LOWER(TRIM(v1.email))
);

-- ================================================================
-- INTERPRETATION:
-- ================================================================

-- SCENARIO A: permissions BLOB is NULL/empty for all rows
-- → No permissions data in V1
-- → V2 group-based system is complete
-- → Action: Skip V1 permissions BLOB, use V2 only ✅

-- SCENARIO B: permissions BLOB has data
-- → Check if V1 admins exist in V2 (migrated)
-- → If YES and in V2: V1 permissions already migrated to V2 groups
-- → If NO (V1 only): Would need BLOB deserialization
-- → But if data is from 2019 and admins not in V2: likely inactive/obsolete

-- SCENARIO C: Mix of populated and empty
-- → Check which admins have permissions
-- → Cross-reference with V2 to see if they were migrated
-- → Likely V2 has superseded V1 permissions

-- ================================================================
-- EXPECTED OUTCOME:
-- ================================================================
-- Given that V2 has 52 active admin_users with group-based permissions,
-- and V1 has 23 admin_users, if there's significant overlap, then:
-- → V1 permissions were likely migrated to V2 group system
-- → V1 BLOB can be safely skipped
-- → Only migrate V2 admin_users (52 rows) which have current permissions
-- ================================================================


