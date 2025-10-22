# Cursor Memory Cleanup Script
# Run this BEFORE opening Cursor

Write-Host "
=== Cleaning Up Memory Before Cursor Launch ===" -ForegroundColor Cyan
Write-Host ""

# Kill any existing Cursor processes
Write-Host "1. Killing existing Cursor processes..." -ForegroundColor Yellow
Get-Process -Name "Cursor" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

# Clear temp files
Write-Host "2. Clearing temp files..." -ForegroundColor Yellow
Remove-Item "$env:TEMP\*" -Force -Recurse -ErrorAction SilentlyContinue

# Check for memory hogs
Write-Host "3. Checking for memory-hogging processes..." -ForegroundColor Yellow
$memoryHogs = Get-Process | Where-Object {$_.WorkingSet64 -gt 500MB} | Select-Object Name, @{Name="Memory MB";Expression={[math]::Round($_.WorkingSet64/1MB,2)}}
if ($memoryHogs) {
    Write-Host ""
    Write-Host "Memory-hogging processes:" -ForegroundColor Red
    $memoryHogs | Format-Table -AutoSize
}

Write-Host ""
Write-Host "=== Ready to launch Cursor ===" -ForegroundColor Green
Write-Host ""

# Launch Cursor with the Migration Strategy workspace
$cursorPath = "C:\Program Files\cursor\Cursor.exe"
$workspacePath = "C:\Users\santi\Menu.ca\Legacy Database\Migration Strategy"

if (Test-Path $cursorPath) {
    Write-Host "Launching Cursor with 8GB memory limit..." -ForegroundColor Yellow
    Start-Process $cursorPath -ArgumentList ""$workspacePath"", "--max-old-space-size=8192", "--disable-gpu-sandbox", "--js-flags=--max-old-space-size=8192" -WorkingDirectory $workspacePath
} else {
    Write-Host "Cursor not found at: $cursorPath" -ForegroundColor Red
}
