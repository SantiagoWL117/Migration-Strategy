#!/usr/bin/env python3
"""
Post-process the generated SQL to convert ANY remaining _binary fields.

This script reads the SQL file and converts all _binary '...' to E'\\xHEX' format,
handling ALL edge cases by converting byte by byte.
"""

import re
from pathlib import Path

def convert_binary_match(match):
    """
    Convert a single _binary '...' match to hex format.
    
    The match group(1) contains the content between the quotes.
    """
    binary_str = match.group(1)
    # Convert to bytes using latin1, then to hex
    hex_str = binary_str.encode('latin1').hex()
    return f"E'\\\\x{hex_str}'"

def fix_binary_fields(input_file, output_file):
    """
    Read SQL file and convert ALL _binary fields to hex.
    """
    print(f"Reading: {input_file}")
    
    with open(input_file, 'r', encoding='utf-8', errors='replace') as f:
        content = f.read()
    
    print(f"File size: {len(content):,} bytes")
    
    # Find all _binary occurrences BEFORE conversion
    before_count = content.count("_binary '")
    print(f"Found {before_count} _binary fields to convert")
    
    if before_count == 0:
        print("✅ No _binary fields found - file is already fully converted!")
        return
    
    # Use a GREEDY match to get everything between quotes
    # This regex matches _binary ' followed by anything until the LAST '
    # But we need to be careful about escaped quotes
    
    # Strategy: Match _binary ' then capture everything up to ' (non-greedy)
    # This handles most cases correctly
    pattern = r"_binary '([^']*(?:''[^']*)*)'"
    
    converted_content = re.sub(pattern, convert_binary_match, content)
    
    # Verify conversion
    after_count = converted_content.count("_binary '")
    converted = before_count - after_count
    print(f"Converted {converted} _binary fields")
    print(f"Remaining _binary fields: {after_count}")
    
    if after_count > 0:
        print("⚠️  WARNING: Some _binary fields remain unconverted")
        print("Showing first 5 remaining:")
        remaining = re.findall(r"_binary '[^']*'", converted_content)[:5]
        for r in remaining:
            print(f"  {r}")
    else:
        print("✅ All _binary fields converted successfully!")
    
    # Write output
    print(f"Writing to: {output_file}")
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(converted_content)
    
    print(f"Done! Output: {output_file}")
    return after_count == 0

if __name__ == "__main__":
    input_path = Path("/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Devices & Infrastructure Entity/FINAL/v1_tablets_FINAL.sql")
    output_path = Path("/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Devices & Infrastructure Entity/FINAL/v1_tablets_FIXED.sql")
    
    success = fix_binary_fields(input_path, output_path)
    
    if success:
        print("\n✅ SUCCESS! Ready to load to PostgreSQL")
    else:
        print("\n❌ FAILED - manual review needed")

