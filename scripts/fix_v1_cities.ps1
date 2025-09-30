$ErrorActionPreference = 'Stop'

$csvPath = Join-Path $PSScriptRoot '..\Database\Location & Geography Entity\CSV\menuca_v1_cities.csv'
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
  $fixed = $fixed -replace 'L\uFFFDvis', 'Lévis'
  $fixed = $fixed.Normalize([Text.NormalizationForm]::FormC)
  return $fixed
}

function Make-DisplayName([string]$name) {
  if ([string]::IsNullOrWhiteSpace($name)) { return $name }
  $n = $name.Trim()
  $n = $n -replace '\s+', '-'
  $n = $n -replace '-{2,}', '-'
  return $n
}

$rows = Import-Csv -Delimiter ';' -Path $csvPath

# First pass: fix strings, names, display names
foreach ($row in $rows) {
  $row.name = Fix-Mojibake $row.name
  $row.display_name = Fix-Mojibake $row.display_name

  # Misspelling: Vaughn -> Vaughan
  if ($row.name -eq 'Vaughn') { $row.name = 'Vaughan' }

  # If display_name empty or not aligned, rebuild from name
  if ([string]::IsNullOrWhiteSpace($row.display_name)) {
    $row.display_name = Make-DisplayName $row.name
  } else {
    $row.display_name = Make-DisplayName $row.display_name
  }

  # Normalize timezone casing
  if (-not [string]::IsNullOrWhiteSpace($row.timezone)) {
    $row.timezone = $row.timezone.Trim()
  }
}

# Targeted coordinate/timezone corrections by id
$byId = @{}
foreach ($r in $rows) { $byId[$r.id] = $r }

function Set-LatLngTZ([string]$id, [double]$lat, [double]$lng, [string]$tz) {
  if ($byId.ContainsKey($id)) {
    $byId[$id].lat = [string]::Format('{0:0.######}', $lat)
    $byId[$id].lng = [string]::Format('{0:0.######}', $lng)
    if ($tz) { $byId[$id].timezone = $tz }
  }
}

# Ville de Québec (id 16)
if ($byId.ContainsKey('16')) {
  $byId['16'].name = 'Ville de Québec'
  $byId['16'].display_name = 'Ville-de-Québec'
  Set-LatLngTZ '16' 46.813878 -71.207981 'America/Montreal'
}

# Lévis (id 72)
if ($byId.ContainsKey('72')) {
  $byId['72'].name = 'Lévis'; $byId['72'].display_name = 'Lévis'
}

# Châteauguay (id 76)
if ($byId.ContainsKey('76')) {
  $byId['76'].name = 'Châteauguay'; $byId['76'].display_name = 'Châteauguay'
}

# Mont-Saint-Hilaire (id 61) coords/timezone
if ($byId.ContainsKey('61')) { Set-LatLngTZ '61' 45.562 -73.189 'America/Montreal' }

# Carleton Place (id 26) coords
if ($byId.ContainsKey('26')) { Set-LatLngTZ '26' 45.1373 -76.1399 $null }

# Smiths Falls (id 21) coords
if ($byId.ContainsKey('21')) { Set-LatLngTZ '21' 44.9001 -76.0210 $null }

# Richmond, BC (id 37) timezone
if ($byId.ContainsKey('37')) { $byId['37'].timezone = 'America/Vancouver' }

# Standardize Quebec city timezones to America/Montreal if obviously Quebec by name
foreach ($r in $rows) {
  if ($r.name -match 'Québec|Montréal|Lévis|Gatineau|Longueuil|Laval|Brossard|Châteauguay|Terrebonne|Rosemère|Boisbriand|Saint' ) {
    if (-not [string]::IsNullOrWhiteSpace($r.timezone)) { $r.timezone = 'America/Montreal' }
  }
}

# Dedupe by lower(name): keep lowest id, drop others
$grouped = $rows | Group-Object { ($_.name).ToLowerInvariant() }
$keepIds = New-Object System.Collections.Generic.HashSet[string]
foreach ($g in $grouped) {
  $ids = $g.Group | ForEach-Object { [int]$_.id } | Sort-Object
  if ($ids.Count -gt 0) { $null = $keepIds.Add([string]$ids[0]) }
}

$deduped = @()
foreach ($r in $rows) {
  if ($keepIds.Contains([string]$r.id)) { $deduped += $r }
  else {
    # drop duplicates (e.g., Calgary second instance id 65)
  }
}

# Save back as UTF-8
$deduped | Export-Csv -Delimiter ';' -NoTypeInformation -Encoding UTF8 -Path $csvPath

Write-Host "Updated CSV: $csvPath`nBackup: $backupPath"


