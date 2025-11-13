#!/usr/bin/env python3
"""Test the _extract_modifier_items method directly."""
from bs4 import BeautifulSoup
from scraper import MenuScraper

# Load the saved HTML
with open('mozzarella_pizza_detail.html', 'r', encoding='utf-8') as f:
    html = f.read()

soup = BeautifulSoup(html, 'html.parser')

# Create a scraper instance to access the method
scraper = MenuScraper()

# Test _extract_modifier_items for different types
type_codes = ['br', 'ci', 'sa']

for type_code in type_codes:
    print('\n' + '='*60)
    print(f'Testing _extract_modifier_items for type: {type_code}')
    print('='*60)
    
    items = scraper._extract_modifier_items(soup, type_code)
    print(f'Items extracted: {len(items)}')
    
    if items:
        print('First 3 items:')
        for item in items[:3]:
            print(f'  - {item["name"]}: {item["prices"]}')
    else:
        print('[WARNING] No items extracted!')
        
        # Debug: check if container exists
        container = soup.find('ul', {'id': f'ul{type_code}'})
        if container:
            print(f'  Container ul{type_code} EXISTS')
            
            # Check for radio buttons
            radios = container.find_all('input', {'type': 'radio', 'name': f'{type_code}_radio'})
            print(f'  Radio buttons found: {len(radios)}')
            
            if radios:
                for radio in radios:
                    radio_value = radio.get('value')
                    print(f'    Radio value: {radio_value}')
                    
                    # Check for group ul
                    group_ul = soup.find('ul', {'id': f'list_{type_code}_{radio_value}'})
                    if group_ul:
                        lis = group_ul.find_all('li', recursive=False)
                        print(f'      Found ul list_{type_code}_{radio_value} with {len(lis)} items')
                    else:
                        print(f'      [ERROR] ul list_{type_code}_{radio_value} NOT FOUND')
        else:
            print(f'  [ERROR] Container ul{type_code} NOT FOUND')

