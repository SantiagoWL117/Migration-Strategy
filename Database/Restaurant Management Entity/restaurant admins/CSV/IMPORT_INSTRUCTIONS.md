# CSV Import Instructions for Supabase

## ✅ File Ready for Import

**File Location:** `Database/Restaurant Management Entity/restaurant admins/CSV/v1_restaurant_admins_for_import.csv`

**Records:** 493 restaurant admin users  
**Columns:** 12  
**BLOB Data:** ❌ Excluded (will be handled separately in Step 5)

---

## 📋 Step-by-Step Import Guide

### Step 1: Access Supabase Dashboard

1. Go to: **https://supabase.com/dashboard**
2. Select your project: **nthpbtdjhhnwfxqsxbvy**
3. Navigate to: **Table Editor** (left sidebar)

### Step 2: Select Target Table

1. In the schema dropdown, select: **staging**
2. Find and click on table: **v1_restaurant_admin_users**
3. Verify the table is empty (should show 0 or 10 rows if you ran Batch 1)

### Step 3: Import CSV

1. Click the **"Insert"** button (top right)
2. From the dropdown, select: **"Import data from CSV"**
3. Click **"Choose File"** or drag and drop
4. Select: `v1_restaurant_admins_for_import.csv`

### Step 4: Verify Column Mapping

The CSV columns should automatically map to the table columns:

| CSV Column | → | Table Column |
|------------|---|--------------|
| legacy_admin_id | → | legacy_admin_id |
| legacy_v1_restaurant_id | → | legacy_v1_restaurant_id |
| fname | → | fname |
| lname | → | lname |
| email | → | email |
| password_hash | → | password_hash |
| lastlogin | → | lastlogin |
| login_count | → | login_count |
| active_user | → | active_user |
| send_statement | → | send_statement |
| created_at | → | created_at |
| updated_at | → | updated_at |

**⚠️ Important:**
- Ensure **"First row is header"** is checked
- Verify all 12 columns are correctly mapped
- Check that data types match (text, integer, timestamptz, etc.)

### Step 5: Execute Import

1. Review the mapping one more time
2. Click **"Import"** button
3. Wait for the import to complete (should take 10-30 seconds)

### Step 6: Verify Import

After import completes, run these verification queries:

```sql
-- Total records loaded
SELECT COUNT(*) AS total FROM staging.v1_restaurant_admin_users;
-- Expected: 493

-- Restaurant admins (restaurant_id > 0)
SELECT COUNT(*) AS restaurant_admins 
FROM staging.v1_restaurant_admin_users 
WHERE legacy_v1_restaurant_id > 0;
-- Expected: 471

-- Global admins (restaurant_id = 0)
SELECT COUNT(*) AS global_admins 
FROM staging.v1_restaurant_admin_users 
WHERE legacy_v1_restaurant_id = 0;
-- Expected: 22

-- Check for nulls
SELECT 
  COUNT(*) - COUNT(legacy_admin_id) AS missing_ids,
  COUNT(*) - COUNT(password_hash) AS missing_passwords,
  COUNT(*) - COUNT(NULLIF(email, '')) AS missing_emails
FROM staging.v1_restaurant_admin_users;
-- Expected: missing_ids=0, missing_passwords=0, missing_emails=1 (one record has empty email)
```

---

## ✅ Success Criteria

After successful import, you should see:
- ✅ 493 total records in the staging table
- ✅ 471 restaurant-specific admins
- ✅ 22 global/platform admins  
- ✅ All password hashes present
- ✅ Only 1 record with missing email (legacy_admin_id=58)

---

## 🔧 Troubleshooting

### Issue: "Duplicate key value violates unique constraint"
**Solution:** Clear the staging table first:
```sql
TRUNCATE TABLE staging.v1_restaurant_admin_users;
```
Then retry the import.

### Issue: "Column mapping mismatch"
**Solution:** 
1. Cancel the import
2. Download the CSV and open in Excel/LibreOffice
3. Verify the header row matches exactly
4. Re-upload

### Issue: "Import failed"
**Solution:**
1. Check Supabase logs for specific error
2. Verify you have write permissions on the `staging` schema
3. Ensure the table exists and has the correct structure

---

## 📝 Next Steps After Import

Once the CSV import is successful:

1. ✅ **Mark Step 1b as COMPLETE**
2. 📋 **Proceed to Step 2:** Transform and upsert into `menuca_v3.restaurant_admin_users`
3. 📋 **Step 3:** Post-load normalization
4. 📋 **Step 4:** Verification queries
5. 📋 **Step 5 (Optional):** Migrate multi-restaurant access from BLOB data

---

**File Created:** 2025-10-02  
**Total Records:** 493  
**Status:** ✅ Ready for Import

