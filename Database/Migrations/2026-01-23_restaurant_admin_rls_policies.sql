-- ============================================================================
-- Restaurant Admin RLS Policies Migration
-- Created: 2026-01-23
-- Purpose: Grant Restaurant Admins CRUD access to their assigned restaurants
-- ============================================================================

-- ============================================================================
-- PHASE 1: Create Helper Function
-- ============================================================================

-- Function to get restaurant IDs for the current authenticated admin
CREATE OR REPLACE FUNCTION menuca_v3.current_admin_restaurant_ids()
RETURNS SETOF bigint
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = 'menuca_v3', 'auth'
AS $$
  SELECT aur.restaurant_id::bigint
  FROM menuca_v3.admin_user_restaurants aur
  JOIN menuca_v3.admin_users au ON au.id = aur.admin_user_id
  WHERE au.auth_user_id = auth.uid()
    AND au.deleted_at IS NULL
    AND au.status = 'active';
$$;

COMMENT ON FUNCTION menuca_v3.current_admin_restaurant_ids() IS 
'Returns restaurant IDs the current admin user has access to. Used by RLS policies.';

-- Grant execute to authenticated users
GRANT EXECUTE ON FUNCTION menuca_v3.current_admin_restaurant_ids() TO authenticated;

-- ============================================================================
-- PHASE 2: Enable RLS on Tables Without It
-- ============================================================================

ALTER TABLE menuca_v3.restaurant_subdomains ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.restaurant_onboarding ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.restaurant_analytics_configs ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.restaurant_payment_options ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.restaurant_cuisines ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.restaurant_reviews ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- PHASE 3: Create Admin CRUD Policies
-- ============================================================================

-- 3.1 restaurants (uses id column, not restaurant_id)
CREATE POLICY "admin_crud_own_restaurants" ON menuca_v3.restaurants
FOR ALL TO authenticated
USING (id IN (SELECT menuca_v3.current_admin_restaurant_ids()))
WITH CHECK (id IN (SELECT menuca_v3.current_admin_restaurant_ids()));

-- 3.2 restaurant_locations
CREATE POLICY "admin_crud_own_restaurant_locations" ON menuca_v3.restaurant_locations
FOR ALL TO authenticated
USING (restaurant_id IN (SELECT menuca_v3.current_admin_restaurant_ids()))
WITH CHECK (restaurant_id IN (SELECT menuca_v3.current_admin_restaurant_ids()));

-- 3.3 restaurant_domains
CREATE POLICY "admin_crud_own_restaurant_domains" ON menuca_v3.restaurant_domains
FOR ALL TO authenticated
USING (restaurant_id IN (SELECT menuca_v3.current_admin_restaurant_ids()))
WITH CHECK (restaurant_id IN (SELECT menuca_v3.current_admin_restaurant_ids()));

-- 3.4 restaurant_subdomains
CREATE POLICY "admin_crud_own_restaurant_subdomains" ON menuca_v3.restaurant_subdomains
FOR ALL TO authenticated
USING (restaurant_id IN (SELECT menuca_v3.current_admin_restaurant_ids()))
WITH CHECK (restaurant_id IN (SELECT menuca_v3.current_admin_restaurant_ids()));

-- 3.5 restaurant_onboarding
CREATE POLICY "admin_crud_own_restaurant_onboarding" ON menuca_v3.restaurant_onboarding
FOR ALL TO authenticated
USING (restaurant_id IN (SELECT menuca_v3.current_admin_restaurant_ids()))
WITH CHECK (restaurant_id IN (SELECT menuca_v3.current_admin_restaurant_ids()));

-- 3.6 restaurant_payment_options
CREATE POLICY "admin_crud_own_restaurant_payment_options" ON menuca_v3.restaurant_payment_options
FOR ALL TO authenticated
USING (restaurant_id IN (SELECT menuca_v3.current_admin_restaurant_ids()))
WITH CHECK (restaurant_id IN (SELECT menuca_v3.current_admin_restaurant_ids()));

-- 3.7 restaurant_cuisines
CREATE POLICY "admin_crud_own_restaurant_cuisines" ON menuca_v3.restaurant_cuisines
FOR ALL TO authenticated
USING (restaurant_id IN (SELECT menuca_v3.current_admin_restaurant_ids()))
WITH CHECK (restaurant_id IN (SELECT menuca_v3.current_admin_restaurant_ids()));

-- 3.8 restaurant_schedules
CREATE POLICY "admin_crud_own_restaurant_schedules" ON menuca_v3.restaurant_schedules
FOR ALL TO authenticated
USING (restaurant_id IN (SELECT menuca_v3.current_admin_restaurant_ids()))
WITH CHECK (restaurant_id IN (SELECT menuca_v3.current_admin_restaurant_ids()));

-- 3.9 restaurant_special_schedules
CREATE POLICY "admin_crud_own_restaurant_special_schedules" ON menuca_v3.restaurant_special_schedules
FOR ALL TO authenticated
USING (restaurant_id IN (SELECT menuca_v3.current_admin_restaurant_ids()))
WITH CHECK (restaurant_id IN (SELECT menuca_v3.current_admin_restaurant_ids()));

-- 3.10 restaurant_delivery_areas
CREATE POLICY "admin_crud_own_restaurant_delivery_areas" ON menuca_v3.restaurant_delivery_areas
FOR ALL TO authenticated
USING (restaurant_id IN (SELECT menuca_v3.current_admin_restaurant_ids()))
WITH CHECK (restaurant_id IN (SELECT menuca_v3.current_admin_restaurant_ids()));

-- 3.11 delivery_and_pickup_configs
CREATE POLICY "admin_crud_own_delivery_and_pickup_configs" ON menuca_v3.delivery_and_pickup_configs
FOR ALL TO authenticated
USING (restaurant_id IN (SELECT menuca_v3.current_admin_restaurant_ids()))
WITH CHECK (restaurant_id IN (SELECT menuca_v3.current_admin_restaurant_ids()));

-- 3.12 restaurant_delivery_companies
CREATE POLICY "admin_crud_own_restaurant_delivery_companies" ON menuca_v3.restaurant_delivery_companies
FOR ALL TO authenticated
USING (restaurant_id IN (SELECT menuca_v3.current_admin_restaurant_ids()))
WITH CHECK (restaurant_id IN (SELECT menuca_v3.current_admin_restaurant_ids()));

-- 3.13 restaurant_distance_based_delivery_fees
CREATE POLICY "admin_crud_own_restaurant_distance_based_delivery_fees" ON menuca_v3.restaurant_distance_based_delivery_fees
FOR ALL TO authenticated
USING (restaurant_id IN (SELECT menuca_v3.current_admin_restaurant_ids()))
WITH CHECK (restaurant_id IN (SELECT menuca_v3.current_admin_restaurant_ids()));

-- ============================================================================
-- PHASE 4: Create Read-Only Policies
-- ============================================================================

-- 4.1 restaurant_analytics_configs (SELECT only)
CREATE POLICY "admin_select_own_restaurant_analytics_configs" ON menuca_v3.restaurant_analytics_configs
FOR SELECT TO authenticated
USING (restaurant_id IN (SELECT menuca_v3.current_admin_restaurant_ids()));

-- 4.2 restaurant_reviews (SELECT only)
CREATE POLICY "admin_select_own_restaurant_reviews" ON menuca_v3.restaurant_reviews
FOR SELECT TO authenticated
USING (restaurant_id IN (SELECT menuca_v3.current_admin_restaurant_ids()));

-- 4.3 restaurant_tags - Global lookup table, all authenticated can read
CREATE POLICY "authenticated_read_tags" ON menuca_v3.restaurant_tags
FOR SELECT TO authenticated
USING (true);

-- ============================================================================
-- PHASE 5: Fix Overly-Permissive Policy
-- ============================================================================

-- Drop the overly-permissive policy on delivery_company_emails
DROP POLICY IF EXISTS "delivery_company_emails_manage_authenticated" ON menuca_v3.delivery_company_emails;

-- Create restricted read-only policy (global lookup table)
CREATE POLICY "admin_select_delivery_emails" ON menuca_v3.delivery_company_emails
FOR SELECT TO authenticated
USING (true);

-- ============================================================================
-- PHASE 6: Ensure Service Role Policies Exist
-- ============================================================================

-- Service role policies for tables that might be missing them
DO $$
DECLARE
    tables TEXT[] := ARRAY[
        'restaurant_subdomains',
        'restaurant_onboarding', 
        'restaurant_analytics_configs',
        'restaurant_payment_options',
        'restaurant_cuisines',
        'restaurant_reviews',
        'restaurant_tags'
    ];
    t TEXT;
BEGIN
    FOREACH t IN ARRAY tables
    LOOP
        -- Check if policy exists, create if not
        IF NOT EXISTS (
            SELECT 1 FROM pg_policies 
            WHERE schemaname = 'menuca_v3' 
            AND tablename = t 
            AND policyname = t || '_service_role_all'
        ) THEN
            EXECUTE format(
                'CREATE POLICY %I ON menuca_v3.%I FOR ALL TO service_role USING (true) WITH CHECK (true)',
                t || '_service_role_all',
                t
            );
        END IF;
    END LOOP;
END $$;

-- ============================================================================
-- Done!
-- ============================================================================
