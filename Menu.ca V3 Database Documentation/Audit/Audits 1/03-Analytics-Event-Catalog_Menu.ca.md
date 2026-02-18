# 03 - Analytics & Event Catalog (Menu.ca V3)

**Audit Date:** 2026-02-17  
**Source:** Database schema analysis  
**Status:** MOSTLY MISSING ACCESS

---

## Missing Access

> **I do not have access to the frontend or backend application code.** Analytics/event tracking is implemented in the app layer, not the database layer. I cannot determine:
> - Which analytics library is used (Segment, PostHog, GA4, Mixpanel, custom)
> - What events fire in the frontend (page views, add-to-cart, checkout steps)
> - Whether analytics is disabled behind env vars or feature flags
> - Whether events actually reach their destination
>
> **To complete this section:**
> 1. Run this audit in the **Replit environment** with app code access
> 2. Search for: `analytics.track`, `posthog.capture`, `gtag`, `mixpanel.track`, `segment`, or similar
> 3. Check `.env` for analytics keys: `NEXT_PUBLIC_POSTHOG_KEY`, `GA_MEASUREMENT_ID`, etc.
> 4. Check `Frontend-build/customer-app/.env.example` for analytics config hints

---

## What EXISTS in the Database (Event-Adjacent Data)

### A. Stripe Webhook Events (the only "event stream" in the DB)

| Event Type | Count | Processed | Notes |
|---|---|---|---|
| `payment_intent.succeeded` | 7,616 | 100% | Payment confirmations |
| `payment_intent.payment_failed` | 334 | 100% | Failed payment attempts |
| `charge.refunded` | 62 | 100% | Refund confirmations |

**Total:** 8,012 events, all processed, zero backlog.

**Concern:** 7,616 succeeded webhooks vs only 137 orders = **55:1 ratio.** This suggests either:
- Multiple webhook retries per order
- Test/dev webhooks mixed with production
- Webhooks from a different Stripe account or environment
- **Action needed:** Query Stripe dashboard to reconcile

### B. Order Status History (Implicit Event Log)

| Status | Count | Can serve as event for... |
|---|---|---|
| `pending` | 413 | Order Created |
| `confirmed` | 274 | Restaurant Accepted |
| `preparing` | 291 | Preparation Started |
| `ready` | 533 | Order Ready |
| `completed` | 51 | Order Completed |
| `delivered` | 9 | Order Delivered |
| `twilio_fallback_call` | 25 | Alert: Device Not Responding |
| `twilio_fallback_confirmed` | 6 | Fallback Success |
| `twilio_fallback_max_reached` | 5 | Alert: Restaurant Unreachable |

### C. Audit Log (Partitioned)

- `audit_log` table with monthly partitions (2025_12 through 2026_03)
- Tracks: `table_name`, `record_id`, `action` (INSERT/UPDATE/DELETE), `old_data`, `new_data`, `changed_by`, `ip_address`
- **This is a comprehensive change log** but NOT user-facing analytics

### D. Admin Audit Log

- `admin_audit_log` table for admin-specific actions
- Separate from general audit_log

### E. Restaurant Analytics Configs

- `restaurant_analytics_configs` table exists (RLS enabled)
- Purpose: Per-restaurant analytics configuration
- **Column details needed** — this may store GA tracking IDs or similar

---

## What DOES NOT EXIST in the Database

| Expected Event | Status | Impact |
|---|---|---|
| Page views / sessions | NOT TRACKED (DB-side) | Cannot measure traffic or conversion |
| Add-to-cart events | NOT TRACKED (DB-side) | Cannot measure cart abandonment |
| Checkout started events | NOT TRACKED | Cannot measure checkout dropoff |
| `cart_sessions` table | EXISTS but EMPTY (0 rows) | Cart tracking is not operational |
| Feature flag events | `feature_flags` table DOES NOT EXIST | Documented but never created |
| System config | `system_config` table DOES NOT EXIST | Documented but never created |
| `data_migrations` table | DOES NOT EXIST | Documented but never created |
| Search events | NOT TRACKED | Cannot measure search behavior |
| Error events | NOT TRACKED (DB-side) | Errors may only exist in app logs |

---

## Proposed Event Catalog (What SHOULD Exist)

### Customer Journey Events

| Event Name | When to Fire | Required Props | Destination |
|---|---|---|---|
| `page_viewed` | Every page load | restaurant_id, page_type, language | PostHog/GA4 |
| `menu_viewed` | Menu page load | restaurant_id, course_count | PostHog/GA4 |
| `item_added_to_cart` | Add to cart click | restaurant_id, dish_id, quantity, price | PostHog/GA4 |
| `item_removed_from_cart` | Remove from cart | restaurant_id, dish_id | PostHog/GA4 |
| `checkout_started` | Checkout page load | restaurant_id, cart_total, item_count | PostHog/GA4 |
| `payment_initiated` | Payment button click | restaurant_id, total, payment_method | PostHog/GA4 |
| `payment_succeeded` | Stripe confirms | restaurant_id, order_id, total | PostHog/GA4 + DB |
| `payment_failed` | Stripe fails | restaurant_id, error_code | PostHog/GA4 + DB |
| `order_placed` | Order confirmed | restaurant_id, order_id, order_type | PostHog/GA4 + DB |

### Restaurant Operations Events

| Event Name | When to Fire | Required Props | Destination |
|---|---|---|---|
| `order_acknowledged` | Device ACKs order | restaurant_id, order_id, device_id, latency_seconds | DB |
| `order_status_changed` | Any status transition | restaurant_id, order_id, old_status, new_status | DB (exists) |
| `twilio_fallback_triggered` | No device ACK | restaurant_id, order_id | DB (exists) |
| `menu_cache_rebuilt` | Cache regenerated | restaurant_id, duration_ms | DB |
| `device_offline` | Device heartbeat missed | restaurant_id, device_id | DB + Alert |

---

## How to Verify Analytics in App Code

Run these searches in the Replit repo:

```bash
# Find analytics library
grep -r "analytics\|posthog\|mixpanel\|gtag\|segment" --include="*.ts" --include="*.tsx" --include="*.js"

# Find event tracking calls
grep -r "track\|capture\|logEvent\|sendEvent" --include="*.ts" --include="*.tsx"

# Check env vars for analytics
grep -r "POSTHOG\|GA_\|ANALYTICS\|MIXPANEL\|SEGMENT" .env* package.json
```
