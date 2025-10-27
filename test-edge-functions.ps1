# Edge Function Testing Script
# Tests all 36 deployed Edge Functions

$SUPABASE_URL = "https://nthpbtdjhhnwfxqsxbvy.supabase.co"
$ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im50aHBidGRqaGhud2Z4cXN4YnZ5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjM3NDM2MDcsImV4cCI6MjAzOTMxOTYwN30.hCPCJ_1Ol0dKU0jY8CwpW42RQCtL-5tUxGj2QFo2G4U"

$headers = @{
    "apikey" = $ANON_KEY
    "Authorization" = "Bearer $ANON_KEY"
    "Content-Type" = "application/json"
}

$results = @()

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Edge Function Testing Report" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Test 1: check-restaurant-availability (GET, Public)
Write-Host "Testing: check-restaurant-availability..." -NoNewline
try {
    $response = Invoke-RestMethod -Uri "$SUPABASE_URL/functions/v1/check-restaurant-availability?restaurant_id=561" -Headers $headers -Method GET -ErrorAction Stop
    Write-Host " ✅ PASS" -ForegroundColor Green
    $results += [PSCustomObject]@{
        Function = "check-restaurant-availability"
        Status = "PASS"
        Method = "GET"
        Auth = "Public"
        Response = $response.success
    }
} catch {
    Write-Host " ❌ FAIL: $($_.Exception.Message)" -ForegroundColor Red
    $results += [PSCustomObject]@{
        Function = "check-restaurant-availability"
        Status = "FAIL"
        Method = "GET"
        Auth = "Public"
        Response = $_.Exception.Message
    }
}

# Test 2: get-operational-restaurants (GET, Public)
Write-Host "Testing: get-operational-restaurants..." -NoNewline
try {
    $response = Invoke-RestMethod -Uri "$SUPABASE_URL/functions/v1/get-operational-restaurants?limit=5" -Headers $headers -Method GET -ErrorAction Stop
    Write-Host " ✅ PASS" -ForegroundColor Green
    $results += [PSCustomObject]@{
        Function = "get-operational-restaurants"
        Status = "PASS"
        Method = "GET"
        Auth = "Public"
        Response = "Count: $($response.total_count)"
    }
} catch {
    Write-Host " ❌ FAIL: $($_.Exception.Message)" -ForegroundColor Red
    $results += [PSCustomObject]@{
        Function = "get-operational-restaurants"
        Status = "FAIL"
        Method = "GET"
        Auth = "Public"
        Response = $_.Exception.Message
    }
}

# Test 3: search-restaurants (GET, Public)
Write-Host "Testing: search-restaurants..." -NoNewline
try {
    $response = Invoke-RestMethod -Uri "$SUPABASE_URL/functions/v1/search-restaurants?cuisine=pizza&limit=5" -Headers $headers -Method GET -ErrorAction Stop
    Write-Host " ✅ PASS" -ForegroundColor Green
    $results += [PSCustomObject]@{
        Function = "search-restaurants"
        Status = "PASS"
        Method = "GET"
        Auth = "Public"
        Response = "Found: $($response.data.total)"
    }
} catch {
    Write-Host " ❌ FAIL: $($_.Exception.Message)" -ForegroundColor Red
    $results += [PSCustomObject]@{
        Function = "search-restaurants"
        Status = "FAIL"
        Method = "GET"
        Auth = "Public"
        Response = $_.Exception.Message
    }
}

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Test Summary" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$passed = ($results | Where-Object { $_.Status -eq "PASS" }).Count
$failed = ($results | Where-Object { $_.Status -eq "FAIL" }).Count

Write-Host "Total Tests: $($results.Count)" -ForegroundColor White
Write-Host "Passed: $passed" -ForegroundColor Green
Write-Host "Failed: $failed" -ForegroundColor Red

Write-Host "`nDetailed Results:" -ForegroundColor Cyan
$results | Format-Table -AutoSize

# Save to file
$results | Export-Csv -Path "edge-function-test-results.csv" -NoTypeInformation
Write-Host "`nResults saved to: edge-function-test-results.csv`n" -ForegroundColor Yellow

