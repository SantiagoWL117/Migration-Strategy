-- ============================================================================
-- MenuCA V3 - Row Level Security (RLS) Policies
-- ============================================================================
-- Purpose: Enforce tenant isolation and access control at database level
-- Author: Brian Lapp, Santiago
-- Date: October 10, 2025
-- Execution: Run on STAGING first, then PRODUCTION
-- Strategy: See /Database/Security/rls_policy_strategy.md
-- ============================================================================

-- IMPORTANT: Test thoroughly before production deployment
-- Rollback: See rls_policy_strategy.md for disable script

BEGIN;

-- ============================================================================
-- SECTION 1: ENABLE RLS ON ALL TABLES
-- ============================================================================

-- Restaurant Management Tables
ALTER TABLE menuca_v3.restaurants ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.restaurant_locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.restaurant_domains ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.restaurant_contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.restaurant_admin_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.restaurant_schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.restaurant_special_schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.restaurant_service_configs ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.restaurant_time_periods ENABLE ROW LEVEL SECURITY;

-- Menu & Catalog Tables
ALTER TABLE menuca_v3.courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.dishes ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.ingredients ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.ingredient_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.ingredient_group_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.dish_modifiers ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.combo_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.combo_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.combo_group_modifier_pricing ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.combo_steps ENABLE ROW LEVEL SECURITY;

-- Delivery Configuration Tables
ALTER TABLE menuca_v3.restaurant_delivery_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.restaurant_delivery_areas ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.restaurant_delivery_companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.restaurant_delivery_fees ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.restaurant_partner_schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.restaurant_twilio_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.delivery_company_emails ENABLE ROW LEVEL SECURITY;

-- Marketing & Promotions Tables
ALTER TABLE menuca_v3.promotional_deals ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.promotional_coupons ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.marketing_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.restaurant_tag_associations ENABLE ROW LEVEL SECURITY;

-- User Tables
ALTER TABLE menuca_v3.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.user_addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.user_favorite_restaurants ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.password_reset_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.autologin_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.admin_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.admin_user_restaurants ENABLE ROW LEVEL SECURITY;

-- Infrastructure Tables
ALTER TABLE menuca_v3.devices ENABLE ROW LEVEL SECURITY;

-- Geography Tables (public read, no write restrictions needed)
ALTER TABLE menuca_v3.provinces ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.cities ENABLE ROW LEVEL SECURITY;

COMMIT;

-- ============================================================================
-- SECTION 2: RESTAURANT MANAGEMENT POLICIES (Tenant-Scoped)
-- ============================================================================

BEGIN;

-- restaurants table
CREATE POLICY tenant_access_restaurants ON menuca_v3.restaurants
  FOR SELECT
  USING (
    id = (auth.jwt() ->> 'restaurant_id')::bigint
    OR (auth.jwt() ->> 'role') = 'admin'
  );

CREATE POLICY tenant_update_restaurants ON menuca_v3.restaurants
  FOR UPDATE
  USING (id = (auth.jwt() ->> 'restaurant_id')::bigint)
  WITH CHECK (id = (auth.jwt() ->> 'restaurant_id')::bigint);

-- Admin can insert/delete
CREATE POLICY admin_manage_restaurants ON menuca_v3.restaurants
  FOR ALL
  USING ((auth.jwt() ->> 'role') = 'admin');

-- restaurant_locations table
CREATE POLICY tenant_access_locations ON menuca_v3.restaurant_locations
  FOR SELECT
  USING (
    restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint
    OR (auth.jwt() ->> 'role') = 'admin'
  );

CREATE POLICY tenant_manage_locations ON menuca_v3.restaurant_locations
  FOR ALL
  USING (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint)
  WITH CHECK (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint);

-- restaurant_domains table
CREATE POLICY tenant_access_domains ON menuca_v3.restaurant_domains
  FOR SELECT
  USING (
    restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint
    OR (auth.jwt() ->> 'role') = 'admin'
  );

CREATE POLICY tenant_manage_domains ON menuca_v3.restaurant_domains
  FOR ALL
  USING (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint)
  WITH CHECK (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint);

-- restaurant_contacts table
CREATE POLICY tenant_access_contacts ON menuca_v3.restaurant_contacts
  FOR SELECT
  USING (
    restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint
    OR (auth.jwt() ->> 'role') = 'admin'
  );

CREATE POLICY tenant_manage_contacts ON menuca_v3.restaurant_contacts
  FOR ALL
  USING (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint)
  WITH CHECK (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint);

-- restaurant_admin_users table
CREATE POLICY tenant_access_admin_users ON menuca_v3.restaurant_admin_users
  FOR SELECT
  USING (
    restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint
    OR (auth.jwt() ->> 'role') = 'admin'
  );

CREATE POLICY tenant_manage_admin_users ON menuca_v3.restaurant_admin_users
  FOR ALL
  USING (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint)
  WITH CHECK (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint);

-- restaurant_schedules table
CREATE POLICY tenant_access_schedules ON menuca_v3.restaurant_schedules
  FOR SELECT
  USING (
    restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint
    OR (auth.jwt() ->> 'role') = 'admin'
  );

CREATE POLICY public_view_schedules ON menuca_v3.restaurant_schedules
  FOR SELECT
  USING (is_enabled = true);

CREATE POLICY tenant_manage_schedules ON menuca_v3.restaurant_schedules
  FOR ALL
  USING (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint)
  WITH CHECK (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint);

-- restaurant_special_schedules table
CREATE POLICY tenant_access_special_schedules ON menuca_v3.restaurant_special_schedules
  FOR SELECT
  USING (
    restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint
    OR (auth.jwt() ->> 'role') = 'admin'
  );

CREATE POLICY tenant_manage_special_schedules ON menuca_v3.restaurant_special_schedules
  FOR ALL
  USING (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint)
  WITH CHECK (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint);

-- restaurant_service_configs table
CREATE POLICY tenant_access_service_configs ON menuca_v3.restaurant_service_configs
  FOR SELECT
  USING (
    restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint
    OR (auth.jwt() ->> 'role') = 'admin'
  );

CREATE POLICY tenant_manage_service_configs ON menuca_v3.restaurant_service_configs
  FOR ALL
  USING (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint)
  WITH CHECK (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint);

-- restaurant_time_periods table
CREATE POLICY tenant_access_time_periods ON menuca_v3.restaurant_time_periods
  FOR SELECT
  USING (
    restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint
    OR (auth.jwt() ->> 'role') = 'admin'
  );

CREATE POLICY tenant_manage_time_periods ON menuca_v3.restaurant_time_periods
  FOR ALL
  USING (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint)
  WITH CHECK (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint);

COMMIT;

-- ============================================================================
-- SECTION 3: MENU & CATALOG POLICIES (Tenant-Scoped + Public Read)
-- ============================================================================

BEGIN;

-- courses table
CREATE POLICY tenant_manage_courses ON menuca_v3.courses
  FOR ALL
  USING (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint)
  WITH CHECK (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint);

CREATE POLICY public_view_active_courses ON menuca_v3.courses
  FOR SELECT
  USING (is_active = true);

CREATE POLICY admin_access_courses ON menuca_v3.courses
  FOR ALL
  USING ((auth.jwt() ->> 'role') = 'admin');

-- dishes table
CREATE POLICY tenant_manage_dishes ON menuca_v3.dishes
  FOR ALL
  USING (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint)
  WITH CHECK (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint);

CREATE POLICY public_view_active_dishes ON menuca_v3.dishes
  FOR SELECT
  USING (is_active = true);

CREATE POLICY admin_access_dishes ON menuca_v3.dishes
  FOR ALL
  USING ((auth.jwt() ->> 'role') = 'admin');

-- ingredients table
CREATE POLICY tenant_manage_ingredients ON menuca_v3.ingredients
  FOR ALL
  USING (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint)
  WITH CHECK (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint);

CREATE POLICY public_view_active_ingredients ON menuca_v3.ingredients
  FOR SELECT
  USING (is_active = true);

CREATE POLICY admin_access_ingredients ON menuca_v3.ingredients
  FOR ALL
  USING ((auth.jwt() ->> 'role') = 'admin');

-- ingredient_groups table
CREATE POLICY tenant_manage_ingredient_groups ON menuca_v3.ingredient_groups
  FOR ALL
  USING (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint)
  WITH CHECK (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint);

CREATE POLICY public_view_active_ingredient_groups ON menuca_v3.ingredient_groups
  FOR SELECT
  USING (is_active = true);

CREATE POLICY admin_access_ingredient_groups ON menuca_v3.ingredient_groups
  FOR ALL
  USING ((auth.jwt() ->> 'role') = 'admin');

-- ingredient_group_items table (no restaurant_id, joins through ingredient_group)
CREATE POLICY public_view_ingredient_group_items ON menuca_v3.ingredient_group_items
  FOR SELECT
  USING (true); -- Public read for menu display

CREATE POLICY tenant_manage_ingredient_group_items ON menuca_v3.ingredient_group_items
  FOR INSERT
  USING (
    ingredient_group_id IN (
      SELECT id FROM menuca_v3.ingredient_groups 
      WHERE restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint
    )
  );

CREATE POLICY tenant_update_ingredient_group_items ON menuca_v3.ingredient_group_items
  FOR UPDATE
  USING (
    ingredient_group_id IN (
      SELECT id FROM menuca_v3.ingredient_groups 
      WHERE restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint
    )
  );

CREATE POLICY tenant_delete_ingredient_group_items ON menuca_v3.ingredient_group_items
  FOR DELETE
  USING (
    ingredient_group_id IN (
      SELECT id FROM menuca_v3.ingredient_groups 
      WHERE restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint
    )
  );

-- dish_modifiers table
CREATE POLICY tenant_manage_dish_modifiers ON menuca_v3.dish_modifiers
  FOR ALL
  USING (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint)
  WITH CHECK (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint);

CREATE POLICY public_view_dish_modifiers ON menuca_v3.dish_modifiers
  FOR SELECT
  USING (true); -- Public read for menu display

CREATE POLICY admin_access_dish_modifiers ON menuca_v3.dish_modifiers
  FOR ALL
  USING ((auth.jwt() ->> 'role') = 'admin');

-- combo_groups table
CREATE POLICY tenant_manage_combo_groups ON menuca_v3.combo_groups
  FOR ALL
  USING (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint)
  WITH CHECK (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint);

CREATE POLICY public_view_active_combo_groups ON menuca_v3.combo_groups
  FOR SELECT
  USING (is_active = true);

CREATE POLICY admin_access_combo_groups ON menuca_v3.combo_groups
  FOR ALL
  USING ((auth.jwt() ->> 'role') = 'admin');

-- combo_items table (no direct restaurant_id, joins through combo_group)
CREATE POLICY public_view_combo_items ON menuca_v3.combo_items
  FOR SELECT
  USING (true); -- Public read for menu display

CREATE POLICY tenant_manage_combo_items ON menuca_v3.combo_items
  FOR INSERT
  USING (
    combo_group_id IN (
      SELECT id FROM menuca_v3.combo_groups 
      WHERE restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint
    )
  );

CREATE POLICY tenant_update_combo_items ON menuca_v3.combo_items
  FOR UPDATE
  USING (
    combo_group_id IN (
      SELECT id FROM menuca_v3.combo_groups 
      WHERE restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint
    )
  );

CREATE POLICY tenant_delete_combo_items ON menuca_v3.combo_items
  FOR DELETE
  USING (
    combo_group_id IN (
      SELECT id FROM menuca_v3.combo_groups 
      WHERE restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint
    )
  );

-- combo_group_modifier_pricing table
CREATE POLICY public_view_combo_modifier_pricing ON menuca_v3.combo_group_modifier_pricing
  FOR SELECT
  USING (true); -- Public read for menu display

CREATE POLICY tenant_manage_combo_modifier_pricing ON menuca_v3.combo_group_modifier_pricing
  FOR INSERT
  USING (
    combo_group_id IN (
      SELECT id FROM menuca_v3.combo_groups 
      WHERE restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint
    )
  );

CREATE POLICY tenant_update_combo_modifier_pricing ON menuca_v3.combo_group_modifier_pricing
  FOR UPDATE
  USING (
    combo_group_id IN (
      SELECT id FROM menuca_v3.combo_groups 
      WHERE restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint
    )
  );

CREATE POLICY tenant_delete_combo_modifier_pricing ON menuca_v3.combo_group_modifier_pricing
  FOR DELETE
  USING (
    combo_group_id IN (
      SELECT id FROM menuca_v3.combo_groups 
      WHERE restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint
    )
  );

-- combo_steps table
CREATE POLICY public_view_combo_steps ON menuca_v3.combo_steps
  FOR SELECT
  USING (true); -- Public read for menu display

CREATE POLICY tenant_manage_combo_steps ON menuca_v3.combo_steps
  FOR INSERT
  USING (
    combo_item_id IN (
      SELECT ci.id FROM menuca_v3.combo_items ci
      JOIN menuca_v3.combo_groups cg ON ci.combo_group_id = cg.id
      WHERE cg.restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint
    )
  );

CREATE POLICY tenant_update_combo_steps ON menuca_v3.combo_steps
  FOR UPDATE
  USING (
    combo_item_id IN (
      SELECT ci.id FROM menuca_v3.combo_items ci
      JOIN menuca_v3.combo_groups cg ON ci.combo_group_id = cg.id
      WHERE cg.restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint
    )
  );

CREATE POLICY tenant_delete_combo_steps ON menuca_v3.combo_steps
  FOR DELETE
  USING (
    combo_item_id IN (
      SELECT ci.id FROM menuca_v3.combo_items ci
      JOIN menuca_v3.combo_groups cg ON ci.combo_group_id = cg.id
      WHERE cg.restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint
    )
  );

COMMIT;

-- ============================================================================
-- SECTION 4: DELIVERY CONFIGURATION POLICIES (Tenant-Scoped)
-- ============================================================================

BEGIN;

-- restaurant_delivery_config table
CREATE POLICY tenant_manage_delivery_config ON menuca_v3.restaurant_delivery_config
  FOR ALL
  USING (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint)
  WITH CHECK (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint);

CREATE POLICY admin_access_delivery_config ON menuca_v3.restaurant_delivery_config
  FOR ALL
  USING ((auth.jwt() ->> 'role') = 'admin');

-- restaurant_delivery_areas table
CREATE POLICY tenant_manage_delivery_areas ON menuca_v3.restaurant_delivery_areas
  FOR ALL
  USING (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint)
  WITH CHECK (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint);

CREATE POLICY public_view_delivery_areas ON menuca_v3.restaurant_delivery_areas
  FOR SELECT
  USING (is_active = true);

-- restaurant_delivery_companies table
CREATE POLICY tenant_manage_delivery_companies ON menuca_v3.restaurant_delivery_companies
  FOR ALL
  USING (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint)
  WITH CHECK (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint);

CREATE POLICY admin_access_delivery_companies ON menuca_v3.restaurant_delivery_companies
  FOR ALL
  USING ((auth.jwt() ->> 'role') = 'admin');

-- restaurant_delivery_fees table
CREATE POLICY tenant_manage_delivery_fees ON menuca_v3.restaurant_delivery_fees
  FOR ALL
  USING (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint)
  WITH CHECK (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint);

CREATE POLICY admin_access_delivery_fees ON menuca_v3.restaurant_delivery_fees
  FOR ALL
  USING ((auth.jwt() ->> 'role') = 'admin');

-- restaurant_partner_schedules table
CREATE POLICY tenant_manage_partner_schedules ON menuca_v3.restaurant_partner_schedules
  FOR ALL
  USING (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint)
  WITH CHECK (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint);

CREATE POLICY admin_access_partner_schedules ON menuca_v3.restaurant_partner_schedules
  FOR ALL
  USING ((auth.jwt() ->> 'role') = 'admin');

-- restaurant_twilio_config table
CREATE POLICY tenant_manage_twilio_config ON menuca_v3.restaurant_twilio_config
  FOR ALL
  USING (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint)
  WITH CHECK (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint);

CREATE POLICY admin_access_twilio_config ON menuca_v3.restaurant_twilio_config
  FOR ALL
  USING ((auth.jwt() ->> 'role') = 'admin');

-- delivery_company_emails table (shared reference data)
CREATE POLICY public_read_delivery_emails ON menuca_v3.delivery_company_emails
  FOR SELECT
  USING (is_active = true);

CREATE POLICY admin_manage_delivery_emails ON menuca_v3.delivery_company_emails
  FOR ALL
  USING ((auth.jwt() ->> 'role') = 'admin');

COMMIT;

-- ============================================================================
-- SECTION 5: MARKETING & PROMOTIONS POLICIES (Hybrid Access)
-- ============================================================================

BEGIN;

-- promotional_deals table
CREATE POLICY tenant_manage_deals ON menuca_v3.promotional_deals
  FOR ALL
  USING (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint)
  WITH CHECK (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint);

CREATE POLICY public_view_active_deals ON menuca_v3.promotional_deals
  FOR SELECT
  USING (
    is_enabled = true 
    AND (date_start IS NULL OR date_start <= CURRENT_DATE)
    AND (date_stop IS NULL OR date_stop >= CURRENT_DATE)
  );

CREATE POLICY admin_access_deals ON menuca_v3.promotional_deals
  FOR ALL
  USING ((auth.jwt() ->> 'role') = 'admin');

-- promotional_coupons table
CREATE POLICY tenant_manage_coupons ON menuca_v3.promotional_coupons
  FOR ALL
  USING (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint)
  WITH CHECK (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint);

CREATE POLICY public_view_active_coupons ON menuca_v3.promotional_coupons
  FOR SELECT
  USING (is_active = true AND NOT is_used);

CREATE POLICY admin_access_coupons ON menuca_v3.promotional_coupons
  FOR ALL
  USING ((auth.jwt() ->> 'role') = 'admin');

-- marketing_tags table (shared reference data)
CREATE POLICY public_read_tags ON menuca_v3.marketing_tags
  FOR SELECT
  USING (true);

CREATE POLICY admin_manage_tags ON menuca_v3.marketing_tags
  FOR ALL
  USING ((auth.jwt() ->> 'role') = 'admin');

-- restaurant_tag_associations table
CREATE POLICY tenant_manage_tag_associations ON menuca_v3.restaurant_tag_associations
  FOR ALL
  USING (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint)
  WITH CHECK (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint);

CREATE POLICY public_view_tag_associations ON menuca_v3.restaurant_tag_associations
  FOR SELECT
  USING (true);

CREATE POLICY admin_access_tag_associations ON menuca_v3.restaurant_tag_associations
  FOR ALL
  USING ((auth.jwt() ->> 'role') = 'admin');

COMMIT;

-- ============================================================================
-- SECTION 6: USER POLICIES (User-Scoped)
-- ============================================================================

BEGIN;

-- users table
CREATE POLICY user_view_own_profile ON menuca_v3.users
  FOR SELECT
  USING (id = auth.uid()::bigint);

CREATE POLICY user_update_own_profile ON menuca_v3.users
  FOR UPDATE
  USING (id = auth.uid()::bigint)
  WITH CHECK (id = auth.uid()::bigint);

CREATE POLICY admin_access_users ON menuca_v3.users
  FOR ALL
  USING ((auth.jwt() ->> 'role') = 'admin');

-- user_addresses table
CREATE POLICY user_manage_own_addresses ON menuca_v3.user_addresses
  FOR ALL
  USING (user_id = auth.uid()::bigint)
  WITH CHECK (user_id = auth.uid()::bigint);

CREATE POLICY admin_access_addresses ON menuca_v3.user_addresses
  FOR ALL
  USING ((auth.jwt() ->> 'role') = 'admin');

-- user_favorite_restaurants table
CREATE POLICY user_manage_own_favorites ON menuca_v3.user_favorite_restaurants
  FOR ALL
  USING (user_id = auth.uid()::bigint)
  WITH CHECK (user_id = auth.uid()::bigint);

-- password_reset_tokens table
CREATE POLICY user_view_own_reset_tokens ON menuca_v3.password_reset_tokens
  FOR SELECT
  USING (user_id = auth.uid()::bigint);

CREATE POLICY admin_manage_reset_tokens ON menuca_v3.password_reset_tokens
  FOR ALL
  USING ((auth.jwt() ->> 'role') = 'admin');

-- autologin_tokens table
CREATE POLICY user_view_own_autologin_tokens ON menuca_v3.autologin_tokens
  FOR SELECT
  USING (user_id = auth.uid()::bigint);

CREATE POLICY admin_manage_autologin_tokens ON menuca_v3.autologin_tokens
  FOR ALL
  USING ((auth.jwt() ->> 'role') = 'admin');

COMMIT;

-- ============================================================================
-- SECTION 7: ADMIN POLICIES (Admin-Only Access)
-- ============================================================================

BEGIN;

-- admin_users table (admin-only)
CREATE POLICY admin_only_admin_users ON menuca_v3.admin_users
  FOR ALL
  USING ((auth.jwt() ->> 'role') = 'admin');

-- admin_user_restaurants table (admin-only)
CREATE POLICY admin_only_admin_user_restaurants ON menuca_v3.admin_user_restaurants
  FOR ALL
  USING ((auth.jwt() ->> 'role') = 'admin');

COMMIT;

-- ============================================================================
-- SECTION 8: INFRASTRUCTURE POLICIES
-- ============================================================================

BEGIN;

-- devices table
CREATE POLICY tenant_manage_devices ON menuca_v3.devices
  FOR ALL
  USING (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint)
  WITH CHECK (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint);

CREATE POLICY admin_access_devices ON menuca_v3.devices
  FOR ALL
  USING ((auth.jwt() ->> 'role') = 'admin');

COMMIT;

-- ============================================================================
-- SECTION 9: GEOGRAPHY POLICIES (Public Read)
-- ============================================================================

BEGIN;

-- provinces table (public reference data)
CREATE POLICY public_read_provinces ON menuca_v3.provinces
  FOR SELECT
  USING (true);

CREATE POLICY admin_manage_provinces ON menuca_v3.provinces
  FOR ALL
  USING ((auth.jwt() ->> 'role') = 'admin');

-- cities table (public reference data)
CREATE POLICY public_read_cities ON menuca_v3.cities
  FOR SELECT
  USING (true);

CREATE POLICY admin_manage_cities ON menuca_v3.cities
  FOR ALL
  USING ((auth.jwt() ->> 'role') = 'admin');

COMMIT;

-- ============================================================================
-- VALIDATION QUERIES
-- ============================================================================

-- Run these after policy creation to verify functionality

-- Test 1: Verify RLS is enabled on all tables
SELECT 
  schemaname, 
  tablename, 
  rowsecurity 
FROM pg_tables 
WHERE schemaname = 'menuca_v3' 
  AND rowsecurity = false;
-- Expected: 0 rows (all should have RLS enabled)

-- Test 2: Count policies per table
SELECT 
  tablename,
  COUNT(*) as policy_count
FROM pg_policies
WHERE schemaname = 'menuca_v3'
GROUP BY tablename
ORDER BY policy_count DESC;

-- Test 3: Find tables without policies (potential oversight)
SELECT tablename
FROM pg_tables
WHERE schemaname = 'menuca_v3'
  AND tablename NOT IN (
    SELECT DISTINCT tablename FROM pg_policies WHERE schemaname = 'menuca_v3'
  );
-- Expected: 0 rows (all tables should have policies)

-- Test 4: Simulate tenant access
-- SET LOCAL app.current_restaurant_id = '123';
-- SELECT COUNT(*) FROM menuca_v3.dishes WHERE restaurant_id != 123;
-- Expected: 0 rows (should only see own restaurant's data)

-- ============================================================================
-- ROLLBACK INSTRUCTIONS (if needed)
-- ============================================================================

/*
-- To disable all RLS policies:
DO $$
DECLARE
  tbl RECORD;
BEGIN
  FOR tbl IN 
    SELECT tablename 
    FROM pg_tables 
    WHERE schemaname = 'menuca_v3'
  LOOP
    EXECUTE 'ALTER TABLE menuca_v3.' || tbl.tablename || ' DISABLE ROW LEVEL SECURITY';
    RAISE NOTICE 'Disabled RLS on menuca_v3.%', tbl.tablename;
  END LOOP;
END $$;

-- To drop all policies:
DO $$
DECLARE
  pol RECORD;
BEGIN
  FOR pol IN 
    SELECT tablename, policyname
    FROM pg_policies 
    WHERE schemaname = 'menuca_v3'
  LOOP
    EXECUTE 'DROP POLICY IF EXISTS ' || pol.policyname || ' ON menuca_v3.' || pol.tablename;
    RAISE NOTICE 'Dropped policy % on menuca_v3.%', pol.policyname, pol.tablename;
  END LOOP;
END $$;
*/

-- ============================================================================
-- END OF SCRIPT
-- ============================================================================

