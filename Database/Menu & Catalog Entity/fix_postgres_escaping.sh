#!/bin/bash

# Fix PostgreSQL quote escaping in all batch files
# MySQL uses \' but PostgreSQL needs ''

BATCH_DIR="/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu & Catalog Entity/split_pg"

echo "=========================================="
echo "🔧 Fixing PostgreSQL Quote Escaping"
echo "=========================================="
echo ""

FIXED=0

for batch_file in "$BATCH_DIR"/*.sql; do
    if [ -f "$batch_file" ]; then
        filename=$(basename "$batch_file")
        
        # Replace \' with '' (PostgreSQL escaping)
        # Use -i '' for in-place editing on macOS
        sed -i '' "s/\\\\'/''''/g" "$batch_file"
        
        echo "✅ Fixed: $filename"
        ((FIXED++))
    fi
done

echo ""
echo "=========================================="
echo "✅ Fixed $FIXED files"
echo "=========================================="
echo ""
echo "Ready to reload! Run:"
echo "./load_missing_files.sh"

