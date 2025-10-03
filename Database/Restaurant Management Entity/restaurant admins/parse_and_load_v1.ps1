# ============================================================================
# Parse V1 MySQL Dump and Generate PostgreSQL INSERT Statements
# ============================================================================
# Purpose: Convert MySQL INSERT to individual PostgreSQL INSERT statements
# Excludes: BLOB data (allowed_restaurants)
# ============================================================================

param(
    [string]$DumpFile = "Database\Restaurant Management Entity\restaurant admins\dumps\menuca_v1_restaurant_admins.sql",
    [string]$OutputFile = "Database\Restaurant Management Entity\restaurant admins\v1_data_inserts.sql"
)

Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "  V1 Data Parser - MySQL to PostgreSQL" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""

# Read dump file
Write-Host "📂 Reading dump file..." -ForegroundColor Yellow
$content = Get-Content $DumpFile -Raw -Encoding UTF8
Write-Host "✅ File read successfully" -ForegroundColor Green
Write-Host ""

# Extract INSERT statement
Write-Host "🔍 Extracting INSERT statement..." -ForegroundColor Yellow
$insertPattern = 'INSERT INTO `restaurant_admins` VALUES (.+?);'
$match = [regex]::Match($content, $insertPattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)

if (-not $match.Success) {
    Write-Host "❌ Could not find INSERT statement" -ForegroundColor Red
    exit 1
}

$valuesString = $match.Groups[1].Value
Write-Host "✅ INSERT statement found" -ForegroundColor Green
Write-Host ""

# Split into individual records
Write-Host "📊 Parsing records..." -ForegroundColor Yellow
$records = $valuesString -split '\),\('

# Clean up first and last records
$records[0] = $records[0] -replace '^\(', ''
$records[-1] = $records[-1] -replace '\)$', ''

Write-Host "✅ Found $($records.Count) records" -ForegroundColor Green
Write-Host ""

# Generate PostgreSQL INSERT statements
Write-Host "🔄 Generating PostgreSQL statements..." -ForegroundColor Yellow

$sqlStatements = @()
$sqlStatements += "-- ============================================================================"
$sqlStatements += "-- V1 restaurant_admins Data - PostgreSQL INSERTs"
$sqlStatements += "-- Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$sqlStatements += "-- Records: $($records.Count)"
$sqlStatements += "-- Note: BLOB data (allowed_restaurants) excluded"
$sqlStatements += "-- ============================================================================"
$sqlStatements += ""
$sqlStatements += "BEGIN;"
$sqlStatements += ""
$sqlStatements += "-- Clear existing data (idempotent)"
$sqlStatements += "TRUNCATE TABLE staging.v1_restaurant_admin_users;"
$sqlStatements += ""

$processed = 0
$skipped = 0

foreach ($record in $records) {
    try {
        # Parse fields using a more robust method
        # MySQL format: id,admin_user_id,password,fname,lname,email,user_type,restaurant,lastlogin,activeUser,loginCount,_binary'...',fields...
        
        # This is complex due to BLOB data, so let's use a simpler approach
        # Split by comma, but respect quoted strings and BLOB markers
        
        $fields = @()
        $currentField = ""
        $inQuotes = $false
        $inBinary = $false
        $depth = 0
        
        for ($i = 0; $i -lt $record.Length; $i++) {
            $char = $record[$i]
            
            if ($char -eq "'" -and ($i -eq 0 -or $record[$i-1] -ne '\')) {
                $inQuotes = -not $inQuotes
                $currentField += $char
            }
            elseif ($char -eq ',' -and -not $inQuotes -and $depth -eq 0) {
                $fields += $currentField
                $currentField = ""
            }
            elseif ($record.Substring($i, [Math]::Min(7, $record.Length - $i)) -eq '_binary' -and -not $inQuotes) {
                $inBinary = $true
                $currentField += $char
            }
            elseif ($char -eq '{' -and $inBinary) {
                $depth++
                $currentField += $char
            }
            elseif ($char -eq '}' -and $inBinary) {
                $depth--
                $currentField += $char
                if ($depth -eq 0) {
                    $inBinary = $false
                }
            }
            else {
                $currentField += $char
            }
        }
        # Add last field
        if ($currentField) {
            $fields += $currentField
        }
        
        if ($fields.Count -lt 11) {
            Write-Host "  ⚠️  Skipping record - insufficient fields: $($fields.Count)" -ForegroundColor Yellow
            $skipped++
            continue
        }
        
        # Extract fields (without BLOB at position 11)
        $id = $fields[0].Trim()
        $admin_user_id = $fields[1].Trim()
        $password = $fields[2].Trim()
        $fname = $fields[3].Trim()
        $lname = $fields[4].Trim()
        $email = $fields[5].Trim()
        $user_type = $fields[6].Trim()
        $restaurant = $fields[7].Trim()
        $lastlogin = $fields[8].Trim()
        $activeUser = $fields[9].Trim()
        $loginCount = $fields[10].Trim()
        # Skip field 11 (_binary BLOB)
        # Fields 12+ are UI flags we don't need
        
        # Convert MySQL NULL to PostgreSQL NULL
        if ($admin_user_id -eq 'NULL') { $admin_user_id = 'NULL' }
        
        # Generate INSERT
        $insert = @"
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    $id, $restaurant, $fname, $lname, $email,
    $password, $lastlogin, $loginCount, $activeUser, 'n',
    NULL, NULL
);
"@
        
        $sqlStatements += $insert
        $processed++
        
        if ($processed % 50 -eq 0) {
            Write-Host "  Processed $processed records..." -ForegroundColor Gray
        }
        
    }
    catch {
        Write-Host "  ⚠️  Error parsing record: $_" -ForegroundColor Yellow
        $skipped++
    }
}

$sqlStatements += ""
$sqlStatements += "COMMIT;"
$sqlStatements += ""
$sqlStatements += "-- Verification"
$sqlStatements += "SELECT COUNT(*) AS total_loaded FROM staging.v1_restaurant_admin_users;"
$sqlStatements += ""

# Write to file
Write-Host ""
Write-Host "💾 Writing to file..." -ForegroundColor Yellow
$sqlStatements | Out-File -FilePath $OutputFile -Encoding UTF8
Write-Host "✅ File written: $OutputFile" -ForegroundColor Green
Write-Host ""

Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "  SUMMARY" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "  Total records found:    $($records.Count)" -ForegroundColor White
Write-Host "  Successfully processed: $processed" -ForegroundColor Green
Write-Host "  Skipped:                $skipped" -ForegroundColor Yellow
Write-Host "  Output file:            $OutputFile" -ForegroundColor White
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""

if ($processed -gt 0) {
    Write-Host "✅ Ready to load into Supabase!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next step: Execute the generated SQL file using Supabase MCP" -ForegroundColor Yellow
}

