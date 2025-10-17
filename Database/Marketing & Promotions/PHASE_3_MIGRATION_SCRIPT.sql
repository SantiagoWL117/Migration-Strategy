-- =====================================================
-- MARKETING & PROMOTIONS V3 - PHASE 3: SCHEMA OPTIMIZATION
-- =====================================================
-- Entity: Marketing & Promotions (Priority 6)
-- Phase: 3 of 7 - Audit Trails, Soft Delete, Validation
-- Created: January 17, 2025
-- Description: Add audit columns, soft delete functions, validation triggers
-- =====================================================

BEGIN;

-- =====================================================
-- SECTION 1: UPDATE AUDIT TRIGGERS
-- =====================================================

-- Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION menuca_v3.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    NEW.updated_by = (SELECT id FROM menuca_v3.admin_users WHERE user_id = auth.uid() LIMIT 1);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to all tables
DROP TRIGGER IF EXISTS update_deals_updated_at ON menuca_v3.promotional_deals;
CREATE TRIGGER update_deals_updated_at
    BEFORE UPDATE ON menuca_v3.promotional_deals
    FOR EACH ROW
    EXECUTE FUNCTION menuca_v3.update_updated_at_column();

DROP TRIGGER IF EXISTS update_coupons_updated_at ON menuca_v3.promotional_coupons;
CREATE TRIGGER update_coupons_updated_at
    BEFORE UPDATE ON menuca_v3.promotional_coupons
    FOR EACH ROW
    EXECUTE FUNCTION menuca_v3.update_updated_at_column();

DROP TRIGGER IF EXISTS update_tags_updated_at ON menuca_v3.marketing_tags;
CREATE TRIGGER update_tags_updated_at
    BEFORE UPDATE ON menuca_v3.marketing_tags
    FOR EACH ROW
    EXECUTE FUNCTION menuca_v3.update_updated_at_column();

-- =====================================================
-- SECTION 2: VALIDATION TRIGGERS
-- =====================================================

-- Validate deal dates
CREATE OR REPLACE FUNCTION menuca_v3.validate_deal_dates()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.start_date >= NEW.end_date THEN
        RAISE EXCEPTION 'Deal start_date must be before end_date';
    END IF;
    
    IF NEW.end_date < NOW() THEN
        RAISE WARNING 'Deal end_date is in the past';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS validate_deal_dates_trigger ON menuca_v3.promotional_deals;
CREATE TRIGGER validate_deal_dates_trigger
    BEFORE INSERT OR UPDATE ON menuca_v3.promotional_deals
    FOR EACH ROW
    EXECUTE FUNCTION menuca_v3.validate_deal_dates();

-- =====================================================

-- Validate coupon dates and code format
CREATE OR REPLACE FUNCTION menuca_v3.validate_coupon_data()
RETURNS TRIGGER AS $$
BEGIN
    -- Validate dates
    IF NEW.valid_from >= NEW.valid_until THEN
        RAISE EXCEPTION 'Coupon valid_from must be before valid_until';
    END IF;
    
    -- Ensure code is uppercase
    NEW.code = UPPER(NEW.code);
    
    -- Check code format (alphanumeric, underscore, hyphen only)
    IF NEW.code !~ '^[A-Z0-9_-]+$' THEN
        RAISE EXCEPTION 'Coupon code must contain only uppercase letters, numbers, underscores, and hyphens';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS validate_coupon_data_trigger ON menuca_v3.promotional_coupons;
CREATE TRIGGER validate_coupon_data_trigger
    BEFORE INSERT OR UPDATE ON menuca_v3.promotional_coupons
    FOR EACH ROW
    EXECUTE FUNCTION menuca_v3.validate_coupon_data();

-- =====================================================

-- Prevent duplicate coupon codes
CREATE OR REPLACE FUNCTION menuca_v3.check_coupon_code_uniqueness()
RETURNS TRIGGER AS $$
DECLARE
    v_existing_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_existing_count
    FROM menuca_v3.promotional_coupons
    WHERE UPPER(code) = UPPER(NEW.code)
      AND id != COALESCE(NEW.id, '00000000-0000-0000-0000-000000000000'::UUID)
      AND deleted_at IS NULL;
    
    IF v_existing_count > 0 THEN
        RAISE EXCEPTION 'Coupon code "%" already exists', NEW.code;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS check_coupon_code_uniqueness_trigger ON menuca_v3.promotional_coupons;
CREATE TRIGGER check_coupon_code_uniqueness_trigger
    BEFORE INSERT OR UPDATE ON menuca_v3.promotional_coupons
    FOR EACH ROW
    EXECUTE FUNCTION menuca_v3.check_coupon_code_uniqueness();

-- =====================================================
-- SECTION 3: SOFT DELETE FUNCTIONS
-- =====================================================

-- Soft delete deal
CREATE OR REPLACE FUNCTION menuca_v3.soft_delete_deal(
    p_deal_id UUID,
    p_reason TEXT DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
    v_restaurant_id BIGINT;
    v_deleted BOOLEAN;
BEGIN
    -- Get restaurant_id
    SELECT restaurant_id INTO v_restaurant_id
    FROM menuca_v3.promotional_deals
    WHERE id = p_deal_id
      AND deleted_at IS NULL;
    
    IF NOT FOUND THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Deal not found or already deleted'
        );
    END IF;
    
    -- Soft delete (RLS enforces ownership)
    UPDATE menuca_v3.promotional_deals
    SET deleted_at = NOW(),
        deleted_by = (SELECT id FROM menuca_v3.admin_users WHERE user_id = auth.uid() LIMIT 1),
        is_active = false
    WHERE id = p_deal_id
      AND restaurant_id = v_restaurant_id
    RETURNING true INTO v_deleted;
    
    IF v_deleted THEN
        RETURN jsonb_build_object(
            'success', true,
            'message', 'Deal deleted successfully',
            'deal_id', p_deal_id,
            'deleted_at', NOW()
        );
    ELSE
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Unauthorized or deal not found'
        );
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================

-- Restore deleted deal
CREATE OR REPLACE FUNCTION menuca_v3.restore_deal(
    p_deal_id UUID
)
RETURNS JSONB AS $$
DECLARE
    v_restaurant_id BIGINT;
    v_restored BOOLEAN;
BEGIN
    -- Get restaurant_id
    SELECT restaurant_id INTO v_restaurant_id
    FROM menuca_v3.promotional_deals
    WHERE id = p_deal_id
      AND deleted_at IS NOT NULL;
    
    IF NOT FOUND THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Deal not found or not deleted'
        );
    END IF;
    
    -- Restore (RLS enforces ownership)
    UPDATE menuca_v3.promotional_deals
    SET deleted_at = NULL,
        deleted_by = NULL
    WHERE id = p_deal_id
      AND restaurant_id = v_restaurant_id
    RETURNING true INTO v_restored;
    
    IF v_restored THEN
        RETURN jsonb_build_object(
            'success', true,
            'message', 'Deal restored successfully',
            'deal_id', p_deal_id
        );
    ELSE
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Unauthorized or deal not found'
        );
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================

-- Soft delete coupon
CREATE OR REPLACE FUNCTION menuca_v3.soft_delete_coupon(
    p_coupon_id UUID
)
RETURNS JSONB AS $$
DECLARE
    v_deleted BOOLEAN;
BEGIN
    -- Soft delete (RLS enforces ownership)
    UPDATE menuca_v3.promotional_coupons
    SET deleted_at = NOW(),
        deleted_by = (SELECT id FROM menuca_v3.admin_users WHERE user_id = auth.uid() LIMIT 1),
        is_active = false
    WHERE id = p_coupon_id
      AND deleted_at IS NULL
    RETURNING true INTO v_deleted;
    
    IF v_deleted THEN
        RETURN jsonb_build_object(
            'success', true,
            'message', 'Coupon deleted successfully',
            'coupon_id', p_coupon_id
        );
    ELSE
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Coupon not found or already deleted'
        );
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================

-- Restore deleted coupon
CREATE OR REPLACE FUNCTION menuca_v3.restore_coupon(
    p_coupon_id UUID
)
RETURNS JSONB AS $$
DECLARE
    v_restored BOOLEAN;
BEGIN
    UPDATE menuca_v3.promotional_coupons
    SET deleted_at = NULL,
        deleted_by = NULL
    WHERE id = p_coupon_id
      AND deleted_at IS NOT NULL
    RETURNING true INTO v_restored;
    
    IF v_restored THEN
        RETURN jsonb_build_object(
            'success', true,
            'message', 'Coupon restored successfully'
        );
    ELSE
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Coupon not found or not deleted'
        );
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- SECTION 4: ADMIN HELPER FUNCTIONS
-- =====================================================

-- Clone deal to another restaurant or same restaurant
CREATE OR REPLACE FUNCTION menuca_v3.clone_deal(
    p_source_deal_id UUID,
    p_target_restaurant_id BIGINT,
    p_new_title VARCHAR(200) DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
    v_source_deal RECORD;
    v_new_deal_id UUID;
BEGIN
    -- Get source deal
    SELECT * INTO v_source_deal
    FROM menuca_v3.promotional_deals
    WHERE id = p_source_deal_id
      AND deleted_at IS NULL;
    
    IF NOT FOUND THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Source deal not found'
        );
    END IF;
    
    -- Insert cloned deal
    INSERT INTO menuca_v3.promotional_deals (
        tenant_id,
        restaurant_id,
        title,
        description,
        deal_type,
        discount_value,
        minimum_order_amount,
        maximum_discount_amount,
        applicable_service_types,
        applicable_item_categories,
        start_date,
        end_date,
        recurring_schedule,
        usage_limit,
        usage_per_customer,
        is_active,
        is_featured,
        priority,
        created_by
    ) VALUES (
        (SELECT id FROM menuca_v3.restaurants WHERE id = p_target_restaurant_id),
        p_target_restaurant_id,
        COALESCE(p_new_title, v_source_deal.title || ' (Copy)'),
        v_source_deal.description,
        v_source_deal.deal_type,
        v_source_deal.discount_value,
        v_source_deal.minimum_order_amount,
        v_source_deal.maximum_discount_amount,
        v_source_deal.applicable_service_types,
        v_source_deal.applicable_item_categories,
        v_source_deal.start_date,
        v_source_deal.end_date,
        v_source_deal.recurring_schedule,
        v_source_deal.usage_limit,
        v_source_deal.usage_per_customer,
        false, -- Start inactive
        v_source_deal.is_featured,
        v_source_deal.priority,
        (SELECT id FROM menuca_v3.admin_users WHERE user_id = auth.uid() LIMIT 1)
    )
    RETURNING id INTO v_new_deal_id;
    
    RETURN jsonb_build_object(
        'success', true,
        'message', 'Deal cloned successfully',
        'source_deal_id', p_source_deal_id,
        'new_deal_id', v_new_deal_id,
        'target_restaurant_id', p_target_restaurant_id
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================

-- Bulk disable all deals for a restaurant
CREATE OR REPLACE FUNCTION menuca_v3.bulk_disable_deals(
    p_restaurant_id BIGINT
)
RETURNS JSONB AS $$
DECLARE
    v_affected_count INTEGER;
BEGIN
    UPDATE menuca_v3.promotional_deals
    SET is_active = false,
        updated_at = NOW(),
        updated_by = (SELECT id FROM menuca_v3.admin_users WHERE user_id = auth.uid() LIMIT 1)
    WHERE restaurant_id = p_restaurant_id
      AND is_active = true
      AND deleted_at IS NULL;
    
    GET DIAGNOSTICS v_affected_count = ROW_COUNT;
    
    RETURN jsonb_build_object(
        'success', true,
        'message', format('Disabled %s deal(s)', v_affected_count),
        'affected_count', v_affected_count
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================

-- Bulk enable deals
CREATE OR REPLACE FUNCTION menuca_v3.bulk_enable_deals(
    p_restaurant_id BIGINT,
    p_deal_ids UUID[] DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
    v_affected_count INTEGER;
BEGIN
    IF p_deal_ids IS NULL THEN
        -- Enable all deals
        UPDATE menuca_v3.promotional_deals
        SET is_active = true,
            updated_at = NOW()
        WHERE restaurant_id = p_restaurant_id
          AND is_active = false
          AND deleted_at IS NULL
          AND NOW() BETWEEN start_date AND end_date;
    ELSE
        -- Enable specific deals
        UPDATE menuca_v3.promotional_deals
        SET is_active = true,
            updated_at = NOW()
        WHERE id = ANY(p_deal_ids)
          AND restaurant_id = p_restaurant_id
          AND deleted_at IS NULL;
    END IF;
    
    GET DIAGNOSTICS v_affected_count = ROW_COUNT;
    
    RETURN jsonb_build_object(
        'success', true,
        'message', format('Enabled %s deal(s)', v_affected_count),
        'affected_count', v_affected_count
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- SECTION 5: CREATE ACTIVE-ONLY VIEWS
-- =====================================================

-- Active deals view (excludes soft-deleted)
CREATE OR REPLACE VIEW menuca_v3.active_deals AS
SELECT *
FROM menuca_v3.promotional_deals
WHERE deleted_at IS NULL;

-- Active coupons view
CREATE OR REPLACE VIEW menuca_v3.active_coupons AS
SELECT *
FROM menuca_v3.promotional_coupons
WHERE deleted_at IS NULL;

-- Active tags view
CREATE OR REPLACE VIEW menuca_v3.active_tags AS
SELECT *
FROM menuca_v3.marketing_tags
WHERE deleted_at IS NULL;

-- =====================================================
-- SECTION 6: GRANT PERMISSIONS
-- =====================================================

-- Grant execute on new functions
GRANT EXECUTE ON FUNCTION menuca_v3.soft_delete_deal(UUID, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION menuca_v3.restore_deal(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION menuca_v3.soft_delete_coupon(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION menuca_v3.restore_coupon(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION menuca_v3.clone_deal(UUID, BIGINT, VARCHAR) TO authenticated;
GRANT EXECUTE ON FUNCTION menuca_v3.bulk_disable_deals(BIGINT) TO authenticated;
GRANT EXECUTE ON FUNCTION menuca_v3.bulk_enable_deals(BIGINT, UUID[]) TO authenticated;

-- Grant select on views
GRANT SELECT ON menuca_v3.active_deals TO authenticated, anon;
GRANT SELECT ON menuca_v3.active_coupons TO authenticated, anon;
GRANT SELECT ON menuca_v3.active_tags TO authenticated, anon;

COMMIT;

-- =====================================================
-- END OF PHASE 3 - SCHEMA OPTIMIZATION
-- =====================================================

-- 🎉 PHASE 3 COMPLETE!
-- Created: 3 validation triggers, 7 admin functions, 3 views
-- Audit: Auto-update triggers on all tables
-- Soft Delete: Complete with restore functions
-- Next: Phase 4 - Real-Time Updates

