# Playwright MCP Installation Script for Cursor
# This script configures the Playwright MCP server in Cursor

Write-Host "=== Playwright MCP Installation for Cursor ===" -ForegroundColor Cyan
Write-Host ""

# Check if Node.js is installed
try {
    $nodeVersion = node --version
    Write-Host "✓ Node.js found: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Node.js not found. Please install Node.js first from https://nodejs.org/" -ForegroundColor Red
    exit 1
}

# Check if npm is available
try {
    $npmVersion = npm --version
    Write-Host "✓ npm found: v$npmVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ npm not found. Please install Node.js with npm." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Configuring Playwright MCP in Cursor..." -ForegroundColor Yellow

# Define the MCP configuration directory and file
$cursorAppData = "$env:APPDATA\Cursor\User\globalStorage"
$mcpConfigPath = "$env:APPDATA\Cursor\User\globalStorage\mcp.json"

# Create directory if it doesn't exist
if (-not (Test-Path $cursorAppData)) {
    New-Item -ItemType Directory -Path $cursorAppData -Force | Out-Null
    Write-Host "✓ Created Cursor global storage directory" -ForegroundColor Green
}

# MCP configuration
$mcpConfig = @{
    mcpServers = @{
        playwright = @{
            command = "npx"
            args = @(
                "-y",
                "@playwright/mcp@latest"
            )
        }
    }
} | ConvertTo-Json -Depth 10

# Check if mcp.json already exists
if (Test-Path $mcpConfigPath) {
    Write-Host ""
    Write-Host "mcp.json already exists at: $mcpConfigPath" -ForegroundColor Yellow
    Write-Host "Current content:" -ForegroundColor Yellow
    Get-Content $mcpConfigPath
    Write-Host ""
    
    $response = Read-Host "Do you want to overwrite it? (y/n)"
    if ($response -ne "y") {
        Write-Host "Installation cancelled. Please manually add Playwright MCP to your existing configuration." -ForegroundColor Yellow
        exit 0
    }
}

# Write the configuration
try {
    $mcpConfig | Set-Content -Path $mcpConfigPath -Force
    Write-Host "✓ MCP configuration written to: $mcpConfigPath" -ForegroundColor Green
} catch {
    Write-Host "✗ Failed to write configuration file: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=== Installation Complete! ===" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Close and restart Cursor completely" -ForegroundColor White
Write-Host "2. The Playwright MCP server will be available for AI interactions" -ForegroundColor White
Write-Host "3. On first use, Playwright may download browser binaries (this is normal)" -ForegroundColor White
Write-Host ""
Write-Host "Configuration file location:" -ForegroundColor Cyan
Write-Host "$mcpConfigPath" -ForegroundColor White
Write-Host ""
Write-Host "To verify installation, restart Cursor and ask the AI to use browser automation features." -ForegroundColor Yellow

