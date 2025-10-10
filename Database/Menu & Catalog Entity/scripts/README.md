# Menu & Catalog Data Extraction Scripts

**Purpose**: Convert SQL dump files to CSV format for staging table creation  
**Phase**: Pre-Phase 2 (Data Extraction)  
**Date**: 2025-01-08

---

## 🎯 Objective

Transform all 17 SQL dump files to CSV format while **excluding BLOB columns** identified in the BLOB analysis. This ensures:
1. Accurate staging table mapping
2. BLOB data handled separately in Phase 4
3. Clean CSV data for Supabase import

---

## 📋 BLOB Columns Excluded

| Table | Excluded Columns | Reason |
|-------|------------------|--------|
| `menuca_v1_menu` | `hideOnDays` | BLOB Case #1 - Day availability rules |
| `menuca_v1_menuothers` | `content` | BLOB Case #2 - Modifier pricing |
| `menuca_v1_ingredient_groups` | `item`, `price` | BLOB Case #3 - Ingredient lists with pricing |
| `menuca_v1_combo_groups` | `dish`, `options`, `group` | BLOB Case #4 - Combo configurations (3 BLOBs) |

**Total BLOB columns excluded**: 7 columns across 4 tables

---

## 🛠️ Scripts

### 1. `convert_dumps_to_csv.py` (RECOMMENDED)

**Python 3 script** - More robust SQL parsing

**Features**:
- Handles complex SQL INSERT statements
- Properly escapes CSV values
- Skips BLOB columns automatically
- Progress indicators
- Error handling and logging

**Requirements**:
- Python 3.7+
- No external dependencies (uses standard library)

**Usage**:
```bash
# From the scripts directory
python convert_dumps_to_csv.py

# Or from project root
python "Database/Menu & Catalog Entity/scripts/convert_dumps_to_csv.py"
```

---

### 2. `convert_all_dumps_to_csv.ps1` (ALTERNATIVE)

**PowerShell script** - For Windows environments

**Features**:
- Native Windows support
- Same BLOB exclusion logic
- CSV output with proper escaping
- Log file creation

**Requirements**:
- PowerShell 5.1+ or PowerShell Core 7+

**Usage**:
```powershell
# From the scripts directory
.\convert_all_dumps_to_csv.ps1

# Or from project root
& "Database\Menu & Catalog Entity\scripts\convert_all_dumps_to_csv.ps1"
```

---

## 📂 Directory Structure

```
Database/Menu & Catalog Entity/
├── dumps/                    # Source SQL dump files (17 files)
│   ├── menuca_v1_courses.sql
│   ├── menuca_v1_menu.sql
│   ├── menuca_v1_menuothers.sql
│   ├── menuca_v1_ingredients.sql
│   ├── menuca_v1_ingredient_groups.sql
│   ├── menuca_v1_combo_groups.sql
│   ├── menuca_v1_combos.sql
│   ├── menuca_v2_global_courses.sql
│   ├── menuca_v2_global_ingredients.sql
│   ├── menuca_v2_restaurants_courses.sql
│   ├── menuca_v2_restaurants_dishes.sql
│   ├── menuca_v2_restaurants_dishes_customization.sql
│   ├── menuca_v2_restaurants_ingredients.sql
│   ├── menuca_v2_restaurants_ingredient_groups.sql
│   ├── menuca_v2_restaurants_ingredient_groups_items.sql
│   ├── menuca_v2_restaurants_combo_groups.sql
│   └── menuca_v2_restaurants_combo_groups_items.sql
│
├── CSV/                      # Output CSV files (created by scripts)
│   ├── menuca_v1_courses.csv
│   ├── menuca_v1_menu.csv              # BLOB column excluded
│   ├── menuca_v1_menuothers.csv        # BLOB column excluded
│   ├── menuca_v1_ingredients.csv
│   ├── menuca_v1_ingredient_groups.csv # BLOB columns excluded
│   ├── menuca_v1_combo_groups.csv      # BLOB columns excluded
│   └── ... (all 17 CSV files)
│
└── scripts/                  # Conversion scripts (this directory)
    ├── README.md             # This file
    ├── convert_dumps_to_csv.py        # Python script (recommended)
    ├── convert_all_dumps_to_csv.ps1   # PowerShell script (alternative)
    └── conversion_log.txt             # Log file (created after run)
```

---

## ✅ Expected Output

After running either script:

1. **CSV directory created**: `Database/Menu & Catalog Entity/CSV/`
2. **17 CSV files generated** (one per dump file)
3. **Log file**: `conversion_log.txt` with details
4. **Console output**: Progress and summary

### Sample Console Output:
```
=== Menu & Catalog SQL to CSV Conversion ===
Dumps Directory: .../dumps
CSV Directory: .../CSV

Found 17 dump files

🔄 Processing: menuca_v1_courses
  📊 Columns: 8 (after excluding BLOBs)
    ✓ Column: id
    ✓ Column: name
    ✓ Column: restaurant
    ...
    → Processed 1000 rows...
    → Processed 2000 rows...
  ✅ Converted 12924 rows to CSV

🔄 Processing: menuca_v1_menu
  📋 Excluding BLOB columns: hideOnDays
  📊 Columns: 72 (after excluding BLOBs)
    ✓ Column: id
    ✓ Column: course
    ⏩ Skipping BLOB column: hideOnDays
    ...
  ✅ Converted 117666 rows to CSV

...

=== Conversion Summary ===
Total Files: 17
✅ Successful: 17
❌ Failed: 0

CSV files: .../CSV

🎉 All dumps converted successfully!
```

---

## 🔍 Validation

After conversion, verify:

1. **CSV file count**: Should have 17 CSV files
2. **Headers match**: Each CSV should have column headers
3. **BLOB columns absent**: Excluded columns should not appear in CSV
4. **Row counts**: Use `wc -l` (Linux/Mac) or PowerShell to count rows

### PowerShell Validation:
```powershell
# Count CSV files
Get-ChildItem "Database\Menu & Catalog Entity\CSV\*.csv" | Measure-Object

# Check row counts
Get-ChildItem "Database\Menu & Catalog Entity\CSV\*.csv" | ForEach-Object {
    $lineCount = (Get-Content $_.FullName | Measure-Object -Line).Lines
    [PSCustomObject]@{
        File = $_.Name
        Rows = $lineCount - 1  # Subtract header
    }
} | Format-Table -AutoSize
```

### Verify BLOB columns excluded:
```powershell
# Check menuca_v1_menu.csv does NOT have hideOnDays
$headers = (Get-Content "Database\Menu & Catalog Entity\CSV\menuca_v1_menu.csv" -First 1)
if ($headers -notmatch "hideOnDays") {
    Write-Host "✅ hideOnDays correctly excluded" -ForegroundColor Green
} else {
    Write-Host "❌ hideOnDays found in CSV!" -ForegroundColor Red
}
```

---

## 🐛 Troubleshooting

### Issue: "No SQL dump files found"
**Solution**: Ensure you're running from the correct directory or update paths

### Issue: "Permission denied"
**Solution**: 
- Python: `chmod +x convert_dumps_to_csv.py`
- PowerShell: Run as Administrator or adjust execution policy

### Issue: "UnicodeDecodeError"
**Solution**: Script handles encoding automatically, but ensure SQL dumps are UTF-8

### Issue: "Row count mismatch"
**Solution**: This is expected when excluding BLOB columns - CSV will have fewer columns than SQL

---

## 📊 Next Steps

After CSV conversion:

1. ✅ **Phase 2**: Create staging tables matching CSV headers
2. ✅ **Phase 2**: Import CSV files to staging via Supabase
3. ⏳ **Phase 3**: Data quality assessment
4. ⏳ **Phase 4**: BLOB deserialization (handle excluded columns)
5. ⏳ **Phase 5**: Transform and load to menuca_v3

---

## 📝 Notes

- **BLOB data NOT lost**: Excluded columns remain in SQL dumps for Phase 4 processing
- **CSV for staging only**: These CSV files are for accurate staging table creation
- **Phase 4 will deserialize BLOBs**: Python scripts will parse BLOB data separately
- **Clean data approach**: Staging → Transform → Validate → Load

---

**Status**: ⏳ Ready to run  
**Next Action**: Execute `convert_dumps_to_csv.py`  
**Estimated Time**: 2-5 minutes for all 17 files




