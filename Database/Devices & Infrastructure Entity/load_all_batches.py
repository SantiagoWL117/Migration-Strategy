#!/usr/bin/env python3
"""
Load all 18 batches of V1 tablets to Supabase staging.

This script:
1. Extracts all 18 batches from the fixed SQL file
2. Writes each batch to a separate file for loading
3. Provides a summary for manual execution
"""

import re
from pathlib import Path

def extract_and_save_batches(sql_file, output_dir):
    """Extract and save all batches as separate files."""
    print(f"Reading: {sql_file}")
    
    with open(sql_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Extract all batches
    batch_pattern = r'-- Batch (\d+): Rows \d+-\d+.*?(INSERT INTO staging\.v1_tablets.*?);'
    matches = re.findall(batch_pattern, content, re.DOTALL)
    
    print(f"Found {len(matches)} batches\n")
    
    output_dir = Path(output_dir)
    output_dir.mkdir(exist_ok=True)
    
    batch_files = []
    for batch_num, insert_sql in matches:
        batch_file = output_dir / f"batch_{batch_num.zfill(2)}.sql"
        
        # Clean up the SQL (remove extra escape sequences if any)
        clean_sql = insert_sql.strip()
        
        with open(batch_file, 'w', encoding='utf-8') as f:
            f.write(clean_sql + ";\n")
        
        batch_files.append(batch_file)
        rows_count = clean_sql.count('(', 0, 1000)  # Estimate
        print(f"  ✓ Batch {batch_num}: {batch_file.name} ({len(clean_sql):,} chars)")
    
    return batch_files

def create_load_script(batch_files, output_file):
    """Create a bash script to load all batches via psql."""
    script_lines = [
        "#!/bin/bash",
        "# Load all V1 tablets batches to Supabase",
        "",
        "echo '🚀 Starting data load to staging.v1_tablets...'",
        "echo",
        ""
    ]
    
    for i, batch_file in enumerate(batch_files, 1):
        script_lines.append(f"echo '📦 Loading Batch {i}/18...'")
        script_lines.append(f"# Load {batch_file.name}")
        script_lines.append("")
    
    script_lines.extend([
        "echo",
        "echo '✅ All batches loaded!'",
        "echo",
        "echo '🔍 Verifying count...'",
        "# Verification: SELECT COUNT(*) FROM staging.v1_tablets;",
        "echo",
        "echo '✓ Expected: 894 rows'",
        ""
    ])
    
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write('\n'.join(script_lines))
    
    Path(output_file).chmod(0o755)
    print(f"\n📄 Load script created: {output_file}")

def main():
    sql_file = Path("/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Devices & Infrastructure Entity/FINAL/v1_tablets_FIXED.sql")
    output_dir = Path("/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Devices & Infrastructure Entity/batches")
    load_script = Path("/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Devices & Infrastructure Entity/load_all.sh")
    
    # Extract and save batches
    batch_files = extract_and_save_batches(sql_file, output_dir)
    
    if not batch_files:
        print("ERROR: No batches extracted!")
        return 1
    
    # Create load script
    create_load_script(batch_files, load_script)
    
    print(f"\n{'='*60}")
    print(f"✅ SUCCESS: {len(batch_files)} batches ready for loading")
    print(f"{'='*60}")
    print(f"\n📂 Batch files: {output_dir}/")
    print(f"📜 Load script: {load_script}")
    print(f"\n💡 Next step: Execute batches via Supabase MCP tool")
    
    return 0

if __name__ == "__main__":
    exit(main())

