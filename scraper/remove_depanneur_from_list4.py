#!/usr/bin/env python3
"""
Remove Dépanneur Généreux (DB:816) from list4_restaurants.json
since it was already scraped by the English scraper.
"""

import json

def main():
    # Load the current list
    with open('list4_restaurants.json', 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    print("=" * 80)
    print("REMOVING DÉPANNEUR GÉNÉREUX FROM LIST 4")
    print("=" * 80)
    print(f"\nBefore removal: {len(data)} restaurants")
    
    # Find and display the restaurant to remove
    removed = [r for r in data if r['db_id'] == 816]
    if removed:
        for r in removed:
            print(f"\nRemoving:")
            print(f"  - {r['name']}")
            print(f"  - DB ID: {r['db_id']}")
            print(f"  - CRM ID: {r['crm_id']}")
            print(f"  - Address: {r['address']}")
            print(f"  - Reason: Already scraped by English scraper")
    
    # Filter out DB:816
    filtered = [r for r in data if r['db_id'] != 816]
    
    print(f"\nAfter removal: {len(filtered)} restaurants")
    
    # Save the updated list
    with open('list4_restaurants.json', 'w', encoding='utf-8') as f:
        json.dump(filtered, f, indent=2, ensure_ascii=False)
    
    print("\n✅ Successfully updated list4_restaurants.json")
    print("=" * 80)

if __name__ == "__main__":
    main()

