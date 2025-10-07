#!/bin/bash
# Load V1 Users from SQL Dump
set -e

PROJECT_HOST="db.nthpbtdjhhnwfxqsxbvy.supabase.co"
DATABASE="postgres"
USER="postgres"
SQL_FILE="/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Users_&_Access/dumps/menuca_v1_users.sql"

if [ -z "$SUPABASE_PASSWORD" ]; then
    echo "❌ Error: SUPABASE_PASSWORD not set"
    exit 1
fi

export PGPASSWORD="$SUPABASE_PASSWORD"

echo "================================================================"
echo "Loading V1 Users from SQL Dump (ALL USERS)"
echo "================================================================"
echo ""

echo "Step 1: Clearing existing V1 users..."
/opt/homebrew/opt/libpq/bin/psql -h "$PROJECT_HOST" -U "$USER" -d "$DATABASE" -c "TRUNCATE staging.v1_users CASCADE;"
echo "   ✅ Cleared"
echo ""

echo "Step 2: Extracting INSERT statements..."
TEMP_SQL="/tmp/v1_users_converted.sql"

# Extract INSERT statements, convert to PostgreSQL
grep "^INSERT INTO" "$SQL_FILE" | \
    sed "s/INSERT INTO \`users\`/INSERT INTO staging.v1_users/" | \
    sed "s/\`//g" \
    > "$TEMP_SQL"

echo "   ✅ Extracted $(wc -l < "$TEMP_SQL") INSERT statements"
echo ""

echo "Step 3: Loading data into PostgreSQL..."
echo "   (This may take a few minutes for 400k+ rows...)"

/opt/homebrew/opt/libpq/bin/psql -h "$PROJECT_HOST" -U "$USER" -d "$DATABASE" \
    -v ON_ERROR_STOP=0 \
    -f "$TEMP_SQL" 2>&1 | \
    grep -E "(ERROR|INSERT)" | head -20 || true

echo ""
echo "Step 4: Verifying row count..."
COUNT=$(/opt/homebrew/opt/libpq/bin/psql -h "$PROJECT_HOST" -U "$USER" -d "$DATABASE" -t -A -c "SELECT COUNT(*) FROM staging.v1_users;")
echo "   ✅ Total V1 users loaded: $COUNT"
echo ""

echo "Step 5: Quick stats on lastLogin (to verify active/inactive)..."
/opt/homebrew/opt/libpq/bin/psql -h "$PROJECT_HOST" -U "$USER" -d "$DATABASE" <<SQL
SELECT 
    COUNT(*) as total_users,
    COUNT(*) FILTER (WHERE lastLogin > '2020-01-01') as active_recent,
    COUNT(*) FILTER (WHERE lastLogin <= '2020-01-01' OR lastLogin IS NULL) as inactive_old,
    ROUND(100.0 * COUNT(*) FILTER (WHERE lastLogin > '2020-01-01') / COUNT(*), 2) as pct_active
FROM staging.v1_users;
SQL

echo ""
echo "================================================================"
echo "✅ V1 USERS LOAD COMPLETE!"
echo "================================================================"

rm -f "$TEMP_SQL"
