# Step 1b: Load V1 Data into Staging

**Status:** Ready to execute  
**BLOB Data:** ❌ Excluded (will be handled in Step 5)

---

## 🎯 **Goal**

Load 493 records from V1 `restaurant_admins` into `staging.v1_restaurant_admin_users` (without BLOB data).

---

## ✅ **Prerequisites**

- [x] Staging table created and BLOB column removed
- [ ] MySQL connection to V1 database
- [ ] Python with `mysql-connector-python` and `psycopg2-binary`

---

## 📋 **Method 1: Python Script (Recommended)**

### **Step 1: Install Dependencies**

```bash
pip install mysql-connector-python psycopg2-binary
```

### **Step 2: Set Environment Variables**

```bash
# PostgreSQL/Supabase connection
export SUPABASE_DB_URL="postgresql://postgres:[your-password]@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres"

# MySQL V1 connection
export MYSQL_HOST="localhost"
export MYSQL_USER="root"
export MYSQL_PASSWORD="your_mysql_password"
export MYSQL_DATABASE="menuca_v1"
```

### **Step 3: Run the Script**

```bash
cd "Database/Restaurant Management Entity/restaurant admins"
python load_v1_data_to_staging.py
```

### **Expected Output:**

```
================================================================================
  Step 1b: Load V1 restaurant_admins Data into Staging
================================================================================

⚠️  Note: BLOB data (allowed_restaurants) excluded - handled in Step 5

📡 Connecting to databases...
✅ Connected to MySQL: menuca_v1
✅ Connected to PostgreSQL/Supabase

🔍 Verifying source data...
  Source records: 493

🧹 Clearing staging table...
  Staging table cleared

📊 Extracting V1 data...
✅ Extracted 493 records from V1

📥 Loading into PostgreSQL staging...
  Loaded 493/493 records...
✅ Loaded 493 records successfully

🔍 Verifying loaded data...
  Total records: 493
  Restaurant admins (restaurant>0): 471
  Global admins (restaurant=0): 22 (will be excluded)
  Active users: 52
  Inactive users: 441

================================================================================
  SUMMARY
================================================================================
  Source records (V1):     493
  Loaded to staging:       493
  Success rate:            100.0%
================================================================================

✅ Step 1b complete!
```

---

## 📋 **Method 2: Direct SQL (Alternative)**

If you can't use Python, you can export/import via CSV:

### **Step 1: Export from MySQL**

```bash
mysql -u root -p menuca_v1 -e "
SELECT 
    id,
    restaurant,
    fname,
    lname,
    email,
    password,
    lastlogin,
    loginCount,
    activeUser,
    sendStatement,
    NULL,
    NULL
FROM restaurant_admins
ORDER BY id
" --batch --skip-column-names > v1_admins.tsv
```

### **Step 2: Convert TSV to CSV (PowerShell)**

```powershell
Get-Content v1_admins.tsv | ForEach-Object {
    $_ -replace "`t", ","
} | Out-File v1_admins.csv -Encoding UTF8
```

### **Step 3: Load into PostgreSQL**

```sql
-- In psql or Supabase SQL Editor
TRUNCATE TABLE staging.v1_restaurant_admin_users;

\COPY staging.v1_restaurant_admin_users (
    legacy_admin_id,
    legacy_v1_restaurant_id,
    fname,
    lname,
    email,
    password_hash,
    lastlogin,
    login_count,
    active_user,
    send_statement,
    created_at,
    updated_at
) 
FROM 'v1_admins.csv' 
WITH (FORMAT csv, NULL 'NULL');
```

---

## 🔍 **Verification Queries**

After loading, run these in Supabase SQL Editor:

```sql
-- 1. Total count
SELECT COUNT(*) AS total_records
FROM staging.v1_restaurant_admin_users;
-- Expected: 493

-- 2. Distribution
SELECT 
    COUNT(*) AS total,
    COUNT(CASE WHEN legacy_v1_restaurant_id > 0 THEN 1 END) AS restaurant_admins,
    COUNT(CASE WHEN legacy_v1_restaurant_id = 0 THEN 1 END) AS global_admins,
    COUNT(CASE WHEN active_user = '1' THEN 1 END) AS active,
    COUNT(CASE WHEN active_user = '0' THEN 1 END) AS inactive
FROM staging.v1_restaurant_admin_users;

-- 3. Data quality check
SELECT 
    COUNT(CASE WHEN email IS NULL OR email = '' THEN 1 END) AS missing_email,
    COUNT(CASE WHEN password_hash IS NULL OR password_hash = '' THEN 1 END) AS missing_password,
    COUNT(CASE WHEN fname IS NULL OR fname = '' THEN 1 END) AS missing_fname,
    COUNT(CASE WHEN lname IS NULL OR lname = '' THEN 1 END) AS missing_lname
FROM staging.v1_restaurant_admin_users;
-- All should be 0 or minimal

-- 4. Sample records
SELECT 
    legacy_admin_id,
    legacy_v1_restaurant_id,
    fname,
    lname,
    email,
    active_user,
    login_count
FROM staging.v1_restaurant_admin_users
ORDER BY legacy_admin_id
LIMIT 10;
```

---

## 🧹 **Optional: Run Cleanup**

After loading, you can run optional cleanup:

```bash
# Updates staging table in Supabase MCP
```

Or run these queries manually:

```sql
-- Normalize emails
UPDATE staging.v1_restaurant_admin_users
SET email = lower(trim(email))
WHERE email IS NOT NULL;

-- Trim names
UPDATE staging.v1_restaurant_admin_users
SET fname = trim(fname),
    lname = trim(lname)
WHERE fname IS NOT NULL OR lname IS NOT NULL;
```

---

## ✅ **Success Criteria**

- [ ] 493 records loaded
- [ ] 471 records with `restaurant > 0`
- [ ] 22 records with `restaurant = 0` (will be excluded in Step 2)
- [ ] No NULL emails
- [ ] All passwords present
- [ ] Sample data looks correct

---

## 📝 **Next Steps**

After successful loading:

1. ✅ **Verify data** using queries above
2. 🔄 **Proceed to Step 2:** Transform and upsert to `restaurant_admin_users`
3. ⏳ **Later - Step 5:** Decode BLOB data for multi-restaurant access

---

## ⚠️ **Troubleshooting**

### **Issue: MySQL connection refused**
```bash
# Check if MySQL is running
mysql -u root -p -e "SELECT 1"

# Check database exists
mysql -u root -p -e "SHOW DATABASES LIKE 'menuca_v1'"
```

### **Issue: Permission denied in PostgreSQL**
- Make sure you're using the service role key
- Check connection string has correct password

### **Issue: Python dependencies not found**
```bash
# Reinstall dependencies
pip install --upgrade mysql-connector-python psycopg2-binary
```

---

**Ready to proceed with Step 1b?** Run the Python script or use the SQL method!

