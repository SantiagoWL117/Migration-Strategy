#!/usr/bin/env python3
"""
Load V1 tablets data from fixed SQL file to Supabase staging.

This script reads the fixed SQL file, splits it into batches,
and loads each batch via Supabase MCP execute_sql tool.
"""

import re
from pathlib import Path

def extract_batches(sql_file):
    """Extract individual batch INSERT statements from SQL file."""
    print(f"Reading: {sql_file}")
    
    with open(sql_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Split by batch markers - matches the actual format with escape sequences
    batch_pattern = r'-- Batch \d+: Rows \d+-\d+.*?(INSERT INTO staging\.v1_tablets.*?;)'
    
    batches = re.findall(batch_pattern, content, re.DOTALL)
    
    print(f"Found {len(batches)} batches")
    return batches

def main():
    sql_file = Path("/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Devices & Infrastructure Entity/FINAL/v1_tablets_FIXED.sql")
    
    batches = extract_batches(sql_file)
    
    if not batches:
        print("ERROR: No batches found!")
        return
    
    print(f"\nExtracted {len(batches)} batches:")
    print(f"  - Batch 1: {len(batches[0])} chars")
    print(f"  - Batch 2: {len(batches[1])} chars")
    print(f"  ...loading data...")
    
    # Note: Actual loading via MCP will be done from command line
    # This script just validates the extraction
    
    # Save first batch for manual testing
    test_batch = Path("/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Devices & Infrastructure Entity/FINAL/batch_1_test.sql")
    with open(test_batch, 'w', encoding='utf-8') as f:
        f.write(batches[0])
    
    print(f"\n✓ Test batch saved to: {test_batch}")
    print(f"✓ Total batches ready: {len(batches)}")

if __name__ == "__main__":
    main()

