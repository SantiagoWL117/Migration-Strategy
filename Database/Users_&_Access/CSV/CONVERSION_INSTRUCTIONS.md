# CSV Conversion Instructions for Users & Access Tables

## Overview
This guide provides step-by-step instructions to convert the remaining 9 SQL dumps to CSV format with UTF-8 encoding and data integrity preserved.

## Files to Convert
1. ✅ menuca_v2_admin_users.sql
2. ✅ menuca_v2_admin_users_restaurants.sql
3. ✅ menuca_v2_ci_sessions.sql (contains BLOB - text-based session data, safe to export)
4. ✅ menuca_v2_login_attempts.sql
5. ✅ menuca_v2_reset_codes.sql
6. ✅ menuca_v2_site_users_autologins.sql
7. ✅ menuca_v2_site_users_delivery_addresses.sql
8. ✅ menuca_v2_site_users_favorite_restaurants.sql
9. ✅ menuca_v2_site_users_fb.sql

## Method: Using MySQL Workbench's SELECT INTO OUTFILE

### Step 1: Open MySQL Workbench
1. Launch MySQL Workbench
2. Connect to your `menuca_v2` database

### Step 2: Run Conversion Queries
Open the file: `CONVERSION_QUERIES.sql` in this directory and execute each query one by one.

**Important Notes:**
- Each query exports to: `C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/`
- UTF-8 encoding is used to preserve special characters
- Comma-delimited with quote enclosure
- If a file already exists, delete it first or the query will fail

### Step 3: Copy Files to Project Directory
After all exports complete, run this PowerShell command:

```powershell
cd "C:\Users\santi\Menu.ca\Legacy Database\Migration Strategy"
Copy-Item "C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\menuca_v2_*.csv" "Database\Users_&_Access\CSV\" -Force
```

### Step 4: Add Headers to CSV Files
Run this PowerShell script to add column headers to each CSV file:

```powershell
cd "C:\Users\santi\Menu.ca\Legacy Database\Migration Strategy"

# Get table structure and add headers
$tables = @(
    "menuca_v2_admin_users",
    "menuca_v2_admin_users_restaurants",
    "menuca_v2_ci_sessions",
    "menuca_v2_login_attempts",
    "menuca_v2_reset_codes",
    "menuca_v2_site_users_autologins",
    "menuca_v2_site_users_delivery_addresses",
    "menuca_v2_site_users_favorite_restaurants",
    "menuca_v2_site_users_fb"
)

foreach ($table in $tables) {
    $csvPath = "Database\Users_&_Access\CSV\$table.csv"
    if (Test-Path $csvPath) {
        Write-Host "Processing: $table.csv" -ForegroundColor Yellow
        
        # You'll need to add the appropriate header for each table
        # Run DESCRIBE in MySQL first to get column names
        # Then prepend the header to the CSV file
        
        Write-Host "  File found" -ForegroundColor Green
    }
}
```

## Data Integrity Checklist

After conversion, verify:

- [ ] All 9 CSV files created in `Database\Users_&_Access\CSV\`
- [ ] UTF-8 encoding preserved (check special characters)
- [ ] Record counts match original tables
- [ ] No data truncation or corruption
- [ ] BLOB field in ci_sessions exported as text (readable session data)

## Table Structures Reference

### 1. menuca_v2_admin_users
```sql
DESCRIBE menuca_v2.admin_users;
```

### 2. menuca_v2_admin_users_restaurants
```sql
DESCRIBE menuca_v2.admin_users_restaurants;
```

### 3. menuca_v2_ci_sessions
```sql
DESCRIBE menuca_v2.ci_sessions;
```
**Note:** Contains BLOB field `data` with text-based session information. Safe to export.

### 4. menuca_v2_login_attempts
```sql
DESCRIBE menuca_v2.login_attempts;
```

### 5. menuca_v2_reset_codes
```sql
DESCRIBE menuca_v2.reset_codes;
```

### 6. menuca_v2_site_users_autologins
```sql
DESCRIBE menuca_v2.site_users_autologins;
```

### 7. menuca_v2_site_users_delivery_addresses
```sql
DESCRIBE menuca_v2.site_users_delivery_addresses;
```

### 8. menuca_v2_site_users_favorite_restaurants
```sql
DESCRIBE menuca_v2.site_users_favorite_restaurants;
```

### 9. menuca_v2_site_users_fb
```sql
DESCRIBE menuca_v2.site_users_fb;
```

## Troubleshooting

### Error: File exists
**Solution:** Delete the existing file in the Uploads directory first:
```sql
-- Check secure_file_priv path
SHOW VARIABLES LIKE 'secure_file_priv';
```

### Error: Access denied
**Solution:** Ensure MySQL has write permissions to the secure_file_priv directory.

### Error: Unicode encoding issues
**Solution:** The queries already use `CHARACTER SET utf8mb4`. If issues persist, use the temporary table method with `CONVERT()` function as shown in previous conversions.

## Next Steps

After all conversions are complete:
1. Verify all 9 files exist and have data
2. Check for any files that need to be split (> 100 MB for GitHub)
3. Add appropriate headers to each CSV file
4. Commit to git repository

## Status Tracking

- [ ] menuca_v2_admin_users.csv
- [ ] menuca_v2_admin_users_restaurants.csv
- [ ] menuca_v2_ci_sessions.csv
- [ ] menuca_v2_login_attempts.csv
- [ ] menuca_v2_reset_codes.csv
- [ ] menuca_v2_site_users_autologins.csv
- [ ] menuca_v2_site_users_delivery_addresses.csv
- [ ] menuca_v2_site_users_favorite_restaurants.csv
- [ ] menuca_v2_site_users_fb.csv

