# Master script to run all SQL to CSV conversions for Delivery Operations
# Phase 2: Data Extraction
# Runs all conversion scripts and generates CSV files

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Delivery Operations - Phase 2: Data Extraction" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Create CSV directory if it does not exist
$csvDir = Join-Path $scriptDir "CSV"
if (-not (Test-Path $csvDir)) {
    New-Item -ItemType Directory -Path $csvDir | Out-Null
    Write-Host "Created CSV directory" -ForegroundColor Green
}

# Track results
$results = @()

# V1 Conversions
Write-Host ""
Write-Host "--- V1 Conversions ---" -ForegroundColor Yellow

# 1. delivery_info
Write-Host ""
Write-Host "[1/8] Converting V1 delivery_info..." -ForegroundColor Cyan
try {
    & "$scriptDir\convert_v1_delivery_info_to_csv.ps1"
    $results += @{ Script = "convert_v1_delivery_info_to_csv.ps1"; Status = "SUCCESS" }
}
catch {
    Write-Host "FAILED: $_" -ForegroundColor Red
    $results += @{ Script = "convert_v1_delivery_info_to_csv.ps1"; Status = "FAILED: $_" }
}

# 2. distance_fees
Write-Host ""
Write-Host "[2/8] Converting V1 distance_fees..." -ForegroundColor Cyan
try {
    & "$scriptDir\convert_v1_distance_fees_to_csv.ps1"
    $results += @{ Script = "convert_v1_distance_fees_to_csv.ps1"; Status = "SUCCESS" }
}
catch {
    Write-Host "FAILED: $_" -ForegroundColor Red
    $results += @{ Script = "convert_v1_distance_fees_to_csv.ps1"; Status = "FAILED: $_" }
}

# 3. tookan_fees
Write-Host ""
Write-Host "[3/8] Converting V1 tookan_fees..." -ForegroundColor Cyan
try {
    & "$scriptDir\convert_v1_tookan_fees_to_csv.ps1"
    $results += @{ Script = "convert_v1_tookan_fees_to_csv.ps1"; Status = "SUCCESS" }
}
catch {
    Write-Host "FAILED: $_" -ForegroundColor Red
    $results += @{ Script = "convert_v1_tookan_fees_to_csv.ps1"; Status = "FAILED: $_" }
}

# 4. restaurants delivery flags
Write-Host ""
Write-Host "[4/8] Extracting V1 restaurants delivery flags..." -ForegroundColor Cyan
try {
    & "$scriptDir\extract_v1_restaurants_delivery_flags_to_csv.ps1"
    $results += @{ Script = "extract_v1_restaurants_delivery_flags_to_csv.ps1"; Status = "SUCCESS" }
}
catch {
    Write-Host "FAILED: $_" -ForegroundColor Red
    $results += @{ Script = "extract_v1_restaurants_delivery_flags_to_csv.ps1"; Status = "FAILED: $_" }
}

# V2 Conversions
Write-Host ""
Write-Host "--- V2 Conversions ---" -ForegroundColor Yellow

# 5. restaurants_delivery_schedule
Write-Host ""
Write-Host "[5/8] Converting V2 restaurants_delivery_schedule..." -ForegroundColor Cyan
try {
    & "$scriptDir\convert_v2_restaurants_delivery_schedule_to_csv.ps1"
    $results += @{ Script = "convert_v2_restaurants_delivery_schedule_to_csv.ps1"; Status = "SUCCESS" }
}
catch {
    Write-Host "FAILED: $_" -ForegroundColor Red
    $results += @{ Script = "convert_v2_restaurants_delivery_schedule_to_csv.ps1"; Status = "FAILED: $_" }
}

# 6. restaurants_delivery_fees
Write-Host ""
Write-Host "[6/8] Converting V2 restaurants_delivery_fees..." -ForegroundColor Cyan
try {
    & "$scriptDir\convert_v2_restaurants_delivery_fees_to_csv.ps1"
    $results += @{ Script = "convert_v2_restaurants_delivery_fees_to_csv.ps1"; Status = "SUCCESS" }
}
catch {
    Write-Host "FAILED: $_" -ForegroundColor Red
    $results += @{ Script = "convert_v2_restaurants_delivery_fees_to_csv.ps1"; Status = "FAILED: $_" }
}

# 7. twilio
Write-Host ""
Write-Host "[7/8] Converting V2 twilio..." -ForegroundColor Cyan
try {
    & "$scriptDir\convert_v2_twilio_to_csv.ps1"
    $results += @{ Script = "convert_v2_twilio_to_csv.ps1"; Status = "SUCCESS" }
}
catch {
    Write-Host "FAILED: $_" -ForegroundColor Red
    $results += @{ Script = "convert_v2_twilio_to_csv.ps1"; Status = "FAILED: $_" }
}

# 8. restaurants_delivery_areas (PostGIS)
Write-Host ""
Write-Host "[8/8] Converting V2 restaurants_delivery_areas (PostGIS)..." -ForegroundColor Cyan
try {
    & "$scriptDir\convert_v2_restaurants_delivery_areas_to_csv.ps1"
    $results += @{ Script = "convert_v2_restaurants_delivery_areas_to_csv.ps1"; Status = "SUCCESS" }
}
catch {
    Write-Host "FAILED: $_" -ForegroundColor Red
    $results += @{ Script = "convert_v2_restaurants_delivery_areas_to_csv.ps1"; Status = "FAILED: $_" }
}

# Summary
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Phase 2 Conversion Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

foreach ($result in $results) {
    $status = $result.Status
    $script = $result.Script
    
    if ($status -like "SUCCESS*") {
        Write-Host "[OK] $script" -ForegroundColor Green
    }
    else {
        Write-Host "[FAILED] $script - $status" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "All CSV files are stored in: $csvDir" -ForegroundColor Cyan
Write-Host ""

# List all CSV files created
$csvFiles = Get-ChildItem -Path $csvDir -Filter "*.csv"
$fileCount = $csvFiles.Count
Write-Host "CSV files created: $fileCount" -ForegroundColor Green
foreach ($file in $csvFiles) {
    $sizeKB = [math]::Round($file.Length / 1KB, 2)
    $fileName = $file.Name
    Write-Host "  - $fileName - $sizeKB KB" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Phase 2: Data Extraction - COMPLETE!" -ForegroundColor Green
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Review CSV files in the CSV folder" -ForegroundColor Gray
Write-Host "  2. Proceed to Phase 3: Create Staging Tables" -ForegroundColor Gray
Write-Host "  3. Manually import CSV files using Supabase web interface" -ForegroundColor Gray
