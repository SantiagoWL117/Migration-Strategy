# 07 - Top 10 Highest-Leverage Recommendations (Menu.ca V3)

**Audit Date:** 2026-02-17  
**Source:** Live production database analysis + 6 restaurant data gap reviews  
**Ranked by:** Impact on reliability x effort x time-to-value

---

## 1. FIX ORDER COMPLETION FLOW (P0 -- Do This Today)

**Impact:** Critical | **Effort:** Medium | **Time-to-value:** Immediate | **Risk:** Low

**The Problem:** 88.7% of orders that reach "ready" status never reach "completed" or "delivered". 70 paid orders are currently stuck. Only 1 restaurant (Centertown Donair) successfully completes orders.

**What to Change:**
- Verify the tablet app has a working "Complete Order" button
- Check if the `update_order_status()` function is called when tablet marks order complete
- Check Supabase Realtime subscriptions -- orders may not be reaching tablets

**Where:**
- Tablet app code (Replit repo)
- `menuca_v3.update_order_status()` function
- `menuca_v3.tablet_update_order_status()` function
- Supabase Realtime subscription config

**Validation Metric:** Order completion rate > 80% within 48 hours of fix

**Interim Workaround:**
```sql
-- Auto-complete orders stuck at "ready" for more than 2 hours
UPDATE menuca_v3.orders
SET order_status = 'completed', completed_at = NOW()
WHERE order_status = 'ready'
AND payment_status = 'paid'
AND created_at < NOW() - INTERVAL '2 hours';
```

---

## 2. SWITCH PAYMENT MODE TO LIVE (P0 -- Do This Week)

**Impact:** Critical | **Effort:** Low | **Time-to-value:** Immediate | **Risk:** Medium

**The Problem:** 180 of 186 restaurants (97%) are on `payment_mode = 'test'`. No real revenue can flow through the platform at scale.

**What to Change:**
```sql
-- For each restaurant that passes go-live checklist:
UPDATE menuca_v3.delivery_and_pickup_configs
SET payment_mode = 'live'
WHERE restaurant_id = <id> AND deleted_at IS NULL;
```

**Where:** `menuca_v3.delivery_and_pickup_configs.payment_mode`

**Validation Metric:** Number of restaurants on `live` mode. Target: 20+ within 2 weeks.

**Pre-requisites per restaurant:**
- End-to-end test order completed successfully
- Stripe account connected and verified
- Restaurant owner notified and agreed
- Device tested and working

---

## 3. IMPLEMENT MENU CACHE AUTO-REFRESH (P1)

**Impact:** High | **Effort:** Low | **Time-to-value:** Hours | **Risk:** Low

**The Problem:** All 186 menu caches are stale (newest is 11 days old). Customers may see outdated menus, wrong prices, or missing items.

**What to Change:**
- Add a cron job / scheduled function to run `rebuild_all_menu_caches()` daily
- OR trigger `rebuild_menu_cache(restaurant_id)` on any menu change (trigger exists: `trigger_invalidate_menu_cache` but only marks stale, doesn't rebuild)

**Where:**
- `menuca_v3.rebuild_all_menu_caches()` function (exists)
- `menuca_v3.trigger_invalidate_menu_cache` (exists but may only invalidate)
- Supabase pg_cron or Edge Function scheduler

**Validation Metric:**
```sql
SELECT COUNT(*) FROM menuca_v3.restaurant_menu_cache WHERE updated_at > NOW() - INTERVAL '24 hours';
-- Target: 186 (all restaurants)
```

---

## 4. CLEAN UP 834 ORPHANED MODIFIER GROUPS (P1)

**Impact:** Medium | **Effort:** Low | **Time-to-value:** Immediate | **Risk:** Low

**The Problem:** 834 modifier groups are linked to 0 dishes. These are dead data from V1/V2 migration creating bloat and confusion.

**What to Change:**
```sql
-- Identify orphaned groups
SELECT mg.id, mg.name_en, mg.restaurant_id
FROM menuca_v3.modifier_groups mg
LEFT JOIN menuca_v3.dish_modifier_groups dmg ON dmg.modifier_group_id = mg.id
WHERE mg.deleted_at IS NULL AND dmg.id IS NULL;

-- Hard delete (modifiers prices first, then modifiers, then groups)
DELETE FROM menuca_v3.modifier_prices WHERE modifier_id IN (
    SELECT m.id FROM menuca_v3.modifiers m
    WHERE m.modifier_group_id IN (
        SELECT mg.id FROM menuca_v3.modifier_groups mg
        LEFT JOIN menuca_v3.dish_modifier_groups dmg ON dmg.modifier_group_id = mg.id
        WHERE mg.deleted_at IS NULL AND dmg.id IS NULL
    )
);
-- Then modifiers, then groups (same pattern)
```

**Validation Metric:** 0 orphaned modifier groups

---

## 5. CREATE FEATURE FLAGS TABLE (P1)

**Impact:** High | **Effort:** Low | **Time-to-value:** Days | **Risk:** Low

**The Problem:** Documented in system entity but never created. No ability to do gradual rollouts, kill-switches, or A/B testing.

**What to Change:** Create the tables as documented in `10-system-entity.md`:
- `feature_flags` (name, is_enabled, restaurant_ids[], percentage)
- `system_config` (key, value, description)

**Where:** `menuca_v3` schema

**Validation:** Tables exist and are queried by app before critical operations

---

## 6. FIX UTF-8 ENCODING ISSUES PLATFORM-WIDE (P2)

**Impact:** Medium | **Effort:** Medium | **Time-to-value:** Hours | **Risk:** Low

**The Problem:** Every reviewed restaurant had French text encoding issues. Characters like e with accent stored as multi-byte garbage. Likely affects all 186 restaurants.

**What to Change:**
```sql
-- Find all affected records
SELECT id, name_fr FROM menuca_v3.dishes WHERE name_fr LIKE '%Ã%' AND deleted_at IS NULL;
SELECT id, name_fr FROM menuca_v3.modifiers WHERE name_fr LIKE '%Ã%' AND deleted_at IS NULL;
SELECT id, name_fr FROM menuca_v3.courses WHERE name_fr LIKE '%Ã%' AND deleted_at IS NULL;

-- Fix with conversion function
UPDATE menuca_v3.modifiers
SET name_fr = convert_from(convert_to(name_fr, 'LATIN1'), 'UTF8')
WHERE name_fr LIKE '%Ã%' AND deleted_at IS NULL;
```

**Validation Metric:** 0 records matching `LIKE '%Ã%'` pattern

---

## 7. IMPLEMENT STUCK ORDER ALERTS (P1)

**Impact:** High | **Effort:** Medium | **Time-to-value:** Days | **Risk:** Low

**The Problem:** 70 orders are stuck right now with no alerting. Restaurant and customer experience suffers silently.

**What to Change:**
- Supabase Edge Function running every 5 minutes
- Query for orders where `payment_status = 'paid'` AND `order_status NOT IN ('completed','delivered','cancelled')` AND age > 15 minutes
- Send alert via Slack/email/SMS to operations team

**Where:** New Edge Function + Supabase pg_cron

**Validation Metric:** Time-to-detect for stuck orders < 15 minutes (currently: infinite)

---

## 8. VERIFY ALL RESTAURANTS AND SET GO-LIVE STATUS (P2)

**Impact:** Medium | **Effort:** Medium | **Time-to-value:** Weeks | **Risk:** Low

**The Problem:** Only 17 of 186 restaurants are `verified = true`. This means 91% haven't been validated.

**What to Change:**
- Run the onboarding checklist (from `04-Restaurant-Onboarding-Checklist_Menu.ca.md`) for each restaurant
- Set `verified = true` only after passing all checks
- Set `payment_mode = 'live'` only after verification

**Validation Metric:** Verified restaurants > 50 within 2 weeks

---

## 9. POPULATE CART SESSIONS FOR CONVERSION TRACKING (P2)

**Impact:** Medium | **Effort:** Medium | **Time-to-value:** Weeks | **Risk:** Low

**The Problem:** `cart_sessions` table has 0 entries. Cannot measure conversion funnel (how many people add items vs checkout vs pay).

**What to Change:**
- In frontend code: create cart session when first item is added
- Update cart_data on changes
- Link to order when checkout completes
- This gives conversion rate: cart_sessions / orders

**Where:** Frontend app code (Replit)

**Validation Metric:** cart_sessions > 0 and ratio to orders is measurable

---

## 10. SET UP DAILY HEALTH DASHBOARD (P1)

**Impact:** High | **Effort:** Low | **Time-to-value:** Hours | **Risk:** None

**The Problem:** No operational visibility. Issues are discovered by restaurants or customers, not by the team.

**What to Change:**
- Use the queries from `03-Dashboard-and-Alert-Spec_Menu.ca.md`
- Set up in Supabase Dashboard, Metabase, or even a daily SQL report
- Minimum: run the Restaurant Health Card query daily and review

**Where:** Supabase pg_cron + Edge Function to email results, OR external dashboard tool

**Validation Metric:** Team reviews dashboard daily. TTD < 1 hour for P1 issues.

---

## Summary Priority Matrix

| # | Fix | Impact | Effort | Do When |
|---|---|---|---|---|
| 1 | Fix order completion flow | CRITICAL | Medium | TODAY |
| 2 | Switch payment mode to live | CRITICAL | Low | THIS WEEK |
| 3 | Auto-refresh menu cache | HIGH | Low | THIS WEEK |
| 4 | Clean orphaned modifier groups | MEDIUM | Low | THIS WEEK |
| 5 | Create feature flags table | HIGH | Low | THIS WEEK |
| 6 | Fix UTF-8 encoding platform-wide | MEDIUM | Medium | NEXT WEEK |
| 7 | Implement stuck order alerts | HIGH | Medium | NEXT WEEK |
| 8 | Verify restaurants + go-live | MEDIUM | Medium | 2 WEEKS |
| 9 | Populate cart sessions | MEDIUM | Medium | 2 WEEKS |
| 10 | Daily health dashboard | HIGH | Low | THIS WEEK |
