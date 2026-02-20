# 04 - Order State Machine (Menu.ca V3)

**Audit Date:** 2026-02-17  
**Source:** Live database queries against `menuca_v3.orders` + `order_status_history`  
**Evidence:** 137 orders, 1,607 status history entries, 8,012 Stripe webhook events

---

## Order Status Values (Observed in Production)

| Status | Count in `orders` | Description |
|---|---|---|
| `pending` | 38 | Order created, awaiting restaurant acknowledgment |
| `confirmed` | 12 | Restaurant acknowledged/accepted |
| `preparing` | 1 | Kitchen actively preparing |
| `ready` | 71 | Food ready for pickup/delivery |
| `delivered` | 9 | Delivered to customer |
| `completed` | 6 | Order fully completed |

**Missing from data (expected but not observed):**
- `cancelled` — 0 orders currently in this state (but `cancelled_at` is populated on some)
- `refunded` — Handled via `payment_status` not `order_status`

---

## Order Lifecycle State Machine

```
                          CUSTOMER PLACES ORDER
                                  |
                                  v
                          +---------------+
                          |    PENDING    |  (order_status='pending', payment_status='pending' or 'paid')
                          +---------------+
                                  |
                     +-----------+-----------+
                     |                       |
              Stripe succeeds          Stripe fails
              (webhook)                (webhook)
                     |                       |
                     v                       v
            payment_status='paid'    payment_status='failed'
                     |                    [DEAD END - no recovery path observed]
                     |
          Restaurant device acknowledges
          (acknowledged_by_device_id, acknowledged_at set)
                     |
              +------+-------+
              |              |
         Device ACK     No ACK within timeout
              |              |
              v              v
      +---------------+  Twilio fallback call triggered
      |   CONFIRMED   |  (status: twilio_fallback_call)
      +---------------+       |
              |          +----+----+
              v          |         |
      +---------------+  Call     Max retries
      |   PREPARING   |  confirmed reached
      +---------------+  |         |
              |          v         v
              v     CONFIRMED   twilio_fallback_max_reached
      +---------------+         [STUCK - requires manual intervention]
      |     READY     |
      +---------------+
              |
         +----+----+
         |         |
      Pickup    Delivery
         |         |
         v         v
   +-----------+  +-----------+
   | COMPLETED |  | DELIVERED |
   +-----------+  +-----------+
```

---

## Status History Transitions (from `order_status_history`)

| Status Logged | Count | Notes |
|---|---|---|
| `pending` | 413 | Initial state (most frequent) |
| `confirmed` | 274 | Restaurant accepted |
| `preparing` | 291 | Kitchen working |
| `ready` | 533 | Most orders reach this state |
| `completed` | 51 | Far fewer than `ready` |
| `delivered` | 9 | Delivery completion |
| `twilio_fallback_call` | 25 | Phone fallback triggered |
| `twilio_fallback_confirmed` | 6 | Restaurant answered phone |
| `twilio_fallback_max_reached` | 5 | All retries exhausted |

**Key Observation:** 533 `ready` entries vs only 51 `completed` + 9 `delivered` = **88.7% of orders that reach READY never reach COMPLETED/DELIVERED.** This is the single biggest operational failure.

---

## Payment Status Values (Observed)

| Payment Status | Order Count | Description |
|---|---|---|
| `paid` | 105 | Stripe payment successful |
| `pending` | 8 | Awaiting payment |
| `refunded` | 20 | Full refund processed |
| `partially_refunded` | 4 | Partial refund |

---

## Stuck Orders Analysis (CRITICAL)

**70 orders are currently paid but NOT completed/delivered/cancelled** (as of 2026-02-17):

| Restaurant | Stuck Orders | Oldest | Status Breakdown |
|---|---|---|---|
| JJ's Shawarma | 52 | Feb 10 | pending(22), ready(19), confirmed(10), preparing(1) |
| Season's Pizza | 5 | Feb 10 | ready(5) |
| Pizzalicious | 8 | Feb 12 | ready(4), confirmed(4) |
| Pho Bo Ga King - Somerset | 3 | Feb 13 | ready(3) |
| Centertown Donair & Pizza | 0 | - | Only restaurant completing orders |

**Root cause hypothesis:** Orders reach `ready` but there is no mechanism (or it's broken) to transition to `completed`/`delivered`. The restaurant tablet or app may not have a "complete order" button, or it's not being used.

---

## Transition Triggers

| Transition | Trigger | Evidence |
|---|---|---|
| (none) -> `pending` | Customer submits order | `create_order()` function |
| `pending` -> `confirmed` | Restaurant device acknowledges | `tablet_update_order_status()`, `acknowledged_at` column |
| `confirmed` -> `preparing` | Restaurant starts prep | `tablet_update_order_status()` or `update_order_status()` |
| `preparing` -> `ready` | Food is ready | Same as above |
| `ready` -> `delivered` | Driver marks delivered | `update_order_status()` |
| `ready` -> `completed` | Pickup completed | `update_order_status()` |
| Any -> `cancelled` | Customer/admin cancels | `cancel_order()` / `cancel_customer_order()` |
| `pending` (no response) -> Twilio fallback | Timeout (no device ACK) | App logic (not in DB functions) |

---

## Idempotency & Safety

| Mechanism | Status | Evidence |
|---|---|---|
| Stripe webhook dedup | EXISTS | `stripe_event_id` unique column in `stripe_webhook_events` |
| Order items immutability | EXISTS | `prevent_order_items_modification` trigger on `order_items` |
| Status history logging | EXISTS | `log_order_status_change` trigger on `orders` |
| `updated_at` auto-update | EXISTS | `update_order_timestamp` trigger on `orders` |
| Concurrent status update protection | UNKNOWN | Need app code to verify optimistic locking |

---

## Timeouts & Retries

| Event | Timeout | Retry | Evidence |
|---|---|---|---|
| Device acknowledgment | UNKNOWN | Twilio fallback (phone call) | `twilio_fallback_call` status entries |
| Twilio fallback | UNKNOWN | Up to N attempts | `twilio_fallback_max_reached` (5 instances) |
| Payment confirmation | UNKNOWN | Via Stripe webhook retry | Stripe handles retries |
| Order completion | NO TIMEOUT | No auto-complete mechanism observed | 70 stuck orders prove this |

---

## Critical Failure: No Order Completion Mechanism

**The data proves there is no reliable path from `ready` to `completed`/`delivered`.**

- 71 orders currently at `ready` status
- Only 15 orders have EVER reached `completed` or `delivered` (all from Centertown Donair & Pizza)
- This means **89% of orders never reach terminal state**

**Immediate fix needed:** Auto-complete orders after X minutes at `ready`, or verify that the tablet app has a working "complete" button.
