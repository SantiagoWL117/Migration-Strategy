-- Menu & Catalog Staging Tables Migration
-- Run this in Supabase SQL Editor: https://supabase.com/dashboard/project/nthpbtdjhhnwfxqsxbvy/sql/new
-- These staging tables will hold V1 and V2 data before transformation to menuca_v3

-- ============================================
-- V1 STAGING TABLES
-- ============================================

-- V1 Courses (Menu Categories)
CREATE TABLE IF NOT EXISTS staging.v1_courses (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255),
  description TEXT,
  restaurant_id INTEGER,
  language VARCHAR(2),
  display_order INTEGER,
  time_period INTEGER,
  ci_header VARCHAR(255),
  xth_promo VARCHAR(1),
  xth_item INTEGER,
  remove_value NUMERIC,
  remove_from VARCHAR(10)
);

-- V1 Menu (Dishes)
CREATE TABLE IF NOT EXISTS staging.v1_menu (
  id INTEGER PRIMARY KEY,
  course_id INTEGER,
  restaurant_id INTEGER,
  sku VARCHAR(50),
  name VARCHAR(255),
  ingredients TEXT,
  price VARCHAR(255), -- Will parse comma-separated
  display_order INTEGER,
  quantity VARCHAR(255),
  language VARCHAR(2),
  show_in_menu VARCHAR(1),
  hide_on_days TEXT, -- BLOB/TEXT for deserialization
  image VARCHAR(255),
  menu_type VARCHAR(125),
  has_customisation VARCHAR(1),
  -- Bread customization
  has_bread VARCHAR(1),
  bread_header VARCHAR(255),
  display_order_bread SMALLINT,
  -- CI (Custom Ingredients) customization
  ci_header VARCHAR(255),
  min_ci SMALLINT,
  max_ci SMALLINT,
  free_ci SMALLINT,
  display_order_ci SMALLINT,
  -- Dressing customization
  has_dressing VARCHAR(1),
  dressing_header VARCHAR(255),
  min_dressing SMALLINT,
  max_dressing SMALLINT,
  free_dressing SMALLINT,
  display_order_dressing SMALLINT,
  -- Sauce customization
  has_sauce VARCHAR(1),
  sauce_header VARCHAR(255),
  min_sauce SMALLINT,
  max_sauce SMALLINT,
  free_sauce SMALLINT,
  display_order_sauce SMALLINT,
  -- Side dish customization
  has_side_dish VARCHAR(1),
  side_dish_header VARCHAR(255),
  min_sd SMALLINT,
  max_sd SMALLINT,
  free_sd SMALLINT,
  display_order_sd SMALLINT,
  is_side_dish VARCHAR(1),
  show_sd_in_menu VARCHAR(1),
  -- Drinks customization
  has_drinks VARCHAR(1),
  drinks_header VARCHAR(255),
  min_drink VARCHAR(25),
  max_drink VARCHAR(25),
  free_drink VARCHAR(25),
  display_order_drink SMALLINT,
  is_drink VARCHAR(1),
  -- Extras customization
  has_extras VARCHAR(1),
  extra_header VARCHAR(255),
  min_extras SMALLINT,
  max_extras SMALLINT,
  free_extra SMALLINT,
  display_order_extras SMALLINT,
  -- Cook method customization
  has_cook_method VARCHAR(1),
  cm_header VARCHAR(255),
  min_cm INTEGER,
  max_cm INTEGER,
  free_cm INTEGER,
  display_order_cm INTEGER,
  -- Combo
  is_combo VARCHAR(1),
  use_steps VARCHAR(1),
  min_combo SMALLINT,
  max_combo SMALLINT,
  display_order_combo SMALLINT,
  show_pizza_icons VARCHAR(1)
);

-- V1 Menu Others (Side dishes, drinks, extras)
CREATE TABLE IF NOT EXISTS staging.v1_menuothers (
  id INTEGER PRIMARY KEY,
  restaurant_id INTEGER,
  dish_id INTEGER,
  content TEXT, -- PHP serialized BLOB
  type VARCHAR(2), -- 'ci', 'sd', 'dr', 'e', 'br', 'sa', 'ds', 'cm'
  group_id INTEGER
);

-- V1 Combo Groups
CREATE TABLE IF NOT EXISTS staging.v1_combo_groups (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255),
  dish TEXT, -- PHP serialized BLOB - array of dish IDs
  options TEXT, -- PHP serialized BLOB - configuration
  group_data TEXT, -- PHP serialized BLOB - ingredient pricing
  restaurant_id INTEGER,
  language VARCHAR(2)
);

-- V1 Combos (Combo Items)
CREATE TABLE IF NOT EXISTS staging.v1_combos (
  id INTEGER PRIMARY KEY,
  dish_id INTEGER,
  group_id INTEGER,
  display_order INTEGER
);

-- V1 Ingredient Groups
CREATE TABLE IF NOT EXISTS staging.v1_ingredient_groups (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255),
  group_type VARCHAR(2), -- 'ci', 'sd', 'dr', 'e', 'br', 'sa', 'ds', 'cm'
  course_id SMALLINT,
  dish_id SMALLINT,
  item TEXT, -- PHP serialized BLOB - array of ingredient IDs
  price TEXT, -- PHP serialized or text prices
  restaurant_id INTEGER,
  language VARCHAR(2),
  use_in_combo VARCHAR(1),
  is_global VARCHAR(1)
);

-- V1 Ingredients
CREATE TABLE IF NOT EXISTS staging.v1_ingredients (
  id INTEGER PRIMARY KEY,
  restaurant_id INTEGER,
  name VARCHAR(255),
  price VARCHAR(255), -- Comma-separated prices
  language VARCHAR(2),
  type VARCHAR(255),
  display_order VARCHAR(255),
  available_for VARCHAR(255)
);

-- ============================================
-- V2 STAGING TABLES
-- ============================================

-- V2 Restaurants Courses
CREATE TABLE IF NOT EXISTS staging.v2_restaurants_courses (
  id INTEGER PRIMARY KEY,
  restaurant_id INTEGER,
  name VARCHAR(255),
  description TEXT,
  time_period_id SMALLINT,
  course_header VARCHAR(255),
  display_order INTEGER,
  language_id SMALLINT,
  is_global SMALLINT,
  created_by INTEGER,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ
);

-- V2 Restaurants Dishes
CREATE TABLE IF NOT EXISTS staging.v2_restaurants_dishes (
  id INTEGER PRIMARY KEY,
  restaurant_id INTEGER,
  course_id INTEGER,
  sku VARCHAR(50),
  name VARCHAR(255),
  description TEXT,
  prices TEXT, -- JSON format
  is_popular SMALLINT,
  display_order INTEGER,
  is_available SMALLINT,
  language_id SMALLINT,
  is_global SMALLINT,
  created_by INTEGER,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ
);

-- V2 Restaurants Dishes Customization
CREATE TABLE IF NOT EXISTS staging.v2_restaurants_dishes_customization (
  id INTEGER PRIMARY KEY,
  dish_id INTEGER,
  options TEXT, -- JSON
  -- Bread
  use_bread SMALLINT,
  bread_config TEXT, -- JSON
  bread_display_order SMALLINT,
  -- CI (Custom Ingredients)
  use_ci SMALLINT,
  ci_config TEXT, -- JSON
  ci_display_order SMALLINT,
  -- Dressing
  use_dressing SMALLINT,
  dressing_config TEXT, -- JSON
  dressing_display_order SMALLINT,
  -- Sauce
  use_sauce SMALLINT,
  sauce_config TEXT, -- JSON
  sauce_display_order SMALLINT,
  -- Side dish
  use_sidedish SMALLINT,
  sidedish_config TEXT, -- JSON
  sidedish_display_order SMALLINT,
  -- Drinks
  use_drinks SMALLINT,
  drinks_config TEXT, -- JSON
  drinks_display_order SMALLINT,
  -- Extras
  use_extras SMALLINT,
  extras_config TEXT, -- JSON
  extras_display_order SMALLINT,
  -- Cook method
  use_cookmethod SMALLINT,
  cookmethod_config TEXT, -- JSON
  cookmethod_display_order SMALLINT,
  created_by INTEGER,
  created_at TIMESTAMPTZ,
  updated_by INTEGER,
  updated_at TIMESTAMPTZ
);

-- V2 Restaurants Combo Groups
CREATE TABLE IF NOT EXISTS staging.v2_restaurants_combo_groups (
  id INTEGER PRIMARY KEY,
  restaurant_id INTEGER,
  name VARCHAR(255),
  config TEXT, -- JSON
  language_id SMALLINT,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ
);

-- V2 Restaurants Combo Groups Items
CREATE TABLE IF NOT EXISTS staging.v2_restaurants_combo_groups_items (
  id INTEGER PRIMARY KEY,
  combo_group_id INTEGER,
  dish_id INTEGER,
  prices TEXT, -- JSON
  display_order INTEGER
);

-- V2 Restaurants Ingredient Groups
CREATE TABLE IF NOT EXISTS staging.v2_restaurants_ingredient_groups (
  id INTEGER PRIMARY KEY,
  restaurant_id INTEGER,
  name VARCHAR(255),
  group_type VARCHAR(50),
  is_global SMALLINT,
  created_at TIMESTAMPTZ
);

-- V2 Restaurants Ingredient Groups Items
CREATE TABLE IF NOT EXISTS staging.v2_restaurants_ingredient_groups_items (
  id INTEGER PRIMARY KEY,
  ingredient_group_id INTEGER,
  name VARCHAR(255),
  prices TEXT, -- JSON
  display_order INTEGER,
  is_available SMALLINT
);

-- V2 Restaurants Ingredients
CREATE TABLE IF NOT EXISTS staging.v2_restaurants_ingredients (
  id INTEGER PRIMARY KEY,
  restaurant_id INTEGER,
  name VARCHAR(255),
  prices TEXT, -- JSON
  display_order INTEGER,
  is_available SMALLINT,
  created_at TIMESTAMPTZ
);

-- V2 Custom Ingredients
CREATE TABLE IF NOT EXISTS staging.v2_custom_ingredients (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255),
  description TEXT,
  created_at TIMESTAMPTZ
);

-- V2 Global Courses
CREATE TABLE IF NOT EXISTS staging.v2_global_courses (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255),
  description TEXT,
  created_at TIMESTAMPTZ
);

-- V2 Global Dishes
CREATE TABLE IF NOT EXISTS staging.v2_global_dishes (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255),
  description TEXT,
  created_at TIMESTAMPTZ
);

-- V2 Global Ingredients
CREATE TABLE IF NOT EXISTS staging.v2_global_ingredients (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255),
  description TEXT,
  created_at TIMESTAMPTZ
);

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================

-- V1 Indexes
CREATE INDEX IF NOT EXISTS idx_v1_courses_restaurant ON staging.v1_courses(restaurant_id);
CREATE INDEX IF NOT EXISTS idx_v1_menu_restaurant ON staging.v1_menu(restaurant_id);
CREATE INDEX IF NOT EXISTS idx_v1_menu_course ON staging.v1_menu(course_id);
CREATE INDEX IF NOT EXISTS idx_v1_menuothers_dish ON staging.v1_menuothers(dish_id);
CREATE INDEX IF NOT EXISTS idx_v1_menuothers_restaurant ON staging.v1_menuothers(restaurant_id);
CREATE INDEX IF NOT EXISTS idx_v1_combo_groups_restaurant ON staging.v1_combo_groups(restaurant_id);
CREATE INDEX IF NOT EXISTS idx_v1_ingredient_groups_restaurant ON staging.v1_ingredient_groups(restaurant_id);
CREATE INDEX IF NOT EXISTS idx_v1_ingredients_restaurant ON staging.v1_ingredients(restaurant_id);

-- V2 Indexes
CREATE INDEX IF NOT EXISTS idx_v2_courses_restaurant ON staging.v2_restaurants_courses(restaurant_id);
CREATE INDEX IF NOT EXISTS idx_v2_dishes_restaurant ON staging.v2_restaurants_dishes(restaurant_id);
CREATE INDEX IF NOT EXISTS idx_v2_dishes_course ON staging.v2_restaurants_dishes(course_id);
CREATE INDEX IF NOT EXISTS idx_v2_customization_dish ON staging.v2_restaurants_dishes_customization(dish_id);
CREATE INDEX IF NOT EXISTS idx_v2_combo_groups_restaurant ON staging.v2_restaurants_combo_groups(restaurant_id);
CREATE INDEX IF NOT EXISTS idx_v2_ingredient_groups_restaurant ON staging.v2_restaurants_ingredient_groups(restaurant_id);

-- ============================================
-- VERIFICATION
-- ============================================

-- Verify tables created
SELECT 
  schemaname, 
  tablename, 
  'Created' as status
FROM pg_tables 
WHERE schemaname = 'staging' 
  AND tablename LIKE 'v1_%' 
  OR tablename LIKE 'v2_%'
ORDER BY tablename;
