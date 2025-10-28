# V2 Export Quick Start Checklist

## ✅ 5-Minute Setup

### 1️⃣ Find Export Path (1 minute)

Open MySQL Workbench and run:
```sql
SHOW VARIABLES LIKE 'secure_file_priv';
```

Copy the path (e.g., `C:\ProgramData\MySQL\MySQL Server 8.0\Uploads`)

---

### 2️⃣ Edit SQL File (2 minutes)

1. Open: `Database/V2_EXPORT_AUTO_CSV.txt`
2. Find & Replace: `YOUR_EXPORT_PATH_HERE` → Your actual path
3. **Use forward slashes:** `C:/ProgramData/...` (not `C:\ProgramData\...`)
4. Save file

---

### 3️⃣ Run Queries (2 minutes)

In MySQL Workbench, run all 7 queries from the modified file:
- Query 1: Courses
- Query 2: Dishes ⭐
- Query 3: Ingredient Groups
- Query 4: Ingredients ⭐
- Query 5: Dish Customizations ⭐
- Query 6: Combo Groups
- Query 7: Combo Items

---

### 4️⃣ Verify & Copy

Check your export directory for 7 CSV files:
```
✓ v2_18_restaurants_courses.csv
✓ v2_18_restaurants_dishes.csv
✓ v2_18_ingredient_groups.csv
✓ v2_18_ingredients.csv
✓ v2_18_dish_customizations.csv
✓ v2_18_combo_groups.csv
✓ v2_18_combo_items.csv
```

Copy them to your working directory. Done! 🎉

---

## 🚨 Common Issues

| Error | Fix |
|-------|-----|
| `secure-file-priv error` | Use EXACT path from Step 1, with forward slashes |
| `File already exists` | Delete existing CSV from export folder |
| `Access denied` | Run MySQL Workbench as Administrator (Windows) |
| `NULL secure_file_priv` | Use GUI export (see full guide) |

---

## 📊 What You're Exporting

**18 live restaurants** currently missing from V3:
- All Out Burger locations
- Kirkwood Pizza
- River Pizza  
- Wandee Thai
- La Nawab
- And 12 more...

**Total Impact:**
- ~2,000 menu items
- ~3,000 customization rules
- $36k/month revenue
- 18 restaurants back online

---

## 📖 Need More Help?

See the full guide: `Database/V2_EXPORT_GUIDE.md`

---

## Example: Correct Path Format

✅ **CORRECT:**
```sql
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/v2_18_restaurants_courses.csv'
```

❌ **WRONG:**
```sql
INTO OUTFILE 'C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\v2_18_restaurants_courses.csv'
```

---

That's it! 5 minutes from start to finish. Let's get these restaurants back online! 🚀

