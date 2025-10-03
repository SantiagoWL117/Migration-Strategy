# Supabase CSV Import Guide

## ✅ Table Updated Successfully

The `staging.v1_restaurant_admin_users` table has been updated to accept all 16 columns from the corrected V1 CSV.

---

## 📋 Column Mapping Verification

**CSV Columns → Staging Table:**

| # | CSV Column | Table Column | Data Type | Status |
|---|------------|--------------|-----------|--------|
| 1 | legacy_admin_id | legacy_admin_id | integer | ✅ PRIMARY KEY |
| 2 | legacy_v1_restaurant_id | legacy_v1_restaurant_id | integer | ✅ |
| 3 | fname | fname | text | ✅ |
| 4 | lname | lname | text | ✅ |
| 5 | email | email | text | ✅ |
| 6 | password_hash | password_hash | text | ✅ |
| 7 | lastlogin | lastlogin | timestamptz | ✅ |
| 8 | login_count | login_count | integer | ✅ |
| 9 | active_user | active_user | text | ✅ |
| 10 | show_all_stats | show_all_stats | text | ✅ |
| 11 | fb_token | fb_token | text | ✅ |
| 12 | show_order_management | show_order_management | text | ✅ |
| 13 | send_statement | send_statement | text | ✅ Will map to V3 |
| 14 | send_statement_to | send_statement_to | text | ✅ |
| 15 | allow_ar | allow_ar | text | ✅ |
| 16 | show_clients | show_clients | text | ✅ |

**All 16 columns match perfectly!** ✓

---

## 📁 File Information

**CSV File:** `v1_restaurant_admins_for_import_CORRECTED.csv`  
**Location:** `Database/Restaurant Management Entity/restaurant admins/CSV/`  
**Records:** 493 (22 global admins + 471 restaurant admins)  
**Encoding:** UTF-8

---

## 🚀 Import Steps

### Step 1: Access Supabase Dashboard

1. Go to: **https://supabase.com/dashboard**
2. Select project: **nthpbtdjhhnwfxqsxbvy**
3. Navigate to: **Table Editor** (left sidebar)

### Step 2: Select Target Table

1. In the schema dropdown, select: **`staging`**
2. Find and click on table: **`v1_restaurant_admin_users`**
3. Verify the table is empty (should show 0 rows)

### Step 3: Import CSV

1. Click the **"Insert"** button (top right, or "+" icon)
2. From the dropdown menu, select: **"Import data from CSV"**
3. Click **"Choose File"** or drag and drop
4. Navigate to: `Database/Restaurant Management Entity/restaurant admins/CSV/`
5. Select: **`v1_restaurant_admins_for_import_CORRECTED.csv`**

### Step 4: Configure Import Settings

**Important Settings:**

- ✅ **First row is header:** Check this box
- ✅ **Delimiter:** Comma (default)
- ✅ **Encoding:** UTF-8
- ✅ **Column mapping:** Should auto-detect (verify all 16 columns map correctly)

**Verify the preview shows:**
- Header row: `legacy_admin_id,legacy_v1_restaurant_id,fname,lname,...`
- First data row: `20,0,James,Walker,james@menu.ca,...`

### Step 5: Execute Import

1. Review the column mapping one final time
2. Click **"Import"** button
3. Wait for completion (should take 15-30 seconds for 493 records)
4. Look for success message

### Step 6: Verify Import

Run these verification queries in the SQL Editor:

```sql
-- Total records imported
SELECT COUNT(*) AS total FROM staging.v1_restaurant_admin_users;
-- Expected: 493

-- Restaurant admins (will migrate to V3)
SELECT COUNT(*) AS restaurant_admins 
FROM staging.v1_restaurant_admin_users 
WHERE legacy_v1_restaurant_id > 0;
-- Expected: 471

-- Global admins (will be filtered out)
SELECT COUNT(*) AS global_admins 
FROM staging.v1_restaurant_admin_users 
WHERE legacy_v1_restaurant_id = 0;
-- Expected: 22

-- Check for any NULL emails
SELECT COUNT(*) AS missing_emails
FROM staging.v1_restaurant_admin_users 
WHERE email IS NULL OR email = '';
-- Expected: 1 (legacy_admin_id=58)

-- Check password hashes
SELECT COUNT(*) AS has_password
FROM staging.v1_restaurant_admin_users 
WHERE password_hash IS NOT NULL AND password_hash != '';
-- Expected: 493 (all records)

-- Sample data verification
SELECT 
  legacy_admin_id,
  legacy_v1_restaurant_id,
  fname,
  lname,
  email,
  active_user,
  send_statement
FROM staging.v1_restaurant_admin_users 
ORDER BY legacy_admin_id 
LIMIT 5;
```

---

## ✅ Success Criteria

After import, you should see:

- ✅ **493 total records** in staging table
- ✅ **471 restaurant admins** (restaurant_id > 0)
- ✅ **22 global admins** (restaurant_id = 0)
- ✅ **All password hashes present** (493/493)
- ✅ **Only 1 missing email** (legacy_admin_id=58)
- ✅ **All 16 columns populated** correctly

---

## 🔄 What Happens Next (After Import)

### Columns That WILL Migrate to V3:
- ✅ `fname` → `first_name`
- ✅ `lname` → `last_name`
- ✅ `email` → `email`
- ✅ `password_hash` → `password_hash`
- ✅ `lastlogin` → `last_login`
- ✅ `login_count` → `login_count`
- ✅ `active_user` ('1'/'0') → `is_active` (boolean)
- ✅ `send_statement` ('y'/'n') → `send_statement` (boolean)

### Columns That WON'T Migrate (V1-specific, out of scope):
- ❌ `show_all_stats` - V1 UI flag
- ❌ `fb_token` - Facebook auth (obsolete)
- ❌ `show_order_management` - V1 UI flag
- ❌ `send_statement_to` - Not in V3 schema
- ❌ `allow_ar` - Arabic language flag
- ❌ `show_clients` - V1 UI flag

These extra columns will simply be ignored during Step 2 (Transform & Upsert to V3).

---

## 🆘 Troubleshooting

### Issue: Column count mismatch
**Solution:** Ensure you're using `v1_restaurant_admins_for_import_CORRECTED.csv` (16 columns), NOT the old version (12 columns)

### Issue: Import fails with "duplicate key" error
**Solution:** Table already has data. Clear it first:
```sql
TRUNCATE TABLE staging.v1_restaurant_admin_users;
```

### Issue: Data appears in wrong columns
**Solution:** Verify "First row is header" checkbox is enabled in import settings

### Issue: Special characters look wrong
**Solution:** Ensure UTF-8 encoding is selected in import settings

---

## 📊 Migration Progress Tracking

- ✅ **Step 0:** Preconditions verified
- ✅ **Step 1a:** Staging table created (16 columns)
- 🔄 **Step 1b:** CSV import (YOU ARE HERE)
- ⏳ **Step 2:** Transform & upsert to `menuca_v3.restaurant_admin_users`
- ⏳ **Step 3:** Post-load normalization
- ⏳ **Step 4:** Verification queries
- ⏳ **Step 5:** Multi-restaurant access (BLOB decoding)

---

**Ready to import!** 🚀

Once you've successfully imported the CSV, verify the counts above, then we'll proceed to Step 2.

