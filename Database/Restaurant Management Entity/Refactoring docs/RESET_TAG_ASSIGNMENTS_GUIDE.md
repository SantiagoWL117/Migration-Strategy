# Reset Tag Assignments - Complete Guide

**Date:** 2025-10-20  
**Purpose:** Export current data, clear tag assignments, and prepare for fresh tagging

---

## ⚠️ WARNING

This process will **DELETE ALL** tag assignments from `menuca_v3.restaurant_tag_assignments`. This action **CANNOT be undone**. Follow the steps carefully.

---

## Step-by-Step Process

### ✅ Step 1: Export Tags Reference (COMPLETED)

**File Created:** `restaurant_tags_reference.csv`

This file contains all 12 tags available in the system:

| Tag ID | Tag Name | Category | Slug |
|--------|----------|----------|------|
| 1 | Halal | dietary | halal |
| 2 | Vegetarian Options | dietary | vegetarian |
| 3 | Vegan Options | dietary | vegan |
| 4 | Gluten-Free Options | dietary | gluten-free |
| 5 | Delivery | service | delivery |
| 6 | Pickup | service | pickup |
| 7 | Dine-In | service | dine-in |
| 8 | Family Friendly | atmosphere | family-friendly |
| 9 | Late Night | feature | late-night |
| 10 | Accepts Cash | payment | cash |
| 11 | Accepts Credit Card | payment | credit-card |
| 12 | Kosher | dietary | kosher |

---

### 📊 Step 2: Export Active Restaurants with Cuisines

**Method A: Supabase SQL Editor (RECOMMENDED)**

1. Open Supabase SQL Editor:
   ```
   https://supabase.com/dashboard/project/nthpbtdjhhnwfxqsxbvy/sql/new
   ```

2. Copy and paste the contents of `export_active_restaurants.sql`

3. Click "Run"

4. Click the "Download CSV" button (top right of results)

5. Save as: `active_restaurants_with_cuisines.csv` in this directory

**Expected Output:**
- ~277 active restaurants
- Columns: id, name, status, primary_cuisine, cuisine_slug, secondary_cuisines

**Method B: Supabase CLI**

```bash
cd "C:\Users\santi\Menu.ca\Legacy Database\Migration Strategy\Database\Restaurant Management Entity\Refactoring docs"

supabase db execute -f export_active_restaurants.sql --linked > active_restaurants_raw.txt
```

Then manually convert to CSV format.

---

### 🗑️ Step 3: Delete All Tag Assignments

**⚠️ CRITICAL: Only proceed after Step 2 is complete!**

**Method A: Supabase SQL Editor (RECOMMENDED)**

1. Open Supabase SQL Editor:
   ```
   https://supabase.com/dashboard/project/nthpbtdjhhnwfxqsxbvy/sql/new
   ```

2. First, check current count:
   ```sql
   SELECT 
       COUNT(*) as total_assignments,
       COUNT(DISTINCT restaurant_id) as unique_restaurants
   FROM menuca_v3.restaurant_tag_assignments;
   ```
   
   **Expected:** ~1,012 assignments, ~208 restaurants

3. Execute the deletion:
   ```sql
   DELETE FROM menuca_v3.restaurant_tag_assignments;
   ```

4. Verify deletion (should return 0):
   ```sql
   SELECT COUNT(*) FROM menuca_v3.restaurant_tag_assignments;
   ```

**Method B: Supabase CLI**

```bash
supabase db execute --sql "DELETE FROM menuca_v3.restaurant_tag_assignments;" --linked
```

Then verify:
```bash
supabase db execute --sql "SELECT COUNT(*) FROM menuca_v3.restaurant_tag_assignments;" --linked
```

**Method C: Use Pre-made SQL Script**

1. Open `clear_tag_assignments.sql`
2. Follow the instructions in the file
3. Uncomment the DELETE line
4. Execute in SQL Editor

---

### ✅ Step 4: Verify Clean State

Run this query to confirm:

```sql
SELECT 
    'restaurant_tag_assignments' as table_name,
    COUNT(*) as row_count
FROM menuca_v3.restaurant_tag_assignments
UNION ALL
SELECT 
    'restaurant_tags' as table_name,
    COUNT(*) as row_count
FROM menuca_v3.restaurant_tags
UNION ALL
SELECT 
    'cuisine_types' as table_name,
    COUNT(*) as row_count
FROM menuca_v3.cuisine_types
UNION ALL
SELECT 
    'restaurant_cuisines' as table_name,
    COUNT(*) as row_count
FROM menuca_v3.restaurant_cuisines;
```

**Expected Results:**
- `restaurant_tag_assignments`: **0 rows** ✅
- `restaurant_tags`: **12 rows** (tags still exist)
- `cuisine_types`: **36 rows** (cuisines still exist)
- `restaurant_cuisines`: **960 rows** (cuisine assignments still exist)

---

## Files Created

| File | Status | Purpose |
|------|--------|---------|
| `restaurant_tags_reference.csv` | ✅ Created | Reference list of all 12 tags |
| `active_restaurants_with_cuisines.csv` | ⏳ Manual Export | List of 277 active restaurants |
| `export_active_restaurants.sql` | ✅ Created | SQL to export active restaurants |
| `export_all_tags.sql` | ✅ Created | SQL to export tags (alternative) |
| `clear_tag_assignments.sql` | ✅ Created | SQL to delete tag assignments |
| `export_data.ps1` | ✅ Created | PowerShell helper script |
| `RESET_TAG_ASSIGNMENTS_GUIDE.md` | ✅ Created | This file |

---

## What Remains After Deletion

### ✅ Data Preserved:
- ✅ **Restaurants:** All 961 restaurants (277 active, 36 pending, 648 suspended)
- ✅ **Restaurant Tags:** All 12 tag definitions
- ✅ **Cuisine Types:** All 36 cuisine types
- ✅ **Restaurant Cuisines:** All 960 cuisine assignments
- ✅ **All other restaurant data:** Contacts, locations, delivery zones, etc.

### ❌ Data Deleted:
- ❌ **Restaurant Tag Assignments:** 0 rows (was ~1,012)

---

## Next Steps After Reset

After clearing tag assignments, you can:

1. **Create a new master tagging file** based on:
   - `active_restaurants_with_cuisines.csv` (277 restaurants)
   - `delivery_pickup_csv.txt` (103 restaurants with Delivery/Pickup info)
   - `tags.txt` (your original research data)

2. **Develop a tagging strategy** for all 277 active restaurants:
   - Dietary tags (Vegan, Vegetarian, Gluten-Free, Halal, Kosher)
   - Service tags (Delivery, Pickup, Dine-In)
   - Atmosphere tags (Family Friendly)
   - Feature tags (Late Night)
   - Payment tags (Cash, Credit Card)

3. **Create new batch insertion scripts** with complete and accurate data

4. **Execute fresh tag assignments** with verified data

---

## Verification Checklist

Before proceeding to fresh tagging:

- [ ] `restaurant_tags_reference.csv` exists and contains 12 tags
- [ ] `active_restaurants_with_cuisines.csv` exported with 277 restaurants
- [ ] Confirmed deletion: `restaurant_tag_assignments` has 0 rows
- [ ] Verified preservation: `restaurant_tags` still has 12 rows
- [ ] Verified preservation: `restaurant_cuisines` still has 960 rows
- [ ] Ready to create new comprehensive tagging file

---

## Support Files Reference

### delivery_pickup_csv.txt
- 103 restaurants with Delivery/Pickup status
- Some restaurants may not be in active status
- Use as reference for service tags

### tags.txt
- Your original research on restaurant tags
- 114 restaurants with various tags
- Use as reference for comprehensive tagging

---

## Database Schema Remains Intact

The following schema objects remain unchanged:

**Tables:**
- `menuca_v3.restaurants` (961 rows)
- `menuca_v3.restaurant_tags` (12 rows)
- `menuca_v3.restaurant_tag_assignments` (**0 rows - cleared**)
- `menuca_v3.cuisine_types` (36 rows)
- `menuca_v3.restaurant_cuisines` (960 rows)

**Indexes:**
- All indexes remain intact

**Constraints:**
- All foreign keys remain intact
- Unique constraints remain intact

---

**Status:** Ready for Execution  
**Risk Level:** Medium (destructive operation)  
**Backup Required:** Yes (export CSV first)  
**Estimated Time:** 15 minutes total

