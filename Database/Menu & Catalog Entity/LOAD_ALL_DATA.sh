#!/bin/bash

# ============================================
# MASTER SCRIPT: Load ALL Menu & Catalog Data
# ============================================

set -e  # Exit on any error

# --- Configuration ---
PSQL="/opt/homebrew/opt/postgresql@16/bin/psql"
PROJECT_REF="nthpbtdjhhnwfxqsxbvy"
DB_USER="postgres.nthpbtdjhhnwfxqsxbvy"
DB_NAME="postgres"
DB_HOST="aws-0-us-east-1.pooler.supabase.com"
DB_PORT="6543"

# Check password
if [ -z "$SUPABASE_DB_PASSWORD" ]; then
  echo "❌ Error: SUPABASE_DB_PASSWORD not set!"
  echo "Run: export SUPABASE_DB_PASSWORD='your-password'"
  exit 1
fi

# Connection string
CONN_STRING="postgresql://${DB_USER}:${SUPABASE_DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}"

echo "🚀 Menu & Catalog Data Migration"
echo "===================================="
echo ""

# --- Step 1: Fix Staging Tables ---
echo "📋 Step 1: Fixing staging table structures..."
if $PSQL "$CONN_STRING" -f "FIX_ALL_STAGING_TABLES.sql" > /dev/null 2>&1; then
  echo "   ✅ Staging tables fixed!"
else
  echo "   ❌ Failed to fix staging tables"
  exit 1
fi
echo ""

# --- Step 2: Load V1 Data ---
echo "📦 Step 2: Loading V1 Data..."

echo "   📄 v1_courses..."
$PSQL "$CONN_STRING" -f "fixed/menuca_v1_courses_WITH_COLUMNS.sql" > /dev/null 2>&1 && echo "      ✅" || echo "      ❌"

echo "   📄 v1_combos..."
$PSQL "$CONN_STRING" -f "fixed/menuca_v1_combos_fixed.sql" > /dev/null 2>&1 && echo "      ✅" || echo "      ❌"

echo ""

# --- Step 3: Load V2 Data ---
echo "📦 Step 3: Loading V2 Data..."

echo "   📄 v2_restaurants_courses..."
$PSQL "$CONN_STRING" -f "fixed/menuca_v2_restaurants_courses_fixed.sql" > /dev/null 2>&1 && echo "      ✅" || echo "      ❌"

echo "   📄 v2_restaurants_dishes..."
$PSQL "$CONN_STRING" -f "fixed/menuca_v2_restaurants_dishes_fixed.sql" > /dev/null 2>&1 && echo "      ✅" || echo "      ❌"

echo "   📄 v2_restaurants_dishes_customization..."
$PSQL "$CONN_STRING" -f "fixed/menuca_v2_restaurants_dishes_customization_fixed.sql" > /dev/null 2>&1 && echo "      ✅" || echo "      ❌"

echo "   📄 v2_restaurants_combo_groups..."
$PSQL "$CONN_STRING" -f "fixed/menuca_v2_restaurants_combo_groups_fixed.sql" > /dev/null 2>&1 && echo "      ✅" || echo "      ❌"

echo "   📄 v2_restaurants_combo_groups_items..."
$PSQL "$CONN_STRING" -f "fixed/menuca_v2_restaurants_combo_groups_items_fixed.sql" > /dev/null 2>&1 && echo "      ✅" || echo "      ❌"

echo "   📄 v2_restaurants_ingredient_groups..."
$PSQL "$CONN_STRING" -f "fixed/menuca_v2_restaurants_ingredient_groups_fixed.sql" > /dev/null 2>&1 && echo "      ✅" || echo "      ❌"

echo "   📄 v2_restaurants_ingredient_groups_items..."
$PSQL "$CONN_STRING" -f "fixed/menuca_v2_restaurants_ingredient_groups_items_fixed.sql" > /dev/null 2>&1 && echo "      ✅" || echo "      ❌"

echo "   📄 v2_restaurants_ingredients..."
$PSQL "$CONN_STRING" -f "fixed/menuca_v2_restaurants_ingredients_fixed.sql" > /dev/null 2>&1 && echo "      ✅" || echo "      ❌"

echo "   📄 v2_global_ingredients..."
$PSQL "$CONN_STRING" -f "fixed/menuca_v2_global_ingredients_fixed.sql" > /dev/null 2>&1 && echo "      ✅" || echo "      ❌"

echo ""

# --- Step 4: Verify ---
echo "📊 Step 4: Verifying data..."
echo ""

$PSQL "$CONN_STRING" -c "
SELECT 
  'v1_courses' as table_name, COUNT(*) as row_count FROM staging.v1_courses UNION ALL
SELECT 'v1_combos', COUNT(*) FROM staging.v1_combos UNION ALL
SELECT 'v2_restaurants_courses', COUNT(*) FROM staging.v2_restaurants_courses UNION ALL
SELECT 'v2_restaurants_dishes', COUNT(*) FROM staging.v2_restaurants_dishes UNION ALL
SELECT 'v2_restaurants_dishes_customization', COUNT(*) FROM staging.v2_restaurants_dishes_customization UNION ALL
SELECT 'v2_restaurants_combo_groups', COUNT(*) FROM staging.v2_restaurants_combo_groups UNION ALL
SELECT 'v2_restaurants_combo_groups_items', COUNT(*) FROM staging.v2_restaurants_combo_groups_items UNION ALL
SELECT 'v2_restaurants_ingredient_groups', COUNT(*) FROM staging.v2_restaurants_ingredient_groups UNION ALL
SELECT 'v2_restaurants_ingredient_groups_items', COUNT(*) FROM staging.v2_restaurants_ingredient_groups_items UNION ALL
SELECT 'v2_restaurants_ingredients', COUNT(*) FROM staging.v2_restaurants_ingredients UNION ALL
SELECT 'v2_global_ingredients', COUNT(*) FROM staging.v2_global_ingredients
ORDER BY table_name;
" 2>/dev/null

echo ""
echo "===================================="
echo "✅ ALL DATA LOADED SUCCESSFULLY!"
echo "===================================="

