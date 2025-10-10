# Emergency Rollback Guide

**Purpose:** Quick reference for rolling back database changes  
**When to Use:** If validation fails or issues detected post-deployment  
**Contact:** Brian Lapp (primary) | Santiago (backup)

---

## ⚠️ WHEN TO ROLLBACK

### Immediate Rollback Required
- ❌ Database corruption detected
- ❌ Data loss > 1% of any table
- ❌ Critical errors preventing orders
- ❌ Performance degradation > 50%
- ❌ Security breach detected
- ❌ RLS blocking valid access

### Consider Rollback
- ⚠️ Error rate > 5%
- ⚠️ P95 latency > 2x baseline
- ⚠️ Customer complaints > 10/hour
- ⚠️ Combo orphan rate still > 20%

---

## ROLLBACK OPTIONS

### Option 1: Full Database Restore (15 minutes)

**Use When:** Complete rollback needed, all changes must be reverted

```bash
# 1. Connect to Supabase
# (Use dashboard or CLI)

# 2. Restore from backup
# Via Dashboard: Database > Backups > Select backup > Restore
# Via CLI:
supabase db restore --backup-id <backup-id-from-step-1>

# 3. Verify restoration
psql -h [host] -U postgres -d postgres -c "SELECT COUNT(*) FROM menuca_v3.combo_items"
# Should show original count (~63 for staging, actual production count)

# 4. Test application
# Load frontend, test menu, test combos
```

**Steps:**
1. **Announce** - Post in #database-migrations: "ROLLBACK IN PROGRESS"
2. **Execute** - Run restore command
3. **Verify** - Check row counts match pre-deployment
4. **Test** - Smoke test application
5. **Monitor** - Watch for 30 minutes
6. **Communicate** - Post completion status

**Time:** ~15 minutes  
**Risk:** LOW (standard PostgreSQL restore)

---

### Option 2: Rollback Indexes Only (10 minutes)

**Use When:** Indexes causing issues, but RLS and combo fix are okay

```sql
-- Generate drop statements
SELECT 'DROP INDEX CONCURRENTLY IF EXISTS menuca_v3.' || indexname || ';'
FROM pg_indexes
WHERE schemaname = 'menuca_v3'
  AND indexname LIKE 'idx_%'
  AND indexname NOT IN (
    -- Keep pre-existing indexes (check pg_indexes before deployment)
    SELECT indexname FROM [backup_indexes_table]
  );

-- Execute generated statements (copy output and run)

-- Verify indexes dropped
SELECT 
  schemaname, 
  tablename, 
  COUNT(*) as index_count
FROM pg_indexes
WHERE schemaname = 'menuca_v3'
GROUP BY schemaname, tablename
ORDER BY tablename;
```

**Steps:**
1. Generate drop statements
2. Execute DROP INDEX CONCURRENTLY commands
3. Verify indexes removed
4. Test query performance (should revert to baseline)
5. Monitor application

**Time:** ~10 minutes  
**Risk:** LOW (indexes can be recreated)

---

### Option 3: Rollback RLS Only (5 minutes)

**Use When:** RLS policies causing access issues

```sql
-- Disable RLS on all tables
DO $$
DECLARE
  tbl RECORD;
BEGIN
  FOR tbl IN 
    SELECT tablename 
    FROM pg_tables 
    WHERE schemaname = 'menuca_v3'
  LOOP
    EXECUTE 'ALTER TABLE menuca_v3.' || tbl.tablename || ' DISABLE ROW LEVEL SECURITY';
    RAISE NOTICE 'Disabled RLS on menuca_v3.%', tbl.tablename;
  END LOOP;
END $$;

-- Drop all policies (optional, if disabling isn't enough)
DO $$
DECLARE
  pol RECORD;
BEGIN
  FOR pol IN 
    SELECT tablename, policyname
    FROM pg_policies 
    WHERE schemaname = 'menuca_v3'
  LOOP
    EXECUTE 'DROP POLICY IF EXISTS ' || pol.policyname || ' ON menuca_v3.' || pol.tablename;
    RAISE NOTICE 'Dropped policy % on menuca_v3.%', pol.policyname, pol.tablename;
  END LOOP;
END $$;

-- Verify RLS disabled
SELECT 
  schemaname, 
  tablename, 
  rowsecurity 
FROM pg_tables 
WHERE schemaname = 'menuca_v3' 
  AND rowsecurity = true;
-- Expected: 0 rows
```

**Steps:**
1. Run disable RLS script
2. Verify RLS disabled on all tables
3. Test application access
4. Monitor for access issues

**Time:** ~5 minutes  
**Risk:** MEDIUM (removes security layer, re-deploy quickly)

---

### Option 4: Rollback Combo Fix Only (10 minutes)

**Use When:** Combo fix created bad data, but indexes and RLS are okay

```bash
# Option A: Delete all combo_items created today
psql -h [host] -U postgres -d postgres <<EOF
BEGIN;

-- Backup current state first
CREATE TABLE menuca_v3.combo_items_rollback_backup AS
SELECT * FROM menuca_v3.combo_items;

-- Delete items created by migration
DELETE FROM menuca_v3.combo_items 
WHERE created_at >= CURRENT_DATE;

-- Check count
SELECT COUNT(*) FROM menuca_v3.combo_items;
-- Should match pre-migration count (~63)

COMMIT;
EOF
```

**Alternative: Time-based rollback**
```sql
BEGIN;

-- Delete items created in last N hours
DELETE FROM menuca_v3.combo_items 
WHERE created_at >= NOW() - INTERVAL '2 hours';

-- Verify orphan rate back to ~99.8%
SELECT 
  COUNT(*) as total_groups,
  COUNT(DISTINCT ci.combo_group_id) as groups_with_items,
  ROUND(((COUNT(*) - COUNT(DISTINCT ci.combo_group_id))::numeric / COUNT(*)::numeric * 100), 2) as orphan_pct
FROM menuca_v3.combo_groups cg
LEFT JOIN menuca_v3.combo_items ci ON cg.id = ci.combo_group_id;

COMMIT;
```

**Steps:**
1. Create backup table
2. Delete migrated combo_items
3. Verify row count matches pre-migration
4. Test combo display (should be broken again)
5. Plan re-migration

**Time:** ~10 minutes  
**Risk:** LOW (can re-run migration after fix)

---

## ROLLBACK DECISION TREE

```
Issue Detected
├─ Is it a data corruption issue?
│  └─ YES → Option 1: Full Database Restore
│
├─ Are queries slow/timing out?
│  └─ YES → Option 2: Rollback Indexes
│
├─ Are users seeing wrong data/access denied?
│  └─ YES → Option 3: Rollback RLS
│
└─ Are combos broken/showing wrong dishes?
   └─ YES → Option 4: Rollback Combo Fix
```

---

## POST-ROLLBACK ACTIONS

### Immediate (0-30 minutes)

1. **Verify Service Restored**
   - [ ] Frontend loads
   - [ ] Users can login
   - [ ] Orders can be placed
   - [ ] Menu displays correctly

2. **Monitor Metrics**
   - [ ] Error rate back to baseline
   - [ ] Query performance normal
   - [ ] No customer complaints
   - [ ] Database CPU/memory normal

3. **Communicate Status**
   - [ ] Post in #database-migrations
   - [ ] Update status page
   - [ ] Notify stakeholders
   - [ ] Brief customer support

### Short-Term (1-4 hours)

4. **Root Cause Analysis**
   - What went wrong?
   - Why didn't staging catch it?
   - What validation was missing?
   - Document findings

5. **Review Logs**
   - Database logs
   - Application logs
   - Error tracking
   - User reports

6. **Assess Data**
   - Any data loss?
   - Any data inconsistency?
   - Backup integrity?

### Medium-Term (1-3 days)

7. **Fix & Re-Test**
   - Fix identified issues
   - Add missing validations
   - Test in staging thoroughly
   - Get team review

8. **Schedule Re-Deployment**
   - Pick new maintenance window
   - Notify team 24h in advance
   - Prepare rollback plan
   - Have backup on standby

9. **Post-Mortem**
   - Write incident report
   - Document lessons learned
   - Update procedures
   - Share with team

---

## VALIDATION AFTER ROLLBACK

Run these queries to verify rollback success:

```sql
-- 1. Check row counts match pre-deployment
SELECT 
  'combo_groups' as table_name, COUNT(*) FROM menuca_v3.combo_groups
UNION ALL
SELECT 'combo_items', COUNT(*) FROM menuca_v3.combo_items
UNION ALL
SELECT 'dishes', COUNT(*) FROM menuca_v3.dishes;

-- 2. Check RLS status
SELECT 
  COUNT(*) as tables_with_rls_enabled
FROM pg_tables 
WHERE schemaname = 'menuca_v3' 
  AND rowsecurity = true;
-- Expected after RLS rollback: 0

-- 3. Check index count
SELECT 
  COUNT(*) as total_indexes
FROM pg_indexes
WHERE schemaname = 'menuca_v3';
-- Compare to pre-deployment count

-- 4. Test query performance
EXPLAIN ANALYZE
SELECT * FROM menuca_v3.dishes WHERE restaurant_id = 123;
-- Should match pre-deployment execution time

-- 5. Smoke test
SELECT 
  r.name as restaurant,
  COUNT(DISTINCT d.id) as dish_count,
  COUNT(DISTINCT cg.id) as combo_count
FROM menuca_v3.restaurants r
LEFT JOIN menuca_v3.dishes d ON r.id = d.restaurant_id
LEFT JOIN menuca_v3.combo_groups cg ON r.id = cg.restaurant_id
WHERE r.id = 123
GROUP BY r.name;
```

---

## EMERGENCY CONTACTS

### On-Call Rotation
- **Primary:** Brian Lapp - [phone]
- **Backup:** Santiago - [phone]
- **Escalation:** James Walker (CTO) - [phone]

### Communication Channels
- **Slack:** #database-migrations
- **War Room:** #deployment-war-room
- **Incidents:** #incidents (if critical)

---

## ROLLBACK TESTING

**IMPORTANT:** Test rollback procedures in staging BEFORE production deployment!

```bash
# Staging Rollback Test
1. Complete staging deployment (tickets 01-05)
2. Intentionally trigger a rollback scenario
3. Execute rollback procedure
4. Verify restoration
5. Document any issues
6. Update this guide if needed
```

---

## ROLLBACK HISTORY

Log all rollbacks here for future reference:

### [Date] - [Environment] - [Reason]
- **Issue:** [Description]
- **Rollback Option Used:** [1/2/3/4]
- **Duration:** [X minutes]
- **Root Cause:** [Description]
- **Prevention:** [What was changed]

---

**Document Version:** 1.0  
**Last Updated:** October 10, 2025  
**Last Tested:** [Not yet tested - test in staging first!]

