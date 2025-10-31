# Duplicate Dish Names Analysis

**Date:** 2025-10-30  
**Status:** 📊 **ANALYZED**  
**Source:** Action Plan Item #5

---

## Executive Summary

Found multiple duplicate dish names within restaurants. Analysis shows:
- **Intentional duplicates:** Same name in different courses (acceptable)
- **Potential issues:** Same name, NULL course_id, same restaurant (may be true duplicates)
- **Recommendation:** Review duplicates with NULL course_id for possible merge/rename

---

## Analysis Results

### Top Duplicates Found

**Restaurant 806 (Chicken restaurant):**
- "3 Pieces" - 4 duplicates, all NULL course_id
- "6 Pieces" - 4 duplicates, all NULL course_id
- "10 Pieces" - 4 duplicates, all NULL course_id
- "12 Pieces" - 4 duplicates, all NULL course_id
- All combos also have 4 duplicates each

**Pattern:** Restaurant 806 has systematic duplicates - likely different menu locations or time periods

**Restaurant 847:**
- "Unagi" - 4 duplicates, all NULL course_id

**Restaurant 523:**
- "Black Cod with Miso HIDE" - 3 duplicates, all same course_id (1471)
- ✅ **Acceptable** - Same course, may be different sizes (should use size_variant)

**Restaurant 42:**
- "French Fries" - 2 duplicates, different course_ids (379, 1420)
- ✅ **Acceptable** - Different courses (Appetizers vs Sides)

**Restaurant 65:**
- "Cantonese Style Sweet and Sour Pork" - 2 duplicates, different course_ids (417, 1832)
- ✅ **Acceptable** - Different courses

---

## Categorization

### ✅ Intentional Duplicates (Acceptable)
- Same name in **different courses** → Acceptable (e.g., "French Fries" in Appetizers and Sides)
- Same name in **same course**, different sizes → Should use `size_variant` in `dish_prices`

### ⚠️ Potential Issues (Need Review)
- Same name, **NULL course_id**, same restaurant → May be true duplicates
- Example: Restaurant 806 has 4 "3 Pieces" dishes, all NULL course_id

---

## Recommendations

### For True Duplicates (NULL course_id, same restaurant)
1. **Investigate:** Check if these are:
   - Different menu locations/locations
   - Historical versions (old vs new)
   - Different time periods (breakfast vs dinner)
   - Accidental duplicates

2. **Action Options:**
   - **If different locations:** Add location_id to distinguish
   - **If historical:** Keep one active, mark others as inactive
   - **If accidental:** Merge duplicates or rename

3. **Prevention:**
   - Consider adding composite unique constraint: `(restaurant_id, name, course_id)` 
   - This allows same name in different courses but prevents true duplicates

### For Size Variants
- If duplicates represent different sizes, ensure they use `dish_prices.size_variant` properly
- Consider using `dish_size_options` table for size metadata

---

## Query to Find True Duplicates

```sql
-- Find duplicates that may be true duplicates (same name, NULL course_id, same restaurant)
SELECT 
    restaurant_id,
    name,
    COUNT(*) as duplicate_count,
    ARRAY_AGG(id ORDER BY id) as dish_ids,
    ARRAY_AGG(created_at ORDER BY id) as created_dates
FROM menuca_v3.dishes
WHERE deleted_at IS NULL
  AND course_id IS NULL  -- Focus on NULL course_id duplicates
GROUP BY restaurant_id, name
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC, restaurant_id, name;
```

---

## Business Rule Recommendation

**Proposed Rule:**
- ✅ Same dish name in **different courses** → Acceptable
- ✅ Same dish name with **different sizes** → Use `size_variant` in `dish_prices`
- ⚠️ Same dish name, **NULL course_id**, same restaurant → Needs review

**Consider:** Adding database constraint to prevent true duplicates:
```sql
-- Optional: Prevent true duplicates (allows same name in different courses)
ALTER TABLE menuca_v3.dishes
ADD CONSTRAINT dishes_unique_name_per_restaurant_course 
UNIQUE (restaurant_id, name, course_id);
```

**Note:** This constraint allows NULL course_id duplicates (multiple NULLs are considered distinct in UNIQUE constraints). If you want to prevent NULL duplicates, need a partial unique index.

---

**Analysis Date:** 2025-10-30  
**Status:** Ready for business decision on duplicate handling strategy

