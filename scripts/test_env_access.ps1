# Test Environment Variables Access
# Verifies agents can access .env file and use credentials

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "TESTING .ENV ACCESS" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Test 1: .env file exists
Write-Host "Test 1: .env file exists" -ForegroundColor Yellow
if (Test-Path ".\.env files\.env") {
    Write-Host "  PASS: .env file found" -ForegroundColor Green
} else {
    Write-Host "  FAIL: .env file not found" -ForegroundColor Red
    exit 1
}

# Test 2: load_env.ps1 script exists
Write-Host "`nTest 2: Helper scripts exist" -ForegroundColor Yellow
if (Test-Path ".\scripts\load_env.ps1") {
    Write-Host "  PASS: load_env.ps1 found" -ForegroundColor Green
} else {
    Write-Host "  FAIL: load_env.ps1 not found" -ForegroundColor Red
    exit 1
}

if (Test-Path ".\scripts\get_db_connection.ps1") {
    Write-Host "  PASS: get_db_connection.ps1 found" -ForegroundColor Green
} else {
    Write-Host "  FAIL: get_db_connection.ps1 not found" -ForegroundColor Red
    exit 1
}

# Test 3: Can load and display variables
Write-Host "`nTest 3: Can load and display variables" -ForegroundColor Yellow
try {
    .\scripts\load_env.ps1 -Show
    Write-Host "  PASS: Variables loaded successfully" -ForegroundColor Green
} catch {
    Write-Host "  FAIL: Could not load variables: $_" -ForegroundColor Red
    exit 1
}

# Test 4: Can get specific variable
Write-Host "`nTest 4: Can get specific variable" -ForegroundColor Yellow
try {
    $conn = .\scripts\load_env.ps1 -Get "DB_CONNECTION_STRING"
    if ($conn) {
        Write-Host "  PASS: Got DB_CONNECTION_STRING ($($conn.Length) chars)" -ForegroundColor Green
    } else {
        Write-Host "  FAIL: DB_CONNECTION_STRING is empty" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "  FAIL: Could not get variable: $_" -ForegroundColor Red
    exit 1
}

# Test 5: Can use in actual database query
Write-Host "`nTest 5: Can use in database query" -ForegroundColor Yellow
try {
    $conn = .\scripts\get_db_connection.ps1
    $result = & "C:\Program Files\PostgreSQL\17\bin\psql.exe" $conn -c "SELECT 'ENV test passed!' as status;" 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  PASS: Database query executed successfully" -ForegroundColor Green
        Write-Host "  Result: $($result | Select-String 'ENV test passed!')" -ForegroundColor Gray
    } else {
        Write-Host "  FAIL: Database query failed" -ForegroundColor Red
        Write-Host "  Error: $result" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "  FAIL: Could not execute query: $_" -ForegroundColor Red
    exit 1
}

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "ALL TESTS PASSED!" -ForegroundColor Green
Write-Host "`nAgents can now:" -ForegroundColor White
Write-Host "  - Access .env file" -ForegroundColor Gray
Write-Host "  - Load environment variables" -ForegroundColor Gray
Write-Host "  - Use credentials in database queries" -ForegroundColor Gray
Write-Host "  - View variables with security masking" -ForegroundColor Gray
Write-Host ""

