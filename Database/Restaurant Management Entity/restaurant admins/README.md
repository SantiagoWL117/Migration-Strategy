# Restaurant Admin Users Migration

## 📁 Directory Contents

This directory contains all scripts and documentation needed to migrate V1 `restaurant_admins` to `menuca_v3.restaurant_admin_users`.

### 🎯 Start Here

1. **[EXECUTION_GUIDE.md](./EXECUTION_GUIDE.md)** - Complete step-by-step migration instructions
2. **[MIGRATION_SUMMARY.md](./MIGRATION_SUMMARY.md)** - Quick reference and overview

### 📊 Migration SQL Scripts (Run in Order)

| Step | Script | Purpose | Required |
|------|--------|---------|----------|
| 0 | `step0_preconditions_check.sql` | Verify prerequisites | ✅ Yes |
| 1a | `step1_create_staging_table.sql` | Create staging table | ✅ Yes |
| 1b | `export_v1_to_csv.ps1` | Export V1 data to CSV | ✅ Yes |
| 1c | `step1b_cleanup_staging.sql` | Clean and validate staging | ⚠️ Recommended |
| 2 | `step2_transform_and_upsert.sql` | **MAIN MIGRATION** (idempotent) | ✅ Yes |
| 3 | `step3_normalization_checks.sql` | Data quality checks | ⚠️ Recommended |
| 4 | `step4_verification.sql` | Comprehensive validation | ✅ Yes |
| 5 | `step5_multi_restaurant_access_ddl.sql` | Multi-restaurant access | ⚡ Optional |

### 🗂️ Source Data Files

- `dumps/menuca_v1_restaurant_admins.sql` - V1 MySQL dump (~1,075 records)
- `dumps/menuca_v2_admin_users.sql` - V2 platform admins (OUT OF SCOPE - do not migrate)
- `dumps/menuca_v2_admin_users_restaurants.sql` - V2 junction table (OUT OF SCOPE)

### 📚 Documentation

- `../../documentation/Restaurants/restaurant_admin_users migration plan.md` - Detailed migration plan
- `EXECUTION_GUIDE.md` - Step-by-step instructions
- `MIGRATION_SUMMARY.md` - Quick reference
- `README.md` - This file

---

## 🚀 Quick Start

```powershell
# 1. Navigate to project root
cd "C:\Users\santi\Menu.ca\Legacy Database\Migration Strategy"

# 2. Check prerequisites
psql -U postgres -d your_database -f "Database/Restaurant Management Entity/restaurant admins/step0_preconditions_check.sql"

# 3. Create staging table
psql -U postgres -d your_database -f "Database/Restaurant Management Entity/restaurant admins/step1_create_staging_table.sql"

# 4. Export V1 data to CSV (requires MySQL client)
cd "Database/Restaurant Management Entity/restaurant admins"
.\export_v1_to_csv.ps1 -MySQLUser "root" -MySQLPassword "yourpass" -MySQLDatabase "menuca_v1"

# 5. Load CSV into PostgreSQL (update path to CSV file)
psql -U postgres -d your_database

# Then in psql:
\COPY staging.v1_restaurant_admin_users (legacy_admin_id, legacy_v1_restaurant_id, user_type, fname, lname, email, password_hash, lastlogin, login_count, active_user, send_statement, allowed_restaurants, created_at, updated_at) FROM 'C:/path/to/v1_restaurant_admins_export.csv' WITH (FORMAT csv, HEADER true);

# 6. Clean staging data
psql -U postgres -d your_database -f step1b_cleanup_staging.sql

# 7. Run main migration (IDEMPOTENT)
psql -U postgres -d your_database -f step2_transform_and_upsert.sql

# 8. Data quality checks
psql -U postgres -d your_database -f step3_normalization_checks.sql

# 9. Comprehensive verification
psql -U postgres -d your_database -f step4_verification.sql

# 10. [OPTIONAL] Multi-restaurant access
psql -U postgres -d your_database -f step5_multi_restaurant_access_ddl.sql
```

---

## 🎯 Migration Rules

### ✅ What Gets Migrated

- V1 `restaurant_admins` with `user_type='r'` AND `restaurant > 0`
- ~1,040 records (after filtering and deduplication)
- All core fields: name, email, password, login tracking, status, preferences

### ❌ What Doesn't Get Migrated

- **V2 `admin_users`** - Platform-level administrators (different entity class)
- **V1 global admins** - `user_type='g'` OR `restaurant=0` (handle via junction table in Step 5)
- **V1 feature flags** - UI-specific fields not applicable to v3
- **`allowed_restaurants` BLOB** - Migrated separately in Step 5 (optional)

### 🔄 Transformations Applied

| Source | Target | Transform |
|--------|--------|-----------|
| `fname` | `first_name` | Direct copy |
| `lname` | `last_name` | Direct copy |
| `email` | `email` | Lowercase + trim |
| `password` | `password_hash` | Direct copy (legacy bcrypt) |
| `lastlogin` | `last_login` | TIMESTAMP → TIMESTAMPTZ |
| `loginCount` | `login_count` | Direct copy |
| `activeUser` ('1'/'0') | `is_active` | → boolean (true/false) |
| `sendStatement` ('y'/'n') | `send_statement` | → boolean (true/false) |
| `restaurant` | `restaurant_id` | FK join via `legacy_v1_id` |

---

## 📊 Expected Results

After successful migration:

- **~1,040 records** in `menuca_v3.restaurant_admin_users`
- **0 broken FKs** (all restaurant references resolve)
- **0 duplicates** (unique constraint on `restaurant_id, email`)
- **All emails** normalized (lowercase, trimmed)
- **Password hashes** preserved (legacy bcrypt format `$2y$10$`)

---

## ⚠️ Critical Dependencies

**Must be completed FIRST:**
1. ✅ `menuca_v3.restaurants` table loaded with `legacy_v1_id` populated
2. ✅ `extensions.uuid_generate_v4()` function exists
3. ✅ `menuca_v3.set_updated_at()` trigger function exists

**Verify with:**
```bash
psql -U postgres -d your_database -f step0_preconditions_check.sql
```

---

## 🔍 Verification Checklist

After running Step 4, verify:

- [ ] Source count ≈ target count (accounting for exclusions)
- [ ] Zero broken foreign keys
- [ ] Zero duplicate (restaurant, email) pairs
- [ ] All emails normalized
- [ ] No orphaned admin users
- [ ] Password hashes in correct format
- [ ] Active/inactive distribution looks correct
- [ ] Sample data review passes

---

## 🐛 Troubleshooting

### Issue: Prerequisites check fails

**Solution:** See `step0_preconditions_check.sql` output for specific missing components

### Issue: MySQL client not found

**Solution:** 
- Install MySQL: https://dev.mysql.com/downloads/mysql/
- Or use alternative: Export manually from MySQL Workbench
- Or use `step1c_load_from_v1_dump.sql` for alternative loading methods

### Issue: Broken FKs during migration

**Solution:**
- Identify missing restaurants (Step 4 will show them)
- Migrate missing restaurants first
- Or exclude admin users for non-existent restaurants

### Issue: Record count mismatch

**Solution:** Review Step 4 output to understand:
- How many were excluded (global admins)
- How many were deduplicated
- How many had broken FKs

---

## 📝 Post-Migration Tasks

1. **Password Security**
   - Plan password reset flow for users
   - Consider rehashing with modern algorithms

2. **User Communication**
   - Notify restaurant admins about migration
   - Provide login instructions

3. **Access Control**
   - If multi-restaurant access needed, complete Step 5
   - Implement role-based permissions if required

4. **Monitoring**
   - Track login success/failure rates
   - Monitor for authentication issues

---

## 📞 Support

If issues arise:
1. Review [EXECUTION_GUIDE.md](./EXECUTION_GUIDE.md) for detailed instructions
2. Check [MIGRATION_SUMMARY.md](./MIGRATION_SUMMARY.md) for quick reference
3. Examine `step4_verification.sql` output for specific problems
4. Consult `../../documentation/Restaurants/restaurant_admin_users migration plan.md` for field mappings

---

## 📈 Progress Tracking

Current status can be tracked in the main todo list:

- [x] Step 0: Preconditions check
- [ ] Step 1: Staging table and data loading
- [ ] Step 2: Transform and upsert
- [ ] Step 3: Normalization checks
- [ ] Step 4: Verification
- [ ] Step 5: Multi-restaurant access (optional)

---

**Last Updated:** 2025-10-02  
**Migration Plan Version:** 1.0




