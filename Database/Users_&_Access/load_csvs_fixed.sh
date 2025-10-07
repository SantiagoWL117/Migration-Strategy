#!/bin/bash
# ================================================================
# ROBUST CSV Loader for MySQL→PostgreSQL Migration
# ================================================================
# Handles common MySQL export issues:
# - Embedded commas in quoted fields
# - Newlines within quoted fields
# - Empty strings as NULL values
# - Different delimiters (semicolon for V1, comma for V2)
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
    echo "Usage: SUPABASE_PASSWORD=\"your_password\" ./load_csvs_fixed.sh"
    exit 1
fi

# Build connection string
export PGPASSWORD="$SUPABASE_PASSWORD"
CONN="postgresql://$USER@$PROJECT_HOST:5432/$DATABASE"

echo "================================================================"
echo "Loading CSVs with MySQL export compatibility..."
echo "================================================================"
echo ""

# Function to get column list (excluding _loaded_at and other metadata)
get_columns() {
    local table=$1
    psql "$CONN" -t -A -c "
        SELECT string_agg(column_name, ', ' ORDER BY ordinal_position)
        FROM information_schema.columns 
        WHERE table_schema='staging' 
          AND table_name='$table' 
          AND column_name NOT LIKE '\_%'
    "
}

# Function to load CSV with robust error handling
load_csv() {
    local table=$1
    local csv_file=$2
    local delimiter=$3
    
    echo "📥 Loading: $csv_file → staging.$table"
    
    # Get columns dynamically
    local columns=$(get_columns "$table")
    
    if [ -z "$columns" ]; then
        echo "   ❌ ERROR: Could not fetch column list for staging.$table"
        return 1
    fi
    
    # Count CSV rows (excluding header)
    local csv_rows=$(tail -n +2 "$CSV_DIR/$csv_file" | wc -l | tr -d ' ')
    echo "   📊 CSV file contains: $csv_rows rows"
    
    # Use PostgreSQL COPY with MySQL-friendly options
    psql "$CONN" <<SQL
\COPY staging.$table ($columns) 
FROM '$CSV_DIR/$csv_file' 
WITH (
    FORMAT CSV,
    HEADER true,
    DELIMITER '$delimiter',
    NULL '',
    QUOTE '"',
    ESCAPE '"',
    ENCODING 'UTF8'
)
SQL
    
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        echo "   ❌ FAILED to load $csv_file (exit code: $exit_code)"
        return 1
    fi
    
    # Verify row count
    local loaded_count=$(psql "$CONN" -t -A -c "SELECT COUNT(*) FROM staging.$table;")
    echo "   ✅ Loaded: $loaded_count rows"
    
    # Warn if counts don't match
    if [ "$loaded_count" != "$csv_rows" ]; then
        echo "   ⚠️  WARNING: CSV had $csv_rows rows but only $loaded_count loaded!"
    fi
    
    echo ""
}

# ================================================================
# STEP 1: Load V1 Tables (delimiter: semicolon)
# ================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 1: Loading V1 Tables"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# V1 Users (4 parts - will be combined)
echo "📦 Loading V1 users (4 CSV files)..."
load_csv "v1_users" "menuca_v1_users.csv" ";"
load_csv "v1_users" "menuca_v1_users_part1.csv" ";"
load_csv "v1_users" "menuca_v1_users_part2.csv" ";"
load_csv "v1_users" "menuca_v1_users_part3.csv" ";"

# Update source file tracking
echo "🏷️  Tagging source files..."
psql "$CONN" -q <<'SQL'
UPDATE staging.v1_users SET _source_file = 'menuca_v1_users.csv' WHERE _source_file IS NULL AND id <= 14292;
UPDATE staging.v1_users SET _source_file = 'menuca_v1_users_part1.csv' WHERE _source_file IS NULL AND id <= 142665;
UPDATE staging.v1_users SET _source_file = 'menuca_v1_users_part2.csv' WHERE _source_file IS NULL AND id <= 285330;
UPDATE staging.v1_users SET _source_file = 'menuca_v1_users_part3.csv' WHERE _source_file IS NULL;
SQL
echo "   ✅ Source files tagged"
echo ""

# V1 Callcenter
load_csv "v1_callcenter_users" "menuca_v1_callcenter_users.csv" ";"

# ================================================================
# STEP 2: Filter V1 Active Users
# ================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 2: Filtering V1 Users (Active Only)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "🔍 Applying filter: lastLogin > '2020-01-01'..."

psql "$CONN" -q <<'SQL'
-- Backup excluded users
CREATE TABLE IF NOT EXISTS staging.v1_users_excluded AS
SELECT *, 'inactive_old_login'::TEXT as exclusion_reason, NOW() as excluded_at
FROM staging.v1_users
WHERE lastLogin IS NULL OR lastLogin <= '2020-01-01';

-- Delete inactive users
DELETE FROM staging.v1_users WHERE lastLogin IS NULL OR lastLogin <= '2020-01-01';
SQL

active=$(psql "$CONN" -t -A -c "SELECT COUNT(*) FROM staging.v1_users;")
excluded=$(psql "$CONN" -t -A -c "SELECT COUNT(*) FROM staging.v1_users_excluded;")

echo "   ✅ Active users kept: $active"
echo "   📦 Excluded users (backed up): $excluded"
echo ""

# ================================================================
# STEP 3: Load V2 Tables (delimiter: comma)
# ================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 3: Loading V2 Tables"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

load_csv "v2_site_users" "menuca_v2_site_users.csv" ","
load_csv "v2_admin_users" "menuca_v2_admin_users.csv" ","
load_csv "v2_admin_users_restaurants" "menuca_v2_admin_users_restaurants.csv" ","
load_csv "v2_site_users_delivery_addresses" "menuca_v2_site_users_delivery_addresses.csv" ","
load_csv "v2_site_users_favorite_restaurants" "menuca_v2_site_users_favorite_restaurants.csv" ","
load_csv "v2_site_users_fb" "menuca_v2_site_users_fb.csv" ","

# ================================================================
# STEP 4: Load & Filter V2 Tokens
# ================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 4: Loading & Filtering V2 Tokens"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Reset codes
load_csv "v2_reset_codes" "menuca_v2_reset_codes.csv" ","

echo "🔍 Filtering reset codes (active only: expires_at > NOW())..."
psql "$CONN" -q <<'SQL'
CREATE TABLE IF NOT EXISTS staging.v2_reset_codes_excluded AS
SELECT *, 'expired_token'::TEXT as exclusion_reason, NOW() as excluded_at
FROM staging.v2_reset_codes
WHERE expires_at IS NULL OR expires_at <= NOW();

DELETE FROM staging.v2_reset_codes WHERE expires_at IS NULL OR expires_at <= NOW();
SQL

active_reset=$(psql "$CONN" -t -A -c "SELECT COUNT(*) FROM staging.v2_reset_codes;")
expired_reset=$(psql "$CONN" -t -A -c "SELECT COUNT(*) FROM staging.v2_reset_codes_excluded;")
echo "   ✅ Active tokens: $active_reset"
echo "   📦 Excluded tokens: $expired_reset"
echo ""

# Autologin tokens
load_csv "v2_site_users_autologins" "menuca_v2_site_users_autologins.csv" ","

echo "🔍 Filtering autologin tokens (active only: expire > NOW())..."
psql "$CONN" -q <<'SQL'
CREATE TABLE IF NOT EXISTS staging.v2_site_users_autologins_excluded AS
SELECT *, 'expired_token'::TEXT as exclusion_reason, NOW() as excluded_at
FROM staging.v2_site_users_autologins
WHERE expire IS NULL OR expire <= NOW();

DELETE FROM staging.v2_site_users_autologins WHERE expire IS NULL OR expire <= NOW();
SQL

active_auto=$(psql "$CONN" -t -A -c "SELECT COUNT(*) FROM staging.v2_site_users_autologins;")
expired_auto=$(psql "$CONN" -t -A -c "SELECT COUNT(*) FROM staging.v2_site_users_autologins_excluded;")
echo "   ✅ Active autologin tokens: $active_auto"
echo "   📦 Excluded tokens: $expired_auto"
echo ""

# ================================================================
# FINAL SUMMARY
# ================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ CSV LOADING COMPLETE!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

psql "$CONN" <<'SQL'
SELECT 
    table_name,
    TO_CHAR(row_count, '999,999') as rows,
    notes
FROM (
    SELECT 'V1 users (active)' as table_name, COUNT(*) as row_count, 1 as sort_order,
           'FILTERED: lastLogin > 2020-01-01' as notes
    FROM staging.v1_users
    UNION ALL
    SELECT 'V1 users (excluded)', COUNT(*), 2, 'Backup of inactive users'
    FROM staging.v1_users_excluded
    UNION ALL
    SELECT 'V1 callcenter_users', COUNT(*), 3, 'All staff accounts'
    FROM staging.v1_callcenter_users
    UNION ALL
    SELECT 'V2 site_users', COUNT(*), 4, 'All V2 users (active)'
    FROM staging.v2_site_users
    UNION ALL
    SELECT 'V2 admin_users', COUNT(*), 5, 'Platform admins'
    FROM staging.v2_admin_users
    UNION ALL
    SELECT 'V2 admin-restaurant junction', COUNT(*), 6, 'Admin access rights'
    FROM staging.v2_admin_users_restaurants
    UNION ALL
    SELECT 'V2 delivery_addresses', COUNT(*), 7, 'User saved addresses'
    FROM staging.v2_site_users_delivery_addresses
    UNION ALL
    SELECT 'V2 reset_codes (active)', COUNT(*), 8, 'FILTERED: expires_at > NOW()'
    FROM staging.v2_reset_codes
    UNION ALL
    SELECT 'V2 reset_codes (excluded)', COUNT(*), 9, 'Backup of expired tokens'
    FROM staging.v2_reset_codes_excluded
    UNION ALL
    SELECT 'V2 autologins (active)', COUNT(*), 10, 'FILTERED: expire > NOW()'
    FROM staging.v2_site_users_autologins
    UNION ALL
    SELECT 'V2 autologins (excluded)', COUNT(*), 11, 'Backup of expired tokens'
    FROM staging.v2_site_users_autologins_excluded
    UNION ALL
    SELECT 'V2 favorite_restaurants', COUNT(*), 12, 'User favorites'
    FROM staging.v2_site_users_favorite_restaurants
    UNION ALL
    SELECT 'V2 fb_profiles', COUNT(*), 13, 'Facebook OAuth'
    FROM staging.v2_site_users_fb
) data
ORDER BY sort_order;
SQL

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Next step: Run data quality assessment"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Run: psql \"\$CONN\" -f Database/Users_&_Access/03_data_quality_assessment.sql"
echo ""
