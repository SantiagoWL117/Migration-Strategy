#!/bin/bash

# Menu & Catalog Bulk Data Loader
# Loads all converted SQL files into Supabase staging tables

# Supabase Connection Details
PROJECT_REF="nthpbtdjhhnwfxqsxbvy"
DB_HOST="aws-0-us-east-1.pooler.supabase.com"
DB_PORT="6543"
DB_NAME="postgres"
DB_USER="postgres.$PROJECT_REF"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "🚀 Menu & Catalog Bulk Data Loader"
echo "===================================="
echo ""

# Check if password is provided
if [ -z "$SUPABASE_DB_PASSWORD" ]; then
    echo "❌ Error: SUPABASE_DB_PASSWORD environment variable not set"
    echo ""
    echo "📝 To get your database password:"
    echo "   1. Go to: https://supabase.com/dashboard/project/$PROJECT_REF/settings/database"
    echo "   2. Click 'Reset database password' or use existing password"
    echo "   3. Export it: export SUPABASE_DB_PASSWORD='your-password-here'"
    echo "   4. Run this script again"
    echo ""
    exit 1
fi

# Connection string
export PGPASSWORD="$SUPABASE_DB_PASSWORD"
DB_URL="postgresql://$DB_USER:$SUPABASE_DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_NAME"

# Test connection
echo "🔌 Testing database connection..."
psql "$DB_URL" -c "SELECT 1;" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Connection failed!${NC}"
    echo "Please check your password and try again."
    exit 1
fi
echo -e "${GREEN}✅ Connected to Supabase!${NC}"
echo ""

# Load V1 files
echo -e "${BLUE}📦 Loading V1 Tables...${NC}"
echo "------------------------------------------------------------"

V1_FILES=(
    "menuca_v1_courses_postgres.sql"
    "menuca_v1_menu_postgres.sql"
    "menuca_v1_menuothers_postgres.sql"
    "menuca_v1_combo_groups_postgres.sql"
    "menuca_v1_combos_postgres.sql"
    "menuca_v1_ingredient_groups_postgres.sql"
    "menuca_v1_ingredients_postgres.sql"
)

for file in "${V1_FILES[@]}"; do
    if [ -f "converted/$file" ]; then
        echo -n "  Loading $file... "
        psql "$DB_URL" -f "converted/$file" > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅${NC}"
        else
            echo -e "${RED}❌${NC}"
        fi
    else
        echo -e "  ${RED}⚠️  $file not found${NC}"
    fi
done

echo ""

# Load V2 files
echo -e "${BLUE}📦 Loading V2 Tables...${NC}"
echo "------------------------------------------------------------"

V2_FILES=(
    "menuca_v2_restaurants_courses_postgres.sql"
    "menuca_v2_restaurants_dishes_postgres.sql"
    "menuca_v2_restaurants_dishes_customization_postgres.sql"
    "menuca_v2_restaurants_combo_groups_postgres.sql"
    "menuca_v2_restaurants_combo_groups_items_postgres.sql"
    "menuca_v2_restaurants_ingredient_groups_postgres.sql"
    "menuca_v2_restaurants_ingredient_groups_items_postgres.sql"
    "menuca_v2_restaurants_ingredients_postgres.sql"
    "menuca_v2_global_courses_postgres.sql"
    "menuca_v2_global_ingredients_postgres.sql"
)

for file in "${V2_FILES[@]}"; do
    if [ -f "converted/$file" ]; then
        echo -n "  Loading $file... "
        psql "$DB_URL" -f "converted/$file" > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅${NC}"
        else
            echo -e "${RED}❌${NC}"
        fi
    else
        echo -e "  ${RED}⚠️  $file not found${NC}"
    fi
done

echo ""
echo "============================================================"
echo -e "${GREEN}✅ Bulk load complete!${NC}"
echo ""
echo "📊 Verify data loaded with:"
echo "   psql \"$DB_URL\" -c \"SELECT 'v1_courses' as table, count(*) from staging.v1_courses;\""
echo ""

