#!/usr/bin/env python3
"""
Flag restaurants in Course-Fix-Progress.md that are no longer on the verified active list.
"""

import re
import csv

# Read verified list
verified_restaurants = set()
with open('active-locations-verified.csv', 'r', encoding='utf-8') as f:
    reader = csv.DictReader(f)
    for row in reader:
        name = row['Name'].strip()
        location = row['Location'].strip()
        verified_restaurants.add(f"{name} {location}".lower())

def normalize_restaurant_entry(text):
    """Normalize restaurant name/address for comparison"""
    # Remove extra whitespace
    text = ' '.join(text.split())
    return text.lower().strip()

def extract_restaurant_info(line):
    """Extract restaurant name and address from audit entry"""
    # Pattern: #### Restaurant Name (Restaurant ID: XXX) or ### Restaurant Name
    match = re.match(r'^#{3,4}\s+(.+?)\s*\(Restaurant ID:\s*(\d+)\)', line)
    if match:
        return match.group(1).strip(), match.group(2)
    
    match = re.match(r'^#{3,4}\s+(.+?)$', line)
    if match:
        return match.group(1).strip(), None
    
    return None, None

def find_restaurant_in_verified(name, address=None):
    """Check if restaurant is in verified list"""
    # Try exact match first
    if address:
        full_entry = f"{name} {address}".lower()
        if full_entry in verified_restaurants:
            return True
    
    # Try name-only match
    name_lower = name.lower()
    for verified in verified_restaurants:
        if verified.startswith(name_lower) or name_lower in verified:
            return True
    
    return False

# Read audit file
with open('Course-Fix-Progress.md', 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Process and flag
output_lines = []
i = 0
while i < len(lines):
    line = lines[i]
    
    # Check if this is a restaurant header
    if re.match(r'^#{3,4}\s+', line):
        restaurant_name, restaurant_id = extract_restaurant_info(line)
        
        if restaurant_name:
            # Check if next lines contain address
            address = None
            j = i + 1
            while j < min(i + 10, len(lines)):
                if 'Address:' in lines[j]:
                    addr_match = re.search(r'Address:\s*(.+?)(?:\s*✅|\s*$)', lines[j])
                    if addr_match:
                        address = addr_match.group(1).strip()
                    break
                j += 1
            
            # Check if restaurant is in verified list
            is_verified = find_restaurant_in_verified(restaurant_name, address)
            
            if not is_verified:
                # Flag as removed - add warning before the header
                flag_note = f"\n**🚫 REMOVED FROM ACTIVE LIST** - Restaurant not in verified billing list (last 4 months). Course assignment work can be skipped.\n\n"
                output_lines.append(flag_note)
                # Also add flag to the status line if it exists
                # We'll add it after we see the status line
                output_lines.append(line)
                i += 1
                
                # Check next few lines for status and add flag there too
                while i < len(lines) and not re.match(r'^#{3,4}\s+', lines[i]):
                    next_line = lines[i]
                    # If this is a status line, add the flag
                    if '**Status:**' in next_line and '🚫 REMOVED' not in next_line:
                        # Add flag to status
                        next_line = next_line.replace('**Status:**', '**Status:** 🚫 REMOVED FROM ACTIVE LIST |')
                    output_lines.append(next_line)
                    i += 1
                continue
    
    output_lines.append(line)
    i += 1

# Write updated file
with open('Course-Fix-Progress.md', 'w', encoding='utf-8') as f:
    f.writelines(output_lines)

print("✅ Flagged restaurants removed from active list in Course-Fix-Progress.md")

