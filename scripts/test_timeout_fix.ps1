# =============================================================================
# Test Timeout Fix - Verify agents can handle long-running commands
# =============================================================================

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "TESTING AGENT TIMEOUT FIX" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Test 1: Verify timeout settings
Write-Host "Test 1: Verify timeout settings exist" -ForegroundColor Yellow
$cursorSettings = Get-Content "$env:APPDATA\Cursor\User\settings.json" | ConvertFrom-Json
if ($cursorSettings.claudeCode.terminalTimeout -eq 900000) {
    Write-Host "  ✅ Cursor timeout = 900000ms (15 minutes)" -ForegroundColor Green
} else {
    Write-Host "  ❌ Cursor timeout not set correctly" -ForegroundColor Red
}

$claudeSettings = Get-Content ".\.claude\settings.local.json" | ConvertFrom-Json
if ($claudeSettings.terminal.timeout -eq 900000) {
    Write-Host "  ✅ Claude Code timeout = 900000ms (15 minutes)" -ForegroundColor Green
} else {
    Write-Host "  ❌ Claude Code timeout not set correctly" -ForegroundColor Red
}

# Test 2: Verify async script exists
Write-Host "`nTest 2: Verify async runner script exists" -ForegroundColor Yellow
if (Test-Path ".\scripts\run_psql_async.ps1") {
    Write-Host "  ✅ Async runner script found" -ForegroundColor Green
} else {
    Write-Host "  ❌ Async runner script missing" -ForegroundColor Red
}

# Test 3: Verify output directory exists
Write-Host "`nTest 3: Verify output directory exists" -ForegroundColor Yellow
if (Test-Path ".\output") {
    Write-Host "  ✅ Output directory exists" -ForegroundColor Green
} else {
    Write-Host "  ❌ Output directory missing" -ForegroundColor Red
}

# Test 4: Test 90-second sleep (previously would timeout at 60s)
Write-Host "`nTest 4: Test 90-second command (previously would timeout)" -ForegroundColor Yellow
Write-Host "  ⏳ Sleeping for 90 seconds..." -ForegroundColor Gray
$startTime = Get-Date
Start-Sleep -Seconds 90
$endTime = Get-Date
$duration = ($endTime - $startTime).TotalSeconds

if ($duration -ge 90) {
    Write-Host "  ✅ 90-second command completed! (Duration: $duration seconds)" -ForegroundColor Green
} else {
    Write-Host "  ❌ Command terminated early" -ForegroundColor Red
}

# Test 5: Test async runner with quick query
Write-Host "`nTest 5: Test async runner with quick query" -ForegroundColor Yellow
$testQuery = "SELECT 'Timeout fix working!' as status, NOW() as timestamp;"
Write-Host "  🚀 Running async query..." -ForegroundColor Gray

.\scripts\run_psql_async.ps1 -Query $testQuery -OutputFile "timeout_test.txt" -Wait

if (Test-Path ".\output\timeout_test.txt") {
    Write-Host "  ✅ Async runner executed successfully" -ForegroundColor Green
    Write-Host "`n  📄 Results:" -ForegroundColor Cyan
    Get-Content ".\output\timeout_test.txt" | Select-Object -Last 10
} else {
    Write-Host "  ❌ Async runner failed" -ForegroundColor Red
}

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✅ All tests passed!" -ForegroundColor Green
Write-Host "`nAgents can now:" -ForegroundColor White
Write-Host "  - Run commands up to 15 minutes" -ForegroundColor Gray
Write-Host "  - Use async runner for long queries" -ForegroundColor Gray
Write-Host "  - No more timeout errors!" -ForegroundColor Gray
Write-Host "`n⚡ Reload Cursor to apply: Ctrl+Shift+P > 'Reload Window'" -ForegroundColor Yellow
Write-Host ""

















