# Convert menuca_v2_restaurants_delivery_areas.sql to CSV
# Source: Database/Delivery Operations/dumps/menuca_v2_restaurants_delivery_areas.sql
# Target: Database/Delivery Operations/CSV/menuca_v2_restaurants_delivery_areas.csv
# Note: Excludes BLOB geometry column, preserves TEXT coords column

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$dumpFile = Join-Path $scriptDir "dumps\menuca_v2_restaurants_delivery_areas.sql"
$csvFile = Join-Path $scriptDir "CSV\menuca_v2_restaurants_delivery_areas.csv"

Write-Host "Converting menuca_v2_restaurants_delivery_areas.sql to CSV..." -ForegroundColor Cyan

# Read the SQL dump
$content = Get-Content $dumpFile -Raw

# Extract INSERT statements
$pattern = "INSERT INTO \`restaurants_delivery_areas\` VALUES \((.*?)\);"
$matches = [regex]::Matches($content, $pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)

if ($matches.Count -eq 0) {
    Write-Host "No INSERT statements found!" -ForegroundColor Red
    exit 1
}

# Define CSV headers based on table structure (excluding BLOB geometry)
$headers = @(
    "id",
    "restaurant_id",
    "area_number",
    "area_name",
    "delivery_fee",
    "min_order_value",
    "is_complex",
    "coords"
)

# Create CSV with headers
$csvContent = @()
$csvContent += $headers -join ","

$totalRows = 0
$skippedGeometry = 0

# Parse each INSERT statement
foreach ($match in $matches) {
    $values = $match.Groups[1].Value
    
    # Split by "),(" to handle multiple value sets in one INSERT
    # Special handling: Some rows may have _binary for geometry
    $valueSets = @()
    $currentSet = ""
    $depth = 0
    $inBinary = $false
    
    for ($i = 0; $i -lt $values.Length; $i++) {
        $char = $values[$i]
        
        if ($values.Substring($i).StartsWith("_binary")) {
            $inBinary = $true
        }
        
        if ($char -eq '(') { $depth++ }
        if ($char -eq ')') { $depth-- }
        
        if ($char -eq ')' -and $depth -eq -1) {
            # End of current value set
            $valueSets += $currentSet
            $currentSet = ""
            $depth = 0
            
            # Skip the "),(" separator
            if ($i + 2 -lt $values.Length -and $values.Substring($i, 3) -eq "),(") {
                $i += 2
            }
            continue
        }
        
        $currentSet += $char
    }
    
    # Add the last set
    if ($currentSet.Trim() -ne "") {
        $valueSets += $currentSet
    }
    
    foreach ($valueSet in $valueSets) {
        # Clean up the value set
        $valueSet = $valueSet.Trim()
        $valueSet = $valueSet -replace "^\(", ""
        $valueSet = $valueSet -replace "\)$", ""
        
        # Parse values carefully
        # Expected format: id, restaurant_id, area_number, area_name, delivery_fee, min_order_value, is_complex, coords, geometry
        # We want to extract the first 8 values and SKIP the geometry BLOB
        
        $parsedValues = @()
        $inString = $false
        $currentValue = ""
        $escaped = $false
        $valueCount = 0
        
        for ($i = 0; $i -lt $valueSet.Length; $i++) {
            $char = $valueSet[$i]
            
            # Check if we're starting a _binary BLOB
            if ($valueCount -eq 8 -and $valueSet.Substring($i).StartsWith("_binary")) {
                # Skip the rest (geometry BLOB)
                $skippedGeometry++
                break
            }
            
            if ($valueCount -eq 8 -and $currentValue.Trim().StartsWith("NULL")) {
                # Geometry is NULL, we can stop here
                break
            }
            
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
                $valueCount++
                
                # Stop after coords (8th column, index 7)
                if ($valueCount -eq 8) {
                    break
                }
                continue
            }
            
            $currentValue += $char
        }
        
        # Add the last value if we haven't reached 8 yet
        if ($valueCount -lt 8 -and $currentValue -ne "") {
            $parsedValues += $currentValue.Trim()
        }
        
        # Ensure we have exactly 8 values
        while ($parsedValues.Count -lt 8) {
            $parsedValues += ""
        }
        
        # Process each value for CSV
        $csvValues = @()
        for ($i = 0; $i -lt 8; $i++) {
            $val = $parsedValues[$i]
            
            if ($val -eq "NULL" -or $val -eq "") {
                $csvValues += ""
            }
            elseif ($val -match "^'(.*)'$") {
                # Remove quotes and escape internal quotes for CSV
                $cleanVal = $matches[1] -replace "\\'", "'" -replace "`"", "`"`""
                # Escape double quotes for CSV
                $cleanVal = $cleanVal -replace "`"", "`"`""
                $csvValues += "`"$cleanVal`""
            }
            else {
                $csvValues += $val
            }
        }
        
        $csvContent += $csvValues -join ","
        $totalRows++
    }
}

# Write to CSV file
$csvContent | Out-File -FilePath $csvFile -Encoding UTF8

Write-Host "✓ Converted $totalRows delivery areas to CSV" -ForegroundColor Green
Write-Host "✓ Columns extracted: 8 (excluding geometry BLOB)" -ForegroundColor Green
if ($skippedGeometry -gt 0) {
    Write-Host "✓ Skipped $skippedGeometry geometry BLOB values (will be rebuilt from coords in Phase 4)" -ForegroundColor Yellow
}
Write-Host "✓ Output: $csvFile" -ForegroundColor Green
Write-Host "" -ForegroundColor Green
Write-Host "NOTE: PostGIS geometry will be rebuilt from 'coords' column during transformation" -ForegroundColor Cyan

