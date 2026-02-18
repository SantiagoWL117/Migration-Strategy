# 03 - Dashboard & Alert Spec (Menu.ca V3)

**Audit Date:** 2026-02-17  
**Source:** Live production database queries  
**All queries are executable against the Supabase `menuca_v3` schema**

---

## Section E1: Golden Signals

### 1. Order Success Rate

**Definition:** Orders that reach terminal state (completed/delivered) / Total paid orders

```sql
SELECT
    COUNT(*) FILTER (WHERE order_status IN ('completed','delivered'))::numeric /
    NULLIF(COUNT(*) FILTER (WHERE payment_status = 'paid'), 0) * 100
    AS order_success_rate_pct
FROM menuca_v3.orders
WHERE created_at >= NOW() - INTERVAL '24 hours';
```

**Current value (all-time):** 15 / 105 = **14.3%** (CRITICAL - should be >90%)

---

### 2. Payment Success Rate

**Definition:** Successful payment webhooks / (Successful + Failed webhooks)

```sql
SELECT
    COUNT(*) FILTER (WHERE event_type = 'payment_intent.succeeded') AS successes,
    COUNT(*) FILTER (WHERE event_type = 'payment_intent.payment_failed') AS failures,
    ROUND(
        COUNT(*) FILTER (WHERE event_type = 'payment_intent.payment_failed')::numeric /
        NULLIF(COUNT(*), 0) * 100, 2
    ) AS failure_rate_pct
FROM menuca_v3.stripe_webhook_events
WHERE event_type IN ('payment_intent.succeeded', 'payment_intent.payment_failed')
AND created_at >= NOW() - INTERVAL '24 hours';
```

**Current value (all-time):** 4.20% failure rate (334/7,950)

---

### 3. Order Volume Anomaly (Per Restaurant)

```sql
-- Compare today vs 7-day average per restaurant
WITH daily AS (
    SELECT restaurant_id,
        COUNT(*) FILTER (WHERE created_at >= (NOW() AT TIME ZONE 'America/Toronto')::date) AS today,
        COUNT(*) FILTER (WHERE created_at >= NOW() - INTERVAL '7 days')::numeric / 7 AS avg_7d
    FROM menuca_v3.orders
    GROUP BY restaurant_id
)
SELECT r.name, d.today, ROUND(d.avg_7d, 1) as avg_7d,
    CASE WHEN d.avg_7d > 0 THEN ROUND((d.today - d.avg_7d) / d.avg_7d * 100, 1) ELSE NULL END AS pct_change
FROM daily d
JOIN menuca_v3.restaurants r ON r.id = d.restaurant_id
ORDER BY d.today DESC;
```

---

### 4. Stuck Orders Count

**Definition:** Orders where payment_status = 'paid' AND order_status NOT IN ('completed', 'delivered', 'cancelled') AND age > 30 minutes

```sql
SELECT COUNT(*) AS stuck_orders
FROM menuca_v3.orders
WHERE payment_status = 'paid'
AND order_status NOT IN ('completed', 'delivered', 'cancelled')
AND created_at < NOW() - INTERVAL '30 minutes';
```

**Current value:** **70 stuck orders** (CRITICAL)

---

### 5. Webhook Processing Backlog

```sql
SELECT COUNT(*) AS unprocessed_webhooks
FROM menuca_v3.stripe_webhook_events
WHERE processed = false;
```

**Current value:** 0 (healthy)

---

### 6. Menu Cache Freshness

```sql
SELECT
    COUNT(*) AS total,
    COUNT(*) FILTER (WHERE updated_at > NOW() - INTERVAL '24 hours') AS fresh_24h,
    COUNT(*) FILTER (WHERE updated_at <= NOW() - INTERVAL '7 days') AS stale_7d,
    MAX(updated_at) AS newest_cache,
    MIN(updated_at) AS oldest_cache
FROM menuca_v3.restaurant_menu_cache;
```

**Current value:** 0 caches updated in last 7 days. All 186 are stale. **Newest: Feb 6** (11 days old)

---

## Section E2: Restaurant Health Card

### Per-Restaurant Health Card Query

```sql
SELECT
    r.id,
    r.name,
    r.status,
    r.verified,
    dc.payment_mode,
    -- Orders
    COUNT(o.id) FILTER (WHERE o.created_at >= NOW() - INTERVAL '15 minutes') AS orders_15min,
    COUNT(o.id) FILTER (WHERE o.created_at >= NOW() - INTERVAL '1 hour') AS orders_1h,
    COUNT(o.id) FILTER (WHERE o.created_at >= NOW() - INTERVAL '24 hours') AS orders_24h,
    -- Financials
    COALESCE(SUM(o.total_amount) FILTER (WHERE o.created_at >= NOW() - INTERVAL '24 hours'), 0) AS gmv_24h,
    COALESCE(ROUND(AVG(o.total_amount) FILTER (WHERE o.created_at >= NOW() - INTERVAL '24 hours'), 2), 0) AS aov_24h,
    -- Stuck orders
    COUNT(o.id) FILTER (
        WHERE o.payment_status = 'paid'
        AND o.order_status NOT IN ('completed', 'delivered', 'cancelled')
        AND o.created_at < NOW() - INTERVAL '30 minutes'
    ) AS stuck_orders,
    -- Refunds
    COUNT(o.id) FILTER (WHERE o.payment_status IN ('refunded', 'partially_refunded')
        AND o.created_at >= NOW() - INTERVAL '24 hours') AS refunds_24h,
    -- Completion rate
    ROUND(
        COUNT(o.id) FILTER (WHERE o.order_status IN ('completed','delivered')
            AND o.created_at >= NOW() - INTERVAL '7 days')::numeric /
        NULLIF(COUNT(o.id) FILTER (WHERE o.payment_status = 'paid'
            AND o.created_at >= NOW() - INTERVAL '7 days'), 0) * 100, 1
    ) AS completion_rate_7d,
    -- Cache freshness
    mc.updated_at AS cache_last_updated,
    EXTRACT(EPOCH FROM (NOW() - mc.updated_at))/3600 AS cache_age_hours
FROM menuca_v3.restaurants r
LEFT JOIN menuca_v3.orders o ON o.restaurant_id = r.id
LEFT JOIN menuca_v3.delivery_and_pickup_configs dc ON dc.restaurant_id = r.id AND dc.deleted_at IS NULL
LEFT JOIN menuca_v3.restaurant_menu_cache mc ON mc.restaurant_id = r.id
GROUP BY r.id, r.name, r.status, r.verified, dc.payment_mode, mc.updated_at
ORDER BY orders_24h DESC;
```

### Health Card Layout

| Field | Green | Yellow | Red |
|---|---|---|---|
| Orders (24h) | > 0 during business hours | 0 during business hours | 0 for 48h+ |
| Completion Rate (7d) | > 80% | 50-80% | < 50% |
| Stuck Orders | 0 | 1-2 | 3+ |
| Refund Rate (7d) | < 5% | 5-15% | > 15% |
| AOV | Within 20% of historical | 20-50% deviation | > 50% deviation |
| Cache Age | < 24h | 24h-7d | > 7d |
| Payment Mode | `live` | — | `test` |
| Verified | `true` | — | `false` |

---

## Section E3: Alert Rules

| # | Alert | Severity | Trigger | Time Window | Owner | First Action |
|---|---|---|---|---|---|---|
| 1 | **Order completion rate drop** | P1/Critical | Completion rate < 50% for any restaurant with orders | Rolling 24h | Platform | Check tablet/device status, contact restaurant |
| 2 | **Payment failure spike** | P1/Critical | > 10% failure rate on Stripe webhooks | Rolling 1h | Platform | Check Stripe dashboard, verify API keys |
| 3 | **Stuck paid order** | P2/High | Any order paid > 15 min without `confirmed` status | Per-order | Platform | Trigger Twilio fallback, then manual follow-up |
| 4 | **Twilio max retries reached** | P1/Critical | `twilio_fallback_max_reached` logged | Per-order | Platform | Call restaurant manually, offer refund to customer |
| 5 | **Zero orders anomaly** | P2/High | Restaurant with history of orders has 0 in expected busy period | Rolling 4h during business hours | Platform | Check if restaurant is open, verify menu/ordering enabled |
| 6 | **Menu cache stale** | P3/Medium | Cache older than 24 hours | Daily check | Platform | Run `rebuild_menu_cache(restaurant_id)` |
| 7 | **Webhook backlog** | P1/Critical | `unprocessed_webhooks > 0` for > 5 minutes | Rolling 5m | Platform | Check Edge Function logs, Stripe webhook dashboard |
| 8 | **Refund rate spike** | P2/High | > 3 refunds in 24h for single restaurant | Rolling 24h | Platform | Investigate order issues, contact restaurant |
| 9 | **Test mode restaurant receiving real orders** | P1/Critical | Order created for restaurant with `payment_mode = 'test'` | Per-order | Platform | Verify payment captured, switch to live if ready |
| 10 | **Device offline** | P2/High | No heartbeat from registered device > 30min during business hours | Rolling 30m | Platform | Contact restaurant, check connectivity |

---

## Current Platform Health Snapshot (2026-02-17)

| Signal | Value | Status |
|---|---|---|
| Order completion rate (all-time) | 14.3% | RED |
| Stuck paid orders | 70 | RED |
| Payment failure rate | 4.2% | YELLOW |
| Webhook backlog | 0 | GREEN |
| Restaurants on TEST payment mode | 180/186 (97%) | RED |
| Verified restaurants | 17/186 (9%) | RED |
| Menu cache freshness | All stale (newest: Feb 6) | RED |
| Cart sessions | 0 (not operational) | RED |
| Feature flags table | Does not exist | RED |
| Total GMV | $5,028.81 | LOW |
| Avg order value | $36.71 | OK |
| Refund rate | 20.5% (28/137) | RED |
