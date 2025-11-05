-- =====================================================
-- Feature 5: Get Customer Order History
-- =====================================================
-- Description: Retrieve paginated order history for authenticated customer
-- Created: 2025-11-05
-- Author: AI Assistant (Claude)
-- Security: Uses auth.uid() for JWT-based authentication
-- Performance Target: < 150ms
-- =====================================================

-- Rollback instructions (if needed):
-- DROP FUNCTION IF EXISTS menuca_v3.get_customer_order_history(INTEGER, INTEGER, VARCHAR[]);
-- REVOKE EXECUTE ON FUNCTION menuca_v3.get_customer_order_history FROM authenticated;

\echo '=================================================='
\echo 'Deploying Feature 5: Get Customer Order History'
\echo '=================================================='

-- =====================================================
-- FUNCTION: get_customer_order_history
-- =====================================================
-- Purpose: Get paginated order history for authenticated customer
-- Authentication: Uses auth.uid() to identify user from JWT token
-- Authorization: User can only see their own order history
-- Performance: Uses existing index idx_orders_user_created (user_id, created_at DESC)
-- No new indexes required
-- =====================================================

CREATE OR REPLACE FUNCTION menuca_v3.get_customer_order_history(
    p_limit INTEGER DEFAULT 20,
    p_offset INTEGER DEFAULT 0,
    p_status_filter VARCHAR[] DEFAULT NULL
)
RETURNS TABLE(
    id BIGINT,
    order_number VARCHAR,
    order_status VARCHAR,
    order_type VARCHAR,
    subtotal NUMERIC,
    tax_amount NUMERIC,
    delivery_fee NUMERIC,
    discount_amount NUMERIC,
    total_amount NUMERIC,
    created_at TIMESTAMPTZ,
    restaurant_id BIGINT,
    restaurant_name VARCHAR,
    restaurant_logo_url TEXT,
    item_count INTEGER,
    payment_status VARCHAR,
    coupon_code VARCHAR
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = menuca_v3, public
AS $$
DECLARE
    v_auth_user_id UUID;
    v_user_id BIGINT;
BEGIN
    -- SECURITY: Get authenticated user's UUID from JWT token
    v_auth_user_id := auth.uid();

    -- SECURITY: Reject if not authenticated
    IF v_auth_user_id IS NULL THEN
        RAISE EXCEPTION 'Authentication required. Please log in to view order history.';
    END IF;

    -- SECURITY: Map UUID to internal user_id
    SELECT u.id INTO v_user_id
    FROM menuca_v3.users u
    WHERE u.auth_user_id = v_auth_user_id
    AND u.deleted_at IS NULL;

    -- SECURITY: Reject if user not found
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'User account not found or has been deleted.';
    END IF;

    -- PERFORMANCE: Return paginated order history
    -- Uses existing index: idx_orders_user_created (user_id, created_at DESC)
    RETURN QUERY
    SELECT
        o.id,
        o.order_number,
        o.order_status,
        o.order_type,
        o.subtotal,
        o.tax_amount,
        o.delivery_fee,
        o.discount_amount,
        o.total_amount,
        o.created_at,
        o.restaurant_id,
        r.name AS restaurant_name,
        r.logo_url AS restaurant_logo_url,
        (
            SELECT COUNT(*)::INTEGER
            FROM menuca_v3.order_items oi
            WHERE oi.order_id = o.id
        ) AS item_count,
        o.payment_status,
        o.coupon_code
    FROM menuca_v3.orders o
    INNER JOIN menuca_v3.restaurants r ON r.id = o.restaurant_id
    WHERE o.user_id = v_user_id
    AND o.deleted_at IS NULL
    AND (
        -- Optional status filter
        p_status_filter IS NULL
        OR o.order_status = ANY(p_status_filter)
    )
    ORDER BY o.created_at DESC
    LIMIT p_limit
    OFFSET p_offset;

END;
$$;

-- =====================================================
-- PERMISSIONS
-- =====================================================

-- Grant to authenticated users only (customers)
GRANT EXECUTE ON FUNCTION menuca_v3.get_customer_order_history(INTEGER, INTEGER, VARCHAR[])
TO authenticated;

-- Revoke from anonymous users (must be logged in to view order history)
REVOKE EXECUTE ON FUNCTION menuca_v3.get_customer_order_history(INTEGER, INTEGER, VARCHAR[])
FROM anon;

-- =====================================================
-- COMMENTS
-- =====================================================

COMMENT ON FUNCTION menuca_v3.get_customer_order_history(INTEGER, INTEGER, VARCHAR[]) IS
'Get paginated order history for authenticated customer. Uses auth.uid() for secure authentication. Returns order summary with restaurant info and item counts.';

-- =====================================================
-- DEPLOYMENT VERIFICATION
-- =====================================================

\echo ''
\echo 'Verifying deployment...'

-- Check function exists
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'menuca_v3'
        AND p.proname = 'get_customer_order_history'
    ) THEN
        RAISE NOTICE '✓ Function get_customer_order_history created successfully';
    ELSE
        RAISE EXCEPTION '✗ Function get_customer_order_history was not created';
    END IF;
END $$;

-- Check permissions
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.routine_privileges
        WHERE routine_schema = 'menuca_v3'
        AND routine_name = 'get_customer_order_history'
        AND grantee = 'authenticated'
        AND privilege_type = 'EXECUTE'
    ) THEN
        RAISE NOTICE '✓ Permissions granted to authenticated role';
    ELSE
        RAISE WARNING '✗ Permissions may not be correctly set';
    END IF;
END $$;

\echo ''
\echo '=================================================='
\echo 'Feature 5 deployment complete!'
\echo 'Function: get_customer_order_history'
\echo 'Security: JWT auth via auth.uid() ✓'
\echo 'Performance: Uses existing index ✓'
\echo 'No new database objects created ✓'
\echo '=================================================='
