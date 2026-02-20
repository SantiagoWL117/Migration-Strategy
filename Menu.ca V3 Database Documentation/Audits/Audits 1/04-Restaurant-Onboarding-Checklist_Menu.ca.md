# 04 - Restaurant Onboarding Checklist (Menu.ca V3)

**Audit Date:** 2026-02-17  
**Source:** Database analysis + patterns from 6 restaurant data gap reviews  
**Restaurants reviewed:** Pho Bo Ga King (199), Charm Thai (943), Crispy's Bank St (806), Riverside Pizzeria (133), New Mee Fung (15), Season's Pizza (83)

---

## Section G1: Standardized Onboarding Checklist

### Phase 1: Required Data Setup

| # | Step | Validation Query | Common Pitfalls Found |
|---|---|---|---|
| 1 | **Restaurant profile** | `SELECT name, slug, status, timezone FROM restaurants WHERE id = ?` | Missing timezone (defaults wrong) |
| 2 | **Location** | `SELECT * FROM restaurant_locations WHERE restaurant_id = ?` | 0 restaurants missing (all 186 have locations) |
| 3 | **Schedule** | `SELECT * FROM restaurant_schedules WHERE restaurant_id = ? AND deleted_at IS NULL` | 0 restaurants missing (all have schedules) |
| 4 | **Payment options** | `SELECT payment_method, is_enabled FROM restaurant_payment_options WHERE restaurant_id = ?` | "Accepts Cash" tag present but cash payment disabled (found in Riverside Pizzeria, New Mee Fung) |
| 5 | **Payment mode** | `SELECT payment_mode FROM delivery_and_pickup_configs WHERE restaurant_id = ?` | **180/186 restaurants on TEST mode** — this must be switched to LIVE before real orders |
| 6 | **Delivery area polygon** | `SELECT area_name, ST_Area(geometry::geography) FROM restaurant_delivery_areas WHERE restaurant_id = ?` | Polygon too small (New Mee Fung: 0.019 sq km), fee tiers not matching polygon reach |
| 7 | **Delivery fee tiers** | `SELECT * FROM restaurant_distance_based_delivery_fees WHERE restaurant_id = ?` | Gap between 0 km and first tier (found in Pho Bo Ga King, Charm Thai) |
| 8 | **Menu (courses)** | `SELECT COUNT(*) FROM courses WHERE restaurant_id = ? AND deleted_at IS NULL AND is_active = true` | Inactive courses with 0 active dishes (found in Riverside, New Mee Fung) |
| 9 | **Menu (dishes)** | `SELECT COUNT(*) FROM dishes WHERE restaurant_id = ? AND deleted_at IS NULL AND is_active = true` | Unnamed dishes ("31."), inactive dishes bloat |
| 10 | **Menu (modifiers)** | Check for orphaned modifier groups | **834 orphaned groups across platform** |
| 11 | **Menu cache** | `SELECT updated_at FROM restaurant_menu_cache WHERE restaurant_id = ?` | All 186 caches stale (>11 days old) |
| 12 | **Commission config** | `SELECT * FROM restaurant_commission_configs WHERE restaurant_id = ?` | 6 restaurants with commission disabled |
| 13 | **Twilio config** | `SELECT * FROM restaurant_twilio_config WHERE restaurant_id = ?` | Only 15/186 restaurants configured |
| 14 | **Device registered** | `SELECT * FROM devices WHERE restaurant_id = ?` | 1,034 devices registered |
| 15 | **Verified flag** | `SELECT verified FROM restaurants WHERE id = ?` | Only 17/186 verified |

### Phase 2: Bilingual Compliance

| # | Check | Query | Common Pitfalls |
|---|---|---|---|
| 1 | `is_bilingual` flag | `SELECT is_bilingual FROM delivery_and_pickup_configs WHERE restaurant_id = ?` | Often set to `false` even when translations exist |
| 2 | Dish names translated | `SELECT COUNT(*) FROM dishes WHERE restaurant_id=? AND is_active=true AND (name_fr IS NULL OR name_en = name_fr)` | Many dishes have name_en copied to name_fr without translation |
| 3 | Dish descriptions translated | `SELECT COUNT(*) FROM dishes WHERE restaurant_id=? AND is_active=true AND description_en IS NOT NULL AND description_fr IS NULL` | 149 missing descriptions found in New Mee Fung |
| 4 | Course names translated | Same pattern | Usually better translated than dishes |
| 5 | Modifier names (encoding) | Check for `Ã©`, `Ã¨`, `Ã` patterns | **UTF-8 encoding issues found in EVERY restaurant reviewed** |

### Phase 3: Data Integrity Checks

| # | Check | What to Look For |
|---|---|---|
| 1 | **Orphaned modifier groups** | Groups linked to 0 dishes via `dish_modifier_groups` |
| 2 | **Inactive modifier bloat** | Groups with large numbers of `is_active = false` modifiers |
| 3 | **Duplicate modifier groups** | Multiple groups with identical modifier lists assigned to same dishes |
| 4 | **Fee tier gaps** | Polygon covers 0-4 km but first fee tier starts at 5 km |
| 5 | **Tag consistency** | "Accepts Cash" tag but cash payment disabled |
| 6 | **Delivery time realism** | 60+ min delivery time in urban area (should be 30-45) |
| 7 | **Empty courses** | Courses with 0 active dishes (dead categories) |

### Phase 4: End-to-End Test Order

| # | Step | What to Verify |
|---|---|---|
| 1 | Browse menu | All courses and dishes load, images display |
| 2 | Add item with modifiers | Modifier groups display correctly, pricing works |
| 3 | Proceed to checkout | Delivery fee calculated, tax calculated |
| 4 | Place order (test) | Order creates in DB, payment_status updates |
| 5 | Device receives order | Order appears on tablet, audio alert plays |
| 6 | Accept order on device | `confirmed_at` populates, status changes |
| 7 | Mark ready | Status transitions to `ready` |
| 8 | Complete order | Status reaches `completed` or `delivered` |
| 9 | Verify commission | Commission calculated correctly |
| 10 | Test refund flow | Refund processes through Stripe |

### Phase 5: Go-Live Criteria

| # | Criterion | Required? |
|---|---|---|
| 1 | All Phase 1 data populated | YES |
| 2 | `payment_mode = 'live'` | YES |
| 3 | `verified = true` | YES |
| 4 | Twilio fallback configured | YES (for unattended orders) |
| 5 | Device registered and tested | YES |
| 6 | Test order completed end-to-end | YES |
| 7 | Menu cache < 24 hours old | YES |
| 8 | No orphaned modifier groups | YES |
| 9 | No UTF-8 encoding issues | YES |
| 10 | Delivery fee tiers cover polygon | YES (if delivery enabled) |

### Phase 6: First Week Monitoring

| Day | What to Check |
|---|---|
| Day 1 | First real order arrives and completes. Device acknowledgment works. |
| Day 2 | No stuck orders. Twilio fallback not triggered. |
| Day 3 | Check AOV is reasonable. No refunds. |
| Day 5 | Check completion rate > 80%. Review any customer complaints. |
| Day 7 | Full health card review. Compare to test period metrics. |

### Known Pitfalls (From Our Reviews)

1. **Payment mode stuck on `test`** — The #1 issue. 97% of restaurants are on test mode.
2. **UTF-8 encoding in French text** — Every restaurant had this. Likely a legacy migration artifact.
3. **Orphaned modifier groups** — Every restaurant had these. Leftover from V1/V2 migration.
4. **Delivery fee tier gaps** — Polygon exists but fee tiers don't cover the first few km.
5. **Inactive modifier bloat** — Hundreds of inactive modifiers that should be hard deleted.
6. **"Accepts Cash" tag without cash enabled** — Tags and payment settings out of sync.
7. **Unrealistic delivery times** — 50-60 min in urban areas, should be 30-40.
8. **Missing French translations** — Especially dish descriptions.
9. **Menu cache not refreshing** — Must manually call `rebuild_menu_cache()`.
10. **No order completion path** — Orders reach `ready` but never `completed`.

---

## Section G2: Support Intake -> Engineering Loop

### Current State: INFORMAL

> No formal support intake or ticketing system was observed in the database or workspace.

### Proposed Triage Template

```markdown
**Issue Report**
- Restaurant: [name] (ID: [id])
- Reported by: [customer/restaurant/internal]
- Reported at: [timestamp]
- Environment: [production/test]
- Symptoms: [what happened]
- Expected: [what should have happened]
- Order #: [if applicable]
- Screenshots: [if applicable]

**Triage:**
- [ ] Can reproduce
- [ ] Affects other restaurants
- [ ] Revenue impact ($ amount)
- [ ] Customer waiting for resolution
```

### Proposed SLA Targets

| Severity | Response Time | Resolution Time |
|---|---|---|
| P1 (customer has paid, order stuck) | 5 minutes | 30 minutes |
| P2 (feature broken, workaround exists) | 1 hour | 24 hours |
| P3 (cosmetic, data quality) | 24 hours | 1 week |

### When to Open an Incident
- Any P1 issue
- Same P2 issue reported by 2+ restaurants
- Payment failures > 10% for any hour
- 0 orders for a restaurant that normally has orders

### When to Create Backlog Items
- P3 issues
- Data quality issues found during reviews
- Feature requests from restaurants
- Performance improvements
