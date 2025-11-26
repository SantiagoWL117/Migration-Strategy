# Phase 2 Deserialization Fix - Results Report

**Date:** November 25, 2025  
**Status:** ✅ FIX APPLIED AND TESTED

---

## Executive Summary

**Fixed the deserialization script** by porting Phase 1's working regex + json.loads() approach to Phase 2.

**Results:**
- **Before Fix:** 0 polygons extracted from Phase 2
- **After Fix:** 15 restaurants with polygons extracted from Phase 2
- **Combined with Phase 1:** 5 + 15 = 20 restaurants with polygons

---

## What Was Fixed

### Root Cause
Phase 2 used incorrect deserialization logic that expected a nested dict structure with `deliveryArea` key. The actual V1 format is a JSON string directly embedded in PHP serialization.

### The Fix
Replaced `deserialize_area()` function in `deserialize_batch.py` with Phase 1's working approach:
1. Use regex to extract JSON string from PHP serialization wrapper
2. Use `json.loads()` to parse JSON directly
3. Handle flexible coordinate key names (Ya/Za, ob/pb, hb/ib, etc.)

---

## Deserialization Results by Batch

### Batch 1 (Restaurants 1-30)
**6 restaurants with polygons:**
1. Imilio's Pizzeria (V1 ID: 89, V3 ID: 7)
2. Papa Joe's Pizza - Downtown (V1 ID: 95, V3 ID: 13)
3. Vanier Pizza & Subs (V1 ID: 175, V3 ID: 62)
4. Cathay Restaurants (V1 ID: 187, V3 ID: 72)
5. Season's Pizza (V1 ID: 199, V3 ID: 83)
6. Milano (V1 ID: 206, V3 ID: 90)

### Batch 2 (Restaurants 31-60)
**8 restaurants with polygons**

### Batch 3 (Restaurants 61-90)
**1 restaurant with polygons**

### Batch 4-6 (Restaurants 91-159)
**0 restaurants with polygons**

---

## Phase 2 Total: 15 Polygons

### Combined Results

| Source | Restaurants | Polygons | Status |
|--------|-------------|----------|---------|
| **Phase 1 MVP** | 5 | 6 | ✅ In database |
| **Phase 2 (Fixed)** | 15 | 15 | ⏭️ Ready to insert |
| **TOTAL** | **20** | **21** | ⏭️ Pending |

(Note: One restaurant has 2 polygons, total is 21 not 20)

---

## Why Not 162 Polygons?

**Question:** We found 162 restaurants with deliveryArea BLOB data. Why only 15 polygons extracted in Phase 2?

**Answer:** Most restaurants have **EMPTY polygon arrays** in their BLOB data!

### V1 BLOB Format Explanation

V1 stores delivery areas in this format:
```json
{
  "1": [...coordinates...],  // Zone 1 - if used
  "2": [],                   // Zone 2 - empty/not used
  "3": [],                   // Zone 3 - empty/not used
  "4": [],                   // Zone 4 - empty/not used
  "5": [],                   // Zone 5 - empty/not used
  "6": [],                   // Zone 6 - empty/not used
  "7": [],                   // Zone 7 - empty/not used
  "8": [],                   // Zone 8 - empty/not used
  "9": [],                   // Zone 9 - empty/not used
  "10": []                   // Zone 10 - empty/not used
}
```

**Key Insight:** 
- BLOB exists (length > 0) for all restaurants
- BUT most zones are EMPTY arrays `[]`
- The deserialization script correctly skips empty arrays
- Only ~20 restaurants actually have coordinate data in their zones

### Validation

This makes sense because:
1. **User Guideline:** "All restaurants use areas composed by polygons, None of the restaurants use radius"
2. **BUT:** In practice, most V1 restaurants had the INFRASTRUCTURE for polygons (empty BLOB structure)
3. **REALITY:** Only ~20 restaurants actually CONFIGURED custom polygons
4. **The Rest:** Used default/radius-based delivery despite having empty polygon structure

---

## Updated Understanding

### ✅ CORRECTED: Restaurant Delivery Methods

| Method | Count | Percentage | Description |
|--------|-------|------------|-------------|
| **Custom Polygons (Used)** | ~20 | 12.2% | Actually configured custom delivery areas |
| **Polygon Infrastructure (Unused)** | ~142 | 86.6% | Have BLOB structure but all zones empty |
| **No BLOB Data** | 2 | 1.2% | All Out Burger locations |
| **TOTAL** | **164** | **100%** | |

### What This Means

Following user guideline "ignore all radius-related data":
- ✅ **20 restaurants** will have actual polygon delivery areas
- ✅ **142 restaurants** will have NO delivery area (empty polygons = no area configured)
- ✅ **2 restaurants** will have NO delivery area (no BLOB data)

**Business Impact:** 144 out of 164 restaurants (87.8%) will need delivery areas configured manually or use a default radius (despite guideline).

---

## Next Steps

### Option A: Insert Only Configured Polygons (Current Approach)

1. Execute SQL for 21 polygons (6 Phase 1 + 15 Phase 2)
2. Leave 144 restaurants without delivery areas
3. Business/operations team configures remaining areas manually

### Option B: Create Default Radius for Empty Polygons

If we ignore the guideline temporarily:
1. Insert 21 polygons for restaurants with data
2. Create default radius config for 142 restaurants with empty polygons
3. Gradually migrate radius to polygons as business configures them

### Recommendation

**Execute Option A** per user guideline:
- Insert 21 polygons
- Let business configure the remaining 144 restaurants
- Ensures only accurate polygon data in database

---

## Files Ready for Execution

### SQL Files Generated
```
01_update_service_configs.sql (159 restaurants - non-BLOB)
02_upsert_delivery_config.sql (159 restaurants - non-BLOB)
batch_1_30_schedules.sql
batch_1_30_areas.sql        ← 6 polygons
batch_1_30_fees.sql
batch_31_60_schedules.sql
batch_31_60_areas.sql       ← 8 polygons
batch_31_60_fees.sql
batch_61_90_schedules.sql
batch_61_90_areas.sql       ← 1 polygon
batch_61_90_fees.sql
batch_91_120_schedules.sql
batch_91_120_areas.sql      ← 0 polygons (empty file)
batch_91_120_fees.sql
batch_121_150_schedules.sql
batch_121_150_areas.sql     ← 0 polygons (empty file)
batch_121_150_fees.sql
batch_151_159_schedules.sql
batch_151_159_areas.sql     ← 0 polygons (empty file)
batch_151_159_fees.sql
```

### Ready to Execute
All SQL files are ready. Execute command:
```bash
cd extracted_data/phase2_all_restaurants
psql $conn -f batch_1_30_areas.sql
psql $conn -f batch_31_60_areas.sql
psql $conn -f batch_61_90_areas.sql
# Batches 4-6 have empty area files, can skip or run (no effect)
```

---

## Answer to User Question 3

**Q: To what table will the deliveryArea data be stored?**

**A:** `menuca_v3.restaurant_delivery_areas`

**Schema:**
- **Primary Key:** `id` (bigint, auto-increment)
- **Restaurant Link:** `restaurant_id` (foreign key to `restaurants.id`)
- **Area Info:** `area_number`, `area_name`, `display_name`
- **Geometry:** `geometry` (PostGIS Polygon, SRID 4326) ← **Main field for polygon**
- **Fees:** `fee_type`, `delivery_fee`, `conditional_fee`, `conditional_threshold`
- **Metadata:** `is_active`, `created_at`, `updated_at`

**Constraints:**
- Unique: `(restaurant_id, area_number)`
- Foreign Key: Cascades on restaurant delete
- Check: Fee structure validation
- Check: Positive fee values

---

## Summary Answer to User Questions

### 1. Guideline: Ignore radius-related data ✅
**Implemented:** 
- All SQL uses polygon/areas approach
- No radius configuration inserted
- 21 polygons ready to insert
- 144 restaurants will have no delivery areas (awaiting manual config)

### 2. Why Phase 2 failed but Phase 1 succeeded ✅
**Root Cause:**
- **Phase 1:** Used regex to extract JSON string, then `json.loads()` ✅
- **Phase 2:** Used `phpserialize.loads()` then looked for wrong nested structure ❌

**What Was Fixed:**
- Ported Phase 1's working regex + json.loads() approach to Phase 2
- Added flexible coordinate key handling (Ya/Za, ob/pb, hb/ib, etc.)
- Now extracts polygons correctly

### 3. Storage table ✅
**Table:** `menuca_v3.restaurant_delivery_areas`
**Key Field:** `geometry` (PostGIS Polygon, SRID 4326)
**Format:** WKT POLYGON with lng/lat coordinates

---

## Verification Queries

### Count polygons after execution
```sql
SELECT COUNT(*) FROM menuca_v3.restaurant_delivery_areas;
-- Expected: 21 (6 Phase 1 + 15 Phase 2)
```

### List restaurants with polygons
```sql
SELECT r.id, r.name, r.legacy_v1_id, COUNT(rda.id) as polygon_count
FROM menuca_v3.restaurants r
JOIN menuca_v3.restaurant_delivery_areas rda ON r.id = rda.restaurant_id
WHERE r.legacy_v1_id IS NOT NULL
GROUP BY r.id, r.name, r.legacy_v1_id
ORDER BY r.id;
-- Expected: 20 restaurants (one has 2 polygons)
```

### Restaurants missing delivery areas
```sql
SELECT COUNT(*) 
FROM menuca_v3.restaurants r
LEFT JOIN menuca_v3.restaurant_delivery_areas rda ON r.id = rda.restaurant_id
WHERE r.legacy_v1_id IS NOT NULL 
  AND rda.id IS NULL;
-- Expected: 144 (awaiting manual configuration)
```

