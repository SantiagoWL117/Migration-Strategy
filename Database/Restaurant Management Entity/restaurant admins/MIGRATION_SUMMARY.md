# Restaurant Admin Users Migration - Quick Summary

## 📋 What We're Migrating

**Source:** V1 `restaurant_admins` (~1,075 records)  
**Target:** `menuca_v3.restaurant_admin_users`  
**Exclusions:** V2 `admin_users` (platform admins - different entity class)

---

## 🎯 Key Migration Rules

1. **Only** migrate `user_type='r'` AND `restaurant > 0` (restaurant-level admins)
2. **Exclude** `user_type='g'` OR `restaurant=0` (global admins - handle separately)
3. **Deduplicate** by `(restaurant_id, email)` keeping most recent `last_login`
4. **Transform** enum fields to boolean: `'1'/'0'` → `true/false`, `'y'/'n'` → `true/false`
5. **Normalize** emails to lowercase and trimmed

---

## 🚀 Quick Start (5 Steps)

```bash
# Step 0: Check prerequisites
psql -U postgres -d your_database -f step0_preconditions_check.sql

# Step 1: Create staging & load data
psql -U postgres -d your_database -f step1_create_staging_table.sql
# ... load V1 data into staging (see EXECUTION_GUIDE.md) ...
psql -U postgres -d your_database -f step1b_cleanup_staging.sql

# Step 2: Main migration (IDEMPOTENT - safe to re-run)
psql -U postgres -d your_database -f step2_transform_and_upsert.sql

# Step 3: Data quality checks
psql -U postgres -d your_database -f step3_normalization_checks.sql

# Step 4: Comprehensive verification
psql -U postgres -d your_database -f step4_verification.sql

# Step 5: (OPTIONAL) Multi-restaurant access
psql -U postgres -d your_database -f step5_multi_restaurant_access_ddl.sql
```

---

## 📊 Expected Results

- **~1,040 records** migrated (after excluding globals and deduplication)
- **0 broken FKs** (all restaurant references resolve)
- **0 duplicates** in target (unique constraint enforced)
- **All emails** lowercase and trimmed
- **Password hashes** preserved as-is (legacy bcrypt format)

---

## 🔍 Critical Dependencies

✅ **Must be completed FIRST:**
1. `menuca_v3.restaurants` table loaded with `legacy_v1_id` populated
2. `extensions.uuid_generate_v4()` function exists
3. `menuca_v3.set_updated_at()` trigger function exists

❌ **Must NOT migrate:**
- V2 `admin_users` (platform staff, not restaurant owners)
- V1 global admins with `restaurant=0` (handle via junction table in Step 5)

---

## 📁 Files Created

**Core Migration:**
- `step0_preconditions_check.sql` - Prerequisites verification
- `step1_create_staging_table.sql` - Staging table DDL
- `step1b_cleanup_staging.sql` - Data cleaning and quality reports
- `step2_transform_and_upsert.sql` - **MAIN MIGRATION** (idempotent)
- `step3_normalization_checks.sql` - Post-migration data quality
- `step4_verification.sql` - Comprehensive validation

**Optional:**
- `step5_multi_restaurant_access_ddl.sql` - Junction table for multi-restaurant access

**Documentation:**
- `EXECUTION_GUIDE.md` - Detailed step-by-step instructions (START HERE)
- `MIGRATION_SUMMARY.md` - This quick reference

---

## ⚠️ Important Notes

1. **Idempotent:** Step 2 is safe to re-run. It uses `ON CONFLICT DO UPDATE`.
2. **Passwords:** Legacy bcrypt hashes (`$2y$10$`) are migrated as-is. Plan post-migration password reset.
3. **Deduplication:** Automatic - keeps most recent `last_login` per (restaurant, email).
4. **Multi-Access:** V1 `allowed_restaurants` BLOB requires separate handling (Step 5 - optional).

---

## 🎯 Success Criteria

✅ All 6 preconditions pass  
✅ Source count ≈ target count (after accounting for exclusions)  
✅ Zero broken foreign keys  
✅ Zero duplicate (restaurant, email) pairs  
✅ All verification checks pass  
✅ Sample data review looks correct  

---

## 📞 Next Steps After Migration

1. ✅ Mark Step 0 as complete in todo list
2. 🔄 Start with Step 1 (staging table and data loading)
3. 📖 Follow EXECUTION_GUIDE.md for detailed instructions
4. 🧪 Review verification output at each step
5. ✅ Update documentation with final migration counts

---

**Ready to begin?** Start with `EXECUTION_GUIDE.md` for detailed instructions!




