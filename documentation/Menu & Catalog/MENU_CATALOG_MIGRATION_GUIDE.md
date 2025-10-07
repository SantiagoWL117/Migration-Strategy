# Menu & Catalog Migration Guide

**Entity**: Menu & Catalog  
**Purpose**: Restaurant menu items, courses, ingredients, modifiers, and combo configurations  
**Status**: 🔄 **UNDER REVIEW**  
**Complexity**: 🔴 HIGH (BLOB deserialization, complex relationships, 380K+ rows)  
**Timeline**: TBD  
**Dependencies**: ✅ Restaurant Management (complete)  
**Created**: 2025-01-07  
**Last Updated**: 2025-01-07

---

## 📋 Table of Contents

1. [Executive Summary](#executive-summary)
2. [Current State Assessment](#current-state-assessment)
3. [Source Data Inventory](#source-data-inventory)
4. [V3 Schema Analysis](#v3-schema-analysis)
5. [BLOB Data Analysis](#blob-data-analysis)
6. [Data Quality Concerns](#data-quality-concerns)
7. [Migration Strategy](#migration-strategy)
8. [Phase Plan](#phase-plan)
9. [Verification Queries](#verification-queries)
10. [Critical Decisions](#critical-decisions)

---

## Executive Summary

### What is Menu & Catalog?

Menu & Catalog manages all menu-related data for restaurants:
- **Courses**: Menu categories (Appetizers, Entrees, Desserts, etc.)
- **Dishes**: Individual menu items with pricing and descriptions
- **Ingredients**: Toppings, modifiers, and add-ons
- **Ingredient Groups**: Organized collections of ingredients (e.g., "Cheese Options", "Sauces")
- **Combo Groups**: Meal deal configurations
- **Customizations**: Dish-specific modifier rules (V2 only)

### Critical Challenge

This entity contains **BLOB (Binary Large Object) data** that stores complex configurations as PHP-serialized strings. This data must be deserialized and transformed into structured JSONB format for V3.

**BLOB Columns Identified:**
1. `v1_menu.hideOnDays` - Day-based availability rules
2. `v1_menuothers.content` - Modifier pricing and relationships
3. `v1_ingredient_groups.item` - Ingredient lists
4. `v1_combo_groups.options` - Combo configurations

---

## Current State Assessment

### menuca_v3 Tables (Existing Data)

| Table | Rows | Status | Concern Level |
|-------|------|--------|---------------|
| courses | 12,194 | ✅ | LOW - Reasonable count |
| dishes | 42,930 | ⚠️ | **HIGH** - Only 36% of expected |
| ingredients | 45,176 | ✅ | LOW - Near expected count |
| ingredient_groups | 9,572 | ⚠️ | MEDIUM - 72% of source |
| combo_groups | 8,341 | ⚠️ | MEDIUM - 13% of source (but V1 has duplicates) |
| combo_items | 2,317 | ✅ | LOW - Matches combos table |
| dish_customizations | 310 | 🚨 | **CRITICAL** - Only 2.3% of V2 source |
| dish_modifiers | 8 | 🚨 | **CRITICAL** - Missing BLOB data |

**Key Findings:**
- ✅ **Courses & Ingredients**: Appear complete
- ⚠️ **Dishes**: Missing ~85,000 rows (potential data loss)
- 🚨 **Customizations**: 99.9% missing from V2 source
- 🚨 **BLOB Data**: Minimal evidence of deserialization

---

## Source Data Inventory

### V1 Tables (7 tables, 345,383 rows)

| # | Table | Rows | Key Columns | BLOB Columns | Notes |
|---|-------|------|-------------|--------------|-------|
| 1 | `courses` | 12,924 | id, name, restaurant, timePeriod | None | Menu categories |
| 2 | `menu` | 117,666 | id, course, restaurant, name, price (73 cols total) | `hideOnDays` | **Main dishes table** |
| 3 | `menuothers` | 70,363 | id, restaurant, dishId, type | `content` | **Side dishes, drinks, extras** |
| 4 | `ingredients` | 52,303 | id, restaurant, name, price | None | Toppings & modifiers |
| 5 | `ingredient_groups` | 13,252 | id, name, type, course, dish | `item`, `price` | Modifier groups |
| 6 | `combo_groups` | 62,344 | id, name, restaurant | `dish`, `options`, `group` | Combo configurations |
| 7 | `combos` | 16,461 | id, dish, group | None | Junction table |

**Total V1 Rows**: 345,383

### V2 Tables (10 tables, 36,636 rows)

| # | Table | Rows | Key Columns | JSON/BLOB Columns | Notes |
|---|-------|------|-------------|-------------------|-------|
| 1 | `global_courses` | 33 | id, name | None | Global course templates |
| 2 | `global_ingredients` | 5,023 | id, name, language_id | None | Global ingredient library |
| 3 | `restaurants_courses` | 1,269 | id, restaurant_id, name | `available_for` (JSON) | Restaurant-specific courses |
| 4 | `restaurants_dishes` | 10,288 | id, course_id, name, price | `size_j`, `price_j` (JSON) | **Modern dishes table** |
| 5 | `restaurants_dishes_customization` | 13,405 | id, dish_id, has_customization | Multiple JSON columns | **Advanced customizations** |
| 6 | `restaurants_ingredients` | 2,681 | id, restaurant_id, name | None | Restaurant-specific ingredients |
| 7 | `restaurants_ingredient_groups` | 588 | id, restaurant_id, group_name | `items` (BLOB) | Ingredient group configs |
| 8 | `restaurants_ingredient_groups_items` | 3,108 | id, group_id, item_hash | `price_j` (JSON) | Group item pricing |
| 9 | `restaurants_combo_groups` | 220 | id, restaurant_id, group_name | None | V2 combo groups |
| 10 | `restaurants_combo_groups_items` | 220 | id, group_id, item_count | Multiple JSON columns | V2 combo configurations |

**Total V2 Rows**: 36,636

**GRAND TOTAL**: 382,019 rows

---

## V3 Schema Analysis

### Existing menuca_v3 Tables

#### 1. `menuca_v3.courses` (10 columns)
```sql
-- Core fields: id, uuid, restaurant_id, name, description
-- Config fields: display_order, time_period_id, is_active
-- Audit fields: created_at, updated_at
```

#### 2. `menuca_v3.dishes` (15 columns)
```sql
-- Core fields: id, uuid, restaurant_id, course_id, name, description
-- Pricing fields: base_price, size_options (JSONB), price_matrix (JSONB)
-- Config fields: display_order, image_url, is_combo, has_customization
-- Audit fields: is_active, created_at, updated_at
```

#### 3. `menuca_v3.ingredients` (13 columns)
```sql
-- Core fields: id, uuid, restaurant_id, name
-- Pricing fields: base_price, price_by_size (JSONB)
-- Config fields: ingredient_type, display_order, is_global
-- Audit fields: is_active, created_at, updated_at
```

#### 4. `menuca_v3.ingredient_groups` (11 columns)
```sql
-- Core fields: id, uuid, restaurant_id, name, group_type
-- Config fields: applies_to_course, applies_to_dish
-- Display fields: display_order, is_active
-- Audit fields: created_at, updated_at
```

#### 5. `menuca_v3.combo_groups` (10 columns)
```sql
-- Core fields: id, uuid, restaurant_id, name
-- Config fields: combo_rules (JSONB), pricing_rules (JSONB)
-- Audit fields: is_active, created_at, updated_at
```

#### 6. `menuca_v3.combo_items` (9 columns)
```sql
-- Core fields: id, uuid, combo_group_id, dish_id
-- Config fields: quantity, is_required, display_order
-- Audit fields: created_at, updated_at
```

#### 7. `menuca_v3.dish_customizations` (12 columns)
```sql
-- Core fields: id, uuid, dish_id
-- Customization types: custom_ingredients, side_dishes, drinks, extras
-- Config fields: customization_rules (JSONB)
-- Audit fields: is_active, created_at, updated_at
```

#### 8. `menuca_v3.dish_modifiers` (6 columns)
```sql
-- Core fields: id, uuid, dish_id, ingredient_id
-- Pricing fields: price_adjustment
-- Audit fields: created_at
```

---

## BLOB Data Analysis

### Critical BLOB Columns Requiring Deserialization

#### 1. `v1_menu.hideOnDays` (865 rows with data)
**Format**: PHP serialized array of day names
```php
// Example:
a:5:{i:0;s:3:"wed";i:1;s:3:"thu";i:2;s:3:"fri";i:3;s:3:"sat";i:4;s:3:"sun";}
// Translation: Hide dish on Wed, Thu, Fri, Sat, Sun
```

**Target**: `menuca_v3.dishes` - New column `availability_schedule JSONB`
```json
{
  "hide_on_days": ["wed", "thu", "fri", "sat", "sun"]
}
```

**Impact**: Day-based availability rules for 865 dishes

---

#### 2. `v1_menuothers.content` (70,363 rows - CRITICAL)
**Format**: PHP serialized modifier pricing
```php
// Example:
a:2:{s:7:"content";a:1:{i:1183;s:4:"0.25";}s:5:"radio";s:3:"140";}
// Translation: Ingredient 1183 costs $0.25, radio button group 140
```

**Target**: Multiple tables
- `menuca_v3.dishes` - New dishes from side dishes/drinks/extras
- `menuca_v3.dish_modifiers` - Ingredient pricing per dish

**Impact**: 
- **70,363 potential dish records** (sides, drinks, extras)
- **500K+ modifier pricing relationships**

---

#### 3. `v1_ingredient_groups.item` (13,252 rows)
**Format**: PHP serialized array of ingredient IDs
```php
// Example:
a:3:{i:0;i:156;i:1;i:157;i:2;i:158;}
// Translation: Group contains ingredients 156, 157, 158
```

**Target**: Junction table linking groups to ingredients

**Impact**: Ingredient grouping for 13,252 groups

---

#### 4. `v1_combo_groups.options` (10,764 rows with data)
**Format**: PHP serialized combo configuration rules

**Target**: `menuca_v3.combo_groups.combo_rules` (JSONB)

**Impact**: Advanced combo rules for 10,764 groups

---

### BLOB Deserialization Requirements

**Tools Needed**:
- Python with `phpserialize` library
- Custom parsers for complex structures

**Estimated Complexity**: 🔴 HIGH
- Multiple BLOB formats
- Nested data structures
- Invalid/corrupted data handling
- 95,265 BLOB records to process

---

## Data Quality Concerns

### 🚨 Critical Issues Identified

#### Issue #1: Massive Dish Count Discrepancy
**Expected**: ~187,000 dishes (117,666 V1 menu + 70,363 V1 menuothers + 10,288 V2 dishes - duplicates)  
**Actual**: 42,930 dishes in menuca_v3  
**Missing**: ~144,000 dishes (77% data loss)

**Possible Causes**:
1. Test restaurant filtering (V1 has many test restaurants)
2. Hidden dishes excluded (`showInMenu='N'`)
3. Blank names excluded (13,798 V1 dishes)
4. **`menuothers` table not migrated** (70,363 rows)
5. Migration incomplete

**Action Required**: ✅ Verify which records should be migrated

---

#### Issue #2: Dish Customizations - 99.8% Missing
**Expected**: ~13,405 customizations from V2  
**Actual**: 310 customizations in menuca_v3  
**Missing**: 13,095 customizations (97.7% data loss)

**Possible Causes**:
1. Orphaned records (parent dishes missing)
2. Disabled customizations excluded
3. Migration incomplete
4. JSON parsing errors

**Action Required**: ✅ Investigate FK relationships

---

#### Issue #3: Dish Modifiers - BLOB Data Not Deserialized
**Expected**: ~70,000+ modifiers from V1 `menuothers.content`  
**Actual**: 8 modifiers in menuca_v3  
**Missing**: 99.99% of modifier data

**Possible Causes**:
1. BLOB deserialization not executed
2. Data in wrong schema (old `menu_v3`?)
3. Migration incomplete

**Action Required**: ✅ Re-run BLOB deserialization

---

#### Issue #4: Combo Groups - Heavy Duplication in V1
**Source**: 62,344 combo groups in V1  
**Actual**: 8,341 combo groups in menuca_v3  
**Analysis**: V1 has 85.5% blank names (53,304 rows) - likely duplicates

**Expected Clean**: ~9,000 groups  
**Actual**: 8,341 groups  
**Assessment**: ✅ Within acceptable range

---

### ⚠️ Data Quality Checks Needed

1. **Test Restaurant Identification**
   - Restaurants with "test"/"dummy"/"sample" in dish names
   - Restaurants with >80% hidden dishes
   - Estimated: 380 test restaurants, 24,323 dishes

2. **Blank Name Records**
   - V1 menu: 13,798 blank names (97.8% hidden)
   - These are soft-deleted records

3. **Hidden Dishes**
   - V1 menu: 8,173 dishes with `showInMenu='N'`
   - Business decision: include or exclude?

4. **Disabled Records**
   - V2 dishes: 378 with `enabled='n'`
   - V2 customizations: 3,250 with `enabled='n'`

---

## Migration Strategy

### Overall Approach

**Phase 0**: Data Discovery & Analysis ✅ IN PROGRESS
- Analyze all dump files
- Identify BLOB structures
- Document relationships
- Count expected vs actual rows

**Phase 1**: Staging Table Creation
- Create staging tables for all 17 source tables
- Load dump data into staging
- Handle BLOB columns as TEXT initially

**Phase 2**: Data Quality Assessment
- Identify test restaurants
- Mark blank/hidden/disabled records
- Analyze orphaned records
- Generate data quality report

**Phase 3**: BLOB Deserialization
- Extract and parse PHP serialized data
- Transform to JSON/JSONB structures
- Load to intermediate tables

**Phase 4**: Data Transformation & Load
- V1 → menuca_v3 transformation
- V2 → menuca_v3 transformation
- Merge strategy (V2 prioritized over V1)
- Handle conflicts

**Phase 5**: Comprehensive Verification
- Row count verification
- Relationship integrity checks
- BLOB data validation
- Business logic validation

---

## Phase Plan

### Phase 0: Data Discovery & Analysis
**Status**: ✅ IN PROGRESS  
**Duration**: 1-2 days

**Tasks**:
- [✅] Identify all source tables
- [✅] Count rows in dumps
- [✅] Identify BLOB columns
- [✅] Document V3 schema
- [⏳] Analyze V3 current state
- [⏳] Generate gap analysis report

---

### Phase 1: Staging Table Creation
**Status**: ⏳ PENDING  
**Duration**: 1 day

**Tasks**:
- [ ] Create `staging.v1_*` tables (7 tables)
- [ ] Create `staging.v2_*` tables (10 tables)
- [ ] Load dump data (382,019 rows)
- [ ] Verify row counts match dumps

**Note**: BLOB columns stored as TEXT in staging for raw data preservation

---

### Phase 2: Data Quality Assessment
**Status**: ⏳ PENDING  
**Duration**: 2-3 days

**Tasks**:
- [ ] Identify test restaurants
- [ ] Mark blank name records
- [ ] Mark hidden dishes
- [ ] Mark disabled records
- [ ] Identify orphaned records
- [ ] Generate exclusion report
- [ ] User review & approval

---

### Phase 3: BLOB Deserialization
**Status**: ⏳ PENDING  
**Duration**: 3-4 days

**Sub-Phase 3.1**: `v1_menu.hideOnDays`
- [ ] Extract 865 BLOB values
- [ ] Parse PHP serialized arrays
- [ ] Generate JSON availability schedules
- [ ] Load to temp table

**Sub-Phase 3.2**: `v1_menuothers.content` (CRITICAL)
- [ ] Extract 70,363 BLOB values
- [ ] Parse modifier pricing structures
- [ ] Generate dish records for sides/drinks/extras
- [ ] Generate dish_modifier linkages
- [ ] Load to temp tables

**Sub-Phase 3.3**: `v1_ingredient_groups.item`
- [ ] Extract 13,252 BLOB values
- [ ] Parse ingredient ID arrays
- [ ] Generate ingredient group linkages
- [ ] Load to junction table

**Sub-Phase 3.4**: `v1_combo_groups.options`
- [ ] Extract 10,764 BLOB values
- [ ] Parse combo rule structures
- [ ] Generate JSONB combo rules
- [ ] Load to temp table

**Verification**:
- [ ] All BLOBs successfully parsed
- [ ] Invalid/corrupted data documented
- [ ] Transformation accuracy spot-checked

---

### Phase 4: Data Transformation & Load
**Status**: ⏳ PENDING  
**Duration**: 4-5 days

**Sub-Phase 4.1**: Courses
- [ ] Load V1 courses
- [ ] Load V2 courses
- [ ] Merge (V2 wins conflicts)
- [ ] Verify: ~14,000 courses

**Sub-Phase 4.2**: Ingredients
- [ ] Load V1 ingredients
- [ ] Load V2 global ingredients
- [ ] Load V2 restaurant ingredients
- [ ] Merge (V2 wins conflicts)
- [ ] Verify: ~52,000 ingredients

**Sub-Phase 4.3**: Ingredient Groups
- [ ] Load V1 ingredient groups
- [ ] Load V2 ingredient groups
- [ ] Apply deserialized item linkages
- [ ] Verify: ~13,000 groups

**Sub-Phase 4.4**: Combo Groups & Items
- [ ] Load V1 combo groups (exclude duplicates)
- [ ] Load V2 combo groups
- [ ] Load combo items
- [ ] Apply deserialized combo rules
- [ ] Verify: ~10,000 groups, ~16,000 items

**Sub-Phase 4.5**: Dishes (CRITICAL)
- [ ] Load V1 menu dishes
- [ ] Load V1 menuothers as dishes
- [ ] Load V2 dishes
- [ ] Apply availability schedules (deserialized)
- [ ] Merge (V2 wins conflicts)
- [ ] Verify: ~180,000+ dishes (after filtering)

**Sub-Phase 4.6**: Dish Customizations
- [ ] Load V2 customizations
- [ ] Verify FK integrity
- [ ] Verify: ~10,000+ customizations (after filtering)

**Sub-Phase 4.7**: Dish Modifiers
- [ ] Apply deserialized modifier pricing
- [ ] Link dishes to ingredients
- [ ] Verify: ~70,000+ modifiers

---

### Phase 5: Comprehensive Verification
**Status**: ⏳ PENDING  
**Duration**: 2-3 days

**Tasks**:
- [ ] Row count verification (all tables)
- [ ] Orphan record check (all FKs)
- [ ] BLOB data validation (spot check samples)
- [ ] Price accuracy check
- [ ] Business logic validation
- [ ] Generate migration success report

---

## Verification Queries

### Row Count Verification

```sql
-- Compare source (staging) vs target (menuca_v3)
WITH source_counts AS (
  SELECT 
    'courses' as entity,
    (SELECT COUNT(*) FROM staging.v1_courses) +
    (SELECT COUNT(*) FROM staging.v2_restaurants_courses) as source_count
  UNION ALL
  SELECT 
    'dishes',
    (SELECT COUNT(*) FROM staging.v1_menu) +
    (SELECT COUNT(*) FROM staging.v1_menuothers) +
    (SELECT COUNT(*) FROM staging.v2_restaurants_dishes) as source_count
  UNION ALL
  SELECT 
    'ingredients',
    (SELECT COUNT(*) FROM staging.v1_ingredients) +
    (SELECT COUNT(*) FROM staging.v2_global_ingredients) +
    (SELECT COUNT(*) FROM staging.v2_restaurants_ingredients) as source_count
  -- Add other entities...
),
target_counts AS (
  SELECT 'courses' as entity, COUNT(*) as target_count FROM menuca_v3.courses
  UNION ALL
  SELECT 'dishes', COUNT(*) FROM menuca_v3.dishes
  UNION ALL
  SELECT 'ingredients', COUNT(*) FROM menuca_v3.ingredients
  -- Add other entities...
)
SELECT 
  s.entity,
  s.source_count,
  t.target_count,
  t.target_count - s.source_count as difference,
  ROUND(t.target_count * 100.0 / NULLIF(s.source_count, 0), 1) as pct_migrated
FROM source_counts s
JOIN target_counts t ON s.entity = t.entity
ORDER BY s.entity;
```

---

## Critical Decisions

### Decision #1: Include `menuothers` as Dishes?
**Context**: V1 `menuothers` table (70,363 rows) contains side dishes, drinks, extras

**Options**:
- **A**: Migrate as separate dishes in `menuca_v3.dishes`
- **B**: Migrate as modifiers only (dish_modifiers table)
- **C**: Exclude (data loss)

**Recommendation**: ⏳ **PENDING USER DECISION**

**Impact**:
- Option A: +70,363 dishes, most comprehensive
- Option B: +70,363 modifiers, no dish duplication
- Option C: Significant data loss

---

### Decision #2: Handle Test Restaurants?
**Context**: ~380 test restaurants identified with 24,323 dishes

**Options**:
- **A**: Exclude all test restaurants
- **B**: Include all data (let application filter)
- **C**: User review & selective exclusion

**Recommendation**: ⏳ **PENDING USER DECISION**

---

### Decision #3: Hidden Dishes Treatment?
**Context**: 8,173 V1 dishes with `showInMenu='N'`

**Options**:
- **A**: Exclude (soft-deleted)
- **B**: Include with `is_active=FALSE`
- **C**: User review

**Recommendation**: ⏳ **PENDING USER DECISION**

---

### Decision #4: V1 vs V2 Merge Strategy?
**Context**: Some restaurants have data in both V1 and V2

**Policy**: V2 data prioritized over V1 (established in previous migrations)

**Conflicts**:
- If dish exists in both V1 and V2 → Keep V2
- If course exists in both V1 and V2 → Keep V2
- Use `ON CONFLICT UPDATE` with V2 data

**Status**: ✅ **APPROVED** (follows established pattern)

---

## Next Steps

### Immediate Actions (Phase 0)

1. ✅ **User Decision Required**: Review critical decisions
2. ⏳ **Analyze V3 Current State**: Query existing data for patterns
3. ⏳ **Generate Gap Analysis**: Document missing data
4. ⏳ **BLOB Sample Analysis**: Extract 10 samples of each BLOB type for validation

### After User Approval

5. Proceed to Phase 1: Create staging tables
6. Load all dump data
7. Begin data quality assessment

---

## Success Criteria

Migration is successful when:
- ✅ All relevant source data accounted for
- ✅ BLOB data successfully deserialized and loaded
- ✅ Row counts match expected (after filtering)
- ✅ All FK relationships valid (no orphans)
- ✅ Spot-check data accuracy (prices, names, relationships)
- ✅ Test restaurant data handled per decision
- ✅ Business logic validated (combos work, modifiers apply correctly)

---

**END OF MIGRATION GUIDE**

This is the **single source of truth** for the Menu & Catalog migration.

