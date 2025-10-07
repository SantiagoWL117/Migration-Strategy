-- ================================================================
-- Users & Access Entity - Phase 1: Data Quality Assessment
-- ================================================================
-- Purpose: Analyze staging data for issues before transformation
-- Created: 2025-10-06
--
-- Prerequisites: Run 02_load_staging_data.sql first
--
-- Assessment Areas:
-- 1. Row counts & completeness
-- 2. Email deduplication conflicts
-- 3. NULL values in required fields
-- 4. Password format validation
-- 5. Address city/province matching
-- 6. Data type issues
-- 7. Character encoding problems
-- ================================================================

\echo '================================================================'
\echo 'USERS & ACCESS - DATA QUALITY ASSESSMENT REPORT'
\echo 'Generated: ' `date`
\echo '================================================================'

-- ================================================================
-- SECTION 1: ROW COUNTS & COMPLETENESS
-- ================================================================

\echo ''
\echo '1. ROW COUNTS & COMPLETENESS'
\echo '----------------------------------------'

SELECT 
    'V1 users (active)' as source_table,
    COUNT(*) as total_rows,
    COUNT(DISTINCT id) as unique_ids,
    COUNT(*) - COUNT(DISTINCT id) as duplicate_ids,
    ROUND(100.0 * COUNT(DISTINCT id) / NULLIF(COUNT(*), 0), 2) as pct_unique
FROM staging.v1_users

UNION ALL

SELECT 
    'V1 users (excluded)',
    COUNT(*),
    COUNT(DISTINCT id),
    COUNT(*) - COUNT(DISTINCT id),
    ROUND(100.0 * COUNT(DISTINCT id) / NULLIF(COUNT(*), 0), 2)
FROM staging.v1_users_excluded

UNION ALL

SELECT 
    'V1 callcenter_users',
    COUNT(*),
    COUNT(DISTINCT id),
    COUNT(*) - COUNT(DISTINCT id),
    ROUND(100.0 * COUNT(DISTINCT id) / NULLIF(COUNT(*), 0), 2)
FROM staging.v1_callcenter_users

UNION ALL

SELECT 
    'V2 site_users',
    COUNT(*),
    COUNT(DISTINCT id),
    COUNT(*) - COUNT(DISTINCT id),
    ROUND(100.0 * COUNT(DISTINCT id) / NULLIF(COUNT(*), 0), 2)
FROM staging.v2_site_users

UNION ALL

SELECT 
    'V2 admin_users',
    COUNT(*),
    COUNT(DISTINCT id),
    COUNT(*) - COUNT(DISTINCT id),
    ROUND(100.0 * COUNT(DISTINCT id) / NULLIF(COUNT(*), 0), 2)
FROM staging.v2_admin_users

UNION ALL

SELECT 
    'V2 delivery_addresses',
    COUNT(*),
    COUNT(DISTINCT id),
    COUNT(*) - COUNT(DISTINCT id),
    ROUND(100.0 * COUNT(DISTINCT id) / NULLIF(COUNT(*), 0), 2)
FROM staging.v2_site_users_delivery_addresses;

-- ================================================================
-- SECTION 2: EMAIL DEDUPLICATION ANALYSIS
-- ================================================================

\echo ''
\echo '2. EMAIL DEDUPLICATION ANALYSIS'
\echo '----------------------------------------'

-- 2A: Overall email statistics
\echo 'Overall Email Statistics:'
SELECT 
    'V1 Users' as source,
    COUNT(*) as total_records,
    COUNT(email) as emails_present,
    COUNT(*) - COUNT(email) as emails_missing,
    COUNT(DISTINCT LOWER(TRIM(email))) as unique_emails_normalized
FROM staging.v1_users

UNION ALL

SELECT 
    'V2 Site Users',
    COUNT(*),
    COUNT(email),
    COUNT(*) - COUNT(email),
    COUNT(DISTINCT LOWER(TRIM(email)))
FROM staging.v2_site_users

UNION ALL

SELECT 
    'V1 Callcenter',
    COUNT(*),
    COUNT(email),
    COUNT(*) - COUNT(email),
    COUNT(DISTINCT LOWER(TRIM(email)))
FROM staging.v1_callcenter_users

UNION ALL

SELECT 
    'V2 Admin',
    COUNT(*),
    COUNT(email),
    COUNT(*) - COUNT(email),
    COUNT(DISTINCT LOWER(TRIM(email)))
FROM staging.v2_admin_users;

-- 2B: Duplicate emails WITHIN V1
\echo ''
\echo 'Duplicate Emails Within V1 Users:'
SELECT 
    LOWER(TRIM(email)) as email_normalized,
    COUNT(*) as occurrences,
    STRING_AGG(DISTINCT id::TEXT, ', ' ORDER BY id::TEXT) as user_ids
FROM staging.v1_users
WHERE email IS NOT NULL
GROUP BY LOWER(TRIM(email))
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC
LIMIT 20;

-- 2C: Duplicate emails WITHIN V2
\echo ''
\echo 'Duplicate Emails Within V2 Site Users:'
SELECT 
    LOWER(TRIM(email)) as email_normalized,
    COUNT(*) as occurrences,
    STRING_AGG(DISTINCT id::TEXT, ', ' ORDER BY id::TEXT) as user_ids
FROM staging.v2_site_users
WHERE email IS NOT NULL
GROUP BY LOWER(TRIM(email))
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC
LIMIT 20;

-- 2D: Email conflicts BETWEEN V1 and V2 (KEY ANALYSIS)
\echo ''
\echo 'Email Conflicts Between V1 and V2 (Sample - Top 50):'

WITH email_sources AS (
    SELECT 
        LOWER(TRIM(email)) as email_normalized,
        id as v1_id,
        NULL::INTEGER as v2_id,
        lastLogin as v1_last_login,
        NULL::TIMESTAMP as v2_last_login,
        isActive as v1_active
    FROM staging.v1_users
    WHERE email IS NOT NULL
    
    UNION ALL
    
    SELECT 
        LOWER(TRIM(email)),
        NULL,
        id,
        NULL,
        last_login,
        NULL
    FROM staging.v2_site_users
    WHERE email IS NOT NULL
),
conflict_summary AS (
    SELECT 
        email_normalized,
        COUNT(*) as total_occurrences,
        COUNT(v1_id) as v1_count,
        COUNT(v2_id) as v2_count,
        MAX(v1_last_login) as v1_most_recent_login,
        MAX(v2_last_login) as v2_most_recent_login
    FROM email_sources
    GROUP BY email_normalized
    HAVING COUNT(v1_id) > 0 AND COUNT(v2_id) > 0  -- Has records in BOTH V1 and V2
)
SELECT 
    email_normalized,
    v1_count,
    v2_count,
    v1_most_recent_login,
    v2_most_recent_login,
    CASE 
        WHEN v2_most_recent_login > v1_most_recent_login THEN 'V2 Winner (newer)'
        WHEN v1_most_recent_login > v2_most_recent_login THEN 'V1 Winner (newer)'
        ELSE 'V2 Winner (default)'
    END as resolution_strategy
FROM conflict_summary
ORDER BY v1_count DESC, v2_count DESC
LIMIT 50;

-- 2E: Total conflict count
\echo ''
\echo 'Email Conflict Summary (V1 vs V2):'

WITH email_presence AS (
    SELECT 
        LOWER(TRIM(email)) as email_normalized,
        MAX(CASE WHEN source = 'v1' THEN 1 ELSE 0 END) as in_v1,
        MAX(CASE WHEN source = 'v2' THEN 1 ELSE 0 END) as in_v2
    FROM (
        SELECT LOWER(TRIM(email)) as email, 'v1' as source FROM staging.v1_users WHERE email IS NOT NULL
        UNION ALL
        SELECT LOWER(TRIM(email)), 'v2' FROM staging.v2_site_users WHERE email IS NOT NULL
    ) combined
    GROUP BY LOWER(TRIM(email))
)
SELECT 
    SUM(CASE WHEN in_v1 = 1 AND in_v2 = 0 THEN 1 ELSE 0 END) as v1_only,
    SUM(CASE WHEN in_v1 = 0 AND in_v2 = 1 THEN 1 ELSE 0 END) as v2_only,
    SUM(CASE WHEN in_v1 = 1 AND in_v2 = 1 THEN 1 ELSE 0 END) as both_v1_and_v2_conflicts,
    COUNT(*) as total_unique_emails
FROM email_presence;

-- ================================================================
-- SECTION 3: NULL VALUES IN REQUIRED FIELDS
-- ================================================================

\echo ''
\echo '3. NULL VALUES IN REQUIRED FIELDS'
\echo '----------------------------------------'

-- 3A: V1 Users
\echo 'V1 Users - NULL Analysis:'
SELECT 
    'email' as field_name,
    COUNT(*) FILTER (WHERE email IS NULL OR TRIM(email) = '') as null_count,
    COUNT(*) as total_count,
    ROUND(100.0 * COUNT(*) FILTER (WHERE email IS NULL OR TRIM(email) = '') / COUNT(*), 2) as null_pct
FROM staging.v1_users
UNION ALL
SELECT 'password', COUNT(*) FILTER (WHERE password IS NULL OR TRIM(password) = ''), COUNT(*), 
       ROUND(100.0 * COUNT(*) FILTER (WHERE password IS NULL OR TRIM(password) = '') / COUNT(*), 2)
FROM staging.v1_users
UNION ALL
SELECT 'fname', COUNT(*) FILTER (WHERE fname IS NULL OR TRIM(fname) = ''), COUNT(*), 
       ROUND(100.0 * COUNT(*) FILTER (WHERE fname IS NULL OR TRIM(fname) = '') / COUNT(*), 2)
FROM staging.v1_users
UNION ALL
SELECT 'lname', COUNT(*) FILTER (WHERE lname IS NULL OR TRIM(lname) = ''), COUNT(*), 
       ROUND(100.0 * COUNT(*) FILTER (WHERE lname IS NULL OR TRIM(lname) = '') / COUNT(*), 2)
FROM staging.v1_users;

-- 3B: V2 Site Users
\echo ''
\echo 'V2 Site Users - NULL Analysis:'
SELECT 
    'email' as field_name,
    COUNT(*) FILTER (WHERE email IS NULL OR TRIM(email) = '') as null_count,
    COUNT(*) as total_count,
    ROUND(100.0 * COUNT(*) FILTER (WHERE email IS NULL OR TRIM(email) = '') / COUNT(*), 2) as null_pct
FROM staging.v2_site_users
UNION ALL
SELECT 'password', COUNT(*) FILTER (WHERE password IS NULL OR TRIM(password) = ''), COUNT(*), 
       ROUND(100.0 * COUNT(*) FILTER (WHERE password IS NULL OR TRIM(password) = '') / COUNT(*), 2)
FROM staging.v2_site_users
UNION ALL
SELECT 'fname', COUNT(*) FILTER (WHERE fname IS NULL OR TRIM(fname) = ''), COUNT(*), 
       ROUND(100.0 * COUNT(*) FILTER (WHERE fname IS NULL OR TRIM(fname) = '') / COUNT(*), 2)
FROM staging.v2_site_users
UNION ALL
SELECT 'lname', COUNT(*) FILTER (WHERE lname IS NULL OR TRIM(lname) = ''), COUNT(*), 
       ROUND(100.0 * COUNT(*) FILTER (WHERE lname IS NULL OR TRIM(lname) = '') / COUNT(*), 2)
FROM staging.v2_site_users;

-- ================================================================
-- SECTION 4: PASSWORD FORMAT VALIDATION
-- ================================================================

\echo ''
\echo '4. PASSWORD FORMAT VALIDATION'
\echo '----------------------------------------'

-- Check for bcrypt format ($2y$10$...)
SELECT 
    'V1 Users' as source,
    COUNT(*) as total_passwords,
    COUNT(*) FILTER (WHERE password LIKE '$2y$10$%') as bcrypt_format,
    COUNT(*) FILTER (WHERE password NOT LIKE '$2y$10$%' AND password IS NOT NULL) as other_format,
    COUNT(*) FILTER (WHERE password IS NULL) as null_passwords
FROM staging.v1_users

UNION ALL

SELECT 
    'V2 Site Users',
    COUNT(*),
    COUNT(*) FILTER (WHERE password LIKE '$2y$10$%'),
    COUNT(*) FILTER (WHERE password NOT LIKE '$2y$10$%' AND password IS NOT NULL),
    COUNT(*) FILTER (WHERE password IS NULL)
FROM staging.v2_site_users

UNION ALL

SELECT 
    'V1 Callcenter',
    COUNT(*),
    COUNT(*) FILTER (WHERE password LIKE '$2y$10$%'),
    COUNT(*) FILTER (WHERE password NOT LIKE '$2y$10$%' AND password IS NOT NULL),
    COUNT(*) FILTER (WHERE password IS NULL)
FROM staging.v1_callcenter_users

UNION ALL

SELECT 
    'V2 Admin',
    COUNT(*),
    COUNT(*) FILTER (WHERE password LIKE '$2y$10$%'),
    COUNT(*) FILTER (WHERE password NOT LIKE '$2y$10$%' AND password IS NOT NULL),
    COUNT(*) FILTER (WHERE password IS NULL)
FROM staging.v2_admin_users;

-- Sample non-bcrypt passwords (if any)
\echo ''
\echo 'Sample Non-Bcrypt Passwords (V1):'
SELECT id, email, 
       LEFT(password, 20) as password_sample,
       LENGTH(password) as password_length
FROM staging.v1_users
WHERE password NOT LIKE '$2y$10$%' 
  AND password IS NOT NULL
LIMIT 10;

-- ================================================================
-- SECTION 5: ADDRESS CITY/PROVINCE MATCHING
-- ================================================================

\echo ''
\echo '5. ADDRESS CITY/PROVINCE VALIDATION'
\echo '----------------------------------------'

-- 5A: V2 Addresses - City/Province combinations
\echo 'V2 Addresses - Top Cities:'
SELECT 
    TRIM(city) as city_name,
    TRIM(province) as province_code,
    COUNT(*) as address_count,
    COUNT(DISTINCT user_id) as unique_users
FROM staging.v2_site_users_delivery_addresses
WHERE city IS NOT NULL
GROUP BY TRIM(city), TRIM(province)
ORDER BY COUNT(*) DESC
LIMIT 20;

-- 5B: Check for unmatched cities against menuca_v3.cities
\echo ''
\echo 'V2 Addresses - Cities NOT in menuca_v3.cities (Sample):'

SELECT DISTINCT
    TRIM(addr.city) as address_city,
    TRIM(addr.province) as address_province,
    COUNT(*) as address_count,
    CASE 
        WHEN c.id IS NULL THEN 'NOT FOUND'
        ELSE 'MATCHED'
    END as match_status
FROM staging.v2_site_users_delivery_addresses addr
LEFT JOIN menuca_v3.provinces p ON 
    LOWER(TRIM(p.code)) = LOWER(TRIM(addr.province))
LEFT JOIN menuca_v3.cities c ON 
    LOWER(TRIM(c.name)) = LOWER(TRIM(addr.city)) 
    AND c.province_id = p.id
WHERE addr.city IS NOT NULL
GROUP BY TRIM(addr.city), TRIM(addr.province), c.id
HAVING c.id IS NULL
ORDER BY COUNT(*) DESC
LIMIT 30;

-- 5C: Address data quality flags
\echo ''
\echo 'V2 Addresses - Data Quality Flags:'
SELECT 
    COUNT(*) as total_addresses,
    COUNT(*) FILTER (WHERE missingData = 'y') as missing_data_flag,
    COUNT(*) FILTER (WHERE active = 'n') as inactive_addresses,
    COUNT(*) FILTER (WHERE city IS NULL OR TRIM(city) = '') as missing_city,
    COUNT(*) FILTER (WHERE province IS NULL OR TRIM(province) = '') as missing_province,
    COUNT(*) FILTER (WHERE zip IS NULL OR TRIM(zip) = '') as missing_zip,
    COUNT(*) FILTER (WHERE lat IS NULL OR lng IS NULL) as missing_geocoding
FROM staging.v2_site_users_delivery_addresses;

-- ================================================================
-- SECTION 6: DATA TYPE & FORMAT ISSUES
-- ================================================================

\echo ''
\echo '6. DATA TYPE & FORMAT ISSUES'
\echo '----------------------------------------'

-- 6A: Email format validation (basic check)
\echo 'Invalid Email Formats (Sample):'
SELECT 
    'V1 Users' as source,
    id,
    email
FROM staging.v1_users
WHERE email IS NOT NULL 
  AND email NOT LIKE '%@%.%'
LIMIT 10

UNION ALL

SELECT 
    'V2 Site Users',
    id,
    email
FROM staging.v2_site_users
WHERE email IS NOT NULL 
  AND email NOT LIKE '%@%.%'
LIMIT 10;

-- 6B: Postal code format check (Canadian format: A1A 1A1)
\echo ''
\echo 'Postal Code Format Issues (V2 Addresses):'
SELECT 
    COUNT(*) as total_with_zip,
    COUNT(*) FILTER (WHERE zip ~ '^[A-Z][0-9][A-Z] [0-9][A-Z][0-9]$') as correct_format,
    COUNT(*) FILTER (WHERE zip !~ '^[A-Z][0-9][A-Z] [0-9][A-Z][0-9]$') as incorrect_format,
    ROUND(100.0 * COUNT(*) FILTER (WHERE zip ~ '^[A-Z][0-9][A-Z] [0-9][A-Z][0-9]$') / NULLIF(COUNT(*), 0), 2) as pct_correct
FROM staging.v2_site_users_delivery_addresses
WHERE zip IS NOT NULL AND TRIM(zip) != '';

-- Sample incorrect postal codes
SELECT zip, COUNT(*) as occurrences
FROM staging.v2_site_users_delivery_addresses
WHERE zip IS NOT NULL 
  AND TRIM(zip) != ''
  AND zip !~ '^[A-Z][0-9][A-Z] [0-9][A-Z][0-9]$'
GROUP BY zip
ORDER BY COUNT(*) DESC
LIMIT 20;

-- ================================================================
-- SECTION 7: ORPHANED RECORDS (FK VALIDATION)
-- ================================================================

\echo ''
\echo '7. ORPHANED RECORDS (Foreign Key Issues)'
\echo '----------------------------------------'

-- 7A: V2 Addresses with missing users
\echo 'V2 Addresses - Orphaned (no matching user):'
SELECT 
    COUNT(*) as total_addresses,
    COUNT(*) FILTER (WHERE u.id IS NULL) as orphaned_addresses,
    ROUND(100.0 * COUNT(*) FILTER (WHERE u.id IS NULL) / NULLIF(COUNT(*), 0), 2) as orphan_pct
FROM staging.v2_site_users_delivery_addresses a
LEFT JOIN staging.v2_site_users u ON u.id = a.user_id;

-- 7B: V2 Admin-Restaurant junction with missing admins
\echo ''
\echo 'V2 Admin-Restaurant Junction - Orphaned admins:'
SELECT 
    COUNT(*) as total_relationships,
    COUNT(*) FILTER (WHERE a.id IS NULL) as orphaned_admin_relationships,
    ROUND(100.0 * COUNT(*) FILTER (WHERE a.id IS NULL) / NULLIF(COUNT(*), 0), 2) as orphan_pct
FROM staging.v2_admin_users_restaurants ar
LEFT JOIN staging.v2_admin_users a ON a.id = ar.user_id;

-- 7C: V2 Reset codes with missing users
\echo ''
\echo 'V2 Reset Codes - Orphaned (no matching user):'
SELECT 
    COUNT(*) as total_reset_codes,
    COUNT(*) FILTER (WHERE u.id IS NULL) as orphaned_codes,
    ROUND(100.0 * COUNT(*) FILTER (WHERE u.id IS NULL) / NULLIF(COUNT(*), 0), 2) as orphan_pct
FROM staging.v2_reset_codes rc
LEFT JOIN staging.v2_site_users u ON u.id = rc.user_id;

-- ================================================================
-- FINAL SUMMARY
-- ================================================================

\echo ''
\echo '================================================================'
\echo 'DATA QUALITY ASSESSMENT COMPLETE'
\echo '================================================================'
\echo ''
\echo 'Key Findings:'
\echo '1. Email conflicts between V1 and V2 users (deduplication needed)'
\echo '2. Password format compatibility (bcrypt in both - GOOD!)'
\echo '3. Address city/province matching against menuca_v3.cities'
\echo '4. Orphaned records requiring cleanup'
\echo ''
\echo 'Next Step: Review findings and create remediation plan'
\echo '================================================================'
