-- ================================================================
-- V1 Admin Users Verification Query
-- Purpose: Verify if callcenter_users contains all V1 admin data
-- Date: January 7, 2025
-- ================================================================

-- ================================================================
-- QUERY 1: Compare Row Counts
-- ================================================================
SELECT 
    'admin_users' AS table_name,
    COUNT(*) AS row_count
FROM menuca_v1.admin_users

UNION ALL

SELECT 
    'callcenter_users' AS table_name,
    COUNT(*) AS row_count
FROM menuca_v1.callcenter_users;

-- Expected: 
-- admin_users: 0 or low count
-- callcenter_users: 37 (per CSV analysis)

-- ================================================================
-- QUERY 2: Check admin_users Structure and Sample Data
-- ================================================================
-- Get schema to understand what data should exist
SELECT 
    id,
    username,
    fname,
    lname,
    email,
    user_type,
    `rank`,  -- Escaped: 'rank' is a MySQL reserved keyword
    activeUser,
    vendor,
    lastlogin,
    created_at
FROM menuca_v1.admin_users
LIMIT 10;

-- Expected: Empty result if CSV analysis is correct

-- ================================================================
-- QUERY 3: Check callcenter_users Structure and Sample Data
-- ================================================================
-- Note: callcenter_users schema has: id, fname, lname, email, password, last_login, is_active, rank
SELECT 
    id,
    fname,
    lname,
    email,
    `rank`,  -- Escaped: 'rank' is a MySQL reserved keyword
    is_active,
    last_login
FROM menuca_v1.callcenter_users
ORDER BY id
LIMIT 10;

-- Expected: 37 rows with call center staff accounts

-- ================================================================
-- QUERY 4: Check for Admin References in Other Tables
-- ================================================================
-- Check if any other V1 tables reference admin_users that might indicate missing data

-- Check restaurant_admins table for admin references
SELECT 
    'restaurant_admins' AS reference_table,
    COUNT(DISTINCT admin_user_id) AS unique_admin_ids
FROM menuca_v1.restaurant_admins
WHERE admin_user_id > 0;

-- Check if admin_users has any AUTO_INCREMENT value set
SELECT 
    TABLE_NAME,
    AUTO_INCREMENT
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'menuca_v1' 
  AND TABLE_NAME = 'admin_users';

-- ================================================================
-- QUERY 5: Email Overlap Analysis
-- ================================================================
-- Check if any admin_users emails exist in callcenter_users
-- (This would indicate if callcenter is a subset or separate set)

SELECT 
    COALESCE(au.email, cc.email) AS email,
    CASE 
        WHEN au.email IS NOT NULL THEN 'admin_users'
        ELSE NULL 
    END AS in_admin_users,
    CASE 
        WHEN cc.email IS NOT NULL THEN 'callcenter_users'
        ELSE NULL 
    END AS in_callcenter,
    au.id AS admin_id,
    cc.id AS callcenter_id,
    au.fname AS admin_fname,
    cc.fname AS callcenter_fname
FROM menuca_v1.admin_users au
FULL OUTER JOIN menuca_v1.callcenter_users cc 
    ON LOWER(TRIM(au.email)) = LOWER(TRIM(cc.email))
WHERE au.email IS NOT NULL OR cc.email IS NOT NULL;

-- Expected: If admin_users is empty, only callcenter_users emails will show

-- ================================================================
-- QUERY 6: Check User Type Distribution in admin_users
-- ================================================================
-- If admin_users has data, check what types of admins exist
SELECT 
    user_type,
    COUNT(*) AS count,
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS percentage
FROM menuca_v1.admin_users
WHERE user_type IS NOT NULL
GROUP BY user_type
ORDER BY count DESC;

-- Expected: Empty if table is empty

-- ================================================================
-- QUERY 7: Comprehensive Comparison
-- ================================================================
-- Compare field availability between both tables
-- Note: callcenter_users doesn't have created_at column
SELECT 
    'admin_users' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT email) AS unique_emails,
    COUNT(CASE WHEN activeUser = '1' THEN 1 END) AS active_count,
    COUNT(CASE WHEN lastlogin IS NOT NULL AND lastlogin > '2020-01-01' THEN 1 END) AS recent_login_count,
    MIN(created_at) AS oldest_created,
    MAX(created_at) AS newest_created
FROM menuca_v1.admin_users

UNION ALL

SELECT 
    'callcenter_users' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT email) AS unique_emails,
    COUNT(CASE WHEN is_active = 'y' THEN 1 END) AS active_count,
    COUNT(CASE WHEN last_login IS NOT NULL AND last_login > '2020-01-01' THEN 1 END) AS recent_login_count,
    NULL AS oldest_created,  -- callcenter_users doesn't have created_at
    NULL AS newest_created   -- callcenter_users doesn't have created_at
FROM menuca_v1.callcenter_users;

-- ================================================================
-- INTERPRETATION GUIDE:
-- ================================================================

-- SCENARIO A: admin_users is TRULY EMPTY (count = 0)
-- → callcenter_users contains all V1 admin staff
-- → Recommendation: Merge callcenter_users into V3 admin_users with role='callcenter'
-- → Action: No re-export needed

-- SCENARIO B: admin_users has SOME DATA (count > 0)
-- → Need to check email overlap with callcenter_users
-- → If overlap exists: callcenter is subset of admins
-- → If no overlap: Two separate admin types
-- → Recommendation: Merge both into V3 admin_users

-- SCENARIO C: admin_users has data but CSV export failed
-- → CSV shows 0 rows but MySQL shows data
-- → Recommendation: Re-export admin_users.csv
-- → Action: Re-run CSV export script

-- ================================================================
-- DECISION MATRIX:
-- ================================================================
-- | admin_users count | callcenter count | Email Overlap | Action                    |
-- |-------------------|------------------|---------------|---------------------------|
-- | 0                 | 37              | N/A           | Use callcenter only ✅    |
-- | >0                | 37              | Yes           | Merge both                |
-- | >0                | 37              | No            | Merge both (separate)     |
-- | 0                 | 0               | N/A           | ERROR - Check V2          |
-- ================================================================


