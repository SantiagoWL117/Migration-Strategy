# Duplicate Dishes Diagnostic Report

**Date:** December 30, 2024  
**Database:** `menuca_v3`  
**Status:** 📊 ANALYSIS COMPLETE - ACTION REQUIRED

---

## Executive Summary

Following the Milano duplicate cleanup, a comprehensive scan of the entire database reveals **significant remaining duplicates** across 70 restaurants. However, most appear to be **legitimate business patterns** rather than true data errors.

### Key Metrics

| Metric | Count |
|--------|-------|
| Total duplicate dish pairs | 587 |
| Restaurants with duplicates | 70 |
| Unique dish names with duplicates | 430 |

---

## 🎯 Classification by Price Pattern

| Pattern | Count | Action |
|---------|-------|--------|
| **DIFFERENT PRICE** - Likely Legitimate | 393 (67%) | ✅ KEEP |
| **SIMILAR PRICE** (<$1 diff) - Review | 124 (21%) | ⚠️ REVIEW |
| **SAME PRICE** - Likely True Duplicate | 65 (11%) | 🔴 CLEANUP |

### Interpretation

- **393 duplicates (67%)** have different prices → These are intentional (e.g., "Pepperoni Pizza" in "Single Pizza" at $12.99 vs "Twin Pizzas" at $19.99)
- **124 duplicates (21%)** have prices within $1 → May be rounding differences or need review
- **65 duplicates (11%)** have identical prices → These are likely TRUE duplicates to clean up

---

## 📍 Duplicates by Pattern Type

| Pattern | Count | Description |
|---------|-------|-------------|
| Other Pattern | 294 | General duplicates - need individual review |
| Twin/2-for-1 Pattern | 99 | Same dish in "Single" and "Twin" courses - **LIKELY LEGITIMATE** |
| Milano Fantino Pattern | 68 | Milano "PIZZAS WITH FANTINO MONDELLO PANCETTA" pattern |
| Unlisted Dishes Pattern | 64 | Dishes appearing in both regular and "Unlisted" courses |
| Features/Specials Pattern | 57 | Same dish in regular menu and "Features/Specials" section |

---

## 🏪 Restaurants with Most Duplicates

### Chain-Level Summary

| Chain | Locations Affected | Total Extra Records |
|-------|-------------------|---------------------|
| **Crispy's** | 2 | 240 |
| **Papa Pizza** | 5 | ~174 |
| **Milano** | 30+ | ~300 |
| **Other restaurants** | 33 | ~260 |

### Top 15 Individual Restaurants

| Restaurant | Duplicate Dish Names | Extra Records |
|------------|---------------------|---------------|
| Crispy's Bank Street | 12 | 120 |
| Crispy's | 12 | 120 |
| Lucky Star Chinese Food | 11 | 68 |
| Papa Pizza Des Flandres | 26 | 52 |
| La Maison du Burger | 4 | 48 |
| Papa Pizza Cantley | 21 | 42 |
| Kabylie Pizza | 21 | 42 |
| Papa Pizza Maloney | 20 | 40 |
| Papa Pizza Val-Des-Monts | 19 | 38 |
| Season's Pizza | 17 | 34 |
| Milano (various) | 15 | 34 |
| Vieux Hull Pizza | 16 | 32 |
| Erman Pizza | 15 | 30 |
| Oka's Hull | 14 | 28 |
| Little Gyros Greek Grill | 10 | 20 |

---

## 🔍 Pattern Analysis

### 1. Crispy's Pattern (240 records)
**Status:** ⚠️ NEEDS REVIEW

The Crispy's locations show "3 Pieces", "6 Pieces", etc. appearing in 4 different courses:
- Chunks of Boneless Fried Chicken
- Thighs of Boneless Fried Chicken
- Mixed Boneless Fried Chicken
- Chicken Tenders

**Question for Business:** Are these intentionally different products (different cuts) or duplicates?

### 2. Twin/2-for-1 Pizza Pattern (99 records)
**Status:** ✅ LIKELY LEGITIMATE

Common French pizzerias pattern:
- Same pizza name appears in "Pizza" and "Pizza 2 pour 1" / "L'ultime 2 Pour 1"
- Prices are different (single vs. twin deal pricing)

**Examples:** Kabylie Pizza, Papa Pizza locations, Erman Pizza

### 3. Milano Fantino Pattern (68 records)
**Status:** 🔴 LIKELY TRUE DUPLICATES

Same pizzas appearing in both:
- "PIZZAS WITH FANTINO MONDELLO PANCETTA" (feature section)
- "Pizza" (regular section)

Often with identical prices → **TRUE DUPLICATES to clean**

### 4. Features/Specials Pattern (57 records)
**Status:** ⚠️ NEEDS REVIEW

Same dish appearing in:
- Regular menu course
- "Features Of The Month" / "Daily Specials" section

May be intentional for visibility or may be duplicates.

### 5. Unlisted Dishes Pattern (64 records)
**Status:** 🔴 LIKELY TRUE DUPLICATES

Dishes appearing in both:
- Regular course
- "Unlisted Dishes" / "UNLISTED DISHES" course

These are often scraper artifacts and should be cleaned.

---

## 🛠️ Recommended Actions

### Immediate Cleanup (LOW RISK)
1. **Unlisted Dishes Pattern** - Delete dishes in "Unlisted" courses that duplicate regular menu items
2. **Milano Fantino Pattern** - Delete from FANTINO section, keep in regular Pizza section
3. **Same Price duplicates** - Clean up 65 identified true duplicates

### Review Required (MEDIUM RISK)
1. **Similar Price (<$1 diff)** - 124 pairs need manual review
2. **Features/Specials Pattern** - Confirm business intent before cleanup

### Do Not Touch (LEGITIMATE)
1. **Twin/2-for-1 Pattern** - These are intentional business logic
2. **Different Price duplicates** - 393 pairs representing legitimate price variations

---

## 📋 For Replit Dev Team

### What This Means for Apps

1. **No code changes required** - The apps will continue to work
2. **Duplicate items may show in menus** - This is a data quality issue, not app issue
3. **After cleanup, menus will be cleaner** - Fewer redundant items

### Expected Impact of Cleanup

| If We Clean | Records Affected |
|-------------|-----------------|
| Unlisted Dishes pattern | ~64 dishes |
| Same-price true duplicates | ~65 dishes |
| Milano Fantino pattern | ~68 dishes |
| **Total potential cleanup** | **~197 dishes** |

Plus associated:
- dish_prices
- dish_modifier_groups
- modifier_group_details
- dish_modifiers

### Verification Query (Run After Cleanup)

```sql
-- Check remaining duplicates
SELECT 
    r.name as restaurant_name,
    d.name as dish_name,
    COUNT(*) as count
FROM menuca_v3.dishes d
JOIN menuca_v3.restaurants r ON r.id = d.restaurant_id
WHERE d.deleted_at IS NULL AND d.is_active = true
GROUP BY r.id, r.name, d.name
HAVING COUNT(*) > 1
ORDER BY count DESC;
```

---

## Next Steps

1. [ ] Review this report with team
2. [ ] Clarify Crispy's pattern with business (are these different products?)
3. [ ] Create cleanup scripts for identified true duplicates
4. [ ] Execute cleanup in stages (one pattern at a time)
5. [ ] Verify with Replit team after each cleanup phase
6. [ ] Update BRIAN HANDOFF.md with cleanup status

---

## Files Reference

- **Previous cleanup:** `Scrapers/Menu Scrapers/logs/Milano Duplicate Cleanup Summary.md`
- **This report:** `Scrapers/Menu Scrapers/logs/DUPLICATE_DISHES_DIAGNOSTIC_REPORT.md`
- **Session summary:** `SESSION_SUMMARY_2025-12-19.md`

---

**Report Generated By:** Claude (Migration Agent)  
**Review Status:** Pending Team Review

