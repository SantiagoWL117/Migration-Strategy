-- ============================================================================
-- Step 0: Preconditions Check for restaurant_admin_users Migration
-- ============================================================================
-- Purpose: Verify all prerequisites are met before migrating restaurant admin users
-- Author: Migration Plan
-- Date: 2025-10-02
-- ============================================================================

\echo '🔍 Checking preconditions for restaurant_admin_users migration...'
\echo ''

-- 1. Check if uuid_generate_v4() function exists
\echo '1️⃣  Checking uuid_generate_v4() function...'
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM pg_proc p
            JOIN pg_namespace n ON p.pronamespace = n.oid
            WHERE n.nspname = 'extensions' AND p.proname = 'uuid_generate_v4'
        ) THEN '✅ uuid_generate_v4() function EXISTS'
        ELSE '❌ uuid_generate_v4() function MISSING - Run: CREATE EXTENSION IF NOT EXISTS "uuid-ossp" SCHEMA extensions;'
    END AS uuid_function_check;
\echo ''

-- 2. Check if set_updated_at() trigger function exists
\echo '2️⃣  Checking set_updated_at() trigger function...'
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM pg_proc p
            JOIN pg_namespace n ON p.pronamespace = n.oid
            WHERE n.nspname = 'menuca_v3' AND p.proname = 'set_updated_at'
        ) THEN '✅ set_updated_at() trigger function EXISTS'
        ELSE '❌ set_updated_at() trigger function MISSING - Run menuca_v3.sql schema creation'
    END AS trigger_function_check;
\echo ''

-- 3. Check if menuca_v3.restaurants table exists and has data
\echo '3️⃣  Checking menuca_v3.restaurants table...'
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.tables 
            WHERE table_schema = 'menuca_v3' AND table_name = 'restaurants'
        ) THEN 
            '✅ restaurants table EXISTS with ' || 
            (SELECT COUNT(*)::text FROM menuca_v3.restaurants) || ' records'
        ELSE '❌ restaurants table MISSING - Must migrate restaurants first'
    END AS restaurants_table_check;
\echo ''

-- 4. Check if restaurants have legacy_v1_id populated
\echo '4️⃣  Checking legacy_v1_id population in restaurants...'
SELECT 
    COUNT(*) AS total_restaurants,
    COUNT(legacy_v1_id) AS restaurants_with_v1_id,
    COUNT(*) - COUNT(legacy_v1_id) AS restaurants_without_v1_id,
    CASE 
        WHEN COUNT(legacy_v1_id) > 0 THEN 
            '✅ ' || COUNT(legacy_v1_id)::text || ' restaurants have legacy_v1_id'
        ELSE '❌ NO restaurants have legacy_v1_id - Must populate before migration'
    END AS legacy_id_check
FROM menuca_v3.restaurants;
\echo ''

-- 5. Check if restaurant_admin_users table exists
\echo '5️⃣  Checking menuca_v3.restaurant_admin_users table...'
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.tables 
            WHERE table_schema = 'menuca_v3' AND table_name = 'restaurant_admin_users'
        ) THEN 
            '✅ restaurant_admin_users table EXISTS (current records: ' || 
            (SELECT COUNT(*)::text FROM menuca_v3.restaurant_admin_users) || ')'
        ELSE '❌ restaurant_admin_users table MISSING - Run menuca_v3.sql schema creation'
    END AS admin_users_table_check;
\echo ''

-- 6. Check for unique constraint on (restaurant_id, email)
\echo '6️⃣  Checking unique constraint on (restaurant_id, email)...'
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM pg_indexes 
            WHERE schemaname = 'menuca_v3' 
            AND tablename = 'restaurant_admin_users'
            AND indexname = 'u_admin_email_per_restaurant'
        ) THEN '✅ Unique index u_admin_email_per_restaurant EXISTS'
        ELSE '❌ Unique index u_admin_email_per_restaurant MISSING'
    END AS unique_constraint_check;
\echo ''

-- 7. Show sample of restaurants with legacy_v1_id for FK verification
\echo '7️⃣  Sample restaurants with legacy_v1_id (for FK verification)...'
SELECT 
    id AS v3_restaurant_id,
    legacy_v1_id,
    name,
    status
FROM menuca_v3.restaurants
WHERE legacy_v1_id IS NOT NULL
ORDER BY legacy_v1_id
LIMIT 10;
\echo ''

\echo '============================================================================'
\echo '✅ All green checkmarks = Ready to proceed'
\echo '❌ Any red X = Fix issues before continuing'
\echo '============================================================================'

