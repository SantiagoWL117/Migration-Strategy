#!/usr/bin/env python3
"""
Split massive INSERT statements into smaller batches
Each batch will have max 1000 rows for safe loading
"""

import os
import re

# Source directory
source_dir = "/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu & Catalog Entity/final_pg"

# Output directory
output_dir = "/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu & Catalog Entity/split_pg"
os.makedirs(output_dir, exist_ok=True)

def split_insert_statement(insert_line, table_name, batch_size=1000):
    """Split a massive INSERT INTO ... VALUES (...),(...),(...); into smaller batches"""
    
    # Extract the VALUES part
    match = re.match(r"INSERT INTO ([^\s]+) VALUES (.+);", insert_line)
    if not match:
        return [insert_line]  # Return as-is if no match
    
    table = match.group(1)
    values_part = match.group(2)
    
    # Split by ),( pattern to separate individual row values
    # This regex splits on ),( but keeps the parentheses with their respective values
    rows = re.split(r'\),\(', values_part)
    
    # Fix the first and last row (they're missing ( or ) respectively)
    if len(rows) > 0:
        rows[0] = rows[0].lstrip('(')
        rows[-1] = rows[-1].rstrip(')')
    
    # Create batches
    batches = []
    for i in range(0, len(rows), batch_size):
        batch = rows[i:i+batch_size]
        # Reconstruct INSERT statement for this batch
        batch_values = '),('.join(batch)
        batch_insert = f"INSERT INTO {table} VALUES ({batch_values});"
        batches.append(batch_insert)
    
    return batches

def process_file(filename):
    """Process a SQL file and split large INSERTs"""
    source_path = os.path.join(source_dir, filename)
    
    # Create output filename
    base_name = filename.replace('_final_pg.sql', '')
    
    print(f"Processing {filename}...")
    
    all_batches = []
    header_lines = []
    
    with open(source_path, 'r', encoding='utf-8', errors='ignore') as f:
        for line in f:
            if line.startswith('--') or line.strip() == '':
                header_lines.append(line)
            elif line.startswith('INSERT INTO'):
                # Split this INSERT
                batches = split_insert_statement(line.strip(), filename)
                all_batches.extend(batches)
    
    # Write batches to separate files
    if len(all_batches) <= 1:
        # Small file, just one batch
        output_path = os.path.join(output_dir, filename)
        with open(output_path, 'w', encoding='utf-8') as f:
            f.writelines(header_lines)
            for batch in all_batches:
                f.write(batch + '\n')
        print(f"  ✅ {filename} (1 file, {len(all_batches)} statements)")
    else:
        # Multiple batches, split into numbered files
        for idx, batch in enumerate(all_batches, 1):
            output_filename = f"{base_name}_batch_{idx:03d}.sql"
            output_path = os.path.join(output_dir, output_filename)
            with open(output_path, 'w', encoding='utf-8') as f:
                f.writelines(header_lines)
                f.write(batch + '\n')
        print(f"  ✅ {filename} → {len(all_batches)} batch files")

# Process all files
print("=" * 60)
print("Splitting Large INSERT Statements")
print("=" * 60)

for filename in sorted(os.listdir(source_dir)):
    if filename.endswith('_final_pg.sql'):
        try:
            process_file(filename)
        except Exception as e:
            print(f"  ⚠️  Error processing {filename}: {e}")

print("\n" + "=" * 60)
print("✅ Splitting complete!")
print(f"📁 Output directory: {output_dir}")
print("=" * 60)

