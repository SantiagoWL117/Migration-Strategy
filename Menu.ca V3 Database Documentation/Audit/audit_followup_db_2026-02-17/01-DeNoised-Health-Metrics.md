# 01 - De-Noised Health Metrics

**Date:** 2026-02-17  
**Schema:** menuca_v3 on Supabase PostgreSQL

---

## Test Noise Proxies

Two proxies exist in the database for isolating test vs production data:

| Proxy | Column | Location | Notes |
|---|---|---|---|
| **Proxy 1: is_test_order** | `orders.is_test_order` | Per-order boolean | 57 of 137 total orders are flagged `true`. Best per-order signal. |
| **Proxy 2: payment_mode** | `delivery_and_pickup_configs.payment_mode` | Per-restaurant setting | 180 restaurants on `test`, 6 on `live`. Best restaurant-level signal. |

**Why testing distorts metrics:** 41.6% of all orders are flagged as test orders. Additionally, 97% of restaurants are on test payment mode, meaning even "non-test" orders from those restaurants are flowing through a test payment pipeline. The cleanest production-like baseline is **CUT C** (live-mode restaurants AND non-test orders).

---

## CUT A: Exclude test orders only (is_test_order = false)

| Metric | Last 30 days | Last 7 days |
|---|---|---|
| Restaurants with ordering enabled | 186 | 186 |
| Paid orders | 55 | 21 |
| Completed orders (completed + delivered) | 15 | 1 |
| **Completion rate** | **27.3%** | **4.8%** |
| Stuck paid orders (>2h, non-terminal) | 40 | 20 |
| Median time-to-complete | 8,849 min (~6.1 days) | n/a (1 sample) |
| P95 time-to-complete | 10,151 min (~7.0 days) | n/a |
| Time-to-complete sample size | 5 | n/a |
| Refunds | 25 | -- |
| Total refunded | $641.39 | -- |

---

## CUT B: Live-mode restaurants only (payment_mode = 'live')

6 restaurants are on live mode (IDs: 83, 131, 199, 815, 829, 1021).

| Metric | Last 30 days | Last 7 days |
|---|---|---|
| Live restaurants with ordering | 6 | 6 |
| Paid orders | 101 | 71 |
| Completed orders | 15 | 1 |
| **Completion rate** | **14.9%** | **1.4%** |
| Stuck paid orders (>2h) | 86 | -- |
| Median time-to-complete | 8,849 min (~6.1 days) | n/a |
| P95 time-to-complete | 10,151 min (~7.0 days) | n/a |
| Refunds | 25 | -- |
| Total refunded | $641.39 | -- |

**Note:** CUT B includes test orders placed against live-mode restaurants, which is why paid orders (101) > CUT A paid orders (55). This means ~50 test orders were placed against live-mode restaurants.

---

## CUT C: Live-mode + non-test orders (intersection of A and B)

This is the **cleanest production-like baseline**.

| Metric | Last 30 days | Last 7 days |
|---|---|---|
| Live restaurants with ordering | 6 | 6 |
| Paid orders | 51 | 21 |
| Completed orders | 15 | 1 |
| **Completion rate** | **29.4%** | **4.8%** |
| Stuck paid orders (>2h) | 36 | -- |
| Median time-to-complete | 8,849 min (~6.1 days) | n/a |
| P95 time-to-complete | 10,151 min (~7.0 days) | n/a |
| Refunds | 25 | -- |
| Total refunded | $641.39 | -- |

---

## Summary Comparison

| Metric | CUT A (no test) | CUT B (live) | CUT C (both) | Raw (all) |
|---|---|---|---|---|
| Paid orders (30d) | 55 | 101 | 51 | 105 |
| Completed (30d) | 15 | 15 | 15 | 15 |
| Completion rate (30d) | 27.3% | 14.9% | 29.4% | 14.3% |
| Stuck (30d, >2h) | 40 | 86 | 36 | 90 |
| Refunds | 25 / $641 | 25 / $641 | 25 / $641 | 28 / $761 |

**Key observations:**

1. All 15 completed orders come from the same set of live-mode, non-test orders. No test orders have been "completed."
2. Completion rate improves from 14.3% (raw) to 29.4% (CUT C) but is still critically low.
3. Time-to-complete is ~6 days median, meaning "completed" status is being set days after order creation -- not during the actual service window. This likely represents bulk status updates or backfills, not real-time operations.
4. The 7-day window shows only 1 completion out of 21 paid orders (4.8%), indicating the problem is getting worse, not better.
5. All 25 refunds are from the same live/non-test cohort -- a 49% refund rate against completed orders (25 refunds vs 51 paid orders).

---

## Queries

All SQL queries used are in `06-Appendix-All-SQL.md`.
