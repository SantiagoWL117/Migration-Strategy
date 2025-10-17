# Check Migration Progress
# Usage: .\check_migration_progress.ps1

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "USER MIGRATION PROGRESS TRACKER" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Check if log file exists
if (Test-Path "migration_output.log") {
    Write-Host "📊 Latest Migration Activity:" -ForegroundColor Yellow
    Write-Host "-----------------------------------"
    Get-Content "migration_output.log" -Tail 30
    
    # Count migrated users
    $migratedCount = (Get-Content "migration_output.log" | Select-String "✅ Migrated:").Count
    Write-Host "`n-----------------------------------"
    Write-Host "✅ Users migrated so far: $migratedCount / 32,240" -ForegroundColor Green
    
    $percentComplete = [math]::Round(($migratedCount / 32240) * 100, 2)
    Write-Host "📈 Progress: $percentComplete%" -ForegroundColor Green
    
    $remaining = 32240 - $migratedCount
    $estimatedMinutes = [math]::Round(($remaining * 0.1) / 60, 1)
    Write-Host "⏱️  Estimated time remaining: $estimatedMinutes minutes`n" -ForegroundColor Cyan
    
} else {
    Write-Host "❌ Migration log file not found." -ForegroundColor Red
    Write-Host "   The migration may not have started yet.`n"
}

# Check for errors
if (Test-Path "migration_error.log") {
    $errorContent = Get-Content "migration_error.log"
    if ($errorContent) {
        Write-Host "⚠️  ERRORS DETECTED:" -ForegroundColor Red
        Write-Host "-----------------------------------"
        $errorContent | Select-Object -Last 10
        Write-Host ""
    }
}


















