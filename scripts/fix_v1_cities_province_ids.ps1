$ErrorActionPreference = 'Stop'

$v1Path = Join-Path $PSScriptRoot '..\Database\Location & Geography Entity\CSV\menuca_v1_cities.csv'
$provPath = Join-Path $PSScriptRoot '..\Database\Location & Geography Entity\CSV\menuca_v2_provincies.csv'
$v1Path = [System.IO.Path]::GetFullPath($v1Path)
$provPath = [System.IO.Path]::GetFullPath($provPath)
if (-not (Test-Path $v1Path)) { throw "v1 cities CSV not found: $v1Path" }
if (-not (Test-Path $provPath)) { throw "provinces CSV not found: $provPath" }

# Backup
$backupPath = $v1Path + '.bak'
Copy-Item -Force $v1Path $backupPath

$provs = Import-Csv -Delimiter ';' -Path $provPath

# Map short_name -> id
$codeToId = @{}
foreach ($p in $provs) {
  $code = ($p.'short_name').ToLowerInvariant().Trim()
  if (-not [string]::IsNullOrWhiteSpace($code)) { $codeToId[$code] = [int]$p.id }
}

# Timezone -> province code
$tzToCode = @{
  'America/Montreal'   = 'qc'
  'America/Toronto'    = 'on'
  'America/Vancouver'  = 'bc'
  'America/Edmonton'   = 'ab'
  'America/Moncton'    = 'nb'
  'America/Whitehorse' = 'yt'
  'America/Inuvik'     = 'nt'
}

# City name -> province code (extend as needed)
$nameToCode = @{}
function AddMap($names, $code) { foreach($n in $names){ if($n){ $nameToCode[$n.ToLowerInvariant()] = $code } } }

# Ontario
AddMap @('Kanata','Ottawa','Orleans','Downtown Ottawa','Toronto','London','Almonte','Stittsville','Greely','Nepean','Gloucester','Smiths Falls','Kemptville','Cornwall','Winchester','Casselman','Carleton Place','North York','Mississauga','Scarborough','Guelph','Kitchener','Bourget','Alfred','Renfrew','Cobden','Oshawa','Osgoode','Etobicoke','Kingston','Vaughan','Sudbury','North Bay','Arnprior','Beachburg','Metcalfe','Barrhaven','Pembroke','Cambridge','Perth','Embrun','Morrisburg','Rockland','Petawawa','Merrickville','Breslau','North Gower','Russell','Westport','Prescott','Port Hope','Cobourg','Lakefield','Barrie','Orillia','Burlington') 'on'

# Quebec (handle mojibake variants too)
AddMap @('Ville de Québec','Ville de QuÃ©bec','Quebec','Montréal','Montreal','Gatineau','Lachine','Pierrefonds','Dorval','Rosemère','RosemÃ¨re','Charny','Terrebonne','Longueuil','Saint-Jean-sur-Richelieu','Greenfield Park','Saint-Constant','Saint-Hyacinthe','Brossard','Saint-Hubert','La Prairie','Laval','LaSalle','Mont-Saint-Hilaire','Saint Lazare','Sainte-Julie','Beloeil','Salaberry-de-Valleyfield','Saint-Luc','Les Coteaux','Vaudreuil-Dorion','Lévis','LÃ©vis','Châteauguay','ChÃ¢teauguay','Boisbriand','Magog','Saint Philippe','Val-des-Monts','Buckingham','Hull') 'qc'

# BC / AB / NB / YT / NT
AddMap @('Richmond','Vancouver') 'bc'
AddMap @('Edmonton','Calgary') 'ab'
AddMap @('Moncton') 'nb'
AddMap @('Whitehorse') 'yt'
AddMap @('Inuvik') 'nt'

$rows = Import-Csv -Delimiter ';' -Path $v1Path

# Ensure province_id column exists by adding a NoteProperty if missing
foreach ($r in $rows) {
  if (-not ($r.PSObject.Properties.Name -contains 'province_id')) {
    $r | Add-Member -NotePropertyName 'province_id' -NotePropertyValue ''
  }
}

foreach ($r in $rows) {
  $name = ($r.name).Trim()
  $tz = $r.timezone
  $code = $null
  if ($name) { $code = $nameToCode[$name.ToLowerInvariant()] }
  if (-not $code -and $tz -and $tzToCode.ContainsKey($tz)) { $code = $tzToCode[$tz] }
  if ($code -and $codeToId.ContainsKey($code)) { $r.province_id = [string]$codeToId[$code] }
}

$rows | Export-Csv -Delimiter ';' -NoTypeInformation -Encoding UTF8 -Path $v1Path

Write-Host "Updated v1 cities province_id using provinces IDs. Backup: $backupPath"


