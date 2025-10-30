# tenant_id Removal - Execution Plan

**Database:** Menu.ca Production (nthpbtdjhhnwfxqsxbvy.supabase.co)
**Schema:** menuca_v3
**Estimated Duration:** 15 minutes
**Risk Level:** Medium (irreversible after Step 5)

---

## Quick Reference

### Connection String
```bash
export PGHOST="db.nthpbtdjhhnwfxqsxbvy.supabase.co"
export PGPORT="5432"
export PGDATABASE="postgres"
export PGUSER="postgres"
export PGPASSWORD="Gz35CPTom1RnsmGM"
export CONNECTION_STRING="postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres"
```

### Windows (PowerShell)
```powershell
$env:CONNECTION_STRING = "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres"
```

---

## Pre-Flight Checklist

### 1. Backup Database (CRITICAL)
```bash
# Create full backup
pg_dump "$CONNECTION_STRING" > menuca_v3_backup_before_tenant_removal_$(date +%Y%m%d_%H%M%S).sql

# Or schema-only backup
pg_dump --schema-only "$CONNECTION_STRING" > menuca_v3_schema_backup_$(date +%Y%m%d_%H%M%S).sql
```

### 2. Verify Current State
```bash
psql "$CONNECTION_STRING" -c "SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = 'menuca_v3' AND column_name = 'tenant_id';"
```
Expected: 31 (22 base tables + 9 views)

### 3. Check Active Connections
```bash
psql "$CONNECTION_STRING" -c "SELECT count(*) FROM pg_stat_activity WHERE datname = 'postgres';"
```
Minimize connections before proceeding.

---

## Execution Steps

### Step 1: Validation (2 minutes)
**Script:** `01_BACKUP_AND_VALIDATION.sql`
**Reversible:** Yes
**Risk:** None

```bash
# Windows
"C:\Program Files\PostgreSQL\17\bin\psql.exe" "$env:CONNECTION_STRING" -f "01_BACKUP_AND_VALIDATION.sql" > step1_output.txt

# Mac/Linux
psql "$CONNECTION_STRING" -f 01_BACKUP_AND_VALIDATION.sql > step1_output.txt
```

**Success Criteria:**
- Script completes without errors
- Output shows 31 tables, 21 indexes, 13 functions, 2 RLS policies
- Data quality percentages displayed

**If Fails:** Review error message and resolve before proceeding

---

### Step 2: Update Functions (1 minute)
**Script:** `02_UPDATE_FUNCTIONS.sql`
**Reversible:** Yes (restore old definitions)
**Risk:** Low

```bash
# Windows
"C:\Program Files\PostgreSQL\17\bin\psql.exe" "$env:CONNECTION_STRING" -f "02_UPDATE_FUNCTIONS.sql" > step2_output.txt

# Mac/Linux
psql "$CONNECTION_STRING" -f 02_UPDATE_FUNCTIONS.sql > step2_output.txt
```

**Success Criteria:**
- All 5 functions recreated successfully
- Validation query shows 0 functions with tenant_id

**If Fails:**
- Review error message
- Restore original function definitions from backup
- Investigate and retry

---

### Step 3: Update RLS Policies (1 minute)
**Script:** `03_UPDATE_RLS_POLICIES.sql`
**Reversible:** Yes (restore old policies)
**Risk:** Low

```bash
# Windows
"C:\Program Files\PostgreSQL\17\bin\psql.exe" "$env:CONNECTION_STRING" -f "03_UPDATE_RLS_POLICIES.sql" > step3_output.txt

# Mac/Linux
psql "$CONNECTION_STRING" -f 03_UPDATE_RLS_POLICIES.sql > step3_output.txt
```

**Success Criteria:**
- 2 policies dropped successfully
- 2 new policies created successfully
- Validation query shows 0 policies with tenant_id

**If Fails:**
- Review error message
- Restore original policies from backup
- Investigate and retry

---

### Step 4: Update Views (1 minute)
**Script:** `04_UPDATE_VIEWS.sql`
**Reversible:** Yes (restore old views)
**Risk:** Low

```bash
# Windows
"C:\Program Files\PostgreSQL\17\bin\psql.exe" "$env:CONNECTION_STRING" -f "04_UPDATE_VIEWS.sql" > step4_output.txt

# Mac/Linux
psql "$CONNECTION_STRING" -f 04_UPDATE_VIEWS.sql > step4_output.txt
```

**Success Criteria:**
- All 9 views recreated successfully
- All views query successfully (counts returned)
- Validation query shows 0 views with tenant_id

**If Fails:**
- Review error message
- Restore original view definitions
- Investigate and retry

---

### ⚠️ CHECKPOINT: Point of No Return

**Before proceeding to Step 5:**
- ✅ Steps 1-4 all completed successfully
- ✅ Backups are verified and accessible
- ✅ Team is notified of maintenance
- ✅ Application is in maintenance mode (optional but recommended)

**Once Step 5 starts, you cannot rollback without restoring from backup.**

---

### Step 5: Drop Indexes and Columns (3-5 minutes)
**Script:** `05_DROP_INDEXES_AND_COLUMNS.sql`
**Reversible:** NO - requires backup restore
**Risk:** HIGH ⚠️

```bash
# Windows
"C:\Program Files\PostgreSQL\17\bin\psql.exe" "$env:CONNECTION_STRING" -f "05_DROP_INDEXES_AND_COLUMNS.sql" > step5_output.txt

# Mac/Linux
psql "$CONNECTION_STRING" -f 05_DROP_INDEXES_AND_COLUMNS.sql > step5_output.txt
```

**Success Criteria:**
- All 21 indexes dropped successfully
- All 22 columns dropped successfully
- All 5 validation queries return 0 (no remaining tenant_id references)

**If Fails:**
- DO NOT PANIC
- Review error message
- If partial failure, determine which tables succeeded
- May need to restore from backup and retry entire migration

**Expected Output:**
```
remaining_tenant_id_columns: 0
remaining_tenant_id_indexes: 0
remaining_functions_with_tenant_id: 0
remaining_policies_with_tenant_id: 0
remaining_views_with_tenant_id: 0
```

---

## Post-Migration Tasks

### Immediate (5 minutes)

1. **Vacuum and Analyze**
```sql
VACUUM ANALYZE menuca_v3.dishes;
VACUUM ANALYZE menuca_v3.courses;
VACUUM ANALYZE menuca_v3.ingredients;
VACUUM ANALYZE menuca_v3.dish_modifiers;
VACUUM ANALYZE menuca_v3.ingredient_groups;
VACUUM ANALYZE menuca_v3.combo_groups;
VACUUM ANALYZE menuca_v3.promotional_deals;
VACUUM ANALYZE menuca_v3.promotional_coupons;
```

2. **Smoke Test Queries**
```sql
-- Test 1: Query dishes by restaurant
SELECT COUNT(*) FROM menuca_v3.dishes WHERE restaurant_id = 89;

-- Test 2: Query active dishes
SELECT COUNT(*) FROM menuca_v3.active_dishes WHERE restaurant_id = 89;

-- Test 3: Test promotional deals
SELECT COUNT(*) FROM menuca_v3.promotional_deals WHERE restaurant_id = 349;

-- Test 4: Test RLS policy (as admin user)
-- (requires authenticated session)
```

3. **Verify Application Health**
- Check application logs for errors
- Test key user flows:
  - View restaurant menu
  - Create/edit dish
  - View promotional deals
  - Admin dashboard access

### Within 24 Hours

4. **Monitor Performance**
```sql
-- Check slow queries
SELECT query, calls, mean_exec_time, total_exec_time
FROM pg_stat_statements
WHERE query ILIKE '%menuca_v3%'
ORDER BY mean_exec_time DESC
LIMIT 20;
```

5. **Update Application Code** (if needed)
- Remove `tenant_id` from TypeScript interfaces
- Update API response models
- Remove JWT `tenant_id` claim generation
- Update documentation

---

## Rollback Procedure

### If Issues Detected After Step 5

**You MUST restore from backup.**

```bash
# 1. Put application in maintenance mode

# 2. Drop current database (if needed)
dropdb --if-exists -h db.nthpbtdjhhnwfxqsxbvy.supabase.co -U postgres postgres_temp

# 3. Restore from backup
pg_restore -d postgres -h db.nthpbtdjhhnwfxqsxbvy.supabase.co -U postgres menuca_v3_backup_TIMESTAMP.sql

# Or if using SQL dump:
psql "$CONNECTION_STRING" < menuca_v3_backup_TIMESTAMP.sql

# 4. Verify restoration
psql "$CONNECTION_STRING" -c "SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = 'menuca_v3' AND column_name = 'tenant_id';"
# Expected: 31

# 5. Remove maintenance mode
```

---

## Communication Template

### Before Migration
**Subject:** [SCHEDULED MAINTENANCE] Database Schema Migration - tenant_id Removal

**Body:**
```
Team,

We will be performing a database schema migration on [DATE] at [TIME].

Duration: ~15 minutes
Impact: [Application will be in read-only mode / Application will be down]

Changes:
- Removing redundant tenant_id columns from menuca_v3 schema
- Simplifying restaurant relationships
- No functional changes expected

What to expect:
- Brief service interruption during migration
- All features will work exactly as before
- Performance may improve slightly

Rollback plan:
- Database backup taken before migration
- Can restore within 10 minutes if issues occur

Please hold off on deployments during this window.

Thank you!
```

### After Migration (Success)
**Subject:** [COMPLETED] Database Migration - tenant_id Removal

**Body:**
```
Team,

✅ Database migration completed successfully!

Duration: [ACTUAL TIME]
Status: All validations passed

Changes applied:
- Removed tenant_id from 31 tables
- Updated 13 functions
- Updated 2 RLS policies
- Recreated 9 views

Post-migration validation:
✅ All queries successful
✅ RLS policies functioning
✅ Application smoke tests passed

Next steps:
- Monitor application logs for 24 hours
- Update client code to remove tenant_id references
- Update documentation

No action required from team members.
```

### After Migration (Issues)
**Subject:** [ALERT] Database Migration - Rolling Back

**Body:**
```
Team,

⚠️ Issues detected during migration. Rolling back to backup.

Issue: [DESCRIPTION]
Action: Restoring database from pre-migration backup
ETA: 15 minutes

Impact:
- Application will remain in maintenance mode
- All data will be restored to pre-migration state
- Will reschedule migration after investigation

Updates will be provided every 15 minutes.
```

---

## Success Metrics

After migration is complete and stable for 24 hours:

- ✅ Zero application errors related to tenant_id
- ✅ All menu operations functioning normally
- ✅ Admin access controls working correctly
- ✅ Query performance unchanged or improved
- ✅ No database errors in PostgreSQL logs
- ✅ User reports of normal functionality

---

## Quick Decision Tree

**During Step 1-4: Error occurs**
→ Stop, review error, fix issue, retry step

**During Step 5: Error occurs**
→ Review error carefully
→ If partial success: Document what succeeded
→ If critical failure: Restore from backup immediately

**After Step 5: Application errors**
→ Check if errors are tenant_id related
→ If yes: Rollback from backup
→ If no: May be unrelated, investigate

**After 24 hours: All stable**
→ Migration successful!
→ Update documentation
→ Remove backup after 30 days

---

## Contact Information

**Database Issues:**
- Check PostgreSQL logs
- Review step output files
- Consult database administrator

**Application Issues:**
- Check application logs
- Review API responses
- Test with different restaurants

**Emergency Rollback:**
- Use backup from Step 0
- Follow rollback procedure above
- Verify data integrity after restore

---

## Final Checklist

Before you begin:
- [ ] Read entire execution plan
- [ ] Understand each step
- [ ] Have backups ready
- [ ] Team is notified
- [ ] Rollback procedure understood
- [ ] Time allocated for full execution
- [ ] Tested on staging/dev environment first

During execution:
- [ ] Execute steps in order
- [ ] Verify success criteria after each step
- [ ] Save output files from each step
- [ ] Do not skip validation queries

After execution:
- [ ] All validation queries passed
- [ ] Application smoke tests passed
- [ ] Monitoring enabled
- [ ] Team notified of completion
- [ ] Documentation updated

---

**Ready to proceed? Start with Step 1: 01_BACKUP_AND_VALIDATION.sql**

Good luck! 🚀
