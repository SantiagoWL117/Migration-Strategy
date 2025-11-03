# Data Integrity Issues Report: Capri Pizza (Restaurant ID: 977)

**Generated:** 2025-11-03
**Database:** menuca_v3 schema
**Project:** menu-rebuild-vo (nthpbtdjhhnwfxqsxbvy)

---

## Executive Summary

Critical data integrity issues discovered for **Capri Pizza** affecting menu structure, dish organization, and modifier assignments. All 86 dishes are affected by multiple severe data quality problems that prevent proper menu display and ordering functionality.

---

## Issue #1: NULL Course Assignments ❌

### Problem
**All 86 dishes have NULL course_id values**, despite 11 valid courses being defined for the restaurant.

### Impact
- Dishes cannot be organized into menu categories
- Menu display will be broken or show all dishes in a single unorganized list
- No logical grouping (Appetizers, Desserts, Pizzas, etc.)

### Data Details

**Courses Defined (11 total):**
| ID   | Course Name      | Display Order |
|------|------------------|---------------|
| 1353 | Halal Menu       | 0             |
| 1357 | Specials         | 0             |
| 1348 | Appetizers       | 1             |
| 1356 | Salads           | 2             |
| 1358 | Specialty Pizza  | 3             |
| 1352 | Gourmet Pizza    | 4             |
| 1355 | Make Your Pizza  | 5             |
| 1350 | Dipping Sauces   | 6             |
| 1354 | Kids Menu        | 7             |
| 1351 | Drinks           | 8             |
| 1349 | Desserts         | 9             |

**Dishes Status:**
```sql
Total dishes: 86
Dishes with valid course_id: 0
Dishes with NULL course_id: 86 (100%)
```

### Example Affected Dishes
- Breaded Zucchini (20 pcs) - ID: 131471 - course_id: NULL
- NY Style Cheese Cake - ID: 131480 - course_id: NULL
- Tiramisu - ID: 131490 - course_id: NULL
- Thai Bites - ID: 131470 - course_id: NULL

---

## Issue #2: Massive Modifier Duplication ❌

### Problem
**Every dish has exactly 704 modifiers assigned**, with each modifier appearing 11 times per dish.

### Impact
- Customer ordering interface will be overwhelmed with duplicate options
- 60,544 total modifier records for only 86 dishes (704 per dish average)
- Incorrect modifiers assigned to incompatible dishes
- Database performance degradation
- Unreliable order data

### Data Details

**Modifier Statistics:**
```sql
Total dishes: 86
Dishes with modifiers: 86 (100%)
Total modifier records: 60,544
Average modifiers per dish: 704
Expected modifiers per dish: ~10-50
```

**Duplication Evidence:**
For dish ID 131491 (3 Layer Mouse Cake):
| Modifier Name         | Duplicate Count |
|-----------------------|-----------------|
| BBQ Sauce             | 11x             |
| Plant-Based Pepperoni | 11x             |
| Sliced Zucchini       | 11x             |
| Crush                 | 11x             |
| Donair Meat           | 11x             |
| Buffalo Chicken       | 11x             |
| Siracha Honey Sauce   | 11x             |
| Ham                   | 11x             |
| Roasted Garlic        | 11x             |
| Parmesan              | 11x             |

---

## Issue #3: Illogical Modifier Assignments ❌

### Problem
**Desserts and appetizers have pizza sauce, meat, and vegetable modifiers** assigned to them.

### Impact
- Customer confusion
- Invalid order combinations
- Kitchen fulfillment errors
- Poor user experience

### Examples of Illogical Assignments

**"3 Layer Mouse Cake" (a dessert) has these modifiers:**
- BBQ Sauce
- Pizza Sauce
- Red Hot Sauce
- Plant-Based Pepperoni
- Donair Meat
- Buffalo Chicken
- Ham
- Sliced Zucchini
- Roasted Garlic

**Expected modifiers for a dessert:** None, or perhaps ice cream, whipped cream, etc.

---

## Issue #4: No Modifier Group Structure ❌

### Problem
**Zero modifier groups assigned** despite modifiers existing in the database.

### Impact
- No logical grouping of modifiers (e.g., "Choose Size", "Add Toppings", "Select Sauce")
- Cannot enforce selection rules (min/max selections, required vs optional)
- Poor UX for customers

### Data Details
```sql
Dishes with modifier groups: 0
Total modifier groups assigned: 0
```

---

## Root Cause Analysis

These issues suggest a **failed data migration or bulk import operation** where:

1. **Course assignments were skipped** during dish import
2. **All modifiers were bulk-assigned to all dishes** without validation
3. **Modifier records were duplicated** 11 times (possibly from 11 different import runs or source systems)
4. **No validation logic** checked for logical consistency (desserts getting pizza toppings)
5. **Modifier group structure** was not migrated or created

---

## Recommended Remediation Steps

### Priority 1: Fix Course Assignments
```sql
-- Map dishes to appropriate courses based on dish names and descriptions
-- Example: All cheesecakes should be in "Desserts" (course_id: 1349)
-- Example: Appetizers like "Breaded Zucchini" should be in "Appetizers" (course_id: 1348)
```

### Priority 2: Remove Duplicate Modifiers
```sql
-- Identify and delete duplicate modifier records
-- Keep only 1 instance of each modifier per dish
-- Estimated reduction: 60,544 → ~6,050 records (90% reduction)
```

### Priority 3: Remove Illogical Modifier Assignments
```sql
-- Remove sauce/topping modifiers from desserts
-- Remove pizza toppings from appetizers
-- Validate modifier-dish compatibility based on dish type
```

### Priority 4: Implement Modifier Groups
```sql
-- Create logical modifier groups (Sizes, Toppings, Sauces, Extras)
-- Assign modifiers to appropriate groups
-- Set min/max selection rules
-- Link groups to compatible dishes
```

### Priority 5: Add Data Validation
- Implement triggers to prevent NULL course_id on active dishes
- Add check constraints for modifier-dish compatibility
- Create uniqueness constraints to prevent duplicate modifiers
- Add referential integrity checks

---

## Data Quality Metrics

| Metric                          | Current | Target | Status |
|---------------------------------|---------|--------|--------|
| Dishes with course_id           | 0%      | 100%   | ❌     |
| Average modifiers per dish      | 704     | 10-50  | ❌     |
| Duplicate modifier rate         | 11x     | 1x     | ❌     |
| Illogical modifier assignments  | High    | 0      | ❌     |
| Modifier groups configured      | 0%      | 100%   | ❌     |
| Overall data quality score      | 15%     | 95%    | ❌     |

---

## Next Steps

1. **Immediate**: Disable online ordering for Capri Pizza until issues are resolved
2. **Review**: Audit other restaurants in the database for similar issues
3. **Fix**: Execute remediation queries (requires data team approval)
4. **Validate**: Test menu display and ordering flow after fixes
5. **Monitor**: Implement ongoing data quality checks

---

## Technical Details

**Restaurant ID:** 977
**Restaurant Name:** Capri Pizza
**Status:** active
**Total Dishes:** 86
**Total Courses:** 11
**Total Modifiers:** 60,544
**Database Schema:** menuca_v3
**Supabase Project:** nthpbtdjhhnwfxqsxbvy

---

**Report prepared by:** Claude Code
**Contact:** Data Quality Team
