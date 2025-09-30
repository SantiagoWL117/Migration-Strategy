$ErrorActionPreference = 'Stop'

$csvPath = Join-Path $PSScriptRoot '..\Database\Location & Geography Entity\CSV\menuca_v2_cities.csv'
$csvPath = [System.IO.Path]::GetFullPath($csvPath)
if (-not (Test-Path $csvPath)) { throw "CSV not found: $csvPath" }

$backupPath = $csvPath + '.bak'
Copy-Item -Force $csvPath $backupPath

Add-Type -AssemblyName System.Web -ErrorAction SilentlyContinue

function Fix-Mojibake([string]$s) {
  if ([string]::IsNullOrWhiteSpace($s)) { return $s }
  $fixed = $s
  $fixed = $fixed -replace 'Qu\uFFFDbec', 'Québec'
  $fixed = $fixed -replace 'Qu\?bec', 'Québec'
  $fixed = $fixed -replace 'Qu�bec', 'Québec'
  $fixed = $fixed -replace 'L\uFFFDvis', 'Lévis'
  $fixed = $fixed -replace 'L\?vis', 'Lévis'
  $fixed = $fixed -replace 'L�vis', 'Lévis'
  $fixed = $fixed -replace 'Ch\uFFFDteauguay', 'Châteauguay'
  $fixed = $fixed -replace 'Ch\?teauguay', 'Châteauguay'
  $fixed = $fixed -replace 'Ch�teauguay', 'Châteauguay'
  $fixed = $fixed -replace 'Rosem\uFFFDre', 'Rosemère'
  $fixed = $fixed -replace 'Rosem\?re', 'Rosemère'
  $fixed = $fixed -replace 'Rosem�re', 'Rosemère'
  $fixed = $fixed -replace 'Desch\uFFFDnes', 'Deschênes'
  $fixed = $fixed -replace 'Desch\?nes', 'Deschênes'
  $fixed = $fixed -replace 'Desch�nes', 'Deschênes'
  $fixed = $fixed.Normalize([Text.NormalizationForm]::FormC)
  return $fixed
}

$rows = Import-Csv -Delimiter ';' -Path $csvPath

# Fix names and timezones basics
foreach ($row in $rows) {
  $row.name = Fix-Mojibake $row.name
  if ($row.name -eq 'Vaughn') { $row.name = 'Vaughan' }
  if (-not [string]::IsNullOrWhiteSpace($row.timezone)) { $row.timezone = $row.timezone.Trim() }
}

# Build index by id for targeted fixes
$byId = @{}
foreach ($r in $rows) { $byId[$r.id] = $r }

function Set-LatLngTZ([string]$id, [double]$lat, [double]$lng, [string]$tz) {
  if ($byId.ContainsKey($id)) {
    $byId[$id].lat = [string]::Format('{0:0.######}', $lat)
    $byId[$id].lng = [string]::Format('{0:0.######}', $lng)
    if ($tz) { $byId[$id].timezone = $tz }
  }
}

function Set-TZ([string]$id, [string]$tz) {
  if ($byId.ContainsKey($id) -and $tz) { $byId[$id].timezone = $tz }
}

# Known corrections
# Ville de Québec (id 19)
if ($byId.ContainsKey('19')) { $byId['19'].name = 'Ville de Québec'; Set-LatLngTZ '19' 46.813878 -71.207981 'America/Montreal' }
# Smiths Falls (id 24)
if ($byId.ContainsKey('24')) { Set-LatLngTZ '24' 44.9001 -76.021 'America/Toronto' }
# Carleton Place (id 29)
if ($byId.ContainsKey('29')) { Set-LatLngTZ '29' 45.1373 -76.1399 'America/Toronto' }
# Mont-Saint-Hilaire (id 61)
if ($byId.ContainsKey('61')) { Set-LatLngTZ '61' 45.562 -73.189 'America/Montreal' }
# Richmond BC (id 37): timezone + province fix
if ($byId.ContainsKey('37')) { $byId['37'].province_id = '8'; Set-TZ '37' 'America/Vancouver' }

# Province-based timezone normalization
foreach ($r in $rows) {
  switch ($r.province_id) {
    '4' { $r.timezone = 'America/Montreal' } # Quebec
    '3' { if (-not [string]::IsNullOrWhiteSpace($r.timezone)) { $r.timezone = 'America/Toronto' } } # Ontario
    '8' { $r.timezone = 'America/Vancouver' } # BC
    '11' { $r.timezone = 'America/Edmonton' } # Alberta
    '6' { $r.timezone = 'America/Moncton' } # New Brunswick (as in sample for Moncton)
    '23' { $r.timezone = 'America/Whitehorse' }
    '24' { $r.timezone = 'America/Inuvik' }
    default { }
  }
}

# Dedupe by (lower(name), province_id): keep lowest id
$grouped = $rows | Group-Object { ($_.name).ToLowerInvariant() + '|' + ($_.province_id) }
$keepIds = New-Object System.Collections.Generic.HashSet[string]
foreach ($g in $grouped) {
  $ids = $g.Group | ForEach-Object { [int]$_.id } | Sort-Object
  if ($ids.Count -gt 0) { $null = $keepIds.Add([string]$ids[0]) }
}

$deduped = @()
foreach ($r in $rows) {
  if ($keepIds.Contains([string]$r.id)) { $deduped += $r }
}

$deduped | Export-Csv -Delimiter ';' -NoTypeInformation -Encoding UTF8 -Path $csvPath

Write-Host "Updated CSV: $csvPath`nBackup: $backupPath"


