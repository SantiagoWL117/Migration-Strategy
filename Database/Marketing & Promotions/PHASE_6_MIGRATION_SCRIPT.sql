-- =====================================================
-- MARKETING & PROMOTIONS V3 - PHASE 6: ADVANCED FEATURES
-- =====================================================
-- Entity: Marketing & Promotions (Priority 6)
-- Phase: 6 of 7 - Dynamic Pricing, Flash Sales, Referrals
-- Created: January 17, 2025
-- Description: Advanced promotional features
-- =====================================================

BEGIN;

-- =====================================================
-- SECTION 1: AUTO-APPLY BEST DEAL FUNCTION
-- =====================================================

CREATE OR REPLACE FUNCTION menuca_v3.auto_apply_best_deal(
    p_restaurant_id BIGINT,
    p_order_total DECIMAL,
    p_service_type TEXT,
    p_customer_id UUID
)
RETURNS JSONB AS $$
DECLARE
    v_best_deal RECORD;
    v_max_discount DECIMAL := 0;
    v_deal RECORD;
    v_discount DECIMAL;
BEGIN
    -- Loop through all eligible deals
    FOR v_deal IN
        SELECT * FROM menuca_v3.promotional_deals
        WHERE restaurant_id = p_restaurant_id
          AND is_active = true
          AND deleted_at IS NULL
          AND NOW() BETWEEN start_date AND end_date
          AND p_service_type = ANY(applicable_service_types)
          AND (minimum_order_amount IS NULL OR p_order_total >= minimum_order_amount)
    LOOP
        -- Calculate discount for this deal
        v_discount := menuca_v3.calculate_deal_discount(v_deal.id, p_order_total);
        
        -- Track best deal
        IF v_discount > v_max_discount THEN
            v_max_discount := v_discount;
            v_best_deal := v_deal;
        END IF;
    END LOOP;
    
    IF v_best_deal.id IS NULL THEN
        RETURN jsonb_build_object(
            'has_deal', false,
            'message', 'No applicable deals found'
        );
    END IF;
    
    RETURN jsonb_build_object(
        'has_deal', true,
        'deal_id', v_best_deal.id,
        'deal_title', v_best_deal.title,
        'discount_amount', v_max_discount,
        'final_total', p_order_total - v_max_discount
    );
END;
$$ LANGUAGE plpgsql STABLE;

-- =====================================================
-- SECTION 2: GENERATE REFERRAL COUPON
-- =====================================================

CREATE OR REPLACE FUNCTION menuca_v3.generate_referral_coupon(
    p_referrer_customer_id UUID,
    p_discount_value DECIMAL DEFAULT 10.00,
    p_valid_days INTEGER DEFAULT 30
)
RETURNS JSONB AS $$
DECLARE
    v_coupon_code TEXT;
    v_coupon_id UUID;
BEGIN
    -- Generate unique referral code
    v_coupon_code := 'REF' || UPPER(substring(md5(random()::text) from 1 for 6));
    
    -- Create coupon
    INSERT INTO menuca_v3.promotional_coupons (
        tenant_id,
        restaurant_id,
        code,
        title,
        description,
        discount_type,
        discount_value,
        minimum_order_amount,
        valid_from,
        valid_until,
        total_usage_limit,
        usage_per_customer,
        is_active,
        is_public
    ) VALUES (
        (SELECT id FROM menuca_v3.restaurants LIMIT 1), -- Platform coupon
        NULL, -- Platform-wide
        v_coupon_code,
        'Referral Reward',
        'Reward for being referred by a friend',
        'fixed_amount',
        p_discount_value,
        0,
        NOW(),
        NOW() + (p_valid_days || ' days')::INTERVAL,
        1, -- Single use
        1,
        true,
        false -- Private, not public
    )
    RETURNING id INTO v_coupon_id;
    
    RETURN jsonb_build_object(
        'success', true,
        'coupon_id', v_coupon_id,
        'coupon_code', v_coupon_code,
        'discount_value', p_discount_value,
        'valid_until', NOW() + (p_valid_days || ' days')::INTERVAL,
        'referrer_id', p_referrer_customer_id
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- SECTION 3: FLASH SALE FUNCTIONS
-- =====================================================

-- Create flash sale deal with limited quantity
CREATE OR REPLACE FUNCTION menuca_v3.create_flash_sale(
    p_restaurant_id BIGINT,
    p_title VARCHAR(200),
    p_discount_value DECIMAL,
    p_quantity_limit INTEGER,
    p_duration_hours INTEGER DEFAULT 24
)
RETURNS JSONB AS $$
DECLARE
    v_deal_id UUID;
BEGIN
    INSERT INTO menuca_v3.promotional_deals (
        tenant_id,
        restaurant_id,
        title,
        description,
        deal_type,
        discount_value,
        start_date,
        end_date,
        usage_limit,
        usage_per_customer,
        is_active,
        is_featured,
        priority,
        created_by
    ) VALUES (
        (SELECT id FROM menuca_v3.restaurants WHERE id = p_restaurant_id),
        p_restaurant_id,
        p_title,
        'Flash Sale - Limited Time!',
        'percentage',
        p_discount_value,
        NOW(),
        NOW() + (p_duration_hours || ' hours')::INTERVAL,
        p_quantity_limit,
        1, -- One per customer
        true,
        true, -- Featured
        999, -- High priority
        (SELECT id FROM menuca_v3.admin_users WHERE user_id = auth.uid() LIMIT 1)
    )
    RETURNING id INTO v_deal_id;
    
    RETURN jsonb_build_object(
        'success', true,
        'deal_id', v_deal_id,
        'title', p_title,
        'quantity_limit', p_quantity_limit,
        'end_time', NOW() + (p_duration_hours || ' hours')::INTERVAL
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================

-- Claim flash sale slot (atomic counter)
CREATE OR REPLACE FUNCTION menuca_v3.claim_flash_sale_slot(
    p_deal_id UUID,
    p_customer_id UUID
)
RETURNS JSONB AS $$
DECLARE
    v_deal RECORD;
    v_claimed BOOLEAN;
BEGIN
    -- Lock row and check availability
    SELECT * INTO v_deal
    FROM menuca_v3.promotional_deals
    WHERE id = p_deal_id
      AND is_active = true
      AND deleted_at IS NULL
    FOR UPDATE;
    
    IF NOT FOUND THEN
        RETURN jsonb_build_object(
            'success', false,
            'reason', 'Flash sale not found or inactive'
        );
    END IF;
    
    -- Check if sold out
    IF v_deal.usage_limit IS NOT NULL AND v_deal.usage_count >= v_deal.usage_limit THEN
        RETURN jsonb_build_object(
            'success', false,
            'reason', 'Flash sale sold out'
        );
    END IF;
    
    -- Check if customer already claimed
    IF EXISTS (
        SELECT 1 FROM menuca_v3.coupon_usage_log
        WHERE coupon_id = p_deal_id
          AND customer_id = p_customer_id
    ) THEN
        RETURN jsonb_build_object(
            'success', false,
            'reason', 'You have already claimed this flash sale'
        );
    END IF;
    
    -- Increment usage count atomically
    UPDATE menuca_v3.promotional_deals
    SET usage_count = usage_count + 1
    WHERE id = p_deal_id
    RETURNING true INTO v_claimed;
    
    RETURN jsonb_build_object(
        'success', true,
        'deal_id', p_deal_id,
        'slots_remaining', v_deal.usage_limit - v_deal.usage_count - 1
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- SECTION 4: TIME-BASED DYNAMIC PRICING
-- =====================================================

-- Check if deal is active based on time schedule
CREATE OR REPLACE FUNCTION menuca_v3.is_deal_active_now(
    p_deal_id UUID
)
RETURNS BOOLEAN AS $$
DECLARE
    v_deal RECORD;
    v_schedule JSONB;
    v_current_dow INTEGER; -- Day of week (0=Sunday)
    v_current_time TIME;
BEGIN
    SELECT * INTO v_deal
    FROM menuca_v3.promotional_deals
    WHERE id = p_deal_id
      AND is_active = true
      AND deleted_at IS NULL
      AND NOW() BETWEEN start_date AND end_date;
    
    IF NOT FOUND THEN
        RETURN false;
    END IF;
    
    -- If no recurring schedule, deal is active
    IF v_deal.recurring_schedule IS NULL THEN
        RETURN true;
    END IF;
    
    -- Check recurring schedule (happy hour, lunch specials, etc.)
    v_schedule := v_deal.recurring_schedule;
    v_current_dow := EXTRACT(DOW FROM NOW());
    v_current_time := NOW()::TIME;
    
    -- Example schedule format:
    -- {"days": [1,2,3,4,5], "start_time": "11:00", "end_time": "14:00"}
    
    IF v_schedule->'days' IS NOT NULL THEN
        IF NOT (v_current_dow::TEXT = ANY(
            SELECT jsonb_array_elements_text(v_schedule->'days')
        )) THEN
            RETURN false;
        END IF;
    END IF;
    
    IF v_schedule->>'start_time' IS NOT NULL THEN
        IF v_current_time < (v_schedule->>'start_time')::TIME THEN
            RETURN false;
        END IF;
    END IF;
    
    IF v_schedule->>'end_time' IS NOT NULL THEN
        IF v_current_time > (v_schedule->>'end_time')::TIME THEN
            RETURN false;
        END IF;
    END IF;
    
    RETURN true;
END;
$$ LANGUAGE plpgsql STABLE;

-- =====================================================
-- SECTION 5: GRANT PERMISSIONS
-- =====================================================

GRANT EXECUTE ON FUNCTION menuca_v3.auto_apply_best_deal(BIGINT, DECIMAL, TEXT, UUID) TO authenticated, anon;
GRANT EXECUTE ON FUNCTION menuca_v3.generate_referral_coupon(UUID, DECIMAL, INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION menuca_v3.create_flash_sale(BIGINT, VARCHAR, DECIMAL, INTEGER, INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION menuca_v3.claim_flash_sale_slot(UUID, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION menuca_v3.is_deal_active_now(UUID) TO authenticated, anon;

COMMIT;

-- =====================================================
-- END OF PHASE 6 - ADVANCED FEATURES
-- =====================================================

-- 🎉 PHASE 6 COMPLETE!
-- Features: Auto-apply best deal, referral coupons, flash sales, dynamic pricing
-- Functions: 5 advanced promotional features
-- Next: Phase 7 - Testing & Completion Documentation

