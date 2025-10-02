-- ============================================
-- FIX ALL MENU & CATALOG STAGING TABLES
-- Run this FIRST in Supabase SQL Editor
-- ============================================

-- Drop all existing staging tables
DROP TABLE IF EXISTS staging.v1_courses CASCADE;
DROP TABLE IF EXISTS staging.v1_combos CASCADE;
DROP TABLE IF EXISTS staging.v2_restaurants_courses CASCADE;
DROP TABLE IF EXISTS staging.v2_restaurants_dishes CASCADE;
DROP TABLE IF EXISTS staging.v2_restaurants_dishes_customization CASCADE;
DROP TABLE IF EXISTS staging.v2_restaurants_combo_groups CASCADE;
DROP TABLE IF EXISTS staging.v2_restaurants_combo_groups_items CASCADE;
DROP TABLE IF EXISTS staging.v2_restaurants_ingredient_groups CASCADE;
DROP TABLE IF EXISTS staging.v2_restaurants_ingredient_groups_items CASCADE;
DROP TABLE IF EXISTS staging.v2_restaurants_ingredients CASCADE;
DROP TABLE IF EXISTS staging.v2_global_ingredients CASCADE;

-- ============================================
-- V1 STAGING TABLES (Fixed)
-- ============================================

-- V1 Courses
CREATE TABLE staging.v1_courses (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255),
  description TEXT,
  xth_promo VARCHAR(1),
  xth_item INTEGER,
  remove_value NUMERIC,
  remove_from VARCHAR(1),
  time_period INTEGER,
  ci_header VARCHAR(255),
  restaurant_id INTEGER,
  language VARCHAR(2),
  display_order INTEGER
);

-- V1 Combos  
CREATE TABLE staging.v1_combos (
  id INTEGER PRIMARY KEY,
  dish_id INTEGER,
  group_id INTEGER,
  display_order INTEGER
);

-- ============================================
-- V2 STAGING TABLES (Fixed to match source)
-- ============================================

-- V2 Courses
CREATE TABLE staging.v2_restaurants_courses (
  id INTEGER PRIMARY KEY,
  restaurant_id INTEGER,
  language_id SMALLINT,
  global_course_id INTEGER,
  name VARCHAR(255),
  description TEXT,
  display_order SMALLINT,
  available_for TEXT,  -- JSON
  time_period INTEGER,
  enabled VARCHAR(1),
  added_by INTEGER,
  added_at TIMESTAMPTZ,
  disabled_by INTEGER,
  disabled_at TIMESTAMPTZ
);

-- V2 Dishes
CREATE TABLE staging.v2_restaurants_dishes (
  id INTEGER PRIMARY KEY,
  restaurant_id INTEGER,
  global_dish_id INTEGER,
  course_id INTEGER,
  sku VARCHAR(50),
  name VARCHAR(255),
  description TEXT,
  prices TEXT,  -- JSON
  is_popular SMALLINT,
  display_order INTEGER,
  available_for TEXT,  -- JSON
  enabled VARCHAR(1),
  language_id SMALLINT,
  added_by INTEGER,
  added_at TIMESTAMPTZ,
  disabled_by INTEGER,
  disabled_at TIMESTAMPTZ
);

-- V2 Dishes Customization
CREATE TABLE staging.v2_restaurants_dishes_customization (
  id INTEGER PRIMARY KEY,
  dish_id INTEGER,
  options TEXT,  -- JSON
  -- Bread
  use_bread SMALLINT,
  bread_config TEXT,  -- JSON
  bread_display_order SMALLINT,
  -- CI
  use_ci SMALLINT,
  ci_config TEXT,  -- JSON
  ci_display_order SMALLINT,
  -- Dressing
  use_dressing SMALLINT,
  dressing_config TEXT,  -- JSON
  dressing_display_order SMALLINT,
  -- Sauce
  use_sauce SMALLINT,
  sauce_config TEXT,  -- JSON
  sauce_display_order SMALLINT,
  -- Side dish
  use_sidedish SMALLINT,
  sidedish_config TEXT,  -- JSON
  sidedish_display_order SMALLINT,
  -- Drinks
  use_drinks SMALLINT,
  drinks_config TEXT,  -- JSON
  drinks_display_order SMALLINT,
  -- Extras
  use_extras SMALLINT,
  extras_config TEXT,  -- JSON
  extras_display_order SMALLINT,
  -- Cook method
  use_cookmethod SMALLINT,
  cookmethod_config TEXT,  -- JSON
  cookmethod_display_order SMALLINT,
  added_by INTEGER,
  added_at TIMESTAMPTZ,
  disabled_by INTEGER,
  disabled_at TIMESTAMPTZ
);

-- V2 Combo Groups
CREATE TABLE staging.v2_restaurants_combo_groups (
  id INTEGER PRIMARY KEY,
  restaurant_id INTEGER,
  language_id SMALLINT,
  group_name VARCHAR(255),
  enabled VARCHAR(1),
  added_by INTEGER,
  added_at TIMESTAMPTZ,
  disabled_by INTEGER,
  disabled_at TIMESTAMPTZ
);

-- V2 Combo Groups Items
CREATE TABLE staging.v2_restaurants_combo_groups_items (
  id INTEGER PRIMARY KEY,
  combo_group_id INTEGER,
  dish_id INTEGER,
  prices TEXT,  -- JSON
  display_order INTEGER,
  enabled VARCHAR(1),
  added_by INTEGER,
  added_at TIMESTAMPTZ,
  disabled_by INTEGER,
  disabled_at TIMESTAMPTZ
);

-- V2 Ingredient Groups
CREATE TABLE staging.v2_restaurants_ingredient_groups (
  id INTEGER PRIMARY KEY,
  restaurant_id INTEGER,
  name VARCHAR(255),
  group_type VARCHAR(50),
  is_global SMALLINT,
  enabled VARCHAR(1),
  added_by INTEGER,
  added_at TIMESTAMPTZ,
  disabled_by INTEGER,
  disabled_at TIMESTAMPTZ
);

-- V2 Ingredient Groups Items
CREATE TABLE staging.v2_restaurants_ingredient_groups_items (
  id INTEGER PRIMARY KEY,
  ingredient_group_id INTEGER,
  name VARCHAR(255),
  prices TEXT,  -- JSON
  display_order INTEGER,
  is_available SMALLINT,
  enabled VARCHAR(1),
  added_by INTEGER,
  added_at TIMESTAMPTZ,
  disabled_by INTEGER,
  disabled_at TIMESTAMPTZ
);

-- V2 Ingredients
CREATE TABLE staging.v2_restaurants_ingredients (
  id INTEGER PRIMARY KEY,
  restaurant_id INTEGER,
  global_ingredient_id INTEGER,
  name VARCHAR(255),
  prices TEXT,  -- JSON
  display_order INTEGER,
  is_available SMALLINT,
  enabled VARCHAR(1),
  added_by INTEGER,
  added_at TIMESTAMPTZ,
  disabled_by INTEGER,
  disabled_at TIMESTAMPTZ
);

-- V2 Global Ingredients
CREATE TABLE staging.v2_global_ingredients (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255),
  description TEXT,
  enabled VARCHAR(1),
  added_by INTEGER,
  added_at TIMESTAMPTZ,
  disabled_by INTEGER,
  disabled_at TIMESTAMPTZ
);

-- ============================================
-- INDEXES
-- ============================================

-- V1
CREATE INDEX idx_v1_courses_restaurant ON staging.v1_courses(restaurant_id);
CREATE INDEX idx_v1_combos_dish ON staging.v1_combos(dish_id);
CREATE INDEX idx_v1_combos_group ON staging.v1_combos(group_id);

-- V2
CREATE INDEX idx_v2_courses_restaurant ON staging.v2_restaurants_courses(restaurant_id);
CREATE INDEX idx_v2_dishes_restaurant ON staging.v2_restaurants_dishes(restaurant_id);
CREATE INDEX idx_v2_dishes_course ON staging.v2_restaurants_dishes(course_id);
CREATE INDEX idx_v2_customization_dish ON staging.v2_restaurants_dishes_customization(dish_id);
CREATE INDEX idx_v2_combo_groups_restaurant ON staging.v2_restaurants_combo_groups(restaurant_id);
CREATE INDEX idx_v2_combo_items_group ON staging.v2_restaurants_combo_groups_items(combo_group_id);
CREATE INDEX idx_v2_ingredient_groups_restaurant ON staging.v2_restaurants_ingredient_groups(restaurant_id);
CREATE INDEX idx_v2_ingredient_items_group ON staging.v2_restaurants_ingredient_groups_items(ingredient_group_id);
CREATE INDEX idx_v2_ingredients_restaurant ON staging.v2_restaurants_ingredients(restaurant_id);

-- ============================================
-- DONE!
-- ============================================

SELECT 'All staging tables fixed and ready for data loading!' as status;


