-- Query to inspect menuca_v3 schema structure
-- Run this to get complete table and column information

-- 1. List all tables in menuca_v3 schema
SELECT
    table_name,
    table_type
FROM information_schema.tables
WHERE table_schema = 'menuca_v3'
ORDER BY table_name;

-- 2. Get all menu-related tables
SELECT
    table_name
FROM information_schema.tables
WHERE table_schema = 'menuca_v3'
AND (
    table_name LIKE '%menu%'
    OR table_name LIKE '%dish%'
    OR table_name LIKE '%course%'
    OR table_name LIKE '%item%'
)
ORDER BY table_name;

-- 3. Get columns for menu_courses table (if it exists)
SELECT
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'menuca_v3'
AND table_name = 'menu_courses'
ORDER BY ordinal_position;

-- 4. Get columns for menu_items table (if it exists)
SELECT
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'menuca_v3'
AND table_name = 'menu_items'
ORDER BY ordinal_position;

-- 5. Get columns for dishes table (if it exists)
SELECT
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'menuca_v3'
AND table_name = 'dishes'
ORDER BY ordinal_position;

-- 6. Get columns for courses table (if it exists)
SELECT
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'menuca_v3'
AND table_name = 'courses'
ORDER BY ordinal_position;

-- 7. List all RPC functions in menuca_v3 schema
SELECT
    routine_name,
    routine_type,
    data_type AS return_type
FROM information_schema.routines
WHERE routine_schema = 'menuca_v3'
ORDER BY routine_name;

-- 8. Get complete restaurants table column list
SELECT
    column_name,
    data_type,
    character_maximum_length,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'menuca_v3'
AND table_name = 'restaurants'
ORDER BY ordinal_position;
