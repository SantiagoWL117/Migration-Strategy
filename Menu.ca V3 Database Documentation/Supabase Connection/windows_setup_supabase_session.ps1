# Supabase Quick Session Setup Script
# Loads credentials from .env file for security
Write-Host "🔧 Setting up Supabase session environment..." -ForegroundColor Cyan

# Point to the actual .env file location
$envFile = Join-Path $PSScriptRoot ".." ".env files" ".env"

if (-not (Test-Path $envFile)) {
    Write-Host "❌ ERROR: .env file not found at: $envFile" -ForegroundColor Red
    Write-Host ""
    Write-Host "Expected location: C:\Users\santi\Menu.ca\Legacy Database\Migration Strategy\.env files\.env" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

# Load environment variables from .env file
Write-Host "📦 Loading credentials from .env file..." -ForegroundColor Cyan
Get-Content $envFile | ForEach-Object {
    $line = $_.Trim()
    # Skip comments and empty lines
    if ($line -match '^#' -or $line -eq '') {
        return
    }
    # Parse KEY=VALUE (supports SUPABASE_KEY and DB_CONNECTION_STRING formats)
    if ($line -match '^([A-Z_][A-Z0-9_]*)=(.*)$') {
        $key = $matches[1]
        $value = $matches[2]
        # Remove quotes if present
        $value = $value -replace '^["'']|["'']$', ''
        [System.Environment]::SetEnvironmentVariable($key, $value, 'Process')
    }
}

# Map the .env variables to expected names
# The .env file uses SUPABASE_KEY instead of SUPABASE_SERVICE_ROLE_KEY
if ($env:SUPABASE_KEY -and -not $env:SUPABASE_SERVICE_ROLE_KEY) {
    $env:SUPABASE_SERVICE_ROLE_KEY = $env:SUPABASE_KEY
}

# Extract DB password from DB_CONNECTION_STRING if SUPABASE_DB_PASSWORD not set
if ($env:DB_CONNECTION_STRING -and -not $env:SUPABASE_DB_PASSWORD) {
    if ($env:DB_CONNECTION_STRING -match 'postgres://postgres:([^@]+)@') {
        $env:SUPABASE_DB_PASSWORD = $matches[1]
    }
}

# Verify required variables are set
$requiredVars = @('SUPABASE_KEY', 'DB_CONNECTION_STRING')
$missingVars = @()
foreach ($var in $requiredVars) {
    if (-not [System.Environment]::GetEnvironmentVariable($var, 'Process')) {
        $missingVars += $var
    }
}

if ($missingVars.Count -gt 0) {
    Write-Host "❌ ERROR: Missing required environment variables:" -ForegroundColor Red
    $missingVars | ForEach-Object { Write-Host "   - $_" -ForegroundColor Red }
    Write-Host ""
    Write-Host "Please verify your .env file at: $envFile" -ForegroundColor Yellow
    exit 1
}

# Set derived variables
$env:SUPABASE_PROJECT_REF = "nthpbtdjhhnwfxqsxbvy"

# Use SUPABASE_URL from .env if available, otherwise derive it
if (-not $env:SUPABASE_URL) {
    $env:SUPABASE_URL = "https://$($env:SUPABASE_PROJECT_REF).supabase.co"
}

$env:SUPABASE_REST_API = "$($env:SUPABASE_URL)/rest/v1"

# Use DB_CONNECTION_STRING from .env (already set)
$env:SUPABASE_CONNECTION_STRING = $env:DB_CONNECTION_STRING

$env:PSQL_PATH = "C:\Program Files\PostgreSQL\17\bin\psql.exe"

Write-Host "Supabase session configured!" -ForegroundColor Green
Write-Host ""
Write-Host "Environment variables set:" -ForegroundColor Cyan
Write-Host "  - SUPABASE_KEY (Service Role Key)" -ForegroundColor Green
Write-Host "  - SUPABASE_DB_PASSWORD" -ForegroundColor Green
Write-Host "  - SUPABASE_PROJECT_REF: $($env:SUPABASE_PROJECT_REF)" -ForegroundColor Green
Write-Host "  - SUPABASE_URL: $($env:SUPABASE_URL)" -ForegroundColor Green
Write-Host "  - DB_CONNECTION_STRING (loaded from .env)" -ForegroundColor Green
Write-Host "  - PSQL_PATH: $($env:PSQL_PATH)" -ForegroundColor Green
Write-Host ""
Write-Host "Ready to use Supabase CLI and psql!" -ForegroundColor Cyan
