#!/bin/bash
# Restore Supabase Database to New Dev Environment
# Run this script to restore your backup to a new Supabase project

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔄 Restoring Supabase Database${NC}"
echo ""

# List available backups
BACKUP_DIR="./Database/Backups"
echo -e "${BLUE}📁 Available backups:${NC}"
ls -lh "$BACKUP_DIR"/*.sql 2>/dev/null | awk '{print $9, "(" $5 ")"}'
echo ""

# Prompt for backup file
read -p "Enter backup filename (or full path): " BACKUP_FILE

# Check if file exists
if [ ! -f "$BACKUP_FILE" ] && [ -f "$BACKUP_DIR/$BACKUP_FILE" ]; then
  BACKUP_FILE="$BACKUP_DIR/$BACKUP_FILE"
fi

if [ ! -f "$BACKUP_FILE" ]; then
  echo -e "${RED}❌ Backup file not found!${NC}"
  exit 1
fi

echo ""
echo -e "${YELLOW}⚠️  WARNING: This will overwrite the target database!${NC}"
echo -e "${YELLOW}Make sure you're restoring to a NEW/EMPTY Supabase project!${NC}"
echo ""
read -p "Are you sure you want to continue? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
  echo "Restore cancelled."
  exit 0
fi

# Prompt for NEW Supabase connection details
echo ""
echo -e "${BLUE}Please enter your NEW Supabase connection details:${NC}"
read -p "Database Host (e.g., db.xxxxx.supabase.co): " DB_HOST
read -p "Database Name (default: postgres): " DB_NAME
DB_NAME=${DB_NAME:-postgres}
read -p "Database User (default: postgres): " DB_USER
DB_USER=${DB_USER:-postgres}
read -sp "Database Password: " DB_PASSWORD
echo ""

# Enable required extensions first
echo ""
echo -e "${GREEN}🔌 Enabling required extensions...${NC}"
PGPASSWORD=$DB_PASSWORD psql \
  -h "$DB_HOST" \
  -U "$DB_USER" \
  -d "$DB_NAME" \
  -c "CREATE EXTENSION IF NOT EXISTS postgis;" \
  -c "CREATE EXTENSION IF NOT EXISTS pg_cron;"

# Restore the backup
echo ""
echo -e "${GREEN}📥 Restoring backup...${NC}"
echo "This may take a few minutes..."
echo ""

PGPASSWORD=$DB_PASSWORD psql \
  -h "$DB_HOST" \
  -U "$DB_USER" \
  -d "$DB_NAME" \
  -f "$BACKUP_FILE"

if [ $? -eq 0 ]; then
  echo ""
  echo -e "${GREEN}✅ Restore completed successfully!${NC}"
  echo ""
  
  # Verify the restore
  echo -e "${BLUE}🔍 Verifying restore...${NC}"
  
  TABLE_COUNT=$(PGPASSWORD=$DB_PASSWORD psql \
    -h "$DB_HOST" \
    -U "$DB_USER" \
    -d "$DB_NAME" \
    -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'menuca_v3';")
  
  echo -e "${GREEN}✅ Tables restored: $TABLE_COUNT${NC}"
  
  RESTAURANT_COUNT=$(PGPASSWORD=$DB_PASSWORD psql \
    -h "$DB_HOST" \
    -U "$DB_USER" \
    -d "$DB_NAME" \
    -t -c "SELECT COUNT(*) FROM menuca_v3.restaurants;")
  
  echo -e "${GREEN}✅ Restaurants: $RESTAURANT_COUNT${NC}"
  
  echo ""
  echo -e "${BLUE}🎯 Next Steps:${NC}"
  echo "1. Update your .env file with new Supabase credentials"
  echo "2. Test the connection: psql -h $DB_HOST -U $DB_USER -d $DB_NAME"
  echo "3. Connect Replit to this dev database"
  echo "4. Build your frontend safely!"
  echo ""
  
else
  echo ""
  echo -e "${RED}❌ Restore failed!${NC}"
  echo "Please check your connection details and try again."
  exit 1
fi

