# V2 Database Export Guide - Auto CSV Export

## Overview

This guide explains how to export data from your V2 Production MySQL database directly to CSV files on your local computer using MySQL Workbench's `INTO OUTFILE` feature.

## Files Created

1. **find-mysql-export-path.ps1** - PowerShell helper script (in root directory)
2. **V2_EXPORT_AUTO_CSV.txt** - Modified SQL queries with INTO OUTFILE (in Database/ directory)

---

## Step-by-Step Instructions

### Step 1: Find Your MySQL Export Directory

1. Open **MySQL Workbench**
2. Connect to your V2 Production database
3. Run this query:

```sql
SHOW VARIABLES LIKE 'secure_file_priv';
```

4. Copy the directory path from the result. Examples:
   - Windows: `C:\ProgramData\MySQL\MySQL Server 8.0\Uploads`
   - Mac: `/usr/local/mysql-8.0/data`
   - Linux: `/var/lib/mysql-files/`

**OR** run the PowerShell helper script:

```powershell
.\find-mysql-export-path.ps1
```

### Step 2: Prepare the SQL File

1. Open `Database/V2_EXPORT_AUTO_CSV.txt` in a text editor
2. Find and replace **ALL** instances of `YOUR_EXPORT_PATH_HERE` with your actual path
3. **CRITICAL:** Use **forward slashes** even on Windows!
   - ✅ Correct: `C:/ProgramData/MySQL/MySQL Server 8.0/Uploads`
   - ❌ Wrong: `C:\ProgramData\MySQL\MySQL Server 8.0\Uploads`
4. Save the file (optionally rename to `.sql` extension)

### Step 3: Run Verification Queries (Optional but Recommended)

Before exporting, run the verification queries at the bottom of the file to confirm data exists:

```sql
-- Check how many courses exist for these restaurants
SELECT 
  restaurant_id,
  COUNT(*) AS course_count
FROM restaurants_courses
WHERE restaurant_id IN (1635,1636,1637,1639,1641,1642,1654,1657,1658,1659,1664,1665,1668,1673,1674,1676,1677,1678)
GROUP BY restaurant_id
ORDER BY restaurant_id;
```

You should see ~14-16 courses per restaurant.

### Step 4: Run Export Queries

Run **each of the 7 queries** in MySQL Workbench one at a time:

1. **Query 1** - Restaurant Courses (~150-200 rows)
2. **Query 2** - Restaurant Dishes (~1,500-2,500 rows) ⭐ CRITICAL
3. **Query 3** - Ingredient Groups (~100-200 rows)
4. **Query 4** - Ingredients (~500-1,500 rows) ⭐ CRITICAL
5. **Query 5** - Dish Customizations (~2,000-5,000 rows) ⭐ CRITICAL
6. **Query 6** - Combo Groups (~50-100 rows)
7. **Query 7** - Combo Items (~200-500 rows)

Each query will create a CSV file in your export directory.

### Step 5: Locate Your CSV Files

1. Navigate to your MySQL export directory
2. You should see 7 new CSV files:
   - `v2_18_restaurants_courses.csv`
   - `v2_18_restaurants_dishes.csv`
   - `v2_18_ingredient_groups.csv`
   - `v2_18_ingredients.csv`
   - `v2_18_dish_customizations.csv`
   - `v2_18_combo_groups.csv`
   - `v2_18_combo_items.csv`

### Step 6: Copy Files to Your Working Directory

Copy all 7 CSV files to your working directory for further processing.

---

## Troubleshooting

### Error: "The MySQL server is running with the --secure-file-priv option"

**Cause:** The path you're using doesn't match MySQL's allowed export directory.

**Solution:**
1. Run `SHOW VARIABLES LIKE 'secure_file_priv';` again
2. Copy the EXACT path shown
3. Make sure you're using forward slashes (`/`)

---

### Error: "File already exists"

**Cause:** A CSV file with that name already exists in the export directory.

**Solution:**
1. Navigate to the export directory
2. Delete the existing CSV file
3. Re-run the query

**OR** modify the filename in the query:
```sql
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/v2_18_restaurants_courses_v2.csv'
```

---

### Error: "Access denied"

**Cause:** MySQL doesn't have write permissions to the directory.

**Solution:**
1. Check that the directory exists
2. On Windows: Run MySQL Workbench as Administrator
3. On Linux/Mac: Check directory permissions:
   ```bash
   sudo chmod 777 /var/lib/mysql-files/
   ```

---

### Error: "Can't create/write to file"

**Cause:** Path syntax is incorrect or directory doesn't exist.

**Solution:**
1. Verify the directory exists in File Explorer
2. Make sure you're using forward slashes (`/`) not backslashes (`\`)
3. Check for typos in the path

---

### Result shows "NULL" for secure_file_priv

**Cause:** File export operations are completely disabled in MySQL.

**Solution:** You'll need to use the GUI export method:

#### Alternative: MySQL Workbench GUI Export

1. Run the SELECT query WITHOUT the `INTO OUTFILE` clause:
   ```sql
   SELECT 
     id,
     restaurant_id,
     language_id,
     global_course_id,
     name,
     description,
     display_order,
     available_for,
     time_period,
     enabled,
     added_by,
     added_at,
     disabled_by,
     disabled_at
   FROM restaurants_courses
   WHERE restaurant_id IN (1635,1636,1637,1639,1641,1642,1654,1657,1658,1659,1664,1665,1668,1673,1674,1676,1677,1678)
   ORDER BY restaurant_id, display_order;
   ```

2. In the result grid, click the **Export** icon (disk icon)
3. Choose "Export recordset to an external file"
4. Set format to "CSV"
5. Choose your destination and filename
6. Configure:
   - Field separator: `,`
   - Enclose strings in: `"`
   - Line separator: `\n`

Repeat for all 7 queries.

---

## What This Exports

### Critical Data for 18 Live Restaurants

These restaurants are currently taking orders on menu.ca but have NO menu data in V3:

1. All Out Burger Gladstone (1635)
2. All Out Burger Montreal Rd (1636)
3. Kirkwood Pizza (1637)
4. River Pizza (1639)
5. Wandee Thai (1641)
6. La Nawab (1642)
7. Cosenza (1654)
8. Cuisine Bombay Indienne (1657)
9. Chicco Shawarma Cantley (1658)
10. Chicco Pizza & Shawarma Buckingham (1659)
11. Chicco Pizza St-Louis (1664)
12. Zait and Zaatar (1665)
13. Little Gyros Greek Grill (1668)
14. Pizza Marie (1673)
15. Capri Pizza (1674)
16. Routine Poutine (1676)
17. Chef Rad Halal Pizza & Burgers (1677)
18. Al's Drive In (1678)

### Revenue Impact

- **Monthly Revenue:** $36,000 (18 restaurants × $2,000/month avg)
- **Menu Items:** ~1,500-3,000 dishes
- **Modifiers:** Critical for order customization
- **Migration Coverage:** Increases from 95.8% to 99%+

---

## Expected File Sizes

| File | Rows | Importance |
|------|------|------------|
| v2_18_restaurants_courses.csv | ~150-200 | Required |
| v2_18_restaurants_dishes.csv | ~1,500-2,500 | ⭐ CRITICAL |
| v2_18_ingredient_groups.csv | ~100-200 | ⭐ CRITICAL |
| v2_18_ingredients.csv | ~500-1,500 | ⭐ CRITICAL |
| v2_18_dish_customizations.csv | ~2,000-5,000 | ⭐ CRITICAL |
| v2_18_combo_groups.csv | ~50-100 | Optional |
| v2_18_combo_items.csv | ~200-500 | Optional |

---

## Next Steps

After successfully exporting all CSV files:

1. Verify all 7 files were created
2. Check file sizes are reasonable (not 0 bytes)
3. Open one file in Excel/text editor to verify data looks correct
4. Upload all files for import into V3 staging
5. Contact Brian for the import process

---

## Quick Reference: Common Paths

### Windows
- MySQL 8.0: `C:/ProgramData/MySQL/MySQL Server 8.0/Uploads`
- MySQL 8.1: `C:/ProgramData/MySQL/MySQL Server 8.1/Uploads`
- XAMPP: `C:/xampp/mysql/data`
- WAMP: `C:/wamp64/tmp`

### Mac
- Homebrew: `/usr/local/mysql/data`
- Standard: `/usr/local/mysql-8.0/data`

### Linux
- Ubuntu/Debian: `/var/lib/mysql-files/`
- CentOS/RHEL: `/var/lib/mysql-files/`

---

## Support

Questions? Contact Brian or refer to:
- Original script comments
- MySQL documentation: https://dev.mysql.com/doc/refman/8.0/en/select-into.html

