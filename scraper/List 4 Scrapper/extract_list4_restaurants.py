#!/usr/bin/env python3
"""
Extract List 4 restaurants from ACTIVE_V1_RESTAURANTS_SCRAPPED.md
and query the database to get their DB IDs and CRM IDs.
"""
import sys
import re
from database import DatabaseManager
from config import SCHEMA
import json

def normalize_string(s):
    """Normalize string for comparison."""
    return s.strip().lower().replace("'", "").replace("-", " ")

def safe_print(text):
    """Print text safely handling Unicode encoding issues."""
    try:
        print(text)
    except UnicodeEncodeError:
        safe_text = text.encode('ascii', 'replace').decode('ascii')
        print(safe_text)

def main():
    """Extract List 4 restaurants and get their database information."""
    
    safe_print("=" * 80)
    safe_print("EXTRACTING LIST 4 RESTAURANTS")
    safe_print("=" * 80)
    
    # Read the markdown file
    with open('ACTIVE_V1_RESTAURANTS_SCRAPPED.md', 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Extract List 4 section
    list4_section = re.search(r'## List 4: V1 Restaurants NOT Scraped.*?\n\|\s*Restaurant Name.*?\|\s*Address.*?\|\n\|\s*-+.*?\|\s*-+.*?\|\n(.*?)(\n##|\Z)', content, re.DOTALL)
    
    if not list4_section:
        safe_print("[ERROR] Could not find List 4 section in markdown file")
        return
    
    list4_text = list4_section.group(1)
    
    # Parse restaurants from table
    restaurants = []
    for line in list4_text.strip().split('\n'):
        if line.strip() and line.strip() != '|':
            # Extract name and address from table row
            match = re.match(r'\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|', line)
            if match:
                name = match.group(1).strip()
                address = match.group(2).strip()
                if name and address:
                    restaurants.append({
                        'name': name,
                        'address': address
                    })
    
    safe_print(f"\n[INFO] Found {len(restaurants)} restaurants in List 4")
    
    # Connect to database
    db = DatabaseManager()
    db.connect()
    
    # Query database for each restaurant
    results = []
    found_count = 0
    not_found = []
    
    for rest in restaurants:
        # Try to find restaurant by name and address
        query = f"""
            SELECT 
                r.id AS db_id,
                r.name AS db_name,
                r.legacy_v1_id AS crm_id,
                rl.street_address AS address
            FROM {SCHEMA}.restaurants r
            LEFT JOIN {SCHEMA}.restaurant_locations rl ON r.id = rl.restaurant_id
            WHERE LOWER(r.name) LIKE %s
              AND r.deleted_at IS NULL
        """
        
        # Try exact name match first
        db.cursor.execute(query, (f"%{rest['name'].lower()}%",))
        db_results = db.cursor.fetchall()
        
        if not db_results:
            not_found.append(rest)
            safe_print(f"\n[WARN] Not found: {rest['name']} | {rest['address']}")
            continue
        
        # If multiple results, try to match by address
        if len(db_results) > 1:
            matched = None
            norm_addr = normalize_string(rest['address'])
            for db_rest in db_results:
                if db_rest['address']:
                    db_addr = normalize_string(db_rest['address'])
                    if norm_addr in db_addr or db_addr in norm_addr:
                        matched = db_rest
                        break
            
            if not matched:
                # Just take the first one if no address match
                matched = db_results[0]
                safe_print(f"\n[WARN] Multiple matches for {rest['name']}, using first: DB ID {matched['db_id']}")
            
            db_rest = matched
        else:
            db_rest = db_results[0]
        
        # Check if it has CRM ID
        if not db_rest['crm_id']:
            safe_print(f"\n[WARN] No CRM ID for: {rest['name']} (DB ID: {db_rest['db_id']})")
            not_found.append(rest)
            continue
        
        found_count += 1
        results.append({
            'name': rest['name'],
            'address': rest['address'],
            'db_id': db_rest['db_id'],
            'db_name': db_rest['db_name'],
            'crm_id': db_rest['crm_id']
        })
        
        safe_print(f"[OK] {rest['name']} | DB ID: {db_rest['db_id']} | CRM ID: {db_rest['crm_id']}")
    
    db.close()
    
    # Save results to JSON
    output_file = 'list4_restaurants.json'
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(results, f, indent=2, ensure_ascii=False)
    
    safe_print("\n" + "=" * 80)
    safe_print("EXTRACTION SUMMARY")
    safe_print("=" * 80)
    safe_print(f"Total restaurants in List 4: {len(restaurants)}")
    safe_print(f"Found in database: {found_count}")
    safe_print(f"Not found / No CRM ID: {len(not_found)}")
    safe_print(f"\nResults saved to: {output_file}")
    safe_print("=" * 80)
    
    if not_found:
        safe_print("\n[INFO] Restaurants not found or missing CRM ID:")
        for rest in not_found:
            safe_print(f"  - {rest['name']} | {rest['address']}")

if __name__ == "__main__":
    main()



