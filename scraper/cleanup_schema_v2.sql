-- ============================================================
-- menuca_v3 Schema Cleanup Script V2
-- ============================================================
-- Purpose: Remove outdated data and constraints, drop unused tables
-- Handles all foreign key dependencies properly
-- ============================================================

BEGIN;

DO $$ BEGIN
    RAISE NOTICE '============================================================';
    RAISE NOTICE 'Starting schema cleanup...';
    RAISE NOTICE '============================================================';
END $$;

-- ============================================================
-- STEP 1: Delete data from dependent tables first
-- ============================================================

DO $$ BEGIN
    RAISE NOTICE 'Step 1: Cleaning dependent tables...';
END $$;

-- Delete order-related data (references dishes)
DELETE FROM menuca_v3.order_items;
DELETE FROM menuca_v3.user_favorite_dishes;

-- Delete dish-related dependent data
DELETE FROM menuca_v3.dish_allergens;
DELETE FROM menuca_v3.dish_dietary_tags;
DELETE FROM menuca_v3.dish_inventory;
DELETE FROM menuca_v3.dish_size_options;
DELETE FROM menuca_v3.dish_translations;
DELETE FROM menuca_v3.dish_modifiers;
DELETE FROM menuca_v3.dish_modifier_prices_legacy;

-- Delete course translations
DELETE FROM menuca_v3.course_translations;

-- Delete modifier group translations
DELETE FROM menuca_v3.modifier_group_translations;

DO $$ BEGIN
    RAISE NOTICE 'Dependent tables cleaned.';
END $$;


-- ============================================================
-- STEP 2: Clean Core Tables (delete data, remove constraints)
-- ============================================================

-- 2.1 MODIFIER_GROUPS
-- ------------------------------------------------------------
DO $$ BEGIN
    RAISE NOTICE 'Cleaning modifier_groups table...';
END $$;

DELETE FROM menuca_v3.modifier_groups;

ALTER TABLE menuca_v3.modifier_groups
DROP CONSTRAINT IF EXISTS modifier_groups_check;

ALTER TABLE menuca_v3.modifier_groups
DROP CONSTRAINT IF EXISTS modifier_groups_min_selections_check;

ALTER TABLE menuca_v3.modifier_groups
DROP CONSTRAINT IF EXISTS valid_selection_range;

ALTER TABLE menuca_v3.modifier_groups
DROP CONSTRAINT IF EXISTS modifier_groups_dish_id_fkey;

ALTER TABLE menuca_v3.modifier_groups
DROP CONSTRAINT IF EXISTS modifier_groups_parent_modifier_id_fkey;

DO $$ BEGIN
    RAISE NOTICE 'Modifier_groups cleaned.';
END $$;


-- 2.2 DISH_PRICES
-- ------------------------------------------------------------
DO $$ BEGIN
    RAISE NOTICE 'Cleaning dish_prices table...';
END $$;

DELETE FROM menuca_v3.dish_prices;

ALTER TABLE menuca_v3.dish_prices
DROP CONSTRAINT IF EXISTS dish_prices_price_check;

ALTER TABLE menuca_v3.dish_prices
DROP CONSTRAINT IF EXISTS dish_prices_dish_id_fkey;

DO $$ BEGIN
    RAISE NOTICE 'Dish_prices cleaned.';
END $$;


-- 2.3 DISHES
-- ------------------------------------------------------------
DO $$ BEGIN
    RAISE NOTICE 'Cleaning dishes table...';
END $$;

DELETE FROM menuca_v3.dishes;

ALTER TABLE menuca_v3.dishes
DROP CONSTRAINT IF EXISTS dishes_source_system_check;

ALTER TABLE menuca_v3.dishes
DROP CONSTRAINT IF EXISTS dishes_course_id_fkey;

ALTER TABLE menuca_v3.dishes
DROP CONSTRAINT IF EXISTS dishes_restaurant_id_fkey;

ALTER TABLE menuca_v3.dishes
DROP CONSTRAINT IF EXISTS dishes_deleted_by_fkey;

DO $$ BEGIN
    RAISE NOTICE 'Dishes cleaned.';
END $$;


-- 2.4 COURSES
-- ------------------------------------------------------------
DO $$ BEGIN
    RAISE NOTICE 'Cleaning courses table...';
END $$;

DELETE FROM menuca_v3.courses;

ALTER TABLE menuca_v3.courses
DROP CONSTRAINT IF EXISTS courses_restaurant_id_name_key;

ALTER TABLE menuca_v3.courses
DROP CONSTRAINT IF EXISTS courses_source_system_check;

ALTER TABLE menuca_v3.courses
DROP CONSTRAINT IF EXISTS courses_restaurant_id_fkey;

DO $$ BEGIN
    RAISE NOTICE 'Courses cleaned.';
END $$;


-- ============================================================
-- STEP 3: Drop Unused Tables
-- ============================================================

DO $$ BEGIN
    RAISE NOTICE 'Step 3: Dropping unused tables...';
END $$;

-- Drop in correct dependency order
DROP TABLE IF EXISTS menuca_v3.dish_modifier_items CASCADE;
DROP TABLE IF EXISTS menuca_v3.dish_modifier_groups CASCADE;
DROP TABLE IF EXISTS menuca_v3.ingredient_group_items CASCADE;
DROP TABLE IF EXISTS menuca_v3.dish_ingredients CASCADE;
DROP TABLE IF EXISTS menuca_v3.ingredient_groups CASCADE;
DROP TABLE IF EXISTS menuca_v3.ingredients CASCADE;
DROP TABLE IF EXISTS menuca_v3.combo_items CASCADE;
DROP TABLE IF EXISTS menuca_v3.combo_groups CASCADE;

DO $$ BEGIN
    RAISE NOTICE 'Tables dropped.';
END $$;


-- ============================================================
-- SUMMARY
-- ============================================================

DO $$ BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '============================================================';
    RAISE NOTICE 'Schema cleanup completed successfully!';
    RAISE NOTICE '============================================================';
    RAISE NOTICE '';
    RAISE NOTICE 'DATA DELETED FROM:';
    RAISE NOTICE '  Core tables:';
    RAISE NOTICE '    - courses';
    RAISE NOTICE '    - dishes';
    RAISE NOTICE '    - dish_prices';
    RAISE NOTICE '    - modifier_groups';
    RAISE NOTICE '  Dependent tables:';
    RAISE NOTICE '    - order_items';
    RAISE NOTICE '    - user_favorite_dishes';
    RAISE NOTICE '    - dish_allergens';
    RAISE NOTICE '    - dish_dietary_tags';
    RAISE NOTICE '    - dish_inventory';
    RAISE NOTICE '    - dish_size_options';
    RAISE NOTICE '    - dish_translations';
    RAISE NOTICE '    - dish_modifiers';
    RAISE NOTICE '    - course_translations';
    RAISE NOTICE '    - modifier_group_translations';
    RAISE NOTICE '';
    RAISE NOTICE 'CONSTRAINTS REMOVED FROM:';
    RAISE NOTICE '  - courses (unique, check, FK)';
    RAISE NOTICE '  - dishes (check, FK)';
    RAISE NOTICE '  - dish_prices (check, FK)';
    RAISE NOTICE '  - modifier_groups (check, FK)';
    RAISE NOTICE '';
    RAISE NOTICE 'TABLES DROPPED:';
    RAISE NOTICE '  - dish_modifier_groups';
    RAISE NOTICE '  - dish_modifier_items';
    RAISE NOTICE '  - ingredients';
    RAISE NOTICE '  - ingredient_groups';
    RAISE NOTICE '  - ingredient_group_items';
    RAISE NOTICE '  - dish_ingredients';
    RAISE NOTICE '  - combo_groups';
    RAISE NOTICE '  - combo_items';
    RAISE NOTICE '============================================================';
END $$;

COMMIT;
