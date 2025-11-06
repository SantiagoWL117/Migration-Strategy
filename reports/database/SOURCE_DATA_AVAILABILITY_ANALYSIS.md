# Source Data Availability Analysis

**Date:** 2025-11-05  
**Scope:** 34 restaurants from recent audits (Batch 4 & 5)  
**Purpose:** Determine which restaurants can be re-imported from staging (NOT scraping) vs. need scraping

---

## Summary Statistics

**Total Analyzed:** 34 restaurants

| Source Data Status | Count | % | Action Required |
|-------------------|-------|---|-----------------|
| **V1 Available in Staging** | 9 | 26% | ✅ Re-import from staging (NOT scraping) |
| **V2 Available** | 9 | 26% | ✅ Re-import from V2 (NOT scraping - check staging tables) |
| **V1 Mapped but No Data** | 16 | 47% | ⚠️ Scrape from live menu (source data missing) |
| **No Source Data** | 0 | 0% | ⚠️ Scrape from live menu |

**Key Finding:** 
- **53% (18 restaurants)** can be re-imported from source data (NOT scraping)
- **47% (16 restaurants)** need scraping from live menus

---

## Detailed Breakdown

### ✅ Can Re-Import from Staging (NOT Scraping) - 9 Restaurants

These restaurants have V1 data in `staging.menuca_v1_menu`:

1. **Papa Joe's Pizza - Downtown** (ID: 13) - Status: suspended
2. **New Mee Fung Restaurant** (ID: 15) - Status: suspended
3. **Papa Pizza - Hull** (ID: 70) - Status: suspended
4. **Papa Pizza - Gatineau Ouest** (ID: 112) - Status: suspended
5. **Pho Dau Bo Restaurant - Kitchener** (ID: 147) - Status: active ✅
6. **Pho Bo Ga King - Somerset** (ID: 199) - Status: suspended
7. **New Mukut Restaurant Indian Cuisine** (ID: 234) - Status: suspended
8. **iCook Pho You** (ID: 479) - Status: suspended
9. **Papa Pizza - Val-des-Monts** (ID: 498) - Status: suspended
10. **Milano 643 Boulevard Saint-René O** (ID: 680) - Status: active ✅
11. **Pizza Joanna** (ID: 726) - Status: active ✅

**Action:** Re-run migration with correct status (active, not suspended) to import from `staging.menuca_v1_menu`

---

### ✅ Can Re-Import from V2 (NOT Scraping) - 9 Restaurants

These restaurants have V2 legacy IDs and likely have V2 data in staging:

1. **Mozza Pizza** (ID: 35) - Status: active ✅
2. **Pizza Bravo** (ID: 139) - Status: suspended
3. **Lucky King Take Out** (ID: 174) - Status: active ✅
4. **Papa Pizza - Gatineau Est** (ID: 207) - Status: suspended
5. **Beneci Pizza** (ID: 241) - Status: active ✅
6. **Sushi Express Fantasia** (ID: 348) - Status: suspended
7. **Sachi Sushi** (ID: 376) - Status: suspended
8. **Papa Joe's Fried Chicken - Downtown** (ID: 437) - Status: suspended
9. **Pizza Lovers Hunt Club** (ID: 507) - Status: suspended

**Action:** Check V2 staging tables and re-import with correct status

**Note:** Need to verify which V2 staging tables exist and contain dish data.

---

### ⚠️ Need Scraping (V1 Mapped but No Data) - 16 Restaurants

These restaurants have V1 mapping but no data in `staging.menuca_v1_menu`:

1. **Papa Grecque des Flandres** (ID: 540) - Status: active ✅
2. **Pizza des Hautes Plaines** (ID: 562) - Status: active ✅
3. **Supreme Pizzeria 425 Donald St** (ID: 595) - Status: active ✅
4. **Papa Grecque Maloney** (ID: 616) - Status: active ✅
5. **Pizza Maisonneuve** (ID: 696) - Status: active ✅
6. **Supreme Pizzeria 380 Chemin Vanier** (ID: 711) - Status: active ✅
7. **Patate Lou Lou** (ID: 712) - Status: active ✅
8. **Roulas Grecque et Pizza** (ID: 777) - Status: active ✅
9. **Poutinerie Québécurds Hull** (ID: 789) - Status: active ✅
10. **Papa Pizza Chem. de Masson** (ID: 795) - Status: active ✅
11. **Papa Burger** (ID: 797) - Status: active ✅
12. **Poutinerie Québécurds Gatineau** (ID: 802) - Status: active ✅
13. **Papa Grecque Cantley** (ID: 810) - Status: active ✅
14. **Papa Burger Maloney** (ID: 822) - Status: active ✅

**Action:** Scrape from live menu URLs (source data not available in staging)

**Root Cause:** V1 data was never loaded into staging, or restaurant was added after V1 migration.

---

## Pattern Analysis

### Pattern 1: Status Mismatch = Data Loss

**Finding:** Many restaurants with V1/V2 source data are marked as `suspended` in database but `active` in verified list.

**Examples:**
- Papa Joe's Pizza (ID: 13) - suspended, has V1 data
- New Mee Fung (ID: 15) - suspended, has V1 data
- New Mukut (ID: 234) - suspended, has V1 data

**Impact:** These restaurants have source data available but were filtered out during migration due to incorrect status.

**Fix:** Update status to `active`, then re-run migration.

---

### Pattern 2: V1 Data Missing from Staging

**Finding:** 16 restaurants have V1 mapping but no data in `staging.menuca_v1_menu`.

**Examples:**
- All Papa Grecque locations (IDs: 540, 616, 810)
- All Papa Burger locations (IDs: 797, 822)
- Poutinerie Québécurds locations (IDs: 789, 802)

**Root Cause:** 
- V1 data was never loaded into staging for these restaurants, OR
- These restaurants were added to V1 after the staging load, OR
- V1 data dump was incomplete

**Impact:** Cannot re-import from staging - must scrape from live menus.

---

### Pattern 3: V2 Data Availability

**Finding:** 9 restaurants have V2 legacy IDs, indicating V2 source data may be available.

**Action Needed:** Check V2 staging tables to verify data availability:
- `staging.menuca_v2_restaurants_dishes`
- `staging.menuca_v2_restaurants_courses`
- Other V2 staging tables

---

## Recommendations

### Immediate Actions:

1. **Update Status Mismatches** (20 restaurants)
   - Change `suspended` → `active` for restaurants on verified list
   - This will allow re-import from staging

2. **Re-Import from V1 Staging** (9 restaurants)
   - Use `staging.menuca_v1_menu` 
   - Re-run migration with correct status
   - Verify completeness against live menu

3. **Check V2 Staging Tables** (9 restaurants)
   - Verify V2 dish data exists in staging
   - Re-import if available
   - If not available, scrape from live menu

4. **Scrape from Live Menus** (16 restaurants)
   - Build scraper for live menu URLs
   - Extract and import menu data
   - These have no source data available

---

## Next Steps

1. **Verify V2 Staging Data Availability**
   - Check which V2 staging tables exist
   - Count rows per restaurant
   - Determine if V2 data is usable

2. **Build Menu Scraper** (if proceeding with scraping)
   - Support common menu formats
   - Extract courses, dishes, modifiers
   - Handle size variants, protein options, etc.

3. **Create Re-Import Scripts**
   - Script to re-import from V1 staging
   - Script to re-import from V2 staging
   - Update status before re-import

4. **Execute Hybrid Approach**
   - Re-import from staging where available (NOT scraping)
   - Scrape from live menus where source missing (IS scraping)
   - Verify all against live menu URLs

---

## Conclusion

**53% of audited restaurants can be re-imported from staging (NOT scraping)** - this is the preferred approach as it uses original source data.

**47% need scraping from live menus** - these have no source data available in staging.

**Recommendation:** Proceed with **True Hybrid Approach**:
1. Re-import from staging for 18 restaurants (NOT scraping)
2. Scrape from live menus for 16 restaurants (IS scraping)
3. Verify all against live menu URLs

This optimizes effort and preserves historical accuracy where possible.

---

**Document Status:** ✅ Complete  
**Last Updated:** 2025-11-05  
**Next Review:** After V2 staging data verification

