# Restaurant V1/V2 Categorization List

**Generated:** 2025-11-06  
**Purpose:** Categorize all restaurants by V1/V2 source data availability for bulk import planning

---

## Summary Statistics

| Category | Count | Description |
|---------|-------|-------------|
| **V1_ONLY with data** | 86 | Restaurants with only V1 legacy ID and V1 source data available |
| **V2_ONLY with data** | 17 | Restaurants with only V2 legacy ID and V2 source data available |
| **BOTH with V1 data (prefer V1)** | 126 | Restaurants with both IDs, V1 has data (use V1) |
| **BOTH with V2 data only (use V2)** | 14 | Restaurants with both IDs, only V2 has data (use V2) |
| **BOTH with V1+V2 data (prefer V1)** | 7 | Restaurants with both IDs, both have data (prefer V1) |
| **TOTAL CAN IMPORT** | **250** | Restaurants with source data available in staging |

---

## Import Strategy

**V1 Restaurants (86 + 126 + 7 = 219 total):**
- Import from `staging.menuca_v1_menu`
- Import from `staging.menuca_v1_courses`
- Import modifiers from `staging.menuca_v1_ingredient_groups` and `staging.menuca_v1_ingredients`

**V2 Restaurants (17 + 14 = 31 total):**
- Import from `staging.menuca_v2_restaurants_dishes`
- Import from `staging.menuca_v2_restaurants_courses`
- Import modifiers from `staging.menuca_v2_restaurants_ingredient_groups` and related tables

**Note:** The document `SOURCE_DATA_AVAILABILITY_ANALYSIS.md` mentions 67 restaurants from a "verified active list" of 142. This suggests filtering by a verified active list. The full database has 250 restaurants with source data available.

---

## Detailed Lists

Detailed restaurant lists have been exported to:
- `/Users/brianlapp/.cursor/projects/Users-brianlapp-Documents-GitHub-Migration-Strategy/agent-tools/5b0c217b-94a3-43cc-b212-28c12d2d89b8.txt`

This file contains all 250 restaurants with:
- Restaurant ID
- Restaurant Name
- Status
- Legacy V1 ID
- Legacy V2 ID
- V1 dishes available count
- V2 dishes available count
- Import source recommendation (USE_V1 or USE_V2)

---

## Next Steps

1. **Verify Active List:** If there's a verified active list of 142 restaurants, filter the 250 down to those 67
2. **Create Import Plan:** Plan bulk import for restaurants with source data
3. **Create Audit Plan:** Plan comprehensive audit to flag anything not 100%

---

**Status:** ✅ Complete  
**Last Updated:** 2025-11-06




