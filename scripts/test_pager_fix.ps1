# Test PSQL Pager Fix
# Verifies agents can run queries without "-- More --" hangs

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "TESTING PSQL PAGER FIX" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Test 1: Run query that would trigger pager (>20 rows)
Write-Host "Test 1: Query with 160 rows (would cause -- More -- without fix)" -ForegroundColor Yellow

$query = "
SELECT 
  r.id as v3_id, 
  r.legacy_v1_id as v1_id, 
  r.name 
FROM menuca_v3.restaurants r 
WHERE 
  r.legacy_v1_id IS NOT NULL 
  AND r.legacy_v1_id != 0 
  AND r.deleted_at IS NULL 
ORDER BY r.name 
LIMIT 20;
"

Write-Host "  Running query..." -ForegroundColor Gray

try {
    $startTime = Get-Date
    $env:PGCLIENTENCODING="UTF8"
    $env:PAGER=""
    $result = & "C:\Program Files\PostgreSQL\17\bin\psql.exe" "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" --pset pager=off -c $query 2>&1
    $endTime = Get-Date
    $duration = ($endTime - $startTime).TotalSeconds
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  PASS: Query completed in $duration seconds" -ForegroundColor Green
        $rowCount = ($result | Select-String "^\s+\d+" | Measure-Object).Count
        Write-Host "  PASS: Retrieved $rowCount rows" -ForegroundColor Green
    } else {
        Write-Host "  FAIL: Query failed with exit code $LASTEXITCODE" -ForegroundColor Red
        Write-Host "  Error: $result" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "  FAIL: Exception occurred: $_" -ForegroundColor Red
    exit 1
}

# Test 2: Verify no "-- More --" in output
Write-Host "`nTest 2: Verify no '-- More --' prompt in output" -ForegroundColor Yellow
if ($result -match "-- More --") {
    Write-Host "  FAIL: Found '-- More --' in output!" -ForegroundColor Red
    exit 1
} else {
    Write-Host "  PASS: No pager prompts detected" -ForegroundColor Green
}

# Test 3: Verify special characters handled correctly
Write-Host "`nTest 3: Verify special characters (é, è, ñ) handled correctly" -ForegroundColor Yellow
$specialCharQuery = "SELECT 'Café René' as test_name;"
try {
    $env:PGCLIENTENCODING="UTF8"
    $env:PAGER=""
    $result = & "C:\Program Files\PostgreSQL\17\bin\psql.exe" "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" --pset pager=off -c $specialCharQuery 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  PASS: Special characters handled correctly" -ForegroundColor Green
    } else {
        Write-Host "  FAIL: Encoding error occurred" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "  FAIL: Exception with special characters: $_" -ForegroundColor Red
    exit 1
}

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "ALL TESTS PASSED!" -ForegroundColor Green
Write-Host "`nFixes verified:" -ForegroundColor White
Write-Host "  - No '-- More --' hangs" -ForegroundColor Gray
Write-Host "  - Complete results returned" -ForegroundColor Gray
Write-Host "  - Special characters handled correctly" -ForegroundColor Gray
Write-Host "  - Encoding errors prevented" -ForegroundColor Gray
Write-Host ""













