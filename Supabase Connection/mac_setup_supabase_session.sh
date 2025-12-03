#!/bin/bash
# Supabase Quick Session Setup Script
# Source this file to configure environment for Claude Code sessions
# Usage: source setup_supabase_session.sh

echo "🔧 Setting up Supabase session environment..."

# Supabase Credentials
export SUPABASE_ACCESS_TOKEN="sbp_c6c07320cadc875cfd087fd8f8edd03769c8b2b9"
export SUPABASE_SERVICE_ROLE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im50aHBidGRqaGhud2Z4cXN4YnZ5Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NTI3MzQ4NCwiZXhwIjoyMDcwODQ5NDg0fQ.THhg9RhwfeN2B9V1SZdef0iJIeBntwd2w67p_J0ch1g"
export SUPABASE_PROJECT_REF="nthpbtdjhhnwfxqsxbvy"
export SUPABASE_DB_PASSWORD="Gz35CPTom1RnsmGM"

# Connection String
export SUPABASE_CONNECTION_STRING="postgresql://postgres:${SUPABASE_DB_PASSWORD}@db.${SUPABASE_PROJECT_REF}.supabase.co:5432/postgres"

# PostgreSQL Client Path (Windows)
export PSQL_PATH="C:\Program Files\PostgreSQL\17\bin\psql.exe"

# Supabase API Endpoint
export SUPABASE_URL="https://${SUPABASE_PROJECT_REF}.supabase.co"
export SUPABASE_REST_API="${SUPABASE_URL}/rest/v1"

# Alias for quick psql access
alias supabase-psql="${PSQL_PATH} \"${SUPABASE_CONNECTION_STRING}\""

echo "✅ Supabase session configured!"
echo ""
echo "📋 Available environment variables:"
echo "   • SUPABASE_ACCESS_TOKEN"
echo "   • SUPABASE_SERVICE_ROLE_KEY"
echo "   • SUPABASE_PROJECT_REF: ${SUPABASE_PROJECT_REF}"
echo "   • SUPABASE_CONNECTION_STRING"
echo "   • SUPABASE_URL: ${SUPABASE_URL}"
echo ""
echo "🚀 Quick commands:"
echo "   • supabase projects list"
echo "   • supabase-psql -c \"SELECT 1\""
echo "   • \"\${PSQL_PATH}\" \"\${SUPABASE_CONNECTION_STRING}\" -c \"YOUR SQL\""
echo ""
echo "📖 Example query:"
echo "   \"\${PSQL_PATH}\" \"\${SUPABASE_CONNECTION_STRING}\" -c \"SELECT * FROM restaurants LIMIT 5;\""
echo ""
