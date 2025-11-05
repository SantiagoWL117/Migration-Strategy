#!/usr/bin/env python3
"""
Compare Restaurants-active.md with active-locations-verified.csv
to identify restaurants that should be added/removed from the active list.
"""

import csv
import re
from typing import Dict, Set, Tuple

def normalize_name(name: str) -> str:
    """Normalize restaurant name for comparison"""
    # Remove extra whitespace
    name = ' '.join(name.split())
    # Lowercase for comparison
    return name.lower().strip()

def normalize_address(address: str) -> str:
    """Normalize address for comparison"""
    # Remove extra whitespace
    address = ' '.join(address.split())
    # Lowercase for comparison
    return address.lower().strip()

def parse_active_markdown(filename: str) -> Dict[str, Dict]:
    """Parse Restaurants-active.md markdown file"""
    active = {}
    with open(filename, 'r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            # Skip headers, empty lines, code blocks
            if not line or line.startswith('#') or line.startswith('```'):
                continue
            
            # Match lines like: "- Restaurant Name Address"
            if line.startswith('-'):
                # Remove status markers (✅, ❌, ⚠️, ⏳)
                line = re.sub(r'^-\s*[✅❌⚠️⏳]\s*', '- ', line)
                # Remove the leading dash and whitespace
                line = line[1:].strip()
                
                # Try to split name and address (address usually has numbers or street indicators)
                # Pattern: Name followed by address (address often starts with number or street name)
                match = re.match(r'^(.+?)\s+(\d+.+)$', line)
                if match:
                    name = match.group(1).strip()
                    address = match.group(2).strip()
                else:
                    # No clear address pattern, take whole line as name
                    name = line
                    address = ""
                
                if name:
                    key = f"{normalize_name(name)}|{normalize_address(address)}"
                    active[key] = {
                        'name': name,
                        'address': address,
                        'full_line': line
                    }
    return active

def parse_verified_csv(filename: str) -> Dict[str, Dict]:
    """Parse active-locations-verified.csv file"""
    verified = {}
    with open(filename, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            name = row['Name'].strip()
            location = row['Location'].strip()
            key = f"{normalize_name(name)}|{normalize_address(location)}"
            verified[key] = {
                'name': name,
                'address': location
            }
    return verified

def fuzzy_match(verified: Dict, active: Dict) -> Tuple[Set[str], Set[str], Set[str]]:
    """Find matches using fuzzy matching for names"""
    only_in_verified = set(verified.keys())
    only_in_active = set(active.keys())
    in_both = set()
    
    # First pass: exact matches
    for v_key in list(only_in_verified):
        if v_key in only_in_active:
            in_both.add(v_key)
            only_in_verified.discard(v_key)
            only_in_active.discard(v_key)
    
    # Second pass: fuzzy match by name only (addresses might differ slightly)
    verified_by_name = {}
    for v_key in only_in_verified:
        v_name = verified[v_key]['name']
        v_norm_name = normalize_name(v_name)
        if v_norm_name not in verified_by_name:
            verified_by_name[v_norm_name] = []
        verified_by_name[v_norm_name].append(v_key)
    
    active_by_name = {}
    for a_key in list(only_in_active):
        a_name = active[a_key]['name']
        a_norm_name = normalize_name(a_name)
        if a_norm_name not in active_by_name:
            active_by_name[a_norm_name] = []
        active_by_name[a_norm_name].append(a_key)
    
    # Match by name
    for v_norm_name, v_keys in verified_by_name.items():
        if v_norm_name in active_by_name:
            # Found name match - check if addresses are similar
            for v_key in v_keys:
                v_addr = normalize_address(verified[v_key]['address'])
                best_match = None
                best_score = 0
                
                for a_key in active_by_name[v_norm_name]:
                    a_addr = normalize_address(active[a_key]['address'])
                    # Simple similarity: check if addresses share common words
                    v_words = set(v_addr.split())
                    a_words = set(a_addr.split())
                    if v_words and a_words:
                        similarity = len(v_words & a_words) / max(len(v_words), len(a_words))
                        if similarity > best_score:
                            best_score = similarity
                            best_match = a_key
                
                # If addresses are similar enough (>50% word overlap), consider it a match
                if best_match and best_score > 0.3:
                    in_both.add(v_key)
                    only_in_verified.discard(v_key)
                    if best_match in only_in_active:
                        only_in_active.discard(best_match)
    
    return only_in_verified, only_in_active, in_both

def main():
    print("Loading files...")
    verified = parse_verified_csv('active-locations-verified.csv')
    active = parse_active_markdown('Restaurants-active.md')
    
    print(f"\n=== COMPARISON RESULTS ===\n")
    print(f"Verified list (billed in last 4 months): {len(verified)} restaurants")
    print(f"Active list (current): {len(active)} restaurants\n")
    
    only_in_verified, only_in_active, in_both = fuzzy_match(verified, active)
    
    print(f"In both lists (confirmed active): {len(in_both)}")
    print(f"Only in verified list (should be added): {len(only_in_verified)}")
    print(f"Only in active list (should be removed): {len(only_in_active)}\n")
    
    # Generate report
    with open('restaurant-list-comparison-report.md', 'w', encoding='utf-8') as f:
        f.write("# Restaurant List Comparison Report\n\n")
        f.write(f"**Date:** 2025-11-03\n\n")
        f.write(f"**Verified List:** {len(verified)} restaurants (billed in last 4 months)\n")
        f.write(f"**Active List:** {len(active)} restaurants (current master list)\n")
        f.write(f"**In Both:** {len(in_both)} restaurants (confirmed active)\n\n")
        
        f.write("## Summary\n\n")
        f.write(f"- ✅ **Confirmed Active:** {len(in_both)} restaurants\n")
        f.write(f"- ➕ **Should Add:** {len(only_in_verified)} restaurants\n")
        f.write(f"- ➖ **Should Remove:** {len(only_in_active)} restaurants\n\n")
        
        f.write("---\n\n")
        f.write("## ➕ Restaurants to ADD (in verified list, not in active list)\n\n")
        f.write(f"**Count:** {len(only_in_verified)}\n\n")
        for key in sorted(only_in_verified):
            v = verified[key]
            f.write(f"- {v['name']} | {v['address']}\n")
        
        f.write("\n---\n\n")
        f.write("## ➖ Restaurants to REMOVE (in active list, not in verified list)\n\n")
        f.write(f"**Count:** {len(only_in_active)}\n\n")
        f.write("⚠️ **Note:** These restaurants have NOT been billed in the last 4 months.\n\n")
        for key in sorted(only_in_active):
            a = active[key]
            f.write(f"- {a['name']} | {a['address']}\n")
        
        f.write("\n---\n\n")
        f.write("## ✅ Confirmed Active (in both lists)\n\n")
        f.write(f"**Count:** {len(in_both)}\n\n")
        f.write("These restaurants are confirmed active and should remain on the list.\n")
    
    print("\n✅ Report generated: restaurant-list-comparison-report.md")
    print("\n=== QUICK SUMMARY ===")
    print(f"✅ Confirmed Active: {len(in_both)}")
    print(f"➕ Should Add: {len(only_in_verified)}")
    print(f"➖ Should Remove: {len(only_in_active)}")

if __name__ == '__main__':
    main()

