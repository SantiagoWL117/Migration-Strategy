# V1 Data Reload Plan - Critical Data Integrity Fix

**Date:** October 2, 2025  
**Status:** ⏳ **READY TO EXECUTE**  
**Priority:** 🔴 **CRITICAL** - Blocks Phase 4 BLOB Deserialization

---

## 🚨 ISSUE SUMMARY

**Problem Discovered:** During Phase 4 preparation, discovered that Phase 1 data loading is 71.3% INCOMPLETE for V1 tables.

**Impact:**
- ❌ Phase 4 BLOB deserialization blocked (missing ingredient names)
- ❌ Production menu data only 41.8% complete (80,884 dishes missing!)
- ❌ Modifier system only 22.2% complete (10,458 ingredient groups missing)
- ❌ Course categories 99.1% missing (13,117 of 13,238 courses missing!)

**Discovery Method:** Comparing ingredient IDs referenced in `ingredient_groups.item` BLOBs (e.g., ID 28849) against staging data (only IDs 54,352-59,949 loaded).

---

## 📊 DATA COMPLETENESS ANALYSIS

### Comparison: Source Dumps vs Staging Tables

| Table | Dump Rows | Staging Rows | Missing Rows | % Loaded | Reload Required |
|-------|-----------|--------------|--------------|----------|-----------------|
| **v1_courses** | 13,238 | 121 | **13,117** | 0.9% | 🔴 YES |
| **v1_ingredient_groups** | 13,450 | 2,992 | **10,458** | 22.2% | 🔴 YES |
| **v1_ingredients** | 53,367 | 3,000 | **50,367** | 5.6% | 🔴 YES |
| **v1_menu** | 138,941 | 58,057 | **80,884** | 41.8% | 🔴 YES |
| **v1_combo_groups** | 62,913 | 53,193 | **9,720** | 84.5% | 🟡 YES |
| v1_combos | 16,461 | 16,461 | 0 | 100% | ✅ NO |
| v1_menuothers | 70,381 | 70,381 | 0 | 100% | ✅ NO |

**Total Missing:** 164,546 rows across 5 tables  
**Total V1 Rows Expected:** 368,751  
**Total V1 Rows Loaded:** 204,205 (55.4%)  
**Data Loss:** 164,546 rows (44.6%)

---

## 🎯 RELOAD STRATEGY

### Phase 1: Backup Current Staging Data

**Purpose:** Preserve investigation work and provide rollback capability

**Actions:**
```sql
-- Backup staging tables before reload
CREATE TABLE staging.v1_courses_backup_20251002 AS SELECT * FROM staging.v1_courses;
CREATE TABLE staging.v1_ingredient_groups_backup_20251002 AS SELECT * FROM staging.v1_ingredient_groups;
CREATE TABLE staging.v1_ingredients_backup_20251002 AS SELECT * FROM staging.v1_ingredients;
CREATE TABLE staging.v1_menu_backup_20251002 AS SELECT * FROM staging.v1_menu;
CREATE TABLE staging.v1_combo_groups_backup_20251002 AS SELECT * FROM staging.v1_combo_groups;
```

**Verification:**
- [ ] All 5 backup tables created successfully
- [ ] Backup row counts match current staging counts

---

### Phase 2: Clear Incomplete Staging Tables

**Purpose:** Prepare for full reload

**Actions:**
```sql
-- Truncate incomplete tables
TRUNCATE TABLE staging.v1_courses CASCADE;
TRUNCATE TABLE staging.v1_ingredient_groups CASCADE;
TRUNCATE TABLE staging.v1_ingredients CASCADE;
TRUNCATE TABLE staging.v1_menu CASCADE;
TRUNCATE TABLE staging.v1_combo_groups CASCADE;
```

**Verification:**
- [ ] All 5 tables now empty (0 rows)
- [ ] No FK constraint violations

---

### Phase 3: Reload Complete V1 Data

**Method:** Use Supabase MCP `execute_sql` to load dump files

**Source Files:**
- `/Database/Menu & Catalog Entity/dumps/menuca_v1_courses.sql`
- `/Database/Menu & Catalog Entity/dumps/menuca_v1_ingredient_groups.sql`
- `/Database/Menu & Catalog Entity/dumps/menuca_v1_ingredients.sql`
- `/Database/Menu & Catalog Entity/dumps/menuca_v1_menu.sql`
- `/Database/Menu & Catalog Entity/dumps/menuca_v1_combo_groups.sql`

**Challenge:** Dump files likely contain MySQL-specific syntax that needs conversion:
- Replace `_binary` markers
- Fix quote escaping (`\'` → `''`)
- Replace zero-dates with NULL
- Remove MySQL-specific options

**Approach:**
1. For each dump file:
   - Extract INSERT statements only
   - Convert MySQL syntax → PostgreSQL
   - Split into manageable batches (< 5MB per batch)
   - Load via MCP execute_sql

2. Batch size strategy:
   - Target: ~5,000 rows per batch
   - Large tables (v1_menu, v1_ingredients) may need 10-30 batches

**Loading Order:**
1. v1_courses (13,238 rows)
2. v1_ingredient_groups (13,450 rows)
3. v1_ingredients (53,367 rows) - May need batching
4. v1_menu (138,941 rows) - Will need batching (~28 batches)
5. v1_combo_groups (62,913 rows) - May need batching

---

### Phase 4: Verification

**Row Count Validation:**
```sql
-- Verify all rows loaded correctly
SELECT 
    'v1_courses' as table_name,
    COUNT(*) as loaded_rows,
    13238 as expected_rows,
    CASE WHEN COUNT(*) = 13238 THEN '✅ PASS' ELSE '❌ FAIL' END as status
FROM staging.v1_courses
UNION ALL
SELECT 'v1_ingredient_groups', COUNT(*), 13450,
    CASE WHEN COUNT(*) = 13450 THEN '✅ PASS' ELSE '❌ FAIL' END
FROM staging.v1_ingredient_groups
UNION ALL
SELECT 'v1_ingredients', COUNT(*), 53367,
    CASE WHEN COUNT(*) = 53367 THEN '✅ PASS' ELSE '❌ FAIL' END
FROM staging.v1_ingredients
UNION ALL
SELECT 'v1_menu', COUNT(*), 138941,
    CASE WHEN COUNT(*) = 138941 THEN '✅ PASS' ELSE '❌ FAIL' END
FROM staging.v1_menu
UNION ALL
SELECT 'v1_combo_groups', COUNT(*), 62913,
    CASE WHEN COUNT(*) = 62913 THEN '✅ PASS' ELSE '❌ FAIL' END
FROM staging.v1_combo_groups;
```

**Data Integrity Checks:**
```sql
-- Verify ingredient IDs from ingredient_groups BLOBs now exist
SELECT 
    COUNT(*) as referenced_ingredients,
    COUNT(DISTINCT i.id) as found_ingredients,
    COUNT(*) - COUNT(DISTINCT i.id) as missing_ingredients
FROM (
    SELECT 28849 as ing_id UNION SELECT 28852 UNION SELECT 28850 
    UNION SELECT 28851 UNION SELECT 38615 UNION SELECT 38619
) refs
LEFT JOIN staging.v1_ingredients i ON refs.ing_id = i.id;
-- Expected: 6 referenced, 6 found, 0 missing
```

**Verification Checklist:**
- [ ] All 5 tables have expected row counts (100% match)
- [ ] Sample ingredient IDs (28849, etc.) exist in v1_ingredients
- [ ] No NULL values in critical columns (id, name where applicable)
- [ ] FK relationships intact (where applicable)

---

### Phase 5: Re-run Phase 2 Transformations

**Purpose:** Populate V3 staging/production with newly loaded V1 data

**Impact:**
- Production `menu_v3.dishes` will increase from 53,809 → ~134,693 rows (+80,884)
- Production `menu_v3.courses` will increase from 1,396 → ~14,513 rows (+13,117)
- Production `menu_v3.ingredient_groups` will increase from 2,587 → ~13,045 rows (+10,458)

**Scripts to Re-run:**
1. `transform_v1_to_v3.sql` - Transform complete V1 data
2. Validation queries
3. Deploy to production (UPDATE/INSERT new records)

**Strategy:**
- **Option A:** Re-transform everything (safest, ~30-45 min)
- **Option B:** Transform only NEW rows (faster but complex ID mapping)

**Recommendation:** Option A - Full re-transformation ensures consistency

---

## 🚧 DOWNSTREAM IMPACTS

### Immediate Impact: Phase 3 Production Data

**Current Production State:**
- ✅ 64,913 rows deployed successfully
- ❌ But missing 80,884 dishes from v1_menu
- ❌ Missing 13,117 courses
- ❌ Missing 10,458 ingredient groups

**Post-Reload Production State:**
- 🎯 ~145,797 total rows (2.25x current)
- ✅ Complete V1 data represented
- ✅ All courses available for dish assignment
- ✅ All ingredient groups available for modifiers

### Phase 4: BLOB Deserialization (Unblocked)

**What Becomes Possible:**
1. ✅ `ingredient_groups.item` deserialization (all ingredient names available)
2. ✅ `menuothers.content` deserialization (can link to complete dishes)
3. ✅ Complete modifier system with dish-specific pricing
4. ✅ Availability schedules (`hideOnDays` deserialization)

---

## ⚠️ RISKS & MITIGATION

### Risk 1: Large Batch Loading Performance
**Mitigation:**
- Split large tables into ~5,000 row batches
- Monitor MCP execute_sql timeout limits
- Implement retry logic for failed batches

### Risk 2: MySQL → PostgreSQL Syntax Issues
**Mitigation:**
- Use proven conversion patterns from Phase 1
- Test first batch before proceeding with all
- Document conversion rules for future reference

### Risk 3: FK Constraint Violations
**Mitigation:**
- Load in dependency order (courses → menu items)
- Temporarily disable constraints if needed
- Validate relationships after reload

### Risk 4: Production Deployment Conflicts
**Mitigation:**
- Use UPSERT logic (INSERT ... ON CONFLICT)
- Preserve existing production IDs
- Test in staging first

---

## 📋 EXECUTION CHECKLIST

### Pre-Execution
- [ ] Read this entire plan
- [ ] Backup current staging tables
- [ ] Verify dump file accessibility
- [ ] Estimate total execution time (~2-3 hours)

### During Execution
- [ ] Phase 1: Backup created successfully
- [ ] Phase 2: Tables truncated
- [ ] Phase 3: All 5 tables reloaded (164,546 rows)
- [ ] Phase 4: Verification passed (100% row counts)
- [ ] Phase 5: Transformations complete

### Post-Execution
- [ ] Update MEMORY_BANK/ENTITIES/05_MENU_CATALOG.md
- [ ] Document reload completion with statistics
- [ ] Verify Phase 4 can proceed with complete data
- [ ] Create RELOAD_COMPLETION_REPORT.md

---

## 🎉 SUCCESS CRITERIA

**Phase 1 Data Reload Complete When:**
1. ✅ All 5 V1 tables have 100% expected row counts
2. ✅ Sample ingredient IDs (28849, etc.) exist and have correct names
3. ✅ Zero FK violations or data quality issues
4. ✅ Verification queries pass with 100% success rate

**Ready for Phase 4 When:**
1. ✅ Phase 2 transformations re-run successfully
2. ✅ Production tables updated with complete data
3. ✅ Ingredient names available for BLOB deserialization
4. ✅ All modifier dependencies satisfied

---

## 📝 NOTES

**Why This Happened:**
- Phase 1 loading scripts likely had batch size limits
- Possible filtering logic that excluded data
- May have used LIMIT clauses during development testing
- No comprehensive row count validation after Phase 1

**Prevention for Future:**
- Always compare source row counts vs loaded row counts
- Implement automated verification after each load phase
- Document expected vs actual row counts in completion reports
- Add row count assertions to loading scripts

---

**Next Command:** Execute Phase 1 (Backup) → Phase 2 (Truncate) → Phase 3 (Reload)

**Estimated Duration:** 2-3 hours for complete reload and verification

