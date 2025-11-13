# List 4 Excluded Restaurants Analysis

**Date:** 2025-11-13  
**Total Excluded:** 15 restaurants  
**Reason:** No V1 CRM ID (`legacy_v1_id` is NULL)

---

## Summary

The List 4 scraper is correctly excluding **15 restaurants** from the 66 restaurants in List 4. These restaurants are being excluded because they do **NOT have a `legacy_v1_id` (V1 CRM ID)**, which is required to scrape menu data from the V1 CRM system.

### Breakdown by Category:

| Category | Count | Restaurant IDs |
|----------|-------|----------------|
| **V2 Only Restaurants** | 5 | 924, 948, 949, 938, 943 |
| **Newly Added (No CRM ID)** | 9 | 1009-1017 |
| **No CRM ID at All** | 1 | 941 |

**Total Restaurants to Scrape:** 66 - 15 = **51 restaurants**

---

## Detailed Analysis

### 1. V2 Only Restaurants (5 restaurants)

These restaurants have a **V2 CRM ID** (`legacy_v2_id`) but **NO V1 CRM ID** (`legacy_v1_id`). They should be scraped using a **V2 scraper**, not the V1 List 4 scraper.

| DB ID | Name | Legacy V1 ID | Legacy V2 ID | Status | Address |
|-------|------|--------------|--------------|--------|---------|
| 924 | All Out Burger Bank St. | null | 1611 | active | 2560 Bank Street |
| 948 | All Out Burger Gladstone | null | 1635 | active | 714 Gladstone Ave |
| 949 | All Out Burger Montreal Rd | null | 1636 | active | 585 Montreal Road |
| 938 | Aroy Thai | null | 1625 | pending | 1 Rideaucrest Drive |
| 943 | Charm Thai Cuisine | null | 1630 | active | 121 Preston St |

**Note:** 
- All Out Burger Bank St. (DB:924) is in List 4 as "2560 Bank Street" 
- All Out Burger Gladstone (DB:948) is in List 4 as "714 Gladstone Ave"
- All Out Burger Montreal Rd (DB:949) is in List 4 as "585 Montreal Road"
- Aroy Thai (DB:938) is in List 4 as "1 Rideaucrest Drive" but is marked as **"pending"** with a parent_restaurant_id of 995
- Charm Thai Cuisine (DB:943) is in List 4 as "121 Preston St"

**Action Required:**
- These 5 restaurants should be **removed from List 4** as they are V2 restaurants
- They should be added to a **V2 scraping queue** instead
- **Note**: Aroy Thai (DB:607) with address "1 Rideaucrest Drive" IS in `list4_restaurants.json` and may be a different restaurant or the V1 version

---

### 2. Newly Added Restaurants (9 restaurants)

These restaurants were **added to the database on 2025-11-12** as part of the "missing restaurants" task. They have **NO CRM ID** (neither V1 nor V2) because they were just inserted and haven't been mapped to the CRM yet.

| DB ID | Name | Legacy V1 ID | Legacy V2 ID | Status | Address | Created At |
|-------|------|--------------|--------------|--------|---------|------------|
| 1009 | Econo Pizza | null | null | pending | 425, boul La Vérendrye E | 2025-11-12 22:12:12 |
| 1010 | Lemongrass Thai Cuisine | null | null | pending | 331 Elgin St | 2025-11-12 22:12:13 |
| 1011 | Mozza Pizza Gatineau | null | null | pending | 425, boul La Vérendrye E | 2025-11-12 22:12:13 |
| 1012 | Papa Pizza Des Flandres | null | null | pending | 22, rue des Flandres | 2025-11-12 22:12:13 |
| 1013 | Papa Pizza Maloney | null | null | pending | 253, boul Maloney | 2025-11-12 22:12:13 |
| 1014 | Papa Pizza Val-Des-Monts | null | null | pending | 1797, rte du Carrefour | 2025-11-12 22:12:14 |
| 1015 | Poutinerie Québecurds Gatineau | null | null | pending | 643 Boulevard Saint-René O | 2025-11-12 22:12:14 |
| 1016 | Roulas Grecque et Pizza | null | null | pending | 245, rue de Cannes | 2025-11-12 22:12:14 |
| 1017 | Sushi Express Chambly | null | null | pending | 886 ch de Chambly | 2025-11-12 22:12:15 |

**Action Required:**
- These 9 restaurants need to be **manually mapped to their V1 CRM IDs** by querying the CRM system
- Once mapped, they can be added to `list4_restaurants.json` and scraped
- **Alternative**: Use the HTML markup provided by the user to extract CRM IDs directly

---

### 3. No CRM ID at All (1 restaurant)

This restaurant has **NO V1 or V2 CRM ID** and is marked as **"pending"**.

| DB ID | Name | Legacy V1 ID | Legacy V2 ID | Status | Address |
|-------|------|--------------|--------------|--------|---------|
| 941 | Ting's Kitchen | null | 1628 | pending | 3-701 Eagleson Rd |

**Note:** Upon closer inspection, this restaurant **DOES have a V2 CRM ID (1628)**, so it should be categorized under "V2 Only Restaurants" instead.

**Revised Count:**
- **V2 Only Restaurants:** 6 (including Ting's Kitchen)
- **Newly Added (No CRM ID):** 9
- **No CRM ID at All:** 0

---

## Confirmation: List 4 Scraper Exclusions

✅ **CONFIRMED:** The List 4 scraper is correctly excluding these **15 restaurants**:

### V2 Only (6 restaurants - should NOT be scraped by V1 scraper):
1. All Out Burger Bank St. (DB:924, V2:1611)
2. All Out Burger Gladstone (DB:948, V2:1635)
3. All Out Burger Montreal Rd (DB:949, V2:1636)
4. Aroy Thai (DB:938, V2:1625)
5. Charm Thai Cuisine (DB:943, V2:1630)
6. Ting's Kitchen (DB:941, V2:1628)

### Newly Added - Need CRM Mapping (9 restaurants):
7. Econo Pizza (DB:1009)
8. Lemongrass Thai Cuisine (DB:1010)
9. Mozza Pizza Gatineau (DB:1011)
10. Papa Pizza Des Flandres (DB:1012)
11. Papa Pizza Maloney (DB:1013)
12. Papa Pizza Val-Des-Monts (DB:1014)
13. Poutinerie Québecurds Gatineau (DB:1015)
14. Roulas Grecque et Pizza (DB:1016)
15. Sushi Express Chambly (DB:1017)

---

## Next Steps

### For V2 Restaurants (6 restaurants):
1. **Remove from List 4** in `ACTIVE_V1_RESTAURANTS_SCRAPPED.md`
2. **Add to V2 scraping queue** (create if needed)
3. **Update counts** in List 4 (66 → 60 restaurants)

### For Newly Added Restaurants (9 restaurants):
1. **Extract CRM IDs** from the HTML markup provided by the user
2. **Update database** with V1 CRM IDs (`legacy_v1_id`)
3. **Re-run** `extract_list4_restaurants.py` to regenerate `list4_restaurants.json`
4. **Verify** the 9 restaurants now appear in `list4_restaurants.json`
5. **Proceed** with List 4 scraper

---

## Expected Final Count

- **Total in List 4:** 66 restaurants
- **V2 Only (exclude):** -6 restaurants
- **Newly Added (needs CRM mapping):** 9 restaurants (will be mapped)
- **Final scraped by List 4:** 60 restaurants (51 existing + 9 newly mapped)

---

*End of Analysis*

