#!/bin/bash
# Fix malformed CSV data from MySQL export
# Issue: Fields like "N," should be "N" or NULL

set -e

CSV_DIR="/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Users_&_Access/CSV"
BACKUP_DIR="$CSV_DIR/broken_originals"

echo "================================================================"
echo "Fixing Malformed CSV Data"
echo "================================================================"
echo ""

mkdir -p "$BACKUP_DIR"

# Fix V1 users part files
for part in part1 part2 part3; do
    file="menuca_v1_users_${part}.csv"
    filepath="$CSV_DIR/$file"
    
    if [ ! -f "$filepath" ]; then
        echo "⏭️  Skipping $file (not found)"
        continue
    fi
    
    echo "🔧 Fixing: $file"
    
    # Backup
    cp "$filepath" "$BACKUP_DIR/$file"
    
    # Fix the malformed data:
    # Replace "N," with "" (empty/NULL)
    # Replace ,"", with ,, (double empty quotes to single)
    sed -E \
        -e 's/"N,""/""/g' \
        -e 's/,""",/,""/g' \
        -e 's/,"N,/,/g' \
        "$BACKUP_DIR/$file" > "$filepath"
    
    echo "   ✅ Fixed (backup: $BACKUP_DIR/$file)"
    
    # Show sample of fixed data
    echo "   Sample after fix:"
    head -2 "$filepath" | tail -1 | cut -c1-100
    echo ""
done

echo "================================================================"
echo "✅ CSV Files Fixed!"
echo "================================================================"
echo ""
echo "You can now run: python3 load_all_data.py <password>"
echo ""
