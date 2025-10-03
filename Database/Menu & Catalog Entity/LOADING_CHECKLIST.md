# Menu & Catalog Data Loading Checklist

## Status: 🚀 IN PROGRESS (3 of 17 tables loaded)

### V1 Tables (7 tables)

| Table | File | Size | Method | Status |
|-------|------|------|--------|--------|
| ✅ v1_courses | menuca_v1_courses_WITH_COLUMNS.sql | 8.2K | SQL Editor | **DONE - 121 rows** |
| 🔄 v1_combo_groups | menuca_v1_combo_groups_postgres.sql | 13K | **SQL Editor** | Ready |
| 🔄 v1_combos | menuca_v1_combos_postgres.sql | 343K | **SQL Editor** | Ready |
| 🔄 v1_ingredient_groups | menuca_v1_ingredient_groups_postgres.sql | 510B (BLOB) | **SQL Editor** | Ready |
| 🔄 v1_ingredients | menuca_v1_ingredients_postgres.sql | 2.3M | **SQL Editor** | Ready |
| 🔄 v1_menu | menuca_v1_menu_postgres.sql | 4.0M | **SQL Editor** | Ready |
| 🔄 v1_menuothers | menuca_v1_menuothers_postgres.sql | 1.6K (BLOB) | **SQL Editor** | Ready |

### V2 Tables (10 tables)

| Table | File | Size | Method | Status |
|-------|------|------|--------|--------|
| ✅ v2_global_courses | menuca_v2_global_courses_postgres.sql | 2.3K | MCP | **DONE - 33 rows** |
| 🔄 v2_global_ingredients | menuca_v2_global_ingredients_postgres.sql | 340K | **SQL Editor** | Ready |
| ✅ v2_restaurants_combo_groups | menuca_v2_restaurants_combo_groups_postgres.sql | 16K | MCP | **DONE - 13 rows** |
| 🔄 v2_restaurants_combo_groups_items | menuca_v2_restaurants_combo_groups_items_postgres.sql | 435K | **SQL Editor** | Ready |
| 🔄 v2_restaurants_courses | menuca_v2_restaurants_courses_postgres.sql | 153K | **SQL Editor** | Ready |
| 🔄 v2_restaurants_dishes | menuca_v2_restaurants_dishes_postgres.sql | 1.1M | **SQL Editor** | Ready |
| 🔄 v2_restaurants_dishes_customization | menuca_v2_restaurants_dishes_customization_postgres.sql | 7.5M | **SQL Editor** | Ready |
| 🔄 v2_restaurants_ingredient_groups | menuca_v2_restaurants_ingredient_groups_postgres.sql | 51K | **SQL Editor** | Ready |
| 🔄 v2_restaurants_ingredient_groups_items | menuca_v2_restaurants_ingredient_groups_items_postgres.sql | 159K | **SQL Editor** | Ready |
| 🔄 v2_restaurants_ingredients | menuca_v2_restaurants_ingredients_postgres.sql | 276K | **SQL Editor** | Ready |

---

## Loading Strategy

### ✅ Phase 1: MCP Loading (COMPLETE)
- v1_courses: 121 rows ✅
- v2_global_courses: 33 rows ✅
- v2_restaurants_combo_groups: 13 rows ✅

### 🔄 Phase 2: SQL Editor Loading (14 files remaining)
**All remaining files need SQL Editor due to size/BLOB complexity**

**Process:**
1. Open [Supabase SQL Editor](https://supabase.com/dashboard/project/nthpbtdjhhnwfxqsxbvy/sql/new)
2. Navigate to file in: `/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu & Catalog Entity/converted/`
3. Copy entire file contents
4. Paste into SQL Editor
5. Click "Run"
6. Verify row count in checklist

**Order of Loading (smallest to largest):**
1. ✅ v1_combo_groups (13K)
2. ✅ v1_ingredient_groups (510B BLOB)
3. ✅ v1_menuothers (1.6K BLOB)
4. ✅ v2_global_ingredients (340K)
5. ✅ v2_restaurants_ingredient_groups (51K)
6. ✅ v2_restaurants_courses (153K)
7. ✅ v2_restaurants_ingredient_groups_items (159K)
8. ✅ v2_restaurants_ingredients (276K)
9. ✅ v1_combos (343K)
10. ✅ v2_restaurants_combo_groups_items (435K)
11. ✅ v2_restaurants_dishes (1.1M)
12. ✅ v1_ingredients (2.3M)
13. ✅ v1_menu (4.0M)
14. ✅ v2_restaurants_dishes_customization (7.5M) - **LARGEST**

---

## Timeline

- ✅ **Phase 1**: MCP Loading (COMPLETE)
- 🔄 **Phase 2**: SQL Editor Loading (20-30 minutes estimated)

---

## Verification Queries

After loading, run:
```sql
SELECT 
  'v1_courses' as table_name, COUNT(*) FROM staging.v1_courses
UNION ALL SELECT 'v1_combo_groups', COUNT(*) FROM staging.v1_combo_groups
UNION ALL SELECT 'v1_combos', COUNT(*) FROM staging.v1_combos
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

