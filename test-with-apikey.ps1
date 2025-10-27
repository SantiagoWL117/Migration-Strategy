# Test Edge Functions with apikey header
$SUPABASE_URL = "https://nthpbtdjhhnwfxqsxbvy.supabase.co"
$ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im50aHBidGRqaGhud2Z4cXN4YnZ5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjM3NDM2MDcsImV4cCI6MjAzOTMxOTYwN30.hCPCJ_1Ol0dKU0jY8CwpW42RQCtL-5tUxGj2QFo2G4U"

$headers = @{
    "apikey" = $ANON_KEY
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Testing Edge Functions with apikey" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Test 1
Write-Host "1. check-restaurant-availability?restaurant_id=561" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$SUPABASE_URL/functions/v1/check-restaurant-availability?restaurant_id=561" -Headers $headers -Method GET
    Write-Host "   ✅ SUCCESS" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 3 | Write-Host -ForegroundColor Gray
} catch {
    Write-Host "   ❌ FAILED: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n========================================`n" -ForegroundColor Cyan

