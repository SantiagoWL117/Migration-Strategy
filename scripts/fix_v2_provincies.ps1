$ErrorActionPreference = 'Stop'

$csvPath = Join-Path $PSScriptRoot '..\Database\Location & Geography Entity\CSV\menuca_v2_provincies.csv'
$csvPath = [System.IO.Path]::GetFullPath($csvPath)
if (-not (Test-Path $csvPath)) { throw "CSV not found: $csvPath" }

$backupPath = $csvPath + '.bak'
Copy-Item -Force $csvPath $backupPath

Add-Type -AssemblyName System.Web -ErrorAction SilentlyContinue

function Fix-Mojibake([string]$s) {
  if ([string]::IsNullOrWhiteSpace($s)) { return $s }
  $fixed = $s
  $fixed = $fixed -replace 'Qu\?bec', 'Québec'
  $fixed = $fixed -replace 'Qu�bec', 'Québec'
  $fixed = $fixed -replace 'Nouvelle-\?cosse', 'Nouvelle-Écosse'
  $fixed = $fixed -replace 'Nouvelle-�cosse', 'Nouvelle-Écosse'
  $fixed = $fixed -replace '�le-du-Prince-�douard', 'Île-du-Prince-Édouard'
  $fixed = $fixed -replace 'L\?le-du-Prince-\?douard', 'Île-du-Prince-Édouard'
  $fixed = $fixed -replace 'Colombie-Britannique', 'Colombie-Britannique'
  $fixed = $fixed -replace 'Les Territoires du Nord-Ouest', 'Les Territoires du Nord-Ouest'
  $fixed = $fixed -replace 'Desch\?nes', 'Deschênes'
  $fixed = $fixed.Normalize([Text.NormalizationForm]::FormC)
  return $fixed
}

# Canonical code -> English/French names
$canonical = @{
  'on' = @{ en = 'Ontario';                      fr = 'Ontario' }
  'qc' = @{ en = 'Quebec';                       fr = 'Québec' }
  'ns' = @{ en = 'Nova Scotia';                  fr = 'Nouvelle-Écosse' }
  'nb' = @{ en = 'New Brunswick';                fr = 'Nouveau-Brunswick' }
  'mb' = @{ en = 'Manitoba';                     fr = 'Manitoba' }
  'bc' = @{ en = 'British Columbia';             fr = 'Colombie-Britannique' }
  'pe' = @{ en = 'Prince Edward Island';         fr = 'Île-du-Prince-Édouard' }
  'sk' = @{ en = 'Saskatchewan';                 fr = 'Saskatchewan' }
  'ab' = @{ en = 'Alberta';                      fr = 'Alberta' }
  'nl' = @{ en = 'Newfoundland and Labrador';    fr = 'Terre-Neuve-et-Labrador' }
  'yt' = @{ en = 'Yukon';                        fr = 'Yukon' }
  'nt' = @{ en = 'Northwest Territories';        fr = 'Les Territoires du Nord-Ouest' }
  'nu' = @{ en = 'Nunavut';                      fr = 'Nunavut' }
}

# Reverse lookups from names to codes (en & fr)
$nameToCode = @{}
foreach ($kv in $canonical.GetEnumerator()) {
  $code = $kv.Key
  $en = $kv.Value.en
  $fr = $kv.Value.fr
  $nameToCode[$en.ToLowerInvariant()] = $code
  $nameToCode[$fr.ToLowerInvariant()] = $code
}

$rows = Import-Csv -Delimiter ';' -Path $csvPath

# Aggregate by code
$byCode = @{}
foreach ($row in $rows) {
  $name = Fix-Mojibake(($row.name | ForEach-Object { $_ }) )
  $name = if ($name) { $name.Trim() -replace '\s{2,}', ' ' } else { '' }
  $short = ($row.short_name | ForEach-Object { $_ })
  $short = if ($short) { $short.Trim().ToLowerInvariant() } else { '' }
  if ($short -eq 'nwt' -or $short -eq 'tno') { $short = 'nt' }
  if ($short -eq '') {
    $lookupCode = $nameToCode[$name.ToLowerInvariant()]
    if ($lookupCode) { $short = $lookupCode }
  }
  # Validate code
  if (-not $canonical.ContainsKey($short)) {
    # Try inference from name if code invalid
    $try = $nameToCode[$name.ToLowerInvariant()]
    if ($try) { $short = $try } else { continue }
  }
  if (-not $byCode.ContainsKey($short)) {
    $byCode[$short] = [ordered]@{ en = $null; fr = $null }
  }
  # Decide if this name is English or French
  $canon = $canonical[$short]
  if ($name -eq $canon.en) { $byCode[$short].en = $canon.en }
  elseif ($name -eq $canon.fr) { $byCode[$short].fr = $canon.fr }
  else {
    # Heuristic: non-ASCII -> fr; otherwise en
    if ($name -match '[^\u0000-\u007F]') { $byCode[$short].fr = $name } else { $byCode[$short].en = $name }
  }
}

# Build final ordered list of codes to output
$order = @('on','qc','ns','nb','mb','bc','pe','sk','ab','nl','yt','nt','nu')
$out = @()
$id = 1
foreach ($code in $order) {
  if (-not $canonical.ContainsKey($code)) { continue }
  $canon = $canonical[$code]
  $agg = $byCode[$code]
  $en = if ($agg -and $agg.en) { $agg.en } else { $canon.en }
  $fr = if ($agg -and $agg.fr) { $agg.fr } else { $canon.fr }
  $out += [pscustomobject]@{
    'id' = $id
    'Name (English)' = $en
    'Nom(Française)' = $fr
    'short_name' = $code
  }
  $id++
}

# Write back as UTF-8 with semicolon delimiter and new headers
$out | Export-Csv -Delimiter ';' -NoTypeInformation -Encoding UTF8 -Path $csvPath

Write-Host "Updated CSV: $csvPath`nBackup: $backupPath"


