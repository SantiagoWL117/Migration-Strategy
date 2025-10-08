#!/usr/bin/env python3
"""
Load extracted staging SQL files into Supabase
Uses subprocess to call supabase CLI or psql
"""

import subprocess
from pathlib import Path
import os

# Directories
STAGING_INSERTS_DIR = Path(__file__).parent / "staging_inserts"

# Files to load in order
LOAD_FILES = [
    "staging_v1_deals_load.sql",
    "staging_v1_coupons_load.sql",
    "staging_v2_restaurants_deals_load.sql",
    "staging_v2_restaurants_deals_splits_load.sql",
    "staging_v2_restaurants_tags_load.sql",
]


def load_sql_file_via_supabase_mcp(sql_file: Path):
    """
    Load SQL file using Supabase MCP via command line
    Note: This requires supabase CLI or direct postgres connection
    """
    print(f"\n📥 Loading {sql_file.name}...")
    
    # Read the SQL
    with open(sql_file, 'r', encoding='utf-8') as f:
        sql = f.read()
    
    # For now, just display what would be loaded
    # In practice, this would use: supabase db execute --file {sql_file}
    # Or: psql -h <host> -U <user> -d <database> -f {sql_file}
    
    lines = sql.count('\n') + 1
    size = len(sql)
    
    print(f"   📄 File: {lines} lines, {size} bytes")
    print(f"   ✅ Ready to load (manual execution required)")
    
    # Extract verification query (last line before blank)
    verification = [line for line in sql.split('\n') if line.startswith('SELECT COUNT')]
    if verification:
        print(f"   🔍 Verification: {verification[0]}")
    
    return sql


def main():
    """Load all staging files"""
    print("🎯 Marketing & Promotions - Load Staging Data")
    print("="*70)
    
    all_sql = []
    
    for filename in LOAD_FILES:
        filepath = STAGING_INSERTS_DIR / filename
        
        if not filepath.exists():
            print(f"\n⚠️  {filename} not found, skipping...")
            continue
        
        sql = load_sql_file_via_supabase_mcp(filepath)
        all_sql.append((filename, sql))
    
    print(f"\n{'='*70}")
    print(f"📊 Summary: {len(all_sql)} files processed")
    print(f"{'='*70}")
    
    # Write combined SQL file for manual execution
    combined_file = Path(__file__).parent / "02_load_all_staging_data.sql"
    with open(combined_file, 'w', encoding='utf-8') as f:
        f.write("-- MARKETING & PROMOTIONS - LOAD ALL STAGING DATA\\n")
        f.write("-- Generated from extracted MySQL dumps\\n")
        f.write("-- Execute this file via Supabase MCP or psql\\n\\n")
        
        for filename, sql in all_sql:
            f.write(f"-- ============================================================================\\n")
            f.write(f"-- {filename}\\n")
            f.write(f"-- ============================================================================\\n\\n")
            f.write(sql)
            f.write("\\n\\n")
    
    print(f"\n💾 Combined SQL written to: {combined_file.name}")
    print(f"✅ Execute this file via Supabase MCP to load all data!")


if __name__ == "__main__":
    main()
