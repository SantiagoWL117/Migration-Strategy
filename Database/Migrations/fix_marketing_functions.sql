-- ============================================================================
-- FIX BROKEN MARKETING FUNCTIONS
-- Date: 2026-01-27
-- Purpose: Fix 3 functions that reference deleted columns/tables
-- ============================================================================

-- ============================================================================
-- FIX 1: get_active_deals
-- Problem: References deleted columns: description, image_url
-- Fix: Use name_en and description_en, remove image_url
-- ============================================================================

DROP FUNCTION IF EXISTS menuca_v3.get_active_deals(bigint, timestamp with time zone);

CREATE OR REPLACE FUNCTION menuca_v3.get_active_deals(
    p_restaurant_id bigint, 
    p_current_time timestamp with time zone DEFAULT now()
)
RETURNS TABLE(
    deal_id integer, 
    restaurant_id integer, 
    deal_name character varying, 
    description text, 
    deal_type character varying, 
    discount_percent numeric, 
    discount_amount numeric, 
    minimum_purchase numeric, 
    date_start date, 
    date_stop date, 
    time_start time without time zone, 
    time_stop time without time zone, 
    active_days jsonb, 
    promo_code character varying, 
    display_order integer, 
    is_first_order_only boolean
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'menuca_v3', 'public'
AS $function$
BEGIN
    RETURN QUERY
    SELECT
        pd.id,
        pd.restaurant_id,
        pd.name_en,
        pd.description_en,
        pd.deal_type,
        pd.discount_percent,
        pd.discount_amount,
        pd.minimum_purchase,
        pd.date_start,
        pd.date_stop,
        pd.time_start,
        pd.time_stop,
        pd.active_days,
        pd.promo_code,
        pd.display_order,
        pd.is_first_order_only
    FROM menuca_v3.promotional_deals pd
    WHERE pd.restaurant_id = p_restaurant_id::INTEGER
        AND pd.is_enabled = TRUE
        AND (pd.date_start IS NULL OR pd.date_start <= p_current_time::DATE)
        AND (pd.date_stop IS NULL OR pd.date_stop >= p_current_time::DATE)
    ORDER BY
        pd.display_order ASC NULLS LAST,
        pd.date_start DESC;
END;
$function$;

-- ============================================================================
-- FIX 2: get_deals_i18n
-- Problem: References deleted columns: type, description (fallback), image_url
-- Fix: Remove type and image_url, fix description fallback
-- ============================================================================

DROP FUNCTION IF EXISTS menuca_v3.get_deals_i18n(bigint, character varying, character varying);

CREATE OR REPLACE FUNCTION menuca_v3.get_deals_i18n(
    p_restaurant_id bigint, 
    p_language character varying DEFAULT 'en'::character varying, 
    p_service_type character varying DEFAULT NULL::character varying
)
RETURNS TABLE(
    id integer, 
    restaurant_id integer, 
    deal_type character varying, 
    discount_percent numeric, 
    discount_amount numeric, 
    minimum_purchase numeric, 
    date_start date, 
    date_stop date, 
    is_enabled boolean, 
    name character varying, 
    description text, 
    availability_types jsonb, 
    promo_code character varying, 
    display_order integer, 
    is_currently_active boolean
)
LANGUAGE plpgsql
STABLE SECURITY DEFINER
AS $function$
BEGIN
    RETURN QUERY
    SELECT 
        pd.id,
        pd.restaurant_id,
        pd.deal_type,
        pd.discount_percent,
        pd.discount_amount,
        pd.minimum_purchase,
        pd.date_start,
        pd.date_stop,
        pd.is_enabled,
        -- Bilingual name with French fallback to English
        CASE 
            WHEN p_language = 'fr' AND pd.name_fr IS NOT NULL THEN pd.name_fr
            ELSE COALESCE(pd.name_en, pd.name)
        END as name,
        -- Bilingual description with French fallback to English
        CASE 
            WHEN p_language = 'fr' AND pd.description_fr IS NOT NULL THEN pd.description_fr
            ELSE pd.description_en
        END as description,
        pd.availability_types,
        pd.promo_code,
        pd.display_order,
        (
            pd.is_enabled 
            AND (pd.date_start IS NULL OR NOW() >= pd.date_start)
            AND (pd.date_stop IS NULL OR NOW() <= pd.date_stop)
        ) as is_currently_active
    FROM menuca_v3.promotional_deals pd
    WHERE pd.restaurant_id = p_restaurant_id
      AND pd.disabled_at IS NULL
      AND pd.is_enabled = true
      AND (pd.date_start IS NULL OR NOW() >= pd.date_start)
      AND (pd.date_stop IS NULL OR NOW() <= pd.date_stop)
      AND (p_service_type IS NULL OR pd.availability_types IS NULL 
           OR pd.availability_types @> jsonb_build_array(p_service_type))
    ORDER BY 
        pd.display_order NULLS LAST,
        pd.date_start DESC NULLS LAST;
END;
$function$;

-- ============================================================================
-- FIX 3: get_deal_with_translation
-- Problem: References deleted table promotional_deals_translations and deleted columns
-- Fix: Rewrite to use bilingual columns directly
-- ============================================================================

DROP FUNCTION IF EXISTS menuca_v3.get_deal_with_translation(bigint, character varying);

CREATE OR REPLACE FUNCTION menuca_v3.get_deal_with_translation(
    p_deal_id bigint, 
    p_language character varying DEFAULT 'en'::character varying
)
RETURNS TABLE(
    id integer, 
    restaurant_id integer, 
    deal_type character varying, 
    discount_percent numeric, 
    discount_amount numeric, 
    minimum_purchase numeric, 
    date_start date, 
    date_stop date, 
    is_enabled boolean, 
    name character varying, 
    description text, 
    availability_types jsonb, 
    promo_code character varying
)
LANGUAGE plpgsql
STABLE SECURITY DEFINER
AS $function$
BEGIN
    RETURN QUERY
    SELECT 
        pd.id,
        pd.restaurant_id,
        pd.deal_type,
        pd.discount_percent,
        pd.discount_amount,
        pd.minimum_purchase,
        pd.date_start,
        pd.date_stop,
        pd.is_enabled,
        -- Bilingual name with French fallback to English
        CASE 
            WHEN p_language = 'fr' AND pd.name_fr IS NOT NULL THEN pd.name_fr
            ELSE COALESCE(pd.name_en, pd.name)
        END as name,
        -- Bilingual description with French fallback to English
        CASE 
            WHEN p_language = 'fr' AND pd.description_fr IS NOT NULL THEN pd.description_fr
            ELSE pd.description_en
        END as description,
        pd.availability_types,
        pd.promo_code
    FROM menuca_v3.promotional_deals pd
    WHERE pd.id = p_deal_id
      AND pd.disabled_at IS NULL;
END;
$function$;

-- ============================================================================
-- VERIFY FIXES
-- ============================================================================

-- Test get_active_deals
DO $$
BEGIN
    RAISE NOTICE 'Testing get_active_deals...';
    PERFORM * FROM menuca_v3.get_active_deals(65) LIMIT 1;
    RAISE NOTICE '✅ get_active_deals: FIXED';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '❌ get_active_deals: STILL BROKEN - %', SQLERRM;
END $$;

-- Test get_deals_i18n
DO $$
BEGIN
    RAISE NOTICE 'Testing get_deals_i18n...';
    PERFORM * FROM menuca_v3.get_deals_i18n(65, 'en') LIMIT 1;
    RAISE NOTICE '✅ get_deals_i18n: FIXED';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '❌ get_deals_i18n: STILL BROKEN - %', SQLERRM;
END $$;

-- Test get_deal_with_translation
DO $$
BEGIN
    RAISE NOTICE 'Testing get_deal_with_translation...';
    PERFORM * FROM menuca_v3.get_deal_with_translation(272, 'en') LIMIT 1;
    RAISE NOTICE '✅ get_deal_with_translation: FIXED';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '❌ get_deal_with_translation: STILL BROKEN - %', SQLERRM;
END $$;
