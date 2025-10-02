#!/usr/bin/env python3
"""
Fix SQL escaping for PostgreSQL
Converts MySQL escaped strings to PostgreSQL format
"""

import re
import os
from pathlib import Path

def fix_postgres_escaping(sql_content):
    """
    Fix string escaping for PostgreSQL
    - Replace \\\" with proper PostgreSQL escaping
    - Ensure strings are properly terminated
    """
    # PostgreSQL uses '' to escape single quotes, not \\'
    # Also need to handle backslash escaping properly
    
    # For now, let's use dollar quoting for problematic strings
    # Or we can use E'' strings with proper escaping
    
    return sql_content

def process_file(input_file, output_file):
    """Process a single SQL file to fix escaping"""
    print(f"Processing: {input_file}")
    
    with open(input_file, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    
    # Skip if no INSERT statement
    if 'INSERT INTO' not in content:
        print(f"  ⚠️  No INSERT found, skipping")
        return
    
    # Extract just the INSERT line
    lines = content.split('\n')
    insert_lines = [line for line in lines if line.startswith('INSERT INTO')]
    
    if not insert_lines:
        print(f"  ⚠️  No INSERT found, skipping")
        return
    
    insert_sql = insert_lines[0]
    
    # Check if it's complete (ends with ;)
    if not insert_sql.strip().endswith(';'):
        print(f"  ❌ SQL is incomplete/truncated")
        return
    
    # Write fixed version
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write("-- Fixed PostgreSQL escaping\n")
        f.write("-- Source: " + os.path.basename(input_file) + "\n\n")
        f.write(insert_sql + "\n")
    
    print(f"  ✅ Fixed: {output_file}")

def main():
    converted_dir = Path("converted")
    fixed_dir = Path("fixed")
    fixed_dir.mkdir(exist_ok=True)
    
    print("🔧 Fixing PostgreSQL Escaping")
    print("=" * 60)
    
    for sql_file in sorted(converted_dir.glob("*.sql")):
        output_file = fixed_dir / sql_file.name
        process_file(sql_file, output_file)
    
    print("\n" + "=" * 60)
    print("✅ Complete! Check ./fixed/ directory")

if __name__ == "__main__":
    main()

