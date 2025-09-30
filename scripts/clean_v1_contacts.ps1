if ($args.Count -lt 1) {
  throw "Usage: clean_v1_contacts.ps1 <path-to-csv>"
}
$Path = $args[0]

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Remove-Cf {
  param([string]$s)
  if ($null -eq $s) { return $null }
  return ([regex]::Replace($s, '\p{Cf}', ''))
}

function Collapse-Whitespace {
  param([string]$s)
  if ($null -eq $s) { return $null }
  return ([regex]::Replace($s.Trim(), '\s+', ' '))
}

function Remove-Diacritics {
  param([string]$s)
  if ($null -eq $s) { return $null }
  $formD = $s.Normalize([Text.NormalizationForm]::FormD)
  $sb = New-Object System.Text.StringBuilder
  foreach ($ch in $formD.ToCharArray()) {
    if ([Globalization.CharUnicodeInfo]::GetUnicodeCategory($ch) -ne [Globalization.UnicodeCategory]::NonSpacingMark) {
      [void]$sb.Append($ch)
    }
  }
  return $sb.ToString().Normalize([Text.NormalizationForm]::FormC)
}

function Sanitize-Text {
  param([string]$s)
  if ($null -eq $s) { return $null }
  $t = Remove-Cf $s
  $t = $t -replace "`uFFFD", ''
  $t = Collapse-Whitespace $t
  return $t
}

function Normalize-Title {
  param([string]$t)
  if ($null -eq $t) { return $null }
  $t2 = Sanitize-Text $t
  if ([string]::IsNullOrWhiteSpace($t2)) { return 'owner' }
  $t2 = $t2.ToLower()
  if ($t2 -match 'manager') { return 'manager' }
  return 'owner'
}

function Normalize-Phone {
  param([string]$p)
  if ($null -eq $p) { return $null }
  $x = Remove-Cf $p
  $x = $x -replace '(?i)\b(cell|store|home|work|fax|ext|x|telephone|tel|CELL)\b',''
  $x = $x -replace '[^0-9]',''
  if ([string]::IsNullOrWhiteSpace($x)) { return $null }
  if ($x.Length -ge 11 -and $x.StartsWith('1')) { $x = $x.TrimStart('1') }
  if ($x.Length -ge 10) {
    $digits = $x.Substring(0,10)
    return ('({0}) {1}-{2}' -f $digits.Substring(0,3), $digits.Substring(3,3), $digits.Substring(6,4))
  }
  return $x
}

function Remove-Diacritics-IfNeeded {
  param([string]$s)
  if ($null -eq $s) { return $null }
  return (Remove-Diacritics $s)
}

function Get-FullPath([string]$p) {
  if ([System.IO.Path]::IsPathRooted($p)) { return $p }
  return (Join-Path -Path (Get-Location) -ChildPath $p)
}

$inPath  = Get-FullPath $Path
if (-not (Test-Path -LiteralPath $inPath)) {
  throw "File not found: $inPath"
}

# Import using semicolon delimiter
$rows = Import-Csv -LiteralPath $inPath -Delimiter ';' -Encoding UTF8

# Process rows
$processed = @()
foreach ($row in $rows) {
  # Preserve original for special-case contact
  $origContact = $row.contact

  # Sanitize basic fields
  $contact = $origContact
  $title   = $row.title
  $phone   = $row.phone
  $email   = $row.email
  $restId  = $row.restaurant
  $id      = $row.id

  $isSpecialContact = ($null -ne $contact -and $contact -eq 'Linda Brunet / Nazrul')

  if (-not $isSpecialContact) {
    $contact = Sanitize-Text $contact
    $contact = Remove-Diacritics-IfNeeded $contact
  }

  $title   = Normalize-Title $title
  $phone   = Normalize-Phone $phone
  $email   = (Sanitize-Text $email)
  if ($email) { $email = $email.ToLower() -replace '\s','' }

  # Filter: delete rows with no contact value
  if ([string]::IsNullOrWhiteSpace($contact)) { continue }

  # Build output object preserving column order
  $obj = [pscustomobject]@{
    id         = [int]$id
    restaurant = $restId
    contact    = $contact
    title      = $title
    phone      = $phone
    email      = $email
  }
  $processed += $obj
}

# Reindex ids continuously starting at 1, ordered by original id
$processed = $processed | Sort-Object { $_.id }
$i = 1
foreach ($r in $processed) { $r.id = $i; $i++ }

$dir = [System.IO.Path]::GetDirectoryName($inPath)
$name = [System.IO.Path]::GetFileName($inPath)
$outPath = [System.IO.Path]::Combine($dir, ("cleaned_" + $name))

# Export consistently as UTF-8 with semicolon delimiter
$processed | Export-Csv -LiteralPath $outPath -Delimiter ';' -NoTypeInformation -Encoding UTF8

# Replace original atomically
Move-Item -LiteralPath $outPath -Destination $inPath -Force

Write-Host "Cleaned and updated: $inPath"



