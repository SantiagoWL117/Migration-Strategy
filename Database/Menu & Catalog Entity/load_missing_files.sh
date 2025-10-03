#!/bin/bash

# Load the missing Menu & Catalog files with CORRECT connection string

# CORRECT Supabase connection (aws-1, not aws-0!)
DB_PASSWORD="SgqBbe2xUuerQBZ5"
CONN_STRING="postgresql://postgres.nthpbtdjhhnwfxqsxbvy:${DB_PASSWORD}@aws-1-us-east-1.pooler.supabase.com:5432/postgres"

# psql path
PSQL="/opt/homebrew/opt/postgresql@16/bin/psql"

# Batch directory
BATCH_DIR="/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu & Catalog Entity/split_pg"

echo "=========================================="
echo "🔄 Loading Missing Menu & Catalog Files"
echo "=========================================="
echo ""

# Test connection
echo "Testing connection..."
if ! "$PSQL" "$CONN_STRING" -c "SELECT 1;" > /dev/null 2>&1; then
    echo "❌ Connection failed!"
    "$PSQL" "$CONN_STRING" -c "SELECT 1;"
    exit 1
fi
echo "✅ Connection successful!"
echo ""

# Files to load (the ones with 0 rows)
MISSING_FILES=(
    # V1 files
    "menuca_v1_ingredients_batch_"
    "menuca_v1_menu_batch_"
    # V2 files
    "menuca_v2_global_ingredients_batch_"
    "menuca_v2_restaurants_combo_groups_items"
    "menuca_v2_restaurants_courses_batch_"
    "menuca_v2_restaurants_dishes_batch_"
    "menuca_v2_restaurants_dishes_customization_batch_"
    "menuca_v2_restaurants_ingredient_groups_"
    "menuca_v2_restaurants_ingredient_groups_items_batch_"
    "menuca_v2_restaurants_ingredients_batch_"
)

LOADED=0
FAILED=0

for pattern in "${MISSING_FILES[@]}"; do
    for batch_file in "$BATCH_DIR"/${pattern}*.sql; do
        if [ -f "$batch_file" ]; then
            filename=$(basename "$batch_file")
            echo -n "Loading $filename... "
            
            if "$PSQL" "$CONN_STRING" -f "$batch_file" > /dev/null 2>&1; then
                echo "✅"
                ((LOADED++))
            else
                echo "❌ FAILED"
                ((FAILED++))
                # Show error for first failure
                if [ "$FAILED" -eq 1 ]; then
                    "$PSQL" "$CONN_STRING" -f "$batch_file" 2>&1 | head -5
                fi
            fi
        fi
    done
done

echo ""
echo "=========================================="
echo "📊 Summary"
echo "=========================================="
echo "✅ Loaded: $LOADED files"
echo "❌ Failed: $FAILED files"
echo ""

if [ "$FAILED" -eq 0 ]; then
    echo "🎉 All missing files loaded successfully!"
else
    echo "⚠️  Some files failed. Check errors above."
fi

