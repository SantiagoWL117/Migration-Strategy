#!/bin/bash
# V1 Data Reload via psql CLI

DB_URL="postgresql://postgres.nthpbtdjhhnwfxqsxbvy:Gz35CPTom1RnsmGM@aws-1-us-east-1.pooler.supabase.com:5432/postgres"
BATCH_DIR="split_pg"

echo "=================================="
echo "V1 DATA RELOAD - PSQL CLI METHOD"
echo "=================================="
echo ""

# Function to load table batches
load_table() {
    local table=$1
    local pattern=$2
    local expected=$3
    
    echo "📊 Loading: $table"
    echo "Expected batches: $expected"
    echo ""
    
    local count=0
    for batch in $BATCH_DIR/$pattern; do
        if [ -f "$batch" ]; then
            count=$((count + 1))
            echo "  [$count/$expected] $(basename $batch)"
            psql "$DB_URL" -f "$batch" -q
            if [ $? -ne 0 ]; then
                echo "❌ Error loading $batch"
                return 1
            fi
        fi
    done
    
    echo "✅ $table complete: $count batches loaded"
    echo ""
}

# Load tables
load_table "v1_ingredient_groups" "menuca_v1_ingredient_groups_batch_*.sql" 16
load_table "v1_ingredients" "menuca_v1_ingredients_batch_*.sql" 54
load_table "v1_combo_groups" "menuca_v1_combo_groups_batch_*.sql" 68
load_table "v1_menu" "menuca_v1_menu_batch_*.sql" 126

echo "=================================="
echo "🔍 Verifying Row Counts..."
echo "=================================="

psql "$DB_URL" -c "
SELECT 
    'v1_ingredient_groups' as table_name,
    COUNT(*) as rows,
    13450 as expected
FROM staging.v1_ingredient_groups
UNION ALL
SELECT 'v1_ingredients', COUNT(*), 53367 FROM staging.v1_ingredients
UNION ALL
SELECT 'v1_combo_groups', COUNT(*), 62913 FROM staging.v1_combo_groups
UNION ALL
SELECT 'v1_menu', COUNT(*), 138941 FROM staging.v1_menu;
"

echo ""
echo "✅ RELOAD COMPLETE!"

