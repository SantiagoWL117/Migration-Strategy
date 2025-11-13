#!/usr/bin/env python3
"""Test the complete _extract_modifiers method."""
from bs4 import BeautifulSoup
from scraper import MenuScraper

# Load the saved HTML
with open('mozzarella_pizza_detail.html', 'r', encoding='utf-8') as f:
    html = f.read()

soup = BeautifulSoup(html, 'html.parser')

# Create a scraper instance
scraper = MenuScraper()

# Test the full _extract_modifiers method
print('='*80)
print('Testing _extract_modifiers() method')
print('='*80)

modifiers = scraper._extract_modifiers(soup)

print(f'\nModifier groups extracted: {len(modifiers)}')

if modifiers:
    for mg in modifiers:
        print(f'\nGroup: {mg["name"]} ({mg["type_code"]})')
        print(f'  Required: {mg["is_required"]}')
        print(f'  Min: {mg["min_selections"]}, Max: {mg["max_selections"]}')
        print(f'  Items: {len(mg["items"])}')
        
        for item in mg['items'][:3]:
            print(f'    - {item["name"]}: {item["prices"]}')
else:
    print('\n[ERROR] No modifier groups returned!')
    
    # Debug each type
    print('\nDEBUGGING:')
    
    modifier_types = {
        'br': {'name': 'hasBread', 'header': 'breadHeader'},
        'ci': {'name': 'hasCustomisation', 'header': 'ciHeader'},
        'sa': {'name': 'hasSauce', 'header': 'sauceHeader'},
    }
    
    for type_code, config in modifier_types.items():
        print(f'\n  Type: {type_code}')
        
        # Check checkbox
        checkbox = soup.find('input', {'id': config['name'], 'type': 'checkbox'})
        if checkbox:
            print(f'    Checkbox found: YES')
            print(f'    Has checked attr: {checkbox.has_attr("checked")}')
            
            if not checkbox.has_attr('checked'):
                print(f'    [REASON] Checkbox not checked!')
        else:
            print(f'    [REASON] Checkbox not found!')
        
        # Check items
        items = scraper._extract_modifier_items(soup, type_code)
        print(f'    Items extracted: {len(items)}')
        
        if not items:
            print(f'    [REASON] No items extracted!')

