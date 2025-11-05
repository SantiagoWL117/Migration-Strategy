#!/usr/bin/env python3
"""
Update Restaurants-active.md based on verified billing list.
Removes restaurants not in verified list, adds restaurants from verified list.
"""

import csv
import re
from typing import Dict, Set, List, Tuple

def normalize_name(name: str) -> str:
    """Normalize restaurant name for comparison"""
    return ' '.join(name.split()).lower().strip()

def normalize_address(address: str) -> str:
    """Normalize address for comparison"""
    return ' '.join(address.split()).lower().strip()

def parse_verified_csv(filename: str) -> Dict[str, Dict]:
    """Parse verified CSV and return dict keyed by normalized name|address"""
    verified = {}
    with open(filename, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            name = row['Name'].strip()
            location = row['Location'].strip()
            key = f"{normalize_name(name)}|{normalize_address(location)}"
            verified[key] = {'name': name, 'address': location}
    return verified

def parse_active_markdown(filename: str) -> List[Tuple[str, str, str]]:
    """Parse active markdown and return list of (line, name, address)"""
    restaurants = []
    with open(filename, 'r', encoding='utf-8') as f:
        for line in f:
            original_line = line.rstrip()
            line = original_line.strip()
            
            # Skip headers, empty lines, code blocks
            if not line or line.startswith('#') or line.startswith('```'):
                restaurants.append((original_line, '', ''))
                continue
            
            # Match lines like: "- Restaurant Name Address"
            if line.startswith('-'):
                # Remove status markers (✅, ❌, ⚠️, ⏳)
                clean_line = re.sub(r'^-\s*[✅❌⚠️⏳]\s*', '- ', line)
                # Remove the leading dash and whitespace
                content = clean_line[1:].strip()
                
                # Try to split name and address
                match = re.match(r'^(.+?)\s+(\d+.+)$', content)
                if match:
                    name = match.group(1).strip()
                    address = match.group(2).strip()
                else:
                    # No clear address pattern, take whole line as name
                    name = content
                    address = ""
                
                restaurants.append((original_line, name, address))
            else:
                restaurants.append((original_line, '', ''))
    
    return restaurants

def create_key(name: str, address: str) -> str:
    """Create normalized key for comparison"""
    return f"{normalize_name(name)}|{normalize_address(address)}"

def fuzzy_match_name(verified: Dict, name: str, address: str) -> bool:
    """Check if restaurant matches verified list by name (with address similarity check)"""
    norm_name = normalize_name(name)
    norm_addr = normalize_address(address)
    
    # Check exact match first
    key = create_key(name, address)
    if key in verified:
        return True
    
    # Check by name only (addresses might differ slightly)
    for v_key, v_data in verified.items():
        v_norm_name = normalize_name(v_data['name'])
        if v_norm_name == norm_name:
            # Names match, check if addresses are similar
            v_addr = normalize_address(v_data['address'])
            if not norm_addr or not v_addr:
                # If either is empty, consider it a match if names match
                return True
            # Check address similarity
            v_words = set(v_addr.split())
            a_words = set(norm_addr.split())
            if v_words and a_words:
                similarity = len(v_words & a_words) / max(len(v_words), len(a_words))
                if similarity > 0.3:  # 30% word overlap
                    return True
    
    return False

def main():
    print("Loading files...")
    verified = parse_verified_csv('active-locations-verified.csv')
    active_list = parse_active_markdown('Restaurants-active.md')
    
    # Build set of restaurants to keep (those in verified list)
    restaurants_to_keep = []
    restaurants_to_add = []
    
    # Track which verified restaurants we've matched
    matched_verified = set()
    
    # Process active list
    for line, name, address in active_list:
        if not name:  # Header, empty line, etc.
            restaurants_to_keep.append(line)
            continue
        
        # Check if this restaurant is in verified list
        if fuzzy_match_name(verified, name, address):
            restaurants_to_keep.append(line)
            # Mark as matched
            key = create_key(name, address)
            if key in verified:
                matched_verified.add(key)
            else:
                # Find matching verified entry by name
                norm_name = normalize_name(name)
                for v_key, v_data in verified.items():
                    if normalize_name(v_data['name']) == norm_name:
                        matched_verified.add(v_key)
                        break
        else:
            # Not in verified list - skip (remove)
            print(f"Removing: {name} | {address}")
    
    # Find restaurants to add (in verified but not matched)
    for v_key, v_data in verified.items():
        if v_key not in matched_verified:
            # Check if we already have it by name match
            norm_name = normalize_name(v_data['name'])
            found = False
            for line, name, address in active_list:
                if normalize_name(name) == norm_name:
                    found = True
                    break
            
            if not found:
                restaurants_to_add.append(f"- {v_data['name']} {v_data['address']}")
                print(f"Adding: {v_data['name']} | {v_data['address']}")
    
    # Write updated list
    with open('Restaurants-active.md', 'w', encoding='utf-8') as f:
        f.write("# Active Restaurant Locations (Deduplicated Names)\n\n")
        f.write(f"**Updated:** 2025-11-03\n")
        f.write(f"**Verified against:** Billing records (last 4 months)\n")
        f.write(f"**Total:** {len(restaurants_to_keep) + len(restaurants_to_add)} restaurants\n\n")
        
        # Write kept restaurants
        for line in restaurants_to_keep:
            if line.strip():
                f.write(line + '\n')
        
        # Write new restaurants
        if restaurants_to_add:
            f.write("\n")
            for restaurant in sorted(restaurants_to_add):
                f.write(restaurant + '\n')
    
    print(f"\n✅ Updated Restaurants-active.md")
    print(f"   Kept: {len([r for r in restaurants_to_keep if r.strip() and not r.startswith('#')])}")
    print(f"   Added: {len(restaurants_to_add)}")
    print(f"   Total: {len([r for r in restaurants_to_keep if r.strip() and not r.startswith('#')]) + len(restaurants_to_add)}")

if __name__ == '__main__':
    main()

