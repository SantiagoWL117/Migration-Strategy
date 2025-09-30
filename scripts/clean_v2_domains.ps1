Param(
    [Parameter(Mandatory=$true)]
    [string]$Path
)

# Backup
$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$backupPath = [System.IO.Path]::Combine(
    [System.IO.Path]::GetDirectoryName($Path),
    ([System.IO.Path]::GetFileNameWithoutExtension($Path) + ".backup_$timestamp" + [System.IO.Path]::GetExtension($Path))
)
Copy-Item -LiteralPath $Path -Destination $backupPath -Force

# Helpers
function Test-HasPortOrPath {
    param([string]$d)
    return ($d -match ':' -or $d -match '/')
}

function Normalize-Domain {
    param([string]$domain)
    if ([string]::IsNullOrWhiteSpace($domain)) { return $domain }
    $d = $domain.Trim().ToLowerInvariant()
    $d = $d -replace '^(https?:\/\/)', ''
    $d = $d -replace '\.{2,}', '.'
    $d = $d -replace '[^a-z0-9\.-]', ''
    # remove trailing hyphens before dots
    $d = $d -replace '-+\.', '.'
    # collapse double hyphens
    while ($d -like '*--*') { $d = $d -replace '--','-' }
    # fix typos
    $d = $d -replace 'rastaurant','restaurant'
    # trim leading/trailing hyphens from each label and drop empty labels
    $labels = @()
    foreach ($label in ($d -split '\.')) {
        if ($label -eq '') { continue }
        $lab = $label.Trim('-')
        if ($lab -ne '') { $labels += $lab }
    }
    if ($labels.Count -eq 0) { return $d }
    return ($labels -join '.')
}

function Test-DomainValid {
    param([string]$domain)
    if ([string]::IsNullOrWhiteSpace($domain)) { return $false }
    if ($domain -notmatch '^[a-z0-9-]+(\.[a-z0-9-]+)+$') { return $false }
    $parts = $domain -split '\.'
    foreach ($p in $parts) {
        if ($p.Length -lt 1 -or $p.Length -gt 63) { return $false }
        if ($p.StartsWith('-') -or $p.EndsWith('-')) { return $false }
    }
    return $true
}

# Load CSV
$rows = Import-Csv -Path $Path -Delimiter ';'

# Remove specific ids
$removeIds = @('55','195','200')
$rows = $rows | Where-Object { $removeIds -notcontains ($_.id) }

# Handle id=170 split of multi-domain cell
$maxId = ($rows | ForEach-Object { [int]$_.id } | Measure-Object -Maximum).Maximum
$extraRows = @()
foreach ($row in $rows) {
    if ($row.id -eq '170' -and $row.domain -match ';') {
        $parts = $row.domain -split ';'
        $first = ($parts[0]).Trim()
        $second = ($parts[1]).Trim()
        # Keep first in-place
        $row.domain = $first
        # Duplicate for second
        $clone = $row.PSObject.Copy()
        $maxId += 1
        $clone.id = $maxId.ToString()
        $clone.domain = $second
        $extraRows += $clone
    }
}
if ($extraRows.Count -gt 0) {
    $rows = @($rows) + @($extraRows)
}

# Apply field transforms
foreach ($row in $rows) {
    # enabled: map y/n -> true/false
    $e = ("" + $row.enabled).Trim()
    if ($e -match '^(y|Y|1|true|t)$') { $row.enabled = 'true' }
    elseif ($e -match '^(n|N|0|false|f)$') { $row.enabled = 'false' }

    # timestamps: empty -> NULL (empty field in CSV)
    foreach ($col in 'added_at','disabled_at') {
        $v = $row.$col
        if ($null -eq $v -or ("" + $v).Trim('"',' ') -eq '') {
            $row.$col = $null
        }
    }

    # domain normalization rules, but skip if missing TLD or has port/path
    $domain = $row.domain
    $skip = $false
    if (Test-HasPortOrPath -d $domain) { $skip = $true }

    if (-not $skip) {
        $norm = Normalize-Domain -domain $domain
        if (Test-DomainValid -domain $norm) {
            $row.domain = $norm
        } else {
            # leave unchanged per rule 7 (missing TLD or invalid)
        }
    }
}

# Write out (preserve delimiter). Export-Csv won't quote headers like the original, but data remains consistent.
$tempOut = [System.IO.Path]::GetTempFileName()
$rows | Sort-Object {[int]$_.id} | Export-Csv -Path $tempOut -Delimiter ';' -NoTypeInformation -Encoding UTF8

# Overwrite original
Move-Item -Force -Path $tempOut -Destination $Path

Write-Host "Backup: $backupPath"
Write-Host "Rows written: $($rows.Count)"

