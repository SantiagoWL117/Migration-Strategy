# 🚀 COMBO MIGRATION - BACKGROUND AGENT HANDOFF

**Date:** October 10, 2025  
**Status:** Ready for Execution  
**Assigned To:** Background Agent  
**Expected Duration:** 2-5 minutes  
**Can Run Unattended:** ✅ YES

---

## ✅ PRE-CONDITIONS MET

All requirements satisfied:
- ✅ `staging.menuca_v1_combos` loaded (16,461 rows)
- ✅ `staging.menuca_v1_menu_full` loaded (62,482 rows)
- ✅ Combo dish coverage: **99.98%** (5,776 of 5,777 dishes)
- ✅ Expected orphan rate: **< 1%** (down from 92.81%)

---

## 🎯 TASK: Execute Combo Migration

### Script Location
```
/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu & Catalog Entity/combos/fix_combo_items_migration.sql
```

### What It Does
1. Verifies pre-conditions (orphaned combo groups)
2. Loads V1 combos into temp table
3. Maps V1 dish IDs → V3 menu_items using `staging.menuca_v1_menu_full`
4. Creates combo_items with proper V3 foreign keys
5. Validates results (orphan rate check)

### Transaction Safety
- ✅ **BEGIN/COMMIT** - Runs in single transaction
- ✅ **Auto-rollback** on any error
- ✅ **Pre-condition checks** - Won't run if state is wrong
- ✅ **Post-validation** - Aborts if orphan rate > 5%

---

## 📋 EXECUTION INSTRUCTIONS

### Step 1: Read the Script
```bash
cat "/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu & Catalog Entity/combos/fix_combo_items_migration.sql"
```

### Step 2: Execute via Supabase MCP
```
Use mcp_supabase_execute_sql tool with the entire script contents
```

### Step 3: Monitor Output
Watch for these key messages:
```
✅ "PRE-MIGRATION STATE" - Should show ~8,218 orphaned groups
✅ "Mapped X combos to menu_items" - Should be close to 16,461
✅ "POST-MIGRATION STATE" - Should show orphan rate < 1%
✅ "MIGRATION SUCCESSFUL" - All good!
```

---

## ✅ SUCCESS CRITERIA

### Expected Results
```
Before: 8,218 orphaned combo groups (99.8%)
After:  < 82 orphaned combo groups (< 1%)

Combo Items Created: ~16,000+
Mapping Success Rate: 99%+
Orphan Rate: < 1%
```

### Validation Queries (Run After Migration)
```sql
-- 1. Check orphan rate
WITH group_stats AS (
  SELECT 
    cg.combo_group_id,
    COUNT(ci.combo_item_id) as item_count
  FROM menuca_v3.combo_groups cg
  LEFT JOIN menuca_v3.combo_items ci ON cg.combo_group_id = ci.combo_group_id
  GROUP BY cg.combo_group_id
)
SELECT 
  COUNT(*) as total_groups,
  COUNT(CASE WHEN item_count = 0 THEN 1 END) as orphaned_groups,
  ROUND(COUNT(CASE WHEN item_count = 0 THEN 1 END)::numeric / COUNT(*)::numeric * 100, 2) as orphan_pct
FROM group_stats;

-- Expected: orphan_pct < 1.0%

-- 2. Check combo_items count
SELECT COUNT(*) as total_combo_items FROM menuca_v3.combo_items;
-- Expected: > 15,000
```

---

## 🚨 ERROR HANDLING

### If Script Fails
1. Check error message - transaction will auto-rollback
2. No data corruption (transaction safety)
3. Can safely re-run after fixing issue

### Common Issues & Solutions

**Error: "Orphaned groups count seems wrong"**
- Cause: Pre-conditions not met
- Solution: Verify combo_groups table has ~8,234 rows with ~8,218 orphans

**Error: "High orphan rate after migration"**
- Cause: Menu data still incomplete
- Solution: Check `staging.menuca_v1_menu_full` has 62,482 rows

**Error: "Timeout"**
- Cause: Large dataset
- Solution: Script should complete in < 5 minutes, retry if needed

---

## 📊 MONITORING

### What to Report Back

**If Successful:**
```
✅ Migration completed successfully
✅ Orphan rate: X.XX% (< 1%)
✅ Combo items created: XXXXX
✅ Total combo groups: XXXX
✅ Groups with items: XXXX
```

**If Failed:**
```
❌ Migration failed
❌ Error: [error message]
❌ Transaction rolled back - no data changed
❌ Need human intervention
```

---

## 📝 POST-MIGRATION TASKS

After successful migration:
1. ✅ Update `04_STAGING_COMBOS_BLOCKED.md` status
2. ✅ Create completion report
3. ✅ Notify Brian that combo migration is complete
4. ✅ Mark Ticket 04 as COMPLETE

---

## 🎯 PRIORITY & URGENCY

**Priority:** HIGH  
**Urgency:** Can run tonight  
**User Impact:** Unblocks combo system for production  
**Risk Level:** LOW (transactional, auto-rollback)

---

## ✅ AUTHORIZATION

**Approved By:** Brian Lapp  
**Approval Date:** October 10, 2025  
**Authorization:** Execute unattended during off-hours  

---

## 📞 ESCALATION

**If Issues Occur:**
1. Document error message
2. Verify transaction rolled back
3. Leave status report in `COMBO_MIGRATION_RESULT.md`
4. Brian will review when back online

**No Need to Escalate If:**
- Script completes successfully
- Orphan rate < 1%
- Validation queries pass

---

## 🎉 SUCCESS MESSAGE

When complete, create `COMBO_MIGRATION_RESULT.md` with:
- Execution timestamp
- Orphan rate achieved
- Number of combo items created
- Validation query results
- Status: ✅ COMPLETE

---

**Safe to execute unattended!** 🚀  
**Brian can review results when he gets home.** 🏠



