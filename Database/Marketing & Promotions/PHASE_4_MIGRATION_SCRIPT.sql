-- =====================================================
-- MARKETING & PROMOTIONS V3 - PHASE 4: REAL-TIME UPDATES
-- =====================================================
-- Entity: Marketing & Promotions (Priority 6)
-- Phase: 4 of 7 - Supabase Realtime & WebSocket Notifications
-- Created: January 17, 2025
-- Description: Enable realtime subscriptions and pg_notify events
-- =====================================================

BEGIN;

-- =====================================================
-- SECTION 1: ENABLE SUPABASE REALTIME
-- =====================================================

-- Enable realtime on core tables
ALTER PUBLICATION supabase_realtime ADD TABLE menuca_v3.promotional_deals;
ALTER PUBLICATION supabase_realtime ADD TABLE menuca_v3.promotional_coupons;
ALTER PUBLICATION supabase_realtime ADD TABLE menuca_v3.marketing_tags;
ALTER PUBLICATION supabase_realtime ADD TABLE menuca_v3.restaurant_tag_associations;
ALTER PUBLICATION supabase_realtime ADD TABLE menuca_v3.coupon_usage_log;

-- =====================================================
-- SECTION 2: NOTIFICATION TRIGGER FUNCTIONS
-- =====================================================

-- Notify when new deal is published
CREATE OR REPLACE FUNCTION menuca_v3.notify_deal_published()
RETURNS TRIGGER AS $$
BEGIN
    -- Only notify when deal becomes active
    IF (TG_OP = 'INSERT' AND NEW.is_active = true) 
       OR (TG_OP = 'UPDATE' AND OLD.is_active = false AND NEW.is_active = true) THEN
        
        PERFORM pg_notify(
            'deal_published',
            json_build_object(
                'deal_id', NEW.id,
                'restaurant_id', NEW.restaurant_id,
                'title', NEW.title,
                'deal_type', NEW.deal_type,
                'discount_value', NEW.discount_value,
                'start_date', NEW.start_date,
                'end_date', NEW.end_date,
                'is_featured', NEW.is_featured
            )::text
        );
        
        -- Also send restaurant-specific notification
        PERFORM pg_notify(
            'restaurant_' || NEW.restaurant_id || '_deal_published',
            json_build_object(
                'deal_id', NEW.id,
                'title', NEW.title,
                'action', 'published'
            )::text
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS deal_published_trigger ON menuca_v3.promotional_deals;
CREATE TRIGGER deal_published_trigger
    AFTER INSERT OR UPDATE ON menuca_v3.promotional_deals
    FOR EACH ROW
    EXECUTE FUNCTION menuca_v3.notify_deal_published();

-- =====================================================

-- Notify when deal status changes
CREATE OR REPLACE FUNCTION menuca_v3.notify_deal_status_change()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'UPDATE' AND OLD.is_active != NEW.is_active THEN
        PERFORM pg_notify(
            'restaurant_' || NEW.restaurant_id || '_deal_status',
            json_build_object(
                'deal_id', NEW.id,
                'title', NEW.title,
                'is_active', NEW.is_active,
                'changed_at', NOW(),
                'action', CASE WHEN NEW.is_active THEN 'activated' ELSE 'deactivated' END
            )::text
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS deal_status_change_trigger ON menuca_v3.promotional_deals;
CREATE TRIGGER deal_status_change_trigger
    AFTER UPDATE ON menuca_v3.promotional_deals
    FOR EACH ROW
    EXECUTE FUNCTION menuca_v3.notify_deal_status_change();

-- =====================================================

-- Notify when new coupon is created
CREATE OR REPLACE FUNCTION menuca_v3.notify_coupon_created()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' AND NEW.is_active = true THEN
        -- Platform-wide notification for platform coupons
        IF NEW.restaurant_id IS NULL THEN
            PERFORM pg_notify(
                'platform_coupon_created',
                json_build_object(
                    'coupon_id', NEW.id,
                    'code', NEW.code,
                    'title', NEW.title,
                    'discount_type', NEW.discount_type,
                    'discount_value', NEW.discount_value,
                    'valid_from', NEW.valid_from,
                    'valid_until', NEW.valid_until
                )::text
            );
        ELSE
            -- Restaurant-specific notification
            PERFORM pg_notify(
                'restaurant_' || NEW.restaurant_id || '_coupon_created',
                json_build_object(
                    'coupon_id', NEW.id,
                    'code', NEW.code,
                    'title', NEW.title
                )::text
            );
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS coupon_created_trigger ON menuca_v3.promotional_coupons;
CREATE TRIGGER coupon_created_trigger
    AFTER INSERT ON menuca_v3.promotional_coupons
    FOR EACH ROW
    EXECUTE FUNCTION menuca_v3.notify_coupon_created();

-- =====================================================

-- Notify when coupon is redeemed
CREATE OR REPLACE FUNCTION menuca_v3.notify_coupon_redeemed()
RETURNS TRIGGER AS $$
DECLARE
    v_coupon RECORD;
BEGIN
    IF TG_OP = 'INSERT' THEN
        -- Get coupon details
        SELECT * INTO v_coupon
        FROM menuca_v3.promotional_coupons
        WHERE id = NEW.coupon_id;
        
        -- Notify restaurant
        IF NEW.restaurant_id IS NOT NULL THEN
            PERFORM pg_notify(
                'restaurant_' || NEW.restaurant_id || '_coupon_redeemed',
                json_build_object(
                    'usage_id', NEW.id,
                    'coupon_code', NEW.coupon_code,
                    'discount_amount', NEW.discount_amount,
                    'order_id', NEW.order_id,
                    'redeemed_at', NEW.redeemed_at
                )::text
            );
        END IF;
        
        -- Notify customer
        PERFORM pg_notify(
            'customer_' || NEW.customer_id || '_coupon_redeemed',
            json_build_object(
                'coupon_code', NEW.coupon_code,
                'discount_amount', NEW.discount_amount,
                'saved_amount', NEW.discount_amount
            )::text
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS coupon_redeemed_trigger ON menuca_v3.coupon_usage_log;
CREATE TRIGGER coupon_redeemed_trigger
    AFTER INSERT ON menuca_v3.coupon_usage_log
    FOR EACH ROW
    EXECUTE FUNCTION menuca_v3.notify_coupon_redeemed();

-- =====================================================

-- Notify when coupon usage limit reached
CREATE OR REPLACE FUNCTION menuca_v3.notify_coupon_limit_reached()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'UPDATE' AND NEW.total_usage_count >= NEW.total_usage_limit THEN
        -- Only notify once when limit is reached
        IF OLD.total_usage_count < OLD.total_usage_limit THEN
            PERFORM pg_notify(
                'coupon_limit_reached',
                json_build_object(
                    'coupon_id', NEW.id,
                    'code', NEW.code,
                    'title', NEW.title,
                    'usage_count', NEW.total_usage_count,
                    'usage_limit', NEW.total_usage_limit
                )::text
            );
            
            -- Restaurant notification
            IF NEW.restaurant_id IS NOT NULL THEN
                PERFORM pg_notify(
                    'restaurant_' || NEW.restaurant_id || '_coupon_limit',
                    json_build_object(
                        'coupon_id', NEW.id,
                        'code', NEW.code,
                        'message', 'Coupon usage limit reached'
                    )::text
                );
            END IF;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS coupon_limit_reached_trigger ON menuca_v3.promotional_coupons;
CREATE TRIGGER coupon_limit_reached_trigger
    AFTER UPDATE ON menuca_v3.promotional_coupons
    FOR EACH ROW
    EXECUTE FUNCTION menuca_v3.notify_coupon_limit_reached();

-- =====================================================

-- Notify when deal is expiring soon (within 24 hours)
CREATE OR REPLACE FUNCTION menuca_v3.check_expiring_deals()
RETURNS void AS $$
DECLARE
    v_deal RECORD;
BEGIN
    FOR v_deal IN
        SELECT id, restaurant_id, title, end_date
        FROM menuca_v3.promotional_deals
        WHERE is_active = true
          AND deleted_at IS NULL
          AND end_date BETWEEN NOW() AND NOW() + INTERVAL '24 hours'
    LOOP
        PERFORM pg_notify(
            'restaurant_' || v_deal.restaurant_id || '_deal_expiring',
            json_build_object(
                'deal_id', v_deal.id,
                'title', v_deal.title,
                'end_date', v_deal.end_date,
                'hours_remaining', EXTRACT(HOUR FROM (v_deal.end_date - NOW()))
            )::text
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- SECTION 3: REAL-TIME ANALYTICS FUNCTIONS
-- =====================================================

-- Get live deal performance
CREATE OR REPLACE FUNCTION menuca_v3.get_live_deal_performance(
    p_restaurant_id BIGINT
)
RETURNS TABLE (
    deal_id UUID,
    title VARCHAR(200),
    usage_count INTEGER,
    hours_active INTEGER,
    redemptions_per_hour DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        d.id,
        d.title,
        d.usage_count,
        EXTRACT(HOUR FROM (NOW() - d.start_date))::INTEGER AS hours_active,
        CASE
            WHEN EXTRACT(HOUR FROM (NOW() - d.start_date)) > 0 THEN
                ROUND(d.usage_count::DECIMAL / EXTRACT(HOUR FROM (NOW() - d.start_date))::DECIMAL, 2)
            ELSE 0
        END AS redemptions_per_hour
    FROM menuca_v3.promotional_deals d
    WHERE d.restaurant_id = p_restaurant_id
      AND d.is_active = true
      AND d.deleted_at IS NULL
      AND NOW() BETWEEN d.start_date AND d.end_date
    ORDER BY d.usage_count DESC;
END;
$$ LANGUAGE plpgsql STABLE;

-- =====================================================

-- Get live coupon redemptions (last 24 hours)
CREATE OR REPLACE FUNCTION menuca_v3.get_live_coupon_redemptions(
    p_restaurant_id BIGINT
)
RETURNS TABLE (
    coupon_code VARCHAR(50),
    redemptions_count BIGINT,
    total_discount DECIMAL,
    last_redeemed_at TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        cul.coupon_code,
        COUNT(*) AS redemptions_count,
        SUM(cul.discount_amount) AS total_discount,
        MAX(cul.redeemed_at) AS last_redeemed_at
    FROM menuca_v3.coupon_usage_log cul
    WHERE cul.restaurant_id = p_restaurant_id
      AND cul.redeemed_at >= NOW() - INTERVAL '24 hours'
    GROUP BY cul.coupon_code
    ORDER BY redemptions_count DESC;
END;
$$ LANGUAGE plpgsql STABLE;

-- =====================================================
-- SECTION 4: SCHEDULED NOTIFICATION CHECKS
-- =====================================================

-- Note: These would be scheduled via pg_cron or external cron job

-- Function to send daily promotion summary
CREATE OR REPLACE FUNCTION menuca_v3.send_daily_promotion_summary(
    p_restaurant_id BIGINT
)
RETURNS JSONB AS $$
DECLARE
    v_summary JSONB;
    v_analytics JSONB;
BEGIN
    -- Get yesterday's analytics
    v_analytics := menuca_v3.get_promotion_analytics(
        p_restaurant_id,
        NOW() - INTERVAL '24 hours',
        NOW()
    );
    
    -- Send notification
    PERFORM pg_notify(
        'restaurant_' || p_restaurant_id || '_daily_summary',
        v_analytics::text
    );
    
    RETURN jsonb_build_object(
        'success', true,
        'restaurant_id', p_restaurant_id,
        'summary_sent_at', NOW()
    );
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- SECTION 5: GRANT PERMISSIONS
-- =====================================================

-- Grant execute on new functions
GRANT EXECUTE ON FUNCTION menuca_v3.check_expiring_deals() TO authenticated;
GRANT EXECUTE ON FUNCTION menuca_v3.get_live_deal_performance(BIGINT) TO authenticated;
GRANT EXECUTE ON FUNCTION menuca_v3.get_live_coupon_redemptions(BIGINT) TO authenticated;
GRANT EXECUTE ON FUNCTION menuca_v3.send_daily_promotion_summary(BIGINT) TO authenticated;

COMMIT;

-- =====================================================
-- VALIDATION QUERIES
-- =====================================================

-- Verify realtime is enabled
SELECT 
    'Realtime Subscriptions Enabled' AS metric,
    COUNT(*) AS table_count,
    CASE 
        WHEN COUNT(*) >= 5 THEN '✅ PASS (5 tables)'
        ELSE '⚠️ WARNING'
    END AS status
FROM pg_publication_tables
WHERE pubname = 'supabase_realtime'
  AND schemaname = 'menuca_v3'
  AND tablename IN ('promotional_deals', 'promotional_coupons', 'marketing_tags', 
                    'restaurant_tag_associations', 'coupon_usage_log');

-- Count notification triggers
SELECT 
    'Notification Triggers Created' AS metric,
    COUNT(*) AS trigger_count
FROM pg_trigger
WHERE tgrelid::regclass::text LIKE 'menuca_v3.promotional%'
   OR tgrelid::regclass::text LIKE 'menuca_v3.coupon_usage_log';

-- =====================================================
-- END OF PHASE 4 - REAL-TIME UPDATES
-- =====================================================

-- 🎉 PHASE 4 COMPLETE!
-- Created: 5 notification triggers, 4 real-time functions
-- Enabled: Supabase Realtime on 5 tables
-- Channels: 10+ notification channels for live updates
-- Next: Phase 5 - Multi-Language Support

