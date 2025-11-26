# 3 Restaurants Requiring V1 Polygon Data

**Date:** 2025-11-25  
**Status:** Final list after V2 coordinate verification

---

## Executive Summary

After cross-referencing with the V2 delivery areas export, **only 3 restaurants** require V1 polygon data migration. The other 12 non-MVP restaurants have V2 coordinate data available, which is newer and should be prioritized.

---

## Critical Finding

**Original Assessment:**
- 21 restaurants with V1 polygons total
- 5 MVP restaurants (already processed)
- 16 non-MVP restaurants remained

**After V2 Coordinate Verification:**
- **12 restaurants** have V2 coordinates available → Use V2 data (better/newer)
- **3 restaurants** have NO V2 coordinates → Must use V1 polygons

---

## 3 Restaurants Requiring V1 Polygon Migration

These restaurants have V1 polygon data but **NO V2 coordinate data** available:

| V3 ID | V1 ID | Restaurant Name | Address | Batch | Notes |
|-------|-------|-----------------|---------|-------|-------|
| 7 | 89 | Imilio's Pizzeria | 110 Bearbrook Rd | Phase 2 Batch 1 | Not found in V2 dump |
| 83 | 199 | Season's Pizza | 725 Somerset Street West | Phase 2 Batch 1 | Not found in V2 dump |
| 147 | 280 | Pho Dau Bo Restaurant - Kitchener | 685 Fischer Hallman Rd Unit G | Phase 2 Batch 2 | Not found in V2 dump |

---

## 12 Restaurants with V2 Coordinates (Do NOT Use V1 Polygons)

These restaurants have **BOTH** V1 polygons and V2 coordinates. **V2 data should be used** as it's newer:

### Phase 2 Batch 1 (3 restaurants)

| V3 ID | V1 ID | V2 ID | Restaurant Name | Address |
|-------|-------|-------|-----------------|---------|
| 13 | 95 | 1037 | Papa Joe's Pizza - Downtown | 527 Bronson Ave |
| 62 | 175 | 1086 | Vanier Pizza & Subs | 201 Marier Ave |
| 72 | 187 | 1096 | Cathay Restaurants | 1423 Woodroffe Ave |
| 90 | 206 | 1114 | Milano | 3796 Champlain Rd |

### Phase 2 Batch 2 (7 restaurants)

| V3 ID | V1 ID | V2 ID | Restaurant Name | Address |
|-------|-------|-------|-----------------|---------|
| 1010 | 219 | 1126 | Lemongrass Thai Cuisine | 331 Elgin St |
| 124 | 246 | 1148 | Carlo's Pizza | 60 Harmer Ave |
| 131 | 255 | 1155 | Centertown Donair & Pizza | 422 Bronson Ave |
| 139 | 264 | 1163 | Pizza Bravo | 108 boul Lorrain |
| 234 | 374 | 1259 | New Mukut Restaurant Indian Cuisine | 1968 Portobello Blvd |
| 241 | 383 | 1266 | Beneci Pizza | 4 Lorry Greenberg Dr |
| 267 | 413 | 1292 | Lucky Fortune | 1970 Trim Rd |

### Phase 2 Batch 3 (1 restaurant)

| V3 ID | V1 ID | V2 ID | Restaurant Name | Address |
|-------|-------|-------|-----------------|---------|
| 437 | 612 | 1462 | Papa Joe's Fried Chicken - Downtown | 527 Bronson Ave |

---

## Migration Strategy Recommendations

### For the 3 Restaurants WITHOUT V2 Data

**Source:** V1 `deliveryArea` BLOB (already deserialized in Phase 2)

**Files to use:**
- `phase2_all_restaurants/batch_1_deserialized_areas.json` (for IDs 89, 199)
- `phase2_all_restaurants/batch_2_deserialized_areas.json` (for ID 280)

**Action required:**
1. Extract V1 polygon data from deserialized JSON files
2. Convert to PostGIS format
3. Generate INSERT statements for `menuca_v3.restaurant_delivery_areas`

### For the 12 Restaurants WITH V2 Data

**Source:** V2 `restaurants_delivery_areas` dump → `v2_delivery_areas_export_FILTERED.csv`

**V2 IDs to use:**
```
1037, 1086, 1096, 1114, 1126, 1148, 1155, 1163, 1259, 1266, 1292, 1462
```

**Action required:**
1. Parse V2 coordinate strings from CSV
2. Convert to PostGIS format
3. Generate INSERT statements for `menuca_v3.restaurant_delivery_areas`

**Why V2 over V1:**
- V2 data is newer (later version of the system)
- V2 coordinates are already in lat/lng format
- V2 data was actively used more recently

---

## Quick Reference

### V1 IDs Requiring V1 Polygon Data
```
89, 199, 280
```

### V1 IDs That Should Use V2 Instead
```
95, 175, 187, 206, 219, 246, 255, 264, 374, 383, 413, 612
```

### V2 IDs with Coordinate Data
```
1037, 1086, 1096, 1114, 1126, 1148, 1155, 1163, 1259, 1266, 1292, 1462
```

---

## Data Quality Notes

1. **All 3 V1-only restaurants** are confirmed to have valid polygon data in Phase 2 deserialized files
2. **All 12 V2 restaurants** have coordinate strings confirmed in the V2 export CSV
3. **Zero overlap** between the two groups (clean separation)

---

## Next Steps

1. **Priority 1:** Extract and convert V2 coordinates for the 12 restaurants (covers 80% of non-MVP polygons)
2. **Priority 2:** Extract and convert V1 polygons for the 3 remaining restaurants
3. **Validation:** Compare V1 vs V2 data for 1-2 restaurants to confirm V2 quality
4. **Migration:** Generate and execute SQL INSERT statements for all 15 restaurants

---

## Appendix: Verification Command

To re-verify this list, run:
```bash
python extracted_data/verify_v2_coords_for_non_mvp.py
```

Results saved in: `extracted_data/v2_coord_verification_results.json`

