-- ============================================================================
-- Menu & Catalog Entity - V1 → V3 Transformation
-- ============================================================================
-- Purpose: Transform and load clean V1 data into V3 staging schema
-- Strategy: Use helper functions, apply exclusion filters, normalize data
-- Created: 2025-10-02
-- Author: Brian Lapp
-- ============================================================================

-- ============================================================================
-- STEP 1: Transform V1 Courses → V3 Courses
-- ============================================================================

DO $$
BEGIN
  RAISE NOTICE '🔄 Starting V1 Courses → V3 Courses transformation...';
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
  false as is_global, -- V1 courses are restaurant-specific
  staging.normalize_language(language) as language,
  staging.create_availability_schedule(time_period) as availability_schedule,
  NOW() as created_at,
  NULL as updated_at
FROM staging.v1_courses
WHERE name IS NOT NULL 
  AND TRIM(name) != ''
  AND staging.validate_restaurant_id(restaurant_id) IS NOT NULL;

DO $$
DECLARE
  rows_inserted INTEGER;
BEGIN
  GET DIAGNOSTICS rows_inserted = ROW_COUNT;
  RAISE NOTICE '✅ Inserted % courses from V1', rows_inserted;
END $$;

-- ============================================================================
-- STEP 2: Transform V1 Ingredient Groups → V3 Ingredient Groups
-- ============================================================================

DO $$
BEGIN
  RAISE NOTICE '🔄 Starting V1 Ingredient Groups → V3 Ingredient Groups transformation...';
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
  name,
  staging.map_customization_type(group_type) as group_type,
  staging.yn_to_boolean(is_global) as is_global,
  NOW() as created_at
FROM staging.v1_ingredient_groups
WHERE name IS NOT NULL 
  AND TRIM(name) != '';

DO $$
DECLARE
  rows_inserted INTEGER;
BEGIN
  GET DIAGNOSTICS rows_inserted = ROW_COUNT;
  RAISE NOTICE '✅ Inserted % ingredient groups from V1', rows_inserted;
END $$;

-- ============================================================================
-- STEP 3: Transform V1 Ingredients → V3 Ingredients
-- ============================================================================

DO $$
BEGIN
  RAISE NOTICE '🔄 Starting V1 Ingredients → V3 Ingredients transformation...';
  RAISE NOTICE '⚠️  Note: This requires ingredient_group mapping from V1';
  RAISE NOTICE '⚠️  V1 ingredients are linked via ingredient_groups.item BLOB';
  RAISE NOTICE '⚠️  This step may require manual mapping or BLOB deserialization';
END $$;

-- Note: V1 ingredients linking is complex because:
-- - ingredient_groups.item contains PHP serialized array of ingredient IDs
-- - We need to deserialize this to create proper FK relationships
-- - This may require external script (Python/PHP) or manual mapping
--
-- For now, we'll load ingredients without group assignment
-- and handle linking separately

-- INSERT INTO staging.v3_ingredients (
--   ingredient_group_id,
--   name,
--   prices,
--   display_order,
--   is_available,
--   created_at
-- )
-- SELECT
--   NULL as ingredient_group_id, -- Will be updated after BLOB deserialization
--   name,
--   staging.parse_price_to_jsonb(price) as prices,
--   COALESCE(display_order::INTEGER, 0) as display_order,
--   true as is_available,
--   NOW() as created_at
-- FROM staging.v1_ingredients
-- WHERE name IS NOT NULL 
--   AND TRIM(name) != '';

DO $$
BEGIN
  RAISE NOTICE '⏭️  V1 Ingredients transformation skipped - requires BLOB deserialization';
  RAISE NOTICE '📝 Action required: Process ingredient_groups.item BLOB field';
END $$;

-- ============================================================================
-- STEP 4: Transform V1 Menu → V3 Dishes
-- ============================================================================

DO $$
BEGIN
  RAISE NOTICE '🔄 Starting V1 Menu → V3 Dishes transformation...';
  RAISE NOTICE '⚠️  Applying exclusion filter (exclude_from_v3 = FALSE)';
END $$;

-- Create temporary mapping table for V1 courses to V3 courses
CREATE TEMP TABLE IF NOT EXISTS v1_to_v3_course_map AS
SELECT 
  v1.id as v1_course_id,
  v3.id as v3_course_id
FROM staging.v1_courses v1
JOIN staging.v3_courses v3 ON (
  v3.restaurant_id = staging.validate_restaurant_id(v1.restaurant_id) AND
  v3.name = v1.name AND
  v3.language = staging.normalize_language(v1.language)
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
  staging.validate_restaurant_id(m.restaurant) as restaurant_id,
  map.v3_course_id as course_id,
  m.sku,
  m.name,
  m.ingredients as description,
  staging.parse_price_to_jsonb(m.price) as prices,
  COALESCE(m.order, 0) as display_order,
  staging.yn_to_boolean(m.showinmenu) as is_available,
  NULL as availability_schedule, -- hideOnDays BLOB requires deserialization
  false as is_global,
  staging.normalize_language(m.lang) as language,
  NOW() as created_at,
  NULL as updated_at
FROM staging.v1_menu m
LEFT JOIN v1_to_v3_course_map map ON m.course = map.v1_course_id
WHERE m.name IS NOT NULL 
  AND TRIM(m.name) != ''
  AND COALESCE(m.exclude_from_v3, false) = false -- Apply exclusion filter
  AND staging.validate_restaurant_id(m.restaurant) IS NOT NULL;

DO $$
DECLARE
  rows_inserted INTEGER;
BEGIN
  GET DIAGNOSTICS rows_inserted = ROW_COUNT;
  RAISE NOTICE '✅ Inserted % dishes from V1 (clean data only)', rows_inserted;
END $$;

-- ============================================================================
-- STEP 5: Transform V1 Combo Groups → V3 Combo Groups
-- ============================================================================

DO $$
BEGIN
  RAISE NOTICE '🔄 Starting V1 Combo Groups → V3 Combo Groups transformation...';
  RAISE NOTICE '⚠️  V1 combo_groups contain BLOB fields (dish, options, group_data)';
  RAISE NOTICE '⚠️  BLOB deserialization required for complete transformation';
END $$;

-- Load basic combo group info (without BLOB data)
INSERT INTO staging.v3_combo_groups (
  restaurant_id,
  name,
  config,
  language,
  created_at,
  updated_at
)
SELECT
  staging.validate_restaurant_id(restaurant_id) as restaurant_id,
  name,
  NULL as config, -- BLOB 'options' requires deserialization
  staging.normalize_language(language) as language,
  NOW() as created_at,
  NULL as updated_at
FROM staging.v1_combo_groups
WHERE name IS NOT NULL 
  AND TRIM(name) != ''
  AND staging.validate_restaurant_id(restaurant_id) IS NOT NULL;

DO $$
DECLARE
  rows_inserted INTEGER;
BEGIN
  GET DIAGNOSTICS rows_inserted = ROW_COUNT;
  RAISE NOTICE '✅ Inserted % combo groups from V1 (basic info only)', rows_inserted;
  RAISE NOTICE '📝 Action required: Deserialize combo_groups BLOB fields (dish, options, group_data)';
END $$;

-- ============================================================================
-- STEP 6: Transform V1 Combos → V3 Combo Items
-- ============================================================================

DO $$
BEGIN
  RAISE NOTICE '🔄 Starting V1 Combos → V3 Combo Items transformation...';
END $$;

-- Create temporary mapping tables
CREATE TEMP TABLE IF NOT EXISTS v1_to_v3_dish_map AS
SELECT 
  v1.id as v1_dish_id,
  v3.id as v3_dish_id
FROM staging.v1_menu v1
JOIN staging.v3_dishes v3 ON (
  v3.restaurant_id = staging.validate_restaurant_id(v1.restaurant) AND
  v3.name = v1.name AND
  v3.language = staging.normalize_language(v1.lang)
);

CREATE TEMP TABLE IF NOT EXISTS v1_to_v3_combo_group_map AS
SELECT 
  v1.id as v1_combo_group_id,
  v3.id as v3_combo_group_id
FROM staging.v1_combo_groups v1
JOIN staging.v3_combo_groups v3 ON (
  v3.restaurant_id = staging.validate_restaurant_id(v1.restaurant_id) AND
  v3.name = v1.name AND
  v3.language = staging.normalize_language(v1.language)
);

INSERT INTO staging.v3_combo_items (
  combo_group_id,
  dish_id,
  display_order,
  customization_config
)
SELECT
  cgm.v3_combo_group_id as combo_group_id,
  dm.v3_dish_id as dish_id,
  COALESCE(c.display_order, 0) as display_order,
  NULL as customization_config
FROM staging.v1_combos c
JOIN v1_to_v3_combo_group_map cgm ON c.group_id = cgm.v1_combo_group_id
LEFT JOIN v1_to_v3_dish_map dm ON c.dish_id = dm.v1_dish_id
WHERE cgm.v3_combo_group_id IS NOT NULL;

DO $$
DECLARE
  rows_inserted INTEGER;
BEGIN
  GET DIAGNOSTICS rows_inserted = ROW_COUNT;
  RAISE NOTICE '✅ Inserted % combo items from V1', rows_inserted;
END $$;

-- ============================================================================
-- STEP 7: Extract Dish Customizations from V1 Menu
-- ============================================================================

DO $$
BEGIN
  RAISE NOTICE '🔄 Starting V1 Menu Customizations → V3 Dish Customizations extraction...';
  RAISE NOTICE '⚠️  Extracting from denormalized V1 menu columns';
END $$;

-- Note: This would be a complex multi-step process to:
-- 1. Read each dish's customization flags (hasBread, hasCI, etc.)
-- 2. Create corresponding v3_dish_customizations records
-- 3. Link to appropriate ingredient_groups
--
-- This requires careful mapping and may need manual verification

DO $$
BEGIN
  RAISE NOTICE '⏭️  V1 dish customizations extraction pending';
  RAISE NOTICE '📝 Action required: Build customization extraction query';
  RAISE NOTICE '📝 Action required: Map to v3_ingredient_groups';
END $$;

-- ============================================================================
-- CLEANUP
-- ============================================================================

-- Drop temporary mapping tables
DROP TABLE IF EXISTS v1_to_v3_course_map;
DROP TABLE IF EXISTS v1_to_v3_dish_map;
DROP TABLE IF EXISTS v1_to_v3_combo_group_map;

-- ============================================================================
-- SUMMARY
-- ============================================================================

DO $$
DECLARE
  courses_count INTEGER;
  dishes_count INTEGER;
  ingredient_groups_count INTEGER;
  combo_groups_count INTEGER;
  combo_items_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO courses_count FROM staging.v3_courses;
  SELECT COUNT(*) INTO dishes_count FROM staging.v3_dishes;
  SELECT COUNT(*) INTO ingredient_groups_count FROM staging.v3_ingredient_groups;
  SELECT COUNT(*) INTO combo_groups_count FROM staging.v3_combo_groups;
  SELECT COUNT(*) INTO combo_items_count FROM staging.v3_combo_items;
  
  RAISE NOTICE '';
  RAISE NOTICE '============================================================';
  RAISE NOTICE '✅ V1 → V3 Transformation Summary';
  RAISE NOTICE '============================================================';
  RAISE NOTICE 'Courses: % rows', courses_count;
  RAISE NOTICE 'Dishes: % rows', dishes_count;
  RAISE NOTICE 'Ingredient Groups: % rows', ingredient_groups_count;
  RAISE NOTICE 'Combo Groups: % rows', combo_groups_count;
  RAISE NOTICE 'Combo Items: % rows', combo_items_count;
  RAISE NOTICE '';
  RAISE NOTICE '⚠️  PENDING TASKS:';
  RAISE NOTICE '1. Deserialize V1 ingredient_groups.item BLOB → link ingredients';
  RAISE NOTICE '2. Deserialize V1 menu.hideOnDays BLOB → availability_schedule';
  RAISE NOTICE '3. Deserialize V1 combo_groups BLOBs (dish, options, group_data)';
  RAISE NOTICE '4. Extract V1 menu customization columns → v3_dish_customizations';
  RAISE NOTICE '5. Deserialize V1 menuothers.content BLOB → ingredients/prices';
  RAISE NOTICE '';
  RAISE NOTICE '⏭️  Next: V2 → V3 Transformation';
  RAISE NOTICE '============================================================';
END $$;

