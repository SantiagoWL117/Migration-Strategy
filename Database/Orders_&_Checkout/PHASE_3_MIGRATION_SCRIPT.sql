-- =====================================================
-- ORDERS & CHECKOUT V3 - PHASE 3: SCHEMA OPTIMIZATION
-- =====================================================
-- Phase: 3 of 7 - Audit Trails, Soft Delete, Validation
-- Created: January 17, 2025
-- =====================================================

BEGIN;

-- =====================================================
-- SECTION 1: ADD AUDIT COLUMNS
-- =====================================================

-- Add soft delete columns to orders
ALTER TABLE menuca_v3.orders 
ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS deleted_by BIGINT REFERENCES menuca_v3.users(id);

-- =====================================================
-- SECTION 2: AUTOMATIC STATUS HISTORY TRACKING
-- =====================================================

CREATE OR REPLACE FUNCTION menuca_v3.track_order_status_change()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status IS DISTINCT FROM NEW.status THEN
        INSERT INTO menuca_v3.order_status_history (
            order_id,
            old_status,
            new_status,
            changed_by_user_id,
            changed_at,
            reason
        ) VALUES (
            NEW.id,
            OLD.status,
            NEW.status,
            NEW.updated_by,
            NOW(),
            COALESCE(NEW.cancellation_reason, NEW.rejection_reason)
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_order_status_history
AFTER UPDATE OF status ON menuca_v3.orders
FOR EACH ROW
EXECUTE FUNCTION menuca_v3.track_order_status_change();

-- =====================================================
-- SECTION 3: SOFT DELETE FUNCTIONS
-- =====================================================

CREATE OR REPLACE FUNCTION menuca_v3.soft_delete_order(
    p_order_id BIGINT,
    p_reason TEXT
)
RETURNS JSONB AS $$
BEGIN
    UPDATE menuca_v3.orders
    SET deleted_at = NOW(),
        deleted_by = auth.uid()::BIGINT,
        is_void = true
    WHERE id = p_order_id
      AND deleted_at IS NULL;
    
    IF NOT FOUND THEN
        RETURN jsonb_build_object('success', false, 'error', 'Order not found or already deleted');
    END IF;
    
    RETURN jsonb_build_object('success', true, 'order_id', p_order_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- SECTION 4: VALIDATION TRIGGERS
-- =====================================================

CREATE OR REPLACE FUNCTION menuca_v3.validate_order_totals()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.grand_total < 0 THEN
        RAISE EXCEPTION 'Grand total cannot be negative';
    END IF;
    
    IF NEW.subtotal < 0 THEN
        RAISE EXCEPTION 'Subtotal cannot be negative';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_order_totals
BEFORE INSERT OR UPDATE ON menuca_v3.orders
FOR EACH ROW
EXECUTE FUNCTION menuca_v3.validate_order_totals();

-- =====================================================

GRANT EXECUTE ON FUNCTION menuca_v3.soft_delete_order(BIGINT, TEXT) TO authenticated;

COMMIT;

-- 🎉 PHASE 3 COMPLETE!
-- Next: Phase 4 - Real-Time Updates
