# Step 5: Multi-Restaurant Access Migration - Execution Guide

**Date:** October 2, 2025  
**Purpose:** Decode V1 `allowed_restaurants` BLOB data and populate `menuca_v3.restaurant_admin_access`  
**Method:** Python Script (Solution 2)

---

## 📋 Prerequisites Check

Before running the script, verify:

- ✅ **Step 0-4 completed** (444 admin users migrated)
- ✅ **Python 3.7+** installed
- ✅ **Supabase database password** available

---

## 🚀 Step-by-Step Execution

### **Step 1: Install Required Python Libraries**

Open PowerShell in the project directory and run:

```powershell
# Install dependencies
pip install psycopg2-binary phpserialize
```

**Expected output:**
```
Successfully installed psycopg2-binary-2.9.x phpserialize-1.3.x
```

---

### **Step 2: Get Your Supabase Database Connection String**

You need the **Direct Connection** string from Supabase:

**Option A: Use the connection string format:**
```
postgresql://postgres.nthpbtdjhhnwfxqsxbvy:[YOUR-PASSWORD]@aws-0-us-east-1.pooler.supabase.com:6543/postgres
```

**Option B: Get it from Supabase Dashboard:**
1. Go to: https://supabase.com/dashboard/project/nthpbtdjhhnwfxqsxbvy
2. Navigate to: **Settings** → **Database**
3. Scroll to: **Connection string** section
4. Copy the **Direct connection** string (port 5432 or 6543)
5. Replace `[YOUR-PASSWORD]` with your actual database password

---

### **Step 3: Set Environment Variable**

**PowerShell (Windows):**
```powershell
$env:SUPABASE_DB_URL = "postgresql://postgres.nthpbtdjhhnwfxqsxbvy:[YOUR-PASSWORD]@aws-0-us-east-1.pooler.supabase.com:6543/postgres"
```

**Important:** Replace `[YOUR-PASSWORD]` with your actual Supabase database password!

---

### **Step 4: Run the Python Script**

```powershell
cd "Database\Restaurant Management Entity\restaurant admins"
python decode_allowed_restaurants.py
```

---

## 📊 Expected Output

The script will:

1. **Connect to database**
   ```
   📡 Connecting to database...
   ✅ Connected!
   ```

2. **Verify prerequisites**
   ```
   🔍 Checking prerequisites...
     Staging records: 493
     Admin users migrated: 444
     Restaurants with V1 IDs: 940
   ✅ All prerequisites met!
   ```

3. **Create junction table** (if it doesn't exist)
   ```
   ✅ Junction table verified/created
   ```

4. **Process BLOB records**
   ```
   📊 Fetching staging records with BLOB data...
   ✅ Found XXX records to process
   
   🔄 Processing records...
   ✓ james@menu.ca: 847/850 restaurants granted
   ✓ stefan@menu.ca: 725/728 restaurants granted
   ...
   ```

5. **Display summary**
   ```
   ================================================================================
     SUMMARY
   ================================================================================
     Total records processed:     XXX
     ✅ Successfully processed:   XXX
     ⊘  Skipped (no BLOB data):   X
     ⚠️  Skipped (user not found): X
     ❌ Errors:                   X
     🎯 Total access grants:      XXXX
   ================================================================================
   ```

---

## ⚠️ Troubleshooting

### **Error: "psycopg2 not found"**
```powershell
pip install psycopg2-binary
```

### **Error: "phpserialize not found"**
```powershell
pip install phpserialize
```

### **Error: "SUPABASE_DB_URL environment variable not set"**
Make sure you set the environment variable in the same PowerShell session where you run the script:
```powershell
$env:SUPABASE_DB_URL = "your_connection_string"
python decode_allowed_restaurants.py
```

### **Error: "Connection refused" or "timeout"**
- Check your database password is correct
- Verify you're using the **Direct connection** string (port 5432 or 6543)
- Check your firewall/VPN settings

### **Warning: "X restaurant(s) not found in V3"**
This is **normal** - some V1 restaurants may not have been migrated to V3 yet (e.g., suspended/closed restaurants). The script will skip these gracefully.

---

## 🔍 Verification Queries

After the script completes, verify the results in Supabase:

### **1. Check total access grants**
```sql
SELECT COUNT(*) AS total_grants
FROM menuca_v3.restaurant_admin_access;
```

### **2. View users with multi-restaurant access**
```sql
SELECT 
    au.email,
    au.first_name || ' ' || au.last_name AS full_name,
    COUNT(ara.restaurant_id) AS restaurant_count
FROM menuca_v3.restaurant_admin_users au
JOIN menuca_v3.restaurant_admin_access ara ON ara.admin_user_id = au.id
GROUP BY au.id, au.email, au.first_name, au.last_name
HAVING COUNT(ara.restaurant_id) > 1
ORDER BY restaurant_count DESC
LIMIT 20;
```

### **3. View top users by access count**
```sql
SELECT 
    au.email,
    COUNT(ara.restaurant_id) AS access_count,
    array_agg(r.name ORDER BY r.name LIMIT 5) AS sample_restaurants
FROM menuca_v3.restaurant_admin_users au
JOIN menuca_v3.restaurant_admin_access ara ON ara.admin_user_id = au.id
JOIN menuca_v3.restaurants r ON r.id = ara.restaurant_id
GROUP BY au.id, au.email
ORDER BY access_count DESC
LIMIT 10;
```

### **4. Check for any issues**
```sql
-- Should be 0: Access grants with invalid restaurant FK
SELECT COUNT(*)
FROM menuca_v3.restaurant_admin_access ara
LEFT JOIN menuca_v3.restaurants r ON r.id = ara.restaurant_id
WHERE r.id IS NULL;

-- Should be 0: Access grants with invalid admin user FK
SELECT COUNT(*)
FROM menuca_v3.restaurant_admin_access ara
LEFT JOIN menuca_v3.restaurant_admin_users au ON au.id = ara.admin_user_id
WHERE au.id IS NULL;
```

---

## 📝 What the Script Does

1. **Connects** to Supabase PostgreSQL database
2. **Verifies** prerequisites (staging data, migrated users, restaurants)
3. **Creates** `menuca_v3.restaurant_admin_access` junction table (if needed)
4. **Reads** BLOB data from `staging.v1_restaurant_admin_users`
5. **Decodes** PHP serialized arrays using `phpserialize` library
6. **Maps** V1 restaurant IDs to V3 restaurant IDs via `legacy_v1_id`
7. **Inserts** access grants into junction table
8. **Reports** summary statistics and verification data

---

## ✅ Success Criteria

The script is successful if:
- ✅ No database connection errors
- ✅ Junction table created successfully
- ✅ All BLOB records processed (some may be skipped if user not found)
- ✅ Access grants inserted without FK violations
- ✅ Summary shows reasonable number of grants (expected: thousands)

---

## 🎯 Estimated Execution Time

- **Small dataset** (< 50 records): 30 seconds
- **Medium dataset** (50-200 records): 1-2 minutes
- **Large dataset** (200+ records): 3-5 minutes

---

## 📞 Need Help?

If you encounter any issues:
1. Check the error message carefully
2. Verify database connection string is correct
3. Confirm Python libraries are installed
4. Review the troubleshooting section above

---

**Ready to proceed?** Follow the steps above in order, and the migration will complete automatically!

