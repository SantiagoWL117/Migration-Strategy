# ============================================================================
# SQL Dump to CSV Converter
# ============================================================================
# Purpose: Convert SQL dump files to CSV format for ETL processing
# Status: Excludes menuca_v2_restaurants_configs.sql due to BLOB column
# ============================================================================

$ErrorActionPreference = "Stop"

# Define paths
$dumpDir = "C:\Users\santi\Menu.ca\Legacy Database\Migration Strategy\Database\Service Configuration & Schedules\dumps"
$csvDir = "C:\Users\santi\Menu.ca\Legacy Database\Migration Strategy\Database\Service Configuration & Schedules\CSV"

# Files to convert (BLOB file excluded)
$filesToConvert = @(
    @{
        Name = "menuca_v2_restaurants_schedule"
        SqlFile = "menuca_v2_restaurants_schedule.sql"
        CsvFile = "menuca_v2_restaurants_schedule.csv"
    },
    @{
        Name = "menuca_v2_restaurants_special_schedule"
        SqlFile = "menuca_v2_restaurants_special_schedule.sql"
        CsvFile = "menuca_v2_restaurants_special_schedule.csv"
    },
    @{
        Name = "menuca_v2_restaurants_time_periods"
        SqlFile = "menuca_v2_restaurants_time_periods.sql"
        CsvFile = "menuca_v2_restaurants_time_periods.csv"
    },
    @{
        Name = "migration_db_menuca_v1_restaurants_service_flags"
        SqlFile = "migration_db_menuca_v1_restaurants_service_flags.sql"
        CsvFile = "migration_db_menuca_v1_restaurants_service_flags.csv"
    },
    @{
        Name = "migration_db_menuca_v2_restaurants_service_flags"
        SqlFile = "migration_db_menuca_v2_restaurants_service_flags.sql"
        CsvFile = "migration_db_menuca_v2_restaurants_service_flags.csv"
    }
)

Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "SQL Dump to CSV Conversion Utility" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""

# Ensure CSV directory exists
if (-not (Test-Path $csvDir)) {
    New-Item -ItemType Directory -Path $csvDir -Force | Out-Null
    Write-Host "[✓] Created CSV directory: $csvDir" -ForegroundColor Green
}

# Process each file
$successCount = 0
$failedCount = 0
$skippedCount = 0

foreach ($file in $filesToConvert) {
    Write-Host "Processing: $($file.Name)" -ForegroundColor Yellow
    Write-Host "  Source: $($file.SqlFile)" -ForegroundColor Gray
    Write-Host "  Target: $($file.CsvFile)" -ForegroundColor Gray
    
    $sqlPath = Join-Path $dumpDir $file.SqlFile
    $csvPath = Join-Path $csvDir $file.CsvFile
    
    # Check if source file exists
    if (-not (Test-Path $sqlPath)) {
        Write-Host "  [✗] Source file not found!" -ForegroundColor Red
        $failedCount++
        continue
    }
    
    # Check if CSV already exists
    if (Test-Path $csvPath) {
        Write-Host "  [!] CSV already exists - skipping" -ForegroundColor Magenta
        $skippedCount++
        continue
    }
    
    try {
        # Read SQL dump file
        $content = Get-Content $sqlPath -Raw
        
        # Extract INSERT statement
        if ($content -match 'INSERT INTO `[^`]+` VALUES (.+);') {
            $insertData = $matches[1]
            
            # Extract column names from CREATE TABLE statement
            if ($content -match 'CREATE TABLE `[^`]+` \(([^;]+)\)') {
                $createTableContent = $matches[1]
                
                # Parse column names (simplified - extracts column names before types)
                $columns = @()
                $lines = $createTableContent -split "`n"
                foreach ($line in $lines) {
                    if ($line -match '^\s*`([^`]+)`\s+') {
                        $columns += $matches[1]
                    }
                }
                
                # Create CSV header
                $csvHeader = $columns -join ","
                
                # Parse INSERT VALUES into rows
                # This handles nested parentheses and quoted strings
                $rows = @()
                $currentRow = ""
                $inQuote = $false
                $parenDepth = 0
                
                for ($i = 0; $i -lt $insertData.Length; $i++) {
                    $char = $insertData[$i]
                    
                    # Handle escape sequences
                    $backslashChar = [char]92
                    if ($char -eq $backslashChar -and $i -lt $insertData.Length - 1) {
                        $currentRow += $char + $insertData[$i + 1]
                        $i++
                        continue
                    }
                    
                    # Track quote state
                    $singleQuoteChar = [char]39
                    if ($char -eq $singleQuoteChar -and ($i -eq 0 -or $insertData[$i - 1] -ne $backslashChar)) {
                        $inQuote = -not $inQuote
                    }
                    
                    # Track parenthesis depth (only when not in quotes)
                    if (-not $inQuote) {
                        $openParen = [char]40
                        $closeParen = [char]41
                        if ($char -eq $openParen) {
                            $parenDepth++
                            if ($parenDepth -eq 1) {
                                # Start of new row
                                $currentRow = ""
                                continue
                            }
                        }
                        elseif ($char -eq $closeParen) {
                            $parenDepth--
                            if ($parenDepth -eq 0) {
                                # End of row
                                $rows += $currentRow
                                $currentRow = ""
                                continue
                            }
                        }
                    }
                    
                    $currentRow += $char
                }
                
                # Write CSV file
                $csvContent = @($csvHeader)
                foreach ($row in $rows) {
                    # Parse row into fields
                    $fields = @()
                    $currentField = ""
                    $inQuote = $false
                    
                    for ($i = 0; $i -lt $row.Length; $i++) {
                        $char = $row[$i]
                        
                        # Handle escape sequences
                        $backslash = [char]92
                        if ($char -eq $backslash -and $i -lt $row.Length - 1) {
                            $nextChar = $row[$i + 1]
                            # Convert SQL escapes to CSV-safe format
                            $singleQuote = [char]39
                            $doubleQuote = [char]34
                            $nChar = [char]110
                            $tChar = [char]116
                            if ($nextChar -eq $singleQuote) {
                                $currentField += $singleQuote
                            } elseif ($nextChar -eq $doubleQuote) {
                                $currentField += $doubleQuote.ToString() * 2
                            } elseif ($nextChar -eq $nChar) {
                                $currentField += " "  # Replace newlines with space
                            } elseif ($nextChar -eq $tChar) {
                                $currentField += " "  # Replace tabs with space
                            } else {
                                $currentField += $nextChar
                            }
                            $i++
                            continue
                        }
                        
                        # Track quote state
                        $singleQuote = [char]39
                        $backslash = [char]92
                        if ($char -eq $singleQuote -and ($i -eq 0 -or $row[$i - 1] -ne $backslash)) {
                            $inQuote = -not $inQuote
                            continue  # Skip quotes
                        }
                        
                        # Handle field separator
                        $comma = ","
                        if ($char -eq $comma -and -not $inQuote) {
                            # Escape quotes for CSV
                            $doubleQuote = [char]34
                            if ($currentField.Contains($doubleQuote)) {
                                $currentField = $doubleQuote + ($currentField -replace $doubleQuote, ($doubleQuote.ToString() * 2)) + $doubleQuote
                            } elseif ($currentField.Contains($comma)) {
                                $currentField = $doubleQuote + $currentField + $doubleQuote
                            }
                            $fields += $currentField
                            $currentField = ""
                            continue
                        }
                        
                        $currentField += $char
                    }
                    
                    # Add last field
                    if ($currentField -ne "") {
                        $doubleQuote = [char]34
                        $comma = ","
                        if ($currentField.Contains($doubleQuote)) {
                            $currentField = $doubleQuote + ($currentField -replace $doubleQuote, ($doubleQuote.ToString() * 2)) + $doubleQuote
                        } elseif ($currentField.Contains($comma)) {
                            $currentField = $doubleQuote + $currentField + $doubleQuote
                        }
                        $fields += $currentField
                    }
                    
                    $csvContent += ($fields -join ",")
                }
                
                # Write to CSV file
                $csvContent | Out-File -FilePath $csvPath -Encoding UTF8
                
                $rowCount = $rows.Count
                Write-Host "  [✓] Success! Converted $rowCount rows" -ForegroundColor Green
                $successCount++
            }
            else {
                Write-Host "  [✗] Could not extract column names" -ForegroundColor Red
                $failedCount++
            }
        }
        else {
            Write-Host "  [✗] Could not find INSERT statement" -ForegroundColor Red
            $failedCount++
        }
    }
    catch {
        Write-Host "  [✗] Error: $($_.Exception.Message)" -ForegroundColor Red
        $failedCount++
    }
    
    Write-Host ""
}

# Summary
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "Conversion Summary" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "  Success:  $successCount file(s)" -ForegroundColor Green
Write-Host "  Skipped:  $skippedCount file(s) (already exist)" -ForegroundColor Magenta
Write-Host "  Failed:   $failedCount file(s)" -ForegroundColor Red
Write-Host ""
Write-Host "Note: menuca_v2_restaurants_configs.sql excluded due to BLOB column" -ForegroundColor Yellow
Write-Host "      See SERVICE_SCHEDULES_MIGRATION_GUIDE.md for details" -ForegroundColor Yellow
Write-Host "============================================================================" -ForegroundColor Cyan

