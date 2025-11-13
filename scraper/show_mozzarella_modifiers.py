#!/usr/bin/env python3
"""Show all modifier groups, items, and prices for Mozzarella Pizza."""

from database import DatabaseManager
from config import SCHEMA

db = DatabaseManager()
db.connect()

print('='*120)
print('MOZZARELLA PIZZA - COMPLETE MODIFIER DATA')
print('='*120)
print('Restaurant: Mozza Pizza (DB ID: 35, CRM ID: 132)')
print('Dish: Mozzarella Pizza')
print()

# Get the dish
query = f"""
SELECT d.id, d.name, d.source_id
FROM {SCHEMA}.dishes d
WHERE d.restaurant_id = 35 
  AND d.name = 'Mozzarella Pizza'
  AND d.deleted_at IS NULL
"""

db.cursor.execute(query)
dish = db.cursor.fetchone()

if not dish:
    print("ERROR: Mozzarella Pizza not found!")
    db.close()
    exit(1)

dish_id = dish['id']
print(f"Dish ID: {dish_id}")
print(f"Menu Entry ID: {dish['source_id']}")
print()

# Get dish prices first
print('='*120)
print('DISH PRICES:')
print('='*120)

query = f"""
SELECT size_variant, price, display_order
FROM {SCHEMA}.dish_prices
WHERE dish_id = {dish_id}
ORDER BY display_order
"""

db.cursor.execute(query)
prices = db.cursor.fetchall()

if prices:
    print(f"{'Size':<20} {'Price':<15}")
    print('-'*120)
    for p in prices:
        print(f"{p['size_variant']:<20} ${p['price']:<14.2f}")
else:
    print("No prices found")

print()

# Get modifier groups
query = f"""
SELECT 
    mg.id as group_id,
    mg.name as group_name,
    mg.is_required,
    mg.min_selections,
    mg.max_selections,
    mg.display_order
FROM {SCHEMA}.modifier_groups mg
WHERE mg.dish_id = {dish_id}
ORDER BY mg.display_order
"""

db.cursor.execute(query)
modifier_groups = db.cursor.fetchall()

if not modifier_groups:
    print("No modifier groups found!")
    db.close()
    exit(0)

print('='*120)
print(f'MODIFIER GROUPS: {len(modifier_groups)} groups found')
print('='*120)
print()

# For each modifier group, get items and prices
for mg in modifier_groups:
    print('='*120)
    print(f"GROUP: {mg['group_name']}")
    print('='*120)
    print(f"Group ID: {mg['group_id']}")
    print(f"Required: {mg['is_required']}")
    print(f"Min Selections: {mg['min_selections']}")
    print(f"Max Selections: {mg['max_selections']}")
    print()
    
    # Get modifier items for this group
    query = f"""
    SELECT 
        dm.id as item_id,
        dm.name as item_name,
        dm.modifier_type,
        dm.is_default,
        dm.display_order
    FROM {SCHEMA}.dish_modifiers dm
    WHERE dm.modifier_group_id = {mg['group_id']}
    ORDER BY dm.display_order
    """
    
    db.cursor.execute(query)
    items = db.cursor.fetchall()
    
    print(f"Items in this group: {len(items)}")
    print()
    print(f"{'#':<4} {'Item Name':<50} {'Prices by Size':<60}")
    print('-'*120)
    
    for idx, item in enumerate(items, 1):
        # Get prices for this modifier item
        price_query = f"""
        SELECT 
            dmp.size_variant,
            dmp.price,
            dmp.display_order
        FROM {SCHEMA}.dish_modifier_prices dmp
        WHERE dmp.dish_modifier_id = {item['item_id']}
        ORDER BY dmp.display_order
        """
        
        db.cursor.execute(price_query)
        item_prices = db.cursor.fetchall()
        
        # Format prices
        price_str = ", ".join([f"{p['size_variant']}: ${p['price']:.2f}" for p in item_prices])
        
        # Print item with prices
        print(f"{idx:<4} {item['item_name']:<50} {price_str:<60}")
    
    print()

# Summary statistics
print('='*120)
print('SUMMARY:')
print('='*120)

# Count totals
query = f"""
SELECT 
    (SELECT COUNT(*) FROM {SCHEMA}.dish_prices WHERE dish_id = {dish_id}) as price_count,
    (SELECT COUNT(*) FROM {SCHEMA}.modifier_groups WHERE dish_id = {dish_id}) as group_count,
    (SELECT COUNT(*) FROM {SCHEMA}.dish_modifiers dm 
     JOIN {SCHEMA}.modifier_groups mg ON dm.modifier_group_id = mg.id 
     WHERE mg.dish_id = {dish_id}) as item_count,
    (SELECT COUNT(*) FROM {SCHEMA}.dish_modifier_prices dmp
     JOIN {SCHEMA}.dish_modifiers dm ON dmp.dish_modifier_id = dm.id
     JOIN {SCHEMA}.modifier_groups mg ON dm.modifier_group_id = mg.id
     WHERE mg.dish_id = {dish_id}) as modifier_price_count
"""

db.cursor.execute(query)
summary = db.cursor.fetchone()

print(f"Dish Prices: {summary['price_count']}")
print(f"Modifier Groups: {summary['group_count']}")
print(f"Modifier Items: {summary['item_count']}")
print(f"Modifier Prices (size variants): {summary['modifier_price_count']}")
print()
print('='*120)

db.close()


