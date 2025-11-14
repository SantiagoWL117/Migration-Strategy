#!/usr/bin/env python3
"""
Phase 2 Scraper for Restaurant 1015 (Poutinerie Québecurds Gatineau)
Scrapes prices and modifiers using the French menu (showLang=fr)
"""
import sys
import os
import json
import time
import logging
from datetime import datetime

# Add List 4 Scrapper directory to path for imports
list4_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'List 4 Scrapper')
sys.path.insert(0, list4_dir)

from scraper import MenuScraper
from database import DatabaseManager
from config import SCHEMA

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('scrape_1015_phase2_french.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

RESTAURANT_ID = 1015
RESTAURANT_NAME = "Poutinerie Québecurds Gatineau"


def get_dishes_to_scrape(db):
    """
    Get all dishes for restaurant 1015 that need Phase 2 scraping.
    """
    logger.info(f"Querying dishes for restaurant {RESTAURANT_ID}...")
    
    query = f"""
    SELECT 
        d.id as dish_id,
        d.name as dish_name,
        d.source_id as menu_entry_id,
        c.name as course_name,
        r.legacy_v1_id as crm_restaurant_id
    FROM {SCHEMA}.dishes d
    JOIN {SCHEMA}.courses c ON d.course_id = c.id
    JOIN {SCHEMA}.restaurants r ON c.restaurant_id = r.id
    WHERE r.id = %s AND d.deleted_at IS NULL
    ORDER BY d.id
    """
    
    db.cursor.execute(query, (RESTAURANT_ID,))
    results = db.cursor.fetchall()
    
    dishes = []
    for row in results:
        dish = dict(row)
        dish['restaurant_id'] = RESTAURANT_ID
        dish['restaurant_name'] = RESTAURANT_NAME
        dishes.append(dish)
    
    logger.info(f"Found {len(dishes)} dishes to process")
    return dishes


def scrape_dish_prices_modifiers(db, scraper, dish):
    """
    Scrape prices and modifiers for a single dish and insert into database.
    Uses French language (showLang=fr).
    
    Returns:
        Dict with 'success', 'prices_count', 'modifiers_count', 'error' keys
    """
    result = {
        'dish_id': dish['dish_id'],
        'dish_name': dish['dish_name'],
        'course_name': dish['course_name'],
        'menu_entry_id': dish['menu_entry_id'],
        'success': False,
        'prices_count': 0,
        'modifier_groups_count': 0,
        'modifier_items_count': 0,
        'modifier_prices_count': 0,
        'error': None
    }
    
    try:
        # Ensure database connection
        db.ensure_connection()
        
        logger.info(f"Scraping: {dish['dish_name']} (Dish ID: {dish['dish_id']}, Entry: {dish['menu_entry_id']})")
        
        # Scrape dish details with FRENCH language parameter
        details = scraper.scrape_dish_details(
            dish['crm_restaurant_id'], 
            dish['menu_entry_id'],
            language='fr'  # Use French menu
        )
        
        if not details:
            result['error'] = 'No details scraped'
            logger.warning(f"  ⚠️ No details for dish {dish['dish_id']}")
            return result
        
        # Insert dish prices
        prices_inserted = 0
        size_variants = []  # Track size variants for modifier prices
        
        for price_data in details.get('prices', []):
            size_variant = price_data.get('size_variant')
            
            # Use "standard" for dishes without size variants
            if not size_variant:
                size_variant = 'standard'
            
            size_variants.append(size_variant)
            
            price_id = db.insert_dish_price(
                dish_id=dish['dish_id'],
                size_variant=size_variant,
                price=price_data['price'],
                display_order=price_data.get('display_order', 0)
            )
            if price_id:
                prices_inserted += 1
                logger.debug(f"    Inserted price: {size_variant} = ${price_data['price']}")
        
        # If no size variants found, use "standard" as default
        if not size_variants:
            size_variants = ['standard']
        
        # Insert modifier groups and items
        modifier_groups_inserted = 0
        modifier_items_inserted = 0
        modifier_prices_inserted = 0
        
        # Map modifier type codes to database modifier_type enum values
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
        
        for mod_group in details.get('modifier_groups', []):
            # Insert modifier group
            group_id = db.insert_modifier_group(
                dish_id=dish['dish_id'],
                name=mod_group['name'],
                is_required=mod_group.get('is_required', False),
                min_selections=mod_group.get('min_selections', 0),
                max_selections=mod_group.get('max_selections', 1),
                display_order=mod_group.get('display_order', 0)
            )
            
            if group_id:
                modifier_groups_inserted += 1
                logger.debug(f"    Inserted modifier group: {mod_group['name']}")
                
                # Insert modifier items
                for mod_item in mod_group.get('items', []):
                    # Map type code to database enum
                    raw_type = mod_item.get('type', '')
                    modifier_type = type_mapping.get(raw_type, 'extras')
                    
                    # Insert modifier item
                    item_id = db.insert_dish_modifier(
                        modifier_group_id=group_id,
                        name=mod_item['name'],
                        modifier_type=modifier_type,
                        is_default=mod_item.get('is_default', False),
                        display_order=mod_item.get('display_order', 0)
                    )
                    
                    if item_id:
                        modifier_items_inserted += 1
                        
                        # Insert modifier prices (one for each size variant)
                        for idx, size_variant in enumerate(size_variants):
                            # Get price for this size, default to 0.0
                            price_value = mod_item.get('price', 0.0)
                            
                            # If modifier has size-specific prices
                            if isinstance(mod_item.get('price'), dict):
                                price_value = mod_item['price'].get(size_variant, 0.0)
                            
                            price_id = db.insert_dish_modifier_price(
                                dish_modifier_id=item_id,
                                size_variant=size_variant,
                                price=price_value,
                                display_order=idx
                            )
                            
                            if price_id:
                                modifier_prices_inserted += 1
        
        result['success'] = True
        result['prices_count'] = prices_inserted
        result['modifier_groups_count'] = modifier_groups_inserted
        result['modifier_items_count'] = modifier_items_inserted
        result['modifier_prices_count'] = modifier_prices_inserted
        
        logger.info(f"  ✅ {dish['dish_name']}: {prices_inserted} prices, {modifier_groups_inserted} groups, {modifier_items_inserted} modifiers")
        
    except Exception as e:
        result['error'] = str(e)
        logger.error(f"  ❌ Error scraping dish {dish['dish_id']}: {e}")
        import traceback
        traceback.print_exc()
    
    return result


def main():
    """Main execution function."""
    logger.info("=" * 80)
    logger.info(f"Phase 2 Scraper for Restaurant {RESTAURANT_ID} - {RESTAURANT_NAME}")
    logger.info(f"Language: French (showLang=fr)")
    logger.info("=" * 80)
    
    start_time = time.time()
    
    # Initialize database
    db = DatabaseManager()
    db.connect()
    logger.info("Database connected")
    
    # Get dishes to scrape
    dishes = get_dishes_to_scrape(db)
    
    if not dishes:
        logger.error("No dishes found for restaurant 1015!")
        return
    
    logger.info(f"Found {len(dishes)} dishes to scrape")
    
    # Initialize scraper
    scraper = MenuScraper()
    scraper.start()
    logger.info("Scraper initialized and logged in")
    
    # Process each dish
    results = []
    success_count = 0
    error_count = 0
    
    total_prices = 0
    total_mod_groups = 0
    total_mod_items = 0
    total_mod_prices = 0
    
    for idx, dish in enumerate(dishes, 1):
        logger.info(f"\n[{idx}/{len(dishes)}] Processing: {dish['dish_name']}")
        
        result = scrape_dish_prices_modifiers(db, scraper, dish)
        results.append(result)
        
        if result['success']:
            success_count += 1
            total_prices += result['prices_count']
            total_mod_groups += result['modifier_groups_count']
            total_mod_items += result['modifier_items_count']
            total_mod_prices += result['modifier_prices_count']
        else:
            error_count += 1
        
        # Small delay between dishes
        time.sleep(0.5)
    
    # Close connections
    scraper.close()
    db.close()
    
    # Calculate duration
    duration = time.time() - start_time
    duration_str = f"{int(duration // 60)}m {int(duration % 60)}s"
    
    # Save results
    results_file = 'scrape_1015_phase2_results.json'
    with open(results_file, 'w') as f:
        json.dump({
            'restaurant_id': RESTAURANT_ID,
            'restaurant_name': RESTAURANT_NAME,
            'language': 'fr',
            'timestamp': datetime.now().isoformat(),
            'duration_seconds': duration,
            'total_dishes': len(dishes),
            'success_count': success_count,
            'error_count': error_count,
            'total_prices_inserted': total_prices,
            'total_modifier_groups': total_mod_groups,
            'total_modifier_items': total_mod_items,
            'total_modifier_prices': total_mod_prices,
            'dishes': results
        }, f, indent=2)
    
    # Print summary
    logger.info("\n" + "=" * 80)
    logger.info("PHASE 2 SCRAPING COMPLETE!")
    logger.info("=" * 80)
    logger.info(f"Restaurant: {RESTAURANT_NAME} (ID: {RESTAURANT_ID})")
    logger.info(f"Duration: {duration_str}")
    logger.info(f"Total Dishes: {len(dishes)}")
    logger.info(f"Successful: {success_count}")
    logger.info(f"Errors: {error_count}")
    logger.info("-" * 80)
    logger.info(f"Prices Inserted: {total_prices}")
    logger.info(f"Modifier Groups: {total_mod_groups}")
    logger.info(f"Modifier Items: {total_mod_items}")
    logger.info(f"Modifier Prices: {total_mod_prices}")
    logger.info("-" * 80)
    logger.info(f"Results saved to: {results_file}")
    logger.info("=" * 80)


if __name__ == '__main__':
    main()

