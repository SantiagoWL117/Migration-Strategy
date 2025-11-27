# V1 Restaurants Data Integrity Verification Report

**Date:** 2025-11-20  
**Total V1 Restaurants Verified:** 166

---

## Executive Summary

✅ **Overall Status:** Data integrity is **GOOD** with minor issues identified.

| Metric | Count | Percentage |
|--------|-------|------------|
| Total V1 Restaurants | 166 | 100% |
| Restaurants with Courses | 163 | 98.2% |
| Restaurants with Dishes | 163 | 98.2% |
| Restaurants with Dish Prices | 162 | 97.6% |

---

## Issues Identified

### 🔴 CRITICAL ISSUES

#### 1. Restaurants WITHOUT Courses (3 restaurants)
- **All Out Burger Bank St.** (ID: 924)
- **All Out Burger Gladstone** (ID: 948)
- **All Out Burger Montreal Rd** (ID: 949)

**Status:** These 3 All Out Burger locations have NO data at all (0 courses, 0 dishes, 0 prices)

#### 2. Restaurants WITHOUT Dishes (3 restaurants)
Same as above - the 3 All Out Burger locations

#### 3. Restaurants WITH Dishes but NO Prices (1 restaurant)
- **Riverside Pizzeria** (ID: 133)
  - Has 16 courses
  - Has 119 dishes
  - Has **0 prices** ❌

---

### ⚠️ MINOR ISSUES

#### 1. Restaurants with Suspiciously Low Prices
Several restaurants have very few prices relative to their dish count:

| Restaurant | ID | Dishes | Prices | Issue |
|------------|-----|--------|--------|-------|
| **Aroy Thai** | 607 | 39 | 12 | Only 30.8% of dishes have prices |
| **Milano - 2 Pembroke** | 265 | 150 | 29 | Only 19.3% of dishes have prices |

---

### ✅ GOOD NEWS

#### No Orphan Data Found!
- ✅ No orphan courses (all courses have valid restaurants)
- ✅ No orphan dishes (all dishes have valid restaurants)
- ✅ No orphan dish prices (all prices have valid dishes)

---

## Detailed Findings

### Restaurants WITHOUT ANY Data (0 courses, 0 dishes, 0 prices)
1. **All Out Burger Bank St.** (ID: 924) - 2560 Bank Street
2. **All Out Burger Gladstone** (ID: 948) - 714 Gladstone Ave
3. **All Out Burger Montreal Rd** (ID: 949) - 585 Montreal Road

**Note:** These locations appear to be completely empty in the database. This suggests they may be:
- Recently added locations that haven't been imported yet
- Closed locations that had their data removed
- Data migration issues

### Restaurants with Dishes but NO Prices
1. **Riverside Pizzeria** (ID: 133) - 3679 Riverside Dr
   - 16 courses
   - 119 dishes
   - **0 prices** ❌

**Impact:** Without prices, these dishes cannot be displayed or ordered.

### Restaurants with Very Few Prices
1. **Aroy Thai** (ID: 607) - 1 Rideaucrest Drive
   - 39 dishes, only 12 prices (30.8%)
   
2. **Milano - 2 Pembroke** (ID: 265) - 2 Pembroke St ( Highway 17 )
   - 150 dishes, only 29 prices (19.3%)

---

## Restaurant Data Health by Category

### Excellent (>200 dishes with prices)
- Joes Family Pizzeria (ID: 636): 371 dishes, 678 prices
- Dépanneur Généreux (ID: 816): 863 dishes, 863 prices
- Milano - 2 Woodfield (ID: 651): 321 dishes, 674 prices
- Milano - 643 Boulevard Saint-René O (ID: 680): 308 dishes, 646 prices
- Milano - 2529 Baseline (ID: 569): 299 dishes, 629 prices

### Good (50-200 dishes with prices)
- 143 restaurants fall into this category
- Average: ~150 dishes with ~250 prices per restaurant

### Needs Attention (<50 dishes or low price ratio)
- 3 All Out Burger locations: 0 data
- 1 Riverside Pizzeria: 0 prices
- 2 restaurants with low price ratios (Aroy Thai, Milano - 2 Pembroke)

---

## Recommendations

### Immediate Actions Required

1. **Fix Critical Issues (3 All Out Burger + 1 Riverside Pizzeria)**
   ```sql
   -- These restaurants need data populated:
   -- ID 924: All Out Burger Bank St.
   -- ID 948: All Out Burger Gladstone
   -- ID 949: All Out Burger Montreal Rd
   -- ID 133: Riverside Pizzeria (has dishes, needs prices)
   ```

2. **Investigate Low Price Ratios**
   - Verify Aroy Thai (ID: 607) - only 12 prices for 39 dishes
   - Verify Milano - 2 Pembroke (ID: 265) - only 29 prices for 150 dishes

### Data Integrity Status for Scraper

**Ready to Proceed:** ✅ **YES**

The V1 scraper should:
1. ✅ **Skip** the 3 All Out Burger locations (924, 948, 949) - they need initial data setup
2. ⚠️ **Priority scrape** Riverside Pizzeria (ID: 133) - it has dishes but no prices
3. 🔍 **Verify** Aroy Thai (ID: 607) and Milano - 2 Pembroke (ID: 265) during scraping
4. ✅ **Proceed normally** with the remaining 161 restaurants

---

## Data Quality Metrics

### Overall Data Completeness
- **Courses Coverage:** 98.2% (163/166)
- **Dishes Coverage:** 98.2% (163/166)
- **Prices Coverage:** 97.6% (162/166)

### Data Integrity
- **Orphan Courses:** 0 ✅
- **Orphan Dishes:** 0 ✅
- **Orphan Prices:** 0 ✅
- **Referential Integrity:** EXCELLENT ✅

---

## Next Steps for V1 Scraper

1. **Exclude from scraping:**
   - All Out Burger Bank St. (ID: 924)
   - All Out Burger Gladstone (ID: 948)
   - All Out Burger Montreal Rd (ID: 949)

2. **High Priority scraping:**
   - Riverside Pizzeria (ID: 133) - needs prices

3. **Verify during scraping:**
   - Aroy Thai (ID: 607)
   - Milano - 2 Pembroke (ID: 265)

4. **Proceed normally:**
   - Remaining 161 restaurants

---

**Report Generated:** 2025-11-20  
**Script:** `verify_data_integrity.py`  
**Database:** `menuca_v3` on Supabase




