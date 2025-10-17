#!/bin/bash
# Backup Supabase Database for Replit Dev Environment
# Run this script to create a full backup of your menuca_v3 database

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🗄️  Backing up Supabase Database${NC}"
echo ""

# Configuration
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="./Database/Backups"
BACKUP_FILE="menuca_v3_backup_${TIMESTAMP}.sql"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Prompt for Supabase connection details
echo -e "${BLUE}Please enter your Supabase connection details:${NC}"
read -p "Database Host (e.g., db.xxxxx.supabase.co): " DB_HOST
read -p "Database Name (default: postgres): " DB_NAME
DB_NAME=${DB_NAME:-postgres}
read -p "Database User (default: postgres): " DB_USER
DB_USER=${DB_USER:-postgres}
read -sp "Database Password: " DB_PASSWORD
echo ""

# Export full schema + data
echo ""
echo -e "${GREEN}📦 Exporting schema and data...${NC}"

PGPASSWORD=$DB_PASSWORD pg_dump \
  -h "$DB_HOST" \
  -U "$DB_USER" \
  -d "$DB_NAME" \
  --schema=menuca_v3 \
  --no-owner \
  --no-acl \
  --clean \
  --if-exists \
  --file="$BACKUP_DIR/$BACKUP_FILE"

if [ $? -eq 0 ]; then
  echo -e "${GREEN}✅ Backup created successfully!${NC}"
  echo ""
  echo -e "${BLUE}📁 Backup location:${NC} $BACKUP_DIR/$BACKUP_FILE"
  echo ""
  
  # Get file size
  FILE_SIZE=$(du -h "$BACKUP_DIR/$BACKUP_FILE" | cut -f1)
  echo -e "${BLUE}📊 Backup size:${NC} $FILE_SIZE"
  echo ""
  
  # Create a README for the backup
  cat > "$BACKUP_DIR/README.md" << EOF
# Supabase Backup - $(date)

## Backup Details
- **File:** $BACKUP_FILE
- **Schema:** menuca_v3
- **Size:** $FILE_SIZE
- **Created:** $(date)

## How to Restore

### To New Supabase Project:
\`\`\`bash
PGPASSWORD=your_new_password psql \\
  -h db.xxxxx.supabase.co \\
  -U postgres \\
  -d postgres \\
  -f $BACKUP_FILE
\`\`\`

### To Replit Postgres:
1. Upload this file to Replit
2. Run: \`psql -U your_user -d your_db -f $BACKUP_FILE\`

## What's Included
- ✅ All 74 tables (menuca_v3 schema)
- ✅ All data (restaurants, users, dishes, orders, etc.)
- ✅ All indexes and constraints
- ✅ All triggers and functions
- ✅ All ENUMs and custom types

## What's NOT Included
- ❌ RLS policies (need to be recreated)
- ❌ Extensions (need to be enabled: postgis, pg_cron)
- ❌ User permissions (pg_dump uses --no-owner)
EOF

  echo -e "${GREEN}📝 README created: $BACKUP_DIR/README.md${NC}"
  echo ""
  echo -e "${BLUE}🎯 Next Steps:${NC}"
  echo "1. Create a new Supabase project for development"
  echo "2. Run the restore command (see README.md)"
  echo "3. Connect Replit to the new dev database"
  echo ""
  
else
  echo -e "${RED}❌ Backup failed!${NC}"
  echo "Please check your connection details and try again."
  exit 1
fi

