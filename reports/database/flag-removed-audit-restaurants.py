#!/usr/bin/env python3
"""
Flag restaurants in Course-Fix-Progress.md that are no longer on the verified active list.
This prevents wasting time fixing menu data for restaurants that are no longer active.
"""

import re
import csv

# Read verified list - create lookup
verified_restaurants = {}
with open('active-locations-verified.csv', 'r', encoding='utf-8') as f:
    reader = csv.DictReader(f)
    for row in reader:
        name = row['Name'].strip()
        location = row['Location'].strip()
        key = f"{name.lower()} {location.lower()}"
        verified_restaurants[key] = {'name': name, 'location': location}

def normalize(text):
    """Normalize text for comparison"""
    return ' '.join(text.split()).lower().strip()

def extract_restaurant_from_audit(header_line, address_line=None):
    """Extract restaurant name and address from audit entry"""
    # Pattern: #### Restaurant Name (Restaurant ID: XXX)
    match = re.match(r'^#{3,4}\s+(.+?)\s*\(Restaurant ID:\s*(\d+)\)', header_line)
    if not match:
        match = re.match(r'^#{3,4}\s+(.+?)$', header_line)
        if match:
            return match.group(1).strip(), None
        return None, None
    
    name = match.group(1).strip()
    restaurant_id = match.group(2)
    
    # Try to extract address from next lines
    address = None
    if address_line:
        addr_match = re.search(r'Address:\s*(.+?)(?:\s*✅|\s*$)', address_line)
        if addr_match:
            address = addr_match.group(1).strip()
    
    return name, address

def is_in_verified_list(name, address=None):
    """Check if restaurant is in verified list"""
    name_norm = normalize(name)
    
    # Try exact match first
    if address:
        addr_norm = normalize(address)
        key = f"{name_norm} {addr_norm}"
        if key in verified_restaurants:
            return True
    
    # Try fuzzy match by name
    for v_key, v_data in verified_restaurants.items():
        v_name_norm = normalize(v_data['name'])
        # Check if names match (allowing for slight variations)
        if v_name_norm == name_norm or name_norm in v_name_norm or v_name_norm in name_norm:
            # If address provided, check similarity
            if address:
                v_addr_norm = normalize(v_data['location'])
                addr_norm = normalize(address)
                # Check if addresses share common words
                v_words = set(v_addr_norm.split())
                a_words = set(addr_norm.split())
                if v_words and a_words:
                    similarity = len(v_words & a_words) / max(len(v_words), len(a_words))
                    if similarity > 0.3:  # 30% word overlap
                        return True
            else:
                # No address to check, names match - consider it verified
                return True
    
    return False

# Read audit file
with open('Course-Fix-Progress.md', 'r', encoding='utf-8') as f:
    content = f.read()

# Split into lines
lines = content.split('\n')

# Process and flag
output_lines = []
i = 0
flagged_count = 0

while i < len(lines):
    line = lines[i]
    
    # Check if this is a restaurant header (#### or ###)
    if re.match(r'^#{3,4}\s+', line):
        restaurant_name, restaurant_id = extract_restaurant_from_audit(line)
        
        if restaurant_name:
            # Look ahead for address
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
            is_verified = is_in_verified_list(restaurant_name, address)
            
            if not is_verified:
                flagged_count += 1
                # Add flag before the header
                flag_note = f"\n**🚫 REMOVED FROM ACTIVE LIST** - Restaurant not in verified billing list (last 4 months). Course assignment work can be skipped.\n\n"
                output_lines.append(flag_note)
                output_lines.append(line)
                i += 1
                
                # Process next lines until next restaurant header
                while i < len(lines) and not re.match(r'^#{3,4}\s+', lines[i]):
                    next_line = lines[i]
                    
                    # Add flag to status line if it exists
                    if '**Status:**' in next_line and '🚫 REMOVED' not in next_line:
                        # Check if it already has status flags
                        if '|' in next_line:
                            next_line = next_line.replace('**Status:**', '**Status:** 🚫 REMOVED FROM ACTIVE LIST |')
                        else:
                            next_line = next_line.replace('**Status:**', '**Status:** 🚫 REMOVED FROM ACTIVE LIST |')
                    
                    output_lines.append(next_line)
                    i += 1
                continue
    
    output_lines.append(line)
    i += 1

# Write updated file
with open('Course-Fix-Progress.md', 'w', encoding='utf-8') as f:
    f.write('\n'.join(output_lines))

print(f"✅ Flagged {flagged_count} restaurants removed from active list in Course-Fix-Progress.md")
print("   These restaurants are marked with 🚫 REMOVED FROM ACTIVE LIST flag")
print("   Course assignment work can be skipped for these restaurants")

