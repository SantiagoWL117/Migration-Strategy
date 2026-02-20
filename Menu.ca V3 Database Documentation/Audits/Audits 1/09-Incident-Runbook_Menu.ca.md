# 09 - Incident Runbook v0 (Menu.ca V3)

**Audit Date:** 2026-02-17  
**Source:** Database analysis, observed failure patterns  
**Status:** v0 — Covers top incidents observable from data

---

## Incident 1: Stuck Paid Orders (Not Reaching Restaurant)

**Severity:** P1/Critical  
**Current impact:** 70 orders stuck right now

### How to Confirm
```sql
SELECT o.id, o.order_number, r.name, o.order_status, o.payment_status,
    o.created_at AT TIME ZONE 'America/Toronto',
    EXTRACT(EPOCH FROM (NOW() - o.created_at))/60 AS mins_stuck
FROM menuca_v3.orders o
JOIN menuca_v3.restaurants r ON r.id = o.restaurant_id
WHERE o.payment_status = 'paid'
AND o.order_status NOT IN ('completed','delivered','cancelled')
AND o.created_at < NOW() - INTERVAL '15 minutes'
ORDER BY o.created_at DESC;
```

### Who to Notify
- Platform team (Jordan)
- Restaurant contact (if customer is waiting)

### Immediate Mitigation
1. Check if restaurant tablet/device is online
2. Check `acknowledged_at` — if NULL, device never received the order
3. Check `order_status_history` for Twilio fallback attempts
4. If Twilio max reached → call restaurant manually
5. If order is > 2 hours old → offer refund to customer

### Recovery
```sql
-- Force complete a stuck order
SELECT menuca_v3.update_order_status(<order_id>, 'completed');

-- Refund a stuck order
-- Must be done via Stripe dashboard, then record:
INSERT INTO menuca_v3.order_refunds (order_id, refund_amount, reason, created_at)
VALUES (<order_id>, <amount>, 'Stuck order - restaurant did not respond', NOW());
```

### Root Cause Investigation
- Is the tablet app installed and running?
- Is Supabase Realtime subscription working? (check Supabase dashboard)
- Is the restaurant's internet working?
- Is `payment_mode = 'test'`? (test mode may not trigger real device notifications)

### Post-Incident
- Log: restaurant_id, order_ids affected, resolution, time-to-resolve
- Prevention: implement auto-escalation after 10 minutes with no device ACK

---

## Incident 2: Payment Failure Spike

**Severity:** P1/Critical

### How to Confirm
```sql
SELECT
    date_trunc('hour', created_at) AS hour,
    COUNT(*) FILTER (WHERE event_type = 'payment_intent.succeeded') AS ok,
    COUNT(*) FILTER (WHERE event_type = 'payment_intent.payment_failed') AS failed,
    ROUND(COUNT(*) FILTER (WHERE event_type = 'payment_intent.payment_failed')::numeric /
        NULLIF(COUNT(*), 0) * 100, 2) AS fail_pct
FROM menuca_v3.stripe_webhook_events
WHERE created_at >= NOW() - INTERVAL '24 hours'
GROUP BY 1 ORDER BY 1 DESC;
```

### Who to Notify
- Platform team (Brian for code, Jordan for operations)

### Immediate Mitigation
1. Check Stripe dashboard for outage notices
2. Check if Stripe API keys are valid (Supabase Edge Function logs)
3. If Stripe is down → display "temporarily unavailable" on checkout
4. If our code is broken → rollback last deploy

### Recovery
- Stripe outages self-recover
- If API key rotation needed → update in Supabase secrets
- Retry failed payments if customer still wants order

### Post-Incident
- Log: duration, # affected customers, root cause
- Prevention: add Stripe status page monitoring

---

## Incident 3: Restaurant Receives No Orders (Zero Order Anomaly)

**Severity:** P2/High

### How to Confirm
```sql
-- Check if restaurant is supposed to be open
SELECT menuca_v3.is_restaurant_open_now(<restaurant_id>);
SELECT menuca_v3.can_accept_orders(<restaurant_id>);

-- Check recent order history
SELECT COUNT(*), MAX(created_at) AS last_order
FROM menuca_v3.orders
WHERE restaurant_id = <restaurant_id>
AND created_at >= NOW() - INTERVAL '7 days';

-- Check config
SELECT has_delivery_enabled, pickup_enabled, payment_mode
FROM menuca_v3.delivery_and_pickup_configs
WHERE restaurant_id = <restaurant_id> AND deleted_at IS NULL;

SELECT online_ordering_enabled FROM menuca_v3.restaurants WHERE id = <restaurant_id>;
```

### Common Causes
1. `online_ordering_enabled = false`
2. `payment_mode = 'test'` (customers can order but payments are test-mode)
3. Schedule not covering current hours
4. Menu cache stale (rebuild: `SELECT menuca_v3.rebuild_menu_cache(<id>)`)
5. No delivery area polygon (for delivery-only restaurants)
6. Custom domain DNS not resolving

### Immediate Mitigation
1. Verify ordering is enabled
2. Rebuild menu cache
3. Verify schedule covers current time
4. Test-place an order yourself

---

## Incident 4: Webhook Processing Failure

**Severity:** P1/Critical

### How to Confirm
```sql
SELECT COUNT(*) FROM menuca_v3.stripe_webhook_events WHERE processed = false;
SELECT * FROM menuca_v3.stripe_webhook_events WHERE processed = false ORDER BY created_at DESC LIMIT 10;
```

### Who to Notify
- Brian (code owner for webhook handler)

### Immediate Mitigation
1. Check Supabase Edge Function logs for errors
2. Check `error_message` column on unprocessed webhooks
3. Stripe will retry webhooks — check Stripe webhook dashboard for retry queue

### Recovery
```sql
-- Manually mark webhook as processed after handling
UPDATE menuca_v3.stripe_webhook_events SET processed = true WHERE id = <id>;
```

### Post-Incident
- Prevention: add dead letter queue, alert on unprocessed count > 0

---

## Incident 5: Menu Not Loading / Stale Menu

**Severity:** P2/High

### How to Confirm
```sql
-- Check cache age
SELECT restaurant_id, updated_at,
    EXTRACT(EPOCH FROM (NOW() - updated_at))/3600 AS hours_old
FROM menuca_v3.restaurant_menu_cache
WHERE restaurant_id = <restaurant_id>;
```

### Immediate Mitigation
```sql
SELECT menuca_v3.rebuild_menu_cache(<restaurant_id>);
```

### If Cache Rebuild Fails
- Check for data integrity issues (circular references, deleted courses, etc.)
- Check `get_restaurant_menu()` function for errors
- As fallback, app should use `get_restaurant_menu()` (live query) instead of cached version

---

## Incident 6: Twilio Fallback Max Reached (Restaurant Unreachable)

**Severity:** P1/Critical (customer has paid, restaurant is unreachable)

### How to Confirm
```sql
SELECT o.id, o.order_number, r.name, o.total_amount, o.customer_phone, o.customer_email
FROM menuca_v3.orders o
JOIN menuca_v3.restaurants r ON r.id = o.restaurant_id
JOIN menuca_v3.order_status_history osh ON osh.order_id = o.id AND osh.order_created_at = o.created_at
WHERE osh.status = 'twilio_fallback_max_reached'
AND o.created_at >= NOW() - INTERVAL '24 hours';
```

### Immediate Mitigation
1. Call restaurant manually using admin contact
2. If restaurant is truly closed → refund customer
3. If restaurant is open but device is down → have them check WiFi/tablet

### Recovery
- Process refund via Stripe dashboard
- Update order status to `cancelled` with reason

---

## General Incident Template

```
**Incident:** [Title]
**Detected:** [Timestamp]
**Severity:** P1/P2/P3
**Affected:** [Restaurant(s) / # customers / $ amount]
**Status:** Investigating / Mitigating / Resolved

**Timeline:**
- HH:MM — Detected via [alert/report/customer complaint]
- HH:MM — [Action taken]
- HH:MM — [Resolution]

**Root Cause:** [Description]
**Prevention:** [What we'll do to prevent recurrence]
**Action Items:** [Specific tasks with owners]
```
