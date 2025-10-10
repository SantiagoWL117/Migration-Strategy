# Combo Items Migration Fix

**Date:** October 10, 2025  
**Author:** Brian Lapp, Santiago  
**Status:** Ready for Implementation  
**Priority:** CRITICAL (P0)

---

## 🔴 Problem Statement

### The Issue
**99.8% of combo_groups are orphaned** - they have NO dishes linked via `combo_items`.

### Current State (Oct 10, 2025)
```sql
Combo Groups: 8,234
Combo Items:  63
Groups with items: 16 (0.2%)
ORPHANED: 8,218 (99.8%)
```

### Root Cause
V1 MySQL stored combo-dish associations in a `combos` junction table:
```sql
-- V1 Structure
CREATE TABLE combos (
  id INT PRIMARY KEY,
  combo_group_id INT,  -- FK to combo_groups
  menu_id INT,         -- FK to menu (dishes)
  step_order INT
);
```

**This junction table was NEVER migrated to V3's `combo_items` table.**

---

## 📊 Impact Analysis

### Business Impact
- **Broken Feature:** Combo meals cannot display their component dishes
- **Revenue Loss:** Customers can't order combos → lost sales
- **Restaurant Count:** 944 restaurants affected
- **Data Loss:** ~110,000+ combo-dish associations missing

### Technical Debt
- Frontend will fail loading combo data
- Order processing for combos impossible
- Reporting/analytics on combos broken

---

## ✅ Solution Overview

### Strategy
1. Load V1 `combos` junction table data
2. Map V1 IDs to V3 IDs (combo_groups + dishes)
3. Bulk insert into `combo_items` table
4. Validate orphan rate drops below 5%

### Expected Outcome
```
Before:  8,218 orphaned (99.8%)
After:   < 400 orphaned (< 5%)
Success: 95%+ groups have items
```

---

## 📁 File Structure

```
combos/
├── README_COMBO_FIX.md              ← You are here
├── fix_combo_items_migration.sql    ← Main migration script
├── validate_combo_fix.sql           ← Validation test suite
└── rollback_combo_fix.sql           ← Emergency rollback
```

---

## 🚀 Execution Guide

### Prerequisites

1. **Access Requirements:**
   - Supabase project access
   - Database admin credentials
   - MCP Supabase tools enabled

2. **Data Requirements:**
   ```bash
   # Ensure V1 combos file exists
   ls -lh /Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu\ &\ Catalog\ Entity/converted/menuca_v1_combos_postgres.sql
   # Should show ~110K INSERT statements
   ```

3. **Backup:**
   ```sql
   -- Create backup of current state
   CREATE TABLE menuca_v3.combo_items_backup_$(date +%Y%m%d) AS
   SELECT * FROM menuca_v3.combo_items;
   
   CREATE TABLE menuca_v3.combo_groups_backup_$(date +%Y%m%d) AS
   SELECT * FROM menuca_v3.combo_groups;
   ```

### Step-by-Step Execution

#### Step 1: Run Pre-Migration Validation
```bash
# Check current state
psql -f validate_combo_fix.sql
# Expected: Orphan rate ~99.8%
```

#### Step 2: Execute Migration
```bash
# Run the fix (takes ~2-5 minutes)
psql -f fix_combo_items_migration.sql

# Watch for:
# - "PRE-MIGRATION STATE" output
# - "V1 combos loaded: XXXXX"
# - "Successfully mapped: XXXXX"
# - "New combo_items inserted: XXXXX"
# - "POST-MIGRATION STATE" output
```

#### Step 3: Validate Results
```bash
# Run full validation suite
psql -f validate_combo_fix.sql

# Review output for:
# ✓ Orphan rate < 5%
# ✓ No data integrity issues
# ✓ Expected vs actual counts match
# ✓ Sample combos look correct
```

#### Step 4: Spot Check in UI (Manual)
```sql
-- Get a sample combo to test
SELECT 
  cg.id, 
  cg.name, 
  cg.restaurant_id,
  string_agg(d.name, ', ') as dishes
FROM menuca_v3.combo_groups cg
JOIN menuca_v3.combo_items ci ON cg.id = ci.combo_group_id
JOIN menuca_v3.dishes d ON ci.dish_id = d.id
GROUP BY cg.id, cg.name, cg.restaurant_id
LIMIT 5;
```
Load one of these combos in the frontend and verify dishes display correctly.

#### Step 5: Monitor for 24 Hours
- Check error logs for combo-related errors
- Monitor query performance for combo queries
- Watch for customer support tickets

---

## 🔄 Rollback Procedure

### When to Rollback
- Orphan rate still > 20% after migration
- Data integrity issues found (null FKs)
- Duplicates created
- Frontend errors spike
- Wrong dishes mapped to combos

### How to Rollback
```bash
# Option 1: Full rollback (delete ALL combo_items)
psql -f rollback_combo_fix.sql
# Then uncomment OPTION 1 and re-run

# Option 2: Partial rollback (V1 items only)
# Uncomment OPTION 2 in rollback script

# Option 3: Time-based (last N hours)
# Uncomment OPTION 3 and set time window
```

### After Rollback
1. Investigate root cause using validation output
2. Fix issues in `fix_combo_items_migration.sql`
3. Test fix in staging environment first
4. Re-run migration when ready

---

## 📋 Validation Checklist

Run `validate_combo_fix.sql` and verify:

- [ ] **Overall Stats:** Combo items > 50,000
- [ ] **Orphan Rate:** < 5% (target: < 1%)
- [ ] **Item Counts:** Expected vs actual match > 90%
- [ ] **Distribution:** Most combos have 2-10 items
- [ ] **Samples:** Top 10 combos show correct dishes
- [ ] **Source Breakdown:** V1 and V2 both covered
- [ ] **Restaurant Coverage:** 500+ restaurants have active combos
- [ ] **Dish Usage:** 5,000+ unique dishes in combos
- [ ] **Data Integrity:** Zero null FKs, zero invalid refs
- [ ] **Duplicates:** No duplicate combo-dish pairs
- [ ] **Recent Items:** Newly created items have correct timestamps

---

## ⚠️ Known Issues & Edge Cases

### Issue 1: V2 Combos Not Migrated
**Status:** Out of scope for this fix  
**Reason:** V2 combos structure different, needs separate migration  
**Impact:** ~300 V2-only combo groups may remain orphaned  
**Plan:** Address in Phase 2 if V2 data available

### Issue 2: Unmapped Legacy IDs
**Description:** Some V1 menu_ids may not exist in V3 dishes  
**Cause:** Dishes deleted/not migrated from V1  
**Mitigation:** Migration script skips unmapped IDs  
**Expected:** < 5% unmapped

### Issue 3: Combo Rules Validation
**Description:** `combo_rules` JSONB may have incorrect `item_count`  
**Cause:** V1 data inconsistencies  
**Mitigation:** Validation compares expected vs actual  
**Action:** Flag mismatches for manual review

### Issue 4: Step Order Gaps
**Description:** `display_order` may have gaps (0, 0, 0, 5)  
**Impact:** Cosmetic only, doesn't break functionality  
**Fix:** Optional cleanup script in Phase 2

---

## 📊 Performance Considerations

### Migration Runtime
- **Expected Duration:** 2-5 minutes
- **Records Processed:** ~110,000 combos
- **Insert Rate:** ~500-1,000 rows/second
- **Table Locks:** Minimal (single table)

### Query Performance After Migration
```sql
-- Before: Fast (no items to join)
SELECT * FROM combo_groups;

-- After: Slightly slower (now joins combo_items)
-- Add index if needed:
CREATE INDEX CONCURRENTLY idx_combo_items_combo_group_id 
ON menuca_v3.combo_items(combo_group_id);
```

### Database Size Impact
- **Current combo_items:** ~4 KB (63 rows)
- **After migration:** ~5-10 MB (~110K rows)
- **Growth:** Negligible (<0.01% of database)

---

## 🧪 Testing Strategy

### Staging Test Plan
1. **Clone production to staging**
2. **Run migration on staging**
3. **Validate results** (run validation suite)
4. **Frontend smoke test** (load 10 random combos)
5. **Load test** (query 1000 combos, measure latency)
6. **Rollback test** (verify rollback works)

### Production Rollout
1. **Maintenance window:** Low traffic period (2-6am)
2. **Team on call:** Brian + Santiago
3. **Rollback ready:** Validated rollback script
4. **Monitoring:** Watch logs + performance dashboard
5. **Success criteria:** Orphan rate < 5% + no errors

---

## 📞 Support & Escalation

### Primary Contact
**Brian Lapp**  
Role: Database Migration Lead  
Slack: @brian  
Email: brian@example.com

### Backup Contact
**Santiago**  
Role: Database Admin  
Slack: @santiago  
Email: santiago@example.com

### Escalation Path
1. Check validation output for specific errors
2. Review `LOAD_PROGRESS.md` for similar issues
3. Slack #database-migrations channel
4. Escalate to CTO if critical

---

## 📚 Related Documentation

- **Schema Design:** `/documentation/Menu & Catalog/menu-catalog-mapping.md`
- **Migration Strategy:** `/MEMORY_BANK/ETL_METHODOLOGY.md`
- **Load Progress:** `/Database/Menu & Catalog Entity/LOAD_PROGRESS.md`
- **Combo Schema:** `/Database/Schemas/menuca_v3.sql` (lines for combo tables)

---

## 🎯 Success Metrics

### Quantitative Goals
- ✅ Orphan rate < 5%
- ✅ Data integrity 100% (no null/invalid FKs)
- ✅ Migration completes in < 10 minutes
- ✅ No rollback required
- ✅ Zero production incidents

### Qualitative Goals
- ✅ Combos display correctly in frontend
- ✅ Customers can order combos
- ✅ Restaurant owners can manage combos
- ✅ Reporting on combos works

---

## 📅 Timeline

| Phase | Task | Duration | Owner |
|-------|------|----------|-------|
| **Phase 1** | Code review + staging test | 2 hours | Brian |
| **Phase 2** | Production migration | 30 mins | Santiago |
| **Phase 3** | Validation + smoke test | 1 hour | Brian |
| **Phase 4** | Monitor for 24h | 1 day | Both |
| **Total** | **~2 days** | | |

**Target Date:** October 11, 2025

---

## ✅ Sign-Off

### Reviewed By
- [ ] Brian Lapp (Database Lead)
- [ ] Santiago (Database Admin)
- [ ] James Walker (Project Lead)

### Approved By
- [ ] CTO

### Deployed By
- [ ] Date:
- [ ] Environment: Staging / Production
- [ ] Result: Success / Rollback
- [ ] Notes:

---

**Last Updated:** October 10, 2025  
**Version:** 1.0  
**Status:** Ready for Review

