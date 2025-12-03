#!/bin/bash
# Supabase Quick Session Setup Script
# Loads credentials from .env file for security
# Usage: source mac_setup_supabase_session.sh

echo "🔧 Setting up Supabase session environment..."

# Find the .env file (in .env files folder)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ENV_FILE="${SCRIPT_DIR}/../.env files/.env"

# Check if .env file exists
if [ ! -f "$ENV_FILE" ]; then
    echo "❌ ERROR: .env file not found at: $ENV_FILE"
    echo ""
    echo "Expected location: .env files/.env"
    echo ""
    return 1 2>/dev/null || exit 1
fi

# Load environment variables from .env file
echo "📦 Loading credentials from .env file..."
set -a  # automatically export all variables
source "$ENV_FILE"
set +a

# Map the .env variables to expected names
# The .env file uses SUPABASE_KEY instead of SUPABASE_SERVICE_ROLE_KEY
if [ -n "$SUPABASE_KEY" ] && [ -z "$SUPABASE_SERVICE_ROLE_KEY" ]; then
    export SUPABASE_SERVICE_ROLE_KEY="$SUPABASE_KEY"
fi

# Extract DB password from DB_CONNECTION_STRING if SUPABASE_DB_PASSWORD not set
if [ -n "$DB_CONNECTION_STRING" ] && [ -z "$SUPABASE_DB_PASSWORD" ]; then
    if [[ "$DB_CONNECTION_STRING" =~ postgres://postgres:([^@]+)@ ]]; then
        export SUPABASE_DB_PASSWORD="${BASH_REMATCH[1]}"
    fi
fi

# Verify required variables are set
REQUIRED_VARS=("SUPABASE_KEY" "DB_CONNECTION_STRING")
MISSING_VARS=()

for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        MISSING_VARS+=("$var")
    fi
done

if [ ${#MISSING_VARS[@]} -gt 0 ]; then
    echo "❌ ERROR: Missing required environment variables:"
    for var in "${MISSING_VARS[@]}"; do
        echo "   - $var"
    done
    echo ""
    echo "Please verify your .env file at: $ENV_FILE"
    return 1 2>/dev/null || exit 1
fi

# Set derived variables
export SUPABASE_PROJECT_REF="nthpbtdjhhnwfxqsxbvy"

# Use SUPABASE_URL from .env if available, otherwise derive it
if [ -z "$SUPABASE_URL" ]; then
    export SUPABASE_URL="https://${SUPABASE_PROJECT_REF}.supabase.co"
fi

export SUPABASE_REST_API="${SUPABASE_URL}/rest/v1"

# Use DB_CONNECTION_STRING from .env (already set)
export SUPABASE_CONNECTION_STRING="$DB_CONNECTION_STRING"

# Set psql path based on OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS - check common PostgreSQL installation paths
    if [ -f "/Applications/Postgres.app/Contents/Versions/latest/bin/psql" ]; then
        export PSQL_PATH="/Applications/Postgres.app/Contents/Versions/latest/bin/psql"
    elif command -v psql &> /dev/null; then
        export PSQL_PATH=$(which psql)
    else
        export PSQL_PATH="psql"
    fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    export PSQL_PATH=$(which psql 2>/dev/null || echo "psql")
else
    # Default
    export PSQL_PATH="psql"
fi

# Create alias for quick psql access
alias supabase-psql="${PSQL_PATH} \"${SUPABASE_CONNECTION_STRING}\""

echo "✅ Supabase session configured!"
echo ""
echo "📋 Environment variables set:"
echo "  ✓ SUPABASE_KEY (Service Role Key)"
echo "  ✓ SUPABASE_DB_PASSWORD"
echo "  ✓ SUPABASE_PROJECT_REF: ${SUPABASE_PROJECT_REF}"
echo "  ✓ SUPABASE_URL: ${SUPABASE_URL}"
echo "  ✓ DB_CONNECTION_STRING (loaded from .env)"
echo "  ✓ PSQL_PATH: ${PSQL_PATH}"
echo ""
echo "🚀 Quick commands:"
echo "   • supabase projects list"
echo "   • supabase-psql -c \"SELECT 1\""
echo "   • \"\${PSQL_PATH}\" \"\${SUPABASE_CONNECTION_STRING}\" -c \"YOUR SQL\""
echo ""
echo "📖 Example query:"
echo "   • supabase-psql -c \"SELECT COUNT(*) FROM menuca_v3.restaurants;\""
echo ""
