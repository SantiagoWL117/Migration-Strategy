# V1 Data Bulk Reload - Instructions

**Created:** October 2, 2025  
**Method:** Direct PostgreSQL Connection via Supabase Pooler

---

## 🚀 Quick Start

### 1. Install Requirements

```bash
pip install psycopg2-binary python-dotenv
```

### 2. Set Database Password

**Option A: Environment Variable (Recommended)**
```bash
export SUPABASE_DB_PASSWORD="your-password-here"
```

**Option B: Enter When Prompted**
The script will ask for password if not set

### 3. Run the Reload Script

```bash
cd "/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu & Catalog Entity"
python3 bulk_reload_v1_data.py
```

---

## 📊 What It Does

The script will:

1. **Connect** to Supabase via connection pooler (fast, no timeouts)
2. **Load 264 batch files** across 4 tables:
   - v1_ingredient_groups: 16 batches → 13,450 rows
   - v1_ingredients: 54 batches → 53,367 rows
   - v1_combo_groups: 68 batches → 62,913 rows
   - v1_menu: 126 batches → 138,941 rows
3. **Verify** row counts match expected totals
4. **Report** detailed progress and completion status

**Estimated Time:** 5-10 minutes for all 264 batches

---

## 📈 Expected Output

```
================================================================================
🚀 V1 DATA BULK RELOAD - PostgreSQL Direct Connection
================================================================================
Batch Directory: .../split_pg
Total Tables: 4
Total Batches: 264
Total Rows: 268,671

🔌 Connecting to Supabase...
✅ Connected successfully!

================================================================================
📊 Loading: V1_INGREDIENT_GROUPS
================================================================================
Target: 13,450 rows in 16 batches
Staging Table: staging.v1_ingredient_groups

  [  1/ 16]   6.2% - menuca_v1_ingredient_groups_batch_001.sql      841 rows -  0.45s
  [  2/ 16]  12.5% - menuca_v1_ingredient_groups_batch_002.sql      841 rows -  0.42s
  ...
  [ 16/ 16] 100.0% - menuca_v1_ingredient_groups_batch_016.sql      810 rows -  0.41s

────────────────────────────────────────────────────────────────────────────────
✅ Table Complete: v1_ingredient_groups
   Loaded: 13,450 rows in 8.2s (1,640 rows/sec)
   Expected: 13,450 rows
   Status: ✅ PERFECT MATCH

[... continues for other 3 tables ...]

================================================================================
🔍 FINAL VERIFICATION
================================================================================

v1_ingredient_groups        13,450 /   13,450  ✅ PASS
v1_ingredients              53,367 /   53,367  ✅ PASS
v1_combo_groups             62,913 /   62,913  ✅ PASS
v1_menu                    138,941 /  138,941  ✅ PASS

================================================================================
📈 RELOAD SUMMARY
================================================================================
Total Time: 312.5s (5.2 minutes)
Success Rate: 4/4 tables

✅ SUCCESS! All tables reloaded with correct row counts!

🎯 Next Steps:
   1. Re-run Phase 2 transformations (V1→V3)
   2. Handle v1_courses separately (13,238 rows)
   3. Deploy updated data to production
```

---

## 🔧 Troubleshooting

### Error: "No module named 'psycopg2'"
```bash
pip install psycopg2-binary
```

### Error: "Connection failed"
- Check password is correct
- Verify Supabase connection pooler URL is current
- Ensure your IP is whitelisted in Supabase (if restrictions enabled)

### Error: "No batch files found"
- Ensure you're running from the correct directory
- Check that `split_pg/` directory exists with batch files

### Warning: "Mismatched row count"
- Check error messages for specific failed batches
- May need to reload individual batches
- Verify batch files are complete and not corrupted

---

## 🎯 After Reload Success

1. **Verify staging data:**
   ```sql
   SELECT 
       'v1_ingredient_groups' as table_name,
       COUNT(*) as rows
   FROM staging.v1_ingredient_groups
   UNION ALL
   SELECT 'v1_ingredients', COUNT(*) FROM staging.v1_ingredients
   UNION ALL
   SELECT 'v1_combo_groups', COUNT(*) FROM staging.v1_combo_groups
   UNION ALL
   SELECT 'v1_menu', COUNT(*) FROM staging.v1_menu;
   ```

2. **Check for v1_courses** (still needs conversion - 13,238 rows missing)

3. **Re-run Phase 2 transformations** to populate V3 tables with complete data

4. **Deploy to production** - menu_v3 tables will get 80,884 additional dishes!

---

## 📝 Notes

- Script uses transactions - if any batch fails, the entire table is rolled back
- Progress is shown in real-time
- Safe to interrupt (Ctrl+C) - current transaction will rollback
- Each table is committed separately for safety
- Connection pooler handles concurrency and connection management


