#!/bin/bash

# Automated batch loading script for Supabase
# Uses psql to load all split batch files

# Supabase connection details
DB_HOST="aws-1-us-east-1.pooler.supabase.com"
DB_PORT="5432"  # Session pooler
DB_NAME="postgres"
DB_USER="postgres.nthpbtdjhhnwfxqsxbvy"
DB_PASSWORD="SgqBbe2xUuerQBZ5"

# Full psql path
PSQL="/opt/homebrew/opt/postgresql@16/bin/psql"

# Directory with batch files
BATCH_DIR="/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu & Catalog Entity/split_pg"

# Connection string
CONN_STRING="postgresql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}"

echo "=========================================="
echo "Loading Menu & Catalog Data Batches"
echo "=========================================="
echo ""
echo "📁 Batch directory: $BATCH_DIR"
echo "🔗 Database: $DB_HOST:$DB_PORT"
echo ""

# Count total files
TOTAL_FILES=$(ls -1 "$BATCH_DIR"/*.sql 2>/dev/null | wc -l)
echo "📊 Total batch files: $TOTAL_FILES"
echo ""

if [ "$TOTAL_FILES" -eq 0 ]; then
    echo "❌ No batch files found!"
    exit 1
fi

# Load each batch file
LOADED=0
FAILED=0

for batch_file in "$BATCH_DIR"/*.sql; do
    filename=$(basename "$batch_file")
    echo -n "Loading $filename... "
    
    # Execute the batch file
    if "$PSQL" "$CONN_STRING" -f "$batch_file" > /dev/null 2>&1; then
        echo "✅"
        ((LOADED++))
    else
        echo "❌ FAILED"
        ((FAILED++))
        # Show the error
        "$PSQL" "$CONN_STRING" -f "$batch_file" 2>&1 | head -5
    fi
done

echo ""
echo "=========================================="
echo "📊 Loading Summary"
echo "=========================================="
echo "✅ Loaded: $LOADED files"
echo "❌ Failed: $FAILED files"
echo "📈 Total: $TOTAL_FILES files"
echo ""

if [ "$FAILED" -eq 0 ]; then
    echo "🎉 All batches loaded successfully!"
else
    echo "⚠️  Some batches failed. Check errors above."
fi

