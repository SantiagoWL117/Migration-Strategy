# 21 Restaurants with V1 Delivery Area Polygons - Complete List with V2 IDs

**Date:** November 25, 2025  
**Purpose:** Master list of all restaurants with custom V1 delivery area polygons, including their V2 IDs for cross-referencing

---

## Complete List of All 21 Restaurants

| V3 ID | V1 ID | V2 ID | Restaurant Name | Address |
|-------|-------|-------|-----------------|---------|
| 8 | 90 | 1032 | Lucky Star Chinese Food | 1615 Orleans Blvd. |
| 87 | 203 | 1111 | Champa Thai Cuisine | 193 King Edward Ave |
| 105 | 224 | 1129 | Ginkgo Garden | 2225 St Laurent Blvd |
| 119 | 239 | 1143 | Hung Mein | 2567 Baseline Rd |
| 245 | 387 | 1270 | Orchid Sushi | 445 Laurier Ave W |
| 7 | 89 | 1031 | Imilio's Pizzeria | 110 Bearbrook Rd |
| 13 | 95 | 1037 | Papa Joe's Pizza - Downtown | 527 Bronson Ave |
| 62 | 175 | 1086 | Vanier Pizza & Subs | 201 Marier Ave |
| 72 | 187 | 1096 | Cathay Restaurants | 1423 Woodroffe Ave |
| **83** | **199** | **N/A** | **Season's Pizza** | **725 Somerset Street West** |
| 90 | 206 | 1114 | Milano | 3796 Champlain Rd |
| 1010 | 219 | 1126 | Lemongrass Thai Cuisine | 331 Elgin St |
| 124 | 246 | 1148 | Carlo's Pizza | 60 Harmer Ave |
| 131 | 255 | 1155 | Centertown Donair & Pizza | 422 Bronson Ave |
| 139 | 264 | 1163 | Pizza Bravo | 108 boul Lorrain |
| 147 | 280 | 1171 | Pho Dau Bo Restaurant - Kitchener | 685 Fischer Hallman Rd Unit G |
| 234 | 374 | 1259 | New Mukut Restaurant Indian Cuisine | 1968 Portobello Blvd |
| 241 | 383 | 1266 | Beneci Pizza | 4 Lorry Greenberg Dr |
| 267 | 413 | 1292 | Lucky Fortune | 1970 Trim Rd |
| 437 | 612 | 1462 | Papa Joe's Fried Chicken - Downtown | 527 Bronson Ave |

---

## V2 IDs for SQL Queries

**Format for WHERE IN clause:**

```sql
(1032, 1111, 1129, 1143, 1270, 1031, 1037, 1086, 1096, 1114, 1126, 1148, 1155, 1163, 1171, 1259, 1266, 1292, 1462)
```

**Total:** 19 V2 IDs (out of 21 restaurants)

---

## Summary Statistics

| Metric | Count | Percentage |
|--------|-------|------------|
| Total restaurants with V1 polygons | 21 | 100% |
| Matched to V2 (have V2 ID) | 20 | 95.2% |
| NOT in V2 (no V2 ID) | 1 | 4.8% |

---

## Missing from V2

**Season's Pizza**
- **V3 ID:** 83
- **V1 ID:** 199
- **V2 ID:** N/A (not found in V2 dump)
- **Address:** 725 Somerset Street West
- **Status:** Has V1 polygon data but no V2 record

**Note:** This restaurant was likely added to V1 but never migrated to V2, or was removed before V2 migration.

---

## Breakdown by Phase

### Phase 1 MVP (5 restaurants)
| V3 ID | V1 ID | V2 ID | Restaurant Name |
|-------|-------|-------|-----------------|
| 8 | 90 | 1032 | Lucky Star Chinese Food |
| 87 | 203 | 1111 | Champa Thai Cuisine |
| 105 | 224 | 1129 | Ginkgo Garden |
| 119 | 239 | 1143 | Hung Mein |
| 245 | 387 | 1270 | Orchid Sushi |

**V2 IDs:** `(1032, 1111, 1129, 1143, 1270)` - 5/5 in V2 (100%)

---

### Phase 2 Batch 1 (6 restaurants)
| V3 ID | V1 ID | V2 ID | Restaurant Name |
|-------|-------|-------|-----------------|
| 7 | 89 | 1031 | Imilio's Pizzeria |
| 13 | 95 | 1037 | Papa Joe's Pizza - Downtown |
| 62 | 175 | 1086 | Vanier Pizza & Subs |
| 72 | 187 | 1096 | Cathay Restaurants |
| **83** | **199** | **N/A** | **Season's Pizza** |
| 90 | 206 | 1114 | Milano |

**V2 IDs:** `(1031, 1037, 1086, 1096, 1114)` - 5/6 in V2 (83.3%)

---

### Phase 2 Batch 2 (8 restaurants)
| V3 ID | V1 ID | V2 ID | Restaurant Name |
|-------|-------|-------|-----------------|
| 1010 | 219 | 1126 | Lemongrass Thai Cuisine |
| 124 | 246 | 1148 | Carlo's Pizza |
| 131 | 255 | 1155 | Centertown Donair & Pizza |
| 139 | 264 | 1163 | Pizza Bravo |
| 147 | 280 | 1171 | Pho Dau Bo Restaurant - Kitchener |
| 234 | 374 | 1259 | New Mukut Restaurant Indian Cuisine |
| 241 | 383 | 1266 | Beneci Pizza |
| 267 | 413 | 1292 | Lucky Fortune |

**V2 IDs:** `(1126, 1148, 1155, 1163, 1171, 1259, 1266, 1292)` - 8/8 in V2 (100%)

---

### Phase 2 Batch 3 (1 restaurant)
| V3 ID | V1 ID | V2 ID | Restaurant Name |
|-------|-------|-------|-----------------|
| 437 | 612 | 1462 | Papa Joe's Fried Chicken - Downtown |

**V2 IDs:** `(1462)` - 1/1 in V2 (100%)

---

## Usage Examples

### Query V2 delivery areas for these restaurants
```sql
SELECT 
    restaurant_id,
    area_number,
    area_name,
    coords,
    delivery_fee,
    min_order_value
FROM v2_restaurants_delivery_areas 
WHERE restaurant_id IN (
    1032, 1111, 1129, 1143, 1270, 1031, 1037, 1086, 1096, 1114, 
    1126, 1148, 1155, 1163, 1171, 1259, 1266, 1292, 1462
)
ORDER BY restaurant_id, area_number;
```

### Check which have delivery areas in V2
```sql
SELECT 
    r.restaurant_id,
    COUNT(*) as area_count
FROM v2_restaurants_delivery_areas rda
WHERE rda.restaurant_id IN (
    1032, 1111, 1129, 1143, 1270, 1031, 1037, 1086, 1096, 1114, 
    1126, 1148, 1155, 1163, 1171, 1259, 1266, 1292, 1462
)
GROUP BY rda.restaurant_id
ORDER BY area_count DESC;
```

---

## Files Generated

- `extracted_data/21_POLYGON_RESTAURANTS_WITH_V2_IDS.md` - This document
- `extracted_data/list_21_polygon_restaurants_with_v2.py` - Python script to generate list

---

**Last Updated:** November 25, 2025  
**Total Restaurants:** 21  
**V2 Match Rate:** 95.2% (20 out of 21)

