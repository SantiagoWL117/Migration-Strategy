Param(
    [Parameter(Mandatory=$true)]
    [string]$Path
)

# Backup original
$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$backupPath = [System.IO.Path]::Combine(
    [System.IO.Path]::GetDirectoryName($Path),
    ([System.IO.Path]::GetFileNameWithoutExtension($Path) + ".backup_$timestamp" + [System.IO.Path]::GetExtension($Path))
)
Copy-Item -LiteralPath $Path -Destination $backupPath -Force

# Load and add ids
$rows = Import-Csv -Path $Path -Delimiter ';'

$idx = 1
foreach ($row in $rows) {
    $row | Add-Member -NotePropertyName 'id' -NotePropertyValue $idx -Force
    $idx++
}

# Reorder columns and write back
$tempOut = [System.IO.Path]::GetTempFileName()
$rows | Select-Object id, restaurant, domain | Export-Csv -Path $tempOut -Delimiter ';' -NoTypeInformation -Encoding UTF8
Move-Item -Force -Path $tempOut -Destination $Path

Write-Host "Backup: $backupPath"
Write-Host "Rows: $($rows.Count)"

