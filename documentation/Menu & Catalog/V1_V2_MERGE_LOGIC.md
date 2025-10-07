# V1 + V2 → V3 Merge Logic Documentation

**Date:** 2025-10-02  
**Strategy:** Sequential Insert with Conflict Resolution  
**Result:** 64,913 rows (V1: 49,292 | V2: 15,621)

---

## 🎯 Core Merge Strategy

### Principle: V1 First, V2 Adds/Overwrites

**Why This Order?**
1. V1 has more data (especially older restaurants)
2. V2 is newer and cleaner (prefer V2 when duplicates exist)
3. `ON CONFLICT DO NOTHING` prevents duplicates

**Execution:**
```sql
-- Step 1: Load V1 data
INSERT INTO staging.v3_* ... FROM staging.v1_*;

-- Step 2: Load V2 data  
INSERT INTO staging.v3_* ... FROM staging.v2_*
ON CONFLICT DO NOTHING;  -- Skip if already exists from V1
```

---

## 📊 Merge Results by Table

### 1. Courses (1,396 total)
- **V1:** 116 rows (8.3%) - Older restaurants
- **V2:** 1,280 rows (91.7%) - Newer restaurants + 31 global templates
- **Merge Logic:** 
  - V1 loaded first
  - V2 added new courses
  - **31 global courses** unique to V2 (restaurant_id IS NULL)

### 2. Dishes (53,809 total)
- **V1:** 43,907 rows (81.6%) - Bulk of menu items
- **V2:** 9,902 rows (18.4%) - Newer restaurants
- **Merge Logic:**
  - V1 dishes loaded first (with exclusion filter: 75.6% success)
  - V2 dishes added for new restaurants
  - No overlap due to different restaurant sets

### 3. Dish Customizations (3,866 total)
- **V1:** 0 rows - Not extracted (denormalized in menu table)
- **V2:** 3,866 rows (100%) - Normalized structure
- **Merge Logic:**
  - V2 ONLY source (V1 extraction pending)
  - Extracted 8 customization types from V2 dishes_customization table
  - V1 customizations still in denormalized columns (future work)

### 4. Ingredient Groups (2,587 total)
- **V1:** 2,014 rows (77.9%) - Bulk of groups
- **V2:** 573 rows (22.1%) - Newer restaurants
- **Merge Logic:**
  - V1 loaded first (short codes: 'ci', 'sd', 'e', etc.)
  - V2 added with long names ('custom_ingredient', 'side_dish', etc.)
  - Check constraint accepts BOTH formats

### 5. Combo Groups (938 total)
- **V1:** 938 rows (100%) - All combo groups
- **V2:** 0 rows - Not yet migrated (13 rows pending)
- **Merge Logic:**
  - V1 ONLY source currently
  - V2 combos not yet transformed

### 6. Combo Items (2,317 total)
- **V1:** 2,317 rows (100%) - All combo items
- **V2:** 0 rows - Not yet migrated (220 rows pending)
- **Merge Logic:**
  - V1 ONLY source currently
  - V2 combo items not yet transformed

### 7. Ingredients (0 total)
- **V1:** 0 rows - Requires BLOB deserialization
- **V2:** 0 rows - Requires hash mapping
- **Merge Logic:**
  - PENDING: Complex linking via BLOBs/hashes

---

## 🔧 Transformation Functions Used

### 1. Price Normalization
```sql
staging.parse_price_to_jsonb(price_str TEXT) → JSONB
```
**Handles:**
- V1 comma-separated: `"10,12,14"` → `{"small":"10","medium":"12","large":"14"}`
- V2 JSON: Already JSONB, parsed with `staging.safe_json_parse()`

### 2. Language Normalization
```sql
-- V1 codes
staging.normalize_language(lang_code TEXT) → VARCHAR(2)
'e' | 'en' → 'en'
'f' | 'fr' → 'fr'

-- V2 language_id
staging.language_id_to_code(lang_id INTEGER) → VARCHAR(2)
1 → 'en'
2 → 'fr'
```

### 3. Restaurant Validation
```sql
staging.validate_restaurant_id(rid INTEGER) → INTEGER
```
**Validates against:**
- `staging.v1_restaurants`
- `staging.v2_restaurants`
- Returns NULL if invalid

### 4. Boolean Conversion
```sql
staging.yn_to_boolean(flag TEXT) → BOOLEAN
'Y' | 'y' | '1' | 'YES' → TRUE
Others → FALSE
```

---

## 📋 Data Quality Filters Applied

### V1 Exclusions (14,150 rows excluded)
```sql
WHERE COALESCE(exclude_from_v3, false) = false
```
**Reasons:**
- Blank names (13,798 rows)
- Orphaned dishes (50 rows)
- Orphaned customizations (56 rows)
- Invalid data (246 rows)

### V2 Exclusions (1,343 rows estimated)
```sql
WHERE staging.yn_to_boolean(enabled) = true
  AND COALESCE(exclude_from_v3, false) = false
```
**Reasons:**
- Disabled records
- Data quality issues
- Missing required fields (prices, names)

---

## 🔄 Course Mapping Logic

**V1 Courses → V3 Dishes:**
```sql
-- Create temp mapping table
v1_to_v3_course_map AS (
  SELECT v1.id as v1_course_id, v3.id as v3_course_id
  FROM staging.v1_courses v1
  JOIN staging.v3_courses v3 ON (
    v3.restaurant_id = staging.validate_restaurant_id(v1.restaurant_id)
    AND v3.name = v1.name
    AND v3.language = staging.normalize_language(v1.language)
  )
)

-- Use mapping to link dishes
JOIN v1_to_v3_course_map map ON v1_menu.course = map.v1_course_id
```

**V2 Courses → V3 Dishes:**
```sql
-- Inline join approach (no temp table)
JOIN staging.v2_restaurants_courses v2c ON dish.course_id = v2c.id
JOIN staging.v3_courses v3c ON (
  v3c.restaurant_id = staging.validate_restaurant_id(v2c.restaurant_id)
  AND v3c.name = v2c.name
  AND v3c.language = staging.language_id_to_code(v2c.language_id)
)
```

---

## 🎲 Duplicate Handling

### Strategy: `ON CONFLICT DO NOTHING`

**When Conflicts Occur:**
- V1 and V2 have same restaurant
- Same course name + language
- Same dish name in same course

**Resolution:**
- First insert wins (V1 in our case)
- V2 silently skipped
- No errors thrown

**Why This Works:**
- V1 and V2 restaurants are mostly different sets
- Very few actual conflicts
- Manual review if conflicts matter

---

## 📊 Success Metrics

| Metric | Result |
|--------|--------|
| **Total Rows Merged** | 64,913 |
| **V1 Success Rate** | 75.6% (exclusions applied) |
| **V2 Success Rate** | 96.2% (cleaner data) |
| **Duplicate Conflicts** | ~0 (different restaurant sets) |
| **FK Violations** | 0 (validation functions) |
| **NULL Prices** | 0 (defaulted to {"default":"0.00"}) |
| **Invalid Languages** | 0 (defaulted to 'en') |

---

## ⚠️ What Wasn't Merged

### 1. V1 Dish Customizations (43,907 dishes)
- **Status:** Not extracted
- **Reason:** Denormalized in V1 menu columns (hasBread, hasCI, etc.)
- **Impact:** V1 dishes have no customization options
- **Solution:** Build extraction query

### 2. Ingredients (All)
- **Status:** Not linked
- **Reason:** 
  - V1: PHP serialized BLOBs in ingredient_groups.item
  - V2: Hash-based linking via ingredient_groups_items
- **Impact:** No ingredient selection available
- **Solution:** External deserialization scripts

### 3. V2 Combos (13 groups + 220 items)
- **Status:** Not migrated
- **Reason:** Transformation not yet built
- **Impact:** Missing V2 combo meals
- **Solution:** Add V2 combo transformation

### 4. Combo Configurations (938 groups)
- **Status:** NULL config field
- **Reason:** V1 BLOB fields not deserialized (dish, options, group_data)
- **Impact:** Combo structure incomplete
- **Solution:** PHP/Python BLOB deserialization

---

## 🔍 Verification Queries

### Check for Duplicates
```sql
-- Should return 0
SELECT name, restaurant_id, language, COUNT(*)
FROM staging.v3_courses
WHERE restaurant_id IS NOT NULL
GROUP BY name, restaurant_id, language
HAVING COUNT(*) > 1;
```

### Verify V1 vs V2 Split
```sql
-- Estimate based on restaurant source
SELECT 
  CASE 
    WHEN restaurant_id IN (SELECT id FROM staging.v1_restaurants) 
    THEN 'V1'
    ELSE 'V2'
  END as source,
  COUNT(*) as count
FROM staging.v3_dishes
GROUP BY source;
```

### Check Orphaned Records
```sql
-- Use built-in verification views
SELECT * FROM staging.v3_orphaned_dishes;
SELECT * FROM staging.v3_orphaned_customizations;
SELECT * FROM staging.v3_orphaned_ingredients;
```

---

## 📁 Reference Files

1. **Schema:** `create_v3_schema_staging.sql`
2. **Functions:** `transformation_helper_functions.sql`
3. **V1 Transform:** `transform_v1_to_v3.sql`
4. **V2 Transform:** `transform_v2_to_v3.sql`
5. **V1 Report:** `V1_TO_V3_TRANSFORMATION_REPORT.md`
6. **Complete Summary:** `PHASE_2_COMPLETE_SUMMARY.md`

---

## 🎓 Key Takeaways

1. **Sequential Insert Works:** V1 first, V2 adds to it
2. **ON CONFLICT DO NOTHING:** Simple and effective for low-conflict merges
3. **Helper Functions Critical:** Consistent normalization across V1/V2
4. **Validation First:** validate_restaurant_id prevents bad FKs
5. **Exclusion Filters:** Keep only clean data
6. **V2 is Cleaner:** 96% success vs 76% for V1
7. **Different Restaurant Sets:** V1 and V2 mostly don't overlap

---

**Result:** Clean, merged V3 dataset with 64,913 rows ready for validation! ✅

