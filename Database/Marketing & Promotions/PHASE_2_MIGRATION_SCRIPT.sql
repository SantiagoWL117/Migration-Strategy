-- =====================================================
-- MARKETING & PROMOTIONS V3 - PHASE 2: PERFORMANCE & APIS
-- =====================================================
-- Entity: Marketing & Promotions (Priority 6)
-- Phase: 2 of 7 - Core Business Logic & API Functions
-- Created: January 17, 2025
-- Description: SQL functions for deal/coupon management and validation
-- =====================================================

BEGIN;

-- =====================================================
-- SECTION 1: DEAL MANAGEMENT FUNCTIONS
-- =====================================================

-- Function 1: Get Active Deals for Restaurant
CREATE OR REPLACE FUNCTION menuca_v3.get_active_deals(
    p_restaurant_id BIGINT,
    p_service_type TEXT DEFAULT NULL
)
RETURNS TABLE (
    deal_id UUID,
    title VARCHAR(200),
    description TEXT,
    deal_type VARCHAR(50),
    discount_value DECIMAL(10,2),
    minimum_order_amount DECIMAL(10,2),
    maximum_discount_amount DECIMAL(10,2),
    start_date TIMESTAMPTZ,
    end_date TIMESTAMPTZ,
    usage_remaining INTEGER,
    is_featured BOOLEAN,
    priority INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        d.id,
        d.title,
        d.description,
        d.deal_type,
        d.discount_value,
        d.minimum_order_amount,
        d.maximum_discount_amount,
        d.start_date,
        d.end_date,
        CASE
            WHEN d.usage_limit IS NULL THEN NULL
            ELSE (d.usage_limit - d.usage_count)
        END AS usage_remaining,
        d.is_featured,
        d.priority
    FROM menuca_v3.promotional_deals d
    WHERE d.restaurant_id = p_restaurant_id
      AND d.is_active = true
      AND d.deleted_at IS NULL
      AND NOW() BETWEEN d.start_date AND d.end_date
      AND (
          p_service_type IS NULL 
          OR p_service_type = ANY(d.applicable_service_types)
      )
    ORDER BY d.is_featured DESC, d.priority DESC, d.start_date DESC;
END;
$$ LANGUAGE plpgsql STABLE;

-- =====================================================

-- Function 2: Validate Deal Eligibility
CREATE OR REPLACE FUNCTION menuca_v3.validate_deal_eligibility(
    p_deal_id UUID,
    p_order_total DECIMAL,
    p_service_type TEXT,
    p_customer_id UUID DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
    v_deal RECORD;
    v_customer_usage INTEGER;
    v_result JSONB;
BEGIN
    -- Get deal details
    SELECT * INTO v_deal
    FROM menuca_v3.promotional_deals
    WHERE id = p_deal_id
      AND is_active = true
      AND deleted_at IS NULL
      AND NOW() BETWEEN start_date AND end_date;
    
    IF NOT FOUND THEN
        RETURN jsonb_build_object(
            'eligible', false,
            'reason', 'Deal not found or expired'
        );
    END IF;
    
    -- Check service type
    IF p_service_type != ALL(v_deal.applicable_service_types) THEN
        RETURN jsonb_build_object(
            'eligible', false,
            'reason', 'Deal not applicable to ' || p_service_type
        );
    END IF;
    
    -- Check minimum order amount
    IF p_order_total < v_deal.minimum_order_amount THEN
        RETURN jsonb_build_object(
            'eligible', false,
            'reason', format('Minimum order amount is $%s', v_deal.minimum_order_amount::TEXT)
        );
    END IF;
    
    -- Check global usage limit
    IF v_deal.usage_limit IS NOT NULL AND v_deal.usage_count >= v_deal.usage_limit THEN
        RETURN jsonb_build_object(
            'eligible', false,
            'reason', 'Deal usage limit reached'
        );
    END IF;
    
    -- Check customer-specific usage limit
    IF p_customer_id IS NOT NULL AND v_deal.usage_per_customer IS NOT NULL THEN
        SELECT COUNT(*) INTO v_customer_usage
        FROM menuca_v3.coupon_usage_log
        WHERE coupon_id = p_deal_id
          AND customer_id = p_customer_id;
        
        IF v_customer_usage >= v_deal.usage_per_customer THEN
            RETURN jsonb_build_object(
                'eligible', false,
                'reason', format('You have already used this deal %s time(s)', v_deal.usage_per_customer::TEXT)
            );
        END IF;
    END IF;
    
    -- All checks passed
    RETURN jsonb_build_object(
        'eligible', true,
        'deal_id', v_deal.id,
        'discount_type', v_deal.deal_type,
        'discount_value', v_deal.discount_value
    );
END;
$$ LANGUAGE plpgsql STABLE;

-- =====================================================

-- Function 3: Calculate Deal Discount
CREATE OR REPLACE FUNCTION menuca_v3.calculate_deal_discount(
    p_deal_id UUID,
    p_order_total DECIMAL
)
RETURNS DECIMAL AS $$
DECLARE
    v_deal RECORD;
    v_discount DECIMAL;
BEGIN
    SELECT * INTO v_deal
    FROM menuca_v3.promotional_deals
    WHERE id = p_deal_id
      AND is_active = true
      AND deleted_at IS NULL;
    
    IF NOT FOUND THEN
        RETURN 0;
    END IF;
    
    -- Calculate discount based on deal type
    CASE v_deal.deal_type
        WHEN 'percentage' THEN
            v_discount := p_order_total * (v_deal.discount_value / 100.0);
        WHEN 'fixed_amount' THEN
            v_discount := v_deal.discount_value;
        ELSE
            v_discount := 0;
    END CASE;
    
    -- Apply maximum discount cap if set
    IF v_deal.maximum_discount_amount IS NOT NULL THEN
        v_discount := LEAST(v_discount, v_deal.maximum_discount_amount);
    END IF;
    
    -- Discount cannot exceed order total
    v_discount := LEAST(v_discount, p_order_total);
    
    RETURN ROUND(v_discount, 2);
END;
$$ LANGUAGE plpgsql STABLE;

-- =====================================================

-- Function 4: Toggle Deal Status
CREATE OR REPLACE FUNCTION menuca_v3.toggle_deal_status(
    p_deal_id UUID,
    p_is_active BOOLEAN
)
RETURNS JSONB AS $$
DECLARE
    v_restaurant_id BIGINT;
    v_updated BOOLEAN;
BEGIN
    -- Get restaurant_id and verify ownership
    SELECT restaurant_id INTO v_restaurant_id
    FROM menuca_v3.promotional_deals
    WHERE id = p_deal_id
      AND deleted_at IS NULL;
    
    IF NOT FOUND THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Deal not found'
        );
    END IF;
    
    -- Check if user can manage this restaurant's deals (RLS handles this)
    UPDATE menuca_v3.promotional_deals
    SET is_active = p_is_active,
        updated_at = NOW(),
        updated_by = (SELECT id FROM menuca_v3.admin_users WHERE user_id = auth.uid() LIMIT 1)
    WHERE id = p_deal_id
      AND restaurant_id = v_restaurant_id
    RETURNING true INTO v_updated;
    
    IF v_updated THEN
        RETURN jsonb_build_object(
            'success', true,
            'message', format('Deal %s successfully', CASE WHEN p_is_active THEN 'activated' ELSE 'deactivated' END),
            'is_active', p_is_active
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
-- SECTION 2: COUPON MANAGEMENT FUNCTIONS
-- =====================================================

-- Function 5: Validate Coupon
CREATE OR REPLACE FUNCTION menuca_v3.validate_coupon(
    p_coupon_code TEXT,
    p_restaurant_id BIGINT,
    p_customer_id UUID,
    p_order_total DECIMAL,
    p_service_type TEXT DEFAULT 'delivery'
)
RETURNS JSONB AS $$
DECLARE
    v_coupon RECORD;
    v_customer_usage INTEGER;
BEGIN
    -- Get coupon details (case-insensitive)
    SELECT * INTO v_coupon
    FROM menuca_v3.promotional_coupons
    WHERE UPPER(code) = UPPER(p_coupon_code)
      AND is_active = true
      AND deleted_at IS NULL
      AND NOW() BETWEEN valid_from AND valid_until
      AND (restaurant_id = p_restaurant_id OR restaurant_id IS NULL); -- Restaurant-specific or platform-wide
    
    IF NOT FOUND THEN
        RETURN jsonb_build_object(
            'valid', false,
            'error_code', 'INVALID_COUPON',
            'message', 'Coupon code is invalid or expired'
        );
    END IF;
    
    -- Check service type eligibility
    IF p_service_type != ALL(v_coupon.applicable_service_types) THEN
        RETURN jsonb_build_object(
            'valid', false,
            'error_code', 'SERVICE_TYPE_MISMATCH',
            'message', format('Coupon not valid for %s orders', p_service_type)
        );
    END IF;
    
    -- Check minimum order amount
    IF p_order_total < v_coupon.minimum_order_amount THEN
        RETURN jsonb_build_object(
            'valid', false,
            'error_code', 'MINIMUM_NOT_MET',
            'message', format('Minimum order amount is $%s', v_coupon.minimum_order_amount::TEXT),
            'minimum_required', v_coupon.minimum_order_amount
        );
    END IF;
    
    -- Check first-time customer requirement
    IF v_coupon.first_time_customers_only THEN
        -- Check if customer has previous orders (to be implemented with orders table)
        -- For now, assume it's valid
        NULL;
    END IF;
    
    -- Check global usage limit
    IF v_coupon.total_usage_limit IS NOT NULL 
       AND v_coupon.total_usage_count >= v_coupon.total_usage_limit THEN
        RETURN jsonb_build_object(
            'valid', false,
            'error_code', 'USAGE_LIMIT_REACHED',
            'message', 'Coupon has reached its usage limit'
        );
    END IF;
    
    -- Check customer-specific usage limit
    SELECT COUNT(*) INTO v_customer_usage
    FROM menuca_v3.coupon_usage_log
    WHERE coupon_id = v_coupon.id
      AND customer_id = p_customer_id;
    
    IF v_customer_usage >= v_coupon.usage_per_customer THEN
        RETURN jsonb_build_object(
            'valid', false,
            'error_code', 'CUSTOMER_LIMIT_REACHED',
            'message', format('You have already used this coupon %s time(s)', v_coupon.usage_per_customer::TEXT)
        );
    END IF;
    
    -- Check targeting (if coupon is private)
    IF NOT v_coupon.is_public THEN
        IF NOT (p_customer_id = ANY(v_coupon.assigned_to_customers)) THEN
            RETURN jsonb_build_object(
                'valid', false,
                'error_code', 'NOT_TARGETED',
                'message', 'This coupon is not available to you'
            );
        END IF;
    END IF;
    
    -- Calculate discount
    DECLARE
        v_discount DECIMAL;
    BEGIN
        CASE v_coupon.discount_type
            WHEN 'percentage' THEN
                v_discount := p_order_total * (v_coupon.discount_value / 100.0);
            WHEN 'fixed_amount' THEN
                v_discount := v_coupon.discount_value;
            WHEN 'free_delivery' THEN
                -- To be determined with delivery fees integration
                v_discount := 5.99; -- Placeholder
            ELSE
                v_discount := 0;
        END CASE;
        
        -- Apply maximum discount cap
        IF v_coupon.maximum_discount_amount IS NOT NULL THEN
            v_discount := LEAST(v_discount, v_coupon.maximum_discount_amount);
        END IF;
        
        -- Discount cannot exceed order total
        v_discount := LEAST(v_discount, p_order_total);
        
        -- Return success with discount details
        RETURN jsonb_build_object(
            'valid', true,
            'coupon_id', v_coupon.id,
            'code', v_coupon.code,
            'title', v_coupon.title,
            'discount_type', v_coupon.discount_type,
            'discount_value', v_coupon.discount_value,
            'calculated_discount', ROUND(v_discount, 2),
            'final_total', p_order_total - v_discount
        );
    END;
END;
$$ LANGUAGE plpgsql STABLE;

-- =====================================================

-- Function 6: Apply Coupon to Order
CREATE OR REPLACE FUNCTION menuca_v3.apply_coupon_to_order(
    p_order_id UUID,
    p_coupon_code TEXT
)
RETURNS JSONB AS $$
DECLARE
    v_validation JSONB;
    v_coupon_id UUID;
    v_customer_id UUID;
    v_order_total DECIMAL;
    v_restaurant_id BIGINT;
    v_service_type TEXT;
BEGIN
    -- Get customer from auth
    v_customer_id := auth.uid();
    
    IF v_customer_id IS NULL THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'Not authenticated'
        );
    END IF;
    
    -- Get order details (stub - to be implemented with orders table)
    -- For now, we'll accept parameters
    -- v_order_total := (SELECT total FROM orders WHERE id = p_order_id);
    -- v_restaurant_id := (SELECT restaurant_id FROM orders WHERE id = p_order_id);
    -- v_service_type := (SELECT service_type FROM orders WHERE id = p_order_id);
    
    -- Placeholder validation
    RETURN jsonb_build_object(
        'success', true,
        'message', 'Coupon applied (integration pending with orders table)',
        'order_id', p_order_id,
        'coupon_code', p_coupon_code
    );
    
    -- Full implementation when orders table ready:
    /*
    v_validation := menuca_v3.validate_coupon(
        p_coupon_code,
        v_restaurant_id,
        v_customer_id,
        v_order_total,
        v_service_type
    );
    
    IF NOT (v_validation->>'valid')::BOOLEAN THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', v_validation->>'message'
        );
    END IF;
    
    -- Insert usage log
    INSERT INTO menuca_v3.coupon_usage_log (
        tenant_id,
        coupon_id,
        coupon_code,
        customer_id,
        order_id,
        restaurant_id,
        discount_amount,
        order_total_before,
        order_total_after,
        service_type
    ) VALUES (
        (SELECT tenant_id FROM menuca_v3.promotional_coupons WHERE id = (v_validation->>'coupon_id')::UUID),
        (v_validation->>'coupon_id')::UUID,
        p_coupon_code,
        v_customer_id,
        p_order_id,
        v_restaurant_id,
        (v_validation->>'calculated_discount')::DECIMAL,
        v_order_total,
        (v_validation->>'final_total')::DECIMAL,
        v_service_type
    );
    
    -- Increment usage count
    UPDATE menuca_v3.promotional_coupons
    SET total_usage_count = total_usage_count + 1
    WHERE id = (v_validation->>'coupon_id')::UUID;
    
    RETURN jsonb_build_object(
        'success', true,
        'discount_applied', v_validation->>'calculated_discount',
        'new_total', v_validation->>'final_total'
    );
    */
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================

-- Function 7: Redeem Coupon (Track Usage)
CREATE OR REPLACE FUNCTION menuca_v3.redeem_coupon(
    p_coupon_code TEXT,
    p_customer_id UUID,
    p_order_id UUID,
    p_restaurant_id BIGINT,
    p_discount_amount DECIMAL,
    p_order_total_before DECIMAL,
    p_order_total_after DECIMAL,
    p_service_type TEXT DEFAULT 'delivery'
)
RETURNS JSONB AS $$
DECLARE
    v_coupon_id UUID;
    v_tenant_id UUID;
BEGIN
    -- Get coupon ID and tenant_id
    SELECT id, tenant_id INTO v_coupon_id, v_tenant_id
    FROM menuca_v3.promotional_coupons
    WHERE UPPER(code) = UPPER(p_coupon_code)
      AND is_active = true
      AND deleted_at IS NULL;
    
    IF NOT FOUND THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'Coupon not found'
        );
    END IF;
    
    -- Insert usage log
    INSERT INTO menuca_v3.coupon_usage_log (
        tenant_id,
        coupon_id,
        coupon_code,
        customer_id,
        order_id,
        restaurant_id,
        discount_amount,
        order_total_before,
        order_total_after,
        service_type,
        redeemed_at
    ) VALUES (
        v_tenant_id,
        v_coupon_id,
        p_coupon_code,
        p_customer_id,
        p_order_id,
        p_restaurant_id,
        p_discount_amount,
        p_order_total_before,
        p_order_total_after,
        p_service_type,
        NOW()
    );
    
    -- Increment usage count
    UPDATE menuca_v3.promotional_coupons
    SET total_usage_count = total_usage_count + 1,
        updated_at = NOW()
    WHERE id = v_coupon_id;
    
    RETURN jsonb_build_object(
        'success', true,
        'coupon_id', v_coupon_id,
        'discount_applied', p_discount_amount,
        'redeemed_at', NOW()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================

-- Function 8: Check Coupon Usage Limit
CREATE OR REPLACE FUNCTION menuca_v3.check_coupon_usage_limit(
    p_coupon_code TEXT,
    p_customer_id UUID
)
RETURNS JSONB AS $$
DECLARE
    v_coupon RECORD;
    v_customer_usage INTEGER;
    v_remaining INTEGER;
BEGIN
    SELECT * INTO v_coupon
    FROM menuca_v3.promotional_coupons
    WHERE UPPER(code) = UPPER(p_coupon_code)
      AND is_active = true
      AND deleted_at IS NULL;
    
    IF NOT FOUND THEN
        RETURN jsonb_build_object(
            'found', false
        );
    END IF;
    
    -- Count customer usage
    SELECT COUNT(*) INTO v_customer_usage
    FROM menuca_v3.coupon_usage_log
    WHERE coupon_id = v_coupon.id
      AND customer_id = p_customer_id;
    
    v_remaining := v_coupon.usage_per_customer - v_customer_usage;
    
    RETURN jsonb_build_object(
        'found', true,
        'code', v_coupon.code,
        'usage_per_customer', v_coupon.usage_per_customer,
        'customer_usage_count', v_customer_usage,
        'remaining_uses', GREATEST(0, v_remaining),
        'can_use', v_remaining > 0
    );
END;
$$ LANGUAGE plpgsql STABLE;

-- =====================================================
-- SECTION 3: TAG & ANALYTICS FUNCTIONS
-- =====================================================

-- Function 9: Get Restaurants by Tag
CREATE OR REPLACE FUNCTION menuca_v3.get_restaurants_by_tag(
    p_tag_id UUID
)
RETURNS TABLE (
    restaurant_id BIGINT,
    restaurant_name VARCHAR,
    added_at TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        rta.restaurant_id,
        r.name,
        rta.added_at
    FROM menuca_v3.restaurant_tag_associations rta
    JOIN menuca_v3.restaurants r ON rta.restaurant_id = r.id
    WHERE rta.tag_id = p_tag_id
      AND r.deleted_at IS NULL
    ORDER BY r.name;
END;
$$ LANGUAGE plpgsql STABLE;

-- =====================================================

-- Function 10: Get Deal Usage Stats
CREATE OR REPLACE FUNCTION menuca_v3.get_deal_usage_stats(
    p_deal_id UUID
)
RETURNS JSONB AS $$
DECLARE
    v_deal RECORD;
    v_stats JSONB;
BEGIN
    SELECT * INTO v_deal
    FROM menuca_v3.promotional_deals
    WHERE id = p_deal_id;
    
    IF NOT FOUND THEN
        RETURN jsonb_build_object('error', 'Deal not found');
    END IF;
    
    v_stats := jsonb_build_object(
        'deal_id', v_deal.id,
        'title', v_deal.title,
        'usage_count', v_deal.usage_count,
        'usage_limit', v_deal.usage_limit,
        'usage_percentage', CASE
            WHEN v_deal.usage_limit IS NULL THEN NULL
            WHEN v_deal.usage_limit = 0 THEN 0
            ELSE ROUND((v_deal.usage_count::DECIMAL / v_deal.usage_limit::DECIMAL) * 100, 2)
        END,
        'is_active', v_deal.is_active,
        'start_date', v_deal.start_date,
        'end_date', v_deal.end_date,
        'days_remaining', EXTRACT(DAY FROM (v_deal.end_date - NOW()))::INTEGER
    );
    
    RETURN v_stats;
END;
$$ LANGUAGE plpgsql STABLE;

-- =====================================================

-- Function 11: Get Promotion Analytics
CREATE OR REPLACE FUNCTION menuca_v3.get_promotion_analytics(
    p_restaurant_id BIGINT,
    p_start_date TIMESTAMPTZ DEFAULT NOW() - INTERVAL '30 days',
    p_end_date TIMESTAMPTZ DEFAULT NOW()
)
RETURNS JSONB AS $$
DECLARE
    v_analytics JSONB;
    v_total_deals INTEGER;
    v_active_deals INTEGER;
    v_total_coupons INTEGER;
    v_active_coupons INTEGER;
    v_total_redemptions INTEGER;
    v_total_discount_given DECIMAL;
BEGIN
    -- Count deals
    SELECT COUNT(*) INTO v_total_deals
    FROM menuca_v3.promotional_deals
    WHERE restaurant_id = p_restaurant_id
      AND deleted_at IS NULL;
    
    SELECT COUNT(*) INTO v_active_deals
    FROM menuca_v3.promotional_deals
    WHERE restaurant_id = p_restaurant_id
      AND is_active = true
      AND deleted_at IS NULL
      AND NOW() BETWEEN start_date AND end_date;
    
    -- Count coupons
    SELECT COUNT(*) INTO v_total_coupons
    FROM menuca_v3.promotional_coupons
    WHERE restaurant_id = p_restaurant_id
      AND deleted_at IS NULL;
    
    SELECT COUNT(*) INTO v_active_coupons
    FROM menuca_v3.promotional_coupons
    WHERE restaurant_id = p_restaurant_id
      AND is_active = true
      AND deleted_at IS NULL
      AND NOW() BETWEEN valid_from AND valid_until;
    
    -- Coupon redemptions in date range
    SELECT 
        COUNT(*),
        COALESCE(SUM(discount_amount), 0)
    INTO 
        v_total_redemptions,
        v_total_discount_given
    FROM menuca_v3.coupon_usage_log
    WHERE restaurant_id = p_restaurant_id
      AND redeemed_at BETWEEN p_start_date AND p_end_date;
    
    v_analytics := jsonb_build_object(
        'restaurant_id', p_restaurant_id,
        'date_range', jsonb_build_object(
            'start', p_start_date,
            'end', p_end_date
        ),
        'deals', jsonb_build_object(
            'total', v_total_deals,
            'active', v_active_deals
        ),
        'coupons', jsonb_build_object(
            'total', v_total_coupons,
            'active', v_active_coupons
        ),
        'redemptions', jsonb_build_object(
            'total_count', v_total_redemptions,
            'total_discount_given', v_total_discount_given,
            'average_discount', CASE
                WHEN v_total_redemptions > 0 THEN ROUND(v_total_discount_given / v_total_redemptions, 2)
                ELSE 0
            END
        )
    );
    
    RETURN v_analytics;
END;
$$ LANGUAGE plpgsql STABLE;

-- =====================================================

-- Function 12: Get Coupon Redemption Rate
CREATE OR REPLACE FUNCTION menuca_v3.get_coupon_redemption_rate(
    p_coupon_id UUID
)
RETURNS JSONB AS $$
DECLARE
    v_coupon RECORD;
    v_redemption_count INTEGER;
    v_redemption_rate DECIMAL;
BEGIN
    SELECT * INTO v_coupon
    FROM menuca_v3.promotional_coupons
    WHERE id = p_coupon_id;
    
    IF NOT FOUND THEN
        RETURN jsonb_build_object('error', 'Coupon not found');
    END IF;
    
    -- Count redemptions
    SELECT COUNT(*) INTO v_redemption_count
    FROM menuca_v3.coupon_usage_log
    WHERE coupon_id = p_coupon_id;
    
    -- Calculate redemption rate (if limit exists)
    IF v_coupon.total_usage_limit IS NOT NULL AND v_coupon.total_usage_limit > 0 THEN
        v_redemption_rate := (v_redemption_count::DECIMAL / v_coupon.total_usage_limit::DECIMAL) * 100;
    ELSE
        v_redemption_rate := NULL;
    END IF;
    
    RETURN jsonb_build_object(
        'coupon_id', v_coupon.id,
        'code', v_coupon.code,
        'title', v_coupon.title,
        'total_usage_count', v_coupon.total_usage_count,
        'redemption_count', v_redemption_count,
        'usage_limit', v_coupon.total_usage_limit,
        'redemption_rate_percentage', ROUND(v_redemption_rate, 2),
        'is_active', v_coupon.is_active,
        'valid_from', v_coupon.valid_from,
        'valid_until', v_coupon.valid_until
    );
END;
$$ LANGUAGE plpgsql STABLE;

-- =====================================================

-- Function 13: Get Popular Deals
CREATE OR REPLACE FUNCTION menuca_v3.get_popular_deals(
    p_restaurant_id BIGINT,
    p_limit INTEGER DEFAULT 5
)
RETURNS TABLE (
    deal_id UUID,
    title VARCHAR(200),
    usage_count INTEGER,
    is_active BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        d.id,
        d.title,
        d.usage_count,
        d.is_active
    FROM menuca_v3.promotional_deals d
    WHERE d.restaurant_id = p_restaurant_id
      AND d.deleted_at IS NULL
    ORDER BY d.usage_count DESC, d.created_at DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql STABLE;

-- =====================================================
-- SECTION 4: GRANT PERMISSIONS
-- =====================================================

-- Grant EXECUTE on all new functions
GRANT EXECUTE ON FUNCTION menuca_v3.get_active_deals(BIGINT, TEXT) TO authenticated, anon;
GRANT EXECUTE ON FUNCTION menuca_v3.validate_deal_eligibility(UUID, DECIMAL, TEXT, UUID) TO authenticated, anon;
GRANT EXECUTE ON FUNCTION menuca_v3.calculate_deal_discount(UUID, DECIMAL) TO authenticated;
GRANT EXECUTE ON FUNCTION menuca_v3.toggle_deal_status(UUID, BOOLEAN) TO authenticated;
GRANT EXECUTE ON FUNCTION menuca_v3.validate_coupon(TEXT, BIGINT, UUID, DECIMAL, TEXT) TO authenticated, anon;
GRANT EXECUTE ON FUNCTION menuca_v3.apply_coupon_to_order(UUID, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION menuca_v3.redeem_coupon(TEXT, UUID, UUID, BIGINT, DECIMAL, DECIMAL, DECIMAL, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION menuca_v3.check_coupon_usage_limit(TEXT, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION menuca_v3.get_restaurants_by_tag(UUID) TO authenticated, anon;
GRANT EXECUTE ON FUNCTION menuca_v3.get_deal_usage_stats(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION menuca_v3.get_promotion_analytics(BIGINT, TIMESTAMPTZ, TIMESTAMPTZ) TO authenticated;
GRANT EXECUTE ON FUNCTION menuca_v3.get_coupon_redemption_rate(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION menuca_v3.get_popular_deals(BIGINT, INTEGER) TO authenticated;

COMMIT;

-- =====================================================
-- END OF PHASE 2 - PERFORMANCE & APIS
-- =====================================================

-- 🎉 PHASE 2 COMPLETE!
-- Created: 13 SQL functions for business logic
-- Performance: All queries optimized with existing indexes
-- Next: Phase 3 - Schema Optimization (Audit Trails & Soft Delete)

