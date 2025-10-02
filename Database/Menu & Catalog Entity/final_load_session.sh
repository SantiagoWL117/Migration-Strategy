#!/bin/bash

# FINAL loading attempt using Session Pooler (not Transaction Pooler)
# Session pooler supports all PostgreSQL features

# Supabase Session Pooler connection
DB_HOST="aws-0-us-east-1.pooler.supabase.com"
DB_PORT="6543"  # Session pooler port
DB_NAME="postgres"
DB_USER="postgres.nthpbtdjhhnwfxqsxbvy"
DB_PASSWORD="SgqBbe2xUuerQBZ5"

# Full psql path
PSQL="/opt/homebrew/opt/postgresql@16/bin/psql"

# Batch directory
BATCH_DIR="/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu & Catalog Entity/split_pg"

# Connection string for Session Pooler (no pgbouncer param)
CONN_STRING="postgresql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}"

echo "=========================================="
echo "🔄 Final Loading Attempt - Session Pooler"
echo "=========================================="
echo ""
echo "Testing connection..."

# Test connection first
if ! "$PSQL" "$CONN_STRING" -c "SELECT 1;" > /dev/null 2>&1; then
    echo "❌ Connection failed!"
    "$PSQL" "$CONN_STRING" -c "SELECT 1;" 2>&1
    echo ""
    echo "Alternative: Try loading the ORIGINAL unsplit files via SQL Editor:"
    echo "They're in: /Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu & Catalog Entity/final_pg/"
    exit 1
fi

echo "✅ Connection successful!"
echo ""
echo "📁 Loading from: $BATCH_DIR"
echo ""

# Load each batch
LOADED=0
FAILED=0
TOTAL=$(ls -1 "$BATCH_DIR"/*.sql 2>/dev/null | wc -l | tr -d ' ')

for batch_file in "$BATCH_DIR"/*.sql; do
    filename=$(basename "$batch_file")
    echo -n "[$((LOADED + FAILED + 1))/$TOTAL] $filename... "
    
    if "$PSQL" "$CONN_STRING" -f "$batch_file" > /dev/null 2>&1; then
        echo "✅"
        ((LOADED++))
    else
        echo "❌"
        ((FAILED++))
    fi
done

echo ""
echo "=========================================="
echo "📊 Summary"
echo "=========================================="
echo "✅ Loaded: $LOADED"
echo "❌ Failed: $FAILED"
echo "📈 Total: $TOTAL"

