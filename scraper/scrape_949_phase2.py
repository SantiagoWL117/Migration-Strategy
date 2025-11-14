#!/usr/bin/env python3
"""
Phase 2 scraper for Restaurant 949 (All Out Burger - 585 Montreal Road).
Scrapes dish prices, modifier groups, and modifier items from the V1 CRM.
"""
import logging
import sys
from pathlib import Path

# Import from parent scraper directory
sys.path.insert(0, str(Path(__file__).parent))

from scraper import MenuScraper
from database import DatabaseManager
from config import SCHEMA

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler()
    ]
)

logger = logging.getLogger(__name__)


def get_dishes_to_scrape(db, restaurant_id):
    """Get all dishes for the restaurant that need Phase 2 data."""
    query = f"""
        SELECT d.id, d.name, d.source_id, c.name as course_name
        FROM {SCHEMA}.dishes d
        JOIN {SCHEMA}.courses c ON d.course_id = c.id
        WHERE d.restaurant_id = %s 
          AND d.source_id IS NOT NULL
          AND d.deleted_at IS NULL
        ORDER BY c.display_order, d.display_order
    """
    db.cursor.execute(query, (restaurant_id,))
    return db.cursor.fetchall()


def insert_dish_prices(db, dish_id, prices_data):
    """Insert prices for a dish."""
    inserted = 0
    for price_data in prices_data:
        price_id = db.insert_dish_price(
            dish_id=dish_id,
            size_variant=price_data.get('size_variant'),
            price=price_data['price'],
            display_order=price_data['display_order']
        )
        if price_id:
            inserted += 1
    return inserted


def insert_modifiers(db, restaurant_id, dish_id, modifiers_data):
    """Insert modifier groups and items for a dish."""
    groups_inserted = 0
    items_inserted = 0
    prices_inserted = 0
    
    for modifier_group in modifiers_data:
        # Insert modifier group
        group_id = db.insert_modifier_group(
            dish_id=dish_id,
            name=modifier_group['name'],
            is_required=modifier_group['is_required'],
            min_selections=modifier_group['min_selections'],
            max_selections=modifier_group['max_selections'],
            display_order=modifier_group['display_order']
        )
        
        if group_id:
            groups_inserted += 1
            
            # Insert modifier items for this group
            for item_data in modifier_group.get('items', []):
                # Map type_code to modifier_type
                type_code = modifier_group.get('type_code', 'other')
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
                modifier_type = type_mapping.get(type_code, 'other')
                
                modifier_id = db.insert_dish_modifier(
                    restaurant_id=restaurant_id,
                    dish_id=dish_id,
                    modifier_group_id=group_id,
                    name=item_data['name'],
                    modifier_type=modifier_type,
                    is_default=item_data.get('is_default', False),
                    display_order=item_data['display_order']
                )
                
                if modifier_id:
                    items_inserted += 1
                    
                    # Insert prices for each size variant
                    prices = item_data.get('prices', [0.0])
                    
                    # If there's only one price, it's for 'standard' size
                    if len(prices) == 1:
                        price_id = db.insert_dish_modifier_price(
                            dish_modifier_id=modifier_id,
                            dish_id=dish_id,
                            restaurant_id=restaurant_id,
                            size_variant='standard',
                            price=prices[0],
                            display_order=0
                        )
                        if price_id:
                            prices_inserted += 1
                    else:
                        # Multiple prices for different size variants
                        size_variants = ['small', 'medium', 'large', 'x-large']
                        for idx, price in enumerate(prices):
                            size_variant = size_variants[idx] if idx < len(size_variants) else f'size_{idx+1}'
                            price_id = db.insert_dish_modifier_price(
                                dish_modifier_id=modifier_id,
                                dish_id=dish_id,
                                restaurant_id=restaurant_id,
                                size_variant=size_variant,
                                price=price,
                                display_order=idx
                            )
                            if price_id:
                                prices_inserted += 1
    
    return groups_inserted, items_inserted, prices_inserted


def main():
    """Scrape Phase 2 data for restaurant 949."""
    
    # Restaurant details
    DB_ID = 949  # Database ID
    CRM_ID = 1071  # CRM/V1 ID (legacy_v1_id)
    RESTAURANT_NAME = "All Out Burger - 585 Montreal Road"
    
    logger.info("=" * 60)
    logger.info(f"Phase 2 Scraper: {RESTAURANT_NAME}")
    logger.info(f"Database ID: {DB_ID}")
    logger.info(f"CRM ID: {CRM_ID}")
    logger.info("=" * 60)
    
    # Initialize database
    db = DatabaseManager()
    db.connect()
    logger.info("Database connection established")
    
    # Get dishes to scrape
    dishes = get_dishes_to_scrape(db, DB_ID)
    logger.info(f"Found {len(dishes)} dishes to scrape")
    
    if not dishes:
        logger.warning("No dishes found with source_id!")
        db.close()
        return
    
    # Initialize scraper
    scraper = MenuScraper()
    scraper.start()
    logger.info("Scraper initialized and logged in")
    
    # Track statistics
    total_prices = 0
    total_groups = 0
    total_items = 0
    total_modifier_prices = 0
    successful = 0
    failed = 0
    
    try:
        for idx, dish in enumerate(dishes, 1):
            dish_id = dish['id']
            dish_name = dish['name']
            menu_entry_id = dish['source_id']
            course_name = dish['course_name']
            
            logger.info(f"[{idx}/{len(dishes)}] {course_name} > {dish_name}")
            logger.info(f"  Scraping menu_entry_id: {menu_entry_id}")
            
            try:
                # Scrape dish details
                details = scraper.scrape_dish_details(CRM_ID, menu_entry_id, language='en')
                
                if not details:
                    logger.warning(f"  No details found for menu_entry_id {menu_entry_id}")
                    failed += 1
                    continue
                
                # Insert prices
                prices_data = details.get('prices', [])
                if prices_data:
                    prices_count = insert_dish_prices(db, dish_id, prices_data)
                    total_prices += prices_count
                    logger.info(f"  Inserted {prices_count} price(s)")
                else:
                    logger.warning(f"  No prices found")
                
                # Insert modifiers
                modifiers_data = details.get('modifiers', [])
                if modifiers_data:
                    groups, items, mod_prices = insert_modifiers(db, DB_ID, dish_id, modifiers_data)
                    total_groups += groups
                    total_items += items
                    total_modifier_prices += mod_prices
                    logger.info(f"  Inserted {groups} group(s), {items} item(s), {mod_prices} modifier price(s)")
                else:
                    logger.info(f"  No modifiers found")
                
                successful += 1
                
            except Exception as e:
                logger.error(f"  Failed to scrape dish {dish_name}: {e}")
                failed += 1
                continue
        
        logger.info("")
        logger.info("=" * 60)
        logger.info("PHASE 2 COMPLETE")
        logger.info("=" * 60)
        logger.info(f"Dishes processed: {successful}/{len(dishes)}")
        logger.info(f"Failed: {failed}")
        logger.info(f"Total prices inserted: {total_prices}")
        logger.info(f"Total modifier groups inserted: {total_groups}")
        logger.info(f"Total modifier items inserted: {total_items}")
        logger.info(f"Total modifier prices inserted: {total_modifier_prices}")
        logger.info("=" * 60)
        
    except Exception as e:
        logger.error(f"Error during scraping: {e}", exc_info=True)
        raise
    
    finally:
        scraper.stop()
        db.close()
        logger.info("Resources cleaned up")


if __name__ == "__main__":
    main()

