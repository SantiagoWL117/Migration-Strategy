# Step 1b Execution Instructions

## Status: READY TO EXECUTE

**Goal:** Load 493 V1 `restaurant_admins` records into `staging.v1_restaurant_admin_users` (BLOB data excluded)

---

## ✅ **Prerequisites Completed**

- [x] Staging table created (without BLOB column)
- [x] 493 records parsed from V1 dump file
- [x] SQL statements generated and validated
- [x] Split into 10 manageable batches (50 records each)

---

## 📊 **Batch Files Created**

10 batch files ready for execution:
- `step1b_mcp_batch_01.sql` - Records 1-50 (includes TRUNCATE)
- `step1b_mcp_batch_02.sql` - Records 51-100
- `step1b_mcp_batch_03.sql` - Records 101-150
- `step1b_mcp_batch_04.sql` - Records 151-200
- `step1b_mcp_batch_05.sql` - Records 201-250
- `step1b_mcp_batch_06.sql` - Records 251-300
- `step1b_mcp_batch_07.sql` - Records 301-350
- `step1b_mcp_batch_08.sql` - Records 351-400
- `step1b_mcp_batch_09.sql` - Records 401-450
- `step1b_mcp_batch_10.sql` - Records 451-493 (includes COMMIT & verification)

---

## 🚀 **Execution Options**

### **Option 1: Supabase MCP (Cursor)** ⭐ RECOMMENDED

Execute each batch sequentially using `mcp_supabase_execute_sql`:

```javascript
// Read and execute each batch file
for (let i = 1; i <= 10; i++) {
  const batchFile = `step1b_mcp_batch_${i.toString().padStart(2, '0')}.sql`;
  const sql = readFileSync(batchFile, 'utf-8');
  await mcp_supabase_execute_sql({ query: sql });
  console.log(`✅ Batch ${i}/10 completed`);
}
```

### **Option 2: PostgreSQL Direct (psql)**

If MCP execution fails, use direct PostgreSQL connection:

```bash
# Set connection string
export SUPABASE_DB_URL="postgresql://postgres:[password]@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres"

# Execute all batches
for i in {01..10}; do
  psql $SUPABASE_DB_URL -f "step1b_mcp_batch_${i}.sql"
  echo "✅ Batch $i completed"
done
```

### **Option 3: Combined Single File**

Use the consolidated file `step1b_bulk_insert_fixed.sql` (contains all 493 records):

```bash
psql $SUPABASE_DB_URL -f "step1b_bulk_insert_fixed.sql"
```

---

## ✅ **Verification Queries**

After execution, run these to verify:

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

-- Check data integrity
SELECT 
  COUNT(DISTINCT legacy_admin_id) AS unique_ids,
  COUNT(*) - COUNT(password_hash) AS missing_passwords,
  COUNT(*) - COUNT(email) AS missing_emails
FROM staging.v1_restaurant_admin_users;
-- Expected: unique_ids=493, missing_passwords=0, missing_emails=1 (one record has empty email)
```

---

## 📝 **Next Steps After Loading**

Once Step 1b is complete:
1. ✅ Mark Step 1 as COMPLETED
2. 📋 Proceed to **Step 2: Transform and Upsert** into `menuca_v3.restaurant_admin_users`
3. 📋 Step 3: Post-load normalization
4. 📋 Step 4: Verification queries
5. 📋 Step 5 (OPTIONAL): Migrate multi-restaurant access from BLOB data

---

## 🔧 **Troubleshooting**

### **Issue: Transaction size too large**
- **Solution:** Execute batches individually instead of bulk file

### **Issue: MCP read-only error**
- **Verify:** `.cursor/mcp.json` includes `SUPABASE_SERVICE_ROLE_KEY`
- **Restart:** Cursor to reload MCP configuration

### **Issue: Duplicate key error**
- **Solution:** Run `TRUNCATE TABLE staging.v1_restaurant_admin_users;` first

---

**Last Updated:** 2025-10-02  
**Files Ready:** ✅ All batch files generated  
**Status:** Awaiting execution command

