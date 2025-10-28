# ========================================
# Find MySQL Secure File Export Path
# Run this first to get your export directory
# ========================================

Write-Host "`n=== MySQL Export Directory Finder ===" -ForegroundColor Cyan
Write-Host "This script will help you find where MySQL allows file exports`n" -ForegroundColor Yellow

# Common MySQL secure-file-priv locations on Windows
$commonPaths = @(
    "C:\ProgramData\MySQL\MySQL Server 8.0\Uploads",
    "C:\ProgramData\MySQL\MySQL Server 8.1\Uploads",
    "C:\ProgramData\MySQL\MySQL Server 5.7\Uploads",
    "C:\Program Files\MySQL\MySQL Server 8.0\Uploads",
    "C:\Program Files\MySQL\MySQL Server 8.1\Uploads",
    "C:\mysql\uploads",
    "C:\xampp\mysql\data",
    "C:\wamp64\tmp"
)

Write-Host "Checking common MySQL export directories..." -ForegroundColor Cyan

$foundPaths = @()
foreach ($path in $commonPaths) {
    if (Test-Path $path) {
        Write-Host "✓ Found: $path" -ForegroundColor Green
        $foundPaths += $path
    }
}

if ($foundPaths.Count -eq 0) {
    Write-Host "`n⚠ No common paths found." -ForegroundColor Yellow
}

Write-Host "`n=== NEXT STEPS ===" -ForegroundColor Cyan
Write-Host "1. Open MySQL Workbench" -ForegroundColor White
Write-Host "2. Run this query:" -ForegroundColor White
Write-Host "   SHOW VARIABLES LIKE 'secure_file_priv';" -ForegroundColor Yellow
Write-Host "3. Copy the directory path from the result" -ForegroundColor White
Write-Host "4. Open 'v2_export_queries_OUTFILE.sql' in a text editor" -ForegroundColor White
Write-Host "5. Replace 'YOUR_EXPORT_PATH_HERE' with the actual path" -ForegroundColor White
Write-Host "   (Use forward slashes: C:/ProgramData/MySQL/...)" -ForegroundColor White
Write-Host "6. Run the modified SQL script in MySQL Workbench`n" -ForegroundColor White

Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

