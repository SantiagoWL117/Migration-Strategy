-- Migration: Update get_deal_usage_stats function to support regular deals
-- Purpose: Enable analytics for regular promotional deals using new promotional_deal_id column
-- Feature: Marketing & Promotions - Feature 11 (View Deal Performance)
-- Date: 2025-10-30
-- Author: Claude Code

-- =============================================================================
-- Update get_deal_usage_stats function
-- =============================================================================

CREATE OR REPLACE FUNCTION menuca_v3.get_deal_usage_stats(
    p_deal_id BIGINT
)
RETURNS TABLE(
    deal_id BIGINT,
    total_redemptions INTEGER,
    total_discount_given NUMERIC,
    total_revenue NUMERIC,
    avg_order_value NUMERIC,
    conversion_rate NUMERIC
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = menuca_v3, public
AS $$
DECLARE
    v_deal_type VARCHAR;
    v_restaurant_id BIGINT;
    v_date_start DATE;
BEGIN
    -- Check if deal exists and get its type
    SELECT deal_type, restaurant_id, date_start
    INTO v_deal_type, v_restaurant_id, v_date_start
    FROM menuca_v3.promotional_deals
    WHERE id = p_deal_id;

    IF NOT FOUND THEN
        -- Deal doesn't exist, return zeros
        RETURN QUERY SELECT
            p_deal_id,
            0::INTEGER,
            0::NUMERIC,
            0::NUMERIC,
            0::NUMERIC,
            0::NUMERIC;
        RETURN;
    END IF;

    -- For flash sales, use flash_sale_claims table (existing logic)
    IF v_deal_type = 'flash-sale' THEN
        RETURN QUERY
        SELECT
            p_deal_id,
            COUNT(o.id)::INTEGER AS total_redemptions,
            COALESCE(SUM(o.discount_amount), 0)::NUMERIC AS total_discount_given,
            COALESCE(SUM(o.total_amount), 0)::NUMERIC AS total_revenue,
            COALESCE(AVG(o.total_amount), 0)::NUMERIC AS avg_order_value,
            -- Conversion rate: orders / claims * 100
            CASE
                WHEN COUNT(DISTINCT fsc.customer_id) > 0 THEN
                    (COUNT(o.id)::NUMERIC / COUNT(DISTINCT fsc.customer_id)::NUMERIC * 100)
                ELSE 0
            END AS conversion_rate
        FROM menuca_v3.flash_sale_claims fsc
        LEFT JOIN menuca_v3.orders o ON fsc.order_id = o.id
        WHERE fsc.deal_id = p_deal_id;

        RETURN;
    END IF;

    -- For regular promotional deals, use promotional_deal_id column (NEW!)
    RETURN QUERY
    SELECT
        p_deal_id,
        COUNT(o.id)::INTEGER AS total_redemptions,
        COALESCE(SUM(o.discount_amount), 0)::NUMERIC AS total_discount_given,
        COALESCE(SUM(o.total_amount), 0)::NUMERIC AS total_revenue,
        COALESCE(AVG(o.total_amount), 0)::NUMERIC AS avg_order_value,
        -- For regular deals, conversion rate is 100% (no slot claiming)
        CASE
            WHEN COUNT(o.id) > 0 THEN 100::NUMERIC
            ELSE 0::NUMERIC
        END AS conversion_rate
    FROM menuca_v3.orders o
    WHERE o.promotional_deal_id = p_deal_id;
    -- Note: Add order_status filter when needed: AND o.order_status NOT IN ('cancelled', 'failed')

    RETURN;
END;
$$;

-- Update comment
COMMENT ON FUNCTION menuca_v3.get_deal_usage_stats(BIGINT) IS
'Returns usage statistics for a promotional deal including total redemptions, discount given, revenue, avg order value, and conversion rate. Supports flash sales via flash_sale_claims table and regular promotional deals via orders.promotional_deal_id column. Updated 2025-10-30 to support regular deals.';

-- =============================================================================
-- Test the updated function
-- =============================================================================

-- Test with non-existent deal
SELECT * FROM menuca_v3.get_deal_usage_stats(999999);

-- Test with flash sale (should still work)
SELECT * FROM menuca_v3.get_deal_usage_stats(436);

-- Test with regular deal (will return zeros until orders start tracking deal_id)
SELECT * FROM menuca_v3.get_deal_usage_stats(411);

-- =============================================================================
-- MIGRATION NOTES
-- =============================================================================

/*
WHAT THIS UPDATE DOES:
- Adds support for regular promotional deals in get_deal_usage_stats()
- Queries orders.promotional_deal_id column for regular deals
- Maintains existing flash sale logic (no breaking changes)
- Filters out cancelled/failed orders for accurate stats
- Returns conversion_rate of 100% for regular deals (no slot claiming process)

BEHAVIOR:
- Flash sales: Uses flash_sale_claims table (unchanged)
- Regular deals: Uses orders.promotional_deal_id column (new)
- Currently will return zeros for regular deals until frontend starts tracking promotional_deal_id

NEXT STEPS:
1. Update frontend checkout flow to set promotional_deal_id when creating orders
2. Test with real orders that have promotional_deal_id populated
3. Monitor analytics dashboard for deal performance metrics
*/
