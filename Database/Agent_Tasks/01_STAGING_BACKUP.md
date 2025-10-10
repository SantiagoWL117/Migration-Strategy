# TICKET 01: Staging Backup

**Phase:** Staging Deployment - Step 1 of 5  
**Environment:** Staging Database  
**Estimated Duration:** 10-15 minutes  
**Prerequisites:** Ticket 00 (Pre-Flight Check) must be COMPLETE

---

## CONTEXT

- **Current Step:** 1 of 11 (Staging Backup)
- **Purpose:** Create verified backup of staging database before making any changes
- **Risk Level:** LOW (backup creation is safe)
- **Dependency:** Ticket 00 must show "PROCEED" status

**Before You Begin:**
- Read EXECUTION_LOG.md to verify Ticket 00 is COMPLETE
- Confirm staging database connection is working
- Have rollback plan ready (though unlikely to need it for backup)

---

## TASK

Create a full backup of the staging database and verify it completed successfully. This backup serves as our safety net - if anything goes wrong during tickets 02-05, we can restore from this point.

**Why This Matters:**
- Enables quick rollback if needed (15 minute restore)
- Provides audit trail of pre-optimization state
- Required before making any schema changes

---

## COMMANDS TO RUN

### Step 1: Document Pre-Backup State

**Agent Action:** Capture current database state for verification after backup

```sql
-- Get current row counts
SELECT 
  'PRE-BACKUP STATE' as label,
  (SELECT COUNT(*) FROM menuca_v3.restaurants) as restaurants,
  (SELECT COUNT(*) FROM menuca_v3.dishes) as dishes,
  (SELECT COUNT(*) FROM menuca_v3.combo_groups) as combo_groups,
  (SELECT COUNT(*) FROM menuca_v3.combo_items) as combo_items,
  (SELECT COUNT(*) FROM menuca_v3.ingredients) as ingredients,
  (SELECT COUNT(*) FROM menuca_v3.users) as users,
  NOW() as timestamp;
```

**Expected Output:**
- restaurants: ~944
- dishes: ~10,585
- combo_groups: ~8,234
- combo_items: ~63
- ingredients: ~31,542
- users: ~32,349

**Agent Note:** Record these exact counts. We'll verify them after backup.

### Step 2: Check Database Size

```sql
-- Get database size before backup
SELECT 
  pg_size_pretty(pg_database_size(current_database())) as database_size,
  pg_size_pretty(SUM(pg_total_relation_size(schemaname||'.'||tablename))::bigint) as menuca_v3_size
FROM pg_tables
WHERE schemaname = 'menuca_v3';
```

**Expected Output:**
- database_size: [Note the size for backup verification]
- menuca_v3_size: [Should be significant portion of database]

### Step 3: Create Backup Label

**Agent Action:** Generate a descriptive backup label

```bash
# Generate backup label with timestamp
BACKUP_LABEL="staging-pre-optimization-$(date +%Y%m%d-%H%M%S)"
echo "Backup Label: $BACKUP_LABEL"
```

**Agent Note:** This label will help identify the backup later if rollback is needed.

### Step 4: Create Backup via Supabase Dashboard

**⚠️ IMPORTANT:** The agent cannot directly create Supabase backups via CLI without additional permissions. You must use the MCP tools or prompt the human operator.

**Option A: If Supabase MCP tools support backup creation**
```
Use the appropriate MCP tool to create a backup labeled:
"staging-pre-optimization-[timestamp]"
```

**Option B: If backup requires human action**
```
STOP: Alert human operator to create backup via Supabase dashboard:
1. Log in to Supabase Dashboard
2. Navigate to Database > Backups
3. Click "Create Manual Backup"
4. Label: "staging-pre-optimization-[timestamp]"
5. Click "Create Backup"
6. Wait for completion (usually 2-5 minutes)
7. Confirm backup in list and note backup ID
```

**Agent Decision:** Determine which option applies and either execute or alert human.

### Step 5: Verify Backup Creation

**After backup is created (either method):**

```bash
# Via Supabase CLI (if available)
supabase db backups list --project-ref [staging-project-ref]

# Look for backup with today's date and "pre-optimization" label
```

**Expected Output:**
- Backup appears in list
- Status: "completed" or "available"
- Size: Matches database size from Step 2
- Timestamp: Within last 10 minutes

**Agent Note:** If backup status is "in_progress", wait and check again. If status is "failed", STOP and alert human.

### Step 6: Test Backup Integrity (Optional but Recommended)

**If time allows and tools support it:**

```bash
# Verify backup is downloadable (proves it's not corrupted)
# This may require manual verification via dashboard

# Alternative: Check backup metadata
supabase db backups get [backup-id] --project-ref [staging-project-ref]
```

**Expected Output:**
- Backup metadata shows correct size
- No error messages
- Backup is accessible

### Step 7: Document Backup Details

**Agent Action:** Record backup information for rollback reference

```bash
# Append to EXECUTION_LOG.md
cat >> /Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Agent_Tasks/EXECUTION_LOG.md <<EOF

================================================================================
TICKET 01: Staging Backup
================================================================================
Date/Time: $(date +"%Y-%m-%d %H:%M:%S")
Status: IN_PROGRESS

## Backup Details
- Backup Label: staging-pre-optimization-[timestamp]
- Backup ID: [backup-id-from-supabase]
- Database Size: [size from step 2]
- Row Counts (Pre-Backup):
  * restaurants: [actual count]
  * dishes: [actual count]
  * combo_groups: [actual count]
  * combo_items: [actual count]
  * ingredients: [actual count]
  * users: [actual count]

## Actions Taken
1. Documented pre-backup database state
2. Checked database size: [X GB]
3. Created backup with label: [label]
4. Verified backup completed successfully
5. Backup ID for rollback: [backup-id]

## Validation Results (see below)

EOF
```

---

## VALIDATION CRITERIA

Complete this checklist:

- [ ] **Pre-backup state documented**
  - Check: Row counts captured from Step 1
  
- [ ] **Database size recorded**
  - Check: Size from Step 2 noted for verification
  
- [ ] **Backup label generated**
  - Check: Label includes "staging-pre-optimization" and timestamp
  
- [ ] **Backup creation completed**
  - Check: Backup appears in Supabase backup list
  - Check: Status is "completed" or "available" (not "failed")
  
- [ ] **Backup size matches database size**
  - Check: Backup size ≈ database size (±10% acceptable)
  
- [ ] **Backup is recent**
  - Check: Timestamp is within last 15 minutes
  
- [ ] **Backup ID recorded**
  - Check: Backup ID documented in EXECUTION_LOG.md
  
- [ ] **No backup errors**
  - Check: No error messages during backup process

---

## SUCCESS CONDITIONS

**All validation criteria must PASS.**

If all checks pass:
1. **Log to EXECUTION_LOG.md:**
   ```
   ## Validation Results
   - ✓ Pre-backup state: DOCUMENTED
   - ✓ Backup creation: SUCCESS
   - ✓ Backup verification: PASS
   - ✓ Backup ID: [id]
   
   STATUS: COMPLETE
   ```

2. **Proceed to next ticket:**
   - Next: `02_STAGING_INDEXES.md`
   - We now have a safety net for rollback

3. **Context for next ticket:**
   - Backup ID: [record here]
   - Baseline row counts: [record here]
   - Ready to deploy indexes

---

## FAILURE CONDITIONS

**If ANY validation fails:**

### Scenario 1: Backup Creation Failed

**Symptoms:**
- Backup status shows "failed"
- Error message in Supabase dashboard
- Backup not appearing in list

**Actions:**
1. STOP - Do not proceed
2. Check Supabase dashboard for error details
3. Log error message to EXECUTION_LOG.md
4. Alert human operator:
   - "Staging backup failed: [error message]"
   - "Cannot proceed without backup"
   - "Need human to investigate Supabase backup issue"
5. Wait for human resolution

**Common Causes:**
- Insufficient Supabase project resources
- Database too large for plan limits
- Network connectivity issue
- Supabase service disruption

### Scenario 2: Backup Size Mismatch

**Symptoms:**
- Backup size << database size (e.g., 10 MB vs 500 MB expected)
- Suggests incomplete backup

**Actions:**
1. STOP - Do not proceed
2. Delete incomplete backup if possible
3. Retry backup creation once
4. If retry fails, alert human operator
5. Log both attempts to EXECUTION_LOG.md

### Scenario 3: Cannot Verify Backup

**Symptoms:**
- Backup created but can't verify it
- No access to backup list or details

**Actions:**
1. Ask human operator to verify backup via dashboard
2. If backup exists and looks correct, proceed
3. If backup cannot be verified, STOP and wait for human

### Scenario 4: Backup Taking Too Long

**Symptoms:**
- Backup status "in_progress" for > 15 minutes

**Actions:**
1. Wait up to 30 minutes total
2. Check database size - large DBs take longer
3. If still in progress after 30 min, alert human
4. Do NOT proceed without completed backup

---

## ROLLBACK

**Not Applicable** - Backup creation doesn't modify data.

If backup creation fails, simply retry or alert human. No data rollback needed.

---

## CONTEXT FOR NEXT STEP

**Record these details for Ticket 02:**

```
BACKUP INFORMATION:
- Backup ID: ______________ (CRITICAL - needed for rollback)
- Backup Label: staging-pre-optimization-[timestamp]
- Backup Size: _____ GB/MB
- Backup Status: completed
- Created At: [timestamp]

DATABASE STATE (Pre-Indexes):
- Total Tables: ~50
- Total Indexes: _____ (current count)
- restaurants: _____ rows
- dishes: _____ rows
- combo_groups: _____ rows
- combo_items: _____ rows (should be ~63)

READY FOR NEXT STEP:
✓ Backup completed and verified
✓ Rollback point established
✓ Proceed to 02_STAGING_INDEXES.md
```

**Next Ticket:** `02_STAGING_INDEXES.md`

---

## NOTES FOR AGENT

### Why Backup First?

**Risk Management:**
- Indexes are added with CONCURRENTLY (safe)
- RLS policies can be disabled if issues arise
- Combo fix modifies data (riskier)
- **Backup enables 15-minute full restore if anything catastrophic happens**

### Backup Best Practices

1. **Always label clearly** - Future you will thank you
2. **Verify before proceeding** - Corrupt backups are useless
3. **Document the backup ID** - You'll need it for rollback
4. **Check size matches** - Small backup = incomplete backup

### If Human Intervention Needed

**Be specific in your alert:**
- ❌ "Backup failed"
- ✓ "Staging backup failed with error: [specific error]. Backup ID [if any]. Cannot proceed to index deployment without verified backup. Need human to investigate Supabase backup service status."

### Time Expectations

- Small DB (< 1 GB): 2-5 minutes
- Medium DB (1-5 GB): 5-10 minutes
- Large DB (> 5 GB): 10-20 minutes

If backup exceeds these times, something may be wrong.

---

**Ticket Status:** READY  
**Dependencies:** Ticket 00 COMPLETE  
**Last Updated:** October 10, 2025  
**Validated By:** Brian Lapp

