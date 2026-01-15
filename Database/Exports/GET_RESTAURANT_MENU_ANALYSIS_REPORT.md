# `get_restaurant_menu` Function Analysis Report

**Generated:** 2026-01-13  
**Last Updated:** 2026-01-13  
**Schema:** `menuca_v3`  
**Function Type:** STABLE, SECURITY INVOKER

---

## 📊 Executive Summary

| Category | Status | Issues Found |
|----------|--------|--------------|
| **Performance** | ⚠️ CONCERNS | 11 correlated subqueries, large JSON payloads (up to 2.9MB) |
| **Data Quality** | ⚠️ GAPS | 4,419 modifiers missing French translations |
| **Code Quality** | ✅ FIXED | ~~Dead parameter~~ ✅, ~~size variants~~ ✅, ~~input validation~~ ✅ |
| **Security** | ✅ GOOD | No SQL injection risk, proper security context |
| **Indexing** | ✅ FIXED | ~~Missing index~~ ✅ `idx_dish_availability_hidden` created |

---

## ✅ CHANGES APPLIED

### Fix #2: New `p_active_items_only` Parameter (Replaces Fix #1) ✅

**Applied:** 2026-01-13  
**Migration File:** `Database/Migrations/fix_002_active_items_only.sql`

**What Changed:**
- **Renamed parameter:** `p_combo_default_only` → `p_active_items_only`
- **Changed default:** `false` → `true` (active items only by default)
- **Extended filtering to 3 tables:**
  - `menuca_v3.dishes` - filter by `is_active`
  - `menuca_v3.combo_group_sections` - filter by `is_active`  
  - `menuca_v3.modifiers` - filter by `is_active`
- **Added `is_active` field** to dish output for frontend visibility

**New Function Signature:**
```sql
menuca_v3.get_restaurant_menu(
    p_restaurant_id bigint,
    p_language_code text DEFAULT 'en',
    p_active_items_only boolean DEFAULT true  -- NEW: controls active/inactive filtering
)
```

**Behavior:**
| Parameter Value | Result |
|-----------------|--------|
| `p_active_items_only = true` (default) | Returns only active dishes, combo sections, and modifiers |
| `p_active_items_only = false` | Returns ALL items including inactive ones |

**Verification Test (Restaurant 636 - Joes Family Pizzeria):**
```sql
-- Dish count comparison
-- p_active_items_only = true:  119 dishes (active only)
-- p_active_items_only = false: 328 dishes (all items)

-- Modifier count comparison  
-- p_active_items_only = true:  1,545 modifiers (active only)
-- p_active_items_only = false: 19,715 modifiers (all items)
```

**Use Cases:**
- **Customer-facing app:** Use default (`true`) to show only active menu items
- **Admin/management:** Use `false` to see all items for editing/reactivation

---

### Fix #7-9: Menu Caching System ✅

**Applied:** 2026-01-13  
**Migration Files:**
- `Database/Migrations/fix_007_menu_cache_columns.sql` - Add cache columns
- `Database/Migrations/fix_008_menu_cache_functions.sql` - Rebuild & access functions
- `Database/Migrations/fix_009_menu_cache_triggers.sql` - Auto-invalidation triggers

**What Changed:**
1. Added `menu_cache_en`, `menu_cache_fr`, `menu_cache_updated_at` columns to restaurants
2. Created `rebuild_menu_cache(restaurant_id)` function
3. Created `get_restaurant_menu_cached(restaurant_id, lang)` function
4. Added triggers on 12 tables to auto-invalidate cache on changes

**Performance Improvement:**
| Query Type | Time | Improvement |
|------------|------|-------------|
| Live query | ~524ms | - |
| Cached query | ~2.4ms | **215x faster** |

**Cache Strategy:**
- **Lazy invalidation**: On data change, cache is set to NULL (not rebuilt)
- **Fallback**: `get_restaurant_menu_cached()` falls back to live query if cache is NULL
- **Manual rebuild**: Use `rebuild_menu_cache(id)` or `rebuild_all_menu_caches()`

**Tables with Invalidation Triggers:**
```
courses, dishes, dish_prices, dish_availability,
modifier_groups, modifiers, modifier_prices, modifier_group_details,
dish_modifier_groups, combo_groups, combo_group_sections, dish_combo_groups
```

---

### Fix #6: Filter Empty Courses from Output ✅

**Applied:** 2026-01-13  
**Migration File:** `Database/Migrations/fix_006_filter_empty_courses.sql`

**What Changed:**
- Added `EXISTS` clause to only include courses with at least one matching dish

```sql
-- Added to WHERE clause for courses:
AND EXISTS (
  SELECT 1 FROM menuca_v3.dishes d
  WHERE d.course_id = c.id
    AND d.restaurant_id = p_restaurant_id
    AND (NOT p_active_items_only OR d.is_active = true)
    AND d.deleted_at IS NULL
)
```

**Verification (Restaurant 636):**
| Metric | Count |
|--------|-------|
| Total active courses in DB | 36 |
| Courses returned (with dishes) | 20 |
| Empty courses filtered out | 16 |

---

### Fix #5: Partial Index on `dish_availability.is_hidden` ✅

**Applied:** 2026-01-13  
**Migration File:** `Database/Migrations/fix_005_dish_availability_index.sql`

**What Changed:**
- Created partial index for the query pattern `WHERE dish_id = ? AND is_hidden = true`

```sql
CREATE INDEX idx_dish_availability_hidden 
ON menuca_v3.dish_availability (dish_id) 
WHERE is_hidden = true;
```

**Index Stats:**
- Total `dish_availability` records: 1,232
- Records with `is_hidden = true`: 1,232 (100% - all hidden days are tracked)

---

### Fix #4: Language Code Validation ✅

**Applied:** 2026-01-13  
**Migration File:** ~~`Database/Migrations/fix_004_language_validation.sql`~~ (superseded by current)

**What Changed:**
- Added input validation at the start of the function
- Invalid language codes now raise a clear exception

**Validation Logic:**
```sql
IF p_language_code NOT IN ('en', 'fr') THEN
  RAISE EXCEPTION 'Invalid language code: %. Supported values are ''en'' or ''fr''', p_language_code;
END IF;
```

**Test Results:**
| Input | Result |
|-------|--------|
| `'en'` | ✅ Works |
| `'fr'` | ✅ Works |
| `'xyz123'` | ❌ `ERROR: Invalid language code: xyz123. Supported values are 'en' or 'fr'` |

---

### Fix #3: Size Variant Translations Now Bilingual ✅

**Applied:** 2026-01-13  
**Migration File:** ~~`Database/Migrations/fix_003_size_variant_translations.sql`~~ (superseded by Fix #4)

**What Changed:**
Three locations updated to use bilingual size variant names:

| Location | Before | After |
|----------|--------|-------|
| `dish_prices` | `dp.size_variant` | `COALESCE(dsv.name_fr/en, dp.size_variant)` |
| `modifier_prices` | `mp.size_variant` | Added JOIN + `COALESCE(msv.name_fr/en, mp.size_variant)` |
| `combo_modifier_prices` | `cmp.size_variant` | `COALESCE(msv.name_fr/en, cmp.size_variant)` |

**Verification Test:**
```sql
-- English output (dsv_id=2)
-- size_variant: "Small"

-- French output (dsv_id=2)  
-- size_variant: "Petite"

-- Full size translations:
-- Small → Petite
-- Medium → Moyenne
-- Large → Grande
-- X-Large → X-Grande
```

**Fallback Chain:** `translated_name → other_language → raw_string`

---

### ~~Fix #1: `p_combo_default_only` Parameter~~ (Superseded by Fix #2)

<details>
<summary>Original Fix #1 (now replaced)</summary>

**Applied:** 2026-01-13  
**Status:** ⚠️ Superseded by Fix #2

The original fix implemented `p_combo_default_only` to filter combo modifier groups by `is_selected`. 
This has been replaced with the more comprehensive `p_active_items_only` parameter.

</details>

---

## 🚨 CRITICAL ISSUES

### ~~1. Dead Parameter: `p_combo_default_only`~~ ✅ RESOLVED & REPLACED

**Status:** ✅ **REPLACED** with `p_active_items_only` on 2026-01-13  
**Severity:** ~~🔴 HIGH~~ → ✅ Resolved  
**Description:** Parameter has been replaced with a more useful `p_active_items_only` parameter that controls visibility of active/inactive items across dishes, combo sections, and modifiers.

**New Function Signature:**
```sql
get_restaurant_menu(p_restaurant_id bigint, p_language_code text, p_active_items_only boolean DEFAULT true)
```

<details>
<summary>Original Issue Details (for reference)</summary>

```sql
-- Old function signature
get_restaurant_menu(p_restaurant_id bigint, p_language_code text, p_combo_default_only boolean)
```

**Evidence:**
- Parameter appeared only 2 times in function body
- Once in declaration, once returned in JSON output
- **No filtering logic used this parameter**

**Resolution:** Rather than implementing the original `p_combo_default_only` functionality, we replaced it with a more comprehensive `p_active_items_only` parameter that filters active/inactive status on:
1. `dishes.is_active`
2. `combo_group_sections.is_active`
3. `modifiers.is_active`

</details>

---

### ~~2. Size Variant Translations NOT Used~~ ✅ RESOLVED

**Status:** ✅ **FIXED** on 2026-01-13  
**Severity:** ~~🔴 HIGH~~ → ✅ Resolved  
**Description:** Size variants now correctly use bilingual translations from lookup tables.

**New Behavior (French mode):**
```json
{
  "size_variant": "Petite",       // ✅ Now uses dish_size_variants.name_fr
  "dish_size_variant_id": 2,
  "modifier_size_variant_id": 2
}
```

<details>
<summary>Original Issue Details (for reference)</summary>

**Tables with translations:**
| Table | Records | Has `name_fr` |
|-------|---------|---------------|
| `dish_size_variants` | 70 | ✅ Yes |
| `modifier_size_variants` | 8 | ✅ Yes |

**Applied Fix:**
```sql
'size_variant', CASE WHEN v_use_french 
    THEN COALESCE(dsv.name_fr, dsv.name_en, dp.size_variant) 
    ELSE COALESCE(dsv.name_en, dsv.name_fr, dp.size_variant) 
END
```

</details>

---

### 3. 4,419 Modifiers Missing French Translations

**Severity:** 🟠 MEDIUM-HIGH  
**Description:** Modifiers table has significant translation gaps affecting French menu display.

**Breakdown by Restaurant:**
| Restaurant | Missing Translations |
|------------|---------------------|
| Milano (all locations) | 1,543 |
| Joes Family Pizzeria | 1,271 |
| Kiki Lebanese Pineview Pizza | 359 |
| The Original Georgie's | 109 |
| Poutinerie Québecurds Gatineau | 81 |
| Little Gyros Greek Grill | 79 |
| *Others* | ~977 |

**Impact:** Users selecting French language will see English modifier names due to COALESCE fallback.

**Recommendation:** Export and translate remaining modifiers:
```sql
SELECT DISTINCT m.name_en, '' as name_fr
FROM menuca_v3.modifiers m
WHERE m.name_fr IS NULL OR TRIM(m.name_fr) = ''
ORDER BY m.name_en;
```

---

## ⚠️ PERFORMANCE CONCERNS

### 4. 11 Correlated Subqueries (N+1 Pattern)

**Severity:** 🟠 MEDIUM  
**Description:** Function uses 11 `SELECT jsonb_agg(...)` subqueries that execute per-row.

**Affected Queries:**
1. `dish_availability` → per dish
2. `dish_prices` → per dish
3. `modifier_groups` (via `dish_modifier_groups`) → per dish
4. `modifiers` → per modifier group
5. `modifier_prices` → per modifier
6. `combo_groups` (via `dish_combo_groups`) → per dish
7. `combo_group_sections` → per combo group
8. `combo_modifier_groups` → per section
9. `combo_modifiers` → per modifier group
10. `combo_modifier_prices` → per combo modifier
11. Hidden days aggregation → per dish

**JSON Payload Sizes Observed:**
| Restaurant | Dishes | JSON Size | Notes |
|------------|--------|-----------|-------|
| Small menu (ID 7) | ~50 | 600 KB | Many modifiers |
| Medium (ID 147) | 225 | 103 KB | Few modifiers |
| Large (ID 636) | 328 | 2.2 MB | Heavy modifiers |
| Milano (ID 88) | 311 | 2.9 MB | Complex combos |
| XL (ID 816) | 861 | 244 KB | Simple items |

**Recommendation:** Consider:
1. Pagination for large menus
2. Materialized views for frequently accessed restaurants
3. Separate endpoints for dishes vs. full menu
4. Redis/CDN caching for menu JSON

---

### ~~5. Missing Index on `dish_availability.is_hidden`~~ ✅ RESOLVED

**Status:** ✅ **FIXED** on 2026-01-13  
**Severity:** ~~🟡 LOW-MEDIUM~~ → ✅ Resolved  
**Description:** Created partial index for optimal query performance.

**Index Created:**
```sql
CREATE INDEX idx_dish_availability_hidden 
ON menuca_v3.dish_availability (dish_id) 
WHERE is_hidden = true;
```

**All Current Indexes on `dish_availability`:**
- ✅ `dish_availability_pkey` on `(id)`
- ✅ `dish_availability_dish_id_day_of_week_key` on `(dish_id, day_of_week)` UNIQUE
- ✅ `idx_dish_availability_dish` on `(dish_id)`
- ✅ `idx_dish_availability_day` on `(day_of_week)`
- ✅ `idx_dish_availability_hidden` on `(dish_id) WHERE is_hidden = true` **NEW**

---

## 🔒 SECURITY ANALYSIS

### ✅ No SQL Injection Risk
- Function uses parameterized queries
- No dynamic SQL (`EXECUTE`)
- No `format()` string building

### ✅ Proper Security Context
- `SECURITY INVOKER` (runs as caller, not owner)
- RLS enabled on `restaurants` table
- Other menu tables have RLS disabled (intentional for public access)

### ~~⚠️ No Language Code Validation~~ ✅ RESOLVED

**Status:** ✅ **FIXED** on 2026-01-13  
**Severity:** ~~🟡 LOW~~ → ✅ Resolved  
**Description:** Function now validates language code and raises clear exception for invalid input.

**New Behavior:**
```sql
SELECT menuca_v3.get_restaurant_menu(7, 'xyz123', false);
-- ERROR: Invalid language code: xyz123. Supported values are 'en' or 'fr'
```

---

## 🗃️ DATA QUALITY ISSUES

### ~~6. 243 Empty Courses (Active with No Dishes)~~ ✅ RESOLVED

**Status:** ✅ **FIXED** on 2026-01-13  
**Severity:** ~~🟡 LOW-MEDIUM~~ → ✅ Resolved  
**Description:** Empty courses are now filtered out from the function output.

**Applied Fix:**
```sql
-- Added EXISTS clause to course query:
AND EXISTS (
  SELECT 1 FROM menuca_v3.dishes d
  WHERE d.course_id = c.id
    AND (NOT p_active_items_only OR d.is_active = true)
    AND d.deleted_at IS NULL
)
```

**Note:** The 243 empty courses still exist in the database (for potential future use), but they are no longer returned by `get_restaurant_menu`.

---

### 7. 73 Empty Combo Groups (No Active Sections)

**Severity:** 🟡 LOW  
**Description:** Combo groups exist with no active sections, resulting in empty JSON arrays.

**Sample:**
- Aroy Thai: 4 dinner combos
- Dumpling Bowl: 1 combo
- Kiki Lebanese: 3 combos

---

### 8. 4 Dishes Without Prices

**Severity:** 🟡 LOW  
**Description:** Active dishes exist with no price records.

| Restaurant | Dish |
|------------|------|
| Pho Dau Bo | 601., 602. (empty names) |
| Pho Dau Bo | 777. Bubble Tea |
| Pho Dau Bo | 781. Soft drinks |

---

### 9. 2 Orphan Modifier Group Details

**Severity:** 🟡 LOW  
**Description:** `modifier_group_details` records exist without matching `dish_modifier_groups`.

---

## 📈 RECOMMENDATIONS SUMMARY

### Priority 1 (Critical)
1. ~~❗ Implement or remove `p_combo_default_only` parameter~~ ✅ **DONE** (replaced with `p_active_items_only`)
2. ~~❗ Add bilingual size variant names to output~~ ✅ **DONE**
3. ❗ Complete modifier translations (4,419 records)

### Priority 2 (Important)
4. ~~⚠️ Add language code validation~~ ✅ **DONE**
5. ~~⚠️ Create index on `dish_availability.is_hidden`~~ ✅ **DONE**
6. ~~⚠️ Filter out empty courses in output~~ ✅ **DONE**

### Priority 3 (Nice to Have)
7. 💡 Add pagination for large menus
8. ~~💡 Implement caching strategy~~ ✅ **DONE** (Fix #7-9)
9. 💡 Clean up orphan data
10. 💡 Add `updated_at` timestamp to output for cache invalidation

---

## 📝 CURRENT FUNCTION SIGNATURE

```sql
-- Current function (as of Fix #2)
CREATE OR REPLACE FUNCTION menuca_v3.get_restaurant_menu(
    p_restaurant_id bigint,
    p_language_code text DEFAULT 'en',
    p_active_items_only boolean DEFAULT true        -- ✅ Filters active/inactive items
)
RETURNS jsonb
```

## 📝 PROPOSED FUTURE IMPROVEMENTS

```sql
-- Future improvements to consider (not yet applied)
CREATE OR REPLACE FUNCTION menuca_v3.get_restaurant_menu(
    p_restaurant_id bigint,
    p_language_code text DEFAULT 'en',
    p_active_items_only boolean DEFAULT true,       -- ✅ Already implemented
    p_include_empty_courses boolean DEFAULT false,  -- Future: filter empty courses
    p_page integer DEFAULT NULL,                    -- Future: pagination
    p_page_size integer DEFAULT 50
)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_result jsonb;
    v_use_french boolean;
BEGIN
    -- Input validation (Priority 2 - not yet applied)
    IF p_language_code NOT IN ('en', 'fr') THEN
        RAISE EXCEPTION 'Invalid language code: %. Use ''en'' or ''fr''', p_language_code;
    END IF;
    
    v_use_french := (p_language_code = 'fr');
    
    -- ... rest of improved implementation
END;
$$;
```

---

## 🔍 TESTING COMMANDS

```sql
-- Test English output (active items only - default)
SELECT jsonb_pretty(menuca_v3.get_restaurant_menu(7::bigint, 'en'::text, true::boolean));

-- Test French output (active items only)
SELECT jsonb_pretty(menuca_v3.get_restaurant_menu(7::bigint, 'fr'::text, true::boolean));

-- Test with ALL items including inactive (for admin view)
SELECT jsonb_pretty(menuca_v3.get_restaurant_menu(636::bigint, 'en'::text, false::boolean));

-- Measure JSON size
SELECT pg_size_pretty(LENGTH(menuca_v3.get_restaurant_menu(88::bigint, 'en', true)::text)::bigint);

-- Find restaurants by ID
SELECT id, name, slug FROM menuca_v3.restaurants WHERE status = 'active' ORDER BY name;

-- Verify p_active_items_only works (compare dish counts)
SELECT 
    'Active only (default)' as mode,
    COUNT(*) as dish_count
FROM (
    SELECT elem FROM menuca_v3.get_restaurant_menu(636::bigint, 'en', true) as menu,
    jsonb_array_elements(menu->'courses') as c,
    jsonb_array_elements(c->'dishes') as elem
) sub
UNION ALL
SELECT 
    'All items (including inactive)' as mode,
    COUNT(*) as dish_count
FROM (
    SELECT elem FROM menuca_v3.get_restaurant_menu(636::bigint, 'en', false) as menu,
    jsonb_array_elements(menu->'courses') as c,
    jsonb_array_elements(c->'dishes') as elem
) sub;
-- Expected: Active only = 119, All items = 328
```

---

## 📋 HANDOFF NOTES FOR REPLIT AGENT

### Current Function State
The `get_restaurant_menu` function is located in schema `menuca_v3` and returns a complete menu structure as JSONB.

**Current Signature:**
```sql
menuca_v3.get_restaurant_menu(
    p_restaurant_id bigint,
    p_language_code text DEFAULT 'en',        -- 'en' or 'fr'
    p_active_items_only boolean DEFAULT true  -- true=active only, false=all items
)
```

### Changes Applied
1. ~~**Fix #1** (2026-01-13): `p_combo_default_only` parameter~~ (superseded)
2. **Fix #2** (2026-01-13): Replaced with `p_active_items_only` parameter that filters:
   - `dishes.is_active`
   - `combo_group_sections.is_active`
   - `modifiers.is_active`
3. **Fix #3** (2026-01-13): Size variant translations now bilingual:
   - `dish_prices.size_variant` → Uses `dish_size_variants.name_fr/en`
   - `modifier_prices.size_variant` → Uses `modifier_size_variants.name_fr/en`
   - `combo_modifier_prices.size_variant` → Uses `modifier_size_variants.name_fr/en`
4. **Fix #4** (2026-01-13): Language code validation:
   - Validates `p_language_code` is 'en' or 'fr'
   - Raises clear exception for invalid input
5. **Fix #5** (2026-01-13): Partial index on `dish_availability`:
   - Created `idx_dish_availability_hidden` for query optimization
6. **Fix #6** (2026-01-13): Filter empty courses from output:
   - Added EXISTS clause to exclude courses with no dishes
7. **Fix #7-9** (2026-01-13): Menu caching system:
   - Added cache columns to restaurants table
   - Created rebuild/access functions
   - Added auto-invalidation triggers on 12 tables
   - **Performance: 524ms → 2.4ms (215x faster)**

### Migration Files Created
- ~~`Database/Migrations/fix_001_combo_default_only.sql`~~ (superseded)
- ~~`Database/Migrations/fix_002_active_items_only.sql`~~ (superseded)
- ~~`Database/Migrations/fix_003_size_variant_translations.sql`~~ (superseded)
- ~~`Database/Migrations/fix_004_language_validation.sql`~~ (superseded)
- `Database/Migrations/fix_005_dish_availability_index.sql` - Index creation
- `Database/Migrations/fix_006_filter_empty_courses.sql` - Function definition
- `Database/Migrations/fix_007_menu_cache_columns.sql` - Cache columns
- `Database/Migrations/fix_008_menu_cache_functions.sql` - Cache functions
- `Database/Migrations/fix_009_menu_cache_triggers.sql` - Invalidation triggers

### Available Functions
```sql
-- Live query (always rebuilds, ~500ms)
menuca_v3.get_restaurant_menu(restaurant_id, 'en'|'fr', active_only)

-- Cached query (instant if cached, fallback to live, ~2ms)
menuca_v3.get_restaurant_menu_cached(restaurant_id, 'en'|'fr')

-- Cache management
menuca_v3.rebuild_menu_cache(restaurant_id)      -- Rebuild single restaurant
menuca_v3.rebuild_all_menu_caches()              -- Rebuild all (takes ~5-10 min)
menuca_v3.invalidate_menu_cache(restaurant_id)   -- Force cache invalidation
```

### Remaining Work
- Issue #3 (data): 4,419 modifiers missing French translations (DATA issue, not function)
- Optional: Pagination for large menus
- Optional: Add `updated_at` to output

---

**Report compiled by:** Cursor AI Agent  
**Analysis methodology:** Direct PostgreSQL function inspection, data sampling, index verification
