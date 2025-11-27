# V1 Restaurants Scraping Strategy

**Date:** 2025-11-20  
**Based on:** Data Integrity Verification Results  
**Total V1 Restaurants:** 166

---

## Executive Summary

After comprehensive data integrity verification of all 166 V1 restaurants, we have categorized them into different scraping strategies based on their current data state.

| Category | Count | Action |
|----------|-------|--------|
| **Ready for Modifier Scraping** | 162 | Proceed with standard V1 scraper |
| **Requires Different Scraper** | 4 | Use alternative scraper (complete data missing) |
| **Total** | 166 | - |

---

## 🟢 Category 1: Ready for Standard V1 Modifier Scraping

**Count:** 162 restaurants  
**Status:** These restaurants have complete courses, dishes, and dish_prices data  
**Action:** Proceed with standard V1 scraper to extract modifiers and modifier prices

### Included Restaurants (162)

All 166 V1 restaurants **EXCEPT** the 4 listed in Category 2 below.

#### Notable Inclusions:

**Riverside Pizzeria (ID: 133)**
- **Status:** Has 119 dishes but 0 prices currently
- **Decision:** INCLUDE in standard V1 scraper
- **Reason:** Can be scraped normally for modifiers; price data will be populated during scraping process
- **Data:** 16 courses, 119 dishes, 0 prices (needs prices)

**Milano - 2 Pembroke (ID: 265)**
- **Status:** Has 150 dishes with only 29 prices (19.3% coverage)
- **Decision:** INCLUDE in standard V1 scraper
- **Reason:** Has base structure; can extract modifiers normally
- **Data:** 20 courses, 150 dishes, 29 prices (low ratio but functional)

---

## 🔴 Category 2: Requires Different Scraper (Complete Re-scrape)

**Count:** 4 restaurants  
**Status:** Missing ALL data (courses, dishes, prices)  
**Action:** Use alternative scraper for complete menu import

### Restaurants Requiring Different Scraper

#### 1. Aroy Thai
- **ID:** 607
- **Address:** 1 Rideaucrest Drive
- **Current Data:** 9 courses, 39 dishes, 12 prices (30.8% coverage)
- **Issue:** Extremely low price coverage suggests incomplete initial scrape
- **Required Action:** Complete re-scrape using different scraper

#### 2. All Out Burger Bank St.
- **ID:** 924
- **Address:** 2560 Bank Street
- **Current Data:** 0 courses, 0 dishes, 0 prices
- **Issue:** No data exists in database
- **Required Action:** Complete menu scrape using different scraper

#### 3. All Out Burger Gladstone
- **ID:** 948
- **Address:** 714 Gladstone Ave
- **Current Data:** 0 courses, 0 dishes, 0 prices
- **Issue:** No data exists in database
- **Required Action:** Complete menu scrape using different scraper

#### 4. All Out Burger Montreal Rd
- **ID:** 949
- **Address:** 585 Montreal Road
- **Current Data:** 0 courses, 0 dishes, 0 prices
- **Issue:** No data exists in database
- **Required Action:** Complete menu scrape using different scraper

---

## Implementation Plan

### Phase 1: Standard V1 Modifier Scraper

**Target:** 162 restaurants  
**Scope:** Extract modifiers and modifier prices only

**Tables to Populate:**
- `menuca_v3.modifier_groups`
- `menuca_v3.dish_modifiers`
- `menuca_v3.dish_modifier_prices`

**Prerequisites:**
- ✅ Existing courses data
- ✅ Existing dishes data
- ✅ Existing dish_prices data (or will be populated during scraping)

**Mapping File:** `v1_v3_id_mapping.csv`

**Excluded IDs:**
```
607, 924, 948, 949
```

**SQL Filter for Standard Scraper:**
```sql
WHERE restaurant_id IN (
    SELECT v3_id FROM v1_v3_id_mapping
    WHERE v3_id NOT IN (607, 924, 948, 949)
)
```

### Phase 2: Alternative Scraper for Complete Menu Import

**Target:** 4 restaurants  
**Scope:** Complete menu scrape (courses, dishes, prices, modifiers)

**Tables to Populate:**
- `menuca_v3.courses`
- `menuca_v3.dishes`
- `menuca_v3.dish_prices`
- `menuca_v3.modifier_groups`
- `menuca_v3.dish_modifiers`
- `menuca_v3.dish_modifier_prices`

**Restaurants:**
| ID | Name | Address |
|----|------|---------|
| 607 | Aroy Thai | 1 Rideaucrest Drive |
| 924 | All Out Burger Bank St. | 2560 Bank Street |
| 948 | All Out Burger Gladstone | 714 Gladstone Ave |
| 949 | All Out Burger Montreal Rd | 585 Montreal Road |

---

## Scraper Configuration

### Standard V1 Modifier Scraper Config

```python
# Configuration for standard V1 modifier scraper
SCRAPER_CONFIG = {
    'name': 'V1_Modifier_Scraper',
    'target_restaurants': 162,
    'excluded_ids': [607, 924, 948, 949],
    'scope': 'modifiers_only',
    'tables': [
        'menuca_v3.modifier_groups',
        'menuca_v3.dish_modifiers',
        'menuca_v3.dish_modifier_prices'
    ],
    'prerequisites': {
        'courses': True,
        'dishes': True,
        'dish_prices': True  # Will be populated if missing
    }
}
```

### Alternative Scraper Config

```python
# Configuration for complete menu scraper
ALTERNATIVE_SCRAPER_CONFIG = {
    'name': 'V1_Complete_Menu_Scraper',
    'target_restaurants': 4,
    'included_ids': [607, 924, 948, 949],
    'scope': 'complete_menu',
    'tables': [
        'menuca_v3.courses',
        'menuca_v3.dishes',
        'menuca_v3.dish_prices',
        'menuca_v3.modifier_groups',
        'menuca_v3.dish_modifiers',
        'menuca_v3.dish_modifier_prices'
    ],
    'prerequisites': {
        'courses': False,
        'dishes': False,
        'dish_prices': False
    }
}
```

---

## Data Validation Checkpoints

### Before Scraping
- [x] Verify V1 ID mappings exist for all restaurants
- [x] Confirm database connectivity
- [x] Validate existing data structure
- [x] Identify restaurants requiring different scraper

### During Scraping
- [ ] Log restaurants with scraping errors
- [ ] Track modifier extraction counts
- [ ] Monitor for duplicate data
- [ ] Validate price formats

### After Scraping
- [ ] Verify modifier data for all 162 restaurants
- [ ] Check for orphan modifiers
- [ ] Validate price completeness
- [ ] Generate scraping summary report

---

## Success Criteria

### Standard V1 Modifier Scraper
- ✅ Successfully scrape modifiers for 162 restaurants
- ✅ No orphan modifier data created
- ✅ All modifier prices properly linked to dishes
- ✅ Riverside Pizzeria (133) has prices populated
- ✅ Milano - 2 Pembroke (265) has improved price coverage

### Alternative Scraper (Future)
- ⏳ Complete menu data for Aroy Thai (607)
- ⏳ Complete menu data for All Out Burger Bank St. (924)
- ⏳ Complete menu data for All Out Burger Gladstone (948)
- ⏳ Complete menu data for All Out Burger Montreal Rd (949)

---

## Restaurant Lists for Scraper Implementation

### Standard V1 Scraper - Restaurant IDs (162 restaurants)

```python
# Complete list of restaurant IDs for standard V1 modifier scraper
V1_MODIFIER_SCRAPER_IDS = [
    7, 8, 12, 13, 15, 22, 28, 31, 44, 45, 47, 48, 55, 57, 59, 62, 65, 69, 70, 72,
    75, 77, 83, 84, 87, 88, 89, 90, 91, 92, 93, 95, 97, 105, 106, 109, 118, 119, 
    123, 124, 126, 131, 133, 139, 143, 147, 160, 174, 180, 190, 196, 199, 205, 
    211, 234, 241, 245, 265, 267, 269, 328, 349, 350, 367, 376, 437, 479, 491, 
    497, 502, 507, 511, 515, 519, 521, 540, 561, 562, 565, 569, 584, 586, 593, 
    595, 596, 601, 602, 607, 614, 616, 624, 630, 636, 638, 641, 644, 646, 651, 
    660, 680, 681, 696, 701, 711, 712, 714, 715, 716, 721, 726, 727, 730, 735, 
    736, 745, 749, 751, 756, 783, 784, 785, 789, 790, 792, 795, 797, 798, 801, 
    806, 807, 810, 815, 816, 818, 819, 820, 821, 822, 824, 829, 833, 835, 836, 
    837, 840, 841, 842, 845, 846, 847, 935, 941, 943, 984, 985, 1009, 1010, 1011, 
    1012, 1013, 1014, 1015, 1016, 1017
]
# Total: 162 restaurants
```

### Alternative Scraper - Restaurant IDs (4 restaurants)

```python
# Restaurant IDs requiring complete menu scrape with alternative scraper
V1_COMPLETE_SCRAPER_IDS = [
    607,   # Aroy Thai
    924,   # All Out Burger Bank St.
    948,   # All Out Burger Gladstone
    949    # All Out Burger Montreal Rd
]
# Total: 4 restaurants
```

---

## Notes and Considerations

### Riverside Pizzeria (ID: 133) - Special Case
- Currently has 119 dishes with 0 prices
- **Decision:** Include in standard scraper
- **Reasoning:** The standard V1 scraper can populate prices during the modifier extraction process
- **Expected Outcome:** After scraping, should have both prices and modifiers populated

### Milano - 2 Pembroke (ID: 265) - Monitoring Required
- Has 150 dishes with only 29 prices (19.3%)
- **Decision:** Include in standard scraper
- **Reasoning:** Low price ratio likely due to many dishes without individual pricing (combo items, etc.)
- **Action:** Monitor during scraping to ensure modifier extraction works correctly

### Aroy Thai (ID: 607) - Requires Investigation
- Has minimal data (only 30.8% of dishes have prices)
- **Decision:** Use different scraper
- **Reasoning:** Low coverage suggests the original import was incomplete or failed
- **Recommended Action:** Investigate why original scrape failed before re-scraping

### All Out Burger Locations - Complete Re-import Needed
- Three locations have absolutely no data (0 courses, 0 dishes, 0 prices)
- **Possible Causes:**
  1. Never imported into menuca_v3
  2. Data was deleted
  3. These are new locations not yet added to V1 system
- **Recommended Action:** Verify if these locations exist in the V1 CRM before attempting to scrape

---

## Timeline

1. **Phase 1 (Current):** Standard V1 Modifier Scraper
   - Target: 162 restaurants
   - Duration: TBD
   - Priority: High

2. **Phase 2 (Future):** Alternative Complete Menu Scraper
   - Target: 4 restaurants
   - Duration: TBD
   - Priority: Medium (after Phase 1 completion)

---

## Related Documents

- **Data Integrity Report:** `DATA_INTEGRITY_REPORT.md`
- **V1 Scraper Documentation:** `V1_SCRAPER.md`
- **Mapping File:** `v1_v3_id_mapping.csv`
- **Verification Script:** `verify_data_integrity.py`

---

**Document Version:** 1.0  
**Last Updated:** 2025-11-20  
**Status:** Active - Ready for Implementation

