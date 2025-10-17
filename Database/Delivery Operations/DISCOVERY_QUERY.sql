-- =====================================================
-- DELIVERY OPERATIONS - DISCOVERY QUERY
-- =====================================================
-- Purpose: Find all existing delivery-related tables in menuca_v3
-- Run this via Supabase MCP to see what exists
-- =====================================================

-- Query 1: Find all delivery-related tables
SELECT
    table_schema,
    table_name,
    table_type
FROM information_schema.tables
WHERE table_schema IN ('menuca_v3', 'public')
    AND (
        table_name LIKE '%deliver%'
        OR table_name LIKE '%driver%'
        OR table_name LIKE '%courier%'
        OR table_name LIKE '%dispatch%'
        OR table_name LIKE '%fleet%'
        OR table_name LIKE '%zone%'
    )
ORDER BY table_schema, table_name;

-- Query 2: Get detailed schema for each delivery table found
-- (Run this after reviewing Query 1 results - replace 'table_name' with actual names)
SELECT
    c.table_schema,
    c.table_name,
    c.column_name,
    c.data_type,
    c.column_default,
    c.is_nullable,
    c.character_maximum_length,
    c.numeric_precision,
    CASE
        WHEN pk.constraint_type = 'PRIMARY KEY' THEN 'PK'
        WHEN fk.constraint_type = 'FOREIGN KEY' THEN 'FK → ' || ccu.table_name || '(' || ccu.column_name || ')'
        ELSE NULL
    END AS constraint_info
FROM information_schema.columns c
LEFT JOIN information_schema.key_column_usage kcu
    ON c.table_schema = kcu.table_schema
    AND c.table_name = kcu.table_name
    AND c.column_name = kcu.column_name
LEFT JOIN information_schema.table_constraints pk
    ON kcu.constraint_name = pk.constraint_name
    AND pk.constraint_type = 'PRIMARY KEY'
LEFT JOIN information_schema.table_constraints fk
    ON kcu.constraint_name = fk.constraint_name
    AND fk.constraint_type = 'FOREIGN KEY'
LEFT JOIN information_schema.constraint_column_usage ccu
    ON kcu.constraint_name = ccu.constraint_name
WHERE c.table_schema = 'menuca_v3'
    AND c.table_name IN (
        -- Add table names from Query 1 results here
        'deliveries',
        'drivers',
        'delivery_zones',
        'driver_locations',
        'driver_earnings'
    )
ORDER BY c.table_name, c.ordinal_position;

-- Query 3: Check for tenant_id column (multi-tenancy)
SELECT
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'menuca_v3'
    AND table_name IN (
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'menuca_v3'
        AND (
            table_name LIKE '%deliver%'
            OR table_name LIKE '%driver%'
        )
    )
    AND column_name IN ('tenant_id', 'restaurant_id', 'legacy_v1_id', 'legacy_v2_id', 'source_system')
ORDER BY table_name, column_name;

-- Query 4: Check RLS status
SELECT
    schemaname,
    tablename,
    rowsecurity AS rls_enabled
FROM pg_tables
WHERE schemaname = 'menuca_v3'
    AND (
        tablename LIKE '%deliver%'
        OR tablename LIKE '%driver%'
    )
ORDER BY tablename;

-- Query 5: Check existing RLS policies
SELECT
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies
WHERE schemaname = 'menuca_v3'
    AND (
        tablename LIKE '%deliver%'
        OR tablename LIKE '%driver%'
    )
ORDER BY tablename, policyname;

-- Query 6: Check existing indexes
SELECT
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'menuca_v3'
    AND (
        tablename LIKE '%deliver%'
        OR tablename LIKE '%driver%'
    )
ORDER BY tablename, indexname;

-- Query 7: Row counts
SELECT
    schemaname || '.' || tablename AS full_table_name,
    n_live_tup AS approx_row_count
FROM pg_stat_user_tables
WHERE schemaname = 'menuca_v3'
    AND (
        tablename LIKE '%deliver%'
        OR tablename LIKE '%driver%'
    )
ORDER BY tablename;

-- =====================================================
-- INSTRUCTIONS:
-- 1. Run Query 1 first to see what tables exist
-- 2. Update Query 2 with actual table names found
-- 3. Run remaining queries to understand current state
-- 4. Share results to determine refactoring approach
-- =====================================================
