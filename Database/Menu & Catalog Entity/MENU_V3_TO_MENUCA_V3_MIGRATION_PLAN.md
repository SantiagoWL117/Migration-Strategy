# Menu Migration: menu_v3 → menuca_v3 Schema Correction

**Date:** October 2, 2025  
**Issue:** Menu data loaded to `menu_v3` instead of `menuca_v3`  
**Impact:** Need to migrate 201,759 rows with proper restaurant FK relationships  
**Safety:** Transaction-based approach with rollback capability

---

## 🎯 Objective

Migrate all menu data from `menu_v3` to `menuca_v3` schema with proper foreign key relationships to `menuca_v3.restaurants(id)`.

---

## 📊 Current State Analysis

### Schema Mismatch
- ❌ **Current:** Data in `menu_v3` schema (standalone)
- ✅ **Target:** Data in `menuca_v3` schema (integrated with restaurants)

### Restaurant ID Mapping Required

**V1 Legacy ID → V3 ID Mapping:**
```sql
menu_v3.dishes.restaurant_id = 79  -- V1 legacy ID
         ↓
menuca_v3.restaurants.legacy_v1_id = 79
         ↓
menuca_v3.restaurants.id = 3  -- New V3 primary key
```

### Data Inventory

| Table | Rows | Unique Restaurants | Restaurant ID Range |
|-------|------|-------------------|---------------------|
| courses | 13,639 | 917 | 1 - 1,678 |
| dishes | 53,809 | 944 | 72 - 1,678 |
| ingredients | 52,305 | 1,105 | 72 - 1,435 |
| ingredient_groups | 13,398 | ? | ? |
| combo_groups | 62,387 | ? | ? |
| combo_items | 2,317 | ? | ? |
| dish_customizations | 3,866 | ? | ? |
| dish_modifiers | 38 | ? | ? |

**Total:** 201,759 rows

### Restaurant Mapping Status

**Available in menuca_v3.restaurants:**
- 940 total restaurants
- 822 with `legacy_v1_id` (87%)
- 591 with `legacy_v2_id` (63%)

**Potential Orphans:**
- Restaurant IDs 72, 73 have dishes but no match in `menuca_v3.restaurants`
- Estimated ~122 restaurants (13%) may be orphaned
- **Decision needed:** Exclude or create placeholder restaurants?

---

## 🏗️ Target Schema Structure

### menuca_v3 Menu Tables (To Be Created)

```sql
-- Core tables with FK to restaurants
menuca_v3.courses (restaurant_id → menuca_v3.restaurants.id)
menuca_v3.dishes (restaurant_id → menuca_v3.restaurants.id)
menuca_v3.ingredients (restaurant_id → menuca_v3.restaurants.id)
menuca_v3.ingredient_groups (restaurant_id → menuca_v3.restaurants.id)
menuca_v3.combo_groups (restaurant_id → menuca_v3.restaurants.id)

-- Junction/detail tables
menuca_v3.combo_items (combo_group_id FK)
menuca_v3.dish_customizations (dish_id FK)
menuca_v3.dish_modifiers (dish_id FK, ingredient_id FK, ingredient_group_id FK)
```

---

## 🔗 Foreign Key Relationships

### Primary FK: restaurants → menu tables
```
menuca_v3.restaurants (id)
    ├── courses (restaurant_id)
    ├── dishes (restaurant_id)
    ├── ingredients (restaurant_id)
    ├── ingredient_groups (restaurant_id)
    └── combo_groups (restaurant_id)
```

### Secondary FKs: menu table relationships
```
courses (id)
    └── dishes (course_id)

dishes (id)
    ├── dish_customizations (dish_id)
    └── dish_modifiers (dish_id)

ingredient_groups (id)
    ├── ingredients (ingredient_group_id)
    └── dish_modifiers (ingredient_group_id)

ingredients (id)
    └── dish_modifiers (ingredient_id)

combo_groups (id)
    └── combo_items (combo_group_id)
```

---

## 📋 Migration Steps

### Phase 1: Schema Creation ✅ READY

**1.1 Copy DDL from menu_v3**
```sql
-- Get existing table definitions
pg_dump with --schema-only for menu_v3 tables
```

**1.2 Modify DDL for menuca_v3**
- Change schema from `menu_v3` to `menuca_v3`
- Update FK constraints to point to `menuca_v3.restaurants(id)`
- Keep all JSONB columns, indexes, constraints
- **ADD:** Source tracking columns (source_system, source_id) if not present

**1.3 Create tables in menuca_v3**
```sql
BEGIN;
  CREATE TABLE menuca_v3.courses (...);
  CREATE TABLE menuca_v3.dishes (...);
  -- etc for all 8 tables
COMMIT;
```

---

### Phase 2: Restaurant ID Mapping ✅ READY

**2.1 Create Mapping Table**
```sql
CREATE TEMP TABLE restaurant_id_mapping AS
SELECT 
    legacy_v1_id as old_id,
    id as new_id,
    name,
    status
FROM menuca_v3.restaurants
WHERE legacy_v1_id IS NOT NULL;

-- Add index for fast lookups
CREATE INDEX idx_temp_old_id ON restaurant_id_mapping(old_id);
```

**2.2 Identify Orphaned Records**
```sql
-- Find restaurant_ids in menu tables that don't exist in mapping
SELECT DISTINCT m.restaurant_id
FROM menu_v3.dishes m
LEFT JOIN restaurant_id_mapping r ON r.old_id = m.restaurant_id
WHERE r.new_id IS NULL
ORDER BY m.restaurant_id;
```

**2.3 Decision: Handle Orphans**

**Option A: Exclude Orphans (RECOMMENDED)**
- Skip records without matching restaurants
- Document excluded records for review
- Clean migration, no data pollution

**Option B: Create Placeholder Restaurant**
- Create "Legacy - Deleted" restaurant entry
- Assign all orphaned records to it
- Preserves all data but requires cleanup later

**Option C: Best-Effort V2 Mapping**
- Check if orphaned V1 IDs match any V2 legacy IDs
- May recover some records
- More complex logic

---

### Phase 3: Data Migration (Transaction-Safe) ✅ READY

**For EACH table, in dependency order:**

#### 3.1 Courses (No dependencies)
```sql
BEGIN;
  INSERT INTO menuca_v3.courses (
    id, 
    restaurant_id,  -- MAPPED!
    name,
    description,
    display_order,
    is_global,
    language,
    availability_schedule,
    created_at,
    updated_at
  )
  SELECT 
    c.id,
    COALESCE(r.new_id, c.restaurant_id) as restaurant_id,  -- Use mapped ID
    c.name,
    c.description,
    c.display_order,
    c.is_global,
    c.language,
    c.availability_schedule,
    c.created_at,
    c.updated_at
  FROM menu_v3.courses c
  LEFT JOIN restaurant_id_mapping r ON r.old_id = c.restaurant_id
  WHERE r.new_id IS NOT NULL  -- Exclude orphans (Option A)
     OR c.restaurant_id IS NULL;  -- Keep global records

  -- Verify count
  SELECT COUNT(*) FROM menuca_v3.courses;
COMMIT;
```

#### 3.2 Ingredient Groups (No dependencies)
```sql
BEGIN;
  INSERT INTO menuca_v3.ingredient_groups (...)
  SELECT ... FROM menu_v3.ingredient_groups ig
  LEFT JOIN restaurant_id_mapping r ON r.old_id = ig.restaurant_id
  WHERE r.new_id IS NOT NULL;

  SELECT COUNT(*) FROM menuca_v3.ingredient_groups;
COMMIT;
```

#### 3.3 Ingredients (Depends on ingredient_groups)
```sql
BEGIN;
  INSERT INTO menuca_v3.ingredients (...)
  SELECT ... FROM menu_v3.ingredients i
  LEFT JOIN restaurant_id_mapping r ON r.old_id = i.restaurant_id
  WHERE r.new_id IS NOT NULL;

  SELECT COUNT(*) FROM menuca_v3.ingredients;
COMMIT;
```

#### 3.4 Combo Groups (No dependencies)
```sql
BEGIN;
  INSERT INTO menuca_v3.combo_groups (...)
  SELECT ... FROM menu_v3.combo_groups cg
  LEFT JOIN restaurant_id_mapping r ON r.old_id = cg.restaurant_id
  WHERE r.new_id IS NOT NULL;

  SELECT COUNT(*) FROM menuca_v3.combo_groups;
COMMIT;
```

#### 3.5 Dishes (Depends on courses)
```sql
BEGIN;
  INSERT INTO menuca_v3.dishes (...)
  SELECT 
    d.id,
    COALESCE(r.new_id, d.restaurant_id) as restaurant_id,  -- Mapped
    d.course_id,  -- Already correct (from courses migration)
    d.name,
    -- ... all other columns
  FROM menu_v3.dishes d
  LEFT JOIN restaurant_id_mapping r ON r.old_id = d.restaurant_id
  WHERE r.new_id IS NOT NULL;

  SELECT COUNT(*) FROM menuca_v3.dishes;
COMMIT;
```

#### 3.6 Combo Items (Depends on combo_groups)
```sql
BEGIN;
  INSERT INTO menuca_v3.combo_items (...)
  SELECT ... FROM menu_v3.combo_items ci
  -- No restaurant_id mapping needed (junction table)
  WHERE combo_group_id IN (SELECT id FROM menuca_v3.combo_groups);

  SELECT COUNT(*) FROM menuca_v3.combo_items;
COMMIT;
```

#### 3.7 Dish Customizations (Depends on dishes)
```sql
BEGIN;
  INSERT INTO menuca_v3.dish_customizations (...)
  SELECT ... FROM menu_v3.dish_customizations dc
  WHERE dish_id IN (SELECT id FROM menuca_v3.dishes);

  SELECT COUNT(*) FROM menuca_v3.dish_customizations;
COMMIT;
```

#### 3.8 Dish Modifiers (Depends on dishes, ingredients, ingredient_groups)
```sql
BEGIN;
  INSERT INTO menuca_v3.dish_modifiers (...)
  SELECT ... FROM menu_v3.dish_modifiers dm
  WHERE dish_id IN (SELECT id FROM menuca_v3.dishes)
    AND ingredient_id IN (SELECT id FROM menuca_v3.ingredients)
    AND ingredient_group_id IN (SELECT id FROM menuca_v3.ingredient_groups);

  SELECT COUNT(*) FROM menuca_v3.dish_modifiers;
COMMIT;
```

---

### Phase 4: Validation ✅ READY

**4.1 Row Count Verification**
```sql
SELECT 
    'courses' as table_name,
    (SELECT COUNT(*) FROM menu_v3.courses) as source_count,
    (SELECT COUNT(*) FROM menuca_v3.courses) as target_count,
    (SELECT COUNT(*) FROM menu_v3.courses c 
     LEFT JOIN restaurant_id_mapping r ON r.old_id = c.restaurant_id 
     WHERE r.new_id IS NOT NULL OR c.restaurant_id IS NULL) as expected_count
UNION ALL
-- Repeat for all 8 tables
```

**4.2 Foreign Key Integrity**
```sql
-- Check for orphaned dishes (course_id not in courses)
SELECT COUNT(*) FROM menuca_v3.dishes d
LEFT JOIN menuca_v3.courses c ON c.id = d.course_id
WHERE d.course_id IS NOT NULL AND c.id IS NULL;
-- Should be 0

-- Check for orphaned dish_modifiers
SELECT COUNT(*) FROM menuca_v3.dish_modifiers dm
LEFT JOIN menuca_v3.dishes d ON d.id = dm.dish_id
WHERE d.id IS NULL;
-- Should be 0

-- Repeat for all FK relationships
```

**4.3 Restaurant Mapping Verification**
```sql
-- Verify all restaurant_ids are valid V3 IDs
SELECT 
    'courses' as table_name,
    COUNT(*) as total,
    COUNT(DISTINCT restaurant_id) as unique_restaurants,
    MIN(restaurant_id) as min_id,
    MAX(restaurant_id) as max_id
FROM menuca_v3.courses
UNION ALL
-- Repeat for all tables

-- Verify no V1 legacy IDs remain
SELECT * FROM menuca_v3.dishes
WHERE restaurant_id NOT IN (SELECT id FROM menuca_v3.restaurants)
LIMIT 10;
-- Should be empty
```

**4.4 Sample Data Validation**
```sql
-- Check specific restaurants to verify mapping worked
SELECT 
    r.id as v3_id,
    r.name,
    r.legacy_v1_id,
    COUNT(DISTINCT c.id) as courses,
    COUNT(DISTINCT d.id) as dishes
FROM menuca_v3.restaurants r
LEFT JOIN menuca_v3.courses c ON c.restaurant_id = r.id
LEFT JOIN menuca_v3.dishes d ON d.restaurant_id = r.id
WHERE r.legacy_v1_id IN (79, 81, 82, 87, 89)
GROUP BY r.id, r.name, r.legacy_v1_id
ORDER BY r.id;
```

**4.5 JSONB Data Integrity**
```sql
-- Verify JSONB columns migrated correctly
SELECT 
    COUNT(*) as total_dishes,
    COUNT(CASE WHEN prices IS NOT NULL THEN 1 END) as with_prices,
    COUNT(CASE WHEN availability_schedule IS NOT NULL THEN 1 END) as with_schedules
FROM menuca_v3.dishes;
```

---

### Phase 5: Cleanup ✅ READY

**5.1 Drop menu_v3 Schema (AFTER FULL VALIDATION)**
```sql
-- ONLY after 100% verification!
BEGIN;
  DROP SCHEMA menu_v3 CASCADE;
COMMIT;
```

**5.2 Generate Orphan Report**
```sql
-- Document which records were excluded
SELECT 
    'dishes' as table_name,
    m.restaurant_id as orphaned_v1_id,
    COUNT(*) as excluded_count,
    STRING_AGG(DISTINCT m.name, ', ') as sample_items
FROM menu_v3.dishes m
LEFT JOIN restaurant_id_mapping r ON r.old_id = m.restaurant_id
WHERE r.new_id IS NULL
GROUP BY m.restaurant_id
ORDER BY excluded_count DESC;
-- Save to CSV for review
```

**5.3 Update Memory Bank**
- Document schema correction in Phase 4 report
- Add note about restaurant ID mapping
- Record orphaned record counts

---

## 🚨 Rollback Strategy

**If ANY step fails:**

```sql
-- Each phase is in a transaction
ROLLBACK;

-- Verify menuca_v3 tables are empty/unchanged
SELECT COUNT(*) FROM menuca_v3.courses;  -- Should be 0

-- menu_v3 data remains intact
SELECT COUNT(*) FROM menu_v3.courses;  -- Should be 13,639
```

**Complete Rollback:**
```sql
BEGIN;
  DROP TABLE IF EXISTS menuca_v3.dish_modifiers CASCADE;
  DROP TABLE IF EXISTS menuca_v3.dish_customizations CASCADE;
  DROP TABLE IF EXISTS menuca_v3.combo_items CASCADE;
  DROP TABLE IF EXISTS menuca_v3.dishes CASCADE;
  DROP TABLE IF EXISTS menuca_v3.ingredients CASCADE;
  DROP TABLE IF EXISTS menuca_v3.combo_groups CASCADE;
  DROP TABLE IF EXISTS menuca_v3.ingredient_groups CASCADE;
  DROP TABLE IF EXISTS menuca_v3.courses CASCADE;
COMMIT;

-- Original data still in menu_v3
```

---

## 📊 Expected Outcomes

### Success Criteria

| Metric | Target | Validation Query |
|--------|--------|-----------------|
| Tables created | 8 | `SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='menuca_v3'` |
| Row count match | ~175K-180K (after orphan exclusion) | Sum of all menuca_v3 table counts |
| FK violations | 0 | All FK integrity checks pass |
| Restaurant mapping | 100% of valid records | No V1 legacy IDs in restaurant_id columns |
| JSONB integrity | 100% | All JSONB columns queryable |

### Data Loss Estimate

**Orphaned Records (No restaurant match):**
- Estimated: 10-15% of records
- Reason: Restaurants deleted/archived before V3 migration
- Mitigation: Generate detailed orphan report for manual review
- **Alternative:** Create placeholder restaurant if data must be preserved

**Expected Final Counts:**
- Courses: ~12,000 (from 13,639)
- Dishes: ~47,000 (from 53,809)
- Ingredients: ~45,000 (from 52,305)
- Other tables: Proportional reduction

---

## 🎯 Execution Checklist

### Pre-Migration
- [ ] Read entire plan
- [ ] Verify `menuca_v3.restaurants` data is complete
- [ ] Backup `menu_v3` schema (pg_dump)
- [ ] Decide on orphan handling strategy (A/B/C)
- [ ] Allocate 2-4 hours for migration

### During Migration
- [ ] Phase 1: Create menuca_v3 tables (DDL)
- [ ] Phase 2: Create restaurant ID mapping table
- [ ] Phase 2: Identify and review orphaned records
- [ ] Phase 3: Migrate data (8 tables in order)
- [ ] Phase 4: Run all validation queries
- [ ] Phase 4: Spot-check sample data
- [ ] Phase 5: Generate orphan report

### Post-Migration
- [ ] Update application connection strings (if needed)
- [ ] Drop `menu_v3` schema (after 100% confirmation)
- [ ] Update memory bank documentation
- [ ] Create MIGRATION_COMPLETE.md report
- [ ] Commit all changes to git

---

## 🚀 Recommendation

**Stay in Current Chat:** ✅ YES
- All context already loaded
- Can execute immediately
- Real-time validation feedback

**Execution Order:**
1. Review this plan
2. Decide on orphan handling (recommend: exclude & report)
3. Execute Phase 1 (create tables)
4. Execute Phase 2 (mapping)
5. Execute Phase 3 (migrate data, one table at a time)
6. Execute Phase 4 (full validation)
7. Execute Phase 5 (cleanup)

**Total Time:** 2-3 hours with validation

---

## 📝 Notes

- All migration queries use transactions for safety
- Each table migration is independent (can retry individually)
- Restaurant ID mapping is the critical transformation
- JSONB columns should migrate without modification
- Source tracking columns (source_system, source_id) already exist

---

**Ready to proceed?** Say "Let's migrate!" and I'll start with Phase 1. 🚀

