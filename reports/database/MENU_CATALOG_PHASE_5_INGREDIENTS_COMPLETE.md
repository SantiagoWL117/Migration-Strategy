# Menu & Catalog Refactoring - Phase 5: Ingredients Repurposing ✅ COMPLETE

**Date:** 2025-10-30  
**Status:** ✅ **SUCCESS**  
**Objective:** Redefine ingredients as what's IN the dish (for allergens/recipes), not modifiers

---

## Executive Summary

Successfully created `dish_ingredients` table and repurposed `ingredients` table to clarify its role as an ingredient library for allergen tracking, nutritional info, and recipe management. Separated concerns: ingredients = what's IN dishes, modifiers = customization options.

---

## Migration Results

### 5.1 Dish Ingredients Table Created

**New Table: `menuca_v3.dish_ingredients`**

**Purpose:** Links dishes to their BASE ingredients (what is IN the dish)

**Columns:**
- `id` - Primary key
- `uuid` - Unique identifier
- `dish_id` - FK to dishes (REQUIRED)
- `ingredient_id` - FK to ingredients (REQUIRED)
- `quantity` - Amount (e.g., 2.5 for "2.5 cups")
- `unit` - Unit of measurement (cups, oz, grams, pieces, whole)
- `is_allergen` - Quick flag for common allergens
- `is_primary` - Primary ingredient vs. secondary
- `display_order` - UI ordering
- `notes` - Recipe notes, preparation instructions
- Standard audit fields (created_at, updated_at, created_by, updated_by)

**Indexes Created:**
- `idx_dish_ingredients_dish_id` - Fast dish lookups
- `idx_dish_ingredients_ingredient_id` - Fast ingredient lookups
- `idx_dish_ingredients_allergen` - Fast allergen filtering (partial index)

**Constraints:**
- UNIQUE(dish_id, ingredient_id) - Prevents duplicate ingredient entries per dish
- ON DELETE CASCADE for dish_id - Cleans up when dish deleted
- ON DELETE RESTRICT for ingredient_id - Prevents deletion of ingredients in use

### 5.2 Ingredients Table Repurposed

**Updated Comments:**

**Table Comment:**
```
Ingredient library - master list of food components (Chicken, Tomatoes, Cheese, etc.).
Used for: allergen tracking, nutritional database, inventory management, recipe ingredients.
NOT for customization options - use modifier_groups and dish_modifiers instead.
To link ingredients to dishes, use dish_ingredients table.
```

**Column Comments Added:**
- `name` - Ingredient name
- `base_price` - LEGACY: Base price (used in legacy modifier system)
- `price_by_size` - LEGACY: Multi-size pricing (used in legacy modifier system)
- `ingredient_type` - Type/category (protein, vegetable, dairy, sauce)
- `is_global` - TRUE if from V2 global_ingredients

**Dish Modifiers Table Comment Updated:**
```
Dish customization options (modifiers). Links to modifier_groups for selection rules.
For what is IN the dish (base ingredients), use dish_ingredients table instead.
```

---

## Current State Analysis

### Ingredient Usage Breakdown

**Total Ingredients:** 32,031

**Usage Patterns:**
- **Used as Modifiers:** 1,251 ingredients (via dish_modifiers)
- **Used in Ingredient Groups:** 26,461 ingredients (legacy modifier system)
- **Not Used (Potential Dish Ingredients):** 5,553 ingredients

**Note:** Many ingredients are currently used for modifiers. The `dish_ingredients` table is ready for when restaurants start populating actual dish ingredients for allergen tracking.

### Dishes with Ingredients Field

- **Total Dishes:** 22,709
- **Dishes with ingredients text:** 0 (field exists but empty)

**Implication:** No existing data to migrate. Table is ready for future population when restaurants add ingredient lists for allergen tracking.

---

## Industry Standard Alignment

**Before (Confused):**
- Ingredients table used for BOTH:
  - ✅ What's in the dish ("contains chicken, garlic, ginger")
  - ❌ Modifiers ("add extra cheese")

**After (Clear Separation):**
- **Ingredients** = Ingredient library (Chicken, Tomatoes, Cheese)
- **dish_ingredients** = What's IN the dish (for allergens, recipes)
- **dish_modifiers** = Customization options (add/remove toppings)

**Industry Pattern:** Matches Uber Eats, DoorDash, Skip the Dishes architecture

---

## Use Cases Enabled

### 1. Allergen Tracking
```sql
-- Find all dishes containing peanuts
SELECT DISTINCT d.id, d.name
FROM menuca_v3.dishes d
JOIN menuca_v3.dish_ingredients di ON di.dish_id = d.id
JOIN menuca_v3.ingredients i ON i.id = di.ingredient_id
WHERE i.name ILIKE '%peanut%'
  OR di.is_allergen = true;
```

### 2. Nutritional Information
```sql
-- Calculate total calories from ingredients
SELECT 
    d.id,
    d.name,
    SUM(ing.calories * di.quantity) as total_calories
FROM menuca_v3.dishes d
JOIN menuca_v3.dish_ingredients di ON di.dish_id = d.id
JOIN menuca_v3.ingredients ing ON ing.id = di.ingredient_id
GROUP BY d.id, d.name;
```

### 3. Inventory Management
```sql
-- Find dishes using a specific ingredient
SELECT DISTINCT d.id, d.name, di.quantity, di.unit
FROM menuca_v3.dishes d
JOIN menuca_v3.dish_ingredients di ON di.dish_id = d.id
WHERE di.ingredient_id = 123;
```

---

## Migration Safety

- ✅ New table only - no data migration needed
- ✅ No changes to existing data
- ✅ Comments clarify table purposes
- ✅ Proper indexes for performance
- ✅ Foreign key constraints ensure data integrity

**Rollback Capability:** Can drop `dish_ingredients` table if needed (no dependencies yet)

---

## Next Steps

✅ **Phase 5 Complete** - Ingredients table repurposed, dish_ingredients table ready

**Ready for Phase 6:** Add Enterprise Schema
- Create allergen tracking tables
- Create dietary tags tables
- Create size options tables (alternative to dish_prices JSONB)

**Future Work:**
- Populate dish_ingredients when restaurants add ingredient lists
- Build UI for restaurants to manage dish ingredients
- Integrate with allergen warning system
- Link to nutritional database

---

## Files Modified

- ✅ `menuca_v3.dish_ingredients` (table created, 0 rows - ready for use)
- ✅ `menuca_v3.ingredients` (comments updated)
- ✅ `menuca_v3.dish_modifiers` (comment updated)

