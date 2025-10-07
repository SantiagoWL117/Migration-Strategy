# Convert menuca_v1_tookan_fees.sql to CSV
# Source: Database/Delivery Operations/dumps/menuca_v1_tookan_fees.sql
# Target: Database/Delivery Operations/CSV/menuca_v1_tookan_fees.csv

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$dumpFile = Join-Path $scriptDir "dumps\menuca_v1_tookan_fees.sql"
$csvFile = Join-Path $scriptDir "CSV\menuca_v1_tookan_fees.csv"

Write-Host "Converting menuca_v1_tookan_fees.sql to CSV..." -ForegroundColor Cyan

# Read the SQL dump
$content = Get-Content $dumpFile -Raw

# Extract INSERT statements
$pattern = "INSERT INTO \`tookan_fees\` VALUES \((.*?)\);"
$matches = [regex]::Matches($content, $pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)

if ($matches.Count -eq 0) {
    Write-Host "No INSERT statements found!" -ForegroundColor Red
    exit 1
}

# Define CSV headers based on table structure
$headers = @(
    "id",
    "restaurant_id",
    "area",
    "driver_earnings",
    "restaurant",
    "vendor",
    "total_fare"
)

# Create CSV with headers
$csvContent = @()
$csvContent += $headers -join ","

# Parse each INSERT statement
foreach ($match in $matches) {
    $values = $match.Groups[1].Value
    
    # Split by "),(" to handle multiple value sets in one INSERT
    $valueSets = $values -split "\),\("
    
    foreach ($valueSet in $valueSets) {
        # Clean up the value set
        $valueSet = $valueSet.Trim()
        $valueSet = $valueSet -replace "^\(", ""
        $valueSet = $valueSet -replace "\)$", ""
        
        # Parse values carefully (handle NULL, strings with commas, etc.)
        $parsedValues = @()
        $inString = $false
        $currentValue = ""
        $escaped = $false
        
        for ($i = 0; $i -lt $valueSet.Length; $i++) {
            $char = $valueSet[$i]
            
            if ($escaped) {
                $currentValue += $char
                $escaped = $false
                continue
            }
            
            if ($char -eq '\') {
                $escaped = $true
                $currentValue += $char
                continue
            }
            
            if ($char -eq "'") {
                $inString = -not $inString
                $currentValue += $char
                continue
            }
            
            if ($char -eq ',' -and -not $inString) {
                $parsedValues += $currentValue.Trim()
                $currentValue = ""
                continue
            }
            
            $currentValue += $char
        }
        
        # Add the last value
        if ($currentValue -ne "") {
            $parsedValues += $currentValue.Trim()
        }
        
        # Process each value
        $csvValues = @()
        foreach ($val in $parsedValues) {
            if ($val -eq "NULL" -or $val -eq "") {
                $csvValues += ""
            }
            elseif ($val -match "^'(.*)'$") {
                # Remove quotes and escape internal quotes for CSV
                $cleanVal = $matches[1] -replace "\\'", "'" -replace "`"", "`"`""
                $csvValues += "`"$cleanVal`""
            }
            else {
                $csvValues += $val
            }
        }
        
        $csvContent += $csvValues -join ","
    }
}

# Write to CSV file
$csvContent | Out-File -FilePath $csvFile -Encoding UTF8

$rowCount = $csvContent.Count - 1
Write-Host "✓ Converted $rowCount rows to CSV" -ForegroundColor Green
Write-Host "✓ Output: $csvFile" -ForegroundColor Green

