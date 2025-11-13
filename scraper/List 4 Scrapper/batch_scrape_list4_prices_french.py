#!/usr/bin/env python3
"""
Batch scraper for List 4 French restaurants - Phase 2.
Scrapes prices and modifiers for dishes from the 12 French restaurants.
"""
import sys
import os
import json
import logging
import time
from datetime import datetime
from pathlib import Path

# Add parent directory to path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from scraper import MenuScraper
from database import DatabaseManager
from config import SCHEMA

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('batch_scrape_list4_prices_french.log'),
        logging.StreamHandler()
    ]
)

logger = logging.getLogger(__name__)

# Configuration
PROGRESS_FILE = 'list4_prices_french_progress.json'
RESULTS_FILE = 'list4_prices_french_results.json'
DELAY_BETWEEN_DISHES = 1  # seconds


def load_progress():
    """Load progress from previous run."""
    if Path(PROGRESS_FILE).exists():
        with open(PROGRESS_FILE, 'r') as f:
            return json.load(f)
    return {'completed': [], 'failed': [], 'skipped': []}


def save_progress(progress):
    """Save progress to file."""
    with open(PROGRESS_FILE, 'w') as f:
        json.dump(progress, f, indent=2)


def load_results():
    """Load results from previous run."""
    if Path(RESULTS_FILE).exists():
        with open(RESULTS_FILE, 'r') as f:
            return json.load(f)
    return []


def save_results(results):
    """Save results to file."""
    with open(RESULTS_FILE, 'w') as f:
        json.dump(results, f, indent=2)


def get_french_restaurant_ids():
    """Get DB IDs of French restaurants from Phase 1 results."""
    with open('list4_french_results.json', 'r', encoding='utf-8') as f:
        phase1_results = json.load(f)
    
    # Filter successful French restaurants
    french_restaurants = [
        r for r in phase1_results 
        if r.get('status') == 'success' and r.get('language') == 'fr'
    ]
    
    return [r['db_id'] for r in french_restaurants]


def get_dishes_to_process(db, restaurant_ids):
    """Get all dishes from French restaurants that need prices/modifiers."""
    db.ensure_connection()
    
    ids_str = ','.join(map(str, restaurant_ids))
    
    query = f"""
        SELECT 
            d.id as dish_id,
            d.restaurant_id,
            d.name as dish_name,
            d.source_id as menu_entry_id,
            r.legacy_v1_id as crm_restaurant_id,
            r.name as restaurant_name
        FROM {SCHEMA}.dishes d
        JOIN {SCHEMA}.restaurants r ON d.restaurant_id = r.id
        WHERE d.restaurant_id IN ({ids_str})
          AND d.source_id IS NOT NULL
          AND d.deleted_at IS NULL
          AND r.deleted_at IS NULL
        ORDER BY d.restaurant_id, d.id
    """
    
    db.cursor.execute(query)
    results = db.cursor.fetchall()
    
    return [dict(row) for row in results]


def scrape_dish_prices_modifiers(db, scraper, dish):
    """
    Scrape prices and modifiers for a single dish and insert into database.
    
    Returns:
        Dict with 'success', 'prices_count', 'modifiers_count', 'error' keys
    """
    result = {
        'dish_id': dish['dish_id'],
        'dish_name': dish['dish_name'],
        'restaurant_id': dish['restaurant_id'],
        'restaurant_name': dish['restaurant_name'],
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
        
        logger.info(f"Scraping dish: {dish['dish_name']} (Dish ID: {dish['dish_id']}, Entry: {dish['menu_entry_id']})")
        
        # Scrape dish details with FRENCH language parameter
        details = scraper.scrape_dish_details(
            dish['crm_restaurant_id'], 
            dish['menu_entry_id'],
            language='fr'
        )
        
        if not details:
            result['error'] = 'No details scraped'
            logger.warning(f"  No details for dish {dish['dish_id']}")
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
        
        for modifier_group_data in details.get('modifiers', []):
            # Insert modifier group
            group_id = db.insert_modifier_group(
                dish_id=dish['dish_id'],
                name=modifier_group_data['name'],
                is_required=modifier_group_data.get('is_required', False),
                min_selections=modifier_group_data.get('min_selections', 0),
                max_selections=modifier_group_data.get('max_selections', 1),
                display_order=modifier_group_data.get('display_order', 0)
            )
            
            if group_id:
                modifier_groups_inserted += 1
                
                # Insert modifier items
                modifier_type = type_mapping.get(
                    modifier_group_data.get('type_code', ''), 
                    'other'
                )
                
                for item_data in modifier_group_data.get('items', []):
                    # Insert modifier item (without price)
                    item_id = db.insert_dish_modifier(
                        restaurant_id=dish['restaurant_id'],
                        dish_id=dish['dish_id'],
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
                            # Match price to size variant, or use "standard" if no sizes
                            if idx < len(size_variants):
                                size_var = size_variants[idx]
                            else:
                                size_var = 'standard'
                            
                            price_id = db.insert_dish_modifier_price(
                                dish_modifier_id=item_id,
                                dish_id=dish['dish_id'],
                                restaurant_id=dish['restaurant_id'],
                                size_variant=size_var,
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
        
        logger.info(f"  Success: {prices_inserted} prices, {modifier_groups_inserted} groups, {modifier_items_inserted} items, {modifier_prices_inserted} modifier prices")
        
    except Exception as e:
        result['error'] = str(e)
        logger.error(f"  Failed: {e}")
        import traceback
        traceback.print_exc()
    
    return result


def main():
    """Main batch scraping function for French restaurant prices and modifiers."""
    start_time = datetime.now()
    
    logger.info("=" * 60)
    logger.info("Batch Scraper - List 4 FRENCH Restaurants (Phase 2)")
    logger.info("=" * 60)
    
    # Get French restaurant IDs
    french_restaurant_ids = get_french_restaurant_ids()
    logger.info(f"French restaurants: {len(french_restaurant_ids)}")
    
    # Connect to database
    db = DatabaseManager()
    db.connect()
    logger.info("Database connected")
    
    # Get dishes to process (French restaurants only)
    dishes = get_dishes_to_process(db, french_restaurant_ids)
    logger.info(f"Found {len(dishes)} French dishes to process")
    
    # Load progress
    progress = load_progress()
    completed_dish_ids = set(progress.get('completed', []))
    failed_dish_ids = set(progress.get('failed', []))
    skipped_dish_ids = set(progress.get('skipped', []))
    
    # Filter out already processed
    remaining = [d for d in dishes if d['dish_id'] not in completed_dish_ids 
                 and d['dish_id'] not in failed_dish_ids
                 and d['dish_id'] not in skipped_dish_ids]
    
    logger.info(f"Already completed: {len(completed_dish_ids)}")
    logger.info(f"Previously failed: {len(failed_dish_ids)}")
    logger.info(f"Previously skipped: {len(skipped_dish_ids)}")
    logger.info(f"Remaining to process: {len(remaining)}")
    
    if not remaining:
        logger.info("All French dishes already processed!")
        db.close()
        return
    
    # Initialize scraper
    scraper = MenuScraper()
    scraper.start()
    logger.info("Scraper initialized and logged in")
    
    # Process dishes
    results = load_results()
    success_count = 0
    failed_count = 0
    skipped_count = 0
    current_restaurant_id = None
    
    try:
        for i, dish in enumerate(remaining, 1):
            # Ensure database connection periodically
            if i % 50 == 1:
                try:
                    db.ensure_connection()
                except Exception as e:
                    logger.error(f"Failed to ensure database connection: {e}")
                    time.sleep(5)
                    db.ensure_connection()
            
            # Log restaurant change
            if dish['restaurant_id'] != current_restaurant_id:
                current_restaurant_id = dish['restaurant_id']
                logger.info(f"\n{'='*60}")
                logger.info(f"Restaurant: {dish['restaurant_name']} (ID: {dish['restaurant_id']})")
                logger.info(f"{'='*60}")
            
            logger.info(f"[{i}/{len(remaining)}] Processing dish {dish['dish_id']}: {dish['dish_name']}")
            
            result = scrape_dish_prices_modifiers(db, scraper, dish)
            results.append(result)
            
            if result['success']:
                success_count += 1
                progress['completed'].append(dish['dish_id'])
            elif result.get('error') == 'No details scraped':
                skipped_count += 1
                progress['skipped'].append(dish['dish_id'])
            else:
                failed_count += 1
                progress['failed'].append(dish['dish_id'])
            
            # Save progress after each dish
            save_progress(progress)
            
            # Save results periodically
            if i % 10 == 0 or i == len(remaining):
                save_results(results)
            
            # Delay between dishes
            if i < len(remaining):
                time.sleep(DELAY_BETWEEN_DISHES)
    
    except KeyboardInterrupt:
        logger.info("\n\nScraping interrupted by user")
    except Exception as e:
        logger.error(f"\n\nProcess error: {e}")
        import traceback
        traceback.print_exc()
    finally:
        scraper.stop()
        db.close()
        logger.info("\nBrowser stopped")
        logger.info("Database connection closed")
    
    # Save final results
    save_results(results)
    
    # Summary
    end_time = datetime.now()
    duration = end_time - start_time
    
    total_prices = sum(r.get('prices_count', 0) for r in results)
    total_groups = sum(r.get('modifier_groups_count', 0) for r in results)
    total_items = sum(r.get('modifier_items_count', 0) for r in results)
    total_modifier_prices = sum(r.get('modifier_prices_count', 0) for r in results)
    
    total_completed = len(progress['completed'])
    total_failed = len(progress['failed'])
    total_skipped = len(progress['skipped'])
    total_processed = total_completed + total_failed + total_skipped
    
    logger.info("\n" + "=" * 60)
    logger.info("BATCH SCRAPING SUMMARY - FRENCH PRICES & MODIFIERS")
    logger.info("=" * 60)
    logger.info(f"Duration: {duration}")
    logger.info(f"Total French dishes: {len(dishes)}")
    logger.info(f"\nProgress Status:")
    logger.info(f"  Already completed: {len(completed_dish_ids)}")
    logger.info(f"  Previously failed: {len(failed_dish_ids)}")
    logger.info(f"  Previously skipped: {len(skipped_dish_ids)}")
    logger.info(f"  Processed this run: {len(results)}")
    logger.info(f"\nThis Run Results:")
    logger.info(f"  Successful: {success_count}")
    logger.info(f"  Skipped (no data): {skipped_count}")
    logger.info(f"  Failed: {failed_count}")
    logger.info(f"\nOverall Completion:")
    logger.info(f"  Total completed: {total_completed}")
    logger.info(f"  Total skipped: {total_skipped}")
    logger.info(f"  Total failed: {total_failed}")
    logger.info(f"  Total processed: {total_processed}/{len(dishes)} ({total_processed/len(dishes)*100:.1f}%)")
    logger.info(f"  Remaining: {len(dishes) - total_processed}")
    logger.info(f"\nData Inserted This Run:")
    logger.info(f"  Dish prices: {total_prices}")
    logger.info(f"  Modifier groups: {total_groups}")
    logger.info(f"  Modifier items: {total_items}")
    logger.info(f"  Modifier prices: {total_modifier_prices}")
    logger.info(f"\nFiles:")
    logger.info(f"  Results: {RESULTS_FILE}")
    logger.info(f"  Progress: {PROGRESS_FILE}")
    logger.info(f"  Log: batch_scrape_list4_prices_french.log")
    logger.info("=" * 60)


if __name__ == "__main__":
    main()

