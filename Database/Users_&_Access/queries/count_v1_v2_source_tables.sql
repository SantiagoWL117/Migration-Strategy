-- ================================================================
-- Users & Access Entity - Source Table Row Counts
-- Purpose: Get row counts from all V1 and V2 source tables
-- Date: January 7, 2025
-- ================================================================

-- ================================================================
-- SECTION 1: V1 TABLES (menuca_v1 schema)
-- ================================================================

SELECT 
    'menuca_v1' AS schema_name,
    'users' AS table_name,
    COUNT(*) AS row_count,
    'Customer accounts' AS description
FROM menuca_v1.users

UNION ALL

SELECT 
    'menuca_v1',
    'admin_users',
    COUNT(*),
    'Platform administrator accounts'
FROM menuca_v1.admin_users

UNION ALL

SELECT 
    'menuca_v1',
    'callcenter_users',
    COUNT(*),
    'Call center staff accounts'
FROM menuca_v1.callcenter_users

UNION ALL

SELECT 
    'menuca_v1',
    'users_delivery_addresses',
    COUNT(*),
    'User saved delivery addresses'
FROM menuca_v1.users_delivery_addresses

UNION ALL

SELECT 
    'menuca_v1',
    'pass_reset',
    COUNT(*),
    'Password reset tokens (historical)'
FROM menuca_v1.pass_reset

UNION ALL

SELECT 
    'menuca_v1',
    'logintoken',
    COUNT(*),
    'Legacy login tokens'
FROM menuca_v1.logintoken

-- ================================================================
-- SECTION 2: V2 TABLES (menuca_v2 schema)
-- ================================================================

UNION ALL

SELECT 
    'menuca_v2',
    'site_users',
    COUNT(*),
    'Customer accounts (V2)'
FROM menuca_v2.site_users

UNION ALL

SELECT 
    'menuca_v2',
    'admin_users',
    COUNT(*),
    'Admin accounts (V2)'
FROM menuca_v2.admin_users

UNION ALL

SELECT 
    'menuca_v2',
    'admin_users_restaurants',
    COUNT(*),
    'Admin-restaurant access mappings'
FROM menuca_v2.admin_users_restaurants

UNION ALL

SELECT 
    'menuca_v2',
    'site_users_delivery_addresses',
    COUNT(*),
    'User delivery addresses (V2)'
FROM menuca_v2.site_users_delivery_addresses

UNION ALL

SELECT 
    'menuca_v2',
    'site_users_favorite_restaurants',
    COUNT(*),
    'User favorite restaurants'
FROM menuca_v2.site_users_favorite_restaurants

UNION ALL

SELECT 
    'menuca_v2',
    'site_users_fb',
    COUNT(*),
    'OAuth/Facebook user profiles'
FROM menuca_v2.site_users_fb

UNION ALL

SELECT 
    'menuca_v2',
    'site_users_autologins',
    COUNT(*),
    '"Remember me" autologin tokens'
FROM menuca_v2.site_users_autologins

UNION ALL

SELECT 
    'menuca_v2',
    'reset_codes',
    COUNT(*),
    'Password reset codes (V2)'
FROM menuca_v2.reset_codes

UNION ALL

SELECT 
    'menuca_v2',
    'ci_sessions',
    COUNT(*),
    'Active user sessions (ephemeral)'
FROM menuca_v2.ci_sessions

UNION ALL

SELECT 
    'menuca_v2',
    'login_attempts',
    COUNT(*),
    'Failed login attempt log'
FROM menuca_v2.login_attempts

-- ================================================================
-- ORDER BY: Schema first, then table name
-- ================================================================
ORDER BY 
    CASE schema_name 
        WHEN 'menuca_v1' THEN 1 
        WHEN 'menuca_v2' THEN 2 
    END,
    table_name;

-- ================================================================
-- EXPECTED OUTPUT (based on CSV analysis):
-- ================================================================
-- | schema_name | table_name                      | row_count | description                          |
-- |-------------|---------------------------------|-----------|--------------------------------------|
-- | menuca_v1   | admin_users                     |         0 | Platform administrator accounts      |
-- | menuca_v1   | callcenter_users                |        37 | Call center staff accounts           |
-- | menuca_v1   | logintoken                      |         7 | Legacy login tokens                  |
-- | menuca_v1   | pass_reset                      |   203,017 | Password reset tokens (historical)   |
-- | menuca_v1   | users                           |   442,282 | Customer accounts                    |
-- | menuca_v1   | users_delivery_addresses        |   UNKNOWN | User saved delivery addresses        |
-- | menuca_v2   | admin_users                     |        52 | Admin accounts (V2)                  |
-- | menuca_v2   | admin_users_restaurants         |        99 | Admin-restaurant access mappings     |
-- | menuca_v2   | ci_sessions                     |       110 | Active user sessions (ephemeral)     |
-- | menuca_v2   | login_attempts                  |         0 | Failed login attempt log             |
-- | menuca_v2   | reset_codes                     |     3,629 | Password reset codes (V2)            |
-- | menuca_v2   | site_users                      |     8,942 | Customer accounts (V2)               |
-- | menuca_v2   | site_users_autologins           |       890 | "Remember me" autologin tokens       |
-- | menuca_v2   | site_users_delivery_addresses   |    12,045 | User delivery addresses (V2)         |
-- | menuca_v2   | site_users_favorite_restaurants |         1 | User favorite restaurants            |
-- | menuca_v2   | site_users_fb                   |         0 | OAuth/Facebook user profiles         |
-- ================================================================
-- 16 rows in set
-- ================================================================

-- ================================================================
-- NOTES:
-- ================================================================
-- 1. This query assumes both menuca_v1 and menuca_v2 databases exist
-- 2. Run this query from any database context (cross-schema query)
-- 3. Expected total: ~671,000 rows across 16 tables (excluding UNKNOWN addresses)
-- 4. CRITICAL: menuca_v1.users_delivery_addresses count is UNKNOWN (no dump available)
-- 5. Many rows will be filtered during migration (inactive users, expired tokens)
-- 6. Target V3 row count after filtering: ~28,000 rows (98% reduction)
-- ================================================================


