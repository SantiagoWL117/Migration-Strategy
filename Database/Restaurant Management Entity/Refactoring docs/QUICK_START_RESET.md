# Quick Start: Reset Tag Assignments

**What I've Done:**

## ✅ Completed Tasks

### 1. Created Tag Reference CSV ✅
**File:** `restaurant_tags_reference.csv`
- Contains all 12 tags in the system
- Columns: tag_id, tag_name, tag_slug, category, description

### 2. Created SQL Export Script ✅
**File:** `export_active_restaurants.sql`
- Query to export all 277 active restaurants with cuisine info
- Ready to run in Supabase SQL Editor

### 3. Created Deletion Script ✅
**File:** `clear_tag_assignments.sql`
- SQL to safely delete all tag assignments
- Includes verification steps

### 4. Created Helper Files ✅
- `export_data.ps1` - PowerShell helper
- `export_all_tags.sql` - Alternative tag export
- `RESET_TAG_ASSIGNMENTS_GUIDE.md` - Complete instructions

---

## ⏳ What You Need to Do

### Step 1: Export Active Restaurants (5 minutes)

1. Open: https://supabase.com/dashboard/project/nthpbtdjhhnwfxqsxbvy/sql/new
2. Open file: `export_active_restaurants.sql`
3. Copy entire contents → Paste in SQL Editor → Click "Run"
4. Click "Download CSV" → Save as `active_restaurants_with_cuisines.csv`

### Step 2: Delete All Tag Assignments (2 minutes)

⚠️ **Warning:** This deletes 1,012 tag assignments!

Run in SQL Editor:
```sql
DELETE FROM menuca_v3.restaurant_tag_assignments;
```

Verify (should return 0):
```sql
SELECT COUNT(*) FROM menuca_v3.restaurant_tag_assignments;
```

---

## 📊 Summary of What Will Happen

### Before Reset:
- Active restaurants: 277
- Tagged restaurants: 208 (61%)
- Untagged restaurants: 107 (39%)
- Total tag assignments: 1,012

### After Reset:
- Active restaurants: 277 (unchanged)
- Tagged restaurants: **0** 
- Untagged restaurants: **277** (100%)
- Total tag assignments: **0**

### Data Preserved:
- ✅ All restaurants (961 total)
- ✅ All restaurant tags (12 definitions)
- ✅ All cuisine types (36)
- ✅ All cuisine assignments (960)
- ✅ All contacts, locations, delivery zones

### Data Deleted:
- ❌ Tag assignments (1,012 rows)

---

## 🎯 Next Steps After Reset

1. **Review the exported CSV** (`active_restaurants_with_cuisines.csv`)
2. **Create a master tagging file** for all 277 active restaurants
3. **Include comprehensive tag data:**
   - Dietary (Vegan, Vegetarian, Halal, etc.)
   - Service (Delivery, Pickup, Dine-In)
   - Atmosphere (Family Friendly)
   - Payment (Cash, Credit Card)
4. **Create new batch SQL scripts** with accurate data
5. **Execute fresh tagging** with confidence

---

## 📁 Files in This Directory

| File | Purpose | Status |
|------|---------|--------|
| `restaurant_tags_reference.csv` | Tag definitions (12 tags) | ✅ Ready |
| `export_active_restaurants.sql` | Export query | ✅ Ready to Run |
| `clear_tag_assignments.sql` | Delete query | ✅ Ready to Run |
| `RESET_TAG_ASSIGNMENTS_GUIDE.md` | Detailed guide | ✅ Reference |
| `QUICK_START_RESET.md` | This file | ✅ Current |
| `delivery_pickup_csv.txt` | Existing reference (103 restaurants) | 📄 Reference |
| `tags.txt` | Existing research (114 restaurants) | 📄 Reference |

---

## ⚠️ Important Notes

1. **Backup First:** Export the active restaurants CSV before deletion
2. **Irreversible:** The deletion cannot be undone
3. **Safe Operation:** Only tag assignments are deleted, not restaurants or tag definitions
4. **Fresh Start:** You'll have a clean slate to create accurate, comprehensive tagging

---

## Need Help?

Refer to `RESET_TAG_ASSIGNMENTS_GUIDE.md` for:
- Detailed step-by-step instructions
- Multiple execution methods
- Verification queries
- Troubleshooting

---

**Ready to proceed? Start with Step 1: Export Active Restaurants**

