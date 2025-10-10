# TICKET 06: Production Backup

**Phase:** Production Deployment - Step 1 of 5  
**Environment:** Production Database ⚠️  
**Estimated Duration:** 15-20 minutes  
**Prerequisites:** Ticket 05 (Staging Validation) must show GO decision

---

## CONTEXT

- **Current Step:** 6 of 11 (Production Backup)
- **Purpose:** Create verified backup of production before ANY changes
- **Risk Level:** LOW (backup is safe)
- **⚠️ PRODUCTION:** Real users, real data, real revenue

**Before You Begin:**
- **CRITICAL:** Verify Ticket 05 shows "GO/NO-GO DECISION: ✅ GO"
- **CRITICAL:** Verify Santiago sign-off in EXECUTION_LOG.md
- **CRITICAL:** Maintenance window scheduled and team notified
- Have emergency contacts ready

**This is Production:**
- Real customer data
- Live transactions
- Revenue-generating system
- Extra caution required

---

## TASK

Create a full, verified backup of the production database. This is the safety net for the entire production deployment.

**Critical Success Factors:**
- Backup must complete successfully
- Backup must be verified (not corrupted)
- Backup ID must be recorded (for rollback)
- **NO PROCEEDING without confirmed backup**

---

## COMMANDS TO RUN

### Step 1: Pre-Deployment Checklist

**Agent Action:** Verify all prerequisites

```bash
# Check Santiago sign-off in EXECUTION_LOG
grep -A 5 "SANTIAGO SIGN-OFF" /Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Agent_Tasks/EXECUTION_LOG.md

# Should show:
# - Approved: YES
# - Date filled in
# - Signature present

# If NO or not filled, STOP - do not proceed
```

**Manual Verification (Agent should log):**
- [ ] Maintenance window announced? (24h notice)
- [ ] Team present? (Brian + Santiago)
- [ ] Customer support briefed?
- [ ] War room Slack channel created?
- [ ] Rollback plan reviewed?

**If ANY item unchecked:**
- STOP
- Alert human operator
- Do NOT proceed until all items confirmed

### Step 2: Document Pre-Backup Production State

**Agent Action:** Capture production baseline

```sql
-- Production database state
SELECT 
  'PRODUCTION PRE-BACKUP' as label,
  (SELECT COUNT(*) FROM menuca_v3.restaurants) as restaurants,
  (SELECT COUNT(*) FROM menuca_v3.dishes) as dishes,
  (SELECT COUNT(*) FROM menuca_v3.combo_groups) as combo_groups,
  (SELECT COUNT(*) FROM menuca_v3.combo_items) as combo_items,
  (SELECT COUNT(*) FROM menuca_v3.users) as users,
  (SELECT COUNT(*) FROM menuca_v3.ingredients) as ingredients,
  NOW() as timestamp;
```

**Expected Output:**
- Values should match or be close to staging counts
- Record EXACT counts - will verify after backup

**⚠️ If Counts Very Different from Staging:**
- May indicate connecting to wrong database
- STOP and verify production credentials
- Confirm with human before proceeding

### Step 3: Check Production Database Size

```sql
-- Get production size (for backup time estimate)
SELECT 
  pg_size_pretty(pg_database_size(current_database())) as database_size,
  pg_size_pretty(SUM(pg_total_relation_size(schemaname||'.'||tablename))::bigint) as menuca_v3_size,
  (SELECT COUNT(*) FROM pg_indexes WHERE schemaname = 'menuca_v3') as current_indexes,
  (SELECT COUNT(*) FROM pg_policies WHERE schemaname = 'menuca_v3') as current_policies
FROM pg_tables
WHERE schemaname = 'menuca_v3';
```

**Expected Output:**
- database_size: [Note for backup verification]
- current_indexes: Pre-optimization count (will increase)
- current_policies: Should be 0 or few (will add many)

### Step 4: Check Active Connections

```sql
-- Verify low production activity (maintenance window)
SELECT 
  state,
  COUNT(*) as connection_count
FROM pg_stat_activity
WHERE datname = current_database()
GROUP BY state;
```

**Expected Output (during maintenance window):**
- active: < 10 (should be low traffic)
- idle: < 50 (normal background)

**If Very High Activity (> 50 active):**
- May not be in maintenance window
- Confirm timing with human
- May need to wait for traffic to drop

### Step 5: Create Production Backup

**⚠️ CRITICAL STEP - DO NOT SKIP**

**Agent Action:** Create labeled backup

**Backup Label:** `production-pre-optimization-$(date +%Y%m%d-%H%M%S)`

**Method:** Use Supabase dashboard or appropriate MCP tool

```
If MCP tools support backup:
- Use backup creation tool
- Label: production-pre-optimization-[timestamp]
- Wait for completion

If human action required:
- Alert: "Ready for production backup creation"
- Provide label: production-pre-optimization-[timestamp]
- Wait for human confirmation of backup ID
```

**Wait Time:**
- Small DB (< 1 GB): 5-10 minutes
- Medium DB (1-5 GB): 10-20 minutes
- Large DB (> 5 GB): 20-45 minutes

**Monitor backup status until complete.**

### Step 6: Verify Backup Completion

**Agent Action:** Confirm backup succeeded

```bash
# Via Supabase CLI (if available)
supabase db backups list --project-ref [production-project-ref]

# Look for:
# - Backup with label "production-pre-optimization-[timestamp]"
# - Status: "completed" or "available"
# - Size: Matches database size from Step 3
# - Created: Within last 30 minutes
```

**Success Indicators:**
- ✓ Backup appears in list
- ✓ Status: completed
- ✓ Size: Reasonable (matches expected)
- ✓ Timestamp: Recent

**Failure Indicators:**
- ✗ Status: failed
- ✗ Size: 0 or very small (incomplete)
- ✗ Not in list (didn't create)

### Step 7: Record Backup Details for Rollback

**Agent Action:** Document backup information

**⚠️ CRITICAL:** This backup ID is the ONLY way to rollback if disaster occurs.

```bash
cat >> /Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Agent_Tasks/EXECUTION_LOG.md <<EOF

================================================================================
TICKET 06: Production Backup
================================================================================
Date/Time: $(date +"%Y-%m-%d %H:%M:%S")
Status: IN_PROGRESS

## PRODUCTION BACKUP - CRITICAL INFORMATION

⚠️ ROLLBACK BACKUP ID: [backup-id-from-step-6]

Backup Label: production-pre-optimization-[timestamp]
Backup Size: [size from step 6]
Database Size at Backup: [size from step 3]
Created: [timestamp]
Status: completed

## Production State (Pre-Optimization)
- Restaurants: [from step 2]
- Dishes: [from step 2]
- Combo Groups: [from step 2]
- Combo Items: [from step 2] (pre-fix count)
- Users: [from step 2]
- Ingredients: [from step 2]
- Current Indexes: [from step 3]
- Current RLS Policies: [from step 3]

## Maintenance Window Info
- Start Time: [timestamp]
- Team Present: Brian Lapp, Santiago
- War Room: #prod-deployment-[date]
- Emergency Contact: [phone numbers]

## Validation (see below)

EOF
```

### Step 8: Test Backup Integrity (If Tools Available)

**Agent Action:** Verify backup is not corrupted

```bash
# If Supabase provides backup validation
# Attempt to verify backup integrity

# May require:
# - Downloading backup metadata
# - Checking backup hash/checksum
# - Confirming backup is downloadable
```

**If Validation Not Possible:**
- Note in log: "Backup created, integrity validation not available via tools"
- Acceptable - Supabase backups are generally reliable
- Proceed with caution

---

## VALIDATION CRITERIA

Complete this checklist:

- [ ] **Prerequisites confirmed**
  - Santiago sign-off present
  - Maintenance window active
  - Team present
  
- [ ] **Pre-backup state documented**
  - Row counts recorded
  - Database size recorded
  - Current index/policy counts noted
  
- [ ] **Backup created successfully**
  - Backup appears in list
  - Status: completed
  - Label correct
  
- [ ] **Backup size reasonable**
  - Size matches database size (±20%)
  - Not zero or suspiciously small
  
- [ ] **Backup ID recorded**
  - **CRITICAL:** Backup ID documented in EXECUTION_LOG.md
  - ID is accessible for rollback
  
- [ ] **Backup recent**
  - Timestamp within last 30 minutes
  
- [ ] **Production not disrupted**
  - No errors during backup
  - Connections stable

---

## SUCCESS CONDITIONS

**All validation criteria must PASS.**

If all checks pass:
1. **Log to EXECUTION_LOG.md:**
   ```
   ## Validation Results
   - ✓ Backup ID: [id] ← CRITICAL FOR ROLLBACK
   - ✓ Backup Status: completed
   - ✓ Backup Size: [size]
   - ✓ Production State: Documented
   - ✓ Ready for deployment
   
   STATUS: COMPLETE
   ```

2. **Communicate to team:**
   - Post in war room: "Production backup complete. Backup ID: [id]. Proceeding to index deployment."

3. **Proceed to next ticket:**
   - Next: `07_PRODUCTION_INDEXES.md`
   - Safety net established

---

## FAILURE CONDITIONS

**If ANY validation fails:**

### Scenario 1: Backup Creation Failed

**Actions:**
1. **STOP** - Do NOT proceed
2. Check Supabase dashboard for error details
3. Verify database is accessible
4. Retry backup creation (once)
5. If retry fails, **ABORT DEPLOYMENT**
6. Alert human operator
7. Reschedule maintenance window

**Do NOT proceed without backup!**

### Scenario 2: Backup Size Incorrect

**Symptoms:**
- Backup size << database size (e.g., 1 MB vs 1 GB expected)

**Actions:**
1. **STOP**
2. Backup likely incomplete or corrupted
3. Delete incomplete backup
4. Retry backup creation
5. If issue persists, **ABORT DEPLOYMENT**

### Scenario 3: Cannot Verify Backup

**Actions:**
1. Ask human to verify via dashboard
2. If human confirms backup looks good, proceed
3. If backup cannot be verified by human, **ABORT**

---

## ROLLBACK

**Not Applicable** - This ticket creates the backup, doesn't modify data.

**However:** If backup cannot be created:
- **ABORT production deployment**
- Reschedule for another time
- Investigate backup system issues

---

## CONTEXT FOR NEXT STEP

```
PRODUCTION BACKUP COMPLETE
================================================================================

⚠️ CRITICAL ROLLBACK INFORMATION ⚠️
Backup ID: _____________ ← SAVE THIS!
Backup Label: production-pre-optimization-[timestamp]
Created: [timestamp]
Size: [size]

PRODUCTION BASELINE:
- Restaurants: _____
- Dishes: _____
- Combo Groups: _____
- Combo Items: _____ (pre-fix, should be low)
- Current Indexes: _____
- Current Policies: _____

DEPLOYMENT STATUS:
✓ Production backup verified
✓ Rollback point established  
✓ Team standing by
✓ Ready to deploy indexes

NEXT STEP:
→ Proceed to 07_PRODUCTION_INDEXES.md

TIMING:
- Backup completed: [time]
- Estimated deployment: 2-3 hours
- Projected completion: [time]
```

**Next Ticket:** `07_PRODUCTION_INDEXES.md`

---

## NOTES FOR AGENT

### This is Production

**Extra Caution Required:**
- Double-check everything
- Verify before proceeding
- When in doubt, ASK human
- Better slow than wrong

### Why Backup is Critical

**Disaster Scenarios:**
- Index creation goes wrong → Rollback to backup
- RLS blocks all access → Rollback to backup
- Combo fix corrupts data → Rollback to backup
- **Unknown unknowns** → Rollback to backup

**Without backup:**
- No safety net
- Can't undo mistakes
- Potential data loss
- Business impact

**15 minutes for backup = hours of peace of mind**

### Communication is Key

**Keep team informed:**
- When backup starts
- When backup completes
- Backup ID (critical!)
- Any issues or delays

**War room should know:**
- Current status always
- Any blockers immediately
- ETA for next steps

---

**Ticket Status:** READY  
**Dependencies:** Ticket 05 COMPLETE + GO decision  
**Last Updated:** October 10, 2025  
**Validated By:** Brian Lapp

**⚠️ PRODUCTION - EXTRA CAUTION REQUIRED ⚠️**

