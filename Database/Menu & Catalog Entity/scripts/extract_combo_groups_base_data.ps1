# Extract non-BLOB columns from combo_groups hex CSV
# Purpose: Get id, name, restaurant, lang for combo_groups base table

$inputFile = "Database/Menu & Catalog Entity/CSV/menuca_v1_combo_groups_hex.csv"
$outputFile = "Database/Menu & Catalog Entity/CSV/menuca_v1_combo_groups_base_clean.csv"

Write-Host "Reading hex CSV..." -ForegroundColor Cyan
$data = Import-Csv $inputFile

Write-Host "Total rows: $($data.Count)" -ForegroundColor Yellow

# Extract only non-BLOB columns and filter for valid names
$cleanData = $data | Where-Object {
    $_.name -and $_.name -ne '' -and $_.name -ne 'empty'
} | Select-Object id, name, restaurant

Write-Host "Rows with valid names (excluding 'empty'): $($cleanData.Count)" -ForegroundColor Yellow

# Export to CSV
$cleanData | Export-Csv -Path $outputFile -NoTypeInformation -Encoding UTF8

Write-Host "`n✅ Created: $outputFile" -ForegroundColor Green
Write-Host "Rows exported: $($cleanData.Count)" -ForegroundColor Green

# Show sample
Write-Host "`nFirst 5 rows:" -ForegroundColor Cyan
$cleanData | Select-Object -First 5 | Format-Table -AutoSize



