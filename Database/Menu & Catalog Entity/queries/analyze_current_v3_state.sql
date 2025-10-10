-- Menu & Catalog Entity - Current menuca_v3 State Analysis
-- Purpose: Understand what data currently exists in V3 tables
-- Status: Analysis Query

-- ================================================================
-- 1. ROW COUNTS (Current State)
-- ================================================================
SELECT 
  'courses' as table_name,
  COUNT(*) as row_count,
  MIN(id) as min_id,
  MAX(id) as max_id
FROM menuca_v3.courses

UNION ALL

SELECT 'dishes', COUNT(*), MIN(id), MAX(id)
FROM menuca_v3.dishes

UNION ALL

SELECT 'ingredients', COUNT(*), MIN(id), MAX(id)
FROM menuca_v3.ingredients

UNION ALL

SELECT 'ingredient_groups', COUNT(*), MIN(id), MAX(id)
FROM menuca_v3.ingredient_groups

UNION ALL

SELECT 'combo_groups', COUNT(*), MIN(id), MAX(id)
FROM menuca_v3.combo_groups

UNION ALL

SELECT 'combo_items', COUNT(*), MIN(id), MAX(id)
FROM menuca_v3.combo_items

UNION ALL

SELECT 'dish_customizations', COUNT(*), MIN(id), MAX(id)
FROM menuca_v3.dish_customizations

UNION ALL

SELECT 'dish_modifiers', COUNT(*), MIN(id), MAX(id)
FROM menuca_v3.dish_modifiers

ORDER BY table_name;

-- ================================================================
-- 2. SAMPLE DATA INSPECTION (5 records per table)
-- ================================================================

-- Courses
SELECT 'COURSES' as table_name, * FROM menuca_v3.courses LIMIT 5;

-- Dishes
SELECT 'DISHES' as table_name, * FROM menuca_v3.dishes LIMIT 5;

-- Ingredients
SELECT 'INGREDIENTS' as table_name, * FROM menuca_v3.ingredients LIMIT 5;

-- Ingredient Groups
SELECT 'INGREDIENT_GROUPS' as table_name, * FROM menuca_v3.ingredient_groups LIMIT 5;

-- Combo Groups
SELECT 'COMBO_GROUPS' as table_name, * FROM menuca_v3.combo_groups LIMIT 5;

-- Combo Items
SELECT 'COMBO_ITEMS' as table_name, * FROM menuca_v3.combo_items LIMIT 5;

-- Dish Customizations
SELECT 'DISH_CUSTOMIZATIONS' as table_name, * FROM menuca_v3.dish_customizations LIMIT 5;

-- Dish Modifiers
SELECT 'DISH_MODIFIERS' as table_name, * FROM menuca_v3.dish_modifiers LIMIT 5;

-- ================================================================
-- 3. CHECK FOR SOURCE TRACKING COLUMNS
-- ================================================================
SELECT 
  table_name,
  column_name,
  data_type
FROM information_schema.columns
WHERE table_schema = 'menuca_v3'
  AND table_name IN ('courses', 'dishes', 'ingredients', 'ingredient_groups', 
                     'combo_groups', 'combo_items', 'dish_customizations', 'dish_modifiers')
  AND column_name LIKE '%legacy%' OR column_name LIKE '%source%'
ORDER BY table_name, column_name;

-- ================================================================
-- 4. CHECK FOR JSONB/BLOB COLUMNS
-- ================================================================
SELECT 
  table_name,
  column_name,
  data_type
FROM information_schema.columns
WHERE table_schema = 'menuca_v3'
  AND table_name IN ('courses', 'dishes', 'ingredients', 'ingredient_groups', 
                     'combo_groups', 'combo_items', 'dish_customizations', 'dish_modifiers')
  AND (data_type = 'jsonb' OR data_type = 'json')
ORDER BY table_name, column_name;

-- ================================================================
-- 5. RELATIONSHIP INTEGRITY CHECK
-- ================================================================

-- Dishes without valid course
SELECT COUNT(*) as dishes_missing_course
FROM menuca_v3.dishes d
WHERE NOT EXISTS (
  SELECT 1 FROM menuca_v3.courses c WHERE c.id = d.course_id
);

-- Dishes without valid restaurant
SELECT COUNT(*) as dishes_missing_restaurant
FROM menuca_v3.dishes d
WHERE NOT EXISTS (
  SELECT 1 FROM menuca_v3.restaurants r WHERE r.id = d.restaurant_id
);

-- Customizations without valid dish
SELECT COUNT(*) as customizations_missing_dish
FROM menuca_v3.dish_customizations dc
WHERE NOT EXISTS (
  SELECT 1 FROM menuca_v3.dishes d WHERE d.id = dc.dish_id
);

-- Modifiers without valid dish
SELECT COUNT(*) as modifiers_missing_dish
FROM menuca_v3.dish_modifiers dm
WHERE NOT EXISTS (
  SELECT 1 FROM menuca_v3.dishes d WHERE d.id = dm.dish_id
);

-- Modifiers without valid ingredient
SELECT COUNT(*) as modifiers_missing_ingredient
FROM menuca_v3.dish_modifiers dm
WHERE NOT EXISTS (
  SELECT 1 FROM menuca_v3.ingredients i WHERE i.id = dm.ingredient_id
);

-- ================================================================
-- 6. DATA QUALITY SPOT CHECKS
-- ================================================================

-- Dishes with NULL names
SELECT COUNT(*) as dishes_null_names
FROM menuca_v3.dishes
WHERE name IS NULL OR TRIM(name) = '';

-- Dishes with NULL/zero prices
SELECT COUNT(*) as dishes_null_prices
FROM menuca_v3.dishes
WHERE base_price IS NULL OR base_price = 0;

-- Ingredients with NULL names
SELECT COUNT(*) as ingredients_null_names
FROM menuca_v3.ingredients
WHERE name IS NULL OR TRIM(name) = '';

-- Courses with NULL names
SELECT COUNT(*) as courses_null_names
FROM menuca_v3.courses
WHERE name IS NULL OR TRIM(name) = '';

-- ================================================================
-- 7. RESTAURANT DISTRIBUTION
-- ================================================================

-- How many unique restaurants have data in each table?
SELECT 
  'courses' as table_name,
  COUNT(DISTINCT restaurant_id) as unique_restaurants
FROM menuca_v3.courses

UNION ALL

SELECT 'dishes', COUNT(DISTINCT restaurant_id)
FROM menuca_v3.dishes

UNION ALL

SELECT 'ingredients', COUNT(DISTINCT restaurant_id)
FROM menuca_v3.ingredients

UNION ALL

SELECT 'ingredient_groups', COUNT(DISTINCT restaurant_id)
FROM menuca_v3.ingredient_groups

UNION ALL

SELECT 'combo_groups', COUNT(DISTINCT restaurant_id)
FROM menuca_v3.combo_groups

ORDER BY table_name;

-- ================================================================
-- 8. JSONB DATA POPULATION CHECK
-- ================================================================

-- Check if JSONB columns have data
SELECT 
  'dishes.size_options' as jsonb_column,
  COUNT(*) as total_rows,
  COUNT(CASE WHEN size_options IS NOT NULL THEN 1 END) as populated,
  ROUND(COUNT(CASE WHEN size_options IS NOT NULL THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0), 1) as pct_populated
FROM menuca_v3.dishes

UNION ALL

SELECT 
  'dishes.price_matrix',
  COUNT(*),
  COUNT(CASE WHEN price_matrix IS NOT NULL THEN 1 END),
  ROUND(COUNT(CASE WHEN price_matrix IS NOT NULL THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0), 1)
FROM menuca_v3.dishes

UNION ALL

SELECT 
  'combo_groups.combo_rules',
  COUNT(*),
  COUNT(CASE WHEN combo_rules IS NOT NULL THEN 1 END),
  ROUND(COUNT(CASE WHEN combo_rules IS NOT NULL THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0), 1)
FROM menuca_v3.combo_groups;

