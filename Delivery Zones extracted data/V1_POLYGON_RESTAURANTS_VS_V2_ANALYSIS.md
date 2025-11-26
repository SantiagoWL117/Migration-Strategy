# V1 Polygon Restaurants vs V2 Matching Analysis

**Date:** November 25, 2025  
**Question:** Do the 21 restaurants with V1 delivery area polygons exist in the 90 V2 matched restaurants list?

---

## Executive Summary

**Answer:** ✅ **YES - 19 out of 21 (90.5%) restaurants with V1 polygons exist in V2**

| Metric | Count | Percentage |
|--------|-------|------------|
| Total V1 polygon restaurants | 21 | 100% |
| Found in V2 matched list | **19** | **90.5%** |
| NOT in V2 matched list | 1 | 4.8% |

**Key Finding:** The vast majority (90.5%) of restaurants with custom V1 delivery area polygons also exist in the V2 database, meaning we can cross-reference with V2 delivery area data (`restaurants_delivery_areas` table) if needed.

---

## Detailed Breakdown

### Phase 1 MVP (5 restaurants with polygons)

**Status:** ✅ **5/5 in V2 (100%)**

| V3 ID | V1 ID | Restaurant Name | In V2? |
|-------|-------|-----------------|--------|
| 8 | 90 | Lucky Star Chinese Food | ✅ Yes |
| 87 | 203 | Champa Thai Cuisine | ✅ Yes |
| 105 | 224 | Ginkgo Garden | ✅ Yes |
| 119 | 239 | Hung Mein | ✅ Yes |
| 245 | 387 | Orchid Sushi | ✅ Yes |

---

### Phase 2 Batch 1 (6 restaurants with polygons)

**Status:** ⚠️ **5/6 in V2 (83.3%)**

| V3 ID | V1 ID | Restaurant Name | In V2? |
|-------|-------|-----------------|--------|
| 7 | 89 | Imilio's Pizzeria | ✅ Yes |
| 13 | 95 | Papa Joe's Pizza - Downtown | ✅ Yes |
| 62 | 175 | Vanier Pizza & Subs | ✅ Yes |
| 72 | 187 | Cathay Restaurants | ✅ Yes |
| **83** | **199** | **Season's Pizza** | ❌ **NOT in V2** |
| 90 | 206 | Milano | ✅ Yes |

---

### Phase 2 Batch 2 (8 restaurants with polygons)

**Status:** ✅ **8/8 in V2 (100%)**

| V3 ID | V1 ID | Restaurant Name | In V2? |
|-------|-------|-----------------|--------|
| 1010 | 219 | Lemongrass Thai Cuisine | ✅ Yes |
| 124 | 246 | Carlo's Pizza | ✅ Yes |
| 131 | 255 | Centertown Donair & Pizza | ✅ Yes |
| 139 | 264 | Pizza Bravo | ✅ Yes |
| 147 | 280 | Pho Dau Bo Restaurant - Kitchener | ✅ Yes |
| 234 | 374 | New Mukut Restaurant Indian Cuisine | ✅ Yes |
| 241 | 383 | Beneci Pizza | ✅ Yes |
| 267 | 413 | Lucky Fortune | ✅ Yes |

---

### Phase 2 Batch 3 (1 restaurant with polygons)

**Status:** ✅ **1/1 in V2 (100%)**

| V3 ID | V1 ID | Restaurant Name | In V2? |
|-------|-------|-----------------|--------|
| 437 | 612 | Papa Joe's Fried Chicken - Downtown | ✅ Yes |

---

## Missing Restaurant Details

### Season's Pizza (V3 ID: 83, V1 ID: 199)

**Status:** ❌ NOT found in V2 dump

**Details:**
- **V3 ID:** 83
- **V1 ID:** 199
- **Name:** Season's Pizza
- **Address:** 725 Somerset Street West (from V3)
- **Has V1 Polygon Data:** ✅ Yes (1 polygon extracted)
- **In V2 Dump:** ❌ No match found

**Possible Reasons:**
1. Restaurant was added to V1 but never migrated to V2
2. Restaurant closed/removed before V2 migration
3. Name or data changed significantly between V1 and V2

**Impact:** This restaurant has valid V1 polygon data that can be migrated to V3, even though no V2 record exists.

---

## Implications for V2 Delivery Area Data

### Opportunity: Cross-Reference with V2 `restaurants_delivery_areas`

Since **19 out of 21** restaurants with V1 polygons also exist in V2, we can:

1. **Query V2 `restaurants_delivery_areas` table** for these 19 restaurants
2. **Compare V1 vs V2 polygon data** to see which is more recent/accurate
3. **Use V2 data as fallback** if V1 polygons have issues
4. **Extract V2 polygons** for any of the 147 restaurants with empty V1 polygon arrays

### V2 Table Reference

From `Database/Legacy Schemas/v2_structure.sql`:
```sql
CREATE TABLE `restaurants_delivery_areas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `restaurant_id` int(11) NOT NULL,
  `area_number` int(11) NOT NULL,
  `area_name` varchar(255) DEFAULT NULL,
  `delivery_fee` decimal(10,2) DEFAULT NULL,
  `min_order_value` decimal(10,2) DEFAULT NULL,
  `is_complex` tinyint(1) DEFAULT '0',
  `coords` text,              -- ← Coordinate data (TEXT format)
  `geometry` geometry DEFAULT NULL,  -- ← PostGIS geometry (GEOMETRY type)
  PRIMARY KEY (`id`),
  UNIQUE KEY `restaurant_id_area_number` (`restaurant_id`,`area_number`)
)
```

### Next Steps

1. **Extract V2 delivery area data** for the 19 matched restaurants
2. **Compare V1 vs V2 polygons** to determine which is more accurate/recent
3. **Use V2 as source** for any of the 147 restaurants with empty V1 polygons
4. **Prioritize V2 data** if it appears more complete or recent

---

## Summary Statistics

| Category | Count | Percentage of 21 |
|----------|-------|------------------|
| MVP restaurants in V2 | 5 | 23.8% |
| Phase 2 Batch 1 in V2 | 5 | 23.8% |
| Phase 2 Batch 2 in V2 | 8 | 38.1% |
| Phase 2 Batch 3 in V2 | 1 | 4.8% |
| **Total in V2** | **19** | **90.5%** |
| **Not in V2** | **1** | **4.8%** |

---

## Files Generated

- `extracted_data/check_polygon_restaurants_in_v2.py` - Python script for analysis
- `extracted_data/V1_POLYGON_RESTAURANTS_VS_V2_ANALYSIS.md` - This report

---

**Report Complete**

