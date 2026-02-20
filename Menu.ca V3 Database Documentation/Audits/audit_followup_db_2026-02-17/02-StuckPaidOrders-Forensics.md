# 02 - Stuck Paid Orders Forensics

**Date:** 2026-02-17  
**Schema:** menuca_v3

---

## 2.1 Definition of "Stuck Paid"

```
stuck_paid = WHERE payment_status = 'paid'
             AND order_status NOT IN ('completed', 'delivered', 'cancelled')
             AND created_at < NOW() - INTERVAL '2 hours'
```

This captures orders where money has been collected but the order has not reached any terminal state within 2 hours.

**Total stuck paid orders:** 90

---

## 2.2 Breakdown Tables

### By Current Order Status

| Order Status | Count | % of Stuck |
|---|---|---|
| ready | 46 | 51.1% |
| pending | 31 | 34.4% |
| confirmed | 12 | 13.3% |
| preparing | 1 | 1.1% |

**Key insight:** 51% are at `ready` -- meaning the restaurant prepared the food but the order was never marked complete. 34% are at `pending` -- the restaurant may never have seen the order.

### By Age Bucket

| Age Bucket | Count | % of Stuck |
|---|---|---|
| 2-6h | 0 | 0% |
| 6-24h | 3 | 3.3% |
| >24h | 87 | 96.7% |

**Key insight:** 97% of stuck orders are more than 24 hours old. There are essentially no "fresh" stuck orders, suggesting this is a systemic completion-flow issue rather than a transient outage.

### By Restaurant ID

| Restaurant ID | Stuck Orders | % of Stuck |
|---|---|---|
| 1021 | 61 | 67.8% |
| 829 | 10 | 11.1% |
| 199 | 4 | 4.4% |
| 131 | 4 | 4.4% |
| 83 | 4 | 4.4% |
| 815 | 3 | 3.3% |
| 1015 | 3 | 3.3% |
| 1009 | 1 | 1.1% |

**Key insight:** Restaurant 1021 accounts for 68% of all stuck orders. This is either a very active test restaurant or has a specific device/integration problem.

### By Test Order Flag

| is_test_order | Stuck Count |
|---|---|
| false | 40 |
| true | 50 |

55.6% of stuck orders are test orders. But 44.4% (40) are real orders -- real money is stuck.

### By Restaurant Payment Mode

| Payment Mode | Stuck Count |
|---|---|
| live | 86 |
| test | 4 |

95.6% of stuck orders are from live-mode restaurants. This is because the most active restaurants (1021, 829, etc.) are on live mode.

---

## 2.3 Failure-Stage Classification

| Failure Stage | Count | % | Interpretation |
|---|---|---|---|
| **paid_no_ack** (acknowledged_at IS NULL) | 11 | 12.2% | Payment confirmed but tablet/device never received or acknowledged the order |
| **acked_not_completed** (acknowledged_at set, completed_at NULL) | 70 | 77.8% | Device acknowledged, restaurant processed, but completion never recorded |
| **completed_at_set_but_status_wrong** (completed_at NOT NULL but status not terminal) | 9 | 10.0% | completed_at timestamp exists but order_status was never updated to 'completed'/'delivered' |

### Interpretation

The **dominant failure mode (78%) is "acknowledged but never completed."** This means:
1. The order reaches the restaurant tablet
2. The restaurant processes it (moves through confirmed -> preparing -> ready)
3. But the final step ("mark as completed" or "mark as delivered") never fires

The 10% with completed_at set but wrong status suggests a **race condition or bug** where the timestamp is written but the status column is not updated in the same transaction.

The 12% with no ACK suggests either:
- Device was offline
- Supabase Realtime subscription was broken
- Twilio fallback was triggered but did not result in ACK

---

## 2.4 Hypotheses (DB-Evidence Only)

### Hypothesis 1: No "Complete Order" Action in Tablet UX

**Evidence:** 70 of 90 stuck orders (78%) are acknowledged by a device but never completed. The order reaches `ready` status but there is no transition to `completed`. Only 1 restaurant (out of 8 with stuck orders) has ever completed orders -- suggesting the completion mechanism either doesn't exist in the tablet app or is broken for most restaurants.

**Supporting data:** Out of 137 total orders, only 15 have ever reached `completed` or `delivered` status, all from the same restaurant cohort (restaurant 131 based on prior analysis).

### Hypothesis 2: Restaurant 1021 Is a Test Harness (Not a Real Restaurant)

**Evidence:** Restaurant 1021 has 61 stuck orders (68% of all stuck), with a mix of test and non-test orders. The daily creation pattern shows spikes on Feb 12 (16), Feb 13 (17), Feb 14 (24) -- which looks like automated or systematic testing, not organic customer behavior.

**Supporting data:** Payment mode is `live`, which means Stripe charges are real. If this is a test harness, real money is being processed unnecessarily.

### Hypothesis 3: Feb 12-14 Spike Correlates with a Code Deploy or Testing Session

**Evidence:** 57 of 90 stuck orders (63%) were created in the 3-day window Feb 12-14.

| Date | Stuck Orders Created |
|---|---|
| Feb 12 | 16 |
| Feb 13 | 17 |
| Feb 14 | 24 |

This concentrated spike suggests either intensive testing or a code change that broke the completion flow.

### Hypothesis 4: Twilio Fallback Is Working But Insufficient

**Evidence:** Among stuck orders, 9 triggered twilio_fallback_call, 5 reached twilio_fallback_confirmed, and 4 reached twilio_fallback_max_reached. This means Twilio correctly detects unacknowledged orders, but even when the restaurant confirms via phone, the order doesn't move to completion.

**Supporting data:** twilio_fallback_confirmed (5 cases) means the restaurant answered the phone and presumably accepted the order, but these orders are STILL stuck. This proves the Twilio path does not have a mechanism to complete orders.

### Hypothesis 5: The completed_at / order_status Update Is Split Across Two Operations and One Fails

**Evidence:** 9 orders have `completed_at` set but `order_status` not in a terminal state. This strongly suggests the completion flow updates the timestamp and the status in separate operations (or separate queries), and the status update sometimes fails silently.

**Supporting data:** This is a data integrity bug. In a correct implementation, `completed_at` and `order_status = 'completed'` should be set atomically.

---

## Queries

All SQL queries used are in `06-Appendix-All-SQL.md`.
