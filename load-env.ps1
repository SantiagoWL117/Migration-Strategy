# Load Environment Variables from .env file
# Usage: . .\load-env.ps1

$envFile = Join-Path $PSScriptRoot ".env"

if (-not (Test-Path $envFile)) {
    Write-Host "❌ ERROR: .env file not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please create a .env file from the template:" -ForegroundColor Yellow
    Write-Host "  1. Copy env.template to .env" -ForegroundColor Yellow
    Write-Host "  2. Fill in your actual credentials" -ForegroundColor Yellow
    Write-Host "  3. Run this script again" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

Write-Host "📦 Loading environment variables from .env..." -ForegroundColor Cyan

$loadedCount = 0
$errorCount = 0

Get-Content $envFile | ForEach-Object {
    $line = $_.Trim()
    
    # Skip comments and empty lines
    if ($line -match '^#' -or $line -eq '') {
        return
    }
    
    # Parse KEY=VALUE
    if ($line -match '^([A-Z_][A-Z0-9_]*)=(.*)$') {
        $key = $matches[1]
        $value = $matches[2]
        
        # Remove quotes if present
        $value = $value -replace '^["'']|["'']$', ''
        
        # Check for placeholder values
        if ($value -match 'your-.*-here' -or $value -eq '') {
            Write-Host "  ⚠️  $key is not set (placeholder value)" -ForegroundColor Yellow
            $errorCount++
        } else {
            [System.Environment]::SetEnvironmentVariable($key, $value, 'Process')
            Write-Host "  ✓ $key" -ForegroundColor Green
            $loadedCount++
        }
    }
}

Write-Host ""
if ($errorCount -gt 0) {
    Write-Host "⚠️  Warning: $errorCount variable(s) have placeholder values" -ForegroundColor Yellow
    Write-Host "   Please update your .env file with actual credentials" -ForegroundColor Yellow
}

Write-Host "✅ Loaded $loadedCount environment variable(s)" -ForegroundColor Green
Write-Host ""

# Verify critical variables
$criticalVars = @(
    'SUPABASE_DB_PASSWORD',
    'SUPABASE_SERVICE_ROLE_KEY',
    'SUPABASE_ACCESS_TOKEN'
)

$missingVars = @()
foreach ($var in $criticalVars) {
    $value = [System.Environment]::GetEnvironmentVariable($var, 'Process')
    if (-not $value -or $value -match 'your-.*-here') {
        $missingVars += $var
    }
}

if ($missingVars.Count -gt 0) {
    Write-Host "❌ CRITICAL: Missing required variables:" -ForegroundColor Red
    $missingVars | ForEach-Object { Write-Host "   - $_" -ForegroundColor Red }
    Write-Host ""
    Write-Host "Please update your .env file and try again." -ForegroundColor Yellow
    exit 1
}

Write-Host "🔐 All critical variables are set" -ForegroundColor Green
Write-Host ""

