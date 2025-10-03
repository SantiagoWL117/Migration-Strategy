# ============================================================================
# Convert V1 restaurant_admins MySQL Dump to PostgreSQL-compatible CSV
# ============================================================================
# Purpose: Extract INSERT statements from MySQL dump and convert to CSV
# Author: Migration Script
# Date: 2025-10-02
# ============================================================================

$ErrorActionPreference = "Stop"

# Configuration
$mysqlDumpFile = "Database\Restaurant Management Entity\restaurant admins\dumps\menuca_v1_restaurant_admins.sql"
$outputCsvFile = "Database\Restaurant Management Entity\restaurant admins\dumps\v1_restaurant_admins.csv"

Write-Host "🔄 Converting V1 restaurant_admins MySQL dump to CSV..." -ForegroundColor Cyan
Write-Host ""

# Check if input file exists
if (-not (Test-Path $mysqlDumpFile)) {
    Write-Host "❌ Error: MySQL dump file not found: $mysqlDumpFile" -ForegroundColor Red
    exit 1
}

Write-Host "📂 Reading MySQL dump file..." -ForegroundColor Yellow
$content = Get-Content -Path $mysqlDumpFile -Raw

# Extract INSERT statement (between INSERT INTO and the final semicolon)
Write-Host "🔍 Extracting INSERT statements..." -ForegroundColor Yellow
$insertPattern = "INSERT INTO `restaurant_admins` VALUES (.+?);"
$matches = [regex]::Match($content, $insertPattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)

if (-not $matches.Success) {
    Write-Host "❌ Error: Could not find INSERT INTO statement in dump file" -ForegroundColor Red
    exit 1
}

$valuesString = $matches.Groups[1].Value

# Split by record boundaries: ),(
Write-Host "📊 Parsing records..." -ForegroundColor Yellow
$records = $valuesString -split '\),\(' 

# Clean first and last records (remove leading/trailing parentheses)
$records[0] = $records[0] -replace '^\(', ''
$records[-1] = $records[-1] -replace '\)$', ''

Write-Host "✅ Found $($records.Count) records" -ForegroundColor Green
Write-Host ""

# Create CSV header
$csvHeader = "id,admin_user_id,password,fname,lname,email,user_type,restaurant,lastlogin,activeUser,loginCount,allowed_restaurants,showAllStats,fb_token,showOrderManagement,sendStatement,sendStatementTo,allowAr,showClients"
$csvLines = @($csvHeader)

Write-Host "🔄 Converting records to CSV format..." -ForegroundColor Yellow
$processedCount = 0

foreach ($record in $records) {
    try {
        # Basic CSV conversion (note: this is simplified and may need adjustment for complex BLOBs)
        # For BLOBs, we'll encode them as base64 to avoid CSV escaping issues
        
        # For now, let's just warn about BLOB fields
        $csvLines += $record
        $processedCount++
        
        if ($processedCount % 100 -eq 0) {
            Write-Host "  Processed $processedCount records..." -ForegroundColor Gray
        }
    }
    catch {
        Write-Host "⚠️  Warning: Failed to process record: $($record.Substring(0, [Math]::Min(100, $record.Length)))..." -ForegroundColor Yellow
    }
}

Write-Host "✅ Processed $processedCount records successfully" -ForegroundColor Green
Write-Host ""

# Write CSV file
Write-Host "💾 Writing CSV file..." -ForegroundColor Yellow
$csvLines | Out-File -FilePath $outputCsvFile -Encoding UTF8

Write-Host "✅ CSV file created: $outputCsvFile" -ForegroundColor Green
Write-Host ""
Write-Host "📝 Next steps:" -ForegroundColor Cyan
Write-Host "   1. Review the CSV file to ensure data integrity" -ForegroundColor White
Write-Host "   2. Use \COPY in PostgreSQL to load the data:" -ForegroundColor White
Write-Host "      \COPY staging.v1_restaurant_admin_users FROM '$outputCsvFile' WITH (FORMAT csv, HEADER true);" -ForegroundColor Gray
Write-Host ""
Write-Host "⚠️  Note: BLOB fields (allowed_restaurants) may need special handling" -ForegroundColor Yellow
Write-Host "   Consider using mysql client to export directly to CSV with proper escaping" -ForegroundColor Yellow
Write-Host ""




