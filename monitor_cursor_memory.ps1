# Monitor Cursor Memory Usage
# Run this while using Cursor to watch for memory leaks

Write-Host "
=== Cursor Memory Monitor ===" -ForegroundColor Cyan
Write-Host "Press Ctrl+C to stop
" -ForegroundColor Yellow

while ($true) {
    $cursorProcesses = Get-Process -Name "Cursor" -ErrorAction SilentlyContinue
    
    if ($cursorProcesses) {
        Clear-Host
        Write-Host "
=== Cursor Memory Usage - $(Get-Date -Format 'HH:mm:ss') ===" -ForegroundColor Cyan
        Write-Host ""
        
        $cursorProcesses | Select-Object ProcessName, Id, @{Name="Memory MB";Expression={[math]::Round($_.WorkingSet64/1MB,2)}} | Format-Table -AutoSize
        
        $totalMemory = ($cursorProcesses | Measure-Object -Property WorkingSet64 -Sum).Sum / 1MB
        $maxProcess = ($cursorProcesses | Measure-Object -Property WorkingSet64 -Maximum).Maximum / 1MB
        
        Write-Host "Total Memory: $([math]::Round($totalMemory, 2)) MB" -ForegroundColor 
        Write-Host "Largest Process: $([math]::Round($maxProcess, 2)) MB" -ForegroundColor 
        
        if ($maxProcess -gt 1800) {
            Write-Host "
âš  WARNING: Process approaching 2GB limit!" -ForegroundColor Red
        }
    } else {
        Write-Host "Cursor not running" -ForegroundColor Gray
    }
    
    Start-Sleep -Seconds 3
}
