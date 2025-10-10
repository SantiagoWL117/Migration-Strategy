# TICKET 09: Production Combo Fix

**Phase:** Production Deployment - Step 4 of 5  
**Environment:** Production Database ⚠️  
**Estimated Duration:** 20-30 minutes  
**Prerequisites:** Tickets 06-08 (Backup, Indexes, RLS) must be COMPLETE

---

## CONTEXT

- **Current Step:** 9 of 11 (Production Combo Fix)
- **Purpose:** Fix 99.8% orphaned combo groups in production
- **Risk Level:** HIGH (modifies production data, ~110K inserts)
- **⚠️ MOST CRITICAL STEP:** This changes production data permanently

**Before You Begin:**
- Verify production backup ID from Ticket 06 is accessible
- Confirm indexes and RLS working from Tickets 07-08
- This matches staging Ticket 04
- **CRITICAL:** This inserts substantial data - be certain before executing

**What This Does:**
- Inserts ~110,000 combo_items records
- Fixes 8,000+ broken combo groups
- Enables combo ordering for customers
- **Revenue Impact:** Enables combo sales across 8,000+ restaurants

---

## TASK

Execute the combo fix migration on production database. This is the highest-risk ticket as it permanently modifies data. Success in staging (Ticket 04) gives confidence, but extra validation required.

**Triple-Check Before Executing:**
- ✓ Staging succeeded (Ticket 04 orphan rate < 5%)
- ✓ Production backup exists and verified (Ticket 06)
- ✓ Indexes deployed (Ticket 07 - needed for performance)
- ✓ Team standing by for rollback if needed

---

## COMMANDS TO RUN

### Step 1: Final Pre-Execution Validation

**Agent Action:** Verify production is ready

```sql
-- Comprehensive pre-check
SELECT 
  'PRODUCTION PRE-COMBO-FIX' as label,
  -- Current combo state
  (SELECT COUNT(*) FROM menuca_v3.combo_groups) as combo_groups,
  (SELECT COUNT(*) FROM menuca_v3.combo_items) as combo_items_before,
  -- Verify indexes exist
  (SELECT COUNT(*) FROM pg_indexes WHERE schemaname = 'menuca_v3' AND indexname = 'idx_combo_items_group') as combo_indexes,
  -- Verify RLS enabled
  (SELECT COUNT(*) FROM pg_tables WHERE schemaname = 'menuca_v3' AND tablename = 'combo_items' AND rowsecurity = true) as rls_enabled,
  NOW() as timestamp;
```

**Expected Output:**
- combo_groups: ~8,234
- combo_items_before: Low (~63-100)
- combo_indexes: 1 (index exists)
- rls_enabled: 1 (RLS active)

**If ANY unexpected:**
- STOP and investigate
- Do not proceed without proper setup

### Step 2-9: Follow Ticket 04 Process

Execute the same steps as Ticket 04:
1. Verify V1 source file exists
2. Document pre-migration state
3. Calculate orphan rate (should be ~99.8%)
4. Verify legacy ID columns exist
5. Execute combo fix migration script
6. Verify post-migration state
7. Calculate post-fix orphan rate (target: < 5%)
8. Run comprehensive validation
9. Sample combo check

**Reference Ticket 04 for detailed commands.**

**Key Difference:** This is production - WATCH CAREFULLY

### Step 10: Production Data Verification

**Agent Action:** Extra validation for production

```sql
-- Verify production combo data looks correct
SELECT 
  'PRODUCTION COMBO VALIDATION' as label,
  -- Items created
  (SELECT COUNT(*) FROM menuca_v3.combo_items WHERE created_at >= CURRENT_DATE) as items_created_today,
  -- Coverage
  (SELECT COUNT(DISTINCT restaurant_id) FROM menuca_v3.combo_groups cg
   JOIN menuca_v3.combo_items ci ON cg.id = ci.combo_group_id) as restaurants_with_combos,
  -- Quality check
  (SELECT COUNT(*) FROM menuca_v3.combo_items WHERE dish_id IS NULL) as null_dish_ids,
  (SELECT COUNT(*) FROM menuca_v3.combo_items ci
   LEFT JOIN menuca_v3.dishes d ON ci.dish_id = d.id WHERE d.id IS NULL) as invalid_dish_refs,
  NOW() as validation_time;
```

**Expected Output:**
- items_created_today: 50,000-120,000
- restaurants_with_combos: 500-900
- null_dish_ids: 0 (CRITICAL - must be zero)
- invalid_dish_refs: 0 (CRITICAL - must be zero)

**If null_dish_ids > 0 OR invalid_dish_refs > 0:**
- **CRITICAL DATA CORRUPTION**
- **IMMEDIATE ROLLBACK REQUIRED**
- Do NOT proceed

### Step 11: Check Customer-Facing Impact

**Agent Action:** Verify combos visible to customers

```sql
-- Simulate customer viewing combo
-- Use real restaurant ID from production
DO $$
BEGIN
  PERFORM set_config('request.jwt.claims', '{}', true);
END $$;

SELECT 
  cg.name as combo_name,
  string_agg(d.name, ' + ') as items,
  COUNT(ci.id) as item_count
FROM menuca_v3.combo_groups cg
JOIN menuca_v3.combo_items ci ON cg.id = ci.combo_group_id
JOIN menuca_v3.dishes d ON ci.dish_id = d.id
WHERE cg.is_active = true
AND ci.created_at >= CURRENT_DATE
GROUP BY cg.id, cg.name
ORDER BY random()
LIMIT 5;

-- Expected: 5 combos with reasonable items
-- Manual review: Do these look like real menu combos?
```

**Human Review Required:**
- Do combo names make sense?
- Do dish combinations look reasonable?
- Would a customer want to order these?

**If Data Looks Wrong:**
- Mapping issue occurred
- Consider rollback
- Investigate before deploying further

### Step 12: Monitor Application Impact

**Agent Action:** Check for errors

```sql
-- Check for combo-related errors post-deployment
SELECT 
  'APPLICATION IMPACT' as label,
  (SELECT COUNT(*) FROM pg_stat_activity WHERE state = 'active') as active_connections,
  (SELECT COUNT(*) FROM pg_stat_activity WHERE query LIKE '%combo%' AND state = 'active') as combo_queries,
  NOW() as check_time;
```

**Watch for:**
- Sudden spike in active connections
- Many combo queries failing
- Database errors

---

## VALIDATION CRITERIA

All Ticket 04 validations PLUS:

- [ ] **Production-specific validations**
  - Items created: 50,000-120,000 ✓
  - No null or invalid FKs ✓ (CRITICAL)
  - Restaurants coverage: 500+ ✓
  
- [ ] **Customer-facing validation**
  - Sample combos look correct ✓
  - Human review PASS ✓
  - Public can view combos ✓
  
- [ ] **Application health**
  - No error spikes ✓
  - Database stable ✓
  - No customer reports ✓

---

## SUCCESS CONDITIONS

If all checks pass:
1. **Log results (Ticket 04 format)**
2. **Production combo status:**
   ```
   ## Production Combo Fix Complete
   
   BEFORE:
   - Combo Items: ~63
   - Orphan Rate: 99.8%
   - Broken: 8,218 combo groups
   
   AFTER:
   - Combo Items: ~[count] (HUGE increase!)
   - Orphan Rate: [X]% (target: <5%) ✓
   - Fixed: ~8,000+ combo groups
   
   DATA QUALITY:
   - ✓ No null FKs
   - ✓ No invalid references
   - ✓ Combos look correct
   - ✓ Customer-facing data good
   
   BUSINESS IMPACT:
   - ✓ 8,000+ restaurants can now sell combos
   - ✓ Revenue opportunity unlocked
   
   STATUS: COMPLETE
   ```
3. **Communicate:** Post in war room: "Production combo fix complete. ~110K items created. Orphan rate [X]%. Data validated. Proceeding to final validation."
4. **Proceed:** Next ticket 10_PRODUCTION_VALIDATION.md

---

## FAILURE CONDITIONS

### Scenario: Data Corruption (CRITICAL)

**Symptoms:**
- Null dish_ids found
- Invalid FK references
- Orphan rate > 20%

**Actions:**
1. **STOP IMMEDIATELY**
2. **DO NOT PROCEED TO TICKET 10**
3. **EXECUTE ROLLBACK IMMEDIATELY**
4. Alert team: "Data corruption detected in combo fix. Rolling back."
5. Review logs to understand what went wrong
6. May need full database restore

### Scenario: Wrong Data Mapped

**Symptoms:**
- Sample combos look wrong
- Unrelated items together
- Human review fails

**Actions:**
1. STOP
2. Review 20+ sample combos
3. If systematically wrong, rollback
4. Investigate legacy ID mapping
5. Fix and re-test in staging

### Scenario: Partial Migration

**Symptoms:**
- Only 10,000-30,000 items created (expected 100K+)
- Orphan rate improved but still > 10%

**Actions:**
1. STOP
2. Check migration logs for errors
3. Identify why partial
4. Decision: Rollback or accept partial fix?
5. If rollback, investigate and retry

---

## ROLLBACK

### Option A: Delete Combo Items (10 minutes)

```sql
BEGIN;

-- Backup first
CREATE TABLE menuca_v3.combo_items_prod_backup_$(date +%Y%m%d) AS
SELECT * FROM menuca_v3.combo_items;

-- Delete today's items
DELETE FROM menuca_v3.combo_items 
WHERE created_at >= CURRENT_DATE;

-- Verify
SELECT COUNT(*) FROM menuca_v3.combo_items;
-- Should match pre-migration count

-- Check orphan rate back to ~99.8%
SELECT 
  ROUND(((COUNT(*) - COUNT(DISTINCT ci.combo_group_id))::numeric / COUNT(*)::numeric * 100), 2) as orphan_pct
FROM menuca_v3.combo_groups cg
LEFT JOIN menuca_v3.combo_items ci ON cg.id = ci.combo_group_id;

COMMIT;
```

### Option B: Full Database Restore (15 minutes)

**⚠️ LAST RESORT - Use if corruption detected**

```bash
# Restore from Ticket 06 backup
supabase db restore --backup-id [production-backup-id-from-ticket-06]
```

**When to Use:**
- Option A: Combo fix only issue
- Option B: Data corruption, multiple systems affected

---

## CONTEXT FOR NEXT STEP

```
PRODUCTION COMBO FIX COMPLETE
================================================================================

MIGRATION RESULTS:
- Items Inserted: ~[count]
- Orphan Rate: 99.8% → [X]%
- Status: ✓ SUCCESS

DATA VALIDATION:
- Integrity: ✓ CLEAN (no nulls, no invalid FKs)
- Sample Check: ✓ PASS (combos look correct)
- Customer Facing: ✓ WORKING

BUSINESS IMPACT:
- Restaurants Enabled: ~8,000+
- Combo Orders: NOW POSSIBLE
- Revenue: UNLOCKED

DEPLOYMENT PROGRESS:
✓ Backup (Ticket 06)
✓ Indexes (Ticket 07)
✓ RLS (Ticket 08)
✓ Combos (Ticket 09)

FINAL STEP:
→ Proceed to 10_PRODUCTION_VALIDATION.md
→ 24-hour monitoring begins
→ Then deployment complete!
```

**Next Ticket:** `10_PRODUCTION_VALIDATION.md` (FINAL TICKET!)

---

## NOTES FOR AGENT

### This is the Riskiest Step

**Why High Risk:**
- Modifies production data permanently
- Inserts 100K+ rows (large change)
- Wrong mapping = wrong combos forever
- Customers will see this data

**Risk Mitigation:**
- ✓ Tested successfully in staging
- ✓ Production backup exists
- ✓ Validation suite comprehensive
- ✓ Rollback tested and ready
- ✓ Team standing by

### Decision Points

**GO Decision:**
- Staging succeeded (Ticket 04)
- Backup verified (Ticket 06)
- All pre-checks pass
- Team ready

**NO-GO Decision:**
- Any validation fails
- Pre-checks concerning
- Staging had issues
- Team not ready

**ROLLBACK Decision:**
- Data corruption detected
- Wrong data mapped
- Orphan rate > 20%
- Customer impact

### After This Step

- One ticket left (10 - Final Validation)
- Then 24-hour monitoring
- Then deployment complete!

**Almost there - stay focused!**

---

**Ticket Status:** READY  
**Dependencies:** Tickets 06-08 COMPLETE  
**Last Updated:** October 10, 2025  

**⚠️ HIGHEST RISK TICKET - TRIPLE CHECK BEFORE EXECUTING ⚠️**

