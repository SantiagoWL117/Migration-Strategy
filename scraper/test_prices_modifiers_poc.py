#!/usr/bin/env python3
"""
Test POC for prices and modifiers scraping.
Tests with a single dish from Carlo's Pizza (Pepperoni Pizza).
"""

import logging
from database import DatabaseManager
from scraper import MenuScraper

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Test dish from Carlo's Pizza
TEST_RESTAURANT = {
    'db_id': 124,
    'name': "Carlo's Pizza",
    'crm_id': 246
}

TEST_DISH = {
    'name': 'Pepperoni Pizza',
    'menu_entry_id': 18750  # From the HTML you provided
}


def main():
    logger.info("=" * 60)
    logger.info("Prices & Modifiers Scraper - POC Test")
    logger.info("=" * 60)
    
    # Step 1: Connect to database
    logger.info("\nStep 1: Connecting to database...")
    db = DatabaseManager()
    db.connect()
    
    # Find the dish in database
    query = f"""
        SELECT id, name, source_id
        FROM menuca_v3.dishes
        WHERE restaurant_id = {TEST_RESTAURANT['db_id']}
          AND name LIKE '%{TEST_DISH['name']}%'
          AND source_id = {TEST_DISH['menu_entry_id']}
        LIMIT 1
    """
    db.cursor.execute(query)
    dish_row = db.cursor.fetchone()
    
    if not dish_row:
        logger.error(f"Dish '{TEST_DISH['name']}' not found in database!")
        logger.info("Please run the basic scraper first to populate dishes.")
        db.close()
        return
    
    dish_id = dish_row['id']
    logger.info(f"Found dish: {dish_row['name']} (ID: {dish_id})")
    
    # Check existing data
    db.cursor.execute(f"""
        SELECT COUNT(*) as count 
        FROM menuca_v3.dish_prices 
        WHERE dish_id = {dish_id}
    """)
    existing_prices = db.cursor.fetchone()['count']
    
    db.cursor.execute(f"""
        SELECT COUNT(*) as count 
        FROM menuca_v3.modifier_groups 
        WHERE dish_id = {dish_id}
    """)
    existing_groups = db.cursor.fetchone()['count']
    
    logger.info(f"Existing data: {existing_prices} prices, {existing_groups} modifier groups")
    
    # Step 2: Scrape dish details
    logger.info("\nStep 2: Scraping dish details...")
    scraper = MenuScraper()
    scraper.start()
    
    details = scraper.scrape_dish_details(
        TEST_RESTAURANT['crm_id'],
        TEST_DISH['menu_entry_id']
    )
    
    if not details:
        logger.error("Failed to scrape dish details!")
        scraper.stop()
        db.close()
        return
    
    logger.info(f"Scraped: {len(details.get('prices', []))} prices, {len(details.get('modifiers', []))} modifier groups")
    
    # Display scraped data
    logger.info("\n--- Scraped Prices ---")
    for price in details.get('prices', []):
        size = price.get('size_variant') or 'Regular'
        logger.info(f"  {size}: ${price['price']:.2f}")
    
    logger.info("\n--- Scraped Modifiers ---")
    for group in details.get('modifiers', []):
        logger.info(f"  Group: {group['name']} ({group['type_code']})")
        logger.info(f"    Required: {group['is_required']}, Min: {group['min_selections']}, Max: {group['max_selections']}")
        logger.info(f"    Items: {len(group.get('items', []))}")
        for item in group.get('items', [])[:3]:  # Show first 3 items
            logger.info(f"      - {item['name']}: ${item.get('price', 0):.2f}")
        if len(group.get('items', [])) > 3:
            logger.info(f"      ... and {len(group['items']) - 3} more items")
    
    scraper.stop()
    
    # Step 3: Insert into database
    logger.info("\nStep 3: Inserting into database...")
    
    # Insert prices
    prices_inserted = 0
    for price_data in details.get('prices', []):
        price_id = db.insert_dish_price(
            dish_id=dish_id,
            size_variant=price_data.get('size_variant'),
            price=price_data['price'],
            display_order=price_data.get('display_order', 0)
        )
        if price_id:
            prices_inserted += 1
            logger.info(f"  ✓ Inserted price: {price_data.get('size_variant') or 'Regular'} - ${price_data['price']:.2f}")
    
    # Get size variants from prices for modifier prices
    size_variants = []
    for price_data in details.get('prices', []):
        size_variant = price_data.get('size_variant')
        if not size_variant:
            size_variant = 'standard'
        size_variants.append(size_variant)
    
    # If no size variants, use "standard"
    if not size_variants:
        size_variants = ['standard']
    
    logger.info(f"  Size variants for modifiers: {size_variants}")
    
    # Insert modifier groups and items
    modifier_groups_inserted = 0
    modifier_items_inserted = 0
    modifier_prices_inserted = 0
    
    # Type mapping
    type_mapping = {
        'br': 'bread',
        'ci': 'custom_ingredients',
        'dr': 'dressing',
        'sa': 'sauces',
        'sd': 'side_dishes',
        'd': 'drinks',
        'e': 'extras',
        'cm': 'cooking_method'
    }
    
    for group_data in details.get('modifiers', []):
        # Insert group
        group_id = db.insert_modifier_group(
            dish_id=dish_id,
            name=group_data['name'],
            is_required=group_data.get('is_required', False),
            min_selections=group_data.get('min_selections', 0),
            max_selections=group_data.get('max_selections', 1),
            display_order=group_data.get('display_order', 0)
        )
        
        if group_id:
            modifier_groups_inserted += 1
            logger.info(f"  ✓ Inserted modifier group: {group_data['name']}")
            
            # Insert items
            modifier_type = type_mapping.get(group_data.get('type_code', ''), 'other')
            
            for item_data in group_data.get('items', []):
                # Insert modifier item (without price)
                item_id = db.insert_dish_modifier(
                    restaurant_id=TEST_RESTAURANT['db_id'],
                    dish_id=dish_id,
                    modifier_group_id=group_id,
                    name=item_data['name'],
                    modifier_type=modifier_type,
                    is_default=item_data.get('is_default', False),
                    display_order=item_data.get('display_order', 0)
                )
                
                if item_id:
                    modifier_items_inserted += 1
                    
                    # Insert prices for each size variant
                    item_prices = item_data.get('prices', [0.0])
                    
                    for idx, price_value in enumerate(item_prices):
                        # Match price to size variant
                        if idx < len(size_variants):
                            size_var = size_variants[idx]
                        else:
                            size_var = 'standard'
                        
                        price_id = db.insert_dish_modifier_price(
                            dish_modifier_id=item_id,
                            dish_id=dish_id,
                            restaurant_id=TEST_RESTAURANT['db_id'],
                            size_variant=size_var,
                            price=price_value,
                            display_order=idx
                        )
                        
                        if price_id:
                            modifier_prices_inserted += 1
            
            logger.info(f"    ✓ Inserted {len(group_data.get('items', []))} items with {modifier_prices_inserted} prices")
    
    # Step 4: Verify in database
    logger.info("\nStep 4: Verifying data in database...")
    
    db.cursor.execute(f"""
        SELECT COUNT(*) as count 
        FROM menuca_v3.dish_prices 
        WHERE dish_id = {dish_id}
    """)
    final_prices = db.cursor.fetchone()['count']
    
    db.cursor.execute(f"""
        SELECT COUNT(*) as count 
        FROM menuca_v3.modifier_groups 
        WHERE dish_id = {dish_id}
    """)
    final_groups = db.cursor.fetchone()['count']
    
    db.cursor.execute(f"""
        SELECT COUNT(*) as count 
        FROM menuca_v3.dish_modifiers 
        WHERE dish_id = {dish_id}
    """)
    final_items = db.cursor.fetchone()['count']
    
    db.cursor.execute(f"""
        SELECT COUNT(*) as count 
        FROM menuca_v3.dish_modifier_prices 
        WHERE dish_id = {dish_id}
    """)
    final_modifier_prices = db.cursor.fetchone()['count']
    
    logger.info(f"Final database state:")
    logger.info(f"  Dish prices: {final_prices}")
    logger.info(f"  Modifier groups: {final_groups}")
    logger.info(f"  Modifier items: {final_items}")
    logger.info(f"  Modifier prices: {final_modifier_prices}")
    
    db.close()
    
    # Summary
    logger.info("\n" + "=" * 60)
    logger.info("SUMMARY")
    logger.info("=" * 60)
    logger.info(f"Restaurant: {TEST_RESTAURANT['name']}")
    logger.info(f"Dish: {TEST_DISH['name']}")
    logger.info(f"Prices inserted: {prices_inserted}")
    logger.info(f"Modifier groups inserted: {modifier_groups_inserted}")
    logger.info(f"Modifier items inserted: {modifier_items_inserted}")
    logger.info("\n✅ POC test completed successfully!")
    logger.info("=" * 60)


if __name__ == "__main__":
    main()

