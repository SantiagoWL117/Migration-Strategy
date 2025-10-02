#!/usr/bin/env python3
"""
Load Menu & Catalog data via Supabase REST API
Uses the access token we already have configured
"""

import requests
import json
import os
import glob

PROJECT_REF = "nthpbtdjhhnwfxqsxbvy"
ACCESS_TOKEN = "sbp_dffd84abb668062f7b8aa549d7a923a1b3b4fe30"
API_URL = f"https://{PROJECT_REF}.supabase.co/rest/v1"

headers = {
    "apikey": ACCESS_TOKEN,
    "Authorization": f"Bearer {ACCESS_TOKEN}",
    "Content-Type": "application/json",
    "Prefer": "return=minimal"
}

def parse_insert_to_json(sql_content):
    """
    Parse INSERT statement and convert to JSON array
    Very basic parser - might need adjustments
    """
    # Extract table name
    table_match = re.search(r'INSERT INTO (\w+\.\w+)', sql_content)
    if not table_match:
        return None, None
    
    table_name = table_match.group(1).split('.')[-1]  # Get table name without schema
    
    # This is complex - we'll use a different approach
    # For now, let's just note files are ready
    return table_name, None

# List converted files
converted_dir = "converted"
files = glob.glob(f"{converted_dir}/*.sql")

print("🚀 Menu & Catalog API Loader")
print("=" * 60)
print(f"\nFound {len(files)} SQL files to process")
print("\n⚠️  Note: REST API method has limitations for bulk inserts")
print("Recommended: Get correct DB password and use psql method\n")
print("=" * 60)

for file in sorted(files):
    print(f"📄 {os.path.basename(file)}")

print("\n💡 Alternative: I can load data via Supabase SQL Editor")
print("   Copy contents of converted/*.sql files manually")

