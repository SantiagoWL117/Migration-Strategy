-- Feature 12: Promotion Analytics Dashboard
-- Creates three SQL functions for comprehensive promotion analytics
-- Date: 2025-10-30
-- Author: Claude Code

-- =============================================================================
-- FUNCTION 1: get_promotion_analytics
-- Purpose: Comprehensive promotion performance report for a date range
-- =============================================================================

CREATE OR REPLACE FUNCTION menuca_v3.get_promotion_analytics(
    p_restaurant_id BIGINT,
    p_start_date DATE,
    p_end_date DATE
)
RETURNS TABLE(
    -- Deal Statistics
    total_deals INTEGER,
    active_deals INTEGER,
    deal_redemptions INTEGER,
    deal_discount_given NUMERIC,
    deal_revenue NUMERIC,

    -- Coupon Statistics
    total_coupons INTEGER,
    active_coupons INTEGER,
    coupon_redemptions INTEGER,
    coupon_discount_given NUMERIC,
    coupon_revenue NUMERIC,

    -- Combined Statistics
    total_promotion_orders INTEGER,
    total_non_promotion_orders INTEGER,
    total_discount_given NUMERIC,
    total_revenue NUMERIC,
    avg_discount_per_order NUMERIC,
    promotion_adoption_rate NUMERIC
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = menuca_v3, public
AS $$
DECLARE
    v_deal_redemptions INTEGER;
    v_deal_discount NUMERIC;
    v_deal_revenue NUMERIC;
    v_coupon_redemptions INTEGER;
    v_coupon_discount NUMERIC;
    v_coupon_revenue NUMERIC;
    v_total_orders INTEGER;
    v_non_promo_orders INTEGER;
    v_total_deals INTEGER;
    v_active_deals INTEGER;
    v_total_coupons INTEGER;
    v_active_coupons INTEGER;
BEGIN
    -- Count total and active deals for restaurant
    SELECT
        COUNT(*),
        COUNT(*) FILTER (WHERE is_enabled = true)
    INTO v_total_deals, v_active_deals
    FROM menuca_v3.promotional_deals
    WHERE restaurant_id = p_restaurant_id
    AND date_start <= p_end_date
    AND (date_stop IS NULL OR date_stop >= p_start_date);

    -- Count total and active coupons for restaurant
    SELECT
        COUNT(*),
        COUNT(*) FILTER (WHERE is_active = true)
    INTO v_total_coupons, v_active_coupons
    FROM menuca_v3.promotional_coupons
    WHERE restaurant_id = p_restaurant_id
    AND valid_from_at::DATE <= p_end_date
    AND (valid_until_at IS NULL OR valid_until_at::DATE >= p_start_date);

    -- Get deal statistics from orders
    SELECT
        COUNT(*),
        COALESCE(SUM(discount_amount), 0),
        COALESCE(SUM(total_amount), 0)
    INTO v_deal_redemptions, v_deal_discount, v_deal_revenue
    FROM menuca_v3.orders
    WHERE restaurant_id = p_restaurant_id
    AND promotional_deal_id IS NOT NULL
    AND created_at::DATE BETWEEN p_start_date AND p_end_date;

    -- Get coupon statistics from coupon_usage_log
    SELECT
        COUNT(*),
        COALESCE(SUM(cul.discount_applied), 0),
        COALESCE(SUM(o.total_amount), 0)
    INTO v_coupon_redemptions, v_coupon_discount, v_coupon_revenue
    FROM menuca_v3.coupon_usage_log cul
    JOIN menuca_v3.promotional_coupons pc ON cul.coupon_id = pc.id
    LEFT JOIN menuca_v3.orders o ON cul.order_id = o.id
    WHERE pc.restaurant_id = p_restaurant_id
    AND cul.used_at::DATE BETWEEN p_start_date AND p_end_date;

    -- Get total orders for restaurant in date range
    SELECT COUNT(*)
    INTO v_total_orders
    FROM menuca_v3.orders
    WHERE restaurant_id = p_restaurant_id
    AND created_at::DATE BETWEEN p_start_date AND p_end_date;

    -- Calculate non-promotion orders
    v_non_promo_orders := v_total_orders - (v_deal_redemptions + v_coupon_redemptions);

    -- Return comprehensive analytics
    RETURN QUERY SELECT
        v_total_deals,
        v_active_deals,
        v_deal_redemptions,
        v_deal_discount,
        v_deal_revenue,

        v_total_coupons,
        v_active_coupons,
        v_coupon_redemptions,
        v_coupon_discount,
        v_coupon_revenue,

        (v_deal_redemptions + v_coupon_redemptions)::INTEGER AS total_promotion_orders,
        v_non_promo_orders,
        (v_deal_discount + v_coupon_discount)::NUMERIC AS total_discount_given,
        (v_deal_revenue + v_coupon_revenue)::NUMERIC AS total_revenue,

        -- Average discount per promotion order
        CASE
            WHEN (v_deal_redemptions + v_coupon_redemptions) > 0 THEN
                ((v_deal_discount + v_coupon_discount) / (v_deal_redemptions + v_coupon_redemptions))::NUMERIC
            ELSE 0
        END AS avg_discount_per_order,

        -- Promotion adoption rate (% of orders using promotions)
        CASE
            WHEN v_total_orders > 0 THEN
                (((v_deal_redemptions + v_coupon_redemptions)::NUMERIC / v_total_orders::NUMERIC) * 100)
            ELSE 0
        END AS promotion_adoption_rate;
END;
$$;

COMMENT ON FUNCTION menuca_v3.get_promotion_analytics(BIGINT, DATE, DATE) IS
'Returns comprehensive promotion analytics for a restaurant within a date range, including deal stats, coupon stats, and combined metrics.';

-- =============================================================================
-- FUNCTION 2: get_coupon_redemption_rate
-- Purpose: Calculate redemption rate and usage stats for a specific coupon
-- =============================================================================

CREATE OR REPLACE FUNCTION menuca_v3.get_coupon_redemption_rate(
    p_coupon_id BIGINT
)
RETURNS TABLE(
    coupon_id BIGINT,
    coupon_code VARCHAR,
    coupon_name VARCHAR,
    total_redemptions INTEGER,
    unique_users INTEGER,
    total_discount_given NUMERIC,
    total_revenue NUMERIC,
    avg_order_value NUMERIC,
    usage_limit INTEGER,
    usage_remaining INTEGER,
    is_active BOOLEAN,
    redemption_rate_percent NUMERIC
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = menuca_v3, public
AS $$
DECLARE
    v_coupon_code VARCHAR;
    v_coupon_name VARCHAR;
    v_usage_limit INTEGER;
    v_is_active BOOLEAN;
    v_total_redemptions INTEGER;
    v_unique_users INTEGER;
    v_total_discount NUMERIC;
    v_total_revenue NUMERIC;
    v_avg_order NUMERIC;
BEGIN
    -- Get coupon details
    SELECT
        pc.code,
        pc.name,
        pc.max_redemptions,
        pc.is_active
    INTO v_coupon_code, v_coupon_name, v_usage_limit, v_is_active
    FROM menuca_v3.promotional_coupons pc
    WHERE pc.id = p_coupon_id;

    IF NOT FOUND THEN
        -- Return zeros for non-existent coupon
        RETURN QUERY SELECT
            p_coupon_id,
            NULL::VARCHAR,
            NULL::VARCHAR,
            0::INTEGER,
            0::INTEGER,
            0::NUMERIC,
            0::NUMERIC,
            0::NUMERIC,
            0::INTEGER,
            0::INTEGER,
            false::BOOLEAN,
            0::NUMERIC;
        RETURN;
    END IF;

    -- Get redemption statistics from coupon_usage_log
    SELECT
        COUNT(*),
        COUNT(DISTINCT cul.user_id),
        COALESCE(SUM(cul.discount_applied), 0),
        COALESCE(SUM(o.total_amount), 0),
        COALESCE(AVG(o.total_amount), 0)
    INTO v_total_redemptions, v_unique_users, v_total_discount, v_total_revenue, v_avg_order
    FROM menuca_v3.coupon_usage_log cul
    LEFT JOIN menuca_v3.orders o ON cul.order_id = o.id
    WHERE cul.coupon_id = p_coupon_id;

    -- Return coupon stats
    RETURN QUERY SELECT
        p_coupon_id,
        v_coupon_code,
        v_coupon_name,
        v_total_redemptions,
        v_unique_users,
        v_total_discount,
        v_total_revenue,
        v_avg_order,
        v_usage_limit,
        CASE
            WHEN v_usage_limit IS NOT NULL THEN GREATEST(0, v_usage_limit - v_total_redemptions)
            ELSE NULL
        END AS usage_remaining,
        v_is_active,
        -- Redemption rate: (actual redemptions / usage limit) * 100
        CASE
            WHEN v_usage_limit IS NOT NULL AND v_usage_limit > 0 THEN
                ((v_total_redemptions::NUMERIC / v_usage_limit::NUMERIC) * 100)
            WHEN v_total_redemptions > 0 THEN 100::NUMERIC
            ELSE 0::NUMERIC
        END AS redemption_rate_percent;
END;
$$;

COMMENT ON FUNCTION menuca_v3.get_coupon_redemption_rate(BIGINT) IS
'Returns detailed usage statistics and redemption rate for a specific coupon, including total redemptions, unique users, revenue impact, and usage limit tracking.';

-- =============================================================================
-- FUNCTION 3: get_popular_deals
-- Purpose: Get top performing deals for a restaurant by redemption count
-- =============================================================================

CREATE OR REPLACE FUNCTION menuca_v3.get_popular_deals(
    p_restaurant_id BIGINT,
    p_limit INTEGER DEFAULT 10
)
RETURNS TABLE(
    deal_id INTEGER,
    deal_name VARCHAR,
    deal_type VARCHAR,
    discount_percent NUMERIC,
    discount_amount NUMERIC,
    is_enabled BOOLEAN,
    date_start DATE,
    date_stop DATE,
    total_redemptions INTEGER,
    total_discount_given NUMERIC,
    total_revenue NUMERIC,
    avg_order_value NUMERIC
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = menuca_v3, public
AS $$
BEGIN
    RETURN QUERY
    SELECT
        pd.id AS deal_id,
        pd.name AS deal_name,
        pd.deal_type,
        pd.discount_percent,
        pd.discount_amount,
        pd.is_enabled,
        pd.date_start,
        pd.date_stop,

        -- Statistics from orders (for regular deals) or flash_sale_claims (for flash sales)
        CASE
            WHEN pd.deal_type = 'flash-sale' THEN
                (SELECT COUNT(o.id)::INTEGER
                 FROM menuca_v3.flash_sale_claims fsc
                 LEFT JOIN menuca_v3.orders o ON fsc.order_id = o.id
                 WHERE fsc.deal_id = pd.id)
            ELSE
                (SELECT COUNT(o.id)::INTEGER
                 FROM menuca_v3.orders o
                 WHERE o.promotional_deal_id = pd.id)
        END AS total_redemptions,

        CASE
            WHEN pd.deal_type = 'flash-sale' THEN
                (SELECT COALESCE(SUM(o.discount_amount), 0)::NUMERIC
                 FROM menuca_v3.flash_sale_claims fsc
                 LEFT JOIN menuca_v3.orders o ON fsc.order_id = o.id
                 WHERE fsc.deal_id = pd.id)
            ELSE
                (SELECT COALESCE(SUM(o.discount_amount), 0)::NUMERIC
                 FROM menuca_v3.orders o
                 WHERE o.promotional_deal_id = pd.id)
        END AS total_discount_given,

        CASE
            WHEN pd.deal_type = 'flash-sale' THEN
                (SELECT COALESCE(SUM(o.total_amount), 0)::NUMERIC
                 FROM menuca_v3.flash_sale_claims fsc
                 LEFT JOIN menuca_v3.orders o ON fsc.order_id = o.id
                 WHERE fsc.deal_id = pd.id)
            ELSE
                (SELECT COALESCE(SUM(o.total_amount), 0)::NUMERIC
                 FROM menuca_v3.orders o
                 WHERE o.promotional_deal_id = pd.id)
        END AS total_revenue,

        CASE
            WHEN pd.deal_type = 'flash-sale' THEN
                (SELECT COALESCE(AVG(o.total_amount), 0)::NUMERIC
                 FROM menuca_v3.flash_sale_claims fsc
                 LEFT JOIN menuca_v3.orders o ON fsc.order_id = o.id
                 WHERE fsc.deal_id = pd.id)
            ELSE
                (SELECT COALESCE(AVG(o.total_amount), 0)::NUMERIC
                 FROM menuca_v3.orders o
                 WHERE o.promotional_deal_id = pd.id)
        END AS avg_order_value

    FROM menuca_v3.promotional_deals pd
    WHERE pd.restaurant_id = p_restaurant_id
    ORDER BY total_redemptions DESC, pd.created_at DESC
    LIMIT p_limit;
END;
$$;

COMMENT ON FUNCTION menuca_v3.get_popular_deals(BIGINT, INTEGER) IS
'Returns the top performing promotional deals for a restaurant, sorted by total redemptions. Supports both regular deals and flash sales. Default limit is 10 deals.';

-- =============================================================================
-- Grant permissions
-- =============================================================================

GRANT EXECUTE ON FUNCTION menuca_v3.get_promotion_analytics(BIGINT, DATE, DATE) TO authenticated;
GRANT EXECUTE ON FUNCTION menuca_v3.get_coupon_redemption_rate(BIGINT) TO authenticated;
GRANT EXECUTE ON FUNCTION menuca_v3.get_popular_deals(BIGINT, INTEGER) TO authenticated;
