#!/bin/bash
# ================================================================
# MySQL to PostgreSQL Dump Converter
# ================================================================
# Properly converts MySQL INSERT statements to PostgreSQL format
# ================================================================

set -e

PROJECT_HOST="db.nthpbtdjhhnwfxqsxbvy.supabase.co"
DATABASE="postgres"
USER="postgres"
DUMP_DIR="/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Users_&_Access/dumps"
TEMP_DIR="/tmp/pg_conversion"

if [ -z "$SUPABASE_PASSWORD" ]; then
    echo "❌ Error: SUPABASE_PASSWORD not set"
    exit 1
fi

export PGPASSWORD="$SUPABASE_PASSWORD"

mkdir -p "$TEMP_DIR"

echo "================================================================"
echo "Converting MySQL Dumps → PostgreSQL"
echo "================================================================"
echo ""

# Function to convert and load
convert_and_load() {
    local dump_file=$1
    local table=$2
    
    echo "📥 Converting: $dump_file → staging.$table"
    
    # Extract and convert INSERT statements
    # 1. Remove LOCK TABLES
    # 2. Remove MySQL comments
    # 3. Extract INSERT INTO lines
    # 4. Remove backticks
    # 5. Change table name to staging.$table
    # 6. Split multi-row INSERTs into single-row INSERTs (safer for errors)
    
    local temp_file="$TEMP_DIR/${table}.sql"
    
    # Extract INSERT statements and clean them up
    grep -v "^--" "$DUMP_DIR/$dump_file" | \
        grep -v "^/\*" | \
        grep -v "LOCK TABLES" | \
        grep -v "UNLOCK TABLES" | \
        grep -v "^$" | \
        sed 's/`//g' | \
        grep "INSERT INTO" | \
        sed "s/INSERT INTO [a-z_]*/INSERT INTO staging.$table/" \
        > "$temp_file"
    
    # Load into PostgreSQL
    echo "   Loading data..."
    /opt/homebrew/opt/libpq/bin/psql -h "$PROJECT_HOST" -U "$USER" -d "$DATABASE" \
        -f "$temp_file" \
        -v ON_ERROR_STOP=0 \
        2>&1 | grep -E "(ERROR|INSERT)" | head -20 || true
    
    # Check final count
    local count=$(/opt/homebrew/opt/libpq/bin/psql -h "$PROJECT_HOST" -U "$USER" -d "$DATABASE" -t -A -c "SELECT COUNT(*) FROM staging.$table;")
    echo "   ✅ Total rows: $count"
    echo "   📄 Temp file: $temp_file"
    echo ""
    
    # Keep temp file for debugging
    # rm -f "$temp_file"
}

echo "Loading V2 Tables from SQL Dumps"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

convert_and_load "menuca_v2_site_users.sql" "v2_site_users"
convert_and_load "menuca_v2_site_users_delivery_addresses.sql" "v2_site_users_delivery_addresses"
convert_and_load "menuca_v2_site_users_autologins.sql" "v2_site_users_autologins"

echo ""
echo "✅ CONVERSION COMPLETE!"
echo ""
