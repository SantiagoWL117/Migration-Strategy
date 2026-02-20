# 03 - Stripe Webhooks vs Orders Reconciliation

**Date:** 2026-02-17  
**Schema:** menuca_v3

---

## 3.1 Deduplicated Webhook Stream

### Distinct Counts

| Metric | Last 30 days | Last 7 days |
|---|---|---|
| Distinct stripe_event_id (all types) | 8,020 | 2,946 |
| Distinct succeeded payment_intent IDs | 7,623 | 2,804 |
| Distinct failed payment_intent events | 334 | -- |
| Distinct charge.refunded events | 63 | -- |

**Note:** Every row in `stripe_webhook_events` has a unique `stripe_event_id` -- there are zero duplicate events. This rules out webhook redelivery/retry as an explanation for the high volume.

### No charge_id Column

The `stripe_webhook_events` table does not store a separate `charge_id` column. Charge data would be nested inside the `payload` JSONB for `charge.refunded` events.

---

## 3.2 Payment Intent Mapping to Orders

### 30-Day Window

| Category | Count |
|---|---|
| Distinct succeeded webhook PIs | 7,623 |
| Distinct order PIs (from orders.stripe_payment_intent_id) | 136 |
| **Succeeded webhook PIs with NO matching order** | **7,575** |
| **Order PIs with NO matching succeeded webhook** | **88** |

### 7-Day Window

| Category | Count |
|---|---|
| Distinct succeeded webhook PIs | 2,804 |
| Distinct order PIs | 99 |
| **Succeeded webhook PIs with NO matching order** | **2,766** |
| **Order PIs with NO matching succeeded webhook** | **61** |

### Ratios

- **30d:** 7,575 unmatched webhook PIs / 136 order PIs = **55.7:1 ratio**
- **7d:** 2,766 unmatched webhook PIs / 99 order PIs = **27.9:1 ratio**
- **All webhooks report `livemode = true`** -- these are not Stripe test-mode events

---

## 3.3 Anomaly Explanation

### The Core Anomaly

99.4% of successful Stripe payment intents recorded in the webhook table (7,575 of 7,623 in 30 days) have no corresponding order in the `menuca_v3.orders` table.

### Ranked Explanations

#### 1. MOST LIKELY: Shared Stripe Account With V1/V2 Legacy System

**Evidence:** 
- All 7,623 succeeded events are `livemode = true`
- The Menu.ca platform has been operating since V1 (165 restaurants migrated from V1, 20 from V2)
- The Stripe webhook endpoint likely receives events from ALL Stripe charges on the same Stripe account
- V1/V2 orders are NOT in the `menuca_v3.orders` table
- Daily webhook volume (200-720/day) is plausible for a platform with 186 restaurants processing orders across multiple systems

**Validation step:** Check Stripe dashboard for multiple webhook endpoints. If the same endpoint receives events from V1, V2, and V3 charges, this explains the ratio entirely.

#### 2. POSSIBLE: Stripe Checkout Sessions Without Order Creation

**Evidence:**
- 88 order PIs (30d) and 61 (7d) have no matching webhook -- suggesting some orders were created with payment intents that either failed to generate a webhook or the webhook was processed before being logged
- If the frontend creates a Stripe PaymentIntent before calling `create_order()`, abandoned checkouts would generate succeeded webhooks without orders

**Validation step:** Check app code for the order of operations: does PaymentIntent creation happen before or after order row insertion?

#### 3. UNLIKELY: Webhook Redelivery / Retries

**Evidence AGAINST:** Every `stripe_event_id` is unique (8,020 distinct = 8,020 rows). Stripe would reuse the same event ID on retries. This explanation is ruled out.

#### 4. UNLIKELY: Multiple Stripe Accounts

**Evidence:** All events use the same Stripe account key prefix (`KjTadFqIQL` visible in event IDs). Only one Stripe account appears to be active.

### Daily Webhook Volume (Last 14 Days)

| Date | Succeeded | Failed | Refunded |
|---|---|---|---|
| Feb 17 | 7 | 0 | 1 |
| Feb 16 | 272 | 7 | 2 |
| Feb 15 | 333 | 25 | 4 |
| Feb 14 | 601 | 14 | 5 |
| Feb 13 | 721 | 22 | 17 |
| Feb 12 | 388 | 22 | 6 |
| Feb 11 | 258 | 10 | 1 |
| Feb 10 | 231 | 3 | 5 |
| Feb 9 | 188 | 12 | 0 |
| Feb 8 | 396 | 15 | 2 |
| Feb 7 | 493 | 19 | 0 |
| Feb 6 | 719 | 47 | 1 |
| Feb 5 | 339 | 10 | 3 |
| Feb 4 | 285 | 13 | 2 |
| Feb 3 | 222 | 13 | 2 |

**Pattern:** Volume fluctuates between 188-721/day with no weekday/weekend pattern. Feb 6 shows a payment failure spike (47 failures vs normal 10-25), worth investigating. The overall volume is consistent with a busy restaurant platform processing real orders through Stripe.

### Payment Failure Rate

- Overall: 334 / (7,623 + 334) = **4.20%** failure rate
- This is within normal ranges for online card payments (2-5% is typical)
- Feb 6 spike: 47 failures out of 766 attempts = **6.14%** (elevated)

---

## Recommendations

1. **Confirm shared Stripe account theory:** Check Stripe dashboard webhook endpoints. If V3 and V1/V2 share the same Stripe account, the 55:1 ratio is explained.
2. **Filter webhook processing:** If confirmed, add a check in the webhook handler to skip events that don't correspond to V3 payment intents. This will reduce unnecessary processing.
3. **Investigate 88 orphaned order PIs:** These orders have a `stripe_payment_intent_id` but no corresponding succeeded webhook. Check if webhooks were lost or if these are old orders predating webhook logging.
4. **Investigate Feb 6 failure spike:** 6.14% failure rate suggests a transient Stripe or configuration issue.

---

## Queries

All SQL queries used are in `06-Appendix-All-SQL.md`.
