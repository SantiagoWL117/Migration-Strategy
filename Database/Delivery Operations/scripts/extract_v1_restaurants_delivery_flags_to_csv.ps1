# Extract delivery flags from menuca_v1_restaurants.sql to CSV
# Source: Database/Delivery Operations/dumps/menuca_v1_restaurants.sql
# Target: Database/Delivery Operations/CSV/menuca_v1_restaurants_delivery_flags.csv
# Note: Extracts only delivery-related columns, excludes deliveryArea BLOB (user approved)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$dumpFile = Join-Path $scriptDir "dumps\menuca_v1_restaurants.sql"
$csvFile = Join-Path $scriptDir "CSV\menuca_v1_restaurants_delivery_flags.csv"

Write-Host "Extracting delivery flags from menuca_v1_restaurants.sql to CSV..." -ForegroundColor Cyan

# Read the SQL dump
$content = Get-Content $dumpFile -Raw

# Find the CREATE TABLE statement to determine column positions
$createTablePattern = "CREATE TABLE \`restaurants\`\s*\((.*?)\)\s*ENGINE"
$createMatch = [regex]::Match($content, $createTablePattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)

if (-not $createMatch.Success) {
    Write-Host "Could not find CREATE TABLE statement!" -ForegroundColor Red
    exit 1
}

# Parse column definitions
$columnDefs = $createMatch.Groups[1].Value
$columnLines = $columnDefs -split "`n" | Where-Object { $_ -match "^\s*\`[a-zA-Z_]" }
$allColumns = @()

foreach ($line in $columnLines) {
    if ($line -match "^\s*\`([a-zA-Z_][a-zA-Z0-9_]*)\`") {
        $allColumns += $matches[1]
    }
}

Write-Host "Found $($allColumns.Count) total columns in restaurants table" -ForegroundColor Yellow

# Define delivery-related columns we want to extract (in order they appear in table)
# Note: deliveryArea BLOB is EXCLUDED per user decision
$deliveryColumns = @(
    "id",
    "deliveryRadius",
    "multipleDeliveryArea",
    "sendToDelivery",
    "sendToDailyDelivery",
    "sendToGeodispatch",
    "geodispatch_username",
    "geodispatch_password",
    "geodispatch_api_key",
    "sendToDelivery_email",
    "restaurant_delivery_charge",
    "tookan_delivery",
    "tookan_tags",
    "tookan_restaurant_email",
    "tookan_delivery_as_pickup",
    "weDeliver",
    "weDeliver_driver_notes",
    "weDeliverEmail",
    "deliveryServiceExtra",
    "use_delivery_areas",
    "delivery_restaurant_id",
    "max_delivery_distance",
    "disable_delivery_until",
    "twilio_call"
)

# Find the index positions of delivery columns in the full column list
$columnIndexes = @{}
foreach ($col in $deliveryColumns) {
    $index = $allColumns.IndexOf($col)
    if ($index -ge 0) {
        $columnIndexes[$col] = $index
        Write-Host "  Column '$col' at position $index" -ForegroundColor Gray
    }
    else {
        Write-Host "  WARNING: Column '$col' not found in table!" -ForegroundColor Yellow
    }
}

# Extract INSERT statements
$insertPattern = "INSERT INTO \`restaurants\` VALUES \((.*?)\);"
$insertMatches = [regex]::Matches($content, $insertPattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)

if ($insertMatches.Count -eq 0) {
    Write-Host "No INSERT statements found!" -ForegroundColor Red
    exit 1
}

Write-Host "Found $($insertMatches.Count) INSERT statements" -ForegroundColor Yellow

# Create CSV with headers
$csvContent = @()
$csvContent += $deliveryColumns -join ","

$totalRows = 0

# Parse each INSERT statement
foreach ($insertMatch in $insertMatches) {
    $values = $insertMatch.Groups[1].Value
    
    # Split by "),(" to handle multiple value sets in one INSERT
    $valueSets = $values -split "\),\("
    
    foreach ($valueSet in $valueSets) {
        # Clean up the value set
        $valueSet = $valueSet.Trim()
        $valueSet = $valueSet -replace "^\(", ""
        $valueSet = $valueSet -replace "\)$", ""
        
        # Parse ALL values from the row
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
        
        # Extract only the delivery-related columns
        $csvValues = @()
        foreach ($col in $deliveryColumns) {
            $index = $columnIndexes[$col]
            if ($index -ge 0 -and $index -lt $parsedValues.Count) {
                $val = $parsedValues[$index]
                
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
            else {
                $csvValues += ""
            }
        }
        
        $csvContent += $csvValues -join ","
        $totalRows++
    }
}

# Write to CSV file
$csvContent | Out-File -FilePath $csvFile -Encoding UTF8

Write-Host "✓ Extracted $totalRows restaurants with delivery flags" -ForegroundColor Green
Write-Host "✓ Columns extracted: $($deliveryColumns.Count)" -ForegroundColor Green
Write-Host "✓ Output: $csvFile" -ForegroundColor Green
Write-Host "" -ForegroundColor Green
Write-Host "NOTE: deliveryArea BLOB column was EXCLUDED per user decision (no data exists)" -ForegroundColor Cyan

