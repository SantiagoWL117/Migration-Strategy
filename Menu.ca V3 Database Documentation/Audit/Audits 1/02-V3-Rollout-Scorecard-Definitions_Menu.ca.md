# 02 - V3 Rollout Scorecard Definitions (Menu.ca V3)

**Audit Date:** 2026-02-17  
**Source:** Live production database  
**Period:** Jan 1 - Feb 17, 2026

---

## Section F1: Platform-Level Scorecard

### Current Baseline (Measured)

| Metric | Value | Status | Target (2 weeks) |
|---|---|---|---|
| **Restaurants in DB** | 186 | — | — |
| **Restaurants active** | 186 (100%) | GREEN | — |
| **Restaurants verified** | 17 (9.1%) | RED | 50+ |
| **Restaurants on LIVE payments** | 6 (3.2%) | RED | 20+ |
| **Restaurants with orders** | 9 | RED | 15+ |
| **Total orders** | 137 | — | 300+ |
| **Test orders** | 57 (41.6%) | YELLOW | < 10% |
| **Total GMV** | $5,028.81 | LOW | $15,000+ |
| **Avg order value (AOV)** | $36.71 | OK | $35-45 |
| **Order completion rate** | 14.3% (15/105 paid) | RED | > 80% |
| **Refund rate** | 20.5% (28/137) | RED | < 5% |
| **Payment failure rate** | 4.2% (Stripe webhooks) | YELLOW | < 2% |
| **Stuck orders (current)** | 70 | RED | 0 |
| **Twilio fallback triggered** | 25 events | CONCERN | < 5/week |
| **Twilio max retries reached** | 5 events | RED | 0 |
| **Cart sessions (conversion tracking)** | 0 (not operational) | RED | Operational |
| **Menu cache freshness** | All stale (>11 days) | RED | < 24h |
| **Onboarding records** | 175 | — | — |
| **Devices registered** | 1,034 | — | — |
| **Twilio configs** | 15 restaurants | — | All active restaurants |

### Key Metric Definitions

#### 1. Adoption
```sql
-- Restaurants live on V3 (has at least 1 real order)
SELECT COUNT(DISTINCT restaurant_id) AS restaurants_with_real_orders
FROM menuca_v3.orders WHERE is_test_order = false;
```

#### 2. Reliability: Order Completion Rate
```sql
-- Rolling 7-day completion rate
SELECT
    COUNT(*) FILTER (WHERE order_status IN ('completed','delivered')) AS completed,
    COUNT(*) FILTER (WHERE payment_status = 'paid') AS total_paid,
    ROUND(
        COUNT(*) FILTER (WHERE order_status IN ('completed','delivered'))::numeric /
        NULLIF(COUNT(*) FILTER (WHERE payment_status = 'paid'), 0) * 100, 1
    ) AS completion_rate_pct
FROM menuca_v3.orders
WHERE created_at >= NOW() - INTERVAL '7 days';
```

#### 3. Revenue: GMV
```sql
-- Monthly GMV (excluding test orders)
SELECT
    date_trunc('month', created_at) AS month,
    SUM(total_amount) AS gmv,
    COUNT(*) AS orders,
    ROUND(AVG(total_amount), 2) AS aov
FROM menuca_v3.orders
WHERE is_test_order = false
GROUP BY 1 ORDER BY 1;
```

#### 4. Conversion: Checkout Completion Rate
```
CANNOT MEASURE — cart_sessions table has 0 entries.
No frontend analytics available from this environment.

To measure:
- Implement cart session tracking (table exists, just not populated)
- OR add analytics event tracking in frontend (PostHog/GA4)
- Numerator: orders created / Denominator: checkout page loads
```

#### 5. Support Load: Incident Rate
```
CANNOT MEASURE — No incident/support ticket tracking in database.

To measure:
- Create incidents table or use external tool (Linear, Jira)
- Track: restaurant_id, issue_type, reported_at, resolved_at
```

#### 6. Time-to-Detect (TTD) / Time-to-Recover (TTR)
```
CANNOT MEASURE — No incident response timestamps in database.

To measure:
- Add to incident tracking workflow
- TTD = time from failure to human awareness
- TTR = time from awareness to resolution
```

---

## Section F2: Restaurant-Level Scorecard (Top Restaurants)

### Current Restaurant Performance

| Restaurant | Orders | GMV | AOV | Completed | Completion % | On Live? |
|---|---|---|---|---|---|---|
| JJ's Shawarma | 64 | $2,869.74 | $44.84 | 0 | 0% | Test |
| Season's Pizza | 21 | $551.43 | $26.26 | 0 | 0% | Test |
| Centertown Donair & Pizza | 19 | $566.58 | $29.82 | 15 | 78.9% | Live? |
| Pizzalicious | 12 | $434.40 | $36.20 | 0 | 0% | Test |
| New Mee Fung Restaurant | 7 | $240.13 | $34.30 | 0 | 0% | Test |
| Pho Bo Ga King - Somerset | 7 | $114.80 | $16.40 | 0 | 0% | Test |
| Golden Center Pizza | 3 | $53.96 | $17.99 | 0 | 0% | Test |
| Poutinerie Quebecurds | 3 | $163.28 | $54.43 | 0 | 0% | Test |
| Econo Pizza | 1 | $34.49 | $34.49 | 0 | 0% | Test |

**Only Centertown Donair & Pizza is operating successfully.** All others have 0% completion rate.

---

## Section F2: Canary Strategy

### Current Canaries (De Facto)

Based on order volume, these restaurants are the implicit V3 canaries:

| Tier | Restaurant | Orders | Status | Notes |
|---|---|---|---|---|
| **Canary 1** | Centertown Donair & Pizza | 19 | WORKING | Only restaurant completing orders |
| **Canary 2** | JJ's Shawarma | 64 | BROKEN | High volume but 0% completion |
| **Canary 3** | Season's Pizza | 21 | BROKEN | 0% completion |
| **Canary 4** | Pizzalicious | 12 | BROKEN | 0% completion |

### 48-Hour Monitoring Checklist (Before Expanding)

Before adding more restaurants to V3:

- [ ] Order completion rate > 80% for current canaries
- [ ] 0 stuck paid orders older than 30 minutes
- [ ] Payment mode switched to `live`
- [ ] Twilio fallback incidents < 2 per restaurant per day
- [ ] Menu cache refreshing automatically (< 24h old)
- [ ] Device acknowledgment latency < 5 minutes
- [ ] Customer can complete full order flow without errors

### Rollback Criteria (Clear Thresholds)

| Metric | Rollback If... |
|---|---|
| Order completion rate | Drops below 50% for any restaurant |
| Payment failures | > 15% failure rate in any 1-hour window |
| Stuck orders | > 5 stuck orders across platform in 1 hour |
| Revenue impact | GMV drops > 30% vs previous comparable period |
| Customer complaints | > 3 complaints about same issue in 24h |

### Rollback Action

1. Disable `online_ordering_enabled` for affected restaurant(s)
2. Switch `payment_mode` back to `test`
3. Notify restaurant owner
4. Investigate root cause
5. Fix and re-test before re-enabling

---

## Monthly Trend

| Month | Orders | GMV | Test Orders | Completed | Completion % |
|---|---|---|---|---|---|
| Jan 2026 | 19 | $515.99 | 0 | 14 | 73.7% |
| Feb 2026 (partial) | 118 | $4,512.82 | 57 | 1 | 1.6% |

**February shows a dramatic decline in completion rate** (73.7% -> 1.6%) despite a 6x increase in order volume. This correlates with new restaurants onboarding that don't have working order completion flows.
