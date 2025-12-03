# Get Database Connection String from .env
# Quick helper to get the DB connection string for psql commands
# Usage: $conn = .\scripts\get_db_connection.ps1

$envVars = & "$PSScriptRoot\load_env.ps1"
Write-Output $envVars["DB_CONNECTION_STRING"]
