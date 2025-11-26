#!/usr/bin/env python3
"""Add Menu Data Scraped column to BILLING_LIST_VERIFICATION_REPORT.md"""

# Read the mapping
mapping = {}
with open('menu_data_status.csv', 'r') as f:
    next(f)  # skip header
    for line in f:
        line = line.strip()
        if line and ',' in line:
            rid, status = line.split(',')
            mapping[int(rid)] = status

print(f'Loaded {len(mapping)} restaurant statuses')

# Read the report
with open('BILLING_LIST_VERIFICATION_REPORT.md', 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Update lines
result_lines = []
in_section1 = False
rows_updated = 0

for line in lines:
    line_stripped = line.rstrip('\n\r')
    
    if '## ✅ SECTION 1: FOUND IN DATABASE' in line_stripped:
        in_section1 = True
        result_lines.append(line_stripped)
    elif in_section1 and line_stripped.startswith('**TOTAL FOUND'):
        in_section1 = False
        result_lines.append(line_stripped)
    elif in_section1 and line_stripped.startswith('| ') and not line_stripped.startswith('|| '):
        # Table rows that start with single | (markdown format)
        # Check if this is a data row
        if 'DB ID' not in line_stripped and 'Billing List' not in line_stripped and '---' not in line_stripped:
            parts = line_stripped.split('|')
            # Format: | Name | DB ID | DB Name | DB Address | Notes |
            if len(parts) >= 6:
                try:
                    # DB ID is in parts[2] (index 2)
                    db_id_str = parts[2].strip()
                    db_id = int(db_id_str)
                    status = mapping.get(db_id, 'UNKNOWN')
                    # Add status before the last |
                    new_line = line_stripped.rstrip(' |') + ' | ' + status + ' |'
                    result_lines.append(new_line)
                    rows_updated += 1
                except (ValueError, IndexError) as e:
                    result_lines.append(line_stripped)
            else:
                result_lines.append(line_stripped)
        else:
            result_lines.append(line_stripped)
    else:
        result_lines.append(line_stripped)

# Write back
with open('BILLING_LIST_VERIFICATION_REPORT.md', 'w', encoding='utf-8') as f:
    f.write('\n'.join(result_lines) + '\n')

print(f'Updated {rows_updated} restaurant rows')




























