$ErrorActionPreference = 'Stop'

# Input CSV path
$csvPath = Join-Path $PSScriptRoot '..\Database\Restaurant Management Entity\restaurants_locations\CSV\menuca_v2_restaurants_locations.csv'
$csvPath = [System.IO.Path]::GetFullPath($csvPath)

if (-not (Test-Path $csvPath)) {
  throw "CSV not found: $csvPath"
}

# Backup original
$backupPath = $csvPath + '.bak'
Copy-Item -Force $csvPath $backupPath

function Normalize-Phone([string]$p) {
  if ([string]::IsNullOrWhiteSpace($p)) { return '' }
  $token = ($p -split '<br\s*/?>|\r?\n|,|;|\||/|\t|\s{2,}')[0].Trim()
  if ([string]::IsNullOrWhiteSpace($token)) { return '' }
  $digits = ($token -replace '[^0-9]', '')
  if ($digits.Length -ge 11 -and $digits[0] -eq '1') {
    $digits = $digits.Substring(1, 10)
  } elseif ($digits.Length -ge 10) {
    $digits = $digits.Substring($digits.Length - 10, 10)
  } else {
    return ''
  }
  return "({0}) {1}-{2}" -f $digits.Substring(0,3), $digits.Substring(3,3), $digits.Substring(6,4)
}

function Normalize-Zip([string]$z) {
  if ([string]::IsNullOrWhiteSpace($z)) { return '' }
  $raw = ($z.ToUpper() -replace '[^A-Z0-9]', '')
  if ($raw.Length -ge 6) { return $raw.Substring(0,3) + ' ' + $raw.Substring(3,3) }
  elseif ($raw.Length -eq 0) { return '' }
  else { return $raw }
}

# Load, transform, save
$rows = Import-Csv -Delimiter ';' -Path $csvPath
foreach ($row in $rows) {
  if ($row.PSObject.Properties.Name -contains 'phone') { $row.phone = Normalize-Phone $row.phone }
  if ($row.PSObject.Properties.Name -contains 'zip') { $row.zip = Normalize-Zip $row.zip }
}

$rows | Export-Csv -Delimiter ';' -NoTypeInformation -Encoding UTF8 -Path $csvPath

Write-Host "Updated CSV: $csvPath`nBackup: $backupPath"


