#!/bin/bash
#
# Load all 18 batches to staging.v1_tablets via psql
# (Supabase MCP would require 18 separate tool calls, psql is more efficient)
#

BATCH_DIR="/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Devices & Infrastructure Entity/batches_v2"

echo "========================================="
echo "Loading 18 batches to staging.v1_tablets"
echo "========================================="
echo ""

# You'll need to set your Supabase connection string
# Example: export DATABASE_URL="postgresql://postgres:[password]@[host]:5432/postgres"

if [ -z "$DATABASE_URL" ]; then
    echo "ERROR: DATABASE_URL not set"
    echo "Please set it with:"
    echo "  export DATABASE_URL='your-supabase-connection-string'"
    exit 1
fi

# Load all 18 batches
for i in {01..18}; do
    BATCH_FILE="$BATCH_DIR/batch_${i}.sql"
    echo "Loading batch ${i}..."
    psql "$DATABASE_URL" < "$BATCH_FILE"
    
    if [ $? -eq 0 ]; then
        echo "  ✓ Batch ${i} loaded successfully"
    else
        echo "  ✗ Batch ${i} FAILED"
        exit 1
    fi
done

echo ""
echo "========================================="
echo "Verifying row count..."
echo "========================================="
psql "$DATABASE_URL" -c "SELECT COUNT(*) AS total_rows FROM staging.v1_tablets;"

echo ""
echo "✅ All batches loaded successfully!"

