# Load V1 data using psql command
# Requires: PostgreSQL client (psql) installed

$bulkFile = "Database\Restaurant Management Entity\restaurant admins\step1b_bulk_insert.sql"
$dbUrl = $env:SUPABASE_DB_URL

if (-not $dbUrl) {
    Write-Host "[ERROR] SUPABASE_DB_URL environment variable not set" -ForegroundColor Red
    Write-Host ""
    Write-Host "Set it with:" -ForegroundColor Yellow
    Write-Host 'Set-Variable SUPABASE_DB_URL "postgresql://postgres:[password]@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres"'
    exit 1
}

Write-Host "="*80 -ForegroundColor Cyan
Write-Host "  Load V1 Data via psql" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""

Write-Host "[INFO] Executing SQL file..." -ForegroundColor Yellow
Write-Host "[FILE] $bulkFile" -ForegroundColor Gray
Write-Host ""

# Execute via psql
psql $dbUrl -f $bulkFile

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "="*80 -ForegroundColor Green
    Write-Host "  SUCCESS - All records loaded!" -ForegroundColor Green
    Write-Host "="*80 -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "="*80 -ForegroundColor Red
    Write-Host "  ERROR - Failed to load data" -ForegroundColor Red
    Write-Host "="*80 -ForegroundColor Red
    exit 1
}

