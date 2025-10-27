# ============================================================================
# PowerShell Helper Script: Restaurant Admin Users Archive
# ============================================================================
# Purpose: Easy execution of archive scripts on Windows
# Usage: .\execute-archive.ps1 [script-number]
# ============================================================================

param(
    [Parameter(Position=0)]
    [string]$ScriptNumber = "00"
)

# Configuration
$PSQL_PATH = "C:\Program Files\PostgreSQL\17\bin\psql.exe"
$CONNECTION_STRING = "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres"

# Color output functions
function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ $Message" -ForegroundColor Cyan
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠ $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

# Check if psql exists
if (-not (Test-Path $PSQL_PATH)) {
    Write-Error "PostgreSQL client not found at: $PSQL_PATH"
    Write-Info "Please install PostgreSQL or update the PSQL_PATH variable"
    exit 1
}

# Script mapping
$scripts = @{
    "00" = "00-MASTER-EXECUTE-ALL.sql"
    "01" = "01-create-archive-backup.sql"
    "02" = "02-migration-audit-report.sql"
    "03" = "03-historical-analytics.sql"
    "04" = "04-user-preferences-extraction.sql"
    "05" = "05-deprecate-table.sql"
    "06" = "06-final-deletion.sql"
}

$descriptions = @{
    "00" = "Master Script (Runs All Phase 1)"
    "01" = "Create Archive Backup"
    "02" = "Migration Audit Report"
    "03" = "Historical Analytics"
    "04" = "User Preferences Extraction"
    "05" = "Deprecate Table (Phase 2)"
    "06" = "Final Deletion (Phase 3)"
}

# Display menu if no argument provided
if ($ScriptNumber -eq "") {
    Write-Host ""
    Write-Host "============================================================================" -ForegroundColor Cyan
    Write-Host "Restaurant Admin Users Archive & Migration" -ForegroundColor Cyan
    Write-Host "============================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Available scripts:" -ForegroundColor White
    Write-Host ""

    foreach ($key in $scripts.Keys | Sort-Object) {
        $phase = if ($key -le "04") { "Phase 1" } elseif ($key -eq "05") { "Phase 2" } else { "Phase 3" }
        Write-Host "  [$key] $($descriptions[$key])" -ForegroundColor White -NoNewline
        Write-Host " ($phase)" -ForegroundColor Gray
    }

    Write-Host ""
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  .\execute-archive.ps1 00    # Run master script (recommended)" -ForegroundColor Gray
    Write-Host "  .\execute-archive.ps1 01    # Run individual script" -ForegroundColor Gray
    Write-Host ""

    $ScriptNumber = Read-Host "Enter script number to execute (or 'q' to quit)"

    if ($ScriptNumber -eq "q") {
        exit 0
    }
}

# Validate script number
if (-not $scripts.ContainsKey($ScriptNumber)) {
    Write-Error "Invalid script number: $ScriptNumber"
    Write-Info "Valid options: $($scripts.Keys -join ', ')"
    exit 1
}

$scriptFile = $scripts[$ScriptNumber]
$scriptPath = Join-Path $PSScriptRoot $scriptFile

# Check if script file exists
if (-not (Test-Path $scriptPath)) {
    Write-Error "Script file not found: $scriptPath"
    exit 1
}

# Display execution info
Write-Host ""
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "Executing: $($descriptions[$ScriptNumber])" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Info "Script: $scriptFile"
Write-Info "Database: nthpbtdjhhnwfxqsxbvy.supabase.co"
Write-Host ""

# Warning for destructive operations
if ($ScriptNumber -eq "05") {
    Write-Warning "This will DEPRECATE the restaurant_admin_users table"
    Write-Warning "The table will be renamed but NOT deleted"
    Write-Host ""
    $confirm = Read-Host "Continue? (yes/no)"
    if ($confirm -ne "yes") {
        Write-Info "Aborted by user"
        exit 0
    }
} elseif ($ScriptNumber -eq "06") {
    Write-Warning "THIS WILL PERMANENTLY DELETE THE TABLE"
    Write-Warning "This action CANNOT be undone"
    Write-Host ""
    $confirm = Read-Host "Type 'DELETE PERMANENTLY' to confirm"
    if ($confirm -ne "DELETE PERMANENTLY") {
        Write-Info "Aborted by user"
        exit 0
    }
}

# Execute the script
Write-Info "Connecting to database..."
Write-Host ""

try {
    & $PSQL_PATH $CONNECTION_STRING -f $scriptPath

    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Success "Script completed successfully"

        # Show next steps
        if ($ScriptNumber -eq "00" -or $ScriptNumber -eq "04") {
            Write-Host ""
            Write-Host "Next Steps:" -ForegroundColor Yellow
            Write-Host "  1. Review the audit reports above" -ForegroundColor Gray
            Write-Host "  2. Verify archive tables were created" -ForegroundColor Gray
            Write-Host "  3. Monitor systems for 1-3 months" -ForegroundColor Gray
            Write-Host "  4. When ready, run: .\execute-archive.ps1 05" -ForegroundColor Gray
        } elseif ($ScriptNumber -eq "05") {
            Write-Host ""
            Write-Host "Next Steps:" -ForegroundColor Yellow
            Write-Host "  1. Table has been deprecated" -ForegroundColor Gray
            Write-Host "  2. Monitor systems for 6+ months" -ForegroundColor Gray
            Write-Host "  3. When ready for final deletion, run: .\execute-archive.ps1 06" -ForegroundColor Gray
        } elseif ($ScriptNumber -eq "06") {
            Write-Host ""
            Write-Success "Migration complete! Table has been permanently deleted."
            Write-Info "Archive tables remain for historical reference"
        }
    } else {
        Write-Error "Script failed with exit code: $LASTEXITCODE"
        exit $LASTEXITCODE
    }
} catch {
    Write-Error "Error executing script: $_"
    exit 1
}

Write-Host ""
Write-Host "============================================================================" -ForegroundColor Cyan
