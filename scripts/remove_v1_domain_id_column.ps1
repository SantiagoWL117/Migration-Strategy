param(
  [string]$Path = "Database/Restaurant Management Entity/restaurant_domains/CSV/menuca_v1_restaurants_domains.csv"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (!(Test-Path -LiteralPath $Path)) { throw "File not found: $Path" }

$rows = Import-Csv -Delimiter ';' -LiteralPath $Path

# Keep only restaurant and domain columns
$rows | Select-Object restaurant, domain |
  Export-Csv -Delimiter ';' -LiteralPath $Path -NoTypeInformation -Encoding UTF8

# Verify header
$sample = Import-Csv -Delimiter ';' -LiteralPath $Path | Select-Object -First 1
$hasId = $false
if ($sample) { $hasId = $sample.psobject.Properties.Name -contains 'id' }
Write-Output ("HAS_ID_COLUMN=" + $hasId)


