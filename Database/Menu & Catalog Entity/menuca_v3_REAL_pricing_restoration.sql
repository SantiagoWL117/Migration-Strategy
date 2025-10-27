-- MenuCA V3 REAL PRICING RESTORATION SCRIPTS
-- Restore actual pricing data from V1/V2 dumps instead of placeholders
-- This connects V3 restaurants to their original V1/V2 menu pricing

-- ========================================
-- STEP 1: Create temporary tables for V1/V2 data
-- ========================================
-- We'll load the dump files into these temp tables for matching

CREATE SCHEMA IF NOT EXISTS temp_migration;

-- V1 Menu table (matches the dump structure)
DROP TABLE IF EXISTS temp_migration.v1_menu;
CREATE TABLE temp_migration.v1_menu (
    id INTEGER,
    course INTEGER,
    restaurant INTEGER,  -- This maps to legacy_v1_id in V3
    sku VARCHAR(50),
    name VARCHAR(255),
    ingredients TEXT,
    price VARCHAR(125),  -- THE REAL PRICING DATA!
    display_order INTEGER,
    quantity VARCHAR(255)
    -- Add other columns as needed
);

-- V2 Dishes table (matches the dump structure)  
DROP TABLE IF EXISTS temp_migration.v2_restaurants_dishes;
CREATE TABLE temp_migration.v2_restaurants_dishes (
    id INTEGER,
    global_dish_id INTEGER,
    course_id INTEGER,   -- This connects to V2 courses
    name VARCHAR(125),
    description TEXT,
    size VARCHAR(125),
    price VARCHAR(125),  -- THE REAL PRICING DATA!
    price_j JSON,        -- JSON encoded pricing
    display_order INTEGER,
    enabled VARCHAR(1)
    -- Add other columns as needed
);

-- V2 Courses table to get restaurant mapping
DROP TABLE IF EXISTS temp_migration.v2_restaurants_courses;
CREATE TABLE temp_migration.v2_restaurants_courses (
    id INTEGER,
    restaurant_id INTEGER,  -- This maps to legacy_v2_id in V3
    global_course_id INTEGER,
    name VARCHAR(125),
    display_order INTEGER
);

-- ========================================
-- STEP 2: Load V1/V2 dump data
-- ========================================
-- MANUAL STEP: Load the dump files into these temp tables:
-- 1. Load menuca_v1_menu.sql into temp_migration.v1_menu
-- 2. Load menuca_v2_restaurants_dishes.sql into temp_migration.v2_restaurants_dishes  
-- 3. Load menuca_v2_restaurants_courses.sql into temp_migration.v2_restaurants_courses

-- ========================================
-- STEP 3: Restore V1 pricing data
-- ========================================
-- Match V3 dishes to V1 menu items by restaurant and name, then restore pricing

INSERT INTO menuca_v3.dish_prices (dish_id, price, cost, created_at, updated_at, source_system, source_id)
SELECT DISTINCT
    v3_dish.id as dish_id,
    CASE 
        WHEN v1_menu.price ~ '^[0-9]+\.?[0-9]*$' THEN v1_menu.price::DECIMAL(10,2)
        ELSE 0.01  -- Only for non-numeric legacy prices
    END as price,
    0.00 as cost,
    NOW() as created_at,
    NOW() as updated_at,
    'V1_RESTORED' as source_system,
    v1_menu.id as source_id
FROM menuca_v3.dishes v3_dish
JOIN menuca_v3.restaurants v3_rest ON v3_dish.restaurant_id = v3_rest.id
JOIN temp_migration.v1_menu v1_menu ON 
    v3_rest.legacy_v1_id = v1_menu.restaurant 
    AND LOWER(TRIM(v3_dish.name)) = LOWER(TRIM(v1_menu.name))
WHERE v3_dish.deleted_at IS NULL
  AND v3_rest.deleted_at IS NULL
  AND v3_rest.legacy_v1_id IS NOT NULL
  AND v1_menu.price IS NOT NULL
  AND v1_menu.price != ''
  AND NOT EXISTS (
      SELECT 1 FROM menuca_v3.dish_prices dp 
      WHERE dp.dish_id = v3_dish.id AND dp.deleted_at IS NULL
  );

-- ========================================
-- STEP 4: Restore V2 pricing data  
-- ========================================
-- Match V3 dishes to V2 dishes through courses and restaurant mapping

INSERT INTO menuca_v3.dish_prices (dish_id, price, cost, created_at, updated_at, source_system, source_id)
SELECT DISTINCT
    v3_dish.id as dish_id,
    CASE 
        WHEN v2_dish.price ~ '^[0-9]+\.?[0-9]*$' THEN v2_dish.price::DECIMAL(10,2)
        WHEN v2_dish.price_j IS NOT NULL THEN 
            COALESCE((v2_dish.price_j->>'price')::DECIMAL(10,2), 0.01)
        ELSE 0.01
    END as price,
    0.00 as cost,
    NOW() as created_at,
    NOW() as updated_at,
    'V2_RESTORED' as source_system,
    v2_dish.id as source_id
FROM menuca_v3.dishes v3_dish
JOIN menuca_v3.restaurants v3_rest ON v3_dish.restaurant_id = v3_rest.id
JOIN menuca_v3.courses v3_course ON v3_dish.course_id = v3_course.id
JOIN temp_migration.v2_restaurants_courses v2_course ON 
    v3_rest.legacy_v2_id = v2_course.restaurant_id
    AND LOWER(TRIM(v3_course.name)) = LOWER(TRIM(v2_course.name))
JOIN temp_migration.v2_restaurants_dishes v2_dish ON 
    v2_course.id = v2_dish.course_id
    AND LOWER(TRIM(v3_dish.name)) = LOWER(TRIM(v2_dish.name))
WHERE v3_dish.deleted_at IS NULL
  AND v3_rest.deleted_at IS NULL  
  AND v3_course.deleted_at IS NULL
  AND v3_rest.legacy_v2_id IS NOT NULL
  AND v2_dish.enabled = 'y'
  AND (v2_dish.price IS NOT NULL OR v2_dish.price_j IS NOT NULL)
  AND NOT EXISTS (
      SELECT 1 FROM menuca_v3.dish_prices dp 
      WHERE dp.dish_id = v3_dish.id AND dp.deleted_at IS NULL
  );

-- ========================================
-- STEP 5: Handle fuzzy matching for near-matches
-- ========================================
-- Some dish names might have slight variations (punctuation, spacing)

-- Fuzzy match V1 dishes with similarity threshold
INSERT INTO menuca_v3.dish_prices (dish_id, price, cost, created_at, updated_at, source_system, source_id)
SELECT DISTINCT
    v3_dish.id as dish_id,
    CASE 
        WHEN v1_menu.price ~ '^[0-9]+\.?[0-9]*$' THEN v1_menu.price::DECIMAL(10,2)
        ELSE 0.01
    END as price,
    0.00 as cost,
    NOW() as created_at,
    NOW() as updated_at,
    'V1_FUZZY_RESTORED' as source_system,
    v1_menu.id as source_id
FROM menuca_v3.dishes v3_dish
JOIN menuca_v3.restaurants v3_rest ON v3_dish.restaurant_id = v3_rest.id
JOIN temp_migration.v1_menu v1_menu ON 
    v3_rest.legacy_v1_id = v1_menu.restaurant
WHERE v3_dish.deleted_at IS NULL
  AND v3_rest.deleted_at IS NULL
  AND v3_rest.legacy_v1_id IS NOT NULL
  AND v1_menu.price IS NOT NULL
  AND v1_menu.price != ''
  -- Fuzzy string matching (85% similarity)
  AND similarity(LOWER(TRIM(v3_dish.name)), LOWER(TRIM(v1_menu.name))) > 0.85
  AND NOT EXISTS (
      SELECT 1 FROM menuca_v3.dish_prices dp 
      WHERE dp.dish_id = v3_dish.id AND dp.deleted_at IS NULL
  );

-- ========================================
-- STEP 6: Create pricing audit report
-- ========================================
-- Generate report showing what was restored vs what's still missing

CREATE OR REPLACE VIEW temp_migration.pricing_restoration_report AS
SELECT 
    'V1 Exact Matches' as match_type,
    COUNT(*) as prices_restored,
    AVG(price::DECIMAL) as avg_price
FROM menuca_v3.dish_prices 
WHERE source_system = 'V1_RESTORED' AND deleted_at IS NULL

UNION ALL

SELECT 
    'V2 Exact Matches' as match_type,
    COUNT(*) as prices_restored,
    AVG(price::DECIMAL) as avg_price
FROM menuca_v3.dish_prices 
WHERE source_system = 'V2_RESTORED' AND deleted_at IS NULL

UNION ALL

SELECT 
    'V1 Fuzzy Matches' as match_type,
    COUNT(*) as prices_restored,
    AVG(price::DECIMAL) as avg_price  
FROM menuca_v3.dish_prices
WHERE source_system = 'V1_FUZZY_RESTORED' AND deleted_at IS NULL

UNION ALL

SELECT 
    'Still Missing Prices' as match_type,
    COUNT(*) as prices_restored,
    0.00 as avg_price
FROM menuca_v3.dishes d
WHERE d.deleted_at IS NULL
  AND NOT EXISTS (
      SELECT 1 FROM menuca_v3.dish_prices dp 
      WHERE dp.dish_id = d.id AND dp.deleted_at IS NULL
  );

-- ========================================
-- STEP 7: Restaurant coverage report  
-- ========================================
-- Show which restaurants got their pricing restored

CREATE OR REPLACE VIEW temp_migration.restaurant_pricing_coverage AS
SELECT 
    r.id,
    r.name,
    r.legacy_v1_id,
    r.legacy_v2_id,
    COUNT(d.id) as total_dishes,
    COUNT(dp.id) as dishes_with_prices,
    ROUND(COUNT(dp.id) * 100.0 / NULLIF(COUNT(d.id), 0), 2) as coverage_percentage,
    STRING_AGG(DISTINCT dp.source_system, ', ' ORDER BY dp.source_system) as price_sources
FROM menuca_v3.restaurants r
LEFT JOIN menuca_v3.dishes d ON r.id = d.restaurant_id AND d.deleted_at IS NULL
LEFT JOIN menuca_v3.dish_prices dp ON d.id = dp.dish_id AND dp.deleted_at IS NULL
WHERE r.deleted_at IS NULL
GROUP BY r.id, r.name, r.legacy_v1_id, r.legacy_v2_id
ORDER BY coverage_percentage DESC, total_dishes DESC;

-- ========================================
-- VERIFICATION QUERIES
-- ========================================
-- Run these to check restoration success:

-- Total pricing restoration summary:
SELECT * FROM temp_migration.pricing_restoration_report;

-- Restaurant coverage (should show 100% for most restaurants):
SELECT 
    coverage_percentage,
    COUNT(*) as restaurant_count
FROM temp_migration.restaurant_pricing_coverage
GROUP BY coverage_percentage
ORDER BY coverage_percentage DESC;

-- Restaurants still missing prices (should be minimal):
SELECT * FROM temp_migration.restaurant_pricing_coverage 
WHERE coverage_percentage < 100
ORDER BY total_dishes DESC
LIMIT 20;

-- ========================================
-- CLEANUP
-- ========================================
-- Uncomment these after successful restoration:
-- DROP SCHEMA temp_migration CASCADE;
