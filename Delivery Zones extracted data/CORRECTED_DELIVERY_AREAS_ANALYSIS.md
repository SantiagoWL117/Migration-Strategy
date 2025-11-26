# CORRECTED: Delivery Areas Analysis

**Date:** November 25, 2025  
**Status:** ✅ Corrected after user inquiry

---

## Key Findings - CORRECTED

### Question 1: Do 91.5% of restaurants use radius-based delivery?

**❌ WRONG - My initial analysis was incorrect!**

**✅ CORRECT Analysis:**

**98.8% (162/164) restaurants HAVE deliveryArea BLOB data in V1 dump**

Only **2 restaurants (1.2%)** have NO deliveryArea BLOB data:
1. All Out Burger Gladstone (V3 ID: 948, V1 ID: 1038)
2. All Out Burger (V3 ID: 841, V1 ID: 1088)

---

## What Actually Happened

### V1 Dump Data
- **162 restaurants** have `deliveryArea` BLOB data (length > 0)
- **2 restaurants** have NO `deliveryArea` BLOB data (length = 0)
- **Average BLOB size:** ~1,500 bytes (indicates polygon coordinates)

### Phase 1 MVP Migration
- **5 restaurants** migrated
- **6 polygons** successfully extracted and inserted
- **Success rate:** 100% for Phase 1

### Phase 2 Migration
- **159 restaurants** processed
- **~157 restaurants** should have had polygons (162 total - 5 MVP)
- **0 polygons** extracted (deserialization FAILED)
- **Success rate:** 0% for Phase 2

---

## The Real Problem: Phase 2 Deserialization Failed

### What Should Have Happened
1. **Extract:** 159 restaurant BLOB data ✅ (completed)
2. **Deserialize:** Parse 159 BLOBs → ~157 polygons ❌ (FAILED)
3. **Generate SQL:** Create INSERT statements for ~157 polygons ❌ (FAILED)
4. **Execute:** Insert ~157 polygons to V3 ❌ (FAILED)

### What Actually Happened
```json
// All Phase 2 restaurants ended up like this:
{
  "94": {
    "v1_id": 94,
    "v3_id": "12",
    "restaurant_name": "Mama Rosa",
    "area_entries": []  // ← SHOULD HAVE 1 POLYGON!
  }
}
```

**Result:** 
- All `area_entries` arrays are EMPTY
- All SQL files are EMPTY
- 0 polygons inserted from Phase 2

---

## Why Only 6 Polygons in V3 Database (After Cleanup)

### Before Cleanup (16 polygons)
- **Phase 1 MVP:** 6 polygons ✅
- **October 7 migration:** 10 polygons (from V2 or earlier V1 migration)

### After Cleanup (6 polygons) ✅
- **Deleted:** 10 polygons from non-MVP restaurants
- **Kept:** Only the 6 Phase 1 MVP polygons
- **Missing:** ~157 polygons that should have been migrated in Phase 2

---

## Current State in V3

### ✅ Phase 1 MVP - In Database (6 polygons)
1. Lucky Star Chinese Food (V3 ID: 8, V1 ID: 90) - **2 polygons**
2. Champa Thai Cuisine (V3 ID: 87, V1 ID: 203) - 1 polygon
3. Ginkgo Garden (V3 ID: 105, V1 ID: 224) - 1 polygon
4. Hung Mein (V3 ID: 119, V1 ID: 239) - 1 polygon
5. Orchid Sushi (V3 ID: 245, V1 ID: 387) - 1 polygon

### ❌ Phase 2 - Missing from Database (~157 polygons)
**Examples of restaurants that SHOULD have polygons:**
- Mama Rosa (V3 ID: 12, V1 ID: 94) - BLOB size: 1,444 bytes
- Papa Joe's Pizza (V3 ID: 13, V1 ID: 95) - BLOB size: 3,025 bytes
- House of Lasagna (V3 ID: 22, V1 ID: 117) - BLOB size: 2,220 bytes
- Eastview Pizza (V3 ID: 28, V1 ID: 124) - BLOB size: 1,675 bytes
- Milano (V3 ID: 31, V1 ID: 127) - BLOB size: 1,597 bytes
- ... and ~152 more restaurants

### ✅ No BLOB Data - Correctly No Polygons (2 restaurants)
- All Out Burger Gladstone (V3 ID: 948, V1 ID: 1038)
- All Out Burger (V3 ID: 841, V1 ID: 1088)

---

## Impact Assessment

### Critical Issue: 157 Missing Polygons

**What this means:**
- **157 out of 159 Phase 2 restaurants** are missing their custom delivery area polygons
- These restaurants are currently using:
  - Default radius-based delivery (if configured)
  - OR no delivery area at all
- **Business Impact:** Incorrect delivery area coverage for 98% of Phase 2 restaurants

### Data Loss
- V1 BLOB data EXISTS and is INTACT in dump file
- Data was EXTRACTED successfully
- Data was NOT DESERIALIZED (script failure)
- **Recovery:** Possible by re-running deserialization with fixed script

---

## Root Cause Analysis

### Why Did Deserialization Fail?

Comparing Phase 1 (working) vs Phase 2 (failed):

**Phase 1 Script:**
```python
# extracted_data/phase1_mvp/deserialize_blobs.py
# Used phpserialize library
# Successfully parsed 5 BLOBs → 6 polygons
```

**Phase 2 Script:**
```python
# extracted_data/phase2_all_restaurants/deserialize_batch.py
# Also uses phpserialize library
# Failed to parse 159 BLOBs → 0 polygons
```

**Possible Causes:**
1. **Different BLOB formats** in different V1 records (unlikely - format looks identical)
2. **Bug in batch processing logic** that doesn't exist in single-file processing
3. **Silent exception handling** that caught errors but didn't log them
4. **JSON structure mismatch** between Phase 1 and Phase 2 input formats

---

## Action Required

### Option 1: Fix and Re-run Phase 2 (Recommended)

1. **Debug `deserialize_batch.py`:**
   ```bash
   cd extracted_data/phase2_all_restaurants
   python deserialize_batch.py batch_1_30 --debug
   ```

2. **Compare with working Phase 1 script:**
   ```bash
   diff ../phase1_mvp/deserialize_blobs.py ./deserialize_batch.py
   ```

3. **Fix deserialization logic**

4. **Re-run all 6 batches:**
   ```bash
   for batch in batch_1_30 batch_31_60 batch_61_90 batch_91_120 batch_121_150 batch_151_159
   do
       python deserialize_batch.py $batch
       python generate_batch_sql.py $batch
   done
   ```

5. **Execute SQL:**
   ```bash
   psql $conn -f batch_1_30_areas.sql
   psql $conn -f batch_31_60_areas.sql
   # ... etc
   ```

### Option 2: Use Phase 1 Script for Phase 2 Data

1. **Copy working script:**
   ```bash
   cp ../phase1_mvp/deserialize_blobs.py ./deserialize_phase2_with_working_script.py
   ```

2. **Modify to read Phase 2 JSON files**

3. **Re-run deserialization**

### Option 3: Manual Polygon Migration

If scripts can't be fixed:
1. Extract top priority restaurants (e.g., top 20 by order volume)
2. Manually deserialize their BLOBs
3. Create SQL INSERT statements
4. Execute to V3

---

## Verification Queries

### Check current state
```sql
-- Should show only 5 restaurants with 6 polygons total
SELECT r.id, r.name, r.legacy_v1_id, COUNT(rda.id) as polygon_count
FROM menuca_v3.restaurants r
JOIN menuca_v3.restaurant_delivery_areas rda ON r.id = rda.restaurant_id
WHERE r.legacy_v1_id IS NOT NULL
GROUP BY r.id, r.name, r.legacy_v1_id;
```

### Check restaurants missing polygons
```sql
-- Should show ~157 restaurants that have V1 data but no V3 polygons
SELECT r.id, r.name, r.legacy_v1_id
FROM menuca_v3.restaurants r
WHERE r.legacy_v1_id IS NOT NULL
  AND r.id NOT IN (8, 87, 105, 119, 245)  -- Exclude Phase 1 MVP
  AND r.id NOT IN (948, 841)  -- Exclude no-BLOB restaurants
ORDER BY r.id;
```

---

## Summary

### Corrected Facts

1. **✅ 98.8% (162/164) restaurants HAVE deliveryArea BLOB data in V1**
   - NOT 8.5% as I initially stated

2. **✅ Only 2 restaurants (1.2%) have NO deliveryArea BLOB data**
   - All Out Burger Gladstone & All Out Burger

3. **❌ Phase 2 deserialization FAILED for all 159 restaurants**
   - 0 out of ~157 expected polygons were extracted

4. **✅ Database now has only 6 Phase 1 MVP polygons (after cleanup)**
   - 10 old polygons from Oct 7 migration deleted

5. **❌ 157 restaurants are missing their custom delivery area polygons**
   - This is a CRITICAL data loss that needs to be fixed

---

## Files Updated

### Deletions Performed
```sql
DELETE FROM menuca_v3.restaurant_delivery_areas 
WHERE restaurant_id NOT IN (8, 87, 105, 119, 245);
-- Deleted 10 records (from Oct 7 migration)
-- Kept 6 records (Phase 1 MVP)
```

### Remaining Records
- 5 restaurants: IDs 8, 87, 105, 119, 245
- 6 polygons total (Lucky Star has 2)
- All created during Phase 1 MVP migration

---

## Next Steps

1. ✅ **Deleted incorrect polygons** (completed)
2. ⏭️ **Debug Phase 2 deserialization script** (required)
3. ⏭️ **Re-run Phase 2 with fixed script** (required)
4. ⏭️ **Validate all 157 missing polygons** (required)
5. ⏭️ **Update documentation** (required)

**Priority:** HIGH - 98% of Phase 2 restaurants missing delivery area data

