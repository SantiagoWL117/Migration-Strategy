-- =====================================================
-- MARKETING & PROMOTIONS V3 - PHASE 5: MULTI-LANGUAGE SUPPORT
-- =====================================================
-- Entity: Marketing & Promotions (Priority 6)
-- Phase: 5 of 7 - Internationalization & Translation Support
-- Created: January 17, 2025
-- Description: Translation tables for EN/ES/FR with fallback logic
-- =====================================================

BEGIN;

-- =====================================================
-- SECTION 1: CREATE TRANSLATION TABLES
-- =====================================================

-- Promotional Deals Translations
CREATE TABLE IF NOT EXISTS menuca_v3.promotional_deals_translations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    deal_id UUID NOT NULL REFERENCES menuca_v3.promotional_deals(id) ON DELETE CASCADE,
    language_code VARCHAR(5) NOT NULL, -- 'en', 'es', 'fr'
    title VARCHAR(200) NOT NULL,
    description TEXT,
    terms_and_conditions TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    UNIQUE(deal_id, language_code)
);

CREATE INDEX idx_deal_translations_deal ON menuca_v3.promotional_deals_translations(deal_id);
CREATE INDEX idx_deal_translations_language ON menuca_v3.promotional_deals_translations(language_code);

-- =====================================================

-- Promotional Coupons Translations
CREATE TABLE IF NOT EXISTS menuca_v3.promotional_coupons_translations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    coupon_id UUID NOT NULL REFERENCES menuca_v3.promotional_coupons(id) ON DELETE CASCADE,
    language_code VARCHAR(5) NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    terms_and_conditions TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    UNIQUE(coupon_id, language_code)
);

CREATE INDEX idx_coupon_translations_coupon ON menuca_v3.promotional_coupons_translations(coupon_id);
CREATE INDEX idx_coupon_translations_language ON menuca_v3.promotional_coupons_translations(language_code);

-- =====================================================

-- Marketing Tags Translations
CREATE TABLE IF NOT EXISTS menuca_v3.marketing_tags_translations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tag_id UUID NOT NULL REFERENCES menuca_v3.marketing_tags(id) ON DELETE CASCADE,
    language_code VARCHAR(5) NOT NULL,
    tag_name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    UNIQUE(tag_id, language_code)
);

CREATE INDEX idx_tag_translations_tag ON menuca_v3.marketing_tags_translations(tag_id);
CREATE INDEX idx_tag_translations_language ON menuca_v3.marketing_tags_translations(language_code);

-- =====================================================
-- SECTION 2: TRANSLATION FUNCTIONS WITH FALLBACK
-- =====================================================

-- Get deal with translation
CREATE OR REPLACE FUNCTION menuca_v3.get_deal_with_translation(
    p_deal_id UUID,
    p_language TEXT DEFAULT 'en'
)
RETURNS JSONB AS $$
DECLARE
    v_deal RECORD;
    v_translation RECORD;
BEGIN
    -- Get base deal
    SELECT * INTO v_deal
    FROM menuca_v3.promotional_deals
    WHERE id = p_deal_id
      AND deleted_at IS NULL;
    
    IF NOT FOUND THEN
        RETURN NULL;
    END IF;
    
    -- Try to get translation
    SELECT * INTO v_translation
    FROM menuca_v3.promotional_deals_translations
    WHERE deal_id = p_deal_id
      AND language_code = p_language;
    
    -- Fallback to English if translation not found
    IF NOT FOUND THEN
        SELECT * INTO v_translation
        FROM menuca_v3.promotional_deals_translations
        WHERE deal_id = p_deal_id
          AND language_code = 'en';
    END IF;
    
    -- Build response
    RETURN jsonb_build_object(
        'id', v_deal.id,
        'restaurant_id', v_deal.restaurant_id,
        'deal_type', v_deal.deal_type,
        'discount_value', v_deal.discount_value,
        'minimum_order_amount', v_deal.minimum_order_amount,
        'maximum_discount_amount', v_deal.maximum_discount_amount,
        'start_date', v_deal.start_date,
        'end_date', v_deal.end_date,
        'is_active', v_deal.is_active,
        'is_featured', v_deal.is_featured,
        'title', COALESCE(v_translation.title, v_deal.title),
        'description', COALESCE(v_translation.description, v_deal.description),
        'terms', v_translation.terms_and_conditions,
        'language', COALESCE(v_translation.language_code, 'en')
    );
END;
$$ LANGUAGE plpgsql STABLE;

-- =====================================================

-- Get deals for restaurant with translations
CREATE OR REPLACE FUNCTION menuca_v3.get_deals_i18n(
    p_restaurant_id BIGINT,
    p_language TEXT DEFAULT 'en',
    p_service_type TEXT DEFAULT NULL
)
RETURNS TABLE (
    deal JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT menuca_v3.get_deal_with_translation(d.id, p_language)
    FROM menuca_v3.promotional_deals d
    WHERE d.restaurant_id = p_restaurant_id
      AND d.is_active = true
      AND d.deleted_at IS NULL
      AND NOW() BETWEEN d.start_date AND d.end_date
      AND (
          p_service_type IS NULL
          OR p_service_type = ANY(d.applicable_service_types)
      )
    ORDER BY d.is_featured DESC, d.priority DESC;
END;
$$ LANGUAGE plpgsql STABLE;

-- =====================================================

-- Get coupon with translation
CREATE OR REPLACE FUNCTION menuca_v3.get_coupon_with_translation(
    p_coupon_id UUID,
    p_language TEXT DEFAULT 'en'
)
RETURNS JSONB AS $$
DECLARE
    v_coupon RECORD;
    v_translation RECORD;
BEGIN
    SELECT * INTO v_coupon
    FROM menuca_v3.promotional_coupons
    WHERE id = p_coupon_id
      AND deleted_at IS NULL;
    
    IF NOT FOUND THEN
        RETURN NULL;
    END IF;
    
    -- Try requested language
    SELECT * INTO v_translation
    FROM menuca_v3.promotional_coupons_translations
    WHERE coupon_id = p_coupon_id
      AND language_code = p_language;
    
    -- Fallback to English
    IF NOT FOUND THEN
        SELECT * INTO v_translation
        FROM menuca_v3.promotional_coupons_translations
        WHERE coupon_id = p_coupon_id
          AND language_code = 'en';
    END IF;
    
    RETURN jsonb_build_object(
        'id', v_coupon.id,
        'code', v_coupon.code,
        'discount_type', v_coupon.discount_type,
        'discount_value', v_coupon.discount_value,
        'minimum_order_amount', v_coupon.minimum_order_amount,
        'valid_from', v_coupon.valid_from,
        'valid_until', v_coupon.valid_until,
        'title', COALESCE(v_translation.title, v_coupon.title),
        'description', COALESCE(v_translation.description, v_coupon.description),
        'terms', v_translation.terms_and_conditions,
        'language', COALESCE(v_translation.language_code, 'en')
    );
END;
$$ LANGUAGE plpgsql STABLE;

-- =====================================================

-- Get coupons for restaurant with translations
CREATE OR REPLACE FUNCTION menuca_v3.get_coupons_i18n(
    p_restaurant_id BIGINT,
    p_language TEXT DEFAULT 'en'
)
RETURNS TABLE (
    coupon JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT menuca_v3.get_coupon_with_translation(c.id, p_language)
    FROM menuca_v3.promotional_coupons c
    WHERE (c.restaurant_id = p_restaurant_id OR c.restaurant_id IS NULL)
      AND c.is_active = true
      AND c.is_public = true
      AND c.deleted_at IS NULL
      AND NOW() BETWEEN c.valid_from AND c.valid_until
    ORDER BY c.valid_until ASC;
END;
$$ LANGUAGE plpgsql STABLE;

-- =====================================================

-- Translate marketing tag
CREATE OR REPLACE FUNCTION menuca_v3.translate_marketing_tag(
    p_tag_id UUID,
    p_language TEXT DEFAULT 'en'
)
RETURNS JSONB AS $$
DECLARE
    v_tag RECORD;
    v_translation RECORD;
BEGIN
    SELECT * INTO v_tag
    FROM menuca_v3.marketing_tags
    WHERE id = p_tag_id
      AND deleted_at IS NULL;
    
    IF NOT FOUND THEN
        RETURN NULL;
    END IF;
    
    SELECT * INTO v_translation
    FROM menuca_v3.marketing_tags_translations
    WHERE tag_id = p_tag_id
      AND language_code = p_language;
    
    IF NOT FOUND THEN
        SELECT * INTO v_translation
        FROM menuca_v3.marketing_tags_translations
        WHERE tag_id = p_tag_id
          AND language_code = 'en';
    END IF;
    
    RETURN jsonb_build_object(
        'id', v_tag.id,
        'tag_type', v_tag.tag_type,
        'tag_name', COALESCE(v_translation.tag_name, v_tag.tag_name),
        'description', COALESCE(v_translation.description, v_tag.description),
        'icon_url', v_tag.icon_url,
        'language', COALESCE(v_translation.language_code, 'en')
    );
END;
$$ LANGUAGE plpgsql STABLE;

-- =====================================================
-- SECTION 3: ENABLE RLS ON TRANSLATION TABLES
-- =====================================================

ALTER TABLE menuca_v3.promotional_deals_translations ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.promotional_coupons_translations ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.marketing_tags_translations ENABLE ROW LEVEL SECURITY;

-- Public can read translations
CREATE POLICY "Public read deal translations"
    ON menuca_v3.promotional_deals_translations FOR SELECT
    TO public
    USING (true);

CREATE POLICY "Public read coupon translations"
    ON menuca_v3.promotional_coupons_translations FOR SELECT
    TO public
    USING (true);

CREATE POLICY "Public read tag translations"
    ON menuca_v3.marketing_tags_translations FOR SELECT
    TO public
    USING (true);

-- Restaurant admins can manage their translations
CREATE POLICY "Restaurant admins manage deal translations"
    ON menuca_v3.promotional_deals_translations FOR ALL
    TO authenticated
    USING (
        deal_id IN (
            SELECT id FROM menuca_v3.promotional_deals
            WHERE restaurant_id IN (SELECT menuca_v3.get_user_restaurants())
        )
    );

CREATE POLICY "Restaurant admins manage coupon translations"
    ON menuca_v3.promotional_coupons_translations FOR ALL
    TO authenticated
    USING (
        coupon_id IN (
            SELECT id FROM menuca_v3.promotional_coupons
            WHERE restaurant_id IN (SELECT menuca_v3.get_user_restaurants())
              OR restaurant_id IS NULL
        )
    );

-- Super admins manage tag translations
CREATE POLICY "Super admins manage tag translations"
    ON menuca_v3.marketing_tags_translations FOR ALL
    TO authenticated
    USING (menuca_v3.is_super_admin());

-- =====================================================
-- SECTION 4: GRANT PERMISSIONS
-- =====================================================

GRANT SELECT ON menuca_v3.promotional_deals_translations TO authenticated, anon;
GRANT SELECT ON menuca_v3.promotional_coupons_translations TO authenticated, anon;
GRANT SELECT ON menuca_v3.marketing_tags_translations TO authenticated, anon;

GRANT INSERT, UPDATE, DELETE ON menuca_v3.promotional_deals_translations TO authenticated;
GRANT INSERT, UPDATE, DELETE ON menuca_v3.promotional_coupons_translations TO authenticated;
GRANT INSERT, UPDATE, DELETE ON menuca_v3.marketing_tags_translations TO authenticated;

GRANT EXECUTE ON FUNCTION menuca_v3.get_deal_with_translation(UUID, TEXT) TO authenticated, anon;
GRANT EXECUTE ON FUNCTION menuca_v3.get_deals_i18n(BIGINT, TEXT, TEXT) TO authenticated, anon;
GRANT EXECUTE ON FUNCTION menuca_v3.get_coupon_with_translation(UUID, TEXT) TO authenticated, anon;
GRANT EXECUTE ON FUNCTION menuca_v3.get_coupons_i18n(BIGINT, TEXT) TO authenticated, anon;
GRANT EXECUTE ON FUNCTION menuca_v3.translate_marketing_tag(UUID, TEXT) TO authenticated, anon;

COMMIT;

-- =====================================================
-- END OF PHASE 5 - MULTI-LANGUAGE SUPPORT
-- =====================================================

-- 🎉 PHASE 5 COMPLETE!
-- Created: 3 translation tables, 5 i18n functions
-- Languages Supported: EN, ES, FR (with fallback)
-- RLS: Complete security on translation tables
-- Next: Phase 6 - Advanced Features

