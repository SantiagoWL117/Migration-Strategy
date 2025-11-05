# Menu & Catalog Refactoring - Phase 6: Add Enterprise Schema ✅ COMPLETE

**Date:** 2025-10-30  
**Status:** ✅ **SUCCESS**  
**Objective:** Add enterprise-grade schema features: allergens, dietary tags, size options

---

## Executive Summary

Successfully created enterprise-grade schema tables for allergen tracking, dietary tags, and size options. These tables match industry standards (Uber Eats, DoorDash, Skip the Dishes) and enable advanced filtering, nutritional tracking, and compliance features.

---

## Migration Results

### 6.1 Allergen Tracking System

**New Table: `menuca_v3.dish_allergens`**

**Purpose:** Track allergens in dishes for food safety and compliance

**Enum Type: `allergen_type`**
- dairy, eggs, fish, shellfish, tree_nuts, peanuts, wheat, soy, sesame, gluten, sulfites, mustard, celery, lupin

**Columns:**
- `dish_id` - FK to dishes (REQUIRED)
- `allergen` - Type of allergen (ENUM)
- `severity` - Level: contains, may_contain, prepared_with, cross_contact
- `notes` - Additional details (e.g., "Prepared in facility that processes peanuts")
- Standard audit fields

**Indexes:**
- `idx_dish_allergens_dish_id` - Fast dish lookups
- `idx_dish_allergens_allergen` - Fast allergen filtering
- `idx_dish_allergens_severity` - Severity-based queries

**Use Cases:**
- Filter dishes by allergen-free requirements
- Display allergen warnings to customers
- Compliance with food labeling regulations
- Cross-contact warnings

### 6.2 Dietary Tags System

**New Table: `menuca_v3.dish_dietary_tags`**

**Purpose:** Tag dishes with dietary preferences for filtering and display

**Enum Type: `dietary_tag`**
- vegetarian, vegan, gluten_free, dairy_free, nut_free, halal, kosher, keto, low_carb, organic, low_fat, low_sodium, sugar_free, paleo, whole30, raw, non_gmo

**Columns:**
- `dish_id` - FK to dishes (REQUIRED)
- `tag` - Dietary tag type (ENUM)
- `verified` - Whether restaurant verified this claim (compliance)
- `verified_at` - Timestamp of verification
- `verified_by` - Admin who verified
- `notes` - Certification details
- Standard audit fields

**Indexes:**
- `idx_dish_dietary_tags_dish_id` - Fast dish lookups
- `idx_dish_dietary_tags_tag` - Fast tag filtering
- `idx_dish_dietary_tags_verified` - Verified tags only (partial index)

**Use Cases:**
- Filter menu by dietary preferences
- Display dietary badges (vegetarian, vegan, etc.)
- Dietary preference matching for customers
- Compliance verification tracking

### 6.3 Size Options Table

**New Table: `menuca_v3.dish_size_options`**

**Purpose:** Structured size metadata with nutritional info (complements dish_prices)

**Enum Type: `size_type`**
- single, small, medium, large, xlarge, xxlarge, personal, regular, family, party

**Columns:**
- `dish_id` - FK to dishes (REQUIRED)
- `size_code` - Standardized size code (ENUM)
- `size_label` - Display label ("12 inch", "Small (10oz)", "Regular")
- `price` - Price for this size (redundant with dish_prices but useful)
- `calories` - Calories per size
- `protein_grams`, `carbs_grams`, `fat_grams` - Nutritional breakdown
- `is_default` - Default size selection
- `display_order` - UI ordering
- Standard audit fields + soft delete

**Indexes:**
- `idx_dish_size_options_dish_id` - Fast dish lookups
- `idx_dish_size_options_size_code` - Size-based queries
- `idx_dish_size_options_default` - Default sizes (partial index)

**Note:** This complements `dish_prices` table. `dish_prices` handles pricing, `dish_size_options` provides size metadata and nutritional info.

**Use Cases:**
- Display size options with labels
- Size-based nutritional calculations
- Default size selection
- Size filtering and ordering

---

## Industry Standard Alignment

**Matches:**
- ✅ Uber Eats allergen/dietary tag system
- ✅ DoorDash size options pattern
- ✅ Skip the Dishes filtering capabilities
- ✅ Food labeling compliance standards

**Key Features:**
- Standardized enums for consistency
- Severity levels for allergens (contains, may_contain, etc.)
- Verification tracking for dietary claims
- Nutritional info per size option

---

## Query Examples

### Find Allergen-Free Dishes
```sql
-- Find dishes without peanuts
SELECT DISTINCT d.id, d.name
FROM menuca_v3.dishes d
WHERE d.id NOT IN (
    SELECT dish_id 
    FROM menuca_v3.dish_allergens 
    WHERE allergen = 'peanuts'
);
```

### Filter by Dietary Tags
```sql
-- Find vegan dishes
SELECT d.id, d.name
FROM menuca_v3.dishes d
JOIN menuca_v3.dish_dietary_tags dt ON dt.dish_id = d.id
WHERE dt.tag = 'vegan'
  AND dt.verified = true;
```

### Size-Based Nutritional Info
```sql
-- Get nutritional info for all sizes
SELECT 
    d.name,
    dso.size_label,
    dso.calories,
    dso.protein_grams,
    dso.carbs_grams,
    dso.fat_grams
FROM menuca_v3.dishes d
JOIN menuca_v3.dish_size_options dso ON dso.dish_id = d.id
WHERE d.id = 123
ORDER BY dso.display_order;
```

---

## Migration Safety

- ✅ All new tables - no existing data affected
- ✅ Proper foreign key constraints
- ✅ Unique constraints prevent duplicates
- ✅ Indexes for performance
- ✅ Soft delete support (dish_size_options)
- ✅ Audit trails (created_by, updated_by)

**Rollback Capability:** Can drop tables if needed (no dependencies yet)

---

## Integration Notes

**Allergen Tracking:**
- Can sync with `dish_ingredients.is_allergen` flag
- Future: Auto-populate from ingredient library allergen flags

**Dietary Tags:**
- Can be inferred from ingredients (e.g., no meat = vegetarian)
- Verification important for legal compliance
- Future: Auto-suggest tags based on ingredients

**Size Options:**
- Complements `dish_prices` table (doesn't replace it)
- `dish_prices` handles pricing, `dish_size_options` handles metadata
- Future: Sync price from `dish_prices` to `dish_size_options.price`

---

## Migration Safety

- ✅ All new tables - no existing data affected
- ✅ Proper foreign key constraints
- ✅ Unique constraints prevent duplicates
- ✅ Indexes for performance
- ✅ Soft delete support (dish_size_options)
- ✅ Audit trails (created_by, updated_by)

**Rollback Capability:** Can drop tables if needed (no dependencies yet)

## Next Steps

✅ **Phase 6 Complete** - Enterprise schema ready

**Ready for Phase 7:** Remove V1/V2 Branching Logic
- Remove source_system checks from functions
- Consolidate to V3-only logic
- Update all SQL functions

---

## Files Modified

- ✅ `menuca_v3.dish_allergens` (table created, 0 rows - ready for use)
- ✅ `menuca_v3.dish_dietary_tags` (table created, 0 rows - ready for use)
- ✅ `menuca_v3.dish_size_options` (table created, 0 rows - ready for use)
- ✅ `menuca_v3.allergen_type` (enum created)
- ✅ `menuca_v3.dietary_tag` (enum created)
- ✅ `menuca_v3.size_type` (enum created)

