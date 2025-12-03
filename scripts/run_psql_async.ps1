# =============================================================================
# ASYNC PSQL RUNNER - Prevents Agent Terminal Timeouts
# =============================================================================
# 
# This script runs long psql queries asynchronously and saves output to file
# Agents can call this script and immediately get a response without waiting
#
# Usage by agents:
# .\scripts\run_psql_async.ps1 -Query "YOUR SQL HERE" -OutputFile "results.txt"
#
# Then read the output file after a few seconds
# =============================================================================

param(
    [Parameter(Mandatory=$true)]
    [string]$Query,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputFile = "query_results_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt",
    
    [Parameter(Mandatory=$false)]
    [string]$ConnectionString = "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres",
    
    [Parameter(Mandatory=$false)]
    [switch]$Wait
)

$outputDir = Join-Path $PSScriptRoot "..\output"
$OutputPath = Join-Path $outputDir $OutputFile
$ErrorPath = Join-Path $outputDir "error_$OutputFile"

# Ensure output directory exists
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

Write-Host "🚀 Starting async psql query..." -ForegroundColor Cyan
Write-Host "   Output will be saved to: $OutputPath" -ForegroundColor Gray
Write-Host "   Errors will be saved to: $ErrorPath" -ForegroundColor Gray

# Create the psql command
$psqlPath = "C:\Program Files\PostgreSQL\17\bin\psql.exe"
$scriptBlock = {
    param($psql, $conn, $query, $out, $err)
    
    $startTime = Get-Date
    Write-Output "Query started at: $startTime" | Out-File $out -Encoding UTF8
    Write-Output "=" * 80 | Out-File $out -Append -Encoding UTF8
    
    try {
        $env:PGCLIENTENCODING = "UTF8"
        $env:PAGER = ""
        & $psql $conn --pset pager=off -c $query 2>&1 | Out-File $out -Append -Encoding UTF8
        $exitCode = $LASTEXITCODE
        
        $endTime = Get-Date
        $duration = ($endTime - $startTime).TotalSeconds
        
        Write-Output "" | Out-File $out -Append -Encoding UTF8
        Write-Output "=" * 80 | Out-File $out -Append -Encoding UTF8
        Write-Output "Query completed at: $endTime" | Out-File $out -Append -Encoding UTF8
        Write-Output "Duration: $duration seconds" | Out-File $out -Append -Encoding UTF8
        Write-Output "Exit Code: $exitCode" | Out-File $out -Append -Encoding UTF8
        
        if ($exitCode -ne 0) {
            Write-Output "ERROR: Query failed with exit code $exitCode" | Out-File $err -Encoding UTF8
        }
    }
    catch {
        Write-Output "EXCEPTION: $_" | Out-File $err -Encoding UTF8
    }
}

# Start the job
$job = Start-Job -ScriptBlock $scriptBlock -ArgumentList $psqlPath, $ConnectionString, $Query, $OutputPath, $ErrorPath

Write-Host "✅ Job started with ID: $($job.Id)" -ForegroundColor Green
Write-Host ""

if ($Wait) {
    Write-Host "⏳ Waiting for query to complete..." -ForegroundColor Yellow
    Wait-Job $job | Out-Null
    Receive-Job $job | Out-Null
    Remove-Job $job
    
    Write-Host "✅ Query completed!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📄 Results:" -ForegroundColor Cyan
    Get-Content $OutputPath
} else {
    Write-Host "⚡ Query running in background. Check results with:" -ForegroundColor Yellow
    Write-Host "   Get-Content '$OutputPath'" -ForegroundColor White
    Write-Host ""
    Write-Host "   Or check job status with:" -ForegroundColor Yellow
    Write-Host "   Get-Job -Id $($job.Id)" -ForegroundColor White
    Write-Host ""
    Write-Host "   Or wait for it with:" -ForegroundColor Yellow
    Write-Host "   Wait-Job -Id $($job.Id); Receive-Job -Id $($job.Id); Remove-Job -Id $($job.Id)" -ForegroundColor White
}

