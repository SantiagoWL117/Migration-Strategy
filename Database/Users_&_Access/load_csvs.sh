#!/bin/bash
# ================================================================
# Quick CSV Loader for Users & Access
# ================================================================
# Run this after providing your Supabase password:
# 
# Usage: 
#   export SUPABASE_PASSWORD="your_password_here"
#   ./load_csvs.sh
#
# Or run directly:
#   SUPABASE_PASSWORD="your_password" ./load_csvs.sh
# ================================================================

set -e  # Exit on error

# Configuration
PROJECT_HOST="db.nthpbtdjhhnwfxqsxbvy.supabase.co"
DATABASE="postgres"
USER="postgres"
CSV_DIR="/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Users_&_Access/CSV"

# Check password
if [ -z "$SUPABASE_PASSWORD" ]; then
    echo "❌ Error: SUPABASE_PASSWORD environment variable not set"
    echo ""
    echo "Usage:"
    echo "  export SUPABASE_PASSWORD=\"your_password_here\""
    echo "  ./load_csvs.sh"
    echo ""
    echo "Or:"
    echo "  SUPABASE_PASSWORD=\"your_password\" ./load_csvs.sh"
    exit 1
fi

# Build connection string
export PGPASSWORD="$SUPABASE_PASSWORD"
CONN="postgresql://$USER@$PROJECT_HOST:5432/$DATABASE"

echo "================================================================"
echo "Loading CSVs into Supabase staging tables..."
echo "================================================================"
echo ""

# Function to load CSV with progress
load_csv() {
    local table=$1
    local csv_file=$2
    local delimiter=$3
    
    echo "📥 Loading: $csv_file → staging.$table"
    
    # Use specific column list (exclude _loaded_at which has DEFAULT)
    local columns=$(psql "$CONN" -t -c "SELECT string_agg(column_name, ', ') FROM information_schema.columns WHERE table_schema='staging' AND table_name='$table' AND column_name NOT LIKE '\_%' ORDER BY ordinal_position;")
    
    psql "$CONN" -c "\COPY staging.$table ($columns) FROM '$CSV_DIR/$csv_file' WITH (FORMAT CSV, HEADER true, DELIMITER '$delimiter', NULL '', ENCODING 'UTF8', FORCE_NULL ($columns))" 2>&1 | grep -v "^COPY" || true
    
    local count=$(psql "$CONN" -t -c "SELECT COUNT(*) FROM staging.$table;" | tr -d ' ')
    echo "   ✅ Loaded: $count rows"
    echo ""
}

# ================================================================
# Load V1 Tables
# ================================================================
echo "Loading V1 Tables (delimiter: semicolon)"
echo "----------------------------------------"

# V1 Users (4 parts)
echo "📦 Loading V1 users (4 CSV files)..."
load_csv "v1_users" "menuca_v1_users.csv" ";"
load_csv "v1_users" "menuca_v1_users_part1.csv" ";"
load_csv "v1_users" "menuca_v1_users_part2.csv" ";"
load_csv "v1_users" "menuca_v1_users_part3.csv" ";"

# Update source file tracking
psql "$CONN" -c "UPDATE staging.v1_users SET _source_file = 'menuca_v1_users.csv' WHERE _source_file IS NULL AND id <= 14292;" > /dev/null
psql "$CONN" -c "UPDATE staging.v1_users SET _source_file = 'menuca_v1_users_part1.csv' WHERE _source_file IS NULL AND id <= 142665;" > /dev/null
psql "$CONN" -c "UPDATE staging.v1_users SET _source_file = 'menuca_v1_users_part2.csv' WHERE _source_file IS NULL AND id <= 285330;" > /dev/null
psql "$CONN" -c "UPDATE staging.v1_users SET _source_file = 'menuca_v1_users_part3.csv' WHERE _source_file IS NULL;" > /dev/null

# V1 Callcenter
load_csv "v1_callcenter_users" "menuca_v1_callcenter_users.csv" ";"

# ================================================================
# Apply Active User Filter to V1
# ================================================================
echo "🔍 Filtering V1 users (active only: lastLogin > 2020-01-01)..."

# Create backup of excluded users
psql "$CONN" << 'SQL' > /dev/null
CREATE TABLE IF NOT EXISTS staging.v1_users_excluded AS
SELECT *, 'inactive_old_login'::TEXT as exclusion_reason, NOW() as excluded_at
FROM staging.v1_users
WHERE lastLogin IS NULL OR lastLogin <= '2020-01-01';
SQL

# Delete inactive users
psql "$CONN" -c "DELETE FROM staging.v1_users WHERE lastLogin IS NULL OR lastLogin <= '2020-01-01';" > /dev/null

# Report filtering results
active=$(psql "$CONN" -t -c "SELECT COUNT(*) FROM staging.v1_users;" | tr -d ' ')
excluded=$(psql "$CONN" -t -c "SELECT COUNT(*) FROM staging.v1_users_excluded;" | tr -d ' ')

echo "   ✅ Active users kept: $active"
echo "   📦 Inactive users excluded: $excluded (backed up in staging.v1_users_excluded)"
echo ""

# ================================================================
# Load V2 Tables
# ================================================================
echo "Loading V2 Tables (delimiter: comma)"
echo "----------------------------------------"

load_csv "v2_site_users" "menuca_v2_site_users.csv" ","
load_csv "v2_admin_users" "menuca_v2_admin_users.csv" ","
load_csv "v2_admin_users_restaurants" "menuca_v2_admin_users_restaurants.csv" ","
load_csv "v2_site_users_delivery_addresses" "menuca_v2_site_users_delivery_addresses.csv" ","

# V2 reset codes with filtering
echo "📥 Loading: menuca_v2_reset_codes.csv → staging.v2_reset_codes"
psql "$CONN" -c "\COPY staging.v2_reset_codes FROM '$CSV_DIR/menuca_v2_reset_codes.csv' WITH (FORMAT CSV, HEADER true, DELIMITER ',', NULL '', ENCODING 'UTF8')" 2>&1 | grep -v "^COPY" || true

echo "🔍 Filtering reset codes (active only: expires_at > NOW())..."
psql "$CONN" << 'SQL' > /dev/null
CREATE TABLE IF NOT EXISTS staging.v2_reset_codes_excluded AS
SELECT *, 'expired_token'::TEXT as exclusion_reason, NOW() as excluded_at
FROM staging.v2_reset_codes
WHERE expires_at IS NULL OR expires_at <= NOW();

DELETE FROM staging.v2_reset_codes
WHERE expires_at IS NULL OR expires_at <= NOW();
SQL

active_tokens=$(psql "$CONN" -t -c "SELECT COUNT(*) FROM staging.v2_reset_codes;" | tr -d ' ')
expired_tokens=$(psql "$CONN" -t -c "SELECT COUNT(*) FROM staging.v2_reset_codes_excluded;" | tr -d ' ')
echo "   ✅ Active tokens: $active_tokens"
echo "   📦 Expired tokens excluded: $expired_tokens"
echo ""

# V2 autologin tokens with filtering
echo "📥 Loading: menuca_v2_site_users_autologins.csv → staging.v2_site_users_autologins"
psql "$CONN" -c "\COPY staging.v2_site_users_autologins FROM '$CSV_DIR/menuca_v2_site_users_autologins.csv' WITH (FORMAT CSV, HEADER true, DELIMITER ',', NULL '', ENCODING 'UTF8')" 2>&1 | grep -v "^COPY" || true

echo "🔍 Filtering autologin tokens (active only: expire > NOW())..."
psql "$CONN" << 'SQL' > /dev/null
CREATE TABLE IF NOT EXISTS staging.v2_site_users_autologins_excluded AS
SELECT *, 'expired_token'::TEXT as exclusion_reason, NOW() as excluded_at
FROM staging.v2_site_users_autologins
WHERE expire IS NULL OR expire <= NOW();

DELETE FROM staging.v2_site_users_autologins
WHERE expire IS NULL OR expire <= NOW();
SQL

active_auto=$(psql "$CONN" -t -c "SELECT COUNT(*) FROM staging.v2_site_users_autologins;" | tr -d ' ')
expired_auto=$(psql "$CONN" -t -c "SELECT COUNT(*) FROM staging.v2_site_users_autologins_excluded;" | tr -d ' ')
echo "   ✅ Active autologin tokens: $active_auto"
echo "   📦 Expired tokens excluded: $expired_auto"
echo ""

# Load remaining V2 tables
load_csv "v2_site_users_favorite_restaurants" "menuca_v2_site_users_favorite_restaurants.csv" ","
load_csv "v2_site_users_fb" "menuca_v2_site_users_fb.csv" ","

# ================================================================
# Final Summary
# ================================================================
echo "================================================================"
echo "✅ CSV LOADING COMPLETE!"
echo "================================================================"
echo ""
echo "Summary of loaded data:"
echo ""

psql "$CONN" << 'SQL'
SELECT 
    'V1 users (active only)' as table_name, 
    COUNT(*) as row_count,
    'FILTERED: lastLogin > 2020-01-01' as notes
FROM staging.v1_users
UNION ALL
SELECT 'V1 users (excluded)', COUNT(*), 'Backup of inactive users'
FROM staging.v1_users_excluded
UNION ALL
SELECT 'V1 callcenter_users', COUNT(*), 'All staff accounts'
FROM staging.v1_callcenter_users
UNION ALL
SELECT 'V2 site_users', COUNT(*), 'All V2 users (all active)'
FROM staging.v2_site_users
UNION ALL
SELECT 'V2 admin_users', COUNT(*), 'Platform admins'
FROM staging.v2_admin_users
UNION ALL
SELECT 'V2 admin_users_restaurants', COUNT(*), 'Admin-restaurant junction'
FROM staging.v2_admin_users_restaurants
UNION ALL
SELECT 'V2 delivery_addresses', COUNT(*), 'User saved addresses'
FROM staging.v2_site_users_delivery_addresses
UNION ALL
SELECT 'V2 reset_codes (active)', COUNT(*), 'FILTERED: expires_at > NOW()'
FROM staging.v2_reset_codes
UNION ALL
SELECT 'V2 reset_codes (excluded)', COUNT(*), 'Backup of expired tokens'
FROM staging.v2_reset_codes_excluded
UNION ALL
SELECT 'V2 autologins (active)', COUNT(*), 'FILTERED: expire > NOW()'
FROM staging.v2_site_users_autologins
UNION ALL
SELECT 'V2 autologins (excluded)', COUNT(*), 'Backup of expired tokens'
FROM staging.v2_site_users_autologins_excluded
UNION ALL
SELECT 'V2 favorite_restaurants', COUNT(*), 'User favorites'
FROM staging.v2_site_users_favorite_restaurants
UNION ALL
SELECT 'V2 fb_profiles', COUNT(*), 'Facebook OAuth'
FROM staging.v2_site_users_fb
ORDER BY table_name;
SQL

echo ""
echo "================================================================"
echo "Next step: Run data quality assessment"
echo "================================================================"
echo ""
echo "Run this command:"
echo "  psql \"$CONN\" -f Database/Users_&_Access/03_data_quality_assessment.sql"
echo ""
