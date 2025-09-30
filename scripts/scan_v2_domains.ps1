Param(
    [Parameter(Mandatory=$true)]
    [string]$Path
)

$rows = Import-Csv -Path $Path -Delimiter ';'

$issues = [System.Collections.ArrayList]::new()

function Add-Issue { param([int]$id, [string]$kind, [string]$detail)
  [void]$issues.Add([PSCustomObject]@{ id=$id; kind=$kind; detail=$detail })
}

function Test-HasPortOrPath { param([string]$d) return ($d -match ':' -or $d -match '/') }

function Test-DomainValidBasic {
  param([string]$d)
  if ([string]::IsNullOrWhiteSpace($d)) { return $false }
  if ($d -notmatch '^[a-z0-9-]+(\.[a-z0-9-]+)+$') { return $false }
  foreach ($p in ($d -split '\.')) {
    if ($p.Length -lt 1 -or $p.Length -gt 63) { return $false }
    if ($p.StartsWith('-') -or $p.EndsWith('-')) { return $false }
  }
  return $true
}

foreach ($r in $rows) {
  $id = [int]$r.id

  # enabled must be true/false
  if ($r.enabled -notin @('true','false')) { Add-Issue $id 'enabled' "value '$($r.enabled)' not boolean" }

  # timestamps: if present, must be valid datetime; empty is allowed
  foreach ($col in 'added_at','disabled_at') {
    $v = $r.$col
    if ($null -ne $v -and (""+$v).Trim() -ne '') {
      [datetime]$dt = $null
      if (-not [datetime]::TryParse($v, [ref]$dt)) {
        Add-Issue $id $col "invalid datetime '$v'"
      }
    }
  }

  # domain checks
  $d = (""+$r.domain).Trim()
  if ([string]::IsNullOrWhiteSpace($d)) { Add-Issue $id 'domain' 'empty'; continue }

  if (Test-HasPortOrPath $d) {
    # Respect rule: skip normalization for ports/paths; only light checks: no spaces/semicolons
    if ($d -match '\s') { Add-Issue $id 'domain-portpath' 'contains whitespace' }
    if ($d -match ';')   { Add-Issue $id 'domain-portpath' 'contains semicolon' }
    continue
  }

  if ($d -match ';') { Add-Issue $id 'domain' 'contains semicolon' }
  if ($d -cmatch '[A-Z]') { Add-Issue $id 'domain' 'contains uppercase' }
  if ($d -match '\.\.') { Add-Issue $id 'domain' 'contains consecutive dots' }
  if (-not (Test-DomainValidBasic $d)) { Add-Issue $id 'domain' 'fails basic regex/label rules' }
}

# Summary
$byKind = $issues | Group-Object kind | Sort-Object Count -Descending
if ($byKind.Count -eq 0) {
  Write-Host 'OK: No format discrepancies found.'
} else {
  Write-Host 'Discrepancies found:'
  foreach ($g in $byKind) {
    Write-Host ("- {0}: {1}" -f $g.Name, $g.Count)
  }
  Write-Host ''
  $issues | Sort-Object kind, id | Select-Object -First 50 | Format-Table -AutoSize
}

