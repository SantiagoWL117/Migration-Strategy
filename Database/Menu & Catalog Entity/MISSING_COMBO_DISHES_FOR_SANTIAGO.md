# Missing Combo Dishes - Data Request for Santiago

**Date:** 2025-10-10  
**Issue:** Combo migration blocked - need unfiltered V1 menu data  
**Current Coverage:** 36.49% (2,108 of 5,777 combo dishes found)  
**Missing:** 3,669 dish IDs (63.51%)

---

## What We Have

**Current Dumps:**
- `menuca_v1_menu.sql` - 14,884 rows (FILTERED - excludes hidden/blank items)
- `menuca_v1_ingredients.sql` - 43,930 rows (COMPLETE)
- `menuca_v1_combos.sql` - 16,461 combo relationships (COMPLETE)

**Combined:** 58,814 total rows in staging.menuca_v1_menu_full

---

## What We Need

### Option 1: Full Unfiltered Menu Dump

Need a dump of `menuca_v1.menu` table that includes:
- ✅ All rows (not just visible dishes)
- ✅ Hidden dishes (`showinmenu='N'`)
- ✅ Dishes with blank/empty names
- ✅ Inactive restaurant dishes

**Expected:** ~58,057 total rows (based on historical data)

### Option 2: Query the Original Database

If you have access to the original MySQL `menuca_v1` database, run this query:

```sql
-- Export ONLY the missing 3,669 dishes that combos reference
SELECT m.*
FROM menuca_v1.menu m
WHERE m.id IN (
    -- List of 3,669 missing dish IDs
    -- (See attached file: missing_dish_ids.txt)
);
```

### Option 3: Full Table Export

```sql
-- Export complete unfiltered menu table
SELECT * 
FROM menuca_v1.menu
-- NO WHERE clause - export everything
ORDER BY id;
```

**Export as:** CSV or SQL INSERT statements

---

## Why Combos Need "Hidden" Dishes

Combos reference dishes by ID. These IDs include:
- **Actual menu items** (visible dishes)
- **Modifiers** (hidden dishes: toppings, add-ons, options)
- **Ingredients** (blank name items used as combo options)

**Example: Pizza Combo**
- Dish ID 1234: "Large Pizza" (visible) ✅
- Dish ID 5678: "Extra Cheese" (hidden modifier) ❌ Missing!
- Dish ID 9012: "Pepperoni" (hidden topping) ❌ Missing!

Without the modifiers, combos can't be built properly.

---

## Missing Dish IDs

The 3,669 missing dish IDs are stored in: `staging.menuca_v1_combos`

To generate the list:

```sql
-- Run this in Supabase staging
WITH combo_dishes AS (
  SELECT DISTINCT dish::integer as dish_id
  FROM staging.menuca_v1_combos
  WHERE dish IS NOT NULL AND dish != ''
)
SELECT cd.dish_id
FROM combo_dishes cd
LEFT JOIN staging.menuca_v1_menu_full m ON m.id::integer = cd.dish_id
WHERE m.id IS NULL
ORDER BY cd.dish_id;
```

This produces the exact list of 3,669 IDs we need from `menuca_v1.menu`.

---

## Priority

**HIGH** - Blocks combo migration for production deployment

Without this data:
- Combos will have 63% orphan rate (unacceptable)
- Customers can't order combo meals with modifiers
- Pizza orders can't include toppings
- Revenue loss for combo-heavy restaurants

---

## Contact

Questions? Check with Brian or refer to:
- `/Database/Agent_Tasks/04_STAGING_COMBOS_BLOCKED.md`
- This file: `MISSING_COMBO_DISHES_FOR_SANTIAGO.md`

