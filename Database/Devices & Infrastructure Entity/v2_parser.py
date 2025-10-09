#!/usr/bin/env python3
"""
V2 tablets parser - adapted from ultimate_parser.py
V2 has 13 fields (missing 'v2' field compared to V1)
"""

import re
from pathlib import Path

def hex_encode_binary_content(binary_content):
    """Convert MySQL _binary to PostgreSQL E'\\xHEX'"""
    hex_string = binary_content.encode('latin1').hex()
    return f"E'\\\\x{hex_string}'"

def parse_v2_tablets(dump_file, output_dir, batch_size=50):
    print(f"Reading V2 dump: {dump_file}")
    with open(dump_file, 'r', encoding='latin1') as f:
        lines = f.readlines()

    # Line 50 contains the INSERT statement (one line before V1's line 51)
    line50 = lines[49]
    print(f"Line 50 length: {len(line50):,} chars")

    # Extract VALUES part
    start_idx = line50.find('VALUES ') + 7
    end_idx = line50.rfind(');')
    raw_values = line50[start_idx:end_idx+1]
    
    print(f"VALUES content: {len(raw_values):,} chars")

    # Split on ),( pattern
    raw_row_strings = raw_values[1:-1].split('),(')
    print(f"Initial split found {len(raw_row_strings)} rows")

    rows = []
    for row_str in raw_row_strings:
        # Convert _binary fields
        converted = re.sub(
            r"_binary '([^']*)'",
            lambda m: hex_encode_binary_content(m.group(1)),
            row_str
        )
        rows.append(f"({converted})")

    if len(rows) != 87:
        print(f"WARNING: Expected 87 rows, got {len(rows)}")
        return False

    print(f"✅ Successfully parsed {len(rows)} rows")

    # Generate batches
    output_dir.mkdir(parents=True, exist_ok=True)
    base_insert = """INSERT INTO staging.v2_tablets
(id, designator, key, restaurant, printing, config_edit, last_boot, last_check,
 fw_ver, sw_ver, desynced, created_at, modified_at)
VALUES
"""
    
    num_batches = (len(rows) + batch_size - 1) // batch_size
    
    for i in range(num_batches):
        start_idx = i * batch_size
        end_idx = min((i + 1) * batch_size, len(rows))
        batch_rows = rows[start_idx:end_idx]

        batch_content = f"""-- V2 Tablets Batch {i+1}: Rows {start_idx+1}-{end_idx}
{base_insert}"""
        batch_content += ",\n".join(batch_rows) + ";\n"

        batch_file = output_dir / f"v2_batch_{i+1:02d}.sql"
        with open(batch_file, 'w', encoding='utf-8') as f:
            f.write(batch_content)
        print(f"  ✓ Batch {i+1}: {batch_file.name} ({len(batch_rows)} rows)")

    print(f"\n✅ Generated {num_batches} V2 batches")
    return True

if __name__ == "__main__":
    dump_file = Path("/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Devices & Infrastructure Entity/menuca_v2_tablets.sql")
    output_dir = Path("/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Devices & Infrastructure Entity/v2_batches")
    
    if parse_v2_tablets(dump_file, output_dir):
        print("\n✅ V2 PARSING COMPLETE - Ready to load!")
    else:
        print("\n❌ V2 PARSING FAILED")
