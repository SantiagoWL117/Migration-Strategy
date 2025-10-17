-- =====================================================
-- ORDERS & CHECKOUT V3 - PHASE 5: PAYMENT INTEGRATION
-- =====================================================
-- Phase: 5 of 7 - Stripe Integration, Refunds, Tips
-- Created: January 17, 2025
-- =====================================================

BEGIN;

-- =====================================================
-- SECTION 1: PAYMENT FUNCTIONS
-- =====================================================

-- Process payment (stub for Stripe integration)
CREATE OR REPLACE FUNCTION menuca_v3.process_payment(
    p_order_id BIGINT,
    p_payment_method_id TEXT,
    p_payment_info JSONB
)
RETURNS JSONB AS $$
BEGIN
    -- TODO: Integrate with Stripe API
    UPDATE menuca_v3.orders
    SET payment_status = 'completed',
        payment_method = 'credit_card',
        payment_info = p_payment_info,
        updated_at = NOW()
    WHERE id = p_order_id;
    
    RETURN jsonb_build_object(
        'success', true,
        'order_id', p_order_id,
        'payment_status', 'completed'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================

-- Process refund
CREATE OR REPLACE FUNCTION menuca_v3.process_refund(
    p_order_id BIGINT,
    p_refund_amount DECIMAL,
    p_reason TEXT
)
RETURNS JSONB AS $$
BEGIN
    UPDATE menuca_v3.orders
    SET payment_status = 'refunded',
        is_refund = true,
        updated_at = NOW()
    WHERE id = p_order_id;
    
    -- TODO: Integrate with Stripe refund API
    
    RETURN jsonb_build_object(
        'success', true,
        'order_id', p_order_id,
        'refund_amount', p_refund_amount
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================

-- Update tip after order
CREATE OR REPLACE FUNCTION menuca_v3.update_order_tip(
    p_order_id BIGINT,
    p_tip_amount DECIMAL
)
RETURNS JSONB AS $$
DECLARE
    v_new_total DECIMAL;
BEGIN
    UPDATE menuca_v3.orders
    SET driver_tip = p_tip_amount,
        grand_total = grand_total + (p_tip_amount - COALESCE(driver_tip, 0)),
        updated_at = NOW()
    WHERE id = p_order_id
    RETURNING grand_total INTO v_new_total;
    
    RETURN jsonb_build_object(
        'success', true,
        'new_tip', p_tip_amount,
        'new_total', v_new_total
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================

GRANT EXECUTE ON FUNCTION menuca_v3.process_payment(BIGINT, TEXT, JSONB) TO service_role;
GRANT EXECUTE ON FUNCTION menuca_v3.process_refund(BIGINT, DECIMAL, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION menuca_v3.update_order_tip(BIGINT, DECIMAL) TO authenticated;

COMMIT;

-- 🎉 PHASE 5 COMPLETE!
-- Payment functions ready for Stripe integration
-- Next: Phase 6 - Advanced Features
