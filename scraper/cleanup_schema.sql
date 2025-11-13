-- ============================================================
-- menuca_v3 Schema Cleanup Script
-- ============================================================
-- Purpose: Remove outdated data and constraints, drop unused tables
--
-- Part 1: Delete data from core tables and remove constraints
-- Part 2: Drop tables that are no longer needed
-- ============================================================

BEGIN;

-- ============================================================
-- PART 1: Clean Core Tables (keep structure, remove data/constraints)
-- ============================================================

-- 1. COURSES: Delete all data and remove constraints
-- ------------------------------------------------------------
DO $$ BEGIN
    RAISE NOTICE 'Cleaning courses table...';
END $$;

-- Delete all data
DELETE FROM menuca_v3.courses;

-- Remove unique constraint on (restaurant_id, name)
ALTER TABLE menuca_v3.courses
DROP CONSTRAINT IF EXISTS courses_restaurant_id_name_key;

-- Remove check constraint on source_system
ALTER TABLE menuca_v3.courses
DROP CONSTRAINT IF EXISTS courses_source_system_check;

-- Remove foreign key constraint
ALTER TABLE menuca_v3.courses
DROP CONSTRAINT IF EXISTS courses_restaurant_id_fkey;

DO $$ BEGIN
    RAISE NOTICE 'Courses table cleaned.';
END $$;


-- 2. DISHES: Delete all data and remove constraints
-- ------------------------------------------------------------
DO $$ BEGIN
    RAISE NOTICE 'Cleaning dishes table...';
END $$;

-- First, need to handle foreign key references
-- Option 1: Delete related order_items first
DELETE FROM menuca_v3.order_items;

-- Option 2: Or we could temporarily disable triggers, but CASCADE delete is safer
-- Now delete all dishes
DELETE FROM menuca_v3.dishes;

-- Remove check constraint on source_system
ALTER TABLE menuca_v3.dishes
DROP CONSTRAINT IF EXISTS dishes_source_system_check;

-- Remove foreign key constraints
ALTER TABLE menuca_v3.dishes
DROP CONSTRAINT IF EXISTS dishes_course_id_fkey;

ALTER TABLE menuca_v3.dishes
DROP CONSTRAINT IF EXISTS dishes_restaurant_id_fkey;

ALTER TABLE menuca_v3.dishes
DROP CONSTRAINT IF EXISTS dishes_deleted_by_fkey;

DO $$ BEGIN
    RAISE NOTICE 'Dishes table cleaned.';
END $$;


-- 3. DISH_PRICES: Delete all data and remove constraints
-- ------------------------------------------------------------
DO $$ BEGIN
    RAISE NOTICE 'Cleaning dish_prices table...';
END $$;

-- Delete all data
DELETE FROM menuca_v3.dish_prices;

-- Remove check constraint on price
ALTER TABLE menuca_v3.dish_prices
DROP CONSTRAINT IF EXISTS dish_prices_price_check;

-- Remove foreign key constraint
ALTER TABLE menuca_v3.dish_prices
DROP CONSTRAINT IF EXISTS dish_prices_dish_id_fkey;

DO $$ BEGIN
    RAISE NOTICE 'Dish_prices table cleaned.';
END $$;


-- 4. MODIFIER_GROUPS: Delete all data and remove constraints
-- ------------------------------------------------------------
DO $$ BEGIN
    RAISE NOTICE 'Cleaning modifier_groups table...';
END $$;

-- Delete all data
DELETE FROM menuca_v3.modifier_groups;

-- Remove check constraints
ALTER TABLE menuca_v3.modifier_groups
DROP CONSTRAINT IF EXISTS modifier_groups_check;

ALTER TABLE menuca_v3.modifier_groups
DROP CONSTRAINT IF EXISTS modifier_groups_min_selections_check;

ALTER TABLE menuca_v3.modifier_groups
DROP CONSTRAINT IF EXISTS valid_selection_range;

-- Remove foreign key constraints
ALTER TABLE menuca_v3.modifier_groups
DROP CONSTRAINT IF EXISTS modifier_groups_dish_id_fkey;

ALTER TABLE menuca_v3.modifier_groups
DROP CONSTRAINT IF EXISTS modifier_groups_parent_modifier_id_fkey;

DO $$ BEGIN
    RAISE NOTICE 'Modifier_groups table cleaned.';
END $$;


-- ============================================================
-- PART 2: Drop Tables (completely remove from schema)
-- ============================================================

-- Drop tables in correct order (child tables first to avoid FK errors)
-- ------------------------------------------------------------

DO $$ BEGIN
    RAISE NOTICE 'Dropping tables...';
END $$;

-- Drop dish_modifier_items (child of dish_modifier_groups)
DROP TABLE IF EXISTS menuca_v3.dish_modifier_items CASCADE;

-- Drop dish_modifier_groups
DROP TABLE IF EXISTS menuca_v3.dish_modifier_groups CASCADE;

-- Drop ingredient_group_items (child of ingredient_groups)
DROP TABLE IF EXISTS menuca_v3.ingredient_group_items CASCADE;

-- Drop dish_ingredients (junction table)
DROP TABLE IF EXISTS menuca_v3.dish_ingredients CASCADE;

-- Drop ingredient_groups
DROP TABLE IF EXISTS menuca_v3.ingredient_groups CASCADE;

-- Drop ingredients
DROP TABLE IF EXISTS menuca_v3.ingredients CASCADE;

-- Drop combo_items (child of combo_groups)
DROP TABLE IF EXISTS menuca_v3.combo_items CASCADE;

-- Drop combo_groups
DROP TABLE IF EXISTS menuca_v3.combo_groups CASCADE;


-- ============================================================
-- SUMMARY
-- ============================================================

DO $$ BEGIN
    RAISE NOTICE '============================================================';
    RAISE NOTICE 'Schema cleanup completed successfully!';
    RAISE NOTICE '============================================================';
    RAISE NOTICE '';
    RAISE NOTICE 'DATA DELETED FROM:';
    RAISE NOTICE '  - courses';
    RAISE NOTICE '  - dishes';
    RAISE NOTICE '  - dish_prices';
    RAISE NOTICE '  - modifier_groups';
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
