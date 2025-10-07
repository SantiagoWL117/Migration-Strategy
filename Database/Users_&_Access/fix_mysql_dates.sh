#!/bin/bash
# ================================================================
# Fix MySQL Date Issues in CSVs
# ================================================================
# MySQL exports can contain:
# - 0000-00-00 00:00:00 (invalid in PostgreSQL)
# - 0000-00-00 (invalid in PostgreSQL)
#
# This script replaces them with empty strings (which become NULL)
# ================================================================

set -e

CSV_DIR="/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Users_&_Access/CSV"
BACKUP_DIR="$CSV_DIR/originals"

echo "================================================================"
echo "Fixing MySQL Date Issues in CSVs..."
echo "================================================================"
echo ""

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Counter
fixed=0

# Process each CSV file
for file in "$CSV_DIR"/*.csv; do
    filename=$(basename "$file")
    
    # Skip if already backed up
    if [ -f "$BACKUP_DIR/$filename" ]; then
        echo "⏭️  Skipping $filename (already processed)"
        continue
    fi
    
    # Check if file contains problematic dates
    if grep -q "0000-00-00" "$file"; then
        echo "🔧 Fixing: $filename"
        
        # Backup original
        cp "$file" "$BACKUP_DIR/$filename"
        
        # Replace problematic dates with empty strings (works for both quoted and unquoted)
        # Handle: ;0000-00-00 00:00:00; and ;"0000-00-00 00:00:00";
        sed -E \
            -e 's/;"0000-00-00 00:00:00";/;"";/g' \
            -e 's/;0000-00-00 00:00:00;/;;/g' \
            -e 's/^0000-00-00 00:00:00;/;/g' \
            -e 's/;0000-00-00 00:00:00$/;/g' \
            -e 's/,"0000-00-00 00:00:00"/,""/g' \
            -e 's/,0000-00-00 00:00:00,/,,/g' \
            -e 's/^0000-00-00 00:00:00,/,/g' \
            -e 's/,0000-00-00 00:00:00$/,/g' \
            -e 's/;"0000-00-00";/;"";/g' \
            -e 's/;0000-00-00;/;;/g' \
            -e 's/^0000-00-00;/;/g' \
            -e 's/;0000-00-00$/;/g' \
            -e 's/,"0000-00-00"/,""/g' \
            -e 's/,0000-00-00,/,,/g' \
            -e 's/^0000-00-00,/,/g' \
            -e 's/,0000-00-00$/,/g' \
            "$BACKUP_DIR/$filename" > "$file"
        
        echo "   ✅ Fixed (backup: $BACKUP_DIR/$filename)"
        ((fixed++))
    else
        echo "✓ OK: $filename"
    fi
done

echo ""
echo "================================================================"
echo "✅ Processed all CSV files"
echo "================================================================"
echo "   Fixed: $fixed files"
echo "   Backups: $BACKUP_DIR/"
echo ""
echo "You can now run the CSV loader:"
echo "  ./Database/Users_&_Access/load_csvs_v2.sh"
echo ""
