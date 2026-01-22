# Distance-Based Delivery Fee Restaurants - Handoff Document

> **Last Updated:** 2026-01-22  
> **Total Restaurants:** 8 with `distance_based_delivery_fee = true`

---

## Overview

These 8 restaurants use **distance-based delivery fees** instead of flat delivery fees. The delivery fee varies based on the distance (in km) from the restaurant to the customer's address.

### Quick Reference

| V3 ID | Restaurant | Legacy V1 ID | Delivery Enabled | Pickup | Fee Range | Distance Range |
|-------|------------|--------------|------------------|--------|-----------|----------------|
| 131 | Centertown Donair & Pizza | 255 | ✅ Yes | ✅ | $7-$10 | 5-8 km |
| 87 | Champa Thai Cuisine | 203 | ✅ Yes | ✅ | $7-$12 | 5-10 km |
| 943 | Charm Thai Cuisine | 323 | ❌ No | ✅ | $6-$9 | 5-8 km |
| 1010 | Lemongrass Thai Cuisine | 219 | ❌ No | ✅ | $6-$11 | 5-10 km |
| 15 | New Mee Fung Restaurant | 101 | ❌ No | ✅ | $4-$6.25 | 5-8 km |
| 807 | Oh My Grill | 1051 | ✅ Yes | ✅ | $7-$12 | 5-10 km |
| 199 | Pho Bo Ga King - Somerset | 337 | ❌ No | ✅ | $6-$9 | 5-8 km |
| 847 | Sushiyana | 1094 | ✅ Yes | ✅ | $7-$12 | 5-10 km |

**Note:** 4 restaurants have `has_delivery_enabled = false` but have distance-based fee data. This may indicate they're pickup-only or the flag needs review.

---

## Restaurant Details

### 1. Centertown Donair & Pizza (V3 ID: 131)

| Field | Value |
|-------|-------|
| **Address** | 422 Bronson Ave, K1R 6J6 |
| **Legacy V1 ID** | 255 |
| **Delivery Enabled** | ✅ Yes |
| **Pickup Enabled** | ✅ Yes |
| **Twilio Call** | ✅ Yes |

**Delivery Companies:**
| Email | Company | Commission | Restaurant Pays |
|-------|---------|------------|-----------------|
| Deliveryzonecanada@gmail.com | Deliveryzonecanada | 15% | $0.00 |
| mattmenuottawa2@gmail.com | Mattmenuottawa2 | 15% | $0.00 |
| restozonedispatch@gmail.com | Restozonedispatch | 15% | $0.00 |

**Fee Tiers:**
| Distance | Customer Fee | Driver Earning | Restaurant Pays | Vendor Pays |
|----------|--------------|----------------|-----------------|-------------|
| 5 km | $7.00 | $7.00 | $7.00 | $0.00 |
| 6 km | $8.00 | $8.00 | $8.00 | $0.00 |
| 7 km | $9.00 | $9.00 | $9.00 | $0.00 |
| 8 km | $10.00 | $10.00 | $10.00 | $0.00 |

---

### 2. Champa Thai Cuisine (V3 ID: 87) ⭐ MVP

| Field | Value |
|-------|-------|
| **Address** | 193 King Edward Ave, K1N 7L6 |
| **Legacy V1 ID** | 203 |
| **Delivery Enabled** | ✅ Yes |
| **Pickup Enabled** | ✅ Yes |
| **Twilio Call** | ✅ Yes |

**Delivery Companies:**
| Email | Company | Commission | Restaurant Pays |
|-------|---------|------------|-----------------|
| Deliveryzonecanada@gmail.com | Deliveryzonecanada | 15% | $0.00 |
| mattmenuottawa2@gmail.com | Mattmenuottawa2 | 15% | $0.00 |
| restozonedispatch@gmail.com | Restozonedispatch | 15% | $0.00 |

**Fee Tiers:**
| Distance | Customer Fee | Driver Earning | Restaurant Pays | Vendor Pays |
|----------|--------------|----------------|-----------------|-------------|
| 5 km | $7.00 | $7.00 | $7.00 | $0.00 |
| 6 km | $8.00 | $8.00 | $8.00 | $0.00 |
| 7 km | $9.00 | $9.00 | $9.00 | $0.00 |
| 8 km | $10.00 | $10.00 | $10.00 | $0.00 |
| 9 km | $11.00 | $11.00 | $11.00 | $0.00 |
| 10 km | $12.00 | $12.00 | $12.00 | $0.00 |

---

### 3. Charm Thai Cuisine (V3 ID: 943)

| Field | Value |
|-------|-------|
| **Address** | 121 Preston Street, K1R 7P3 |
| **Legacy V1 ID** | 323 |
| **Delivery Enabled** | ❌ No |
| **Pickup Enabled** | ✅ Yes |
| **Twilio Call** | ✅ Yes |

**Delivery Companies:** ⚠️ None linked

**Fee Tiers:**
| Distance | Customer Fee | Driver Earning | Restaurant Pays | Vendor Pays |
|----------|--------------|----------------|-----------------|-------------|
| 5 km | $6.00 | $6.00 | $6.00 | $0.00 |
| 6 km | $7.00 | $7.00 | $7.00 | $0.00 |
| 7 km | $8.00 | $8.00 | $8.00 | $0.00 |
| 8 km | $9.00 | $9.00 | $9.00 | $0.00 |

---

### 4. Lemongrass Thai Cuisine (V3 ID: 1010)

| Field | Value |
|-------|-------|
| **Address** | 331 Elgin St |
| **Legacy V1 ID** | 219 |
| **Delivery Enabled** | ❌ No |
| **Pickup Enabled** | ✅ Yes |
| **Twilio Call** | ✅ Yes |

**Delivery Companies:**
| Email | Company | Commission | Restaurant Pays |
|-------|---------|------------|-----------------|
| Deliveryzonecanada@gmail.com | Deliveryzonecanada | 15% | $0.00 |
| mattmenuottawa2@gmail.com | Mattmenuottawa2 | 15% | $0.00 |
| restozonedispatch@gmail.com | Restozonedispatch | 15% | $0.00 |

**Fee Tiers:** ⚠️ Note irregular `restaurant_pays` at 7km
| Distance | Customer Fee | Driver Earning | Restaurant Pays | Vendor Pays |
|----------|--------------|----------------|-----------------|-------------|
| 5 km | $6.00 | $6.00 | $6.00 | $0.00 |
| 6 km | $7.00 | $7.00 | $7.00 | $0.00 |
| 7 km | $8.00 | $8.00 | **$9.00** | $0.00 |
| 8 km | $9.00 | $9.00 | $9.00 | $0.00 |
| 9 km | $10.00 | $10.00 | $10.00 | **$10.00** |
| 10 km | $11.00 | $11.00 | $11.00 | **$11.00** |

---

### 5. New Mee Fung Restaurant (V3 ID: 15)

| Field | Value |
|-------|-------|
| **Address** | 350 Booth St, K1R 7K1 |
| **Legacy V1 ID** | 101 |
| **Delivery Enabled** | ❌ No |
| **Pickup Enabled** | ✅ Yes |
| **Twilio Call** | ✅ Yes |

**Delivery Companies:** ⚠️ None linked

**Fee Tiers:** (Lowest fees of all)
| Distance | Customer Fee | Driver Earning | Restaurant Pays | Vendor Pays |
|----------|--------------|----------------|-----------------|-------------|
| 5 km | $4.00 | $4.00 | $4.00 | $0.00 |
| 6 km | $4.75 | $4.75 | $4.75 | $0.00 |
| 7 km | $5.50 | $5.50 | $5.50 | $0.00 |
| 8 km | $6.25 | $6.25 | $6.25 | $0.00 |

---

### 6. Oh My Grill (V3 ID: 807)

| Field | Value |
|-------|-------|
| **Address** | 169 York St, K1N 5T4 |
| **Legacy V1 ID** | 1051 |
| **Delivery Enabled** | ✅ Yes |
| **Pickup Enabled** | ✅ Yes |
| **Twilio Call** | ✅ Yes |

**Delivery Companies:**
| Email | Company | Commission | Restaurant Pays |
|-------|---------|------------|-----------------|
| Deliveryzonecanada@gmail.com | Deliveryzonecanada | 15% | $0.00 |
| mattmenuottawa2@gmail.com | Mattmenuottawa2 | 15% | $0.00 |
| restozonedispatch@gmail.com | Restozonedispatch | 15% | $0.00 |

**Fee Tiers:**
| Distance | Customer Fee | Driver Earning | Restaurant Pays | Vendor Pays |
|----------|--------------|----------------|-----------------|-------------|
| 5 km | $7.00 | $7.00 | $7.00 | $0.00 |
| 6 km | $8.00 | $8.00 | $8.00 | $0.00 |
| 7 km | $9.00 | $9.00 | $9.00 | $0.00 |
| 8 km | $10.00 | $10.00 | $10.00 | $0.00 |
| 9 km | $11.00 | $11.00 | $11.00 | $0.00 |
| 10 km | $12.00 | $12.00 | $12.00 | $0.00 |

---

### 7. Pho Bo Ga King - Somerset (V3 ID: 199)

| Field | Value |
|-------|-------|
| **Address** | 778 Somerset St W, K1R 6R1 |
| **Legacy V1 ID** | 337 |
| **Delivery Enabled** | ❌ No |
| **Pickup Enabled** | ✅ Yes |
| **Twilio Call** | ✅ Yes |

**Delivery Companies:** ⚠️ None linked

**Fee Tiers:**
| Distance | Customer Fee | Driver Earning | Restaurant Pays | Vendor Pays |
|----------|--------------|----------------|-----------------|-------------|
| 5 km | $6.00 | $6.00 | $6.00 | $0.00 |
| 6 km | $7.00 | $7.00 | $7.00 | $0.00 |
| 7 km | $8.00 | $8.00 | $8.00 | $0.00 |
| 8 km | $9.00 | $9.00 | $9.00 | $0.00 |

---

### 8. Sushiyana (V3 ID: 847)

| Field | Value |
|-------|-------|
| **Address** | 34 boul mont bleu, J8Z 1J1 |
| **Legacy V1 ID** | 1094 |
| **Delivery Enabled** | ✅ Yes |
| **Pickup Enabled** | ✅ Yes |
| **Twilio Call** | ✅ Yes |

**Delivery Companies:**
| Email | Company | Commission | Restaurant Pays |
|-------|---------|------------|-----------------|
| Deliveryzonecanada@gmail.com | Deliveryzonecanada | 15% | $0.00 |
| mattmenuottawa2@gmail.com | Mattmenuottawa2 | 15% | $0.00 |
| restozonedispatch@gmail.com | Restozonedispatch | 15% | $0.00 |

**Fee Tiers:**
| Distance | Customer Fee | Driver Earning | Restaurant Pays | Vendor Pays |
|----------|--------------|----------------|-----------------|-------------|
| 5 km | $7.00 | $7.00 | $7.00 | $0.00 |
| 6 km | $8.00 | $8.00 | $8.00 | $0.00 |
| 7 km | $9.00 | $9.00 | $9.00 | $0.00 |
| 8 km | $10.00 | $10.00 | $10.00 | $0.00 |
| 9 km | $11.00 | $11.00 | $11.00 | $0.00 |
| 10 km | $12.00 | $12.00 | $12.00 | $0.00 |

---

## Delivery Company Emails Reference

| ID | Email | Company Name | Status |
|----|-------|--------------|--------|
| 2 | Deliveryzonecanada@gmail.com | Deliveryzonecanada | Active |
| 4 | mattmenuottawa2@gmail.com | Mattmenuottawa2 | Active |
| 8 | restozonedispatch@gmail.com | Restozonedispatch | Active |

**Note:** All 3 companies are linked to the same 6 restaurants that have delivery company associations.

---

## Data Issues / Action Items

### 1. Restaurants with Delivery Disabled (4)
These restaurants have `distance_based_delivery_fee = true` but `has_delivery_enabled = false`:
- **Charm Thai Cuisine** (943)
- **Lemongrass Thai Cuisine** (1010)
- **New Mee Fung Restaurant** (15)
- **Pho Bo Ga King - Somerset** (199)

**Action:** Verify if these should be pickup-only or if the delivery flag should be enabled.

### 2. Restaurants Without Delivery Company Links (3)
These restaurants have fee tiers but no delivery company assigned:
- **Charm Thai Cuisine** (943)
- **New Mee Fung Restaurant** (15)
- **Pho Bo Ga King - Somerset** (199)

**Action:** Assign delivery companies or confirm they handle delivery in-house.

### 3. Lemongrass Thai Cuisine Data Anomaly
- At 7 km: `restaurant_pays = $9.00` but `total_delivery_fee = $8.00` (mismatch)
- At 9-10 km: `vendor_pays` has values ($10-$11) unlike other restaurants

**Action:** Verify if this is intentional or needs correction.

### 4. Colonnade Pizza Data Inconsistency
- Has 4 fee tiers in `restaurant_distance_based_delivery_fees` (5-8 km)
- Has 3 delivery company links
- BUT `distance_based_delivery_fee = false` in config

**Action:** This restaurant appears in fee tables but is NOT flagged as distance-based. Needs review.

---

## Database Tables Reference

```sql
-- Main config table
SELECT * FROM menuca_v3.delivery_and_pickup_configs 
WHERE distance_based_delivery_fee = true;

-- Fee tiers
SELECT * FROM menuca_v3.restaurant_distance_based_delivery_fees 
WHERE restaurant_id IN (131, 87, 943, 1010, 15, 807, 199, 847);

-- Delivery company links
SELECT * FROM menuca_v3.restaurant_delivery_companies 
WHERE restaurant_id IN (131, 87, 943, 1010, 15, 807, 199, 847);

-- Company emails
SELECT * FROM menuca_v3.delivery_company_emails;
```

---

## Fee Calculation Logic

```
1. Check delivery_and_pickup_configs.distance_based_delivery_fee
2. IF true:
   a. Calculate straight-line distance from restaurant to customer address
   b. Look up fee tier in restaurant_distance_based_delivery_fees
   c. Return total_delivery_fee for matching distance_in_km tier
3. IF false:
   a. Use ST_Contains() to find which delivery zone contains the address
   b. Return restaurant_delivery_areas.delivery_fee (flat fee)
```

---

**Document Created:** 2026-01-22
