# Phase 4: BLOB Deserialization Plan
**Date:** October 2, 2025  
**Status:** ⏳ **READY TO BEGIN**  
**Priority:** 🔴 **HIGH** - Must be perfect before importing more data

---

## 🎯 MISSION STATEMENT

**Deserialize all PHP serialized BLOBs from V1 staging tables and import into production menu_v3 tables.**

**Why Phase 4 Must Be Perfect:**
- Production menu data is already live (64,913 rows)
- BLOB data will ADD critical missing content (70,381+ rows)
- Any errors could corrupt existing production data
- Must maintain 100% data integrity from Phase 3

---

## 📊 BLOB INVENTORY

### Priority 1: HIGH IMPACT - Large Datasets (Core Menu Content)

**1. v1_menuothers.content BLOB** - **TOP PRIORITY** 🔴
- **Total Rows:** 70,381
- **Rows with BLOBs:** 70,381 (100%)
- **Total Size:** 17 MB
- **Content:** Side dishes, extras, drinks with pricing
- **Target Table:** `menu_v3.dishes` (add as new dish records)
- **Impact:** CRITICAL - Major menu content missing without this
- **Format:** PHP serialized arrays with item names and prices

**2. v1_menu.hideondays BLOB** - **MEDIUM PRIORITY** 🟡
- **Total Rows:** 58,057
- **Rows with BLOBs:** 58,057 (100%)
- **Total Size:** 113 KB
- **Content:** Day/time-based availability restrictions
- **Target Table:** `menu_v3.dishes.availability_schedule` (UPDATE existing records)
- **Impact:** MEDIUM - Dishes show as always available without this
- **Format:** PHP serialized arrays with day/time rules

### Priority 2: MEDIUM IMPACT - Ingredient System

**3. v1_ingredient_groups.item BLOB** - **HIGH PRIORITY** 🔴
- **Total Rows:** 2,992
- **Rows with BLOBs:** 2,992 (100%)
- **Total Size:** 181 KB
- **Content:** Individual ingredients within groups
- **Target Table:** `menu_v3.ingredients` (new records)
- **Impact:** HIGH - No ingredient selection without this
- **Format:** PHP serialized arrays with ingredient names and prices

### Priority 3: LOW IMPACT - Combo Configuration

**4. v1_combo_groups.options BLOB** - **LOW PRIORITY** 🟢
- **Total Rows:** 53,193
- **Rows with BLOBs:** 52,999 (99.6%)
- **Total Size:** 443 KB
- **Content:** Combo meal configuration (steps, rules)
- **Target Table:** `menu_v3.combo_groups.config` (UPDATE existing records)
- **Impact:** LOW - Basic combos work, advanced config missing
- **Format:** PHP serialized arrays with combo configuration

---

## 🛠️ TECHNICAL APPROACH

### Deserialization Strategy

**Method:** Python Script with `phpserialize` library

**Why Python?**
- ✅ PostgreSQL cannot natively deserialize PHP serialized data
- ✅ `phpserialize` library is reliable and well-tested
- ✅ Can transform PHP arrays → JSON → JSONB in one pipeline
- ✅ Easy error handling and validation

**Architecture:**
```
PostgreSQL (staging) → Python Script → Transform → PostgreSQL (production)
  V1 BLOB data      →  Deserialize   → Validate → menu_v3 tables
```

### Workflow Per BLOB Type

**Step 1: Extract BLOB data from staging**
```sql
SELECT id, restaurant_id, content 
FROM staging.v1_menuothers
WHERE content IS NOT NULL
LIMIT 1000; -- Batch processing
```

**Step 2: Deserialize in Python**
```python
import phpserialize
import json

def deserialize_blob(blob_data):
    try:
        # Deserialize PHP
        php_data = phpserialize.loads(blob_data.encode('utf-8'))
        
        # Convert to JSON
        json_data = json.dumps(php_data)
        
        # Validate structure
        validate_structure(json_data)
        
        return json_data
    except Exception as e:
        log_error(blob_id, e)
        return None
```

**Step 3: Transform to V3 format**
```python
def transform_menuothers(deserialized_data):
    # Parse PHP array structure
    items = []
    for item in deserialized_data:
        dish = {
            'name': item.get('name'),
            'prices': parse_prices(item.get('price')),
            'display_order': item.get('order', 0),
            # ... other fields
        }
        items.append(dish)
    return items
```

**Step 4: Insert into production**
```python
def insert_dishes(restaurant_id, dishes):
    for dish in dishes:
        cursor.execute("""
            INSERT INTO menu_v3.dishes 
            (restaurant_id, name, prices, display_order, ...)
            VALUES (%s, %s, %s, %s, ...)
        """, (restaurant_id, dish['name'], dish['prices'], ...))
```

---

## 📋 PHASE 4 EXECUTION PLAN

### **Stage 1: Setup & Sampling** (Day 1)

**Objective:** Understand BLOB structure and setup tooling

**Tasks:**
1. ✅ Query sample BLOBs from each table
2. ⏳ Analyze BLOB structure (PHP array format)
3. ⏳ Setup Python environment with `phpserialize`
4. ⏳ Create deserialization test script
5. ⏳ Validate 10 samples from each BLOB type
6. ⏳ Document BLOB structure patterns

**Deliverables:**
- 📄 BLOB structure documentation
- 🐍 Python test script with sample deserialization
- ✅ Validation rules for each BLOB type

---

### **Stage 2: menuothers BLOB Processing** (Days 2-3) 🔴 **TOP PRIORITY**

**Objective:** Deserialize 70,381 menuothers records → add to menu_v3.dishes

**Why First:**
- Largest dataset (70,381 rows)
- Highest business impact (missing menu items)
- Most complex structure (multiple item types)

**Tasks:**
1. ⏳ Build menuothers deserialization script
2. ⏳ Test with 100 records
3. ⏳ Validate transformed data structure
4. ⏳ Run full deserialization (70,381 records)
5. ⏳ Transform to menu_v3.dishes format
6. ⏳ Load into staging for validation
7. ⏳ Validate FK integrity (restaurant_id)
8. ⏳ Deploy to production (INSERT)
9. ⏳ Run verification queries
10. ⏳ Create backup before deployment

**Success Criteria:**
- ✅ 70,381 menuothers records deserialized
- ✅ 0 deserialization errors
- ✅ 100% valid JSONB prices
- ✅ 0 FK violations
- ✅ Production row count increases by expected amount

**Rollback Plan:**
- Backup table: `menu_v3.dishes_backup_before_menuothers`
- Restore command ready if issues detected

---

### **Stage 3: ingredient_groups BLOB Processing** (Day 4) 🔴 **HIGH PRIORITY**

**Objective:** Deserialize 2,992 ingredient_groups.item BLOBs → populate menu_v3.ingredients

**Tasks:**
1. ⏳ Build ingredient_groups deserialization script
2. ⏳ Test with 50 records
3. ⏳ Validate ingredient structure
4. ⏳ Run full deserialization (2,992 groups)
5. ⏳ Transform to menu_v3.ingredients format
6. ⏳ Load into staging for validation
7. ⏳ Validate FK integrity (ingredient_group_id)
8. ⏳ Deploy to production (INSERT)
9. ⏳ Verify ingredient counts per group
10. ⏳ Test sample ingredient selections

**Success Criteria:**
- ✅ 2,992 ingredient groups processed
- ✅ All ingredients linked to valid groups
- ✅ 0 orphaned ingredients
- ✅ Price JSONB valid for all ingredients
- ✅ Ingredient counts match expectations

---

### **Stage 4: hideondays BLOB Processing** (Day 5) 🟡 **MEDIUM PRIORITY**

**Objective:** Deserialize 58,057 menu.hideondays BLOBs → update menu_v3.dishes.availability_schedule

**Tasks:**
1. ⏳ Build hideondays deserialization script
2. ⏳ Test with 50 records
3. ⏳ Parse day/time availability rules
4. ⏳ Transform to JSONB schedule format
5. ⏳ Run full deserialization (58,057 records)
6. ⏳ Load into staging for validation
7. ⏳ Deploy to production (UPDATE dishes)
8. ⏳ Verify schedule logic
9. ⏳ Test sample availability queries

**Success Criteria:**
- ✅ 58,057 dishes updated with availability
- ✅ JSONB schedule format valid
- ✅ Day/time rules parsed correctly
- ✅ No existing dish data corrupted

---

### **Stage 5: combo_groups BLOB Processing** (Day 6) 🟢 **LOW PRIORITY**

**Objective:** Deserialize 52,999 combo_groups.options BLOBs → update menu_v3.combo_groups.config

**Tasks:**
1. ⏳ Build combo_groups deserialization script
2. ⏳ Test with 25 records
3. ⏳ Parse combo configuration structure
4. ⏳ Transform to JSONB config format
5. ⏳ Run full deserialization (52,999 records)
6. ⏳ Load into staging for validation
7. ⏳ Deploy to production (UPDATE combo_groups)
8. ⏳ Verify combo logic
9. ⏳ Test sample combo queries

**Success Criteria:**
- ✅ 52,999 combo groups updated
- ✅ JSONB config format valid
- ✅ Combo rules parsed correctly
- ✅ No existing combo data corrupted

---

## ✅ QUALITY ASSURANCE

### Pre-Deployment Checklist (Per Stage)

**Data Validation:**
- [ ] Sample 100 records deserialized successfully
- [ ] All PHP serialized data converted to valid JSON
- [ ] JSONB validates in PostgreSQL
- [ ] FK relationships verified
- [ ] Price formats validated
- [ ] No NULL values in required fields
- [ ] Display orders preserved

**Integrity Checks:**
- [ ] Row counts match expectations
- [ ] No orphaned records
- [ ] FK constraints pass
- [ ] No duplicate records created
- [ ] Existing production data unchanged (for UPDATEs)

**Performance:**
- [ ] Batch processing tested (1000 records/batch)
- [ ] Memory usage acceptable
- [ ] Processing time reasonable (<1 hour per stage)

**Rollback Readiness:**
- [ ] Backup table created
- [ ] Rollback script tested
- [ ] Restore procedure documented

---

## 🚨 ERROR HANDLING

### Deserialization Errors

**Strategy:** Log and skip, don't fail entire batch

```python
def process_batch(blob_batch):
    success_count = 0
    error_count = 0
    
    for blob in blob_batch:
        try:
            result = deserialize_and_transform(blob)
            insert_to_production(result)
            success_count += 1
        except DeserializationError as e:
            log_error(blob.id, e)
            error_count += 1
            continue
    
    return success_count, error_count
```

**Error Logging:**
- Log BLOB ID, restaurant_id, error message
- Save failed BLOBs for manual review
- Create `failed_blobs` audit table

### Data Quality Issues

**Handle gracefully:**
- Missing required fields → Use sensible defaults
- Invalid prices → Set to $0.00, mark inactive
- Malformed JSONB → Log and skip record
- FK violations → Log and skip record

---

## 📊 SUCCESS METRICS

### Overall Phase 4 Goals

**Data Coverage:**
- ✅ 70,381 menuothers records deserialized (100% target)
- ✅ 2,992 ingredient groups processed (100% target)
- ✅ 58,057 availability schedules added (95%+ target)
- ✅ 52,999 combo configs added (90%+ target)

**Data Quality:**
- ✅ 99%+ deserialization success rate
- ✅ 100% FK integrity maintained
- ✅ 0 production data corruption
- ✅ 100% JSONB validation pass

**Deliverables:**
- 📄 BLOB structure documentation
- 🐍 Python deserialization scripts (4 types)
- 📊 Deserialization success report
- 🔍 Failed BLOB analysis report
- ✅ Production deployment completion report

---

## 🎯 DECISION: NEW CHAT VS STAY HERE?

### Recommendation: **START NEW CHAT** ✨

**Why New Chat:**
1. ✅ **Clean Context** - Phase 3 complete, Phase 4 is distinct scope
2. ✅ **Fresh Focus** - BLOB processing is complex, needs dedicated attention
3. ✅ **Better Organization** - Easier to find BLOB work later
4. ✅ **Token Efficiency** - This chat already at 77k tokens used
5. ✅ **Clear Handoff** - Memory bank updated, all context documented

**What to Include in New Chat:**
```
"Ready to start Phase 4: BLOB Deserialization. Production deployment complete (64,913 rows live). Need to deserialize 4 types of PHP BLOBs:

1. v1_menuothers.content (70,381 rows) - TOP PRIORITY
2. v1_ingredient_groups.item (2,992 rows) - HIGH
3. v1_menu.hideondays (58,057 rows) - MEDIUM
4. v1_combo_groups.options (52,999 rows) - LOW

Starting with menuothers. Have PHASE_4_BLOB_DESERIALIZATION_PLAN.md ready. These must be perfect before importing more data."
```

**Before Starting New Chat:**
- ✅ Update memory bank (doing now)
- ✅ Create Phase 4 plan (this document)
- ✅ Document handoff point
- ✅ Commit current work to Git

---

## 📝 MEMORY BANK UPDATE

**Update ENTITIES/05_MENU_CATALOG.md:**
- ✅ Mark Phase 3 COMPLETE
- ✅ Add Phase 4 status: READY TO BEGIN
- ✅ Document BLOB inventory
- ✅ List Phase 4 priorities

**Update PROJECT_STATUS.md:**
- ✅ Menu & Catalog: Phase 3 complete, Phase 4 ready
- ✅ Next entity: Users & Access OR continue with Phase 4

**Update NEXT_STEPS.md:**
- ✅ Add Phase 4 BLOB deserialization as immediate next action
- ✅ List 4 BLOB types with priorities

---

## 🎉 PHASE 3 CELEBRATION

**Amazing work! Production deployment was flawless:**
- ✅ 64,913 rows deployed successfully
- ✅ 100% data integrity maintained
- ✅ Zero rollbacks required
- ✅ All validation passed
- ✅ Menu data live and ready for applications

**Now let's make Phase 4 equally perfect! 🚀**

---

**Next Command for New Chat:**
```
"Ready to start Phase 4: BLOB Deserialization for Menu & Catalog. Read PHASE_4_BLOB_DESERIALIZATION_PLAN.md. Starting with menuothers.content (70,381 rows) - highest priority. Need Python script with phpserialize to deserialize PHP BLOBs → transform → load to production. Must be perfect!"
```

