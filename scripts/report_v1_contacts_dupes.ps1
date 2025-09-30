if ($args.Count -lt 1) {
  throw "Usage: report_v1_contacts_dupes.ps1 <path-to-csv> [output-directory]"
}

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-FullPath([string]$p) {
  if ([System.IO.Path]::IsPathRooted($p)) { return $p }
  return (Join-Path -Path (Get-Location) -ChildPath $p)
}

$inPath = Get-FullPath $args[0]
if (-not (Test-Path -LiteralPath $inPath)) {
  throw "File not found: $inPath"
}

$outDir = if ($args.Count -ge 2 -and $args[1]) { Get-FullPath $args[1] } else { [System.IO.Path]::GetDirectoryName($inPath) }
if (-not (Test-Path -LiteralPath $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }

$rows = Import-Csv -LiteralPath $inPath -Delimiter ';' -Encoding UTF8

function Export-Dupes {
  param(
    [Parameter(Mandatory=$true)][object[]]$groups,
    [Parameter(Mandatory=$true)][string]$fileName
  )
  $dupes = @()
  foreach ($g in $groups) {
    if ($g.Count -gt 1) {
      foreach ($r in $g.Group) {
        $dupes += [pscustomobject]@{
          group_key   = $g.Name
          group_count = $g.Count
          id          = $r.id
          restaurant  = $r.restaurant
          contact     = $r.contact
          title       = $r.title
          phone       = $r.phone
          email       = $r.email
        }
      }
    }
  }
  $outPath = [System.IO.Path]::Combine($outDir, $fileName)
  $dupes | Sort-Object group_key, id | Export-Csv -LiteralPath $outPath -Delimiter ';' -NoTypeInformation -Encoding UTF8
  Write-Host "Wrote: $outPath (`$($dupes.Count) rows)"
}

# Duplicates by email + restaurant (non-empty email)
$byEmail = $rows | Where-Object { $_.email -and ($_.email.Trim() -ne '') } |
  Group-Object { "rest=$($_.restaurant)|email=$($_.email.ToLower().Trim())" }
Export-Dupes -groups $byEmail -fileName 'dupes_by_email_and_restaurant.csv'

# Duplicates by contact + restaurant (normalized contact)
function Normalize-Contact([string]$s) {
  if (-not $s) { return '' }
  ($s -replace '\s+', ' ').Trim().ToLower()
}
$byContact = $rows | Where-Object { $_.contact -and ($_.contact.Trim() -ne '') } |
  Group-Object { "rest=$($_.restaurant)|contact=$(Normalize-Contact $_.contact)" }
Export-Dupes -groups $byContact -fileName 'dupes_by_contact_and_restaurant.csv'

# Duplicates by phone + restaurant (non-empty phone)
$byPhone = $rows | Where-Object { $_.phone -and ($_.phone.Trim() -ne '') } |
  Group-Object { "rest=$($_.restaurant)|phone=$($_.phone.Trim())" }
Export-Dupes -groups $byPhone -fileName 'dupes_by_phone_and_restaurant.csv'

# Exact duplicate rows for same restaurant/contact/title/phone/email
$byExact = $rows |
  Group-Object { "rest=$($_.restaurant)|contact=$($_.contact)|title=$($_.title)|phone=$($_.phone)|email=$($_.email)" }
Export-Dupes -groups $byExact -fileName 'dupes_exact_by_restaurant.csv'

Write-Host "Duplicate reports generated in: $outDir"



