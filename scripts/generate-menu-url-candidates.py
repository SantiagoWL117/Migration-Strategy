#!/usr/bin/env python3
"""
Generate candidate menu URLs for restaurants based on known patterns.
This helps speed up the audit process by pre-generating likely URLs.
"""

import re
import unicodedata

def normalize_name(name):
    """Normalize restaurant name for URL generation."""
    # Remove location suffixes (e.g., "- Downtown", "- Hull")
    name = re.sub(r'\s*-\s*[^-]+$', '', name)
    
    # Remove common words
    name = re.sub(r'\b(Pizza|Restaurant|Take Out|&|and)\b', '', name, flags=re.IGNORECASE)
    
    # Remove special characters except spaces
    name = re.sub(r'[^\w\s]', '', name)
    
    # Remove accents
    name = unicodedata.normalize('NFD', name)
    name = name.encode('ascii', 'ignore').decode('ascii')
    
    # Convert to lowercase and remove spaces
    name = name.lower().replace(' ', '')
    
    return name

def generate_url_candidates(restaurant_name, address=""):
    """Generate candidate menu URLs based on known patterns."""
    base_name = normalize_name(restaurant_name)
    
    candidates = [
        # Pattern 1: name + ottawa + .menu.ca
        f"https://{base_name}ottawa.menu.ca/?p=menu",
        
        # Pattern 2: name + .menu.ca
        f"https://{base_name}.menu.ca/?p=menu",
        
        # Pattern 3: name + .ca
        f"https://{base_name}.ca/?p=menu",
        
        # Pattern 4: name + ottawa + .ca
        f"https://{base_name}ottawa.ca/?p=menu",
        
        # Pattern 5: m. + name + ottawa + .com
        f"https://m.{base_name}ottawa.com/menu",
        
        # Pattern 6: name + .com
        f"https://{base_name}.com/?p=menu",
    ]
    
    # If address has a number, try address prefix pattern
    address_match = re.search(r'(\d+)', address)
    if address_match:
        street_num = address_match.group(1)
        candidates.insert(0, f"https://{street_num}{base_name}.ca/?p=menu")
    
    return candidates

# Example usage
if __name__ == "__main__":
    test_restaurants = [
        ("Papa Burger", "22, rue des Flandres"),
        ("Papa Pizza - Hull", "574, boul Saint-Joseph"),
        ("Papa Joe's Pizza - Downtown", "527 Bronson Ave"),
    ]
    
    for name, address in test_restaurants:
        print(f"\n{name} ({address}):")
        for url in generate_url_candidates(name, address):
            print(f"  - {url}")

