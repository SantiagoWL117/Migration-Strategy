-- ============================================================================
-- Menu & Catalog Entity - V2 → V3 Transformation
-- ============================================================================
-- Purpose: Transform and load clean V2 data into V3 staging schema
-- Strategy: Merge with V1, handle global templates, parse JSON configs
-- Created: 2025-10-02
-- Author: Brian Lapp
-- ============================================================================

-- ============================================================================
-- STRATEGY: Merge vs Replace
-- ============================================================================
-- V2 data is newer and cleaner than V1
-- Where a restaurant exists in both V1 and V2, V2 should be preferred
-- We'll INSERT V2 data and handle conflicts/duplicates
-- ============================================================================

-- ============================================================================
-- STEP 1: Transform V2 Global Courses → V3 Courses
-- ============================================================================

DO $$
BEGIN
  RAISE NOTICE '🔄 Starting V2 Global Courses → V3 Courses transformation...';
  RAISE NOTICE '⚠️  Global courses have NULL restaurant_id';
END $$;

INSERT INTO staging.v3_courses (
  restaurant_id,
  name,
  description,
  display_order,
  is_global,
  language,
  availability_schedule,
  created_at,
  updated_at
)
SELECT
  NULL as restaurant_id, -- Global courses
  name,
  description,
  0 as display_order,
  true as is_global,
  staging.language_id_to_code(language_id) as language,
  NULL as availability_schedule,
  added_at as created_at,
  NULL as updated_at
FROM staging.v2_global_courses
WHERE name IS NOT NULL 
  AND TRIM(name) != ''
  AND staging.yn_to_boolean(enabled) = true
  AND COALESCE(exclude_from_v3, false) = false
ON CONFLICT DO NOTHING; -- Handle duplicates gracefully

DO $$
DECLARE
  rows_inserted INTEGER;
  total_v3_courses INTEGER;
BEGIN
  GET DIAGNOSTICS rows_inserted = ROW_COUNT;
  SELECT COUNT(*) INTO total_v3_courses FROM staging.v3_courses;
  RAISE NOTICE '✅ Inserted % global courses from V2', rows_inserted;
  RAISE NOTICE '📊 Total v3_courses now: %', total_v3_courses;
END $$;

-- ============================================================================
-- STEP 2: Transform V2 Restaurant Courses → V3 Courses
-- ============================================================================

DO $$
BEGIN
  RAISE NOTICE '🔄 Starting V2 Restaurant Courses → V3 Courses transformation...';
END $$;

INSERT INTO staging.v3_courses (
  restaurant_id,
  name,
  description,
  display_order,
  is_global,
  language,
  availability_schedule,
  created_at,
  updated_at
)
SELECT
  staging.validate_restaurant_id(restaurant_id) as restaurant_id,
  name,
  description,
  COALESCE(display_order, 0) as display_order,
  false as is_global,
  staging.language_id_to_code(language_id) as language,
  staging.create_availability_schedule(time_period) as availability_schedule,
  added_at as created_at,
  NULL as updated_at
FROM staging.v2_restaurants_courses
WHERE name IS NOT NULL 
  AND TRIM(name) != ''
  AND COALESCE(exclude_from_v3, false) = false
  AND staging.yn_to_boolean(enabled) = true
  AND staging.validate_restaurant_id(restaurant_id) IS NOT NULL
ON CONFLICT DO NOTHING;

DO $$
DECLARE
  rows_inserted INTEGER;
  total_v3_courses INTEGER;
BEGIN
  GET DIAGNOSTICS rows_inserted = ROW_COUNT;
  SELECT COUNT(*) INTO total_v3_courses FROM staging.v3_courses;
  RAISE NOTICE '✅ Inserted % restaurant courses from V2', rows_inserted;
  RAISE NOTICE '📊 Total v3_courses now: %', total_v3_courses;
END $$;

-- ============================================================================
-- STEP 3: Transform V2 Restaurant Dishes → V3 Dishes
-- ============================================================================

DO $$
BEGIN
  RAISE NOTICE '🔄 Starting V2 Restaurant Dishes → V3 Dishes transformation...';
  RAISE NOTICE '⚠️  Applying exclusion filter (exclude_from_v3 = FALSE)';
  RAISE NOTICE '⚠️  V2 prices are already in JSON format!';
END $$;

-- Create course mapping for V2
CREATE TEMP TABLE IF NOT EXISTS v2_to_v3_course_map AS
SELECT 
  v2.id as v2_course_id,
  v3.id as v3_course_id
FROM staging.v2_restaurants_courses v2
JOIN staging.v3_courses v3 ON (
  v3.restaurant_id = staging.validate_restaurant_id(v2.restaurant_id) AND
  v3.name = v2.name AND
  v3.language = staging.language_id_to_code(v2.language_id)
);

INSERT INTO staging.v3_dishes (
  restaurant_id,
  course_id,
  sku,
  name,
  description,
  prices,
  display_order,
  is_available,
  availability_schedule,
  is_global,
  language,
  created_at,
  updated_at
)
SELECT
  staging.validate_restaurant_id(
    (SELECT restaurant_id FROM staging.v2_restaurants_courses WHERE id = d.course_id)
  ) as restaurant_id,
  map.v3_course_id as course_id,
  NULL as sku, -- V2 doesn't have SKU
  d.name,
  d.description,
  staging.safe_json_parse(d.price_j) as prices, -- V2 uses price_j (JSON)
  COALESCE(d.display_order, 0) as display_order,
  staging.yn_to_boolean(d.enabled) as is_available,
  NULL as availability_schedule,
  false as is_global,
  staging.language_id_to_code(
    (SELECT language_id FROM staging.v2_restaurants_courses WHERE id = d.course_id)
  ) as language,
  d.added_at as created_at,
  NULL as updated_at
FROM staging.v2_restaurants_dishes d
LEFT JOIN v2_to_v3_course_map map ON d.course_id = map.v2_course_id
WHERE d.name IS NOT NULL 
  AND TRIM(d.name) != ''
  AND COALESCE(d.exclude_from_v3, false) = false
  AND staging.yn_to_boolean(d.enabled) = true
  AND d.price_j IS NOT NULL
ON CONFLICT DO NOTHING;

DO $$
DECLARE
  rows_inserted INTEGER;
  total_v3_dishes INTEGER;
BEGIN
  GET DIAGNOSTICS rows_inserted = ROW_COUNT;
  SELECT COUNT(*) INTO total_v3_dishes FROM staging.v3_dishes;
  RAISE NOTICE '✅ Inserted % dishes from V2', rows_inserted;
  RAISE NOTICE '📊 Total v3_dishes now: %', total_v3_dishes;
END $$;

-- ============================================================================
-- STEP 4: Transform V2 Dish Customizations → V3 Dish Customizations
-- ============================================================================

DO $$
BEGIN
  RAISE NOTICE '🔄 Starting V2 Dish Customizations → V3 transformation...';
  RAISE NOTICE '⚠️  V2 has separate columns for each customization type';
END $$;

-- Create dish mapping
CREATE TEMP TABLE IF NOT EXISTS v2_to_v3_dish_map AS
SELECT 
  v2.id as v2_dish_id,
  v3.id as v3_dish_id
FROM staging.v2_restaurants_dishes v2
JOIN staging.v3_dishes v3 ON (
  v3.name = v2.name AND
  v3.course_id IN (
    SELECT v3c.id FROM staging.v3_courses v3c
    JOIN staging.v2_restaurants_courses v2c ON (
      v2c.id = v2.course_id AND
      v3c.restaurant_id = staging.validate_restaurant_id(v2c.restaurant_id) AND
      v3c.name = v2c.name
    )
  )
);

-- Crust/Bread customizations
INSERT INTO staging.v3_dish_customizations (
  dish_id,
  customization_type,
  ingredient_group_id,
  title,
  min_selections,
  max_selections,
  free_selections,
  display_order,
  is_required,
  created_at
)
SELECT
  dm.v3_dish_id as dish_id,
  'bread' as customization_type,
  NULL as ingredient_group_id, -- Will need separate mapping
  'Crust' as title,
  0 as min_selections,
  1 as max_selections,
  1 as free_selections,
  COALESCE(dc.crust_display_order, 0) as display_order,
  false as is_required,
  dc.added_at as created_at
FROM staging.v2_restaurants_dishes_customization dc
JOIN v2_to_v3_dish_map dm ON dc.dish_id = dm.v2_dish_id
WHERE staging.yn_to_boolean(dc.crust) = true
  AND COALESCE(dc.exclude_from_v3, false) = false
ON CONFLICT DO NOTHING;

-- Custom Ingredients (CI)
INSERT INTO staging.v3_dish_customizations (
  dish_id,
  customization_type,
  ingredient_group_id,
  title,
  min_selections,
  max_selections,
  free_selections,
  display_order,
  is_required,
  created_at
)
SELECT
  dm.v3_dish_id as dish_id,
  'ci' as customization_type,
  NULL as ingredient_group_id,
  'Toppings' as title,
  0 as min_selections,
  0 as max_selections,
  0 as free_selections,
  COALESCE(dc.custom_ingredient_display_order, 0) as display_order,
  false as is_required,
  dc.added_at as created_at
FROM staging.v2_restaurants_dishes_customization dc
JOIN v2_to_v3_dish_map dm ON dc.dish_id = dm.v2_dish_id
WHERE staging.yn_to_boolean(dc.custom_ingredient) = true
  AND COALESCE(dc.exclude_from_v3, false) = false
ON CONFLICT DO NOTHING;

-- Extras
INSERT INTO staging.v3_dish_customizations (
  dish_id,
  customization_type,
  ingredient_group_id,
  title,
  min_selections,
  max_selections,
  free_selections,
  display_order,
  is_required,
  created_at
)
SELECT
  dm.v3_dish_id as dish_id,
  'extras' as customization_type,
  NULL as ingredient_group_id,
  'Extras' as title,
  0, 0, 0,
  COALESCE(dc.extra_display_order, 0) as display_order,
  false as is_required,
  dc.added_at as created_at
FROM staging.v2_restaurants_dishes_customization dc
JOIN v2_to_v3_dish_map dm ON dc.dish_id = dm.v2_dish_id
WHERE staging.yn_to_boolean(dc.extra) = true
  AND COALESCE(dc.exclude_from_v3, false) = false
ON CONFLICT DO NOTHING;

-- Dressing
INSERT INTO staging.v3_dish_customizations (
  dish_id,
  customization_type,
  ingredient_group_id,
  title,
  min_selections,
  max_selections,
  free_selections,
  display_order,
  is_required,
  created_at
)
SELECT
  dm.v3_dish_id as dish_id,
  'dressing' as customization_type,
  NULL as ingredient_group_id,
  'Dressing' as title,
  0, 0, 0,
  COALESCE(dc.dressing_display_order, 0) as display_order,
  false as is_required,
  dc.added_at as created_at
FROM staging.v2_restaurants_dishes_customization dc
JOIN v2_to_v3_dish_map dm ON dc.dish_id = dm.v2_dish_id
WHERE staging.yn_to_boolean(dc.dressing) = true
  AND COALESCE(dc.exclude_from_v3, false) = false
ON CONFLICT DO NOTHING;

-- Sauce
INSERT INTO staging.v3_dish_customizations (
  dish_id,
  customization_type,
  ingredient_group_id,
  title,
  min_selections,
  max_selections,
  free_selections,
  display_order,
  is_required,
  created_at
)
SELECT
  dm.v3_dish_id as dish_id,
  'sauce' as customization_type,
  NULL as ingredient_group_id,
  'Sauce' as title,
  0, 0, 0,
  COALESCE(dc.sauce_display_order, 0) as display_order,
  false as is_required,
  dc.added_at as created_at
FROM staging.v2_restaurants_dishes_customization dc
JOIN v2_to_v3_dish_map dm ON dc.dish_id = dm.v2_dish_id
WHERE staging.yn_to_boolean(dc.sauce) = true
  AND COALESCE(dc.exclude_from_v3, false) = false
ON CONFLICT DO NOTHING;

-- Drinks
INSERT INTO staging.v3_dish_customizations (
  dish_id,
  customization_type,
  ingredient_group_id,
  title,
  min_selections,
  max_selections,
  free_selections,
  display_order,
  is_required,
  created_at
)
SELECT
  dm.v3_dish_id as dish_id,
  'drinks' as customization_type,
  NULL as ingredient_group_id,
  'Drinks' as title,
  0, 0, 0,
  COALESCE(dc.drink_display_order, 0) as display_order,
  false as is_required,
  dc.added_at as created_at
FROM staging.v2_restaurants_dishes_customization dc
JOIN v2_to_v3_dish_map dm ON dc.dish_id = dm.v2_dish_id
WHERE staging.yn_to_boolean(dc.drink) = true
  AND COALESCE(dc.exclude_from_v3, false) = false
ON CONFLICT DO NOTHING;

-- Side Dishes
INSERT INTO staging.v3_dish_customizations (
  dish_id,
  customization_type,
  ingredient_group_id,
  title,
  min_selections,
  max_selections,
  free_selections,
  display_order,
  is_required,
  created_at
)
SELECT
  dm.v3_dish_id as dish_id,
  'sidedish' as customization_type,
  NULL as ingredient_group_id,
  'Side Dish' as title,
  0, 0, 0,
  COALESCE(dc.side_dish_display_order, 0) as display_order,
  false as is_required,
  dc.added_at as created_at
FROM staging.v2_restaurants_dishes_customization dc
JOIN v2_to_v3_dish_map dm ON dc.dish_id = dm.v2_dish_id
WHERE staging.yn_to_boolean(dc.side_dish) = true
  AND COALESCE(dc.exclude_from_v3, false) = false
ON CONFLICT DO NOTHING;

-- Cook Method
INSERT INTO staging.v3_dish_customizations (
  dish_id,
  customization_type,
  ingredient_group_id,
  title,
  min_selections,
  max_selections,
  free_selections,
  display_order,
  is_required,
  created_at
)
SELECT
  dm.v3_dish_id as dish_id,
  'cookmethod' as customization_type,
  NULL as ingredient_group_id,
  'Cook Method' as title,
  0, 0, 0,
  COALESCE(dc.cook_method_display_order, 0) as display_order,
  false as is_required,
  dc.added_at as created_at
FROM staging.v2_restaurants_dishes_customization dc
JOIN v2_to_v3_dish_map dm ON dc.dish_id = dm.v2_dish_id
WHERE staging.yn_to_boolean(dc.cook_method) = true
  AND COALESCE(dc.exclude_from_v3, false) = false
ON CONFLICT DO NOTHING;

DO $$
DECLARE
  rows_inserted INTEGER;
BEGIN
  SELECT COUNT(*) INTO rows_inserted FROM staging.v3_dish_customizations;
  RAISE NOTICE '✅ Total v3_dish_customizations now: %', rows_inserted;
END $$;

-- ============================================================================
-- STEP 5: Transform V2 Ingredient Groups → V3
-- ============================================================================

DO $$
BEGIN
  RAISE NOTICE '🔄 Starting V2 Ingredient Groups → V3 transformation...';
END $$;

INSERT INTO staging.v3_ingredient_groups (
  restaurant_id,
  name,
  group_type,
  is_global,
  created_at
)
SELECT
  staging.validate_restaurant_id(restaurant_id) as restaurant_id,
  group_name as name,
  NULLIF(TRIM(group_type), '') as group_type,
  false as is_global,
  added_at as created_at
FROM staging.v2_restaurants_ingredient_groups
WHERE group_name IS NOT NULL 
  AND TRIM(group_name) != ''
  AND staging.yn_to_boolean(enabled) = true
  AND staging.validate_restaurant_id(restaurant_id) IS NOT NULL
ON CONFLICT DO NOTHING;

DO $$
DECLARE
  rows_inserted INTEGER;
  total_groups INTEGER;
BEGIN
  GET DIAGNOSTICS rows_inserted = ROW_COUNT;
  SELECT COUNT(*) INTO total_groups FROM staging.v3_ingredient_groups;
  RAISE NOTICE '✅ Inserted % ingredient groups from V2', rows_inserted;
  RAISE NOTICE '📊 Total v3_ingredient_groups now: %', total_groups;
END $$;

-- ============================================================================
-- STEP 6: Transform V2 Global Ingredients → V3
-- ============================================================================

DO $$
BEGIN
  RAISE NOTICE '🔄 Starting V2 Global Ingredients → V3 transformation...';
  RAISE NOTICE '⚠️  V2 global ingredients need group assignment';
END $$;

-- Note: V2 global ingredients don't have direct group linkage
-- They need to be linked via restaurants_ingredient_groups_items
-- This is complex and may need separate processing

DO $$
BEGIN
  RAISE NOTICE '⏭️  V2 global ingredients transformation pending';
  RAISE NOTICE '📝 Action required: Link via ingredient_groups_items';
END $$;

-- ============================================================================
-- STEP 7: Transform V2 Restaurant Ingredients → V3
-- ============================================================================

DO $$
BEGIN
  RAISE NOTICE '🔄 Starting V2 Restaurant Ingredients → V3 transformation...';
  RAISE NOTICE '⚠️  V2 ingredients linked via ingredient_groups_items';
END $$;

-- Note: Similar to global ingredients, restaurant ingredients
-- need to be linked via ingredient_groups_items hash mapping
-- This requires separate processing

DO $$
BEGIN
  RAISE NOTICE '⏭️  V2 restaurant ingredients transformation pending';
  RAISE NOTICE '📝 Action required: Process hash-based linkage';
END $$;

-- ============================================================================
-- CLEANUP
-- ============================================================================

DROP TABLE IF EXISTS v2_to_v3_course_map;
DROP TABLE IF EXISTS v2_to_v3_dish_map;

-- ============================================================================
-- SUMMARY
-- ============================================================================

DO $$
DECLARE
  courses_count INTEGER;
  dishes_count INTEGER;
  customizations_count INTEGER;
  ingredient_groups_count INTEGER;
  ingredients_count INTEGER;
  combo_groups_count INTEGER;
  combo_items_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO courses_count FROM staging.v3_courses;
  SELECT COUNT(*) INTO dishes_count FROM staging.v3_dishes;
  SELECT COUNT(*) INTO customizations_count FROM staging.v3_dish_customizations;
  SELECT COUNT(*) INTO ingredient_groups_count FROM staging.v3_ingredient_groups;
  SELECT COUNT(*) INTO ingredients_count FROM staging.v3_ingredients;
  SELECT COUNT(*) INTO combo_groups_count FROM staging.v3_combo_groups;
  SELECT COUNT(*) INTO combo_items_count FROM staging.v3_combo_items;
  
  RAISE NOTICE '';
  RAISE NOTICE '============================================================';
  RAISE NOTICE '✅ V2 → V3 Transformation Summary';
  RAISE NOTICE '============================================================';
  RAISE NOTICE 'Courses: % rows', courses_count;
  RAISE NOTICE 'Dishes: % rows', dishes_count;
  RAISE NOTICE 'Dish Customizations: % rows', customizations_count;
  RAISE NOTICE 'Ingredient Groups: % rows', ingredient_groups_count;
  RAISE NOTICE 'Ingredients: % rows', ingredients_count;
  RAISE NOTICE 'Combo Groups: % rows', combo_groups_count;
  RAISE NOTICE 'Combo Items: % rows', combo_items_count;
  RAISE NOTICE '';
  RAISE NOTICE '⚠️  PENDING TASKS:';
  RAISE NOTICE '1. Link V2 global_ingredients via ingredient_groups_items';
  RAISE NOTICE '2. Link V2 restaurants_ingredients via hash mapping';
  RAISE NOTICE '3. Transform V2 combo_groups (13 rows)';
  RAISE NOTICE '4. Transform V2 combo_groups_items (220 rows)';
  RAISE NOTICE '5. Link dish_customizations to ingredient_groups';
  RAISE NOTICE '';
  RAISE NOTICE '⏭️  Next: Data Validation';
  RAISE NOTICE '============================================================';
END $$;

