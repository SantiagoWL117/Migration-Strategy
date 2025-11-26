# V2 Delivery Areas Filtering Summary

**Date:** 2025-11-25  
**Process:** Filtered V2 delivery areas export to retain only relevant restaurants

---

## Question 1: Are the 21 V1 Polygon Restaurants in V2 Export?

### Answer: ✅ **YES - 17 out of 21 (85.0%)**

#### Found in V2 Export (17 restaurants):

| V3 ID | V1 ID | V2 ID | Restaurant Name |
|-------|-------|-------|-----------------|
| 8 | 90 | 1032 | Lucky Star Chinese Food |
| 87 | 203 | 1111 | Champa Thai Cuisine |
| 105 | 224 | 1129 | Ginkgo Garden |
| 119 | 239 | 1143 | Hung Mein |
| 245 | 387 | 1270 | Orchid Sushi |
| 13 | 95 | 1037 | Papa Joe's Pizza - Downtown |
| 62 | 175 | 1086 | Vanier Pizza & Subs |
| 72 | 187 | 1096 | Cathay Restaurants |
| 90 | 206 | 1114 | Milano |
| 1010 | 219 | 1126 | Lemongrass Thai Cuisine |
| 124 | 246 | 1148 | Carlo's Pizza |
| 131 | 255 | 1155 | Centertown Donair & Pizza |
| 139 | 264 | 1163 | Pizza Bravo |
| 234 | 374 | 1259 | New Mukut Restaurant Indian Cuisine |
| 241 | 383 | 1266 | Beneci Pizza |
| 267 | 413 | 1292 | Lucky Fortune |
| 437 | 612 | 1462 | Papa Joe's Fried Chicken - Downtown |

#### NOT Found in V2 Export (3 restaurants):

| V3 ID | V1 ID | Restaurant Name | Notes |
|-------|-------|-----------------|-------|
| 7 | 89 | Imilio's Pizzeria | Has V1 polygon, NO V2 data |
| 83 | 199 | Season's Pizza | Has V1 polygon, NO V2 data |
| 147 | 280 | Pho Dau Bo Restaurant - Kitchener | Has V1 polygon, NO V2 data |

**Implication:** These 3 restaurants will need to rely on their V1 polygon data only, as they have no V2 coordinate data available.

---

## Question 2: Filter V2 Export to Relevant Restaurants

### Filtering Criteria:
1. **83 matched restaurants** (from V2-V3 matching analysis)
2. **21 restaurants with V1 polygons** (identified from Phase 1 MVP + Phase 2 extraction)

### Results:

| Metric | Count |
|--------|-------|
| Original rows in export | 574 |
| Filtered rows retained | 93 |
| Rows removed | 481 |
| Retention rate | 16.2% |
| Unique restaurants (by V2 ID) | 84 |
| Unique restaurants (by V1 ID) | 68 |

### File Operations:

✅ **Original file backed up:** `v2_delivery_areas_export_ORIGINAL_BACKUP.csv`  
✅ **Filtered version created:** `v2_delivery_areas_export_FILTERED.csv`  
✅ **Original file replaced:** `v2_delivery_areas_export.csv` now contains only filtered data

---

## Key Findings

### Coverage Analysis:

1. **V1 Polygon Restaurants in V2:**
   - 17 out of 21 V1 polygon restaurants (81.0%) have corresponding V2 coordinate data
   - This provides a valuable cross-reference for validating V1 polygon accuracy

2. **V2 Data Availability:**
   - 83 active V3 restaurants have V2 coordinate data
   - Combined with V1 polygons, we have geographic data for a significant portion of active restaurants

3. **Multiple Delivery Areas:**
   - Some restaurants in the filtered export have multiple delivery zones defined
   - This complexity needs to be handled during V3 migration

### Data Quality Implications:

- **Best Coverage:** Restaurants with BOTH V1 polygons AND V2 coordinates (17 restaurants)
  - Can cross-validate polygon accuracy
  - Can choose best quality data source
  
- **V2 Only:** Restaurants with V2 coordinates but no V1 polygons (~66 restaurants)
  - V2 coordinates can fill gaps in V3 delivery areas
  
- **V1 Only:** Restaurants with V1 polygons but no V2 data (3 restaurants)
  - Must rely on V1 polygon data
  - Manual validation recommended

---

## Next Steps

1. **Extract V2 Coordinates:**
   - Parse the `coords` column from filtered export
   - Convert format: `lat,lng|lat,lng|...` → PostGIS `POLYGON((lng lat, lng lat, ...))`

2. **Compare V1 vs V2 Data:**
   - For the 17 restaurants with both V1 and V2 data, compare polygon shapes
   - Identify discrepancies and choose best source

3. **Generate V3 INSERT Statements:**
   - Create SQL to insert V2 coordinate data into `menuca_v3.restaurant_delivery_areas`
   - Use V2 data to fill gaps for restaurants without V1 polygons

4. **Validate:**
   - Test delivery area calculations in V3
   - Verify polygon accuracy for sample addresses

---

## Scripts Created

- `check_21_in_v2_export.py` - Checks which V1 polygon restaurants exist in V2 export
- `filter_v2_delivery_areas.py` - Filters V2 export to retain only relevant restaurants
- `match_restaurants_with_v2_delivery_areas.py` - Matches active restaurants with V2 export

---

## Files Generated

- `v2_delivery_areas_export.csv` - **FILTERED** export (93 rows, 84 unique restaurants)
- `v2_delivery_areas_export_ORIGINAL_BACKUP.csv` - Original unfiltered export (574 rows)
- `v2_delivery_areas_export_FILTERED.csv` - Filtered export (duplicate of current main file)
- `V2_DELIVERY_AREAS_MATCHING_REPORT.md` - Full matching analysis report
- `v2_delivery_areas_matches.csv` - CSV of 83 matched restaurants
- `V2_FILTERING_SUMMARY.md` - This document

