#!/bin/bash
# Load all staging INSERT files into Supabase

# Note: This would normally use psql, but we're using Supabase MCP instead
# This script serves as documentation of what needs to be loaded

STAGING_DIR="/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Marketing & Promotions/staging_inserts"

echo "📦 Loading Marketing & Promotions data into staging..."
echo "="

# Files to load (in order)
files=(
  "staging_v1_deals_load.sql"
  "staging_v1_coupons_load.sql"
  "staging_v2_restaurants_deals_load.sql"
  "staging_v2_restaurants_deals_splits_load.sql"
  "staging_v2_restaurants_tags_load.sql"
)

for file in "${files[@]}"; do
  filepath="$STAGING_DIR/$file"
  if [ -f "$filepath" ]; then
    echo "✅ Found: $file"
  else
    echo "❌ Missing: $file"
  fi
done

echo ""
echo "💡 Use Supabase MCP to execute these SQL files"
