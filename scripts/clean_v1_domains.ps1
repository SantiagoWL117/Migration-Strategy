param(
  [string]$InputPath,
  [string]$OutputPath,
  [string]$InvalidReportPath = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (!(Test-Path -LiteralPath $InputPath)) {
  throw "Input file not found: $InputPath"
}

$regexValid = '^[a-z0-9-]+(\.[a-z0-9-]+)+$'

function Normalize-Domain([string]$domain) {
  if ([string]::IsNullOrWhiteSpace($domain)) { return '' }

  $d = $domain.Trim().ToLowerInvariant()

  # strip protocol
  $d = [regex]::Replace($d, '^(https?://)', '')
  # strip leading www.
  $d = [regex]::Replace($d, '^www\.', '')
  # strip trailing slashes
  $d = [regex]::Replace($d, '/+$', '')

  # fix common typos
  $d = [regex]::Replace($d, '\.mene(\.ca\b)', '.menu$1')
  $d = [regex]::Replace($d, '\.orgg\b', '.org')

  # remove invalid characters (keep only a-z, 0-9, dot, hyphen)
  $d = [regex]::Replace($d, '[^a-z0-9\.-]', '')

  # collapse duplicates
  $d = [regex]::Replace($d, '\.{2,}', '.')
  $d = [regex]::Replace($d, '-{2,}', '-')

  # trim leading/trailing dot or hyphen
  $d = [regex]::Replace($d, '^[\.-]+', '')
  $d = [regex]::Replace($d, '[\.-]+$', '')

  return $d
}

$rows = Import-Csv -Delimiter ';' -LiteralPath $InputPath

$cleaned = foreach ($row in $rows) {
  $orig = $row.domain
  $norm = Normalize-Domain $orig

  # keep lowercase always (already enforced)
  $row | Add-Member -NotePropertyName domain_original -NotePropertyValue $orig -Force
  $row.domain = $norm
  $row
}

# ensure output directory exists
$outDir = [System.IO.Path]::GetDirectoryName($OutputPath)
if ($outDir -and !(Test-Path -LiteralPath $outDir)) { New-Item -ItemType Directory -Force -Path $outDir | Out-Null }

$cleaned | Select-Object id, restaurant, domain | Export-Csv -Delimiter ';' -LiteralPath $OutputPath -NoTypeInformation -Encoding UTF8

if ($InvalidReportPath) {
  $invDir = [System.IO.Path]::GetDirectoryName($InvalidReportPath)
  if ($invDir -and !(Test-Path -LiteralPath $invDir)) { New-Item -ItemType Directory -Force -Path $invDir | Out-Null }

  $invalid = $cleaned | Where-Object {
    $d = $_.domain
    # consider invalid if empty or fails regex
    ([string]::IsNullOrWhiteSpace($d)) -or (-not [regex]::IsMatch($d, $regexValid))
  } | Select-Object id, restaurant, domain_original, domain

  $invalid | Export-Csv -Delimiter ';' -LiteralPath $InvalidReportPath -NoTypeInformation -Encoding UTF8
}

Write-Host "Cleaned CSV written to: $OutputPath"
if ($InvalidReportPath) { Write-Host "Invalids report written to: $InvalidReportPath" }


