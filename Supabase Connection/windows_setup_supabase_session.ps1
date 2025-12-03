# Supabase Quick Session Setup Script
Write-Host "Setting up Supabase session environment..."

# S
upabase Credentials
$env:SUPABASE_ACCESS_TOKEN = "sbp_c6c07320cadc875cfd087fd8f8edd03769c8b2b9"
$env:SUPABASE_SERVICE_ROLE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im50aHBidGRqaGhud2Z4cXN4YnZ5Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NTI3MzQ4NCwiZXhwIjoyMDcwODQ5NDg0fQ.THhg9RhwfeN2B9V1SZdef0iJIeBntwd2w67p_J0ch1g"
$env:SUPABASE_PROJECT_REF = "nthpbtdjhhnwfxqsxbvy"
$env:SUPABASE_DB_PASSWORD = "Gz35CPTom1RnsmGM"

# Connection String
$env:SUPABASE_CONNECTION_STRING = "postgresql://postgres:$($env:SUPABASE_DB_PASSWORD)@db.$($env:SUPABASE_PROJECT_REF).supabase.co:5432/postgres"

# PostgreSQL Client Path
$env:PSQL_PATH = "C:\Program Files\PostgreSQL\17\bin\psql.exe"

# Supabase API Endpoint
$env:SUPABASE_URL = "https://$($env:SUPABASE_PROJECT_REF).supabase.co"
$env:SUPABASE_REST_API = "$($env:SUPABASE_URL)/rest/v1"

Write-Host "Supabase session configured!" -ForegroundColor Green
Write-Host ""
Write-Host "Environment variables set:"
Write-Host "  SUPABASE_PROJECT_REF: $($env:SUPABASE_PROJECT_REF)"
Write-Host "  SUPABASE_URL: $($env:SUPABASE_URL)"
Write-Host "  SUPABASE_CONNECTION_STRING: Set"
Write-Host "  PSQL_PATH: $($env:PSQL_PATH)"
