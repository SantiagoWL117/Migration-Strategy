# Menu & Catalog Migration - V2 Tables Handoff

## 🎯 Current Status

### ✅ **COMPLETED - V1 Tables (ALL 7 LOADED!)**
| Table | Rows Loaded | Status |
|-------|-------------|--------|
| v1_combo_groups | 53,193 | ✅ COMPLETE |
| v1_combos | 16,461 | ✅ COMPLETE |
| v1_courses | 121 | ✅ COMPLETE |
| v1_ingredient_groups | 2,992 | ✅ COMPLETE |
| v1_ingredients | 3,000 | ✅ COMPLETE |
| v1_menu | 58,057 | ✅ COMPLETE |
| v1_menuothers | 70,381 | ✅ COMPLETE |
| **TOTAL V1** | **204,248 rows** | ✅ |

### 🔄 **IN PROGRESS - V2 Tables (2 of 10 LOADED)**
| Table | Rows Loaded | Status |
|-------|-------------|--------|
| v2_global_courses | 33 | ✅ COMPLETE |
| v2_restaurants_combo_groups | 13 | ✅ COMPLETE |
| v2_global_ingredients | 0 | ❌ PENDING |
| v2_restaurants_combo_groups_items | 0 | ❌ PENDING |
| v2_restaurants_courses | 0 | ❌ PENDING |
| v2_restaurants_dishes | 0 | ❌ PENDING |
| v2_restaurants_dishes_customization | 0 | ❌ PENDING |
| v2_restaurants_ingredient_groups | 0 | ❌ PENDING |
| v2_restaurants_ingredient_groups_items | 0 | ❌ PENDING |
| v2_restaurants_ingredients | 0 | ❌ PENDING |

---

## 🔧 **What Needs to Be Done**

### Problem: V2 Tables Have Schema Mismatches

Just like `v1_menu` had column count mismatches, the V2 tables likely have:
1. **Column count mismatches** (staging tables missing columns vs. source data)
2. **Data type mismatches** (VARCHAR vs SMALLINT, etc.)

### Solution Steps:

1. **Check V2 Schema** from: `/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Schemas/menuca_v2_structure.sql`

2. **For Each V2 Table That's Empty:**
   - Get the CREATE TABLE statement from V2 schema
   - Count columns in the batch file INSERT statement
   - If mismatch, recreate the staging table with correct schema
   - Reload the batches

3. **Test & Load:**
   ```bash
   # Test one batch first
   /opt/homebrew/opt/postgresql@16/bin/psql "postgresql://postgres.nthpbtdjhhnwfxqsxbvy:SgqBbe2xUuerQBZ5@aws-1-us-east-1.pooler.supabase.com:5432/postgres" -f "/path/to/batch.sql"
   
   # If successful, load all batches
   for f in menuca_v2_*_batch_*.sql; do
       psql "CONNECTION_STRING" -f "$f"
   done
   ```

---

## 📁 **Key Files & Locations**

### Batch Files (Ready to Load):
```
/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu & Catalog Entity/split_pg/
```

### V2 Schema Reference:
```
/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Schemas/menuca_v2_structure.sql
```

### Working psql Connection String:
```bash
postgresql://postgres.nthpbtdjhhnwfxqsxbvy:SgqBbe2xUuerQBZ5@aws-1-us-east-1.pooler.supabase.com:5432/postgres
```

### psql Binary Path:
```
/opt/homebrew/opt/postgresql@16/bin/psql
```

---

## 🛠️ **Known Issues & Fixes**

### Issue 1: Quote Escaping (FIXED ✅)
**Problem:** MySQL uses `\'` but PostgreSQL needs `''`  
**Solution:** All batch files already fixed with:
```bash
sed -i '' "s/\\\\'/''''/g" *.sql
```

### Issue 2: _binary Keyword (FIXED ✅)
**Problem:** MySQL `_binary` syntax not supported in PostgreSQL  
**Solution:** Already removed from all batches

### Issue 3: Column Count Mismatch (PARTIALLY FIXED ✅)
**Problem:** Staging tables don't match source schema  
**Solution for v1_menu:** Recreated table with correct 73 columns  
**Needs:** Apply same fix to V2 tables

---

## 📊 **V2 Tables Batch Count**

| Table | Batch Files |
|-------|-------------|
| v2_global_ingredients | 6 batches |
| v2_restaurants_courses | 2 batches |
| v2_restaurants_dishes | 11 batches |
| v2_restaurants_dishes_customization | 18 batches |
| v2_restaurants_ingredient_groups | 1 file |
| v2_restaurants_ingredient_groups_items | 4 batches |
| v2_restaurants_ingredients | 3 batches |
| v2_restaurants_combo_groups_items | 1 file |

**Total: ~46 batch files to load**

---

## ✅ **Example: How We Fixed v1_menu**

1. **Identified problem:**
   ```bash
   ERROR: INSERT has more expressions than target columns
   ```

2. **Found root cause:**
   - Staging table: 68 columns
   - Source data: 73 columns
   - Missing: `hideOnDays`, `checkoutItems`, `upsell`

3. **Recreated table:**
   ```sql
   DROP TABLE staging.v1_menu;
   CREATE TABLE staging.v1_menu (
       -- All 73 columns with correct data types
   );
   ```

4. **Loaded successfully:**
   ```bash
   for f in menuca_v1_menu_batch_*.sql; do
       psql "CONNECTION_STRING" -f "$f"
   done
   ```
   Result: 58,057 rows loaded ✅

---

## 🚀 **Next Steps for New Chat**

1. **Start with v2_global_ingredients** (smallest - 6 batches)
2. **Check schema:** `grep "CREATE TABLE.*global_ingredients" -A 50 /path/to/menuca_v2_structure.sql`
3. **Compare columns:** staging table vs batch file
4. **Fix & load**
5. **Repeat for other 7 V2 tables**

---

## 📈 **Success Criteria**

When done, this query should show rows for ALL tables:
```sql
SELECT 
  'v2_global_ingredients' as table_name, COUNT(*) FROM staging.v2_global_ingredients
UNION ALL SELECT 'v2_restaurants_combo_groups_items', COUNT(*) FROM staging.v2_restaurants_combo_groups_items
UNION ALL SELECT 'v2_restaurants_courses', COUNT(*) FROM staging.v2_restaurants_courses
UNION ALL SELECT 'v2_restaurants_dishes', COUNT(*) FROM staging.v2_restaurants_dishes
UNION ALL SELECT 'v2_restaurants_dishes_customization', COUNT(*) FROM staging.v2_restaurants_dishes_customization
UNION ALL SELECT 'v2_restaurants_ingredient_groups', COUNT(*) FROM staging.v2_restaurants_ingredient_groups
UNION ALL SELECT 'v2_restaurants_ingredient_groups_items', COUNT(*) FROM staging.v2_restaurants_ingredient_groups_items
UNION ALL SELECT 'v2_restaurants_ingredients', COUNT(*) FROM staging.v2_restaurants_ingredients
ORDER BY table_name;
```

**None should be 0!**

---

## 🎯 **After V2 Loading Complete**

Move to next phase:
1. ✅ Verify all data loaded
2. 🔄 Analyze BLOB data (PHP serialized → JSON)
3. 🔄 Design V3 schema with JSONB
4. 🔄 Create transformation scripts
5. 🔄 Load V3 final tables

Good luck! 🚀

