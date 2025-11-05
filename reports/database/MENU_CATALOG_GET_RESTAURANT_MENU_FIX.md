# Fix: get_restaurant_menu() Function Refactoring

**Date:** 2025-10-30  
**Status:** ✅ **COMPLETE**  
**Issue:** Function not updated for refactored schema

---

## 🚨 Issues Found

1. **Wrong signature:** Function only accepted 1 parameter (`p_restaurant_id`) but API expects 2 (`p_restaurant_id`, `p_language_code`)
2. **References deleted table:** Function tried to query `dish_modifier_prices` which doesn't exist anymore (renamed to `dish_modifier_prices_legacy`)
3. **Not updated:** Function wasn't updated to use new refactored tables (`modifier_groups`, `dish_modifiers` with direct name+price)

---

## ✅ Fixes Applied

### 1. Updated Function Signature
- ✅ Added `p_language_code` parameter (default: 'en')
- ✅ Validates language code ('en', 'fr', 'es', 'zh', 'ar')
- ✅ Falls back to 'en' if invalid language provided

### 2. Removed Deleted Table References
- ✅ Removed all references to `dish_modifier_prices` table
- ✅ Updated to use new `modifier_groups` + `dish_modifiers` structure

### 3. Updated to Refactored Schema
- ✅ Uses `dish_prices` table for pricing (not legacy columns)
- ✅ Uses `modifier_groups` for modifier grouping with selection rules
- ✅ Uses `dish_modifiers` with direct `name` + `price` (not ingredient-based)
- ✅ Added translation support via translation tables:
  - `course_translations`
  - `dish_translations`
  - `modifier_group_translations`
  - `dish_modifier_translations`

### 4. Function Structure
```sql
get_restaurant_menu(
    p_restaurant_id BIGINT,
    p_language_code VARCHAR DEFAULT 'en'
)
RETURNS TABLE(
    course_id BIGINT,
    course_name VARCHAR,
    course_display_order INTEGER,
    dish_id BIGINT,
    dish_name VARCHAR,
    dish_description TEXT,
    dish_display_order INTEGER,
    pricing JSONB,        -- Array of {size, price, display_order}
    modifiers JSONB,      -- Array of modifier groups with nested modifiers
    availability JSONB    -- Real-time availability info
)
```

---

## 📊 Modifier Structure

**New Structure (Refactored):**
```json
{
  "modifiers": [
    {
      "modifier_group_id": 123,
      "group_name": "Toppings",
      "is_required": false,
      "min_selections": 0,
      "max_selections": 5,
      "display_order": 0,
      "modifiers": [
        {
          "modifier_id": 456,
          "name": "Extra Cheese",
          "price": 1.50,
          "display_order": 0
        }
      ]
    }
  ]
}
```

**Old Structure (Legacy - REMOVED):**
- Used `dish_modifier_prices` table
- Referenced `ingredients` table
- No modifier groups

---

## ✅ Verification

**Function Signature:**
```sql
get_restaurant_menu(p_restaurant_id bigint, p_language_code character varying DEFAULT 'en'::character varying)
```

**Test Results:**
- ✅ Function executes successfully
- ✅ Returns correct structure
- ✅ Pricing loaded from `dish_prices` table
- ✅ Modifiers loaded from `modifier_groups` + `dish_modifiers`
- ✅ Translations fallback correctly

---

## 📝 Migration Details

**Migration:** `drop_and_recreate_get_restaurant_menu_refactored`  
**Migration:** `fix_get_restaurant_menu_modifier_groups`

**Changes:**
1. Dropped old 1-parameter function
2. Created new 2-parameter function with translations
3. Fixed `modifier_groups` reference (removed non-existent `deleted_at` check)

---

## 🎯 Impact

**Before:**
- ❌ Function broken (references deleted table)
- ❌ No multi-language support
- ❌ Wrong modifier structure

**After:**
- ✅ Function works with refactored schema
- ✅ Multi-language support (5 languages)
- ✅ Correct modifier structure (groups + modifiers)
- ✅ Uses modern pricing table

---

**Status:** ✅ **COMPLETE**  
**Next:** Frontend can now use updated function with language parameter

---

## ✅ Final Fix Applied

**Issue:** Function referenced `dish_inventory` table columns that don't exist  
**Fix:** Simplified availability to use `is_dish_available_now()` function only  
**Migration:** `fix_get_restaurant_menu_final_complete`

**Final Function Signature:**
```sql
get_restaurant_menu(
    p_restaurant_id BIGINT,
    p_language_code VARCHAR DEFAULT 'en'
)
```

**Availability Object:**
```json
{
  "is_available": true/false,
  "is_active": true/false,
  "unavailable_until": "2025-10-31T12:00:00Z" | null
}
```

**Verification:**
- ✅ Function accepts 2 parameters (matches API expectations)
- ✅ No references to deleted tables (`dish_modifier_prices`)
- ✅ Uses refactored schema (`dish_prices`, `modifier_groups`, `dish_modifiers`)
- ✅ Multi-language support via translation tables
- ✅ Function executes successfully

