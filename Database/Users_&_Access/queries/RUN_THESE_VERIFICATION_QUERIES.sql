-- ================================================================
-- V1 ADMIN PERMISSIONS BLOB - VERIFICATION QUERIES
-- ================================================================
-- Purpose: Determine if V1 admin users and permissions were lost
-- Date: October 9, 2025
-- Database: Run these on MySQL (menuca_v1 + menuca_v2)
-- ================================================================

-- ================================================================
-- QUERY 1: Check V1 Admin Users Row Count and Permissions BLOB
-- ================================================================
-- This tells us how many V1 admins exist and if they have permissions

SELECT 
    COUNT(*) AS total_v1_admins,
    COUNT(CASE WHEN permissions IS NOT NULL AND LENGTH(permissions) > 0 THEN 1 END) AS has_permissions_blob,
    COUNT(CASE WHEN permissions IS NULL OR LENGTH(permissions) = 0 THEN 1 END) AS null_or_empty_permissions,
    ROUND(COUNT(CASE WHEN permissions IS NOT NULL AND LENGTH(permissions) > 0 THEN 1 END) * 100.0 / COUNT(*), 2) AS pct_with_permissions
FROM menuca_v1.admin_users;

-- Expected: 23 total rows
-- Question: How many have permissions BLOB data?

-- ================================================================
-- QUERY 2: Sample V1 Admin Users with Permissions BLOB Content
-- ================================================================
-- This shows us WHAT is in the permissions BLOB

SELECT 
    id,
    username,
    email,
    fname,
    lname,
    activeUser,
    lastlogin,
    CASE 
        WHEN permissions IS NULL THEN 'NULL'
        WHEN LENGTH(permissions) = 0 THEN 'EMPTY'
        ELSE CONCAT('HAS DATA (', LENGTH(permissions), ' bytes)')
    END AS permissions_status,
    -- Show first 500 characters of BLOB (if it's serialized PHP)
    CAST(SUBSTRING(permissions, 1, 500) AS CHAR(500)) AS permissions_sample
FROM menuca_v1.admin_users
ORDER BY id;

-- This will show us:
-- 1. Which admins have permissions data
-- 2. What format the permissions are in (likely serialized PHP array)
-- 3. Sample of the actual permission flags

-- ================================================================
-- QUERY 3: Check V2 Admin Users and Their Group-Based Permissions
-- ================================================================
-- V2 uses group-based permissions instead of BLOB

SELECT 
    id,
    email,
    fname,
    lname,
    `group` AS permission_group,
    override_restaurants,
    allow_login_to_sites,
    receive_statements,
    active,
    last_activity
FROM menuca_v2.admin_users
ORDER BY id;

-- This shows us:
-- 1. How many V2 admins exist (expected: 51-52)
-- 2. What group-based permissions they have
-- 3. Their email addresses for matching with V1

-- ================================================================
-- QUERY 4: V1 vs V2 Admin Email Overlap Analysis
-- ================================================================
-- This is THE CRITICAL QUERY - tells us if V1 admins were migrated to V2

SELECT 
    'v1_only_admins' AS category,
    COUNT(*) AS count,
    GROUP_CONCAT(v1.email ORDER BY v1.email SEPARATOR ', ') AS emails
FROM menuca_v1.admin_users v1
WHERE NOT EXISTS (
    SELECT 1 FROM menuca_v2.admin_users v2 
    WHERE LOWER(TRIM(v2.email)) = LOWER(TRIM(v1.email))
)

UNION ALL

SELECT 
    'v2_only_admins' AS category,
    COUNT(*) AS count,
    GROUP_CONCAT(v2.email ORDER BY v2.email SEPARATOR ', ') AS emails
FROM menuca_v2.admin_users v2
WHERE NOT EXISTS (
    SELECT 1 FROM menuca_v1.admin_users v1 
    WHERE LOWER(TRIM(v1.email)) = LOWER(TRIM(v2.email))
)

UNION ALL

SELECT 
    'both_v1_and_v2' AS category,
    COUNT(*) AS count,
    GROUP_CONCAT(v1.email ORDER BY v1.email SEPARATOR ', ') AS emails
FROM menuca_v1.admin_users v1
WHERE EXISTS (
    SELECT 1 FROM menuca_v2.admin_users v2 
    WHERE LOWER(TRIM(v2.email)) = LOWER(TRIM(v1.email))
);

-- This tells us:
-- 1. How many V1 admins are NOT in V2 (potential data loss)
-- 2. How many V2 admins are NOT in V1 (new admins added)
-- 3. How many exist in BOTH (successfully migrated V1→V2)

-- ================================================================
-- QUERY 5: Detailed Comparison of V1-Only Admins
-- ================================================================
-- If Query 4 shows V1-only admins, run this to see their details

SELECT 
    v1.id AS v1_id,
    v1.email,
    v1.username,
    v1.fname,
    v1.lname,
    v1.activeUser AS is_active,
    v1.lastlogin AS last_login,
    v1.loginCount AS login_count,
    CASE 
        WHEN v1.permissions IS NOT NULL AND LENGTH(v1.permissions) > 0 THEN 'HAS PERMISSIONS'
        ELSE 'NO PERMISSIONS'
    END AS permissions_status,
    LENGTH(v1.permissions) AS permissions_blob_size
FROM menuca_v1.admin_users v1
WHERE NOT EXISTS (
    SELECT 1 FROM menuca_v2.admin_users v2 
    WHERE LOWER(TRIM(v2.email)) = LOWER(TRIM(v1.email))
)
ORDER BY v1.lastlogin DESC;

-- This shows:
-- 1. Which V1 admins were NOT migrated to V2
-- 2. When they last logged in (are they still active?)
-- 3. Whether they have permissions BLOB data
-- 4. Their login history

-- ================================================================
-- INTERPRETATION GUIDE
-- ================================================================

/*
SCENARIO A: V1-only admins count = 0 (ALL V1 admins in V2)
    → RESULT: ✅ NO DATA LOSS
    → V1 permissions were migrated to V2 group system
    → Action: None needed, migration was correct

SCENARIO B: V1-only admins count = 1-5 (Small number not in V2)
    → RESULT: ⚠️ POTENTIAL MINOR DATA LOSS
    → Check Query 5 - are these admins inactive?
    → Check lastlogin date - if >2 years old, likely obsolete
    → Decision: Review and decide if they need recovery

SCENARIO C: V1-only admins count = 10+ (Many not in V2)
    → RESULT: 🔴 SIGNIFICANT DATA LOSS
    → V1 admins were NOT migrated to V2
    → Check Query 5 - are any recently active?
    → Decision: Need to recover V1 admin data

SCENARIO D: Permissions BLOB has data + V1 admins in V2
    → RESULT: ✅ LIKELY OK
    → V1 BLOB permissions converted to V2 groups
    → Action: Compare V1 BLOB content with V2 group permissions
    → Verify they're equivalent

SCENARIO E: Permissions BLOB has data + V1 admins NOT in V2
    → RESULT: 🔴 CRITICAL DATA LOSS
    → Permission data exists but was never migrated
    → Action: MUST deserialize BLOB and migrate to V3
*/

-- ================================================================
-- NEXT STEPS AFTER RUNNING QUERIES
-- ================================================================

/*
1. Run all 5 queries on your MySQL database
2. Save the results
3. Analyze using the interpretation guide above
4. Report findings in V1_ADMIN_PERMISSIONS_BLOB_ANALYSIS.md
5. Decide on remediation action:
   - If no V1-only admins: Update docs to confirm no data loss
   - If V1-only admins exist: Decide if they need recovery
   - If permissions BLOB has data: Compare with V2 to ensure equivalence
*/

-- ================================================================
-- END OF VERIFICATION QUERIES
-- ================================================================

