# Menu & Catalog Entity: Source → menuca_v3 Mapping

**Last Updated:** 2025-09-30  
**Status:** Planning Phase - Blocked by Restaurant Management  
**Total V1 Rows:** ~750,000+  
**Complexity:** HIGH (BLOB deserialization, multilingual, complex pricing)

---

## 🎯 Entity Purpose

Complete menu structure including courses (categories), dishes (menu items), combos (meal deals), ingredients, and customization options. This entity defines what customers can order.

---

## 📊 Source Tables Overview

### V1 Tables (7 tables - PHP Serialized BLOBs)
| Table | Rows | Purpose | BLOB Columns |
|-------|------|---------|--------------|
| `courses` | ~16,001 | Menu categories | None |
| `menu` | ~141,282 | Individual dishes | `hideOnDays`, blob fields for options |
| `menuothers` | ~328,167 | Side dishes, drinks, extras | `content` (PHP serialized) |
| `combo_groups` | ~62,720 | Combo meal definitions | `dish`, `options`, `group` (all PHP serialized) |
| `combos` | ~112,125 | Combo item links | None |
| `ingredient_groups` | ~13,627 | Ingredient group defs | `item`, `price` (PHP serialized) |
| `ingredients` | ~59,950 | Individual ingredients | None |

### V2 Tables (13 tables - JSON Format)
| Table | Rows (est.) | Purpose | JSON Columns |
|-------|-------------|---------|--------------|
| `restaurants_courses` | Medium | Course categories per restaurant | None |
| `restaurants_dishes` | High | Menu items per restaurant | `prices` (JSON) |
| `restaurants_dishes_customization` | High | Customization options | Multiple JSON columns |
| `restaurants_combo_groups` | Medium | Combo groups | `config` (JSON) |
| `restaurants_combo_groups_items` | High | Combo group items | `prices` (JSON) |
| `restaurants_ingredients` | High | Restaurant ingredients | `prices` (JSON) |
| `restaurants_ingredient_groups` | Medium | Ingredient groups | None |
| `restaurants_ingredient_groups_items` | High | Group items | `prices` (JSON) |
| `custom_ingredients` | Low | Custom ingredient defs | None |
| `global_courses` | Low | Template courses | None |
| `global_dishes` | Low | Template dishes | None |
| `global_ingredients` | Low | Template ingredients | None |
| `global_restaurant_types` | Low | Restaurant type templates | None |

---

## 🗂️ Target Schema (menuca_v3) - TO BE DEFINED

**Note:** Menu & Catalog tables not yet defined in menuca_v3.sql. Schema needs to be designed based on V1/V2 analysis.

### Recommended V3 Structure

```sql
-- Course Categories
CREATE TABLE menuca_v3.courses (
  id SERIAL PRIMARY KEY,
  restaurant_id INTEGER REFERENCES menuca_v3.restaurants(id),
  name VARCHAR(255) NOT NULL,
  description TEXT,
  display_order INTEGER DEFAULT 0,
  is_global BOOLEAN DEFAULT false,
  language VARCHAR(2) DEFAULT 'en',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);

-- Menu Dishes
CREATE TABLE menuca_v3.dishes (
  id SERIAL PRIMARY KEY,
  restaurant_id INTEGER REFERENCES menuca_v3.restaurants(id),
  course_id INTEGER REFERENCES menuca_v3.courses(id),
  sku VARCHAR(50),
  name VARCHAR(255) NOT NULL,
  description TEXT,
  prices JSONB NOT NULL, -- {"small": "10.99", "medium": "14.99", "large": "18.99"}
  display_order INTEGER DEFAULT 0,
  is_available BOOLEAN DEFAULT true,
  availability_schedule JSONB, -- days/times when available
  is_global BOOLEAN DEFAULT false,
  language VARCHAR(2) DEFAULT 'en',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);

-- Dish Customizations
CREATE TABLE menuca_v3.dish_customizations (
  id SERIAL PRIMARY KEY,
  dish_id INTEGER REFERENCES menuca_v3.dishes(id) ON DELETE CASCADE,
  customization_type VARCHAR(50) NOT NULL, -- 'bread', 'ci', 'sauce', 'dressing', 'extras', 'sidedish', 'drinks', 'cookmethod'
  ingredient_group_id INTEGER REFERENCES menuca_v3.ingredient_groups(id),
  title VARCHAR(255),
  min_selections INTEGER DEFAULT 0,
  max_selections INTEGER DEFAULT 0,
  free_selections INTEGER DEFAULT 0,
  display_order INTEGER DEFAULT 0,
  is_required BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Ingredient Groups
CREATE TABLE menuca_v3.ingredient_groups (
  id SERIAL PRIMARY KEY,
  restaurant_id INTEGER REFERENCES menuca_v3.restaurants(id),
  name VARCHAR(255) NOT NULL,
  group_type VARCHAR(50), -- 'ci', 'sd', 'dr', 'e', 'br', 'sa', 'ds', 'cm'
  is_global BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Ingredients
CREATE TABLE menuca_v3.ingredients (
  id SERIAL PRIMARY KEY,
  ingredient_group_id INTEGER REFERENCES menuca_v3.ingredient_groups(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  prices JSONB, -- {"default": "0.00"} or {"small": "1.00", "medium": "1.50", "large": "2.00"}
  display_order INTEGER DEFAULT 0,
  is_available BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Combo Groups
CREATE TABLE menuca_v3.combo_groups (
  id SERIAL PRIMARY KEY,
  restaurant_id INTEGER REFERENCES menuca_v3.restaurants(id),
  name VARCHAR(255) NOT NULL,
  config JSONB, -- {"itemcount": 2, "showPizzaIcons": true, "steps": [...]}
  language VARCHAR(2) DEFAULT 'en',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Combo Items
CREATE TABLE menuca_v3.combo_items (
  id SERIAL PRIMARY KEY,
  combo_group_id INTEGER REFERENCES menuca_v3.combo_groups(id) ON DELETE CASCADE,
  dish_id INTEGER REFERENCES menuca_v3.dishes(id),
  display_order INTEGER DEFAULT 0,
  customization_config JSONB -- Store which customizations are allowed
);
```

---

## 🔄 V1 → V3 Field Mapping

### Table 1: courses → menuca_v3.courses

| V1 Column | Type | V3 Column | Transform | Notes |
|-----------|------|-----------|-----------|-------|
| `id` | int unsigned | - | Skip | Generate new IDs |
| `name` | varchar(100) | `name` | Direct copy | |
| `desc` | text | `description` | Direct copy | |
| `restaurant` | int unsigned | `restaurant_id` | FK lookup | Map to V3 restaurant |
| `lang` | char(2) | `language` | Direct copy | 'en' or 'fr' |
| `order` | int | `display_order` | Direct copy | |
| `xthPromo` | enum('n','y') | - | Skip | Promotion logic moved elsewhere |
| `xthItem` | int | - | Skip | |
| `remove` | float | - | Skip | |
| `removeFrom` | enum('b','t') | - | Skip | |
| `timePeriod` | int | `availability_schedule` | Transform to JSONB | Map time period to schedule |
| `ciHeader` | varchar(255) | - | Skip | Handled in customizations |

---

### Table 2: menu → menuca_v3.dishes

| V1 Column | Type | V3 Column | Transform | Notes |
|-----------|------|-----------|-----------|-------|
| `id` | int unsigned | - | Skip | Generate new IDs |
| `course` | int unsigned | `course_id` | FK lookup | Map to V3 course |
| `restaurant` | int unsigned | `restaurant_id` | FK lookup | Map to V3 restaurant |
| `sku` | varchar(50) | `sku` | Direct copy | Product SKU |
| `name` | varchar(255) | `name` | Direct copy | |
| `ingredients` | text | `description` | Direct copy | Ingredient description |
| `price` | varchar(125) | `prices` | **Parse to JSONB** | Parse comma-separated: "10,12,14" → {"small":"10","medium":"12","large":"14"} |
| `order` | int unsigned | `display_order` | Direct copy | |
| `quantity` | varchar(255) | - | Skip | Not used in V2 |
| `lang` | char(2) | `language` | Direct copy | |
| `showInMenu` | enum('Y','N') | `is_available` | Convert | 'Y' → true, 'N' → false |
| `hideOnDays` | blob | `availability_schedule` | **Deserialize PHP → JSONB** | PHP array → JSON schedule |
| `image` | varchar(255) | - | Skip | Images handled separately |
| `menuType` | varchar(125) | - | Skip | Type classification |
| `hasCustomisation` | enum('N','Y') | - | Skip | Determined by dish_customizations |

**Customization Fields** → migrate to `menuca_v3.dish_customizations`:
| V1 Column | V3 Mapping |
|-----------|------------|
| `hasBread`, `breadHeader`, `displayOrderBread` | Create customization record type='bread' |
| `hasCustomisation`, `ciHeader`, `minci`, `maxci`, `freeci`, `displayOrderCI` | Create customization record type='ci' |
| `hasDressing`, `dressingHeader`, `mindressing`, `maxdressing`, `freeDressing`, `displayOrderDressing` | Create customization record type='dressing' |
| `hasSauce`, `sauceHeader`, `minsauce`, `maxsauce`, `freeSauce`, `displayOrderSauce` | Create customization record type='sauce' |
| `hasSideDish`, `sideDishHeader`, `minsd`, `maxsd`, `freeSD`, `displayOrderSD`, `isSideDish`, `showSDInMenu` | Create customization record type='sidedish' |
| `hasDrinks`, `drinksHeader`, `mindrink`, `maxdrink`, `freeDrink`, `displayOrderDrink`, `isDrink` | Create customization record type='drinks' |
| `hasExtras`, `extraHeader`, `minextras`, `maxextras`, `freeExtra`, `displayOrderExtras` | Create customization record type='extras' |
| `hasCookMethod`, `cmHeader`, `mincm`, `maxcm`, `freecm`, `displayOrderCM` | Create customization record type='cookmethod' |

---

### Table 3: menuothers → menuca_v3.ingredients (via dish_customizations)

| V1 Column | Type | V3 Column | Transform | Notes |
|-----------|------|-----------|-----------|-------|
| `id` | int | - | Skip | Generate new IDs |
| `restaurant` | int | - | Use for grouping | Link to restaurant |
| `dishId` | int | - | Link to dish | Map to V3 dish |
| `content` | text | `prices` | **Deserialize PHP → JSONB** | ⚠️ PHP serialized: `a:2:{s:7:"content";a:1:{i:1183;s:4:"0.25";}s:5:"radio";s:3:"140";}` |
| `type` | char(2) | `customization_type` | Map type | 'ci'→'ci', 'sd'→'sidedish', 'dr'→'drinks', 'e'→'extras', 'br'→'bread', 'sa'→'sauce', 'ds'→'dressing', 'cm'→'cookmethod' |
| `groupId` | int unsigned | `ingredient_group_id` | FK lookup | Map to V3 ingredient_group |

**PHP Content Structure:**
```php
// Example deserialized structure:
array(
  'content' => array(
    1183 => "0.25",  // ingredient_id => price
    1184 => "0.50"
  ),
  'radio' => "140"    // group_id
)
```

**Migration Strategy:**
1. Deserialize PHP array from `content` column
2. Extract `radio` value → map to ingredient_group_id
3. Extract `content` array → create ingredient records with prices
4. Link via dish_customizations table

---

### Table 4: combo_groups → menuca_v3.combo_groups

| V1 Column | Type | V3 Column | Transform | Notes |
|-----------|------|-----------|-----------|-------|
| `id` | int unsigned | - | Skip | Generate new IDs |
| `name` | varchar(125) | `name` | Direct copy | |
| `dish` | blob | - | **Deserialize PHP → combo_items** | ⚠️ PHP array of dish IDs |
| `options` | blob | `config` | **Deserialize PHP → JSONB** | ⚠️ Complex options structure |
| `group` | blob | - | **Deserialize PHP → ingredient pricing** | ⚠️ Maps ingredient groups to prices |
| `restaurant` | int unsigned | `restaurant_id` | FK lookup | Map to V3 restaurant |
| `lang` | char(2) | `language` | Direct copy | |

**PHP BLOB Structure Examples:**

**`dish` column:**
```php
a:1:{i:0;s:3:"827";}  // Array of dish IDs
```

**`options` column:**
```php
a:5:{
  s:9:"itemcount";s:1:"2";
  s:14:"showPizzaIcons";s:1:"Y";
  s:5:"bread";a:3:{s:3:"has";s:1:"Y";s:5:"order";s:1:"1";s:6:"header";s:0:"";}
  s:2:"ci";a:6:{s:3:"has";s:1:"Y";s:3:"min";s:1:"1";s:3:"max";s:3:"100";s:4:"free";s:1:"1";s:5:"order";s:1:"2";s:6:"header";s:0:"";}
  s:1:"e";a:6:{s:3:"has";s:1:"Y";s:3:"min";s:1:"0";s:3:"max";s:1:"0";s:4:"free";s:1:"0";s:5:"order";s:1:"3";s:6:"header";s:0:"";}
}
```

**`group` column:**
```php
a:3:{
  s:2:"ci";a:1:{i:7;a:20:{i:278;s:5:"2,3,4";...}}  // Maps ingredient_group_id to ingredient pricing
  s:2:"br";a:1:{i:8;a:2:{...}}
  s:1:"e";a:1:{i:9;a:5:{...}}
}
```

---

### Table 5: combos → menuca_v3.combo_items

| V1 Column | Type | V3 Column | Transform | Notes |
|-----------|------|-----------|-----------|-------|
| `id` | int unsigned | - | Skip | Generate new IDs |
| `dish` | int unsigned | `dish_id` | FK lookup | Map to V3 dish |
| `group` | int unsigned | `combo_group_id` | FK lookup | Map to V3 combo_group |
| `order` | int unsigned | `display_order` | Direct copy | |

---

### Table 6: ingredient_groups → menuca_v3.ingredient_groups

| V1 Column | Type | V3 Column | Transform | Notes |
|-----------|------|-----------|-----------|-------|
| `id` | int unsigned | - | Skip | Generate new IDs |
| `name` | varchar(125) | `name` | Direct copy | |
| `type` | char(2) | `group_type` | Direct copy | 'ci', 'sd', 'dr', 'e', 'br', 'sa', 'ds', 'cm' |
| `course` | smallint unsigned | - | Skip | Course-level grouping |
| `dish` | smallint | - | Skip | Dish-level grouping |
| `item` | blob | - | **Deserialize PHP → ingredients** | ⚠️ PHP array of ingredient IDs |
| `price` | text | - | **Deserialize → ingredient prices** | PHP array or text prices |
| `restaurant` | int unsigned | `restaurant_id` | FK lookup | Map to V3 restaurant |
| `lang` | char(2) | - | Skip | Handled by parent |
| `useInCombo` | enum('Y','N') | - | Skip | Determined by usage |
| `isGlobal` | enum('Y','N') | `is_global` | Convert | 'Y' → true, 'N' → false |

**PHP `item` Structure:**
```php
a:21:{
  i:0;s:3:"278";  // Array index => ingredient_id (as string)
  i:1;s:3:"292";
  i:2;s:3:"293";
  ...
}
```

**PHP `price` Structure (when present):**
```php
a:5:{
  i:16996;s:4:"2.00";  // ingredient_id => price
  i:16997;s:4:"2.00";
  ...
}
```

---

### Table 7: ingredients → menuca_v3.ingredients

| V1 Column | Type | V3 Column | Transform | Notes |
|-----------|------|-----------|-----------|-------|
| `id` | int unsigned | - | Skip | Generate new IDs |
| `restaurant` | int unsigned | - | Use for grouping | Link via ingredient_group |
| `name` | varchar(255) | `name` | Direct copy | |
| `price` | varchar(255) | `prices` | **Parse to JSONB** | Comma-separated: "1.00,1.50,2.00" → {"small":"1.00","medium":"1.50","large":"2.00"} |
| `lang` | char(2) | - | Skip | Handled by parent |
| `type` | varchar(255) | - | Skip | Type from ingredient_group |
| `order` | varchar(255) | `display_order` | Cast to int | |
| `availableFor` | varchar(255) | - | Skip | Legacy field |

---

## 🔄 V2 → V3 Field Mapping

### Table 1: restaurants_courses → menuca_v3.courses

| V2 Column | Type | V3 Column | Transform | Notes |
|-----------|------|-----------|-----------|-------|
| `id` | int | - | Skip | Generate new IDs |
| `restaurant_id` | smallint unsigned | `restaurant_id` | Direct copy | |
| `name` | varchar(255) | `name` | Direct copy | |
| `description` | text | `description` | Direct copy | |
| `time_period_id` | smallint unsigned | `availability_schedule` | Map to JSONB | |
| `course_header` | varchar(255) | - | Skip | |
| `display_order` | int | `display_order` | Direct copy | |
| `language_id` | tinyint unsigned | `language` | Map | 1→'en', 2→'fr' |
| `is_global` | tinyint(1) | `is_global` | Cast to boolean | |
| `created_by` | int | - | Skip | |
| `created_at` | datetime | `created_at` | Direct copy | |
| `updated_at` | datetime | `updated_at` | Direct copy | |

---

### Table 2: restaurants_dishes → menuca_v3.dishes

| V2 Column | Type | V3 Column | Transform | Notes |
|-----------|------|-----------|-----------|-------|
| `id` | int | - | Skip | Generate new IDs |
| `restaurant_id` | smallint unsigned | `restaurant_id` | Direct copy | |
| `course_id` | int | `course_id` | FK lookup | Map to V3 course |
| `sku` | varchar(50) | `sku` | Direct copy | |
| `name` | varchar(255) | `name` | Direct copy | |
| `description` | text | `description` | Direct copy | |
| `prices` | text | `prices` | **Parse JSON to JSONB** | Already JSON in V2! |
| `is_popular` | tinyint(1) | - | Skip | |
| `display_order` | int | `display_order` | Direct copy | |
| `is_available` | tinyint(1) | `is_available` | Cast to boolean | |
| `language_id` | tinyint unsigned | `language` | Map | 1→'en', 2→'fr' |
| `is_global` | tinyint(1) | `is_global` | Cast to boolean | |
| `created_by` | int | - | Skip | |
| `created_at` | datetime | `created_at` | Direct copy | |
| `updated_at` | datetime | `updated_at` | Direct copy | |

---

### Table 3: restaurants_dishes_customization → menuca_v3.dish_customizations + metadata

**This table is COMPLEX with multiple JSON columns for different customization types:**

| V2 Column | Type | V3 Mapping | Transform | Notes |
|-----------|------|------------|-----------|-------|
| `id` | int | - | Skip | Generate new IDs |
| `dish_id` | int | `dish_id` | FK lookup | Map to V3 dish |
| `options` | text | - | Parse JSON | Metadata (show_on, calories, hot_level, etc.) |
| `use_bread` | tinyint(1) | Create record | If true, create customization | type='bread' |
| `bread_config` | text | `ingredient_group_id` + config | Parse JSON | Extract group, min/max/free |
| `bread_display_order` | tinyint | `display_order` | Direct copy | |
| `use_ci` | tinyint(1) | Create record | If true, create customization | type='ci' |
| `ci_config` | text | `ingredient_group_id` + config | Parse JSON | |
| `ci_display_order` | tinyint | `display_order` | Direct copy | |
| `use_dressing` | tinyint(1) | Create record | If true, create customization | type='dressing' |
| `dressing_config` | text | `ingredient_group_id` + config | Parse JSON | |
| `dressing_display_order` | tinyint | `display_order` | Direct copy | |
| `use_sauce` | tinyint(1) | Create record | If true, create customization | type='sauce' |
| `sauce_config` | text | `ingredient_group_id` + config | Parse JSON | |
| `sauce_display_order` | tinyint | `display_order` | Direct copy | |
| `use_sidedish` | tinyint(1) | Create record | If true, create customization | type='sidedish' |
| `sidedish_config` | text | `ingredient_group_id` + config | Parse JSON | |
| `sidedish_display_order` | tinyint | `display_order` | Direct copy | |
| `use_drinks` | tinyint(1) | Create record | If true, create customization | type='drinks' |
| `drinks_config` | text | `ingredient_group_id` + config | Parse JSON | |
| `drinks_display_order` | tinyint | `display_order` | Direct copy | |
| `use_extras` | tinyint(1) | Create record | If true, create customization | type='extras' |
| `extras_config` | text | `ingredient_group_id` + config | Parse JSON | |
| `extras_display_order` | tinyint | `display_order` | Direct copy | |
| `use_cookmethod` | tinyint(1) | Create record | If true, create customization | type='cookmethod' |
| `cookmethod_config` | text | `ingredient_group_id` + config | Parse JSON | |
| `cookmethod_display_order` | tinyint | `display_order` | Direct copy | |

**JSON Config Structure (V2):**
```json
{
  "25": {"global_prices": "n"},
  "26": {"global_prices": "y"},
  "max": "1",
  "min": "1",
  "use": "1",
  "free": "1",
  "group": "25",
  "title": "crust",
  "display_order": "1"
}
```

---

### Table 4: restaurants_combo_groups → menuca_v3.combo_groups

| V2 Column | Type | V3 Column | Transform | Notes |
|-----------|------|-----------|-----------|-------|
| `id` | int | - | Skip | Generate new IDs |
| `restaurant_id` | smallint unsigned | `restaurant_id` | Direct copy | |
| `name` | varchar(255) | `name` | Direct copy | |
| `config` | text | `config` | Parse JSON to JSONB | Already JSON! |
| `language_id` | tinyint unsigned | `language` | Map | 1→'en', 2→'fr' |
| `created_at` | datetime | `created_at` | Direct copy | |
| `updated_at` | datetime | `updated_at` | Direct copy | |

---

### Table 5: restaurants_combo_groups_items → menuca_v3.combo_items

| V2 Column | Type | V3 Column | Transform | Notes |
|-----------|------|-----------|-----------|-------|
| `id` | int | - | Skip | Generate new IDs |
| `combo_group_id` | int | `combo_group_id` | FK lookup | Map to V3 combo_group |
| `dish_id` | int | `dish_id` | FK lookup | Map to V3 dish |
| `prices` | text | `customization_config` | Parse JSON to JSONB | Store pricing overrides |
| `display_order` | int | `display_order` | Direct copy | |

---

### Table 6-9: Ingredient Tables

**Pattern is similar for:**
- `restaurants_ingredients` → `menuca_v3.ingredients`
- `restaurants_ingredient_groups` → `menuca_v3.ingredient_groups`
- `restaurants_ingredient_groups_items` → `menuca_v3.ingredients`
- `custom_ingredients` → `menuca_v3.ingredients`

**V2 is already well-structured with JSON, so migration is straightforward.**

---

## 🔧 BLOB Deserialization Strategy

### PHP Serialized Array Format

**Example from `menuothers.content`:**
```
a:2:{s:7:"content";a:1:{i:1183;s:4:"0.25";}s:5:"radio";s:3:"140";}
```

**Deserialized:**
```php
array(
  'content' => array(1183 => "0.25"),
  'radio' => "140"
)
```

### PostgreSQL Deserialization Function

Since PostgreSQL doesn't natively handle PHP serialized data, we'll need to:

**Option 1: Pre-process in Python/PHP**
```python
import phpserialize

def deserialize_php_blob(blob_str):
    try:
        data = phpserialize.loads(blob_str.encode('utf-8'))
        return json.dumps(data)  # Convert to JSON
    except:
        return None
```

**Option 2: Use staging tables with text columns**
1. Load BLOB data as TEXT into staging
2. Process with Python/PHP script to convert to JSON
3. Load JSON into V3 JSONB columns

---

## ⚠️ Migration Challenges & Solutions

### Challenge 1: PHP BLOB Deserialization
**Issue:** V1 uses PHP serialized arrays, PostgreSQL doesn't support this  
**Solution:**
1. Create intermediate Python/PHP script
2. Load V1 data into staging as TEXT
3. Deserialize using `phpserialize` library
4. Convert to JSON
5. Load JSON into V3 JSONB columns

### Challenge 2: Complex Pricing Formats
**Issue:** Multiple price formats: "10,12,14", "10.99", JSON  
**Solution:**
- Create price normalization function
- Parse comma-separated → JSONB: `{"small": "10", "medium": "12", "large": "14"}`
- Single price → JSONB: `{"default": "10.99"}`
- JSON → JSONB (V2 only)

### Challenge 3: Multilingual Data
**Issue:** EN/FR content in separate rows (V1) or language_id (V2)  
**Solution:**
- Maintain language column in V3
- Group by restaurant_id + language for deduplication
- Consider separate `*_translations` tables if needed

### Challenge 4: Denormalized V1 vs Normalized V2
**Issue:** V1 `menu` table has 30+ customization columns  
**Solution:**
- Extract customization columns → create `dish_customizations` records
- Map each customization type to separate row
- Preserve min/max/free/order values

### Challenge 5: Global vs Restaurant-Specific
**Issue:** V1 shares ingredients globally, V2 has both  
**Solution:**
- Use `is_global` flag in V3
- Global items: `restaurant_id` IS NULL
- Restaurant-specific: `restaurant_id` set
- Deduplication strategy needed

---

## 📊 Data Quality Checks

### Pre-Migration Validation

1. **BLOB Integrity**
   - Check all BLOB columns can be deserialized
   - Log failed deserializations for manual review
   - Validate JSON structure after conversion

2. **Price Format Validation**
   - Ensure all prices are numeric or valid format
   - Check for negative prices
   - Validate price ranges (e.g., small < medium < large)

3. **Foreign Key Validation**
   - Verify all restaurant_id exist in restaurants table
   - Check all course_id references are valid
   - Validate ingredient_group_id links

4. **Multilingual Consistency**
   - Ensure EN/FR pairs exist where expected
   - Check for orphaned translations

---

## 🗓️ Migration Execution Order

### Phase 1: Foundation (Restaurants must be complete)
1. ✅ Restaurants (BLOCKED - in progress by other dev)

### Phase 2: Categories & Templates
2. Global courses (if keeping global concept)
3. Restaurant courses
4. Global ingredient groups
5. Restaurant ingredient groups

### Phase 3: Items & Ingredients
6. Global dishes (templates)
7. Restaurant dishes
8. Global ingredients
9. Restaurant ingredients
10. Ingredient group items (link ingredients to groups)

### Phase 4: Customizations
11. Dish customizations (extracted from V1 menu table and V2 customization table)
12. Custom ingredients

### Phase 5: Combos
13. Combo groups
14. Combo items (link dishes to combos)

### Phase 6: Verification
15. Run all verification queries
16. Sample data review
17. Price validation
18. FK integrity checks

---

## 📝 Notes for Implementation

### V1 to V3 Migration
- **Complexity:** HIGH due to BLOB deserialization
- **Estimated Time:** 2-3 weeks
- **Prerequisites:** Python/PHP deserialization script, staging tables
- **Risk:** BLOB parsing failures (mitigation: extensive logging)

### V2 to V3 Migration
- **Complexity:** MEDIUM (JSON already, but complex structure)
- **Estimated Time:** 1-2 weeks
- **Prerequisites:** JSON parsing logic
- **Risk:** Lower - data already in modern format

### Recommended Approach
1. **Prioritize V2 over V1** - cleaner data, modern format
2. **Use V1 for backfill only** - where V2 data is missing
3. **Validate V2 against V1** - cross-check for data loss
4. **Batch processing** - migrate by restaurant to manage memory
5. **Extensive logging** - track every transformation

---

## 🎯 Success Criteria

- [ ] All courses migrated with correct display_order
- [ ] All dishes with valid prices in JSONB format
- [ ] All customizations properly normalized
- [ ] All ingredient groups and items linked correctly
- [ ] All combos with proper configuration
- [ ] Zero BLOB deserialization failures (or documented exceptions)
- [ ] All FKs valid (no orphaned records)
- [ ] EN/FR pairs maintained where applicable
- [ ] Price ranges validated (small ≤ medium ≤ large)
- [ ] Sample menus rendered correctly for test restaurants

---

**Status:** Planning Complete - Ready for Restaurant Management prerequisite completion

**Next Steps:**
1. Wait for Restaurant Management migration to complete
2. Create V3 schema tables based on this mapping
3. Build PHP/Python deserialization utilities
4. Create detailed migration plans per table group
5. Execute migration following phases above
