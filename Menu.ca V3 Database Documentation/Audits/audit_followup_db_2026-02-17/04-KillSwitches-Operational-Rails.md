# 04 - Kill Switches and Operational Rails

**Date:** 2026-02-17  
**Schema:** menuca_v3

---

## 4.1 Existing Switches in the Database

### Platform-Level Switches

| # | Switch | Table.Column | Scope | Current State |
|---|---|---|---|---|
| 1 | **Online ordering enabled** | `restaurants.online_ordering_enabled` | Per-restaurant | 186/186 = ALL ON |
| 2 | **Payment mode** | `delivery_and_pickup_configs.payment_mode` | Per-restaurant | 6 live, 180 test |
| 3 | **Delivery enabled** | `delivery_and_pickup_configs.has_delivery_enabled` | Per-restaurant | 154 on, 32 off |
| 4 | **Pickup enabled** | `delivery_and_pickup_configs.pickup_enabled` | Per-restaurant | 170 on, 16 off |
| 5 | **Twilio call fallback** | `delivery_and_pickup_configs.twilio_call` | Per-restaurant | 170 on, 16 off |
| 6 | **Busy mode** | `delivery_and_pickup_configs.busy_mode_enabled` | Per-restaurant | 1 on, 185 off |
| 7 | **Device active** | `devices.is_active` | Per-device | 1,034/1,034 = ALL ON |

### RPC Toggle Functions

| Function | Purpose | How Invoked |
|---|---|---|
| `toggle_online_ordering(restaurant_id, enabled)` | Enable/disable ordering | RPC call |
| `toggle_delivery_zone_status(zone_id, enabled)` | Enable/disable delivery zone | RPC call |
| `toggle_deal_status(deal_id, active)` | Enable/disable promotional deal | RPC call |
| `toggle_favorite_restaurant(user_id, restaurant_id)` | User favorite toggle | RPC call (not operational) |
| `deactivate_device(device_id)` | Deactivate a POS device | RPC call |

### Missing Switches (Do Not Exist)

| Switch Needed | Impact | Notes |
|---|---|---|
| Global ordering kill-switch | Platform-wide disable | Would need to UPDATE all 186 restaurants |
| Global payment kill-switch | Stop all charges | Would need to switch all to `payment_mode='test'` |
| Feature flags | Granular feature control | `feature_flags` table documented but NOT created |
| Maintenance mode | Show "under maintenance" page | No mechanism exists |
| Per-restaurant "freeze" | Stop one restaurant without disabling | Could use `online_ordering_enabled = false` |

---

## 4.2 Safe Procedures

### Procedure 1: Disable Ordering for ONE Restaurant

**When to use:** Restaurant is having issues, needs to stop receiving orders immediately.

**Steps:**

1. **Verify current state:**
```sql
SELECT id, online_ordering_enabled
FROM menuca_v3.restaurants WHERE id = <RESTAURANT_ID>;
```

2. **Disable ordering:**
```sql
SELECT menuca_v3.toggle_online_ordering(<RESTAURANT_ID>, false);
```

3. **Verify:**
```sql
SELECT id, online_ordering_enabled
FROM menuca_v3.restaurants WHERE id = <RESTAURANT_ID>;
-- Expected: online_ordering_enabled = false
```

4. **Expected impact:** New orders cannot be placed. Existing in-progress orders are unaffected.

5. **Revert:**
```sql
SELECT menuca_v3.toggle_online_ordering(<RESTAURANT_ID>, true);
```

---

### Procedure 2: Disable Ordering Platform-Wide

**When to use:** Critical platform failure affecting all restaurants (e.g., payment processing is broken).

**Steps:**

1. **Record current state (for revert):**
```sql
SELECT id, online_ordering_enabled
FROM menuca_v3.restaurants
WHERE online_ordering_enabled = true;
-- Save this list for revert
```

2. **Disable all:**
```sql
UPDATE menuca_v3.restaurants SET online_ordering_enabled = false;
```

3. **Verify:**
```sql
SELECT COUNT(*) FROM menuca_v3.restaurants WHERE online_ordering_enabled = true;
-- Expected: 0
```

4. **Expected impact:** No new orders can be placed on any restaurant. Existing orders continue processing. Menu pages remain viewable.

5. **Revert:**
```sql
UPDATE menuca_v3.restaurants SET online_ordering_enabled = true;
-- Or selectively re-enable only previously-enabled restaurants
```

---

### Procedure 3: Disable Payments But Keep Browsing

**When to use:** Stripe issues -- let customers browse menus but prevent checkout.

**Steps:**

1. **Record current payment modes:**
```sql
SELECT restaurant_id, payment_mode
FROM menuca_v3.delivery_and_pickup_configs
WHERE payment_mode = 'live' AND deleted_at IS NULL;
-- Save this list (currently 6 restaurants)
```

2. **Switch all to test mode:**
```sql
UPDATE menuca_v3.delivery_and_pickup_configs
SET payment_mode = 'test'
WHERE payment_mode = 'live' AND deleted_at IS NULL;
```

3. **Verify:**
```sql
SELECT payment_mode, COUNT(*)
FROM menuca_v3.delivery_and_pickup_configs
WHERE deleted_at IS NULL GROUP BY payment_mode;
-- Expected: all 186 on 'test'
```

4. **Expected impact:** Menus remain accessible. Checkout will use test Stripe keys (no real charges). Customers may see confusing behavior if test keys produce test confirmations.

5. **Revert:**
```sql
UPDATE menuca_v3.delivery_and_pickup_configs
SET payment_mode = 'live'
WHERE restaurant_id IN (<saved_restaurant_ids>) AND deleted_at IS NULL;
```

---

### Procedure 4: Emergency Response for "Paid But Stuck" Incident

**When to use:** Customer paid but order is not reaching restaurant.

**Steps:**

1. **Identify stuck orders:**
```sql
SELECT o.id, o.order_number, o.restaurant_id, o.order_status,
    o.total_amount, o.acknowledged_at,
    EXTRACT(EPOCH FROM (NOW() - o.created_at))/60 AS minutes_stuck
FROM menuca_v3.orders o
WHERE o.payment_status = 'paid'
AND o.order_status NOT IN ('completed','delivered','cancelled')
AND o.created_at < NOW() - INTERVAL '15 minutes'
ORDER BY o.created_at DESC;
```

2. **For orders with no device ACK (acknowledged_at IS NULL):**
   - Check if Twilio fallback was triggered:
```sql
SELECT osh.status, osh.created_at
FROM menuca_v3.order_status_history osh
WHERE osh.order_id = <ORDER_ID>
ORDER BY osh.created_at;
```
   - If no Twilio events: device is likely offline. Contact restaurant manually.

3. **For orders acknowledged but not completed:**
   - The restaurant has the order. Issue is in the completion flow.
   - If order is at `ready` status: food is done but "complete" was never pressed.
   - Manual completion:
```sql
UPDATE menuca_v3.orders
SET order_status = 'completed', completed_at = NOW()
WHERE id = <ORDER_ID>;
```

4. **For orders requiring refund:**
   - Process refund in Stripe dashboard first
   - Then record in DB:
```sql
INSERT INTO menuca_v3.order_refunds (order_id, restaurant_id, refund_amount, reason_code, notes, created_at)
VALUES (<ORDER_ID>, <RESTAURANT_ID>, <AMOUNT>, 'stuck_order', 'Order stuck - restaurant unresponsive', NOW());
UPDATE menuca_v3.orders SET order_status = 'cancelled', cancelled_at = NOW(), cancellation_reason = 'Stuck order refund' WHERE id = <ORDER_ID>;
```

5. **Verify resolution:**
```sql
SELECT id, order_status, payment_status, completed_at, cancelled_at
FROM menuca_v3.orders WHERE id = <ORDER_ID>;
```

---

### Procedure 5: Bulk-Close Stale Stuck Orders

**When to use:** Large backlog of old stuck orders needs cleanup (like the current 87 orders >24h old).

**Steps:**

1. **Identify scope:**
```sql
SELECT COUNT(*), MIN(created_at), MAX(created_at)
FROM menuca_v3.orders
WHERE payment_status = 'paid'
AND order_status NOT IN ('completed','delivered','cancelled')
AND created_at < NOW() - INTERVAL '24 hours';
```

2. **Auto-complete orders that reached 'ready' (food was prepared):**
```sql
UPDATE menuca_v3.orders
SET order_status = 'completed', completed_at = NOW()
WHERE payment_status = 'paid'
AND order_status = 'ready'
AND created_at < NOW() - INTERVAL '24 hours';
```

3. **Cancel orders that never reached restaurant (still 'pending'):**
```sql
UPDATE menuca_v3.orders
SET order_status = 'cancelled', cancelled_at = NOW(), cancellation_reason = 'Auto-cancelled: unacknowledged >24h'
WHERE payment_status = 'paid'
AND order_status = 'pending'
AND acknowledged_at IS NULL
AND created_at < NOW() - INTERVAL '24 hours';
```

4. **Verify:**
```sql
SELECT order_status, COUNT(*)
FROM menuca_v3.orders
WHERE payment_status = 'paid'
AND created_at < NOW() - INTERVAL '24 hours'
GROUP BY order_status;
```

5. **Note:** Orders that were `pending` and never acknowledged may need refunds processed through Stripe dashboard.
