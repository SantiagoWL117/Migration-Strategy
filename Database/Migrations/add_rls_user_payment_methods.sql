-- Add RLS policies to user_payment_methods table
-- Issue: Table had no RLS policies (security vulnerability)
-- Date: 2026-01-23

-- 1. Enable RLS on table
ALTER TABLE menuca_v3.user_payment_methods ENABLE ROW LEVEL SECURITY;

-- 2. SELECT policy - Users can view their own payment methods
CREATE POLICY payment_methods_select_own ON menuca_v3.user_payment_methods
    FOR SELECT TO authenticated
    USING (user_id IN (SELECT id FROM menuca_v3.users WHERE auth_user_id = auth.uid()));

-- 3. INSERT policy - Users can add their own payment methods
CREATE POLICY payment_methods_insert_own ON menuca_v3.user_payment_methods
    FOR INSERT TO authenticated
    WITH CHECK (user_id IN (SELECT id FROM menuca_v3.users WHERE auth_user_id = auth.uid()));

-- 4. UPDATE policy - Users can update their own payment methods
CREATE POLICY payment_methods_update_own ON menuca_v3.user_payment_methods
    FOR UPDATE TO authenticated
    USING (user_id IN (SELECT id FROM menuca_v3.users WHERE auth_user_id = auth.uid()));

-- 5. DELETE policy - Users can delete their own payment methods
CREATE POLICY payment_methods_delete_own ON menuca_v3.user_payment_methods
    FOR DELETE TO authenticated
    USING (user_id IN (SELECT id FROM menuca_v3.users WHERE auth_user_id = auth.uid()));

-- 6. Service role full access for backend operations
CREATE POLICY payment_methods_service_role_all ON menuca_v3.user_payment_methods
    FOR ALL TO service_role
    USING (true) WITH CHECK (true);

-- Add table comment for documentation
COMMENT ON TABLE menuca_v3.user_payment_methods IS 'Stored Stripe payment methods for users. RLS enforced - users can only access their own records.';
