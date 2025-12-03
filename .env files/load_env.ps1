# Load Environment Variables from .env File
# Usage:
#   .\scripts\load_env.ps1                    # Load all variables
#   .\scripts\load_env.ps1 -Show              # Display all variables
#   .\scripts\load_env.ps1 -Get "VAR_NAME"    # Get specific variable

param(
    [Parameter(Mandatory=$false)]
    [switch]$Show,
    
    [Parameter(Mandatory=$false)]
    [string]$Get,
    
    [Parameter(Mandatory=$false)]
    [switch]$Export
)

$envFile = Join-Path $PSScriptRoot "..\.env"

if (-not (Test-Path $envFile)) {
    Write-Host "ERROR: .env file not found at: $envFile" -ForegroundColor Red
    exit 1
}

# Parse .env file
$envVars = @{}
Get-Content $envFile | ForEach-Object {
    $line = $_.Trim()
    
    # Skip empty lines and comments
    if ($line -and -not $line.StartsWith("#")) {
        if ($line -match "^([^=]+)=(.*)$") {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            
            # Remove quotes if present
            $value = $value -replace '^["'']|["'']$', ''
            
            $envVars[$key] = $value
            
            # Export to environment if requested
            if ($Export) {
                [Environment]::SetEnvironmentVariable($key, $value, "Process")
            }
        }
    }
}

# Handle different modes
if ($Get) {
    # Return specific variable
    if ($envVars.ContainsKey($Get)) {
        Write-Output $envVars[$Get]
    } else {
        Write-Host "ERROR: Variable '$Get' not found in .env" -ForegroundColor Red
        exit 1
    }
} elseif ($Show) {
    # Display all variables (mask sensitive values)
    Write-Host ""
    Write-Host "Environment Variables from .env:" -ForegroundColor Cyan
    $separator = "=" * 80
    Write-Host $separator -ForegroundColor Gray
    
    foreach ($key in $envVars.Keys | Sort-Object) {
        $value = $envVars[$key]
        
        # Mask sensitive values
        if ($key -match "PASSWORD|KEY|SECRET|TOKEN") {
            $maskedValue = if ($value.Length -gt 8) {
                $value.Substring(0, 4) + "..." + $value.Substring($value.Length - 4)
            } else {
                "***"
            }
            Write-Host "  $key = $maskedValue" -ForegroundColor Yellow
        } else {
            Write-Host "  $key = $value" -ForegroundColor Green
        }
    }
    
    Write-Host $separator -ForegroundColor Gray
    Write-Host ""
} else {
    # Return hashtable for use in other scripts
    return $envVars
}
