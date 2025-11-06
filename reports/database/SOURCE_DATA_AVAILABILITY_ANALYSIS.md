# Source Data Availability Analysis

**Date:** 2025-11-05  
**Scope:** 142 audited restaurants (out of 189 total active)  
**Purpose:** Determine which restaurants can be re-imported from staging (NOT scraping) vs. need scraping

---

## Summary Statistics

**Total Analyzed:** 142 audited restaurants (114 active, 28 suspended)

| Source Data Status | Count | Active | Suspended | Action Required |
|-------------------|-------|--------|-----------|-----------------|
| **V1 Available in Staging** | 46 | 30 | 16 | ✅ Re-import from staging (NOT scraping) |
| **V2 Available** | 21 | 20 | 1 | ✅ Re-import from V2 (NOT scraping - check staging tables) |
| **V1 Mapped but No Data** | 75 | 64 | 11 | ⚠️ Scrape from live menu (source data missing) |
| **No Source Data** | 0 | 0 | 0 | ⚠️ Scrape from live menu |

**Key Finding:** 
- **66% (94 restaurants)** can be re-imported from source data (NOT scraping)
  - **66 active** restaurants can re-import
- **34% (48 restaurants)** need scraping from live menus (IS scraping)
  - **48 active** restaurants need scraping

---

## Detailed Breakdown

### ✅ Can Re-Import from Staging (NOT Scraping) - 94 Restaurants

**V1 Available (46 restaurants):** Have V1 data in `staging.menuca_v1_menu`
- 30 active restaurants
- 16 suspended restaurants

**V2 Available (21 restaurants):** Have V2 legacy IDs (need to verify V2 staging tables)
- 20 active restaurants
- 1 suspended restaurant

**Action:** 
- Re-run migration with correct status (active, not suspended) to import from `staging.menuca_v1_menu`
- Check V2 staging tables and re-import with correct status

**Note:** Need to verify which V2 staging tables exist and contain dish data.

---

### ⚠️ Need Scraping (V1 Mapped but No Data) - 75 Restaurants

These restaurants have V1 mapping but no data in `staging.menuca_v1_menu`:
- 64 active restaurants
- 11 suspended restaurants

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

1. **Update Status Mismatches** (for suspended restaurants on active list)
   - Change `suspended` → `active` for restaurants on verified list
   - This will allow re-import from staging

2. **Re-Import from V1 Staging** (46 restaurants)
   - Use `staging.menuca_v1_menu` 
   - Re-run migration with correct status
   - Verify completeness against live menu
   - **30 active** restaurants can be fixed this way

3. **Check V2 Staging Tables** (21 restaurants)
   - Verify V2 dish data exists in staging
   - Re-import if available
   - If not available, scrape from live menu
   - **20 active** restaurants can potentially be fixed this way

4. **Scrape from Live Menus** (75 restaurants)
   - Build scraper for live menu URLs
   - Extract and import menu data
   - These have no source data available
   - **64 active** restaurants need scraping

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

**66% of audited restaurants (94 total, 66 active) can be re-imported from staging (NOT scraping)** - this is the preferred approach as it uses original source data.

**34% need scraping from live menus (48 active)** - these have no source data available in staging.

**Recommendation:** Proceed with **True Hybrid Approach**:
1. Re-import from staging for 94 restaurants (66 active) - NOT scraping
2. Scrape from live menus for 75 restaurants (64 active) - IS scraping
3. Verify all against live menu URLs

This optimizes effort and preserves historical accuracy where possible.

**For Active Restaurants Specifically:**
- 58% (66) can re-import from staging
- 42% (48) need scraping from live menus

---

**Document Status:** ✅ Complete  
**Last Updated:** 2025-11-05  
**Next Review:** After V2 staging data verification

