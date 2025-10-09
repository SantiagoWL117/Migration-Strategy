#!/usr/bin/env python3
"""
ULTIMATE MySQL to PostgreSQL parser for tablets.

Strategy: Parse row by row by counting exactly 14 comma-separated fields.
Handle binary data properly by tracking field position.
"""

import re
from pathlib import Path

def parse_row(row_str):
    """
    Parse a single row tuple into 14 fields.
    Returns tuple of 14 values or None if invalid.
    """
    # Remove leading/trailing parentheses and whitespace
    row_str = row_str.strip()
    if row_str.startswith('('):
        row_str = row_str[1:]
    if row_str.endswith(')'):
        row_str = row_str[:-1]
    
    fields = []
    current_field = ""
    in_string = False
    escape_next = False
    paren_depth = 0
    
    for char in row_str:
        if escape_next:
            current_field += char
            escape_next = False
            continue
        
        if char == '\\':
            escape_next = True
            current_field += char
            continue
        
        if char == "'":
            in_string = not in_string
            current_field += char
            continue
        
        if not in_string and char == ',':
            # Field separator found
            fields.append(current_field.strip())
            current_field = ""
            if len(fields) == 14:
                break  # We have all 14 fields
            continue
        
        current_field += char
    
    # Add the last field
    if current_field and len(fields) < 14:
        fields.append(current_field.strip())
    
    if len(fields) != 14:
        return None
    
    return tuple(fields)

def convert_binary_field(field_value):
    """
    Convert MySQL _binary 'data' to PostgreSQL E'\\xHEX' format.
    """
    if not field_value.startswith("_binary"):
        return field_value
    
    # Extract the content between quotes
    match = re.search(r"_binary '(.+)'$", field_value)
    if not match:
        print(f"WARNING: Could not parse binary field: {field_value[:50]}")
        return field_value
    
    binary_content = match.group(1)
    # Convert to hex
    try:
        hex_str = binary_content.encode('latin1').hex()
        return f"E'\\\\x{hex_str}'"
    except Exception as e:
        print(f"ERROR converting binary: {e}")
        return field_value

def parse_tablets_ultimate(dump_file, output_dir, batch_size=50):
    """
    Ultimate parser: Read line 51, split by ),( carefully, parse each row.
    """
    print(f"Reading dump: {dump_file}")
    
    with open(dump_file, 'r', encoding='latin1') as f:
        lines = f.readlines()
    
    # Line 51 contains the INSERT
    line51 = lines[50]
    print(f"Line 51 length: {len(line51):,} chars")
    
    # Extract VALUES content
    start_idx = line51.find('VALUES ') + 7
    end_idx = line51.rfind(');')
    values_content = line51[start_idx:end_idx+1]  # Include the final )
    
    print(f"VALUES content: {len(values_content):,} chars")
    
    # Split by ),( pattern - but we'll validate each row has 14 fields
    raw_rows = values_content.split('),(')
    
    print(f"Initial split found {len(raw_rows)} potential rows")
    
    # Clean up first and last rows
    if raw_rows:
        raw_rows[0] = raw_rows[0].lstrip('(')
        raw_rows[-1] = raw_rows[-1].rstrip(')')
    
    # Parse and validate each row
    valid_rows = []
    for i, raw_row in enumerate(raw_rows):
        parsed = parse_row(raw_row)
        if parsed and len(parsed) == 14:
            valid_rows.append(parsed)
        else:
            print(f"WARNING: Row {i+1} invalid (fields: {len(parsed) if parsed else 'None'})")
            # Try to debug
            if parsed:
                print(f"  Fields: {[f[:20] for f in parsed]}")
    
    print(f"\n✅ Successfully parsed {len(valid_rows)}/894 rows")
    
    if len(valid_rows) != 894:
        print(f"❌ ERROR: Expected 894 rows, got {len(valid_rows)}")
        return False
    
    # Convert binary fields (field index 2 is the 'key')
    print("\nConverting binary fields...")
    converted_rows = []
    for row in valid_rows:
        row_list = list(row)
        row_list[2] = convert_binary_field(row_list[2])  # Convert 'key' field
        converted_rows.append(row_list)
    
    print("✅ Binary conversion complete")
    
    # Generate batches
    output_dir.mkdir(parents=True, exist_ok=True)
    num_batches = (len(converted_rows) + batch_size - 1) // batch_size
    
    for batch_num in range(num_batches):
        start_idx = batch_num * batch_size
        end_idx = min(start_idx + batch_size, len(converted_rows))
        batch_rows = converted_rows[start_idx:end_idx]
        
        batch_file = output_dir / f"batch_{batch_num+1:02d}.sql"
        
        with open(batch_file, 'w', encoding='utf-8') as f:
            f.write("INSERT INTO staging.v1_tablets\n")
            f.write("(id, designator, key, restaurant, printing, config_edit, v2, fw_ver, sw_ver,\n")
            f.write(" desynced, last_boot, last_check, created_at, modified_at)\n")
            f.write("VALUES\n")
            
            for i, row in enumerate(batch_rows):
                row_str = f"({','.join(row)})"
                if i < len(batch_rows) - 1:
                    row_str += ","
                else:
                    row_str += ";"
                f.write(row_str + "\n")
        
        print(f"  ✓ Batch {batch_num+1}: {batch_file.name} ({end_idx - start_idx} rows)")
    
    print(f"\n✅ SUCCESS: Generated {num_batches} batches")
    return True

if __name__ == "__main__":
    dump_file = Path("/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Devices & Infrastructure Entity/menuca_v1_tablets.sql")
    output_dir = Path("/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Devices & Infrastructure Entity/batches_v2/")
    
    success = parse_tablets_ultimate(dump_file, output_dir, batch_size=50)
    
    if success:
        print("\n" + "="*60)
        print("✅ READY TO LOAD")
        print("="*60)
    else:
        print("\n" + "="*60)
        print("❌ PARSING FAILED")
        print("="*60)

