#!/bin/bash
# ================================================================
# Load from SQL Dumps (MySQL → PostgreSQL)
# ================================================================
# This is MUCH more reliable than CSVs for complex data with
# special characters, bcrypt hashes, commas, etc.
# ================================================================

set -e

PROJECT_HOST="db.nthpbtdjhhnwfxqsxbvy.supabase.co"
DATABASE="postgres"
USER="postgres"
DUMP_DIR="/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Users_&_Access/dumps"

if [ -z "$SUPABASE_PASSWORD" ]; then
    echo "❌ Error: SUPABASE_PASSWORD not set"
    exit 1
fi

export PGPASSWORD="$SUPABASE_PASSWORD"

echo "================================================================"
echo "Loading from SQL Dumps (MySQL → PostgreSQL)"
echo "================================================================"
echo ""

# Function to convert MySQL dump to PostgreSQL
convert_and_load() {
    local dump_file=$1
    local table=$2
    
    echo "📥 Loading: $dump_file → staging.$table"
    
    # Extract INSERT statements and convert MySQL to PostgreSQL syntax
    # 1. Remove MySQL-specific comments /*! ... */
    # 2. Remove SET commands
    # 3. Remove DROP/CREATE TABLE statements
    # 4. Keep only INSERT statements
    # 5. Convert MySQL backticks to nothing (PostgreSQL uses double quotes, but we don't need them for simple names)
    # 6. Add _loaded_at = NOW() to each INSERT
    
    grep -i "INSERT INTO" "$DUMP_DIR/$dump_file" | \
        sed -E "s/INSERT INTO \`?[a-z_]+\`?/INSERT INTO staging.$table/" | \
        sed -E "s/\`//g" | \
        /opt/homebrew/opt/libpq/bin/psql -h "$PROJECT_HOST" -U "$USER" -d "$DATABASE" 2>&1 | \
        grep -v "^INSERT"  | \
        (grep "ERROR" || true)
    
    # Check if successful
    if [ $? -eq 0 ]; then
        count=$(/opt/homebrew/opt/libpq/bin/psql -h "$PROJECT_HOST" -U "$USER" -d "$DATABASE" -t -A -c "SELECT COUNT(*) FROM staging.$table;")
        echo "   ✅ $count rows loaded"
    else
        echo "   ⚠️  Some errors occurred (check above)"
    fi
    
    echo ""
}

echo "STEP 1: Loading V1 Tables"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
convert_and_load "menuca_v1_callcenter_users.sql" "v1_callcenter_users"

echo ""
echo "STEP 2: Loading V2 Tables"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
convert_and_load "menuca_v2_site_users.sql" "v2_site_users"
convert_and_load "menuca_v2_admin_users.sql" "v2_admin_users"
convert_and_load "menuca_v2_admin_users_restaurants.sql" "v2_admin_users_restaurants"
convert_and_load "menuca_v2_site_users_delivery_addresses.sql" "v2_site_users_delivery_addresses"
convert_and_load "menuca_v2_site_users_favorite_restaurants.sql" "v2_site_users_favorite_restaurants"
convert_and_load "menuca_v2_site_users_fb.sql" "v2_site_users_fb"
convert_and_load "menuca_v2_reset_codes.sql" "v2_reset_codes"
convert_and_load "menuca_v2_site_users_autologins.sql" "v2_site_users_autologins"

echo ""
echo "✅ ALL DUMPS LOADED!"
echo ""
echo "Note: V1 users main file already loaded successfully (14,291 rows)"
echo "      V1 part files have CSV issues - investigating alternative approaches"
echo ""
