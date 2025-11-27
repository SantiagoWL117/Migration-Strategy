import re
import csv

# Parse V2_V3_MATCHING_REPORT.md to extract V2->V3 mappings
print("Extracting V2->V3 mappings from matching report...")

v2_v3_mappings = []

with open('extracted_data/V2_V3_MATCHING_REPORT.md', 'r', encoding='utf-8') as f:
    content = f.read()
    
    # Find the matched restaurants table
    matched_section_start = content.find("## Matched Restaurants")
    if matched_section_start == -1:
        print("ERROR: Could not find matched restaurants section")
        exit(1)
    
    print(f"Found matched section at position {matched_section_start}")
    
    # Find the next section (which starts with ##)
    next_section_start = content.find("\n##", matched_section_start + 10)
    if next_section_start == -1:
        matched_section_end = len(content)
    else:
        matched_section_end = next_section_start
    
    print(f"Section ends at position {matched_section_end}")
    matched_table = content[matched_section_start:matched_section_end]
    print(f"Matched table length: {len(matched_table)} characters")
    
    # Parse table rows - simpler approach, split by lines
    lines = matched_table.split('\n')
    print(f"Total lines in matched section: {len(lines)}")
    
    parsed_count = 0
    for line_num, line in enumerate(lines):
        if not line.strip() or '|' not in line:
            continue
        if '-----' in line or 'V3 ID' in line:  # Skip header and separator
            continue
            
        # Split by pipe and clean
        parts = [p.strip() for p in line.split('|') if p.strip()]
        
        if parsed_count < 3:  # Debug first 3 lines
            print(f"Line {line_num}: {len(parts)} parts")
            if len(parts) > 0:
                print(f"  Parts[0]: '{parts[0]}'")
                if len(parts) > 4:
                    print(f"  Parts[4]: '{parts[4]}'")
        
        if len(parts) >= 9:  # Ensure we have all columns
            try:
                v3_id = parts[0]
                v3_name = parts[1].replace('\\\'', "'")
                v3_v1_id = parts[3]
                v2_id = parts[4]
                v2_v1_id = parts[5]
                v2_name = parts[6].replace('\\\'', "'")
                
                # Validate it's a data row (v3_id should be numeric)
                if v3_id.isdigit() and v2_id.isdigit():
                    v2_v3_mappings.append({
                        'v2_id': v2_id,
                        'v2_v1_id': v2_v1_id if v2_v1_id != 'NULL' else None,
                        'v2_name': v2_name,
                        'v3_id': v3_id,
                        'v3_name': v3_name
                    })
                    parsed_count += 1
            except (IndexError, ValueError) as e:
                continue  # Skip malformed rows

print(f"Extracted {len(v2_v3_mappings)} V2->V3 mappings")

# Save to CSV
with open('extracted_data/v2_v3_mappings_from_report.csv', 'w', encoding='utf-8', newline='') as f:
    if v2_v3_mappings:
        fieldnames = ['v2_id', 'v2_v1_id', 'v2_name', 'v3_id', 'v3_name']
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(v2_v3_mappings)

print(f"Saved to: extracted_data/v2_v3_mappings_from_report.csv")

