# Database Export Summary

**Date:** 2025-10-20  
**Total Restaurants:** 313 (277 active + 36 pending)  
**Cuisine Assignments:** 960 restaurants have cuisines assigned

---

## ✅ What I've Completed

### 1. Exported Tag Definitions ✅
**File:** `restaurant_tags_reference.csv`
- 12 tags documented
- Categories: dietary, service, atmosphere, feature, payment

### 2. Exported Cuisine Distribution ✅
**File:** `cuisine_distribution_summary.csv`
- 36 cuisine types
- 960 total assignments
- Breakdown by primary/secondary

### 3. Created Export Scripts ✅
**Files:**
- `export_restaurants_with_cuisines.sql` - Complete export query
- `EXPORT_INSTRUCTIONS.md` - Step-by-step guide

---

## 📊 Cuisine Assignment Analysis

### Coverage

| Category | Count | Percentage |
|----------|-------|------------|
| **Restaurants with cuisines** | 960 | 100% (of categorized) |
| **Total active & pending** | 313 | - |
| **Primary cuisine assignments** | 959 | 99.9% |
| **Secondary cuisine assignments** | 1 | 0.1% |

### Top 10 Cuisines

| Rank | Cuisine | Restaurants | Type |
|------|---------|-------------|------|
| 1 | Pizza | 269 | 28.0% |
| 2 | American | 115 | 12.0% |
| 3 | Italian | 93 | 9.7% |
| 4 | Chinese | 74 | 7.7% |
| 5 | Lebanese | 71 | 7.4% |
| 6 | Indian | 59 | 6.1% |
| 7 | Vietnamese | 49 | 5.1% |
| 8 | Sushi | 38 | 4.0% |
| 9 | Greek | 37 | 3.9% |
| 10 | Thai | 27 | 2.8% |

**Top 10 Total:** 832 restaurants (86.7% of all cuisine assignments)

### Notable Observations

1. **Almost all primary cuisines** - Only 1 restaurant has a secondary cuisine
2. **Pizza dominates** - 269 pizza restaurants (28% of all)
3. **Non-restaurant entities** - 7 entities with special categories:
   - 5 Liquor Stores
   - 1 POS System
   - 1 Convenience Store

---

## ⏳ What You Need to Do

### Step 1: Export Full Restaurant List with Cuisines

**Why Manual Export?**
- 313 restaurants is too many for MCP to handle in one query
- Need complete data with all columns

**How to Export:**

1. Open Supabase SQL Editor:
   ```
   https://supabase.com/dashboard/project/nthpbtdjhhnwfxqsxbvy/sql/new
   ```

2. Copy query from `export_restaurants_with_cuisines.sql`

3. Click "Run" → "Download CSV"

4. Save as: `active_pending_restaurants_with_cuisines.csv`

**What You'll Get:**
```csv
id,name,status,primary_cuisine,primary_cuisine_slug,secondary_cuisines,all_cuisines
7,Imilio's Pizzeria,active,Pizza,pizza,,Pizza
8,Lucky Star Chinese Food,active,Chinese,chinese,,Chinese
19,Milano INACTIVE,active,Italian,italian,"Pizza, American","Italian, Pizza, American"
```

---

## 📁 Files Created in @Refactoring docs/

| File | Status | Size | Purpose |
|------|--------|------|---------|
| `restaurant_tags_reference.csv` | ✅ Complete | 12 rows | Tag definitions |
| `cuisine_distribution_summary.csv` | ✅ Complete | 36 rows | Cuisine breakdown |
| `export_restaurants_with_cuisines.sql` | ✅ Ready | - | Export query |
| `EXPORT_INSTRUCTIONS.md` | ✅ Complete | - | Export guide |
| `DATABASE_EXPORT_SUMMARY.md` | ✅ Complete | - | This file |
| `active_restaurants_with_cuisines.csv` | ❌ Outdated | 277 rows | NO CUISINES - Replace |
| `active_pending_restaurants_with_cuisines.csv` | ⏳ Awaiting Export | 313 rows | Target file |

---

## 🗑️ Tag Assignment Deletion Status

**Current State:**
- Tag assignments: ~1,012 (need to delete manually)
- Tag definitions: 12 (preserved)
- Cuisine assignments: 960 (preserved)

**To Delete All Tag Assignments:**

Run in Supabase SQL Editor:
```sql
DELETE FROM menuca_v3.restaurant_tag_assignments;
```

**Verify deletion:**
```sql
SELECT COUNT(*) FROM menuca_v3.restaurant_tag_assignments;
```
Expected: 0 rows

---

## 🎯 Next Steps After Export

Once you have `active_pending_restaurants_with_cuisines.csv`:

### 1. Review Data Quality
- Verify cuisine assignments are correct
- Check for restaurants missing cuisines
- Identify non-restaurant entities (POS, liquor stores)

### 2. Delete Tag Assignments
- Run DELETE command in SQL Editor
- Verify table is empty (0 rows)

### 3. Create Master Tagging File
Combine data from:
- ✅ `active_pending_restaurants_with_cuisines.csv` (313 restaurants with cuisines)
- ✅ `delivery_pickup_csv.txt` (103 restaurants with service data)
- ✅ `tags.txt` (114 restaurants with tag research)
- ✅ `restaurant_tags_reference.csv` (12 available tags)

### 4. Develop Tagging Strategy

**For each of 313 restaurants, determine:**

**Dietary Tags:**
- Vegan Options (tag 3)
- Vegetarian Options (tag 2)
- Gluten-Free Options (tag 4)
- Halal (tag 1)
- Kosher (tag 12)

**Service Tags:**
- Delivery (tag 5)
- Pickup (tag 6)
- Dine-In (tag 7)

**Other Tags:**
- Family Friendly (tag 8)
- Late Night (tag 9)
- Accepts Cash (tag 10)
- Accepts Credit Card (tag 11)

### 5. Create Comprehensive Tag Assignment SQL

Based on the master file:
- Generate INSERT statements for all 313 restaurants
- Include all appropriate tags per restaurant
- Use `ON CONFLICT DO NOTHING` for safety

---

## 📊 Database State Summary

| Table | Current Rows | After Deletion | Notes |
|-------|--------------|----------------|-------|
| `restaurants` | 961 | 961 | Unchanged |
| `restaurant_tags` | 12 | 12 | Unchanged |
| `restaurant_tag_assignments` | 1,012 | **0** | Will be deleted |
| `cuisine_types` | 36 | 36 | Unchanged |
| `restaurant_cuisines` | 960 | 960 | Unchanged |

**Active restaurants:** 277  
**Pending restaurants:** 36  
**Suspended restaurants:** 648  
**Total:** 961

---

## ✅ Verification Checklist

Before proceeding with fresh tagging:

- [ ] Exported `active_pending_restaurants_with_cuisines.csv` (313 restaurants)
- [ ] Verified cuisine data is correct
- [ ] Deleted all tag assignments (0 rows in `restaurant_tag_assignments`)
- [ ] Have `restaurant_tags_reference.csv` (12 tags)
- [ ] Have `cuisine_distribution_summary.csv` (36 cuisines)
- [ ] Ready to create master tagging file

---

## 🚀 Estimated Timeline

| Task | Time | Status |
|------|------|--------|
| Export restaurants with cuisines | 3 min | ⏳ Pending |
| Delete tag assignments | 2 min | ⏳ Pending |
| Create master tagging file | 30-60 min | ⏳ Pending |
| Generate tag assignment SQL | 15 min | ⏳ Pending |
| Execute tag assignments | 10 min | ⏳ Pending |
| **Total** | **1-1.5 hours** | |

---

**Status:** Ready for Manual Export  
**Next Action:** Export restaurants with cuisines using SQL Editor  
**Documentation:** See `EXPORT_INSTRUCTIONS.md`

