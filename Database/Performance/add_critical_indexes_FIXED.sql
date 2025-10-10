-- ============================================================================
-- MenuCA V3 - Critical Index Creation Script (FIXED VERSION)
-- ============================================================================
-- Purpose: Add missing foreign key and performance indexes
-- Author: Brian Lapp, Santiago
-- Date: October 10, 2025 (Fixed: January 10, 2025)
-- Execution: Run on STAGING first, then PRODUCTION
-- Duration: ~5-10 minutes depending on data size
-- Lock Impact: Using CONCURRENTLY to avoid table locks
-- ============================================================================

-- ⚠️ FIX APPLIED: Removed BEGIN/COMMIT blocks (incompatible with CONCURRENTLY)
-- CONCURRENTLY requires running OUTSIDE transaction blocks
-- Each CREATE INDEX CONCURRENTLY is its own implicit transaction

-- ============================================================================
-- SECTION 1: CRITICAL MENU QUERY INDEXES (Priority 1)
-- ============================================================================
-- These indexes are hit on EVERY menu load and are essential for performance

-- Dishes (10,585 rows) - Most critical table
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_dishes_restaurant 
ON menuca_v3.dishes(restaurant_id);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_dishes_course 
ON menuca_v3.dishes(course_id);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_dishes_active 
ON menuca_v3.dishes(restaurant_id, is_active) 
WHERE is_active = true;

-- Composite index for full menu queries
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_dishes_restaurant_active_course 
ON menuca_v3.dishes(restaurant_id, is_active, course_id, display_order);

-- Courses (1,207 rows) - Menu organization
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_courses_restaurant 
ON menuca_v3.courses(restaurant_id);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_courses_order 
ON menuca_v3.courses(restaurant_id, display_order);

-- ============================================================================
-- SECTION 2: MODIFIER SYSTEM INDEXES (Priority 1)
-- ============================================================================
-- Required for loading dish customization options

-- Dish Modifiers (2,922 rows) - Links dishes to ingredients with pricing
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_dish_modifiers_dish 
ON menuca_v3.dish_modifiers(dish_id);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_dish_modifiers_ingredient 
ON menuca_v3.dish_modifiers(ingredient_id);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_dish_modifiers_group 
ON menuca_v3.dish_modifiers(ingredient_group_id);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_dish_modifiers_restaurant 
ON menuca_v3.dish_modifiers(restaurant_id);

-- Ingredients (31,542 rows) - Modifier options
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_ingredients_restaurant 
ON menuca_v3.ingredients(restaurant_id);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_ingredients_active 
ON menuca_v3.ingredients(restaurant_id, is_active) 
WHERE is_active = true;

-- ============================================================================
-- SECTION 3: INGREDIENT GROUP INDEXES (Priority 1)
-- ============================================================================
-- Required for modifier group organization

-- Ingredient Groups (9,169 rows)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_ingredient_groups_restaurant 
ON menuca_v3.ingredient_groups(restaurant_id);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_ingredient_groups_course 
ON menuca_v3.ingredient_groups(applies_to_course);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_ingredient_groups_dish 
ON menuca_v3.ingredient_groups(applies_to_dish);

-- Ingredient Group Items (37,684 rows) - Junction table
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_ingredient_group_items_group 
ON menuca_v3.ingredient_group_items(ingredient_group_id);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_ingredient_group_items_ingredient 
ON menuca_v3.ingredient_group_items(ingredient_id);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_ingredient_group_items_order 
ON menuca_v3.ingredient_group_items(ingredient_group_id, display_order);

-- ============================================================================
-- SECTION 4: COMBO SYSTEM INDEXES (Priority 1 - after combo fix)
-- ============================================================================
-- Required for combo meal assembly

-- Combo Groups (8,234 rows)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_combo_groups_restaurant 
ON menuca_v3.combo_groups(restaurant_id);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_combo_groups_active 
ON menuca_v3.combo_groups(restaurant_id, is_active) 
WHERE is_active = true;

-- Combo Items (63 rows - will be much larger after fix)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_combo_items_group 
ON menuca_v3.combo_items(combo_group_id);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_combo_items_dish 
ON menuca_v3.combo_items(dish_id);

-- Combo Group Modifier Pricing (9,141 rows)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_combo_mod_pricing_group 
ON menuca_v3.combo_group_modifier_pricing(combo_group_id);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_combo_mod_pricing_ingredient 
ON menuca_v3.combo_group_modifier_pricing(ingredient_group_id);

-- Combo Steps (0 rows currently)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_combo_steps_item 
ON menuca_v3.combo_steps(combo_item_id);

-- ============================================================================
-- SECTION 5: RESTAURANT MANAGEMENT INDEXES (Priority 2)
-- ============================================================================
-- Required for tenant isolation and restaurant lookups

-- Restaurant Locations (921 rows)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_locations_restaurant 
ON menuca_v3.restaurant_locations(restaurant_id);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_locations_coords 
ON menuca_v3.restaurant_locations(latitude, longitude);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_locations_active 
ON menuca_v3.restaurant_locations(restaurant_id, is_active) 
WHERE is_active = true;

-- Restaurant Schedules (1,002 rows)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_schedules_restaurant 
ON menuca_v3.restaurant_schedules(restaurant_id);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_schedules_restaurant_type 
ON menuca_v3.restaurant_schedules(restaurant_id, type, day_start);

-- Restaurant Service Configs (944 rows)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_service_configs_restaurant 
ON menuca_v3.restaurant_service_configs(restaurant_id);

-- Restaurant Domains (713 rows)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_domains_restaurant 
ON menuca_v3.restaurant_domains(restaurant_id);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_domains_lookup 
ON menuca_v3.restaurant_domains(domain) 
WHERE is_enabled = true;

-- ============================================================================
-- SECTION 6: DELIVERY & SERVICE INDEXES (Priority 2)
-- ============================================================================

-- Restaurant Delivery Config (825 rows)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_delivery_config_restaurant 
ON menuca_v3.restaurant_delivery_config(restaurant_id);

-- Restaurant Delivery Areas (47 rows)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_delivery_areas_restaurant 
ON menuca_v3.restaurant_delivery_areas(restaurant_id);

-- Restaurant Delivery Companies (160 rows)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_delivery_companies_restaurant 
ON menuca_v3.restaurant_delivery_companies(restaurant_id);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_delivery_companies_email 
ON menuca_v3.restaurant_delivery_companies(company_email_id);

-- Restaurant Delivery Fees (210 rows)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_delivery_fees_restaurant 
ON menuca_v3.restaurant_delivery_fees(restaurant_id);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_delivery_fees_company 
ON menuca_v3.restaurant_delivery_fees(company_email_id);

-- ============================================================================
-- SECTION 7: MARKETING & PROMOTIONS INDEXES (Priority 3)
-- ============================================================================

-- Promotional Deals (202 rows)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_deals_restaurant 
ON menuca_v3.promotional_deals(restaurant_id);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_deals_active 
ON menuca_v3.promotional_deals(restaurant_id, is_enabled, date_start, date_stop);

-- Promotional Coupons (581 rows)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_coupons_restaurant 
ON menuca_v3.promotional_coupons(restaurant_id);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_coupons_code 
ON menuca_v3.promotional_coupons(code) 
WHERE is_active = true;

-- Restaurant Tag Associations (29 rows)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_tag_associations_restaurant 
ON menuca_v3.restaurant_tag_associations(restaurant_id);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_tag_associations_tag 
ON menuca_v3.restaurant_tag_associations(tag_id);

-- ============================================================================
-- SECTION 8: USER INDEXES (Priority 3)
-- ============================================================================

-- Users (32,349 rows)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_email 
ON menuca_v3.users(email);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_origin 
ON menuca_v3.users(origin_restaurant_id);

-- User Addresses (0 rows currently)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_user_addresses_user 
ON menuca_v3.user_addresses(user_id);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_user_addresses_default 
ON menuca_v3.user_addresses(user_id, is_default) 
WHERE is_default = true;

-- Admin Users (51 rows)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_admin_users_email 
ON menuca_v3.admin_users(email);

-- Admin User Restaurants (91 rows)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_admin_user_restaurants_admin 
ON menuca_v3.admin_user_restaurants(admin_user_id);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_admin_user_restaurants_restaurant 
ON menuca_v3.admin_user_restaurants(restaurant_id);

-- ============================================================================
-- SECTION 9: JSONB GIN INDEXES (Priority 2)
-- ============================================================================
-- Only if keeping JSONB pricing (recommended to add these for now)

-- Dishes JSONB pricing
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_dishes_prices_gin 
ON menuca_v3.dishes USING GIN(prices jsonb_path_ops)
WHERE prices IS NOT NULL;

-- Dish Modifiers JSONB pricing
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_dish_modifiers_price_gin 
ON menuca_v3.dish_modifiers USING GIN(price_by_size jsonb_path_ops)
WHERE price_by_size IS NOT NULL;

-- Ingredient Group Items JSONB pricing
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_ingredient_items_price_gin 
ON menuca_v3.ingredient_group_items USING GIN(price_by_size jsonb_path_ops)
WHERE price_by_size IS NOT NULL;

-- Combo Groups JSONB rules
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_combo_groups_rules_gin 
ON menuca_v3.combo_groups USING GIN(combo_rules jsonb_path_ops)
WHERE combo_rules IS NOT NULL;

-- ============================================================================
-- SECTION 10: DEVICES & INFRASTRUCTURE (Priority 3)
-- ============================================================================

-- Devices (981 rows)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_devices_restaurant 
ON menuca_v3.devices(restaurant_id);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_devices_active 
ON menuca_v3.devices(restaurant_id, is_active) 
WHERE is_active = true;

-- ============================================================================
-- VALIDATION QUERIES
-- ============================================================================
-- Run these after index creation to verify performance improvement

-- 1. Check all indexes were created
SELECT 
  schemaname,
  tablename,
  indexname,
  indexdef
FROM pg_indexes
WHERE schemaname = 'menuca_v3'
ORDER BY tablename, indexname;

-- 2. Test critical menu query (should use Index Scan)
EXPLAIN ANALYZE
SELECT 
  d.id, d.name, d.base_price, d.prices,
  c.name as course_name
FROM menuca_v3.dishes d
JOIN menuca_v3.courses c ON d.course_id = c.id
WHERE d.restaurant_id = 123 
  AND d.is_active = true
ORDER BY c.display_order, d.display_order;

-- 3. Test modifier lookup (should use Index Scan)
EXPLAIN ANALYZE
SELECT dm.*, i.name as ingredient_name
FROM menuca_v3.dish_modifiers dm
JOIN menuca_v3.ingredients i ON dm.ingredient_id = i.id
WHERE dm.dish_id = 1000;

-- 4. Check index sizes
SELECT
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as total_size,
  pg_size_pretty(pg_indexes_size(schemaname||'.'||tablename)) as indexes_size,
  ROUND(100.0 * pg_indexes_size(schemaname||'.'||tablename) / 
        NULLIF(pg_total_relation_size(schemaname||'.'||tablename), 0), 2) as index_pct
FROM pg_tables
WHERE schemaname = 'menuca_v3'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- 5. Monitor index usage (run after 1 week)
SELECT
  schemaname,
  tablename,
  indexname,
  idx_scan,
  idx_tup_read,
  idx_tup_fetch,
  pg_size_pretty(pg_relation_size(indexrelid)) as index_size
FROM pg_stat_user_indexes
WHERE schemaname = 'menuca_v3'
ORDER BY idx_scan DESC;

-- ============================================================================
-- ROLLBACK INSTRUCTIONS (if needed)
-- ============================================================================
/*
If you need to rollback indexes (unlikely):

DROP INDEX CONCURRENTLY IF EXISTS menuca_v3.idx_dishes_restaurant;
DROP INDEX CONCURRENTLY IF EXISTS menuca_v3.idx_dishes_course;
-- ... repeat for all indexes

OR use this script to generate drop statements:

SELECT 'DROP INDEX CONCURRENTLY IF EXISTS menuca_v3.' || indexname || ';'
FROM pg_indexes
WHERE schemaname = 'menuca_v3'
  AND indexname LIKE 'idx_%';
*/

-- ============================================================================
-- MAINTENANCE NOTES
-- ============================================================================
/*
1. REINDEX if indexes become bloated:
   REINDEX INDEX CONCURRENTLY menuca_v3.idx_dishes_restaurant;

2. Monitor autovacuum:
   SELECT * FROM pg_stat_user_tables WHERE schemaname = 'menuca_v3';

3. Check for unused indexes quarterly:
   SELECT * FROM pg_stat_user_indexes 
   WHERE schemaname = 'menuca_v3' AND idx_scan = 0;

4. Update statistics after bulk data changes:
   ANALYZE menuca_v3.dishes;
   ANALYZE menuca_v3.ingredients;
*/

-- ============================================================================
-- END OF SCRIPT - FIXED VERSION (No duplicates, no transaction conflicts)
-- ============================================================================


