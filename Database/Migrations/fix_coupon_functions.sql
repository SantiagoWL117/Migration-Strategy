-- Fix broken coupon functions after schema changes
-- Run this migration to update functions that reference deleted columns

-- ============================================================================
-- FIX: get_coupons_i18n
-- Removed: pc.name, pc.description, pc.is_used (columns deleted)
-- ============================================================================
DROP FUNCTION IF EXISTS menuca_v3.get_coupons_i18n(bigint, character varying);

CREATE OR REPLACE FUNCTION menuca_v3.get_coupons_i18n(
    p_restaurant_id bigint, 
    p_language character varying DEFAULT 'en'::character varying
)
RETURNS TABLE(
    coupon_id bigint, 
    code character varying, 
    name character varying, 
    description text, 
    terms_and_conditions text, 
    discount_type character varying, 
    discount_amount numeric, 
    minimum_purchase numeric, 
    redeem_value_limit numeric, 
    valid_from_at timestamp with time zone, 
    valid_until_at timestamp with time zone, 
    max_redemptions integer, 
    current_usage_count integer, 
    is_active boolean, 
    is_one_time_use boolean, 
    is_reorder_coupon boolean, 
    language_code character varying
)
LANGUAGE plpgsql
STABLE SECURITY DEFINER
AS $function$
BEGIN
    RETURN QUERY
    SELECT 
        pc.id::BIGINT AS coupon_id,
        pc.code::VARCHAR,
        -- Use bilingual columns with fallback
        CASE 
            WHEN p_language = 'fr' AND pc.name_fr IS NOT NULL THEN pc.name_fr
            ELSE pc.name_en
        END::VARCHAR AS name,
        CASE 
            WHEN p_language = 'fr' AND pc.description_fr IS NOT NULL THEN pc.description_fr
            ELSE pc.description_en
        END::TEXT AS description,
        ''::TEXT AS terms_and_conditions,
        pc.discount_type::VARCHAR,
        pc.discount_amount,
        pc.minimum_purchase,
        pc.redeem_value_limit,
        pc.valid_from_at,
        pc.valid_until_at,
        pc.max_redemptions,
        (SELECT COUNT(*)::INTEGER FROM menuca_v3.coupon_usage_log cul WHERE cul.coupon_id = pc.id) AS current_usage_count,
        pc.is_active,
        pc.is_one_time_use,
        pc.is_reorder_coupon,
        p_language::VARCHAR AS language_code
    FROM menuca_v3.promotional_coupons pc
    WHERE (pc.restaurant_id = p_restaurant_id OR pc.restaurant_id IS NULL)
    AND pc.is_active = TRUE
    AND pc.deleted_at IS NULL
    AND (pc.valid_from_at IS NULL OR pc.valid_from_at <= NOW())
    AND (pc.valid_until_at IS NULL OR pc.valid_until_at >= NOW())
    ORDER BY pc.created_at DESC;
END;
$function$;

-- ============================================================================
-- FIX: get_top_coupons
-- Removed: pc.name (column deleted)
-- ============================================================================
CREATE OR REPLACE FUNCTION menuca_v3.get_top_coupons(
    p_restaurant_id bigint, 
    p_limit integer DEFAULT 10, 
    p_language character varying DEFAULT 'en'::character varying
)
RETURNS TABLE(
    coupon_id bigint, 
    code character varying, 
    name character varying, 
    redemption_count integer, 
    total_discount numeric, 
    unique_customers integer, 
    last_used_at timestamp with time zone
)
LANGUAGE plpgsql
STABLE SECURITY DEFINER
AS $function$
BEGIN
    RETURN QUERY
    SELECT 
        pc.id::bigint as coupon_id,
        pc.code::varchar,
        CASE 
            WHEN p_language = 'fr' AND pc.name_fr IS NOT NULL THEN pc.name_fr
            ELSE pc.name_en
        END::varchar as name,
        COUNT(cul.id)::integer as redemption_count,
        COALESCE(SUM(cul.discount_applied), 0)::numeric as total_discount,
        COUNT(DISTINCT cul.user_id)::integer as unique_customers,
        MAX(cul.used_at)::timestamptz as last_used_at
    FROM menuca_v3.promotional_coupons pc
    LEFT JOIN menuca_v3.coupon_usage_log cul ON pc.id = cul.coupon_id
    WHERE pc.restaurant_id = p_restaurant_id
      AND pc.deleted_at IS NULL
    GROUP BY pc.id, pc.code, pc.name_en, pc.name_fr
    HAVING COUNT(cul.id) > 0
    ORDER BY redemption_count DESC, total_discount DESC
    LIMIT p_limit;
END;
$function$;
