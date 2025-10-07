#!/bin/bash
# Load remaining tables (skip problematic V1 part files for now)
set -e

PROJECT_HOST="db.nthpbtdjhhnwfxqsxbvy.supabase.co"
DATABASE="postgres"
USER="postgres"
CSV_DIR="/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Users_&_Access/CSV"

if [ -z "$SUPABASE_PASSWORD" ]; then
    echo "❌ Error: SUPABASE_PASSWORD not set"
    exit 1
fi

export PGPASSWORD="$SUPABASE_PASSWORD"

get_columns() {
    local table=$1
    /opt/homebrew/opt/libpq/bin/psql -h "$PROJECT_HOST" -U "$USER" -d "$DATABASE" -t -A -c "SELECT string_agg(column_name, ', ' ORDER BY ordinal_position) FROM information_schema.columns WHERE table_schema='staging' AND table_name='$table' AND column_name NOT LIKE '\_%'"
}

load_csv() {
    local table=$1
    local file=$2
    local delim=$3
    
    echo "📥 $file → staging.$table"
    cols=$(get_columns "$table")
    /opt/homebrew/opt/libpq/bin/psql -h "$PROJECT_HOST" -U "$USER" -d "$DATABASE" -c "\\COPY staging.$table ($cols) FROM '$CSV_DIR/$file' WITH (FORMAT CSV, HEADER true, DELIMITER '$delim', NULL '', QUOTE '\"', ESCAPE '\"', ENCODING 'LATIN1', FORCE_NULL ($cols))"
    count=$(/opt/homebrew/opt/libpq/bin/psql -h "$PROJECT_HOST" -U "$USER" -d "$DATABASE" -t -A -c "SELECT COUNT(*) FROM staging.$table;")
    echo "   ✅ $count rows"
    echo ""
}

echo "════════════════════════════════════════════════════════════"
echo "Loading Remaining Tables"
echo "════════════════════════════════════════════════════════════"
echo ""

# V1 Callcenter (semicolon)
load_csv "v1_callcenter_users" "menuca_v1_callcenter_users.csv" ";"

# V2 Tables (comma)
load_csv "v2_site_users" "menuca_v2_site_users.csv" ","
load_csv "v2_admin_users" "menuca_v2_admin_users.csv" ","
load_csv "v2_admin_users_restaurants" "menuca_v2_admin_users_restaurants.csv" ","
load_csv "v2_site_users_delivery_addresses" "menuca_v2_site_users_delivery_addresses.csv" ","
load_csv "v2_site_users_favorite_restaurants" "menuca_v2_site_users_favorite_restaurants.csv" ","
load_csv "v2_site_users_fb" "menuca_v2_site_users_fb.csv" ","
load_csv "v2_reset_codes" "menuca_v2_reset_codes.csv" ","
load_csv "v2_site_users_autologins" "menuca_v2_site_users_autologins.csv" ","

echo "✅ All remaining tables loaded!"
