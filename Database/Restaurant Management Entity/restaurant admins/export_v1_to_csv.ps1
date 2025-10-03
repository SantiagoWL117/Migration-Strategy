# ============================================================================
# Export V1 restaurant_admins to PostgreSQL-compatible CSV
# ============================================================================
# Purpose: Use MySQL to export restaurant_admins data to CSV for PostgreSQL import
# Requirements: MySQL client installed and accessible via PATH
# Author: Migration Script
# Date: 2025-10-02
# ============================================================================

param(
    [string]$MySQLUser = "root",
    [string]$MySQLPassword = "",
    [string]$MySQLHost = "localhost",
    [string]$MySQLDatabase = "menuca_v1",
    [string]$OutputDir = "Database\Restaurant Management Entity\restaurant admins\dumps"
)

$ErrorActionPreference = "Stop"

Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "  V1 Restaurant Admins Export to CSV" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""

# Check if MySQL client is available
try {
    $mysqlVersion = mysql --version 2>&1
    Write-Host "✅ MySQL client found: $mysqlVersion" -ForegroundColor Green
}
catch {
    Write-Host "❌ MySQL client not found in PATH" -ForegroundColor Red
    Write-Host "   Please install MySQL client or add it to your PATH" -ForegroundColor Yellow
    Write-Host "   Download from: https://dev.mysql.com/downloads/mysql/" -ForegroundColor Yellow
    exit 1
}

# Create output directory if it doesn't exist
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

$outputFile = Join-Path $OutputDir "v1_restaurant_admins_export.csv"
Write-Host "📂 Output file: $outputFile" -ForegroundColor Yellow
Write-Host ""

# Prepare MySQL password argument
$passwordArg = if ($MySQLPassword) { "-p$MySQLPassword" } else { "" }

# SQL query to export data
$query = @"
SELECT 
  id AS legacy_admin_id,
  restaurant AS legacy_v1_restaurant_id,
  COALESCE(user_type, 'r') AS user_type,
  fname,
  lname,
  email,
  password AS password_hash,
  lastlogin,
  loginCount AS login_count,
  activeUser AS active_user,
  sendStatement AS send_statement,
  HEX(allowed_restaurants) AS allowed_restaurants_hex,
  NULL AS created_at,
  NULL AS updated_at
FROM restaurant_admins
ORDER BY id
"@

Write-Host "🔄 Exporting data from MySQL..." -ForegroundColor Cyan
Write-Host ""

try {
    # Export using mysql client
    # Note: We use --batch for tab-separated output, then convert to CSV
    $tempFile = "$outputFile.tmp"
    
    $mysqlCmd = "mysql -h $MySQLHost -u $MySQLUser $passwordArg $MySQLDatabase -e `"$query`" --batch"
    
    Write-Host "📊 Executing query..." -ForegroundColor Yellow
    
    # Execute and save to temp file
    if ($MySQLPassword) {
        mysql -h $MySQLHost -u $MySQLUser -p$MySQLPassword $MySQLDatabase -e $query --batch | Out-File -FilePath $tempFile -Encoding UTF8
    }
    else {
        mysql -h $MySQLHost -u $MySQLUser $MySQLDatabase -e $query --batch | Out-File -FilePath $tempFile -Encoding UTF8
    }
    
    # Convert tab-separated to CSV
    Write-Host "📝 Converting to CSV format..." -ForegroundColor Yellow
    $content = Get-Content -Path $tempFile
    $csvContent = $content | ForEach-Object {
        $_ -replace "`t", ","
    }
    $csvContent | Out-File -FilePath $outputFile -Encoding UTF8
    
    # Clean up temp file
    Remove-Item -Path $tempFile -ErrorAction SilentlyContinue
    
    Write-Host "✅ Export complete!" -ForegroundColor Green
    Write-Host ""
    
    # Count records
    $recordCount = (Get-Content $outputFile | Measure-Object -Line).Lines - 1
    Write-Host "📊 Exported $recordCount records" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "📝 Next steps:" -ForegroundColor Cyan
    Write-Host "   1. Review the CSV file: $outputFile" -ForegroundColor White
    Write-Host "   2. Load into PostgreSQL staging table:" -ForegroundColor White
    Write-Host ""
    Write-Host "      psql -U postgres -d your_database -f step1_create_staging_table.sql" -ForegroundColor Gray
    Write-Host ""
    Write-Host "      \COPY staging.v1_restaurant_admin_users (" -ForegroundColor Gray
    Write-Host "        legacy_admin_id, legacy_v1_restaurant_id, user_type," -ForegroundColor Gray
    Write-Host "        fname, lname, email, password_hash, lastlogin," -ForegroundColor Gray
    Write-Host "        login_count, active_user, send_statement," -ForegroundColor Gray
    Write-Host "        allowed_restaurants, created_at, updated_at" -ForegroundColor Gray
    Write-Host "      ) FROM '$outputFile' WITH (FORMAT csv, HEADER true);" -ForegroundColor Gray
    Write-Host ""
    Write-Host "   3. Run cleanup: psql -U postgres -d your_database -f step1b_cleanup_staging.sql" -ForegroundColor White
    Write-Host ""
    
    Write-Host "⚠️  Note: allowed_restaurants is HEX-encoded for CSV compatibility" -ForegroundColor Yellow
    Write-Host "   It will be decoded during Step 5 (multi-restaurant access migration)" -ForegroundColor Yellow
    Write-Host ""
    
}
catch {
    Write-Host "❌ Error during export:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 Troubleshooting:" -ForegroundColor Yellow
    Write-Host "   - Verify MySQL credentials" -ForegroundColor White
    Write-Host "   - Check database name: $MySQLDatabase" -ForegroundColor White
    Write-Host "   - Ensure restaurant_admins table exists" -ForegroundColor White
    Write-Host ""
    Write-Host "   Retry with parameters:" -ForegroundColor White
    Write-Host "   .\export_v1_to_csv.ps1 -MySQLUser 'root' -MySQLPassword 'yourpass' -MySQLDatabase 'menuca_v1'" -ForegroundColor Gray
    Write-Host ""
    exit 1
}

Write-Host "============================================================================" -ForegroundColor Cyan




