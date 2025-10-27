# Test public Edge Functions without authentication
$SUPABASE_URL = "https://nthpbtdjhhnwfxqsxbvy.supabase.co"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Testing Public Edge Functions" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Test 1: check-restaurant-availability (should be public)
Write-Host "1. Testing: check-restaurant-availability" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$SUPABASE_URL/functions/v1/check-restaurant-availability?restaurant_id=561" -Method GET
    Write-Host "   ✅ SUCCESS" -ForegroundColor Green
    Write-Host "   Response: $($response | ConvertTo-Json -Depth 3)`n" -ForegroundColor Gray
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    Write-Host "   ❌ FAILED (Status: $statusCode)" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)`n" -ForegroundColor Red
}

# Test 2: get-operational-restaurants
Write-Host "2. Testing: get-operational-restaurants" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$SUPABASE_URL/functions/v1/get-operational-restaurants?limit=3" -Method GET
    Write-Host "   ✅ SUCCESS" -ForegroundColor Green
    Write-Host "   Found $($response.total_count) restaurants`n" -ForegroundColor Gray
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    Write-Host "   ❌ FAILED (Status: $statusCode)" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)`n" -ForegroundColor Red
}

# Test 3: search-restaurants
Write-Host "3. Testing: search-restaurants" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$SUPABASE_URL/functions/v1/search-restaurants?cuisine=pizza&limit=3" -Method GET
    Write-Host "   ✅ SUCCESS" -ForegroundColor Green
    Write-Host "   Found $($response.data.total) restaurants`n" -ForegroundColor Gray
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    Write-Host "   ❌ FAILED (Status: $statusCode)" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)`n" -ForegroundColor Red
}

# Test 4: get-deletion-audit-trail (GET method)
Write-Host "4. Testing: get-deletion-audit-trail" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$SUPABASE_URL/functions/v1/get-deletion-audit-trail?table=ALL&days=7" -Method GET
    Write-Host "   ✅ SUCCESS" -ForegroundColor Green
    Write-Host "   Total deletions: $($response.data.total_deletions)`n" -ForegroundColor Gray
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    Write-Host "   ❌ FAILED (Status: $statusCode)" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)`n" -ForegroundColor Red
}

Write-Host "========================================`n" -ForegroundColor Cyan

