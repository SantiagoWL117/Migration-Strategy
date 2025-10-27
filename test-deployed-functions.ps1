# Comprehensive Edge Function Testing
$SUPABASE_URL = "https://nthpbtdjhhnwfxqsxbvy.supabase.co"
$ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im50aHBidGRqaGhud2Z4cXN4YnZ5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjM3NDM2MDcsImV4cCI6MjAzOTMxOTYwN30.hCPCJ_1Ol0dKU0jY8CwpW42RQCtL-5tUxGj2QFo2G4U"
$headers = @{ "apikey" = $ANON_KEY }

$results = @()

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "EDGE FUNCTION TEST REPORT" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Test Public GET Endpoints
Write-Host "PUBLIC GET ENDPOINTS:" -ForegroundColor Yellow
Write-Host "--------------------`n" -ForegroundColor Yellow

# 1. check-restaurant-availability
Write-Host "1. check-restaurant-availability..." -NoNewline
try {
    $response = Invoke-RestMethod -Uri "$SUPABASE_URL/functions/v1/check-restaurant-availability?restaurant_id=561" -Headers $headers -Method GET -ErrorAction Stop
    Write-Host " ✅" -ForegroundColor Green
    $results += [PSCustomObject]@{ Function = "check-restaurant-availability"; Status = "PASS"; Type = "GET Public" }
} catch {
    Write-Host " ❌ ($($_.Exception.Response.StatusCode.value__))" -ForegroundColor Red
    $results += [PSCustomObject]@{ Function = "check-restaurant-availability"; Status = "FAIL"; Type = "GET Public" }
}

# 2. get-operational-restaurants
Write-Host "2. get-operational-restaurants..." -NoNewline
try {
    $response = Invoke-RestMethod -Uri "$SUPABASE_URL/functions/v1/get-operational-restaurants?limit=5" -Headers $headers -Method GET -ErrorAction Stop
    Write-Host " ✅ (Found: $($response.total_count))" -ForegroundColor Green
    $results += [PSCustomObject]@{ Function = "get-operational-restaurants"; Status = "PASS"; Type = "GET Public" }
} catch {
    Write-Host " ❌ ($($_.Exception.Response.StatusCode.value__))" -ForegroundColor Red
    $results += [PSCustomObject]@{ Function = "get-operational-restaurants"; Status = "FAIL"; Type = "GET Public" }
}

# 3. search-restaurants
Write-Host "3. search-restaurants..." -NoNewline
try {
    $response = Invoke-RestMethod -Uri "$SUPABASE_URL/functions/v1/search-restaurants?cuisine=pizza&limit=5" -Headers $headers -Method GET -ErrorAction Stop
    Write-Host " ✅ (Found: $($response.data.total))" -ForegroundColor Green
    $results += [PSCustomObject]@{ Function = "search-restaurants"; Status = "PASS"; Type = "GET Public" }
} catch {
    Write-Host " ❌ ($($_.Exception.Response.StatusCode.value__))" -ForegroundColor Red
    $results += [PSCustomObject]@{ Function = "search-restaurants"; Status = "FAIL"; Type = "GET Public" }
}

# 4. get-deletion-audit-trail
Write-Host "4. get-deletion-audit-trail..." -NoNewline
try {
    $response = Invoke-RestMethod -Uri "$SUPABASE_URL/functions/v1/get-deletion-audit-trail?table=ALL&days=7" -Headers $headers -Method GET -ErrorAction Stop
    Write-Host " ✅" -ForegroundColor Green
    $results += [PSCustomObject]@{ Function = "get-deletion-audit-trail"; Status = "PASS"; Type = "GET Public" }
} catch {
    Write-Host " ❌ ($($_.Exception.Response.StatusCode.value__))" -ForegroundColor Red
    $results += [PSCustomObject]@{ Function = "get-deletion-audit-trail"; Status = "FAIL"; Type = "GET Public" }
}

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "SUMMARY" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$passed = ($results | Where-Object { $_.Status -eq "PASS" }).Count
$failed = ($results | Where-Object { $_.Status -eq "FAIL" }).Count

Write-Host "Tested: $($results.Count)" -ForegroundColor White
Write-Host "Passed: $passed" -ForegroundColor Green
Write-Host "Failed: $failed" -ForegroundColor Red
Write-Host "`n" -ForegroundColor White

$results | Format-Table -AutoSize

