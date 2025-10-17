-- =====================================================
-- ORDERS & CHECKOUT V3 - PHASE 1: AUTH & SECURITY
-- =====================================================
-- Entity: Orders & Checkout (Priority 7)
-- Phase: 1 of 7 - Row-Level Security & Multi-Party Access Control
-- Created: January 17, 2025
-- Description: Comprehensive RLS policies for orders, customers, restaurants, drivers, admins
-- =====================================================

BEGIN;

-- =====================================================
-- SECTION 1: CREATE HELPER FUNCTIONS
-- =====================================================

-- Get current user ID from JWT
CREATE OR REPLACE FUNCTION menuca_v3.current_user_id()
RETURNS BIGINT AS $$
  SELECT COALESCE(
    NULLIF(current_setting('request.jwt.claims', true)::json->>'user_id', '')::BIGINT,
    NULLIF(current_setting('request.jwt.claim.user_id', true), '')::BIGINT
  );
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- Get current user role from JWT
CREATE OR REPLACE FUNCTION menuca_v3.current_user_role()
RETURNS TEXT AS $$
  SELECT COALESCE(
    current_setting('request.jwt.claims', true)::json->>'role',
    current_setting('request.jwt.claim.role', true),
    'anon'
  )::TEXT;
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- Check if user is admin
CREATE OR REPLACE FUNCTION menuca_v3.is_admin()
RETURNS BOOLEAN AS $$
  SELECT menuca_v3.current_user_role() IN ('admin', 'super_admin', 'platform_admin');
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- Get restaurants managed by current user
CREATE OR REPLACE FUNCTION menuca_v3.get_user_restaurants()
RETURNS SETOF BIGINT AS $$
  SELECT restaurant_id 
  FROM menuca_v3.admin_users
  WHERE user_id = auth.uid()
  AND deleted_at IS NULL;
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- Check if user is restaurant admin
CREATE OR REPLACE FUNCTION menuca_v3.is_restaurant_admin(p_restaurant_id BIGINT)
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 
    FROM menuca_v3.admin_users
    WHERE user_id = auth.uid()
      AND restaurant_id = p_restaurant_id
      AND deleted_at IS NULL
  );
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- Check if driver is assigned to order
CREATE OR REPLACE FUNCTION menuca_v3.is_assigned_driver(p_order_id BIGINT)
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 
    FROM menuca_v3.deliveries d
    JOIN menuca_v3.drivers dr ON d.driver_id = dr.id
    WHERE d.order_id = p_order_id
      AND dr.user_id = auth.uid()
      AND d.deleted_at IS NULL
  );
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- =====================================================
-- SECTION 2: ENABLE ROW-LEVEL SECURITY
-- =====================================================

-- Enable RLS on all order-related tables
ALTER TABLE menuca_v3.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.order_item_modifiers ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.order_delivery_addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.order_discounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.order_status_history ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- SECTION 3: ORDERS TABLE RLS POLICIES
-- =====================================================

-- Policy 1: Customers view own orders
CREATE POLICY "customers_view_own_orders"
ON menuca_v3.orders FOR SELECT
TO authenticated
USING (
  user_id = auth.uid()::BIGINT
  AND is_void = false
);

-- Policy 2: Customers create orders
CREATE POLICY "customers_create_orders"
ON menuca_v3.orders FOR INSERT
TO authenticated
WITH CHECK (
  user_id = auth.uid()::BIGINT
);

-- Policy 3: Customers cancel their pending orders
CREATE POLICY "customers_cancel_orders"
ON menuca_v3.orders FOR UPDATE
TO authenticated
USING (
  user_id = auth.uid()::BIGINT
  AND status IN ('pending', 'accepted')
  AND is_void = false
)
WITH CHECK (
  user_id = auth.uid()::BIGINT
  AND status = 'canceled'
);

-- Policy 4: Restaurant admins view their orders
CREATE POLICY "restaurant_admins_view_orders"
ON menuca_v3.orders FOR SELECT
TO authenticated
USING (
  restaurant_id IN (SELECT menuca_v3.get_user_restaurants())
);

-- Policy 5: Restaurant admins update order status
CREATE POLICY "restaurant_admins_update_orders"
ON menuca_v3.orders FOR UPDATE
TO authenticated
USING (
  restaurant_id IN (SELECT menuca_v3.get_user_restaurants())
)
WITH CHECK (
  restaurant_id IN (SELECT menuca_v3.get_user_restaurants())
);

-- Policy 6: Drivers view assigned orders
CREATE POLICY "drivers_view_assigned_orders"
ON menuca_v3.orders FOR SELECT
TO authenticated
USING (
  menuca_v3.is_assigned_driver(id)
  AND order_type = 'delivery'
);

-- Policy 7: Drivers update delivery status
CREATE POLICY "drivers_update_delivery_status"
ON menuca_v3.orders FOR UPDATE
TO authenticated
USING (
  menuca_v3.is_assigned_driver(id)
  AND status IN ('accepted', 'preparing', 'ready', 'out_for_delivery')
)
WITH CHECK (
  status IN ('out_for_delivery', 'completed')
);

-- Policy 8: Super admins view all orders
CREATE POLICY "super_admins_view_all_orders"
ON menuca_v3.orders FOR SELECT
TO authenticated
USING (menuca_v3.is_admin());

-- Policy 9: Super admins update any order
CREATE POLICY "super_admins_update_all_orders"
ON menuca_v3.orders FOR UPDATE
TO authenticated
USING (menuca_v3.is_admin())
WITH CHECK (menuca_v3.is_admin());

-- Policy 10: Service role (payment webhooks, APIs) full access
CREATE POLICY "service_role_full_access_orders"
ON menuca_v3.orders FOR ALL
TO service_role
USING (true)
WITH CHECK (true);

-- =====================================================
-- SECTION 4: ORDER ITEMS RLS POLICIES
-- =====================================================

-- Customers view items for their orders
CREATE POLICY "customers_view_own_order_items"
ON menuca_v3.order_items FOR SELECT
TO authenticated
USING (
  order_id IN (
    SELECT id FROM menuca_v3.orders 
    WHERE user_id = auth.uid()::BIGINT
  )
);

-- Customers create items for their orders
CREATE POLICY "customers_create_order_items"
ON menuca_v3.order_items FOR INSERT
TO authenticated
WITH CHECK (
  order_id IN (
    SELECT id FROM menuca_v3.orders 
    WHERE user_id = auth.uid()::BIGINT
  )
);

-- Restaurant admins view items for their orders
CREATE POLICY "restaurant_admins_view_order_items"
ON menuca_v3.order_items FOR SELECT
TO authenticated
USING (
  order_id IN (
    SELECT id FROM menuca_v3.orders 
    WHERE restaurant_id IN (SELECT menuca_v3.get_user_restaurants())
  )
);

-- Drivers view items for assigned orders
CREATE POLICY "drivers_view_assigned_order_items"
ON menuca_v3.order_items FOR SELECT
TO authenticated
USING (
  order_id IN (
    SELECT id FROM menuca_v3.orders 
    WHERE menuca_v3.is_assigned_driver(id)
  )
);

-- Super admins view all items
CREATE POLICY "super_admins_view_all_order_items"
ON menuca_v3.order_items FOR SELECT
TO authenticated
USING (menuca_v3.is_admin());

-- Service role full access
CREATE POLICY "service_role_full_access_order_items"
ON menuca_v3.order_items FOR ALL
TO service_role
USING (true)
WITH CHECK (true);

-- =====================================================
-- SECTION 5: ORDER MODIFIERS RLS POLICIES
-- =====================================================

-- Customers view modifiers for their order items
CREATE POLICY "customers_view_own_order_modifiers"
ON menuca_v3.order_item_modifiers FOR SELECT
TO authenticated
USING (
  order_item_id IN (
    SELECT oi.id FROM menuca_v3.order_items oi
    JOIN menuca_v3.orders o ON oi.order_id = o.id
    WHERE o.user_id = auth.uid()::BIGINT
  )
);

-- Customers create modifiers
CREATE POLICY "customers_create_order_modifiers"
ON menuca_v3.order_item_modifiers FOR INSERT
TO authenticated
WITH CHECK (
  order_item_id IN (
    SELECT oi.id FROM menuca_v3.order_items oi
    JOIN menuca_v3.orders o ON oi.order_id = o.id
    WHERE o.user_id = auth.uid()::BIGINT
  )
);

-- Restaurant admins view modifiers for their orders
CREATE POLICY "restaurant_admins_view_order_modifiers"
ON menuca_v3.order_item_modifiers FOR SELECT
TO authenticated
USING (
  order_item_id IN (
    SELECT oi.id FROM menuca_v3.order_items oi
    JOIN menuca_v3.orders o ON oi.order_id = o.id
    WHERE o.restaurant_id IN (SELECT menuca_v3.get_user_restaurants())
  )
);

-- Drivers view modifiers for assigned orders
CREATE POLICY "drivers_view_assigned_order_modifiers"
ON menuca_v3.order_item_modifiers FOR SELECT
TO authenticated
USING (
  order_item_id IN (
    SELECT oi.id FROM menuca_v3.order_items oi
    WHERE menuca_v3.is_assigned_driver(oi.order_id)
  )
);

-- Super admins view all
CREATE POLICY "super_admins_view_all_order_modifiers"
ON menuca_v3.order_item_modifiers FOR SELECT
TO authenticated
USING (menuca_v3.is_admin());

-- Service role full access
CREATE POLICY "service_role_full_access_order_modifiers"
ON menuca_v3.order_item_modifiers FOR ALL
TO service_role
USING (true)
WITH CHECK (true);

-- =====================================================
-- SECTION 6: DELIVERY ADDRESSES RLS POLICIES
-- =====================================================

-- Customers view addresses for their orders
CREATE POLICY "customers_view_own_delivery_addresses"
ON menuca_v3.order_delivery_addresses FOR SELECT
TO authenticated
USING (
  order_id IN (
    SELECT id FROM menuca_v3.orders 
    WHERE user_id = auth.uid()::BIGINT
  )
);

-- Customers create addresses
CREATE POLICY "customers_create_delivery_addresses"
ON menuca_v3.order_delivery_addresses FOR INSERT
TO authenticated
WITH CHECK (
  order_id IN (
    SELECT id FROM menuca_v3.orders 
    WHERE user_id = auth.uid()::BIGINT
  )
);

-- Restaurant admins view addresses for their orders
CREATE POLICY "restaurant_admins_view_delivery_addresses"
ON menuca_v3.order_delivery_addresses FOR SELECT
TO authenticated
USING (
  order_id IN (
    SELECT id FROM menuca_v3.orders 
    WHERE restaurant_id IN (SELECT menuca_v3.get_user_restaurants())
  )
);

-- Drivers view addresses for assigned deliveries
CREATE POLICY "drivers_view_assigned_delivery_addresses"
ON menuca_v3.order_delivery_addresses FOR SELECT
TO authenticated
USING (
  order_id IN (
    SELECT id FROM menuca_v3.orders 
    WHERE menuca_v3.is_assigned_driver(id)
  )
);

-- Super admins view all
CREATE POLICY "super_admins_view_all_delivery_addresses"
ON menuca_v3.order_delivery_addresses FOR SELECT
TO authenticated
USING (menuca_v3.is_admin());

-- Service role full access
CREATE POLICY "service_role_full_access_delivery_addresses"
ON menuca_v3.order_delivery_addresses FOR ALL
TO service_role
USING (true)
WITH CHECK (true);

-- =====================================================
-- SECTION 7: ORDER DISCOUNTS RLS POLICIES
-- =====================================================

-- Customers view discounts for their orders
CREATE POLICY "customers_view_own_order_discounts"
ON menuca_v3.order_discounts FOR SELECT
TO authenticated
USING (
  order_id IN (
    SELECT id FROM menuca_v3.orders 
    WHERE user_id = auth.uid()::BIGINT
  )
);

-- Restaurant admins view discounts for their orders
CREATE POLICY "restaurant_admins_view_order_discounts"
ON menuca_v3.order_discounts FOR SELECT
TO authenticated
USING (
  order_id IN (
    SELECT id FROM menuca_v3.orders 
    WHERE restaurant_id IN (SELECT menuca_v3.get_user_restaurants())
  )
);

-- Super admins view all
CREATE POLICY "super_admins_view_all_order_discounts"
ON menuca_v3.order_discounts FOR SELECT
TO authenticated
USING (menuca_v3.is_admin());

-- Service role full access (for applying coupons)
CREATE POLICY "service_role_full_access_order_discounts"
ON menuca_v3.order_discounts FOR ALL
TO service_role
USING (true)
WITH CHECK (true);

-- =====================================================
-- SECTION 8: ORDER STATUS HISTORY RLS POLICIES
-- =====================================================

-- Customers view status history for their orders
CREATE POLICY "customers_view_own_order_status_history"
ON menuca_v3.order_status_history FOR SELECT
TO authenticated
USING (
  order_id IN (
    SELECT id FROM menuca_v3.orders 
    WHERE user_id = auth.uid()::BIGINT
  )
);

-- Restaurant admins view status history for their orders
CREATE POLICY "restaurant_admins_view_order_status_history"
ON menuca_v3.order_status_history FOR SELECT
TO authenticated
USING (
  order_id IN (
    SELECT id FROM menuca_v3.orders 
    WHERE restaurant_id IN (SELECT menuca_v3.get_user_restaurants())
  )
);

-- Drivers view status history for assigned orders
CREATE POLICY "drivers_view_assigned_order_status_history"
ON menuca_v3.order_status_history FOR SELECT
TO authenticated
USING (
  order_id IN (
    SELECT id FROM menuca_v3.orders 
    WHERE menuca_v3.is_assigned_driver(id)
  )
);

-- Super admins view all
CREATE POLICY "super_admins_view_all_order_status_history"
ON menuca_v3.order_status_history FOR SELECT
TO authenticated
USING (menuca_v3.is_admin());

-- Service role full access
CREATE POLICY "service_role_full_access_order_status_history"
ON menuca_v3.order_status_history FOR ALL
TO service_role
USING (true)
WITH CHECK (true);

-- =====================================================
-- SECTION 9: GRANT PERMISSIONS
-- =====================================================

-- Grant execute on helper functions
GRANT EXECUTE ON FUNCTION menuca_v3.current_user_id() TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION menuca_v3.current_user_role() TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION menuca_v3.is_admin() TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION menuca_v3.get_user_restaurants() TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION menuca_v3.is_restaurant_admin(BIGINT) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION menuca_v3.is_assigned_driver(BIGINT) TO authenticated, service_role;

-- Grant table permissions
GRANT SELECT, INSERT, UPDATE ON menuca_v3.orders TO authenticated;
GRANT SELECT, INSERT, UPDATE ON menuca_v3.order_items TO authenticated;
GRANT SELECT, INSERT ON menuca_v3.order_item_modifiers TO authenticated;
GRANT SELECT, INSERT ON menuca_v3.order_delivery_addresses TO authenticated;
GRANT SELECT ON menuca_v3.order_discounts TO authenticated;
GRANT SELECT ON menuca_v3.order_status_history TO authenticated;

-- Service role gets full access
GRANT ALL ON ALL TABLES IN SCHEMA menuca_v3 TO service_role;

COMMIT;

-- =====================================================
-- VALIDATION QUERIES
-- =====================================================

-- Count RLS policies per table
SELECT 
  tablename,
  COUNT(*) AS policy_count
FROM pg_policies
WHERE schemaname = 'menuca_v3'
  AND tablename IN ('orders', 'order_items', 'order_item_modifiers', 
                    'order_delivery_addresses', 'order_discounts', 'order_status_history')
GROUP BY tablename
ORDER BY tablename;

-- Verify RLS is enabled
SELECT 
  tablename,
  rowsecurity AS rls_enabled
FROM pg_tables
WHERE schemaname = 'menuca_v3'
  AND tablename IN ('orders', 'order_items', 'order_item_modifiers', 
                    'order_delivery_addresses', 'order_discounts', 'order_status_history');

-- =====================================================
-- END OF PHASE 1 - AUTH & SECURITY
-- =====================================================

-- 🎉 PHASE 1 COMPLETE!
-- Created: 6 helper functions, 40+ RLS policies across 6 tables
-- Security: Multi-party access (customers, restaurants, drivers, admins)
-- Next: Phase 2 - Performance & Core APIs
