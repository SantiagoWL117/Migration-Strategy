#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Convert all Menu & Catalog SQL dumps to CSV files, excluding BLOB columns.

.DESCRIPTION
    This script converts all 17 SQL dump files to CSV format for accurate staging table mapping.
    BLOB columns identified in the BLOB analysis are excluded from CSV conversion.

.NOTES
    Author: Migration Team
    Date: 2025-01-08
    Phase: Pre-Phase 2 (Data Extraction)
    
    BLOB Columns Excluded:
    - menuca_v1_menu: hideOnDays (BLOB Case #1)
    - menuca_v1_menuothers: content (BLOB Case #2)
    - menuca_v1_ingredient_groups: item, price (BLOB Case #3)
    - menuca_v1_combo_groups: dish, options, group (BLOB Case #4)
#>

# Configuration
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$DumpsDir = Join-Path (Split-Path -Parent $ScriptDir) "dumps"
$CsvDir = Join-Path (Split-Path -Parent $ScriptDir) "CSV"
$LogFile = Join-Path $ScriptDir "conversion_log.txt"

# Create CSV directory if it doesn't exist
if (-not (Test-Path $CsvDir)) {
    New-Item -ItemType Directory -Path $CsvDir | Out-Null
    Write-Host "✅ Created CSV directory: $CsvDir" -ForegroundColor Green
}

# Initialize log
"=== SQL to CSV Conversion Log ===" | Out-File $LogFile
"Date: $(Get-Date)" | Out-File $LogFile -Append
"" | Out-File $LogFile -Append

# Define BLOB columns to exclude per table
$ExcludeColumns = @{
    'menuca_v1_menu' = @('hideOnDays')
    'menuca_v1_menuothers' = @('content')
    'menuca_v1_ingredient_groups' = @('item', 'price')
    'menuca_v1_combo_groups' = @('dish', 'options', 'group')
}

# Function to extract column names from CREATE TABLE statement
function Get-ColumnNames {
    param (
        [string]$CreateTableBlock,
        [string[]]$ExcludeList = @()
    )
    
    $columns = @()
    $lines = $CreateTableBlock -split "`n"
    
    foreach ($line in $lines) {
        # Match column definitions (skip PRIMARY KEY, KEY, UNIQUE, etc.)
        if ($line -match '^\s*`([^`]+)`\s+(.*?)(?:,|$)' -and 
            $line -notmatch 'PRIMARY KEY' -and 
            $line -notmatch '^\s*KEY' -and
            $line -notmatch '^\s*UNIQUE' -and
            $line -notmatch '^\s*CONSTRAINT') {
            
            $columnName = $matches[1]
            
            # Skip if in exclude list
            if ($ExcludeList -notcontains $columnName) {
                $columns += $columnName
            } else {
                Write-Host "  ⏩ Skipping BLOB column: $columnName" -ForegroundColor Yellow
            }
        }
    }
    
    return $columns
}

# Function to parse INSERT values
function Parse-InsertValues {
    param (
        [string]$ValuesString,
        [int]$TotalColumns,
        [int[]]$SkipIndices
    )
    
    $values = @()
    $current = ""
    $inString = $false
    $escaped = $false
    $parenDepth = 0
    $columnIndex = 0
    $valueIndex = 0
    
    for ($i = 0; $i -lt $ValuesString.Length; $i++) {
        $char = $ValuesString[$i]
        
        if ($escaped) {
            $current += $char
            $escaped = $false
            continue
        }
        
        if ($char -eq '\') {
            $escaped = $true
            $current += $char
            continue
        }
        
        if ($char -eq "'") {
            $inString = -not $inString
            continue
        }
        
        if (-not $inString) {
            if ($char -eq '(') {
                $parenDepth++
                if ($parenDepth -eq 1) {
                    $columnIndex = 0
                    continue
                }
            }
            elseif ($char -eq ')') {
                $parenDepth--
                if ($parenDepth -eq 0) {
                    # End of row - add last value if not skipped
                    if ($SkipIndices -notcontains $columnIndex) {
                        $values += $current.Trim()
                    }
                    $current = ""
                    $columnIndex = 0
                    continue
                }
            }
            elseif ($char -eq ',' -and $parenDepth -eq 1) {
                # Column separator
                if ($SkipIndices -notcontains $columnIndex) {
                    $values += $current.Trim()
                }
                $current = ""
                $columnIndex++
                continue
            }
        }
        
        $current += $char
    }
    
    return $values
}

# Function to convert SQL dump to CSV
function Convert-SqlDumpToCsv {
    param (
        [string]$SqlFile,
        [string]$CsvFile,
        [string]$TableName
    )
    
    Write-Host "`n🔄 Processing: $TableName" -ForegroundColor Cyan
    "Processing: $TableName" | Out-File $LogFile -Append
    
    try {
        # Read SQL file
        $content = Get-Content $SqlFile -Raw -Encoding UTF8
        
        # Extract CREATE TABLE block
        $createMatch = $content -match '(?s)CREATE TABLE.*?`' + $TableName + '`.*?\((.*?)\);'
        if (-not $createMatch) {
            Write-Host "  ❌ Could not find CREATE TABLE for $TableName" -ForegroundColor Red
            "  ERROR: Could not find CREATE TABLE" | Out-File $LogFile -Append
            return $false
        }
        
        $createBlock = $matches[0]
        
        # Get exclude list for this table
        $excludeList = @()
        if ($ExcludeColumns.ContainsKey($TableName)) {
            $excludeList = $ExcludeColumns[$TableName]
        }
        
        # Extract column names (excluding BLOB columns)
        $columns = Get-ColumnNames -CreateTableBlock $createBlock -ExcludeList $excludeList
        
        if ($columns.Count -eq 0) {
            Write-Host "  ❌ No columns found" -ForegroundColor Red
            "  ERROR: No columns extracted" | Out-File $LogFile -Append
            return $false
        }
        
        Write-Host "  📋 Columns: $($columns.Count) (after excluding BLOBs)" -ForegroundColor Gray
        "  Columns: $($columns -join ', ')" | Out-File $LogFile -Append
        
        # Extract INSERT statements
        $insertPattern = 'INSERT INTO\s+`?' + $TableName + '`?\s+VALUES\s+(.*?);'
        $insertMatches = [regex]::Matches($content, $insertPattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
        
        if ($insertMatches.Count -eq 0) {
            Write-Host "  ⚠️  No INSERT statements found (empty table)" -ForegroundColor Yellow
            "  WARNING: No data rows found" | Out-File $LogFile -Append
            
            # Create CSV with headers only
            $columns -join ',' | Out-File $CsvFile -Encoding UTF8
            Write-Host "  ✅ Created empty CSV with headers" -ForegroundColor Green
            return $true
        }
        
        # Create CSV file with headers
        $columns -join ',' | Out-File $CsvFile -Encoding UTF8
        
        # Determine which column indices to skip
        $allColumnsMatch = $content -match '(?s)CREATE TABLE.*?`' + $TableName + '`.*?\((.*?)\);'
        $allColumnsBlock = $matches[0]
        $allColumns = Get-ColumnNames -CreateTableBlock $allColumnsBlock -ExcludeList @()
        
        $skipIndices = @()
        for ($i = 0; $i -lt $allColumns.Count; $i++) {
            if ($excludeList -contains $allColumns[$i]) {
                $skipIndices += $i
            }
        }
        
        Write-Host "  📊 Processing INSERT statements..." -ForegroundColor Gray
        
        $rowCount = 0
        $totalRows = 0
        
        foreach ($match in $insertMatches) {
            $valuesString = $match.Groups[1].Value
            
            # Split by ),( to get individual rows
            $rows = $valuesString -split '\),\s*\('
            $totalRows += $rows.Count
            
            foreach ($row in $rows) {
                # Clean up row
                $row = $row.Trim()
                $row = $row.TrimStart('(')
                $row = $row.TrimEnd(')')
                
                if ([string]::IsNullOrWhiteSpace($row)) {
                    continue
                }
                
                # Parse values
                $values = @()
                $current = ""
                $inString = $false
                $escaped = $false
                $columnIndex = 0
                
                for ($i = 0; $i -lt $row.Length; $i++) {
                    $char = $row[$i]
                    
                    if ($escaped) {
                        if ($char -eq 'n') { $current += "`n" }
                        elseif ($char -eq 'r') { $current += "`r" }
                        elseif ($char -eq 't') { $current += "`t" }
                        elseif ($char -eq '\') { $current += '\' }
                        elseif ($char -eq "'") { $current += "'" }
                        elseif ($char -eq '"') { $current += '"' }
                        else { $current += $char }
                        $escaped = $false
                        continue
                    }
                    
                    if ($char -eq '\') {
                        $escaped = $true
                        continue
                    }
                    
                    if ($char -eq "'") {
                        $inString = -not $inString
                        continue
                    }
                    
                    if (-not $inString -and $char -eq ',') {
                        # Column separator
                        if ($skipIndices -notcontains $columnIndex) {
                            # Clean value
                            $value = $current.Trim()
                            if ($value -eq 'NULL') { $value = '' }
                            # Escape quotes for CSV
                            if ($value -match '[",`n`r]') {
                                $value = '"' + ($value -replace '"', '""') + '"'
                            }
                            $values += $value
                        }
                        $current = ""
                        $columnIndex++
                        continue
                    }
                    
                    $current += $char
                }
                
                # Add last value
                if ($skipIndices -notcontains $columnIndex) {
                    $value = $current.Trim()
                    if ($value -eq 'NULL') { $value = '' }
                    if ($value -match '[",`n`r]') {
                        $value = '"' + ($value -replace '"', '""') + '"'
                    }
                    $values += $value
                }
                
                # Validate column count
                if ($values.Count -eq $columns.Count) {
                    $values -join ',' | Out-File $CsvFile -Append -Encoding UTF8
                    $rowCount++
                } else {
                    Write-Host "  ⚠️  Row $rowCount has $($values.Count) values, expected $($columns.Count)" -ForegroundColor Yellow
                }
                
                # Progress indicator
                if ($rowCount % 1000 -eq 0 -and $rowCount -gt 0) {
                    Write-Host "    → Processed $rowCount rows..." -ForegroundColor DarkGray
                }
            }
        }
        
        Write-Host "  ✅ Converted $rowCount rows to CSV" -ForegroundColor Green
        "  Success: $rowCount rows converted" | Out-File $LogFile -Append
        
        return $true
        
    } catch {
        Write-Host "  ❌ Error: $_" -ForegroundColor Red
        "  ERROR: $_" | Out-File $LogFile -Append
        return $false
    }
}

# Main execution
Write-Host "=== Menu & Catalog SQL to CSV Conversion ===" -ForegroundColor Cyan
Write-Host "Dumps Directory: $DumpsDir" -ForegroundColor Gray
Write-Host "CSV Directory: $CsvDir" -ForegroundColor Gray
Write-Host ""

# Get all SQL dump files
$dumpFiles = Get-ChildItem -Path $DumpsDir -Filter "*.sql" | Sort-Object Name

$successCount = 0
$failCount = 0

foreach ($file in $dumpFiles) {
    $tableName = $file.BaseName
    $csvFile = Join-Path $CsvDir "$tableName.csv"
    
    $success = Convert-SqlDumpToCsv -SqlFile $file.FullName -CsvFile $csvFile -TableName $tableName
    
    if ($success) {
        $successCount++
    } else {
        $failCount++
    }
}

# Summary
Write-Host "`n=== Conversion Summary ===" -ForegroundColor Cyan
Write-Host "Total Files: $($dumpFiles.Count)" -ForegroundColor Gray
Write-Host "✅ Successful: $successCount" -ForegroundColor Green
Write-Host "❌ Failed: $failCount" -ForegroundColor Red
Write-Host ""
Write-Host "Log file: $LogFile" -ForegroundColor Gray
Write-Host "CSV files: $CsvDir" -ForegroundColor Gray

"" | Out-File $LogFile -Append
"=== Summary ===" | Out-File $LogFile -Append
"Total: $($dumpFiles.Count)" | Out-File $LogFile -Append
"Success: $successCount" | Out-File $LogFile -Append
"Failed: $failCount" | Out-File $LogFile -Append

if ($successCount -eq $dumpFiles.Count) {
    Write-Host "🎉 All dumps converted successfully!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "⚠️  Some conversions failed. Check log for details." -ForegroundColor Yellow
    exit 1
}




