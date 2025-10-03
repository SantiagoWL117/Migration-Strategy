# ============================================================================
# Analyze V1 restaurant_admins.sql for Formatting Discrepancies
# ============================================================================
# Purpose: Comprehensive formatting analysis before migration
# Date: 2025-10-02
# ============================================================================

param(
    [string]$FilePath = "Database\Restaurant Management Entity\restaurant admins\dumps\menuca_v1_restaurant_admins.sql"
)

Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "  V1 restaurant_admins.sql - Formatting Analysis Report" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""

# Read file
$content = Get-Content $FilePath -Raw
$lines = Get-Content $FilePath

Write-Host "FILE STATISTICS" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
Write-Host "File Path:      $FilePath"
Write-Host "File Size:      $((Get-Item $FilePath).Length) bytes"
Write-Host "Total Lines:    $($lines.Count)"
Write-Host ""

# Count records
$recordSeparators = ([regex]::Matches($content, '\),\(')).Count
$estimatedRecords = $recordSeparators + 1

Write-Host "RECORD COUNT" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
Write-Host "Record Separators: $recordSeparators"
Write-Host "Estimated Records: $estimatedRecords"
Write-Host "Expected:          ~1,075 (from AUTO_INCREMENT)"
Write-Host "Discrepancy:       $(1075 - $estimatedRecords) records missing/different"
Write-Host ""

# BLOB Analysis
Write-Host "1. BLOB FIELD ANALYSIS (_binary markers)" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
$binaryCount = ([regex]::Matches($content, '_binary')).Count
Write-Host "BLOB fields marked with _binary: $binaryCount"
if ($binaryCount -lt $estimatedRecords) {
    Write-Host "⚠️  WARNING: Not all records have BLOB data!" -ForegroundColor Yellow
    Write-Host "   Expected: ~$estimatedRecords, Found: $binaryCount"
    Write-Host "   Impact: Some users may have empty allowed_restaurants field"
}
Write-Host ""

# NULL value analysis
Write-Host "2. NULL VALUE ANALYSIS" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
$nullCount = ([regex]::Matches($content, ',NULL,')).Count
Write-Host "NULL values in data: $nullCount"
Write-Host "Average NULLs per record: $([Math]::Round($nullCount / $estimatedRecords, 2))"
Write-Host "Impact: Fields like admin_user_id, created_at, updated_at are likely NULL"
Write-Host ""

# Empty string analysis
Write-Host "3. EMPTY STRING ANALYSIS" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
$emptyStrings = ([regex]::Matches($content, "''")).Count
Write-Host "Empty string markers (''): $emptyStrings"
Write-Host "Average empty strings per record: $([Math]::Round($emptyStrings / $estimatedRecords, 2))"
Write-Host "Impact: Fields like fb_token, sendStatementTo are likely empty"
Write-Host ""

# Password hash analysis
Write-Host "4. PASSWORD HASH FORMAT" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
$bcryptHashes = ([regex]::Matches($content, '\$2y\$10\$')).Count
Write-Host "Bcrypt hashes (\$2y\$10\$...): $bcryptHashes"
Write-Host "Records without password: $($estimatedRecords - $bcryptHashes)"
if ($bcryptHashes -ne $estimatedRecords) {
    Write-Host "⚠️  WARNING: Some records may have NULL or non-bcrypt passwords!" -ForegroundColor Yellow
}
Write-Host ""

# Email format analysis
Write-Host "5. EMAIL ADDRESS FORMAT" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
$emailPattern = "([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})"
$emails = [regex]::Matches($content, $emailPattern)
Write-Host "Email addresses found: $($emails.Count)"
Write-Host "Records without email: $($estimatedRecords - $emails.Count)"
if ($emails.Count -lt $estimatedRecords) {
    Write-Host "⚠️  WARNING: Some records missing email addresses!" -ForegroundColor Yellow
    Write-Host "   This violates NOT NULL constraint in V3 table"
}
Write-Host ""

# User type analysis
Write-Host "6. USER TYPE DISTRIBUTION" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
# More flexible pattern matching
$userTypeRCount = 0
$userTypeGCount = 0
foreach ($line in $lines) {
    $userTypeRCount += ([regex]::Matches($line, ",'r',")).Count
    $userTypeGCount += ([regex]::Matches($line, ",'g',")).Count
}
Write-Host "user_type = 'r' (restaurant): $userTypeRCount"
Write-Host "user_type = 'g' (global): $userTypeGCount"
Write-Host "user_type = NULL or other: $($estimatedRecords - $userTypeRCount - $userTypeGCount)"
Write-Host ""
Write-Host "✅ Migration Impact:" -ForegroundColor Green
Write-Host "   - Will migrate: ~$userTypeRCount restaurant-type users"
Write-Host "   - Will exclude: ~$userTypeGCount global-type users"
Write-Host ""

# Active user analysis
Write-Host "7. ACTIVE USER STATUS" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
$activeCount = 0
$inactiveCount = 0
foreach ($line in $lines) {
    # Looking for the activeUser enum field
    $activeCount += ([regex]::Matches($line, ",'1',\d+,")).Count
    $inactiveCount += ([regex]::Matches($line, ",'0',\d+,")).Count
}
Write-Host "activeUser = '1' (active): $activeCount"
Write-Host "activeUser = '0' (inactive): $inactiveCount"
Write-Host ""

# Send statement analysis  
Write-Host "8. SEND STATEMENT PREFERENCE" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
$sendYCount = 0
$sendNCount = 0
foreach ($line in $lines) {
    $sendYCount += ([regex]::Matches($line, ",_binary")).Count  # sendStatement='y' typically before _binary
    $sendNCount += ([regex]::Matches($line, ",'n',_binary")).Count
}
Write-Host "sendStatement = 'y': ~$sendYCount"
Write-Host "sendStatement = 'n': ~$sendNCount"
Write-Host ""

# Timestamp analysis
Write-Host "9. TIMESTAMP FORMAT" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
$timestampPattern = '\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}'
$timestamps = [regex]::Matches($content, $timestampPattern)
Write-Host "Timestamps found: $($timestamps.Count)"
Write-Host "Expected: ~$estimatedRecords (one lastlogin per record)"
Write-Host "Format: YYYY-MM-DD HH:MM:SS (MySQL format)"
Write-Host "✅ Will convert to: timestamptz (PostgreSQL format)"
Write-Host ""

# Restaurant ID = 0 check
Write-Host "10. RESTAURANT ID = 0 (GLOBAL ADMINS)" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
$rest0Count = ([regex]::Matches($content, ",'g',0,")).Count
Write-Host "Records with restaurant=0: $rest0Count"
Write-Host "⚠️  These are global admins and will be EXCLUDED from migration" -ForegroundColor Yellow
Write-Host ""

# Data structure issues
Write-Host "11. POTENTIAL FORMATTING ISSUES" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
$issues = @()

# Check for single-line INSERT
if ($lines.Count -lt 100) {
    $issues += "✅ Single-line INSERT statement (normal for MySQL dumps)"
}

# Check for escaped characters
$escapedQuotes = ([regex]::Matches($content, "\\'")).Count
if ($escapedQuotes -gt 0) {
    $issues += "⚠️  Escaped quotes (\\') found: $escapedQuotes - May need special handling"
}

# Check for newlines in data
if ($content -match '\\n') {
    $issues += "⚠️  Newline characters (\\n) in data - May cause parsing issues"
}

# Check for tabs in data
if ($content -match '\\t') {
    $issues += "⚠️  Tab characters (\\t) in data - May cause parsing issues"
}

# Check file line ending
if ($content -match "`r`n") {
    $issues += "✅ Windows line endings (CRLF) detected"
} elseif ($content -match "`n") {
    $issues += "✅ Unix line endings (LF) detected"
}

if ($issues.Count -eq 0) {
    Write-Host "✅ No critical formatting issues detected" -ForegroundColor Green
} else {
    foreach ($issue in $issues) {
        Write-Host $issue
    }
}
Write-Host ""

# Migration readiness summary
Write-Host "MIGRATION READINESS SUMMARY" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
Write-Host "✅ Total records to process: $estimatedRecords"
Write-Host "✅ Estimated records to migrate: ~$($userTypeRCount - $rest0Count) (user_type='r' AND restaurant>0)"
Write-Host "❌ Records to exclude: ~$($userTypeGCount + $rest0Count) (global admins)"
Write-Host ""
Write-Host "⚠️  WARNINGS TO ADDRESS:" -ForegroundColor Yellow
if ($binaryCount -lt $estimatedRecords) {
    Write-Host "   - Not all records have BLOB data (allowed_restaurants)"
}
if ($emails.Count -lt $estimatedRecords) {
    Write-Host "   - Some records missing email addresses (will fail NOT NULL constraint)"
}
if ($bcryptHashes -ne $estimatedRecords) {
    Write-Host "   - Some records may have NULL passwords"
}
Write-Host ""
Write-Host "============================================================================" -ForegroundColor Cyan


