#!/usr/bin/env python3
"""
Validate scraped data completeness and identify potential partial dishes.
"""
import psycopg2
from psycopg2.extras import RealDictCursor
from config import DB_CONNECTION_STRING, SCHEMA
import json

def validate_scraped_data():
    """Run comprehensive validation checks."""
    conn = psycopg2.connect(DB_CONNECTION_STRING)
    cursor = conn.cursor(cursor_factory=RealDictCursor)
    
    issues = {
        'dishes_no_prices': [],
        'dishes_one_price': [],
        'dishes_no_modifiers_expected': [],
        'modifier_groups_no_items': [],
        'modifier_items_no_prices': []
    }
    
    print("=" * 60)
    print("DATA COMPLETENESS VALIDATION")
    print("=" * 60)
    
    # 1. Dishes with no prices
    print("\n1. Checking dishes with no prices...")
    query = f"""
        SELECT d.id, d.name, r.name as restaurant_name
        FROM {SCHEMA}.dishes d
        JOIN {SCHEMA}.restaurants r ON d.restaurant_id = r.id
        LEFT JOIN {SCHEMA}.dish_prices dp ON d.id = dp.dish_id
        WHERE d.source_id IS NOT NULL
          AND d.deleted_at IS NULL
        GROUP BY d.id, d.name, r.name
        HAVING COUNT(dp.id) = 0
    """
    cursor.execute(query)
    results = cursor.fetchall()
    issues['dishes_no_prices'] = [dict(r) for r in results]
    print(f"   Found: {len(results)} dishes with no prices")
    
    # 2. Dishes with only 1 price
    print("\n2. Checking dishes with only 1 price (may be incomplete)...")
    query = f"""
        SELECT d.id, d.name, r.name as restaurant_name,
               STRING_AGG(dp.size_variant, ', ') as sizes
        FROM {SCHEMA}.dishes d
        JOIN {SCHEMA}.restaurants r ON d.restaurant_id = r.id
        LEFT JOIN {SCHEMA}.dish_prices dp ON d.id = dp.dish_id
        WHERE d.source_id IS NOT NULL
          AND d.deleted_at IS NULL
        GROUP BY d.id, d.name, r.name
        HAVING COUNT(dp.id) = 1
    """
    cursor.execute(query)
    results = cursor.fetchall()
    issues['dishes_one_price'] = [dict(r) for r in results]
    print(f"   Found: {len(results)} dishes with only 1 price")
    
    # 3. Pizza/Burger dishes without modifiers
    print("\n3. Checking pizza/burger dishes without modifiers...")
    query = f"""
        SELECT d.id, d.name, r.name as restaurant_name
        FROM {SCHEMA}.dishes d
        JOIN {SCHEMA}.restaurants r ON d.restaurant_id = r.id
        LEFT JOIN {SCHEMA}.modifier_groups mg ON d.id = mg.dish_id
        WHERE d.source_id IS NOT NULL
          AND d.deleted_at IS NULL
          AND d.name ILIKE ANY(ARRAY['%pizza%', '%burger%', '%sub%', '%sandwich%'])
        GROUP BY d.id, d.name, r.name
        HAVING COUNT(mg.id) = 0
    """
    cursor.execute(query)
    results = cursor.fetchall()
    issues['dishes_no_modifiers_expected'] = [dict(r) for r in results]
    print(f"   Found: {len(results)} dishes expected to have modifiers but don't")
    
    # 4. Modifier groups with no items
    print("\n4. Checking modifier groups with no items...")
    query = f"""
        SELECT mg.id, mg.name, d.name as dish_name, r.name as restaurant_name
        FROM {SCHEMA}.modifier_groups mg
        JOIN {SCHEMA}.dishes d ON mg.dish_id = d.id
        JOIN {SCHEMA}.restaurants r ON d.restaurant_id = r.id
        LEFT JOIN {SCHEMA}.dish_modifiers dm ON mg.id = dm.modifier_group_id
        GROUP BY mg.id, mg.name, d.name, r.name
        HAVING COUNT(dm.id) = 0
    """
    cursor.execute(query)
    results = cursor.fetchall()
    issues['modifier_groups_no_items'] = [dict(r) for r in results]
    print(f"   Found: {len(results)} modifier groups with no items")
    
    # 5. Modifier items with no prices
    print("\n5. Checking modifier items with no prices...")
    query = f"""
        SELECT dm.id, dm.name, d.name as dish_name, r.name as restaurant_name
        FROM {SCHEMA}.dish_modifiers dm
        JOIN {SCHEMA}.dishes d ON dm.dish_id = d.id
        JOIN {SCHEMA}.restaurants r ON d.restaurant_id = r.id
        LEFT JOIN {SCHEMA}.dish_modifier_prices dmp ON dm.id = dmp.dish_modifier_id
        GROUP BY dm.id, dm.name, d.name, r.name
        HAVING COUNT(dmp.id) = 0
    """
    cursor.execute(query)
    results = cursor.fetchall()
    issues['modifier_items_no_prices'] = [dict(r) for r in results]
    print(f"   Found: {len(results)} modifier items with no prices")
    
    # Summary
    total_issues = sum(len(v) for v in issues.values())
    print("\n" + "=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print(f"Total potential issues found: {total_issues}")
    for issue_type, items in issues.items():
        print(f"  {issue_type}: {len(items)}")
    
    # Save to file
    output_file = 'data_validation_issues.json'
    with open(output_file, 'w') as f:
        json.dump(issues, f, indent=2, default=str)
    print(f"\nDetailed results saved to: {output_file}")
    
    # Generate list of dish IDs to re-scrape
    dishes_to_rescrape = set()
    for issue_list in [issues['dishes_no_prices'], issues['dishes_one_price'], 
                       issues['dishes_no_modifiers_expected']]:
        for item in issue_list:
            dishes_to_rescrape.add(item['id'])
    
    rescrape_file = 'dishes_to_rescrape.txt'
    with open(rescrape_file, 'w') as f:
        for dish_id in sorted(dishes_to_rescrape):
            f.write(f"{dish_id}\n")
    print(f"Dish IDs to re-scrape saved to: {rescrape_file}")
    print(f"Total unique dishes to re-scrape: {len(dishes_to_rescrape)}")
    
    cursor.close()
    conn.close()
    
    return issues

if __name__ == "__main__":
    validate_scraped_data()


