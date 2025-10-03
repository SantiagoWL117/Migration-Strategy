-- ============================================================================
-- Menu & Catalog Entity - V3 Schema Creation (STAGING)
-- ============================================================================
-- Purpose: Create clean V3 schema in staging for Menu & Catalog transformation
-- Strategy: Staging-first approach - validate before production deployment
-- Created: 2025-10-02
-- Author: Brian Lapp
-- ============================================================================

-- Ensure staging schema exists
CREATE SCHEMA IF NOT EXISTS staging;

-- ============================================================================
-- TABLE 1: COURSES (Menu Categories)
-- ============================================================================

CREATE TABLE IF NOT EXISTS staging.v3_courses (
  id SERIAL PRIMARY KEY,
  restaurant_id INTEGER, -- Will add FK constraint after validation
  name VARCHAR(255) NOT NULL,
  description TEXT,
  display_order INTEGER DEFAULT 0,
  is_global BOOLEAN DEFAULT false,
  language VARCHAR(2) DEFAULT 'en',
  
  -- Availability scheduling (from V1 timePeriod)
  availability_schedule JSONB,
  
  -- Audit timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  
  -- Data quality constraints
  CONSTRAINT v3_courses_name_not_empty CHECK (LENGTH(TRIM(name)) > 0),
  CONSTRAINT v3_courses_language_valid CHECK (language IN ('en', 'fr')),
  CONSTRAINT v3_courses_display_order_positive CHECK (display_order >= 0)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_v3_courses_restaurant ON staging.v3_courses(restaurant_id);
CREATE INDEX IF NOT EXISTS idx_v3_courses_language ON staging.v3_courses(language);
CREATE INDEX IF NOT EXISTS idx_v3_courses_display_order ON staging.v3_courses(display_order);
CREATE INDEX IF NOT EXISTS idx_v3_courses_global ON staging.v3_courses(is_global);

-- Comment
COMMENT ON TABLE staging.v3_courses IS 'Menu categories/sections - V3 unified structure from V1 courses + V2 restaurants_courses';

-- ============================================================================
-- TABLE 2: DISHES (Menu Items)
-- ============================================================================

CREATE TABLE IF NOT EXISTS staging.v3_dishes (
  id SERIAL PRIMARY KEY,
  restaurant_id INTEGER, -- Will add FK constraint after validation
  course_id INTEGER, -- Will add FK constraint to v3_courses
  sku VARCHAR(50),
  name VARCHAR(255) NOT NULL,
  description TEXT,
  
  -- Pricing structure (JSONB for flexibility)
  -- Format: {"default": "10.99"} or {"small": "10", "medium": "12", "large": "14"}
  prices JSONB NOT NULL,
  
  display_order INTEGER DEFAULT 0,
  is_available BOOLEAN DEFAULT true,
  
  -- Availability scheduling (from V1 hideOnDays deserialized)
  -- Format: {"hide_on_days": [0,6], "show_times": [{"start": "11:00", "end": "22:00"}]}
  availability_schedule JSONB,
  
  is_global BOOLEAN DEFAULT false,
  language VARCHAR(2) DEFAULT 'en',
  
  -- Audit timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  
  -- Data quality constraints
  CONSTRAINT v3_dishes_name_not_empty CHECK (LENGTH(TRIM(name)) > 0),
  CONSTRAINT v3_dishes_language_valid CHECK (language IN ('en', 'fr')),
  CONSTRAINT v3_dishes_display_order_positive CHECK (display_order >= 0),
  CONSTRAINT v3_dishes_prices_not_empty CHECK (jsonb_typeof(prices) = 'object' AND prices != '{}'::jsonb)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_v3_dishes_restaurant ON staging.v3_dishes(restaurant_id);
CREATE INDEX IF NOT EXISTS idx_v3_dishes_course ON staging.v3_dishes(course_id);
CREATE INDEX IF NOT EXISTS idx_v3_dishes_language ON staging.v3_dishes(language);
CREATE INDEX IF NOT EXISTS idx_v3_dishes_display_order ON staging.v3_dishes(display_order);
CREATE INDEX IF NOT EXISTS idx_v3_dishes_available ON staging.v3_dishes(is_available);
CREATE INDEX IF NOT EXISTS idx_v3_dishes_sku ON staging.v3_dishes(sku);
CREATE INDEX IF NOT EXISTS idx_v3_dishes_global ON staging.v3_dishes(is_global);

-- GIN index for JSONB queries
CREATE INDEX IF NOT EXISTS idx_v3_dishes_prices_gin ON staging.v3_dishes USING GIN (prices);

-- Comment
COMMENT ON TABLE staging.v3_dishes IS 'Individual menu items/dishes - V3 unified structure from V1 menu + V2 restaurants_dishes';

-- ============================================================================
-- TABLE 3: DISH CUSTOMIZATIONS (Customization Options)
-- ============================================================================

CREATE TABLE IF NOT EXISTS staging.v3_dish_customizations (
  id SERIAL PRIMARY KEY,
  dish_id INTEGER NOT NULL, -- Will add FK constraint to v3_dishes
  
  -- Customization type
  -- V1 types: 'bread', 'ci', 'sauce', 'dressing', 'extras', 'sidedish', 'drinks', 'cookmethod'
  customization_type VARCHAR(50) NOT NULL,
  
  ingredient_group_id INTEGER, -- Links to ingredient group (optional)
  
  title VARCHAR(255), -- Display title (e.g., "Choose your bread", "Select toppings")
  
  -- Selection constraints
  min_selections INTEGER DEFAULT 0,
  max_selections INTEGER DEFAULT 0,
  free_selections INTEGER DEFAULT 0, -- How many selections are free before charging
  
  display_order INTEGER DEFAULT 0,
  is_required BOOLEAN DEFAULT false,
  
  -- Audit timestamp
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Data quality constraints
  CONSTRAINT v3_dish_cust_type_valid CHECK (customization_type IN (
    'bread', 'ci', 'sauce', 'dressing', 'extras', 'sidedish', 'drinks', 'cookmethod'
  )),
  CONSTRAINT v3_dish_cust_selections_valid CHECK (
    min_selections >= 0 AND 
    max_selections >= 0 AND 
    free_selections >= 0 AND
    (max_selections = 0 OR max_selections >= min_selections)
  ),
  CONSTRAINT v3_dish_cust_display_order_positive CHECK (display_order >= 0)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_v3_dish_cust_dish ON staging.v3_dish_customizations(dish_id);
CREATE INDEX IF NOT EXISTS idx_v3_dish_cust_type ON staging.v3_dish_customizations(customization_type);
CREATE INDEX IF NOT EXISTS idx_v3_dish_cust_group ON staging.v3_dish_customizations(ingredient_group_id);
CREATE INDEX IF NOT EXISTS idx_v3_dish_cust_display_order ON staging.v3_dish_customizations(display_order);

-- Comment
COMMENT ON TABLE staging.v3_dish_customizations IS 'Dish customization options - extracted from V1 menu columns + V2 restaurants_dishes_customization';

-- ============================================================================
-- TABLE 4: INGREDIENT GROUPS (Ingredient Category/Groups)
-- ============================================================================

CREATE TABLE IF NOT EXISTS staging.v3_ingredient_groups (
  id SERIAL PRIMARY KEY,
  restaurant_id INTEGER, -- NULL for global groups
  name VARCHAR(255) NOT NULL,
  
  -- Group type matches customization_type
  -- Types: 'ci' (custom ingredients), 'sd' (side dishes), 'dr' (drinks), 
  --        'e' (extras), 'br' (bread), 'sa' (sauce), 'ds' (dressing), 'cm' (cook method)
  group_type VARCHAR(50),
  
  is_global BOOLEAN DEFAULT false,
  
  -- Audit timestamp
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Data quality constraints
  CONSTRAINT v3_ing_groups_name_not_empty CHECK (LENGTH(TRIM(name)) > 0),
  CONSTRAINT v3_ing_groups_type_valid CHECK (
    group_type IS NULL OR group_type IN ('ci', 'sd', 'dr', 'e', 'br', 'sa', 'ds', 'cm')
  )
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_v3_ing_groups_restaurant ON staging.v3_ingredient_groups(restaurant_id);
CREATE INDEX IF NOT EXISTS idx_v3_ing_groups_type ON staging.v3_ingredient_groups(group_type);
CREATE INDEX IF NOT EXISTS idx_v3_ing_groups_global ON staging.v3_ingredient_groups(is_global);

-- Comment
COMMENT ON TABLE staging.v3_ingredient_groups IS 'Ingredient group definitions - V3 unified from V1 ingredient_groups + V2 restaurants_ingredient_groups';

-- ============================================================================
-- TABLE 5: INGREDIENTS (Individual Ingredients)
-- ============================================================================

CREATE TABLE IF NOT EXISTS staging.v3_ingredients (
  id SERIAL PRIMARY KEY,
  ingredient_group_id INTEGER NOT NULL, -- Will add FK constraint to v3_ingredient_groups
  name VARCHAR(255) NOT NULL,
  
  -- Pricing structure (JSONB for flexibility)
  -- Format: {"default": "0.00"} or {"small": "1.00", "medium": "1.50", "large": "2.00"}
  prices JSONB,
  
  display_order INTEGER DEFAULT 0,
  is_available BOOLEAN DEFAULT true,
  
  -- Audit timestamp
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Data quality constraints
  CONSTRAINT v3_ingredients_name_not_empty CHECK (LENGTH(TRIM(name)) > 0),
  CONSTRAINT v3_ingredients_display_order_positive CHECK (display_order >= 0),
  CONSTRAINT v3_ingredients_prices_valid CHECK (
    prices IS NULL OR (jsonb_typeof(prices) = 'object' AND prices != '{}'::jsonb)
  )
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_v3_ingredients_group ON staging.v3_ingredients(ingredient_group_id);
CREATE INDEX IF NOT EXISTS idx_v3_ingredients_display_order ON staging.v3_ingredients(display_order);
CREATE INDEX IF NOT EXISTS idx_v3_ingredients_available ON staging.v3_ingredients(is_available);

-- GIN index for JSONB queries
CREATE INDEX IF NOT EXISTS idx_v3_ingredients_prices_gin ON staging.v3_ingredients USING GIN (prices);

-- Comment
COMMENT ON TABLE staging.v3_ingredients IS 'Individual ingredients - V3 unified from V1 ingredients + V2 restaurants_ingredients + ingredient_groups_items';

-- ============================================================================
-- TABLE 6: COMBO GROUPS (Combo Meal Definitions)
-- ============================================================================

CREATE TABLE IF NOT EXISTS staging.v3_combo_groups (
  id SERIAL PRIMARY KEY,
  restaurant_id INTEGER, -- Will add FK constraint after validation
  name VARCHAR(255) NOT NULL,
  
  -- Configuration (deserialized from V1 BLOBs or V2 JSON)
  -- Format: {"itemcount": 2, "showPizzaIcons": true, "steps": [...], "customizations": {...}}
  config JSONB,
  
  language VARCHAR(2) DEFAULT 'en',
  
  -- Audit timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  
  -- Data quality constraints
  CONSTRAINT v3_combo_groups_name_not_empty CHECK (LENGTH(TRIM(name)) > 0),
  CONSTRAINT v3_combo_groups_language_valid CHECK (language IN ('en', 'fr'))
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_v3_combo_groups_restaurant ON staging.v3_combo_groups(restaurant_id);
CREATE INDEX IF NOT EXISTS idx_v3_combo_groups_language ON staging.v3_combo_groups(language);

-- GIN index for JSONB queries
CREATE INDEX IF NOT EXISTS idx_v3_combo_groups_config_gin ON staging.v3_combo_groups USING GIN (config);

-- Comment
COMMENT ON TABLE staging.v3_combo_groups IS 'Combo meal group definitions - V3 unified from V1 combo_groups + V2 restaurants_combo_groups';

-- ============================================================================
-- TABLE 7: COMBO ITEMS (Items Within Combos)
-- ============================================================================

CREATE TABLE IF NOT EXISTS staging.v3_combo_items (
  id SERIAL PRIMARY KEY,
  combo_group_id INTEGER NOT NULL, -- Will add FK constraint to v3_combo_groups
  dish_id INTEGER, -- Will add FK constraint to v3_dishes (nullable for flexibility)
  
  display_order INTEGER DEFAULT 0,
  
  -- Customization config (which customizations are allowed, pricing overrides)
  -- Format: {"allowed_customizations": ["ci", "extras"], "price_overrides": {...}}
  customization_config JSONB,
  
  -- Data quality constraints
  CONSTRAINT v3_combo_items_display_order_positive CHECK (display_order >= 0)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_v3_combo_items_group ON staging.v3_combo_items(combo_group_id);
CREATE INDEX IF NOT EXISTS idx_v3_combo_items_dish ON staging.v3_combo_items(dish_id);
CREATE INDEX IF NOT EXISTS idx_v3_combo_items_display_order ON staging.v3_combo_items(display_order);

-- GIN index for JSONB queries
CREATE INDEX IF NOT EXISTS idx_v3_combo_items_config_gin ON staging.v3_combo_items USING GIN (customization_config);

-- Comment
COMMENT ON TABLE staging.v3_combo_items IS 'Items within combo groups - V3 unified from V1 combos + V2 restaurants_combo_groups_items';

-- ============================================================================
-- FOREIGN KEY CONSTRAINTS (Added in staging for validation)
-- ============================================================================
-- Note: These will be validated before production deployment
-- Restaurant FK will be added after Restaurant Management completion

-- Courses → Dishes
ALTER TABLE staging.v3_dishes
  DROP CONSTRAINT IF EXISTS fk_v3_dishes_course,
  ADD CONSTRAINT fk_v3_dishes_course 
  FOREIGN KEY (course_id) REFERENCES staging.v3_courses(id) ON DELETE SET NULL;

-- Dishes → Customizations
ALTER TABLE staging.v3_dish_customizations
  DROP CONSTRAINT IF EXISTS fk_v3_dish_cust_dish,
  ADD CONSTRAINT fk_v3_dish_cust_dish 
  FOREIGN KEY (dish_id) REFERENCES staging.v3_dishes(id) ON DELETE CASCADE;

-- Ingredient Groups → Customizations
ALTER TABLE staging.v3_dish_customizations
  DROP CONSTRAINT IF EXISTS fk_v3_dish_cust_ing_group,
  ADD CONSTRAINT fk_v3_dish_cust_ing_group 
  FOREIGN KEY (ingredient_group_id) REFERENCES staging.v3_ingredient_groups(id) ON DELETE SET NULL;

-- Ingredient Groups → Ingredients
ALTER TABLE staging.v3_ingredients
  DROP CONSTRAINT IF EXISTS fk_v3_ingredients_group,
  ADD CONSTRAINT fk_v3_ingredients_group 
  FOREIGN KEY (ingredient_group_id) REFERENCES staging.v3_ingredient_groups(id) ON DELETE CASCADE;

-- Combo Groups → Combo Items
ALTER TABLE staging.v3_combo_items
  DROP CONSTRAINT IF EXISTS fk_v3_combo_items_group,
  ADD CONSTRAINT fk_v3_combo_items_group 
  FOREIGN KEY (combo_group_id) REFERENCES staging.v3_combo_groups(id) ON DELETE CASCADE;

-- Dishes → Combo Items
ALTER TABLE staging.v3_combo_items
  DROP CONSTRAINT IF EXISTS fk_v3_combo_items_dish,
  ADD CONSTRAINT fk_v3_combo_items_dish 
  FOREIGN KEY (dish_id) REFERENCES staging.v3_dishes(id) ON DELETE SET NULL;

-- ============================================================================
-- VERIFICATION VIEWS (Helper views for validation)
-- ============================================================================

-- View: Orphaned dishes (dishes without valid courses)
CREATE OR REPLACE VIEW staging.v3_orphaned_dishes AS
SELECT d.id, d.name, d.course_id, d.restaurant_id
FROM staging.v3_dishes d
LEFT JOIN staging.v3_courses c ON d.course_id = c.id
WHERE d.course_id IS NOT NULL AND c.id IS NULL;

-- View: Orphaned customizations (customizations without valid dishes)
CREATE OR REPLACE VIEW staging.v3_orphaned_customizations AS
SELECT dc.id, dc.customization_type, dc.dish_id
FROM staging.v3_dish_customizations dc
LEFT JOIN staging.v3_dishes d ON dc.dish_id = d.id
WHERE d.id IS NULL;

-- View: Orphaned ingredients (ingredients without valid groups)
CREATE OR REPLACE VIEW staging.v3_orphaned_ingredients AS
SELECT i.id, i.name, i.ingredient_group_id
FROM staging.v3_ingredients i
LEFT JOIN staging.v3_ingredient_groups ig ON i.ingredient_group_id = ig.id
WHERE ig.id IS NULL;

-- View: Orphaned combo items (combo items without valid groups/dishes)
CREATE OR REPLACE VIEW staging.v3_orphaned_combo_items AS
SELECT ci.id, ci.combo_group_id, ci.dish_id
FROM staging.v3_combo_items ci
LEFT JOIN staging.v3_combo_groups cg ON ci.combo_group_id = cg.id
LEFT JOIN staging.v3_dishes d ON ci.dish_id = d.id
WHERE cg.id IS NULL OR (ci.dish_id IS NOT NULL AND d.id IS NULL);

-- View: Price validation issues
CREATE OR REPLACE VIEW staging.v3_invalid_prices AS
SELECT 'dish' as table_name, id, name, prices
FROM staging.v3_dishes
WHERE prices IS NULL 
   OR jsonb_typeof(prices) != 'object'
   OR prices = '{}'::jsonb
UNION ALL
SELECT 'ingredient' as table_name, id, name, prices
FROM staging.v3_ingredients
WHERE prices IS NOT NULL 
  AND (jsonb_typeof(prices) != 'object' OR prices = '{}'::jsonb);

-- ============================================================================
-- COMPLETION SUMMARY
-- ============================================================================

DO $$
BEGIN
  RAISE NOTICE '✅ V3 Schema Creation Complete!';
  RAISE NOTICE '';
  RAISE NOTICE '📊 Tables Created:';
  RAISE NOTICE '  1. staging.v3_courses (Menu categories)';
  RAISE NOTICE '  2. staging.v3_dishes (Menu items)';
  RAISE NOTICE '  3. staging.v3_dish_customizations (Customization options)';
  RAISE NOTICE '  4. staging.v3_ingredient_groups (Ingredient groups)';
  RAISE NOTICE '  5. staging.v3_ingredients (Individual ingredients)';
  RAISE NOTICE '  6. staging.v3_combo_groups (Combo meal definitions)';
  RAISE NOTICE '  7. staging.v3_combo_items (Items in combos)';
  RAISE NOTICE '';
  RAISE NOTICE '🔗 Foreign Key Constraints: Added with CASCADE/SET NULL rules';
  RAISE NOTICE '✅ Check Constraints: Added for data quality';
  RAISE NOTICE '📈 Performance Indexes: Created on all key columns';
  RAISE NOTICE '🔍 Verification Views: Created for validation';
  RAISE NOTICE '';
  RAISE NOTICE '⏭️  Next Step: Build transformation scripts for V1→V3 and V2→V3';
END $$;

