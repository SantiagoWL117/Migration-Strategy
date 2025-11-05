# V1 Active Restaurants Migration Plan

**Date:** October 31, 2025  
**Status:** 📋 **PLANNING**  
**Objective:** Migrate V1 active restaurant data, handling V1/V2 overlaps

---

## 🎯 Strategy Overview

**Approach:** Focus on V1 active restaurants first, since:
1. These are the restaurants that should have data
2. Most are missing dishes (98.48% migration rate suggests gaps)
3. Some overlap with V2 data (need conflict resolution strategy)

---

## 📊 V1 Active Restaurants Analysis

### Summary Statistics

**Total V1 Active Restaurants:** 132
- **With V2 Data:** TBD (need query results)
- **V1 Only:** TBD (need query results)
- **Has Dishes:** 130 (98.48%)
- **Missing Dishes:** 2 (1.52%)

---

## 🔍 Overlap Analysis Strategy

### Type 1: V1 Only Restaurants (No V2 Data)

**Strategy:** 
- ✅ **Direct Migration** - No conflicts
- Load V1 data → Create courses → Create dishes → Create prices
- Use V1 as source of truth

**Handling:**
- Map V1 categories → V3 courses
- Map V1 menu items → V3 dishes
- Parse V1 prices → V3 dish_prices
- Preserve `legacy_v1_id` for audit trail

### Type 2: V1 + V2 Overlap (Both Have Data)

**Strategy:** 
- ⚠️ **Merge Strategy** - Need conflict resolution rules
- V2 data already migrated, V1 data missing
- Decision: **Supplement V2 with V1** or **Replace V2 with V1**?

**Conflict Resolution Options:**

#### Option A: V2 Priority (Keep Existing, Add Missing)
- **Logic:** V2 data is more recent/normalized
- **Action:** Only add V1 dishes that don't exist in V2
- **Pros:** Preserves existing V2 migration work
- **Cons:** May miss V1-only items that are better/unique

#### Option B: V1 Priority (Replace with V1, Keep V2 as Backup)
- **Logic:** V1 is source of truth for active restaurants
- **Action:** Replace dishes with V1 versions, keep V2 as reference
- **Pros:** Ensures V1 active data is accurate
- **Cons:** Loses V2 improvements/normalization

#### Option C: Merge Strategy (Combine Both)
- **Logic:** Best of both worlds
- **Action:** 
  - Keep V2 dishes that match V1 names
  - Add V1 dishes that don't exist in V2
  - Use V1 prices if different
  - Mark source_system for audit
- **Pros:** Comprehensive, preserves both sources
- **Cons:** More complex, may have duplicates

**Recommended:** **Option C (Merge Strategy)** - Preserves both data sources, marks conflicts for review

---

## 📋 Migration Plan

### Phase 1: Data Discovery (READ-ONLY)

**Step 1: Get V1 Active Restaurant List**
```sql
-- Export list of V1 active restaurants
SELECT 
    arm.old_restaurant_id as v1_id,
    arm.new_restaurant_id as v3_id,
    arm.restaurant_name,
    r.legacy_v2_id as v2_id,
    CASE 
        WHEN r.legacy_v2_id IS NOT NULL THEN 'OVERLAP'
        ELSE 'V1_ONLY'
    END as type
FROM archive.restaurant_id_mapping arm
LEFT JOIN menuca_v3.restaurants r ON r.id = arm.new_restaurant_id
WHERE arm.status = 'active'
ORDER BY type, arm.restaurant_name;
```

**Step 2: Verify V1 Data Availability**
- Check if V1 dump files contain these restaurant IDs
- Verify menu/course/ingredient data exists
- Sample a few restaurants to preview data structure

**Step 3: Identify Overlaps**
- List restaurants with both V1 and V2 data
- Compare dish counts (V2 current vs V1 expected)
- Flag potential conflicts for review

### Phase 2: Conflict Resolution Strategy

**For V1+V2 Overlaps:**

1. **Dish Name Matching:**
   - Match V1 dishes to V2 dishes by name (case-insensitive)
   - If match found: Keep V2 dish, update with V1 price if different
   - If no match: Add V1 dish as new

2. **Course Mapping:**
   - Match V1 categories to V2 courses by name
   - If match found: Use existing V3 course
   - If no match: Create new course from V1 category

3. **Price Handling:**
   - V1 prices: Parse multi-size strings (e.g., "11.86,16.06,20.26")
   - V2 prices: Already normalized in dish_prices
   - Strategy: Use V1 prices if V2 prices missing or $0.00

4. **Source Tracking:**
   - Mark dishes: `source_system = 'V1_MERGED'` or `'V2_MERGED'`
   - Preserve: `legacy_v1_id` and `legacy_v2_id` for audit

### Phase 3: V1 Data Loading

**Step 1: Load V1 Data into temp_migration**
- Load all V1 active restaurants (ignore other statuses for now)
- Use explicit type casting: `CAST(restaurant AS INTEGER)`
- Handle errors gracefully, log failures

**Step 2: Create Staging Tables**
- `temp_v1_courses` - V1 categories → V3 courses mapping
- `temp_v1_dishes` - V1 menu items → V3 dishes mapping
- `temp_v1_prices` - V1 prices → V3 dish_prices mapping

**Step 3: Data Transformation**
- Parse multi-size prices into separate rows
- Normalize course names (trim, lowercase for matching)
- Handle special characters, encoding issues

### Phase 4: Migration Execution

**For V1-Only Restaurants:**
```sql
-- Direct migration, no conflicts
INSERT INTO menuca_v3.courses (...)
SELECT ... FROM temp_migration.v1_menu
WHERE restaurant = <v1_id>
ON CONFLICT DO NOTHING;

INSERT INTO menuca_v3.dishes (...)
SELECT ... FROM temp_migration.v1_menu
WHERE restaurant = <v1_id>
ON CONFLICT DO UPDATE ...;
```

**For V1+V2 Overlaps:**
```sql
-- Merge strategy
-- 1. Add missing courses
INSERT INTO menuca_v3.courses (...)
SELECT ... FROM temp_v1_courses
WHERE NOT EXISTS (
    SELECT 1 FROM menuca_v3.courses c 
    WHERE c.restaurant_id = <v3_id> 
    AND LOWER(TRIM(c.name)) = LOWER(TRIM(temp_v1_courses.name))
);

-- 2. Add missing dishes (by name matching)
INSERT INTO menuca_v3.dishes (...)
SELECT ... FROM temp_v1_dishes
WHERE NOT EXISTS (
    SELECT 1 FROM menuca_v3.dishes d 
    WHERE d.restaurant_id = <v3_id>
    AND LOWER(TRIM(d.name)) = LOWER(TRIM(temp_v1_dishes.name))
);

-- 3. Update prices for existing dishes (if V1 price is different)
UPDATE menuca_v3.dish_prices dp
SET price = temp_v1_prices.price,
    source_system = 'V1_MERGED',
    updated_at = NOW()
FROM temp_v1_prices
WHERE dp.dish_id = temp_v1_prices.dish_id
    AND dp.price != temp_v1_prices.price;
```

### Phase 5: Verification

**Verify Each Restaurant:**
1. Course count matches V1 categories
2. Dish count matches V1 menu items (±10% tolerance for duplicates)
3. Price count matches V1 price strings
4. No orphaned records (dishes without courses, prices without dishes)

**Generate Report:**
- Restaurants migrated: X
- Dishes added: Y
- Courses added: Z
- Conflicts resolved: W
- Failures: List with reasons

---

## 🔧 Technical Implementation

### Step 1: Get V1 Active Restaurant List

**Query to Export:**
```sql
SELECT 
    arm.old_restaurant_id as v1_restaurant_id,
    arm.new_restaurant_id as v3_restaurant_id,
    arm.restaurant_name,
    r.legacy_v2_id as v2_restaurant_id,
    CASE 
        WHEN r.legacy_v2_id IS NOT NULL THEN 'OVERLAP_WITH_V2'
        ELSE 'V1_ONLY'
    END as migration_type,
    (SELECT COUNT(*) FROM menuca_v3.dishes d WHERE d.restaurant_id = arm.new_restaurant_id AND d.deleted_at IS NULL) as current_dish_count
FROM archive.restaurant_id_mapping arm
LEFT JOIN menuca_v3.restaurants r ON r.id = arm.new_restaurant_id
WHERE arm.status = 'active'
ORDER BY migration_type, arm.restaurant_name;
```

**Export Format:** CSV or copy/paste into text file

### Step 2: Load V1 Data (Filtered by Restaurant List)

**Approach:** Load only V1 active restaurants into temp_migration

```sql
-- Create filtered temp table
CREATE TEMP TABLE temp_v1_active_restaurants AS
SELECT old_restaurant_id 
FROM archive.restaurant_id_mapping
WHERE status = 'active';

-- Load V1 data (filtered)
INSERT INTO temp_migration.v1_menu (...)
SELECT ... FROM <v1_source>
WHERE CAST(restaurant AS INTEGER) IN (
    SELECT old_restaurant_id FROM temp_v1_active_restaurants
);
```

### Step 3: Conflict Detection Query

```sql
-- Find V1+V2 overlaps with dish conflicts
SELECT 
    r.id as v3_restaurant_id,
    r.name,
    r.legacy_v1_id,
    r.legacy_v2_id,
    (SELECT COUNT(*) FROM menuca_v3.dishes d WHERE d.restaurant_id = r.id AND d.deleted_at IS NULL) as v2_dish_count,
    (SELECT COUNT(*) FROM temp_migration.v1_menu v1m WHERE CAST(v1m.restaurant AS INTEGER) = r.legacy_v1_id) as v1_menu_count,
    (SELECT COUNT(*) FROM temp_migration.v1_menu v1m 
     WHERE CAST(v1m.restaurant AS INTEGER) = r.legacy_v1_id
     AND NOT EXISTS (
         SELECT 1 FROM menuca_v3.dishes d 
         WHERE d.restaurant_id = r.id 
         AND LOWER(TRIM(d.name)) = LOWER(TRIM(v1m.name))
     )) as v1_only_dishes
FROM menuca_v3.restaurants r
WHERE r.legacy_v1_id IS NOT NULL
    AND r.legacy_v2_id IS NOT NULL
    AND EXISTS (
        SELECT 1 FROM archive.restaurant_id_mapping arm
        WHERE arm.new_restaurant_id = r.id
        AND arm.status = 'active'
    );
```

---

## 📊 Expected Results

### V1-Only Restaurants
- **Expected:** Full migration (courses + dishes + prices)
- **No conflicts:** Direct insert
- **Success Rate:** Should be 100% (no existing data to conflict)

### V1+V2 Overlaps
- **Expected:** Merge (add missing, update prices)
- **Conflicts:** Handle by name matching
- **Success Rate:** Depends on merge strategy

---

## ⚠️ Risk Mitigation

### Risk 1: Duplicate Dishes
**Mitigation:** Use `ON CONFLICT (restaurant_id, name, course_id)` with name normalization

### Risk 2: Price Conflicts
**Mitigation:** Use V1 prices if V2 prices are $0.00 or missing, otherwise keep V2

### Risk 3: Course Name Mismatches
**Mitigation:** Fuzzy matching or manual mapping table for common variations

### Risk 4: Data Quality Issues
**Mitigation:** Validate before migration, log failures, manual review for edge cases

---

## 📋 Next Steps

1. **Export V1 Active Restaurant List** (use query above)
2. **Verify V1 Data Availability** (check dump files)
3. **Decide on Merge Strategy** (Option A, B, or C)
4. **Create Migration Script** (with conflict resolution)
5. **Test with 1-2 Restaurants** (dry run)
6. **Execute Full Migration** (all V1 active restaurants)
7. **Verify Results** (generate report)

---

## 🔍 Verification Queries

### Check Migration Success
```sql
SELECT 
    arm.status,
    COUNT(DISTINCT arm.new_restaurant_id) as total,
    COUNT(DISTINCT arm.new_restaurant_id) FILTER (WHERE EXISTS (
        SELECT 1 FROM menuca_v3.dishes d 
        WHERE d.restaurant_id = arm.new_restaurant_id AND d.deleted_at IS NULL
    )) as with_dishes,
    ROUND(100.0 * COUNT(DISTINCT arm.new_restaurant_id) FILTER (WHERE EXISTS (
        SELECT 1 FROM menuca_v3.dishes d 
        WHERE d.restaurant_id = arm.new_restaurant_id AND d.deleted_at IS NULL
    )) / COUNT(DISTINCT arm.new_restaurant_id), 2) as success_rate
FROM archive.restaurant_id_mapping arm
WHERE arm.status = 'active'
GROUP BY arm.status;
```

### Check Overlap Handling
```sql
SELECT 
    CASE 
        WHEN r.legacy_v2_id IS NOT NULL THEN 'Has V2 Data'
        ELSE 'V1 Only'
    END as type,
    COUNT(*) as restaurant_count,
    AVG((SELECT COUNT(*) FROM menuca_v3.dishes d WHERE d.restaurant_id = r.id AND d.deleted_at IS NULL)) as avg_dishes
FROM menuca_v3.restaurants r
JOIN archive.restaurant_id_mapping arm ON arm.new_restaurant_id = r.id
WHERE arm.status = 'active'
GROUP BY type;
```

---

**Report Generated:** October 31, 2025  
**Status:** 📋 **READY FOR EXECUTION**  
**Next Step:** Export V1 active restaurant list and verify data availability

