# Menu & Catalog Data Loading - FINAL GUIDE ✅

## 🎯 Fixed Files Ready to Load

All SQL files have been properly converted:
- ✅ `_binary` keyword removed
- ✅ Complete INSERT statements (no truncation)
- ✅ PostgreSQL-compatible format
- ✅ Proper table targeting (`staging.v1_*` / `staging.v2_*`)

---

## 📁 Files to Load (Copy & Paste to Supabase SQL Editor)

**Location:** `/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu & Catalog Entity/final_pg/`

### **V1 Tables** (Already have v1_courses = 121 rows ✅)

1. **v1_combo_groups**  
   `/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu & Catalog Entity/final_pg/menuca_v1_combo_groups_final_pg.sql`

2. **v1_combos**  
   `/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu & Catalog Entity/final_pg/menuca_v1_combos_final_pg.sql`

3. **v1_ingredient_groups**  
   `/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu & Catalog Entity/final_pg/menuca_v1_ingredient_groups_final_pg.sql`

4. **v1_ingredients**  
   `/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu & Catalog Entity/final_pg/menuca_v1_ingredients_final_pg.sql`

5. **v1_menu**  
   `/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu & Catalog Entity/final_pg/menuca_v1_menu_final_pg.sql`

6. **v1_menuothers**  
   `/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu & Catalog Entity/final_pg/menuca_v1_menuothers_final_pg.sql`

### **V2 Tables** (Already have v2_global_courses = 33 rows, v2_restaurants_combo_groups = 13 rows ✅)

7. **v2_global_ingredients**  
   `/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu & Catalog Entity/final_pg/menuca_v2_global_ingredients_final_pg.sql`

8. **v2_restaurants_combo_groups_items**  
   `/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu & Catalog Entity/final_pg/menuca_v2_restaurants_combo_groups_items_final_pg.sql`

9. **v2_restaurants_courses**  
   `/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu & Catalog Entity/final_pg/menuca_v2_restaurants_courses_final_pg.sql`

10. **v2_restaurants_dishes**  
    `/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu & Catalog Entity/final_pg/menuca_v2_restaurants_dishes_final_pg.sql`

11. **v2_restaurants_dishes_customization**  
    `/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu & Catalog Entity/final_pg/menuca_v2_restaurants_dishes_customization_final_pg.sql`

12. **v2_restaurants_ingredient_groups**  
    `/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu & Catalog Entity/final_pg/menuca_v2_restaurants_ingredient_groups_final_pg.sql`

13. **v2_restaurants_ingredient_groups_items**  
    `/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu & Catalog Entity/final_pg/menuca_v2_restaurants_ingredient_groups_items_final_pg.sql`

14. **v2_restaurants_ingredients**  
    `/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu & Catalog Entity/final_pg/menuca_v2_restaurants_ingredients_final_pg.sql`

---

## 🔄 Loading Process

**For each file:**

1. **Click the path** → Opens in Cursor
2. **Cmd+A** (Select All) → **Cmd+C** (Copy)
3. **Open Supabase SQL Editor**: https://supabase.com/dashboard/project/nthpbtdjhhnwfxqsxbvy/sql/new
4. **Cmd+V** (Paste) → **Click "Run"**
5. **Wait for success** (large files may take 30-60 seconds)

---

## ✅ Verification Query

After loading all files, run this in Supabase SQL Editor to verify row counts:

```sql
SELECT 
  'v1_combo_groups' as table_name, COUNT(*) FROM staging.v1_combo_groups
UNION ALL SELECT 'v1_combos', COUNT(*) FROM staging.v1_combos
UNION ALL SELECT 'v1_courses', COUNT(*) FROM staging.v1_courses
UNION ALL SELECT 'v1_ingredient_groups', COUNT(*) FROM staging.v1_ingredient_groups
UNION ALL SELECT 'v1_ingredients', COUNT(*) FROM staging.v1_ingredients
UNION ALL SELECT 'v1_menu', COUNT(*) FROM staging.v1_menu
UNION ALL SELECT 'v1_menuothers', COUNT(*) FROM staging.v1_menuothers
UNION ALL SELECT 'v2_global_courses', COUNT(*) FROM staging.v2_global_courses
UNION ALL SELECT 'v2_global_ingredients', COUNT(*) FROM staging.v2_global_ingredients
UNION ALL SELECT 'v2_restaurants_combo_groups', COUNT(*) FROM staging.v2_restaurants_combo_groups
UNION ALL SELECT 'v2_restaurants_combo_groups_items', COUNT(*) FROM staging.v2_restaurants_combo_groups_items
UNION ALL SELECT 'v2_restaurants_courses', COUNT(*) FROM staging.v2_restaurants_courses
UNION ALL SELECT 'v2_restaurants_dishes', COUNT(*) FROM staging.v2_restaurants_dishes
UNION ALL SELECT 'v2_restaurants_dishes_customization', COUNT(*) FROM staging.v2_restaurants_dishes_customization
UNION ALL SELECT 'v2_restaurants_ingredient_groups', COUNT(*) FROM staging.v2_restaurants_ingredient_groups
UNION ALL SELECT 'v2_restaurants_ingredient_groups_items', COUNT(*) FROM staging.v2_restaurants_ingredient_groups_items
UNION ALL SELECT 'v2_restaurants_ingredients', COUNT(*) FROM staging.v2_restaurants_ingredients
ORDER BY table_name;
```

---

## 📊 Expected Status

- **Files needing load**: 14
- **Already loaded**: 3 (v1_courses, v2_global_courses, v2_restaurants_combo_groups)
- **Estimated time**: 15-20 minutes

---

**NOTE:** If you get any errors, stop immediately and let me know! The files are now properly formatted, so loading should work smoothly. 🚀

