# Restaurant Admin Users Migration - Execution Guide

## Overview

This guide provides step-by-step instructions for migrating restaurant administrator/owner login accounts from V1 `restaurant_admins` to `menuca_v3.restaurant_admin_users`.

**Key Facts:**
- **Source**: V1 `restaurant_admins` table ONLY (~1,075 records)
- **Excluded**: V2 `admin_users` (platform-level administrators, NOT restaurant owners)
- **Filter**: Only migrate `user_type='r'` AND `restaurant > 0`
- **Deduplication**: Automatic by `(restaurant_id, email)` keeping most recent `last_login`

---

## Prerequisites ✅

Before starting, ensure:
1. PostgreSQL database with `menuca_v3` schema exists
2. `menuca_v3.restaurants` table is loaded with `legacy_v1_id` populated
3. Access to V1 MySQL database or SQL dumps
4. `uuid-ossp` extension installed

---

## Migration Steps

### **Step 0: Verify Preconditions**

Run the preconditions check script:

```bash
psql -U postgres -d your_database -f step0_preconditions_check.sql
```

**Expected Output:**
- ✅ uuid_generate_v4() function EXISTS
- ✅ set_updated_at() trigger function EXISTS
- ✅ restaurants table EXISTS with N records
- ✅ N restaurants have legacy_v1_id
- ✅ restaurant_admin_users table EXISTS
- ✅ Unique index u_admin_email_per_restaurant EXISTS

**If any checks fail (❌):**
- Missing uuid function: `CREATE EXTENSION IF NOT EXISTS "uuid-ossp" SCHEMA extensions;`
- Missing tables: Run `Database/Legacy schemas/Menuca v3 schema/menuca_v3.sql`
- Missing restaurants: Complete restaurants migration first

---

### **Step 1: Create Staging Table and Load Data**

#### 1a. Create Staging Table

```bash
psql -U postgres -d your_database -f step1_create_staging_table.sql
```

This creates `staging.v1_restaurant_admin_users` table.

#### 1b. Extract V1 Data

**Option A: Direct from V1 MySQL Database**

```bash
# Export from MySQL to CSV
mysql -u root -p menuca_v1 -e "
SELECT 
  id, 
  restaurant, 
  user_type, 
  fname, 
  lname, 
  email, 
  password, 
  lastlogin, 
  loginCount, 
  activeUser, 
  sendStatement,
  allowed_restaurants,
  created_at, 
  updated_at 
FROM restaurant_admins
" --quick --skip-column-names > v1_restaurant_admins.csv
```

**Option B: Use Existing SQL Dump**

If you have the dump file, you can load it directly into a temporary MySQL database and export.

#### 1c. Load into PostgreSQL Staging

```bash
# Load CSV into staging table
psql -U postgres -d your_database -c "
COPY staging.v1_restaurant_admin_users (
  legacy_admin_id, 
  legacy_v1_restaurant_id, 
  user_type, 
  fname, 
  lname, 
  email, 
  password_hash, 
  lastlogin, 
  login_count, 
  active_user, 
  send_statement,
  allowed_restaurants,
  created_at, 
  updated_at
) 
FROM '/path/to/v1_restaurant_admins.csv' 
WITH (FORMAT csv, HEADER true, NULL 'NULL');
"
```

#### 1d. Clean Staging Data (Optional but Recommended)

```bash
psql -U postgres -d your_database -f step1b_cleanup_staging.sql
```

**Review the output:**
- Total records loaded
- Records eligible for migration (user_type='r', restaurant>0)
- Records excluded (global admins)
- Any duplicate (restaurant, email) pairs

---

### **Step 2: Transform and Upsert** 🚀

This is the main migration step. It's **idempotent** - safe to run multiple times.

```bash
psql -U postgres -d your_database -f step2_transform_and_upsert.sql
```

**What it does:**
1. Joins staging data with `menuca_v3.restaurants` to resolve FKs
2. Filters to only `user_type='r'` and `restaurant > 0`
3. Deduplicates by `(restaurant_id, email)` keeping most recent `last_login`
4. Upserts into `menuca_v3.restaurant_admin_users`
5. Reports records inserted/updated

**Expected Output:**
```
records_inserted | records_updated
-----------------+----------------
           1042  |              0
```

---

### **Step 3: Post-Load Normalization Checks**

Run data quality checks:

```bash
psql -U postgres -d your_database -f step3_normalization_checks.sql
```

**Reviews:**
- Email normalization (all lowercase/trimmed)
- Orphaned admin users (broken restaurant FKs)
- Missing emails
- Duplicate pairs (should be 0)
- Password hash format
- Active/inactive distribution
- Login activity patterns

**Action Items:**
- ✅ All green: Proceed to Step 4
- ⚠️ Warnings: Review and decide if fixes needed
- ❌ Errors: Fix issues and re-run Step 2

---

### **Step 4: Comprehensive Verification** 🔍

Run full verification suite:

```bash
psql -U postgres -d your_database -f step4_verification.sql
```

**Validates:**
- Source vs target record counts match
- No broken foreign keys
- Duplicates were handled correctly
- Unique constraint is enforced
- Distribution analysis
- Sample data review
- Login activity summary
- Restaurants without admin users

**Success Criteria:**
- ✅ Eligible source count ≈ target count (accounting for deduplication)
- ✅ Zero broken FKs
- ✅ Zero duplicates in target
- ✅ All admin users have valid restaurant links

---

### **Step 5: Multi-Restaurant Access (OPTIONAL)** 🔧

**Only needed if multi-restaurant access functionality is required.**

This step migrates the `allowed_restaurants` BLOB field (PHP serialized arrays) into a junction table.

#### 5a. Create Junction Table

```bash
psql -U postgres -d your_database -f step5_multi_restaurant_access_ddl.sql
```

Creates `menuca_v3.restaurant_admin_access` table.

#### 5b. Parse and Load PHP Serialized Data

**This requires external processing** because PostgreSQL cannot natively parse PHP serialized arrays.

**Option A: Python Script** (Recommended)

You'll need a Python script to:
1. Read `allowed_restaurants` BLOB from staging
2. Parse PHP serialized arrays using `phpserialize` library
3. Insert into `restaurant_admin_access` junction table

**Option B: PHP Script**

Create a PHP script to:
1. Connect to both databases
2. Read and unserialize `allowed_restaurants`
3. Insert into junction table

**Note:** This step is complex and may require custom scripting based on your environment.

---

## Verification Queries

After migration, run these quick checks:

```sql
-- Total migrated admin users
SELECT COUNT(*) FROM menuca_v3.restaurant_admin_users;

-- Active vs inactive
SELECT 
    COUNT(CASE WHEN is_active THEN 1 END) AS active,
    COUNT(CASE WHEN NOT is_active THEN 1 END) AS inactive
FROM menuca_v3.restaurant_admin_users;

-- Sample with restaurant names
SELECT 
    au.email,
    r.name AS restaurant_name,
    au.login_count,
    au.last_login
FROM menuca_v3.restaurant_admin_users au
JOIN menuca_v3.restaurants r ON r.id = au.restaurant_id
ORDER BY au.login_count DESC
LIMIT 10;
```

---

## Troubleshooting

### Issue: Broken FK (restaurants not found)

**Symptom:** Step 4 shows broken foreign keys

**Solution:**
1. Identify missing restaurants:
   ```sql
   SELECT DISTINCT s.legacy_v1_restaurant_id
   FROM staging.v1_restaurant_admin_users s
   LEFT JOIN menuca_v3.restaurants r ON r.legacy_v1_id = s.legacy_v1_restaurant_id
   WHERE r.id IS NULL AND s.legacy_v1_restaurant_id > 0;
   ```
2. Either:
   - Migrate missing restaurants first
   - Exclude admin users for non-existent restaurants

### Issue: Duplicates in Source

**Symptom:** Step 1b shows duplicate (restaurant, email) pairs

**Solution:**
- The migration script automatically deduplicates by keeping the most recent `last_login`
- Review the duplicates report to understand which records will be kept
- If needed, manually adjust before running Step 2

### Issue: Migration Count Mismatch

**Symptom:** Step 4 shows source count > target count

**Possible Causes:**
1. **Broken FKs** - Admin users for restaurants that don't exist in V3
2. **Excluded globals** - `user_type='g'` or `restaurant=0` records (expected)
3. **Deduplication** - Multiple records per (restaurant, email) collapsed to one (expected)
4. **Missing emails** - Records without email addresses (violates NOT NULL)

**Verify:**
```sql
-- Count eligible source records
SELECT COUNT(*) FROM staging.v1_restaurant_admin_users
WHERE legacy_v1_restaurant_id > 0 AND user_type = 'r' AND email IS NOT NULL;

-- Count target records
SELECT COUNT(*) FROM menuca_v3.restaurant_admin_users;
```

---

## Rollback

If you need to rollback the migration:

```sql
-- Option 1: Truncate (if this is the only migration)
TRUNCATE TABLE menuca_v3.restaurant_admin_users CASCADE;

-- Option 2: Delete specific migration batch (if mixed with other data)
-- Add a batch_id column to track migrations if needed
```

**WARNING:** Truncate will remove ALL data. Only use if this is a fresh migration.

---

## Post-Migration Tasks

After successful migration:

1. **Password Security Review**
   - Migrated passwords use legacy bcrypt (`$2y$10$`)
   - Consider implementing password reset flow
   - Plan upgrade to modern hashing algorithms

2. **User Notification**
   - Notify restaurant admins about the migration
   - Provide login instructions for new system
   - Set up password reset mechanism if needed

3. **Access Control**
   - If Step 5 was skipped, document multi-restaurant access requirements
   - Plan implementation of role-based permissions if needed

4. **Monitoring**
   - Track login success/failure rates
   - Monitor for authentication issues
   - Set up alerts for suspicious activity

---

## Files Reference

- `step0_preconditions_check.sql` - Verify prerequisites
- `step1_create_staging_table.sql` - Create staging table
- `step1b_cleanup_staging.sql` - Clean and validate staging data
- `step2_transform_and_upsert.sql` - **MAIN MIGRATION** (idempotent)
- `step3_normalization_checks.sql` - Post-migration data quality
- `step4_verification.sql` - Comprehensive validation
- `step5_multi_restaurant_access_ddl.sql` - Optional junction table (Step 5)

---

## Success Checklist ✅

- [ ] All preconditions pass (Step 0)
- [ ] Staging table loaded with V1 data (Step 1)
- [ ] Migration completes without errors (Step 2)
- [ ] No data quality issues (Step 3)
- [ ] All verification checks pass (Step 4)
- [ ] Source count matches target (accounting for exclusions/deduplication)
- [ ] Sample data review looks correct
- [ ] Documentation updated with migration results
- [ ] Optional: Multi-restaurant access migrated (Step 5)

---

## Support

If you encounter issues:
1. Review the verification output from Step 4
2. Check the troubleshooting section above
3. Examine the migration plan document for detailed field mappings
4. Verify restaurants migration completed successfully

---

**Last Updated:** 2025-10-02




