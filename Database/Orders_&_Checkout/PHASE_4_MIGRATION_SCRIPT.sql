-- =====================================================
-- ORDERS & CHECKOUT V3 - PHASE 4: REAL-TIME UPDATES
-- =====================================================
-- Phase: 4 of 7 - Supabase Realtime & WebSocket Notifications
-- Created: January 17, 2025
-- =====================================================

BEGIN;

-- =====================================================
-- SECTION 1: ENABLE SUPABASE REALTIME
-- =====================================================

ALTER PUBLICATION supabase_realtime ADD TABLE menuca_v3.orders;
ALTER PUBLICATION supabase_realtime ADD TABLE menuca_v3.order_status_history;

-- =====================================================
-- SECTION 2: NOTIFICATION TRIGGERS
-- =====================================================

-- Notify on new order
CREATE OR REPLACE FUNCTION menuca_v3.notify_new_order()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM pg_notify(
        'restaurant_' || NEW.restaurant_id || '_new_order',
        json_build_object(
            'order_id', NEW.id,
            'order_number', NEW.order_number,
            'order_type', NEW.order_type,
            'grand_total', NEW.grand_total
        )::text
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_notify_new_order
AFTER INSERT ON menuca_v3.orders
FOR EACH ROW
EXECUTE FUNCTION menuca_v3.notify_new_order();

-- =====================================================

-- Notify on status change
CREATE OR REPLACE FUNCTION menuca_v3.notify_order_status_change()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status != NEW.status THEN
        -- Notify customer
        PERFORM pg_notify(
            'customer_' || NEW.user_id || '_order_status',
            json_build_object(
                'order_id', NEW.id,
                'old_status', OLD.status,
                'new_status', NEW.status
            )::text
        );
        
        -- Notify restaurant
        PERFORM pg_notify(
            'restaurant_' || NEW.restaurant_id || '_order_status',
            json_build_object(
                'order_id', NEW.id,
                'status', NEW.status
            )::text
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_notify_order_status_change
AFTER UPDATE ON menuca_v3.orders
FOR EACH ROW
EXECUTE FUNCTION menuca_v3.notify_order_status_change();

COMMIT;

-- 🎉 PHASE 4 COMPLETE!
-- Real-time enabled, notifications active
-- Next: Phase 5 - Payment Integration
