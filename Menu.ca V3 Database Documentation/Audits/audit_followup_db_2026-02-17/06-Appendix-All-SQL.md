# 06 - Appendix: All SQL Queries

**Date:** 2026-02-17  
**Database:** Supabase PostgreSQL, schema `menuca_v3`  
**Timezone used:** UTC (database default), displayed as America/Toronto where noted

---

## 1. De-Noised Health Metrics

### CUT A: Exclude test orders (is_test_order = false)

```sql
-- A1: Restaurants with ordering enabled
SELECT COUNT(*) as restaurants_ordering_enabled
FROM menuca_v3.restaurants WHERE online_ordering_enabled = true;
-- Result: 186
```

```sql
-- A2: Paid orders last 30 days (excluding test)
SELECT COUNT(*) as paid_orders_30d
FROM menuca_v3.orders
WHERE is_test_order = false AND payment_status = 'paid'
AND created_at >= NOW() - INTERVAL '30 days';
-- Result: 55
```

```sql
-- A2-7d: Paid orders last 7 days (excluding test)
SELECT COUNT(*) as paid_orders_7d
FROM menuca_v3.orders
WHERE is_test_order = false AND payment_status = 'paid'
AND created_at >= NOW() - INTERVAL '7 days';
-- Result: 21
```

```sql
-- A3: Completed orders last 30 days (excluding test)
SELECT COUNT(*) as completed_30d
FROM menuca_v3.orders
WHERE is_test_order = false AND payment_status = 'paid'
AND order_status IN ('completed','delivered')
AND created_at >= NOW() - INTERVAL '30 days';
-- Result: 15
```

```sql
-- A3-7d: Completed orders last 7 days (excluding test)
SELECT COUNT(*) as completed_7d
FROM menuca_v3.orders
WHERE is_test_order = false AND payment_status = 'paid'
AND order_status IN ('completed','delivered')
AND created_at >= NOW() - INTERVAL '7 days';
-- Result: 1
```

```sql
-- A5: Stuck paid orders (>2h, non-terminal, excluding test) last 30 days
SELECT COUNT(*) as stuck_30d
FROM menuca_v3.orders
WHERE is_test_order = false AND payment_status = 'paid'
AND order_status NOT IN ('completed','delivered','cancelled')
AND created_at < NOW() - INTERVAL '2 hours'
AND created_at >= NOW() - INTERVAL '30 days';
-- Result: 40
```

```sql
-- A5-7d: Stuck paid orders last 7 days
SELECT COUNT(*) as stuck_7d
FROM menuca_v3.orders
WHERE is_test_order = false AND payment_status = 'paid'
AND order_status NOT IN ('completed','delivered','cancelled')
AND created_at < NOW() - INTERVAL '2 hours'
AND created_at >= NOW() - INTERVAL '7 days';
-- Result: 20
```

```sql
-- A6: Time-to-complete (median + p95) for completed non-test orders
SELECT
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY EXTRACT(EPOCH FROM (completed_at - created_at))/60) as median_minutes,
    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY EXTRACT(EPOCH FROM (completed_at - created_at))/60) as p95_minutes,
    COUNT(*) as sample_size
FROM menuca_v3.orders
WHERE is_test_order = false AND payment_status = 'paid'
AND order_status IN ('completed','delivered')
AND completed_at IS NOT NULL;
-- Result: median=8849 min (~6.1 days), p95=10151 min (~7 days), sample=5
```

```sql
-- A7: Refunds (non-test orders)
SELECT COUNT(*) as refund_count_nontest, COALESCE(SUM(or2.refund_amount),0) as total_refunded
FROM menuca_v3.order_refunds or2
JOIN menuca_v3.orders o ON o.id = or2.order_id
WHERE o.is_test_order = false;
-- Result: 25 refunds, $641.39 total
```

### CUT B: Live-mode restaurants only (payment_mode = 'live')

```sql
-- B-list: Restaurants on live mode
SELECT dc.restaurant_id
FROM menuca_v3.delivery_and_pickup_configs dc
WHERE dc.payment_mode = 'live' AND dc.deleted_at IS NULL;
-- Result: 6 restaurants (IDs: 83, 131, 199, 815, 829, 1021)
```

```sql
-- B2-30d: Paid orders from live restaurants last 30d
SELECT COUNT(*) as paid_orders_live_30d
FROM menuca_v3.orders o
JOIN menuca_v3.delivery_and_pickup_configs dc ON dc.restaurant_id = o.restaurant_id AND dc.deleted_at IS NULL
WHERE dc.payment_mode = 'live' AND o.payment_status = 'paid'
AND o.created_at >= NOW() - INTERVAL '30 days';
-- Result: 101
```

```sql
-- B2-7d
SELECT COUNT(*) as paid_orders_live_7d
FROM menuca_v3.orders o
JOIN menuca_v3.delivery_and_pickup_configs dc ON dc.restaurant_id = o.restaurant_id AND dc.deleted_at IS NULL
WHERE dc.payment_mode = 'live' AND o.payment_status = 'paid'
AND o.created_at >= NOW() - INTERVAL '7 days';
-- Result: 71
```

```sql
-- B3-30d/7d: Completed from live restaurants
-- 30d Result: 15 | 7d Result: 1
```

```sql
-- B5-30d: Stuck from live restaurants
SELECT COUNT(*) as stuck_live_30d
FROM menuca_v3.orders o
JOIN menuca_v3.delivery_and_pickup_configs dc ON dc.restaurant_id = o.restaurant_id AND dc.deleted_at IS NULL
WHERE dc.payment_mode = 'live' AND o.payment_status = 'paid'
AND o.order_status NOT IN ('completed','delivered','cancelled')
AND o.created_at < NOW() - INTERVAL '2 hours'
AND o.created_at >= NOW() - INTERVAL '30 days';
-- Result: 86
```

```sql
-- B6: Time-to-complete for live restaurants
SELECT
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY EXTRACT(EPOCH FROM (o.completed_at - o.created_at))/60) as median_min,
    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY EXTRACT(EPOCH FROM (o.completed_at - o.created_at))/60) as p95_min,
    COUNT(*) as sample
FROM menuca_v3.orders o
JOIN menuca_v3.delivery_and_pickup_configs dc ON dc.restaurant_id = o.restaurant_id AND dc.deleted_at IS NULL
WHERE dc.payment_mode = 'live' AND o.payment_status = 'paid'
AND o.order_status IN ('completed','delivered')
AND o.completed_at IS NOT NULL;
-- Result: median=8849 min, p95=10151 min, sample=5
```

```sql
-- B7: Refunds from live restaurants
SELECT COUNT(*) as refund_count_live, COALESCE(SUM(or2.refund_amount),0) as total_refunded
FROM menuca_v3.order_refunds or2
JOIN menuca_v3.orders o ON o.id = or2.order_id
JOIN menuca_v3.delivery_and_pickup_configs dc ON dc.restaurant_id = o.restaurant_id AND dc.deleted_at IS NULL
WHERE dc.payment_mode = 'live';
-- Result: 25 refunds, $641.39
```

### CUT C: Live + non-test (intersection)

```sql
-- C2-30d
SELECT COUNT(*) as paid_live_nontest_30d
FROM menuca_v3.orders o
JOIN menuca_v3.delivery_and_pickup_configs dc ON dc.restaurant_id = o.restaurant_id AND dc.deleted_at IS NULL
WHERE dc.payment_mode = 'live' AND o.is_test_order = false AND o.payment_status = 'paid'
AND o.created_at >= NOW() - INTERVAL '30 days';
-- Result: 51
```

```sql
-- C2-7d: Result: 21
-- C3-30d: Result: 15
-- C3-7d: Result: 1
-- C5-30d (stuck): Result: 36
-- C6 (time-to-complete): Result: median=8849 min, p95=10151 min, sample=5
-- C7 (refunds): Result: 25 / $641.39
```

---

## 2. Stuck Paid Orders Forensics

```sql
-- S1: Stuck by current status
SELECT order_status, COUNT(*) as cnt
FROM menuca_v3.orders
WHERE payment_status = 'paid'
AND order_status NOT IN ('completed','delivered','cancelled')
AND created_at < NOW() - INTERVAL '2 hours'
GROUP BY order_status ORDER BY cnt DESC;
-- Result: ready=46, pending=31, confirmed=12, preparing=1
```

```sql
-- S2: Stuck by age bucket
SELECT
    CASE
        WHEN EXTRACT(EPOCH FROM (NOW() - created_at))/3600 BETWEEN 2 AND 6 THEN '2-6h'
        WHEN EXTRACT(EPOCH FROM (NOW() - created_at))/3600 BETWEEN 6 AND 24 THEN '6-24h'
        WHEN EXTRACT(EPOCH FROM (NOW() - created_at))/3600 > 24 THEN '>24h'
    END as age_bucket,
    COUNT(*) as cnt
FROM menuca_v3.orders
WHERE payment_status = 'paid'
AND order_status NOT IN ('completed','delivered','cancelled')
AND created_at < NOW() - INTERVAL '2 hours'
GROUP BY 1 ORDER BY 1;
-- Result: >24h=87, 6-24h=3
```

```sql
-- S3: Stuck by restaurant_id
SELECT restaurant_id, COUNT(*) as stuck_count
FROM menuca_v3.orders
WHERE payment_status = 'paid'
AND order_status NOT IN ('completed','delivered','cancelled')
AND created_at < NOW() - INTERVAL '2 hours'
GROUP BY restaurant_id ORDER BY stuck_count DESC;
-- Result: 1021=61, 829=10, 199=4, 131=4, 83=4, 815=3, 1015=3, 1009=1
```

```sql
-- S4: Failure-stage classification
SELECT 'paid_no_ack' as stage, COUNT(*) as cnt
FROM menuca_v3.orders
WHERE payment_status = 'paid'
AND order_status NOT IN ('completed','delivered','cancelled')
AND created_at < NOW() - INTERVAL '2 hours'
AND acknowledged_at IS NULL
UNION ALL
SELECT 'acked_not_completed' as stage, COUNT(*) as cnt
FROM menuca_v3.orders
WHERE payment_status = 'paid'
AND order_status NOT IN ('completed','delivered','cancelled')
AND created_at < NOW() - INTERVAL '2 hours'
AND acknowledged_at IS NOT NULL AND completed_at IS NULL
UNION ALL
SELECT 'completed_at_set_but_status_wrong' as stage, COUNT(*) as cnt
FROM menuca_v3.orders
WHERE payment_status = 'paid'
AND order_status NOT IN ('completed','delivered','cancelled')
AND created_at < NOW() - INTERVAL '2 hours'
AND completed_at IS NOT NULL;
-- Result: paid_no_ack=11, acked_not_completed=70, completed_at_set_but_status_wrong=9
```

```sql
-- S5: Stuck vs is_test_order
SELECT is_test_order, COUNT(*) as stuck
FROM menuca_v3.orders
WHERE payment_status = 'paid'
AND order_status NOT IN ('completed','delivered','cancelled')
AND created_at < NOW() - INTERVAL '2 hours'
GROUP BY is_test_order;
-- Result: false=40, true=50
```

```sql
-- S6: Stuck vs payment_mode
SELECT dc.payment_mode, COUNT(*) as stuck
FROM menuca_v3.orders o
JOIN menuca_v3.delivery_and_pickup_configs dc ON dc.restaurant_id = o.restaurant_id AND dc.deleted_at IS NULL
WHERE o.payment_status = 'paid'
AND o.order_status NOT IN ('completed','delivered','cancelled')
AND o.created_at < NOW() - INTERVAL '2 hours'
GROUP BY dc.payment_mode;
-- Result: live=86, test=4
```

```sql
-- S7: Daily distribution of stuck order creation
SELECT (created_at AT TIME ZONE 'America/Toronto')::date as created_date, COUNT(*)
FROM menuca_v3.orders
WHERE payment_status = 'paid'
AND order_status NOT IN ('completed','delivered','cancelled')
AND created_at < NOW() - INTERVAL '2 hours'
GROUP BY 1 ORDER BY 1;
-- Result: Feb 12=16, Feb 13=17, Feb 14=24 (spike), plus earlier dates
```

```sql
-- S8: Twilio fallback on stuck orders
SELECT osh.status as twilio_status, COUNT(DISTINCT o.id) as order_count
FROM menuca_v3.orders o
JOIN menuca_v3.order_status_history osh ON osh.order_id = o.id AND osh.order_created_at = o.created_at
WHERE o.payment_status = 'paid'
AND o.order_status NOT IN ('completed','delivered','cancelled')
AND o.created_at < NOW() - INTERVAL '2 hours'
AND osh.status LIKE 'twilio%'
GROUP BY osh.status ORDER BY order_count DESC;
-- Result: twilio_fallback_call=9, twilio_fallback_confirmed=5, twilio_fallback_max_reached=4
```

---

## 3. Stripe Webhooks vs Orders

```sql
-- W2: Distinct events last 30d + 7d
SELECT
    COUNT(DISTINCT stripe_event_id) as distinct_events_30d,
    COUNT(DISTINCT stripe_event_id) FILTER (WHERE created_at >= NOW() - INTERVAL '7 days') as distinct_events_7d
FROM menuca_v3.stripe_webhook_events
WHERE created_at >= NOW() - INTERVAL '30 days';
-- Result: 30d=8020, 7d=2946
```

```sql
-- W3: Event type breakdown last 30d
SELECT event_type, COUNT(*) as total, COUNT(DISTINCT stripe_event_id) as distinct_events
FROM menuca_v3.stripe_webhook_events
WHERE created_at >= NOW() - INTERVAL '30 days'
GROUP BY event_type ORDER BY total DESC;
-- Result: succeeded=7623 (all unique), failed=334 (all unique), refunded=63 (all unique)
```

```sql
-- W5: Payment intent mapping (30d)
WITH webhook_pis AS (
    SELECT DISTINCT payload->'data'->'object'->>'id' as pi_id
    FROM menuca_v3.stripe_webhook_events
    WHERE event_type = 'payment_intent.succeeded'
    AND created_at >= NOW() - INTERVAL '30 days'
),
order_pis AS (
    SELECT DISTINCT stripe_payment_intent_id as pi_id
    FROM menuca_v3.orders
    WHERE stripe_payment_intent_id IS NOT NULL
    AND created_at >= NOW() - INTERVAL '30 days'
)
SELECT
    (SELECT COUNT(*) FROM webhook_pis) as webhook_distinct_pis_30d,
    (SELECT COUNT(*) FROM order_pis) as order_distinct_pis_30d,
    (SELECT COUNT(*) FROM webhook_pis w WHERE NOT EXISTS (SELECT 1 FROM order_pis o WHERE o.pi_id = w.pi_id)) as webhook_pi_no_order,
    (SELECT COUNT(*) FROM order_pis o WHERE NOT EXISTS (SELECT 1 FROM webhook_pis w WHERE w.pi_id = o.pi_id)) as order_pi_no_webhook;
-- Result: webhook_pis=7623, order_pis=136, no_order=7575, no_webhook=88
```

```sql
-- W6: Same for 7d
-- Result: webhook_pis=2804, order_pis=99, no_order=2766, no_webhook=61
```

```sql
-- W7: Livemode check
SELECT payload->'data'->'object'->>'livemode' as livemode, COUNT(*)
FROM menuca_v3.stripe_webhook_events
WHERE event_type = 'payment_intent.succeeded'
AND created_at >= NOW() - INTERVAL '30 days'
GROUP BY 1;
-- Result: true=7623 (all are livemode)
```

```sql
-- W8: Daily webhook volume (14 days)
SELECT (created_at AT TIME ZONE 'America/Toronto')::date as event_date,
    event_type, COUNT(*)
FROM menuca_v3.stripe_webhook_events
WHERE created_at >= NOW() - INTERVAL '14 days'
GROUP BY 1, 2 ORDER BY 1 DESC, 2;
-- Result: see daily table in report 03
```

---

## 4. Kill Switches

```sql
-- KS1: Online ordering status
SELECT online_ordering_enabled, COUNT(*) FROM menuca_v3.restaurants GROUP BY 1;
-- Result: true=186
```

```sql
-- KS2: Delivery/pickup/payment mode counts
SELECT
    COUNT(*) as total,
    COUNT(*) FILTER (WHERE has_delivery_enabled = true) as delivery_on,
    COUNT(*) FILTER (WHERE pickup_enabled = true) as pickup_on,
    COUNT(*) FILTER (WHERE busy_mode_enabled = true) as busy_mode_on,
    COUNT(*) FILTER (WHERE twilio_call = true) as twilio_on,
    COUNT(*) FILTER (WHERE payment_mode = 'live') as live_payment,
    COUNT(*) FILTER (WHERE payment_mode = 'test') as test_payment
FROM menuca_v3.delivery_and_pickup_configs WHERE deleted_at IS NULL;
-- Result: total=186, delivery=154, pickup=170, busy=1, twilio=170, live=6, test=180
```

```sql
-- KS4: Toggle RPC functions
SELECT routine_name FROM information_schema.routines
WHERE routine_schema = 'menuca_v3'
AND (routine_name LIKE 'toggle%' OR routine_name LIKE 'disable%' OR routine_name LIKE 'enable%' OR routine_name LIKE 'deactivate%')
ORDER BY routine_name;
-- Result: deactivate_device, toggle_deal_status, toggle_delivery_zone_status, toggle_favorite_restaurant, toggle_online_ordering
```

---

## 5. RLS / RPC

```sql
-- RLS1: Policy count per table
SELECT tablename, COUNT(*) as policy_count
FROM pg_policies WHERE schemaname = 'menuca_v3'
GROUP BY tablename ORDER BY policy_count DESC;
-- Result: see report 05
```

```sql
-- RLS2: Critical table policies
SELECT tablename, policyname, permissive, roles, cmd,
    LEFT(qual::text, 200) as qual_preview,
    LEFT(with_check::text, 200) as with_check_preview
FROM pg_policies
WHERE schemaname = 'menuca_v3'
AND tablename IN ('orders', 'restaurants', 'admin_users', 'users', 'payment_transactions')
ORDER BY tablename, policyname;
-- Result: see report 05
```

```sql
-- RLS3: Tables with RLS enabled but 0 policies
SELECT t.tablename
FROM pg_tables t
LEFT JOIN pg_policies p ON p.schemaname = t.schemaname AND p.tablename = t.tablename
WHERE t.schemaname = 'menuca_v3' AND t.rowsecurity = true
GROUP BY t.tablename HAVING COUNT(p.policyname) = 0;
-- Result: promotion_templates
```

```sql
-- RLS4: RPC functions touching critical paths
SELECT routine_name, data_type as return_type
FROM information_schema.routines
WHERE routine_schema = 'menuca_v3'
AND (routine_name LIKE '%order%' OR routine_name LIKE '%payment%'
     OR routine_name LIKE '%tablet%' OR routine_name LIKE '%domain%'
     OR routine_name LIKE '%slug%' OR routine_name LIKE '%restaurant_config%')
ORDER BY routine_name;
-- Result: 28 functions (see report 05)
```
