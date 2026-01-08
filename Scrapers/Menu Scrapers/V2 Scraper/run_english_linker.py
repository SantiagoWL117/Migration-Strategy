"""
Run V2 Combo Dish Linker for all English restaurants.

Restaurants:
- Al's Drive In (981 / 1678)
- Capital Bites (973 / 1670)
- Capri Pizza (977 / 1674)
- Cosenza (957 / 1654)
- Cuisine Bombay Indienne (960 / 1657)
- Kirkwood Pizza (950 / 1637)
- Little Gyros Greek Grill (971 / 1668)
- Pachino Pizza (974 / 1671)
- Pho Dau Bo Restaurant (147 / 1171)
- Pizza Marie (976 / 1673)
- River Pizza (952 / 1639)
- Sushi Presse (1020 / 1285)
- Wandee Thai (954 / 1641)
"""

import asyncio
import json
import logging
from datetime import datetime
from pathlib import Path
from typing import List, Dict

from v2_combo_dish_linker import run_scraper, setup_logging


async def run_all_english():
    """Run combo dish linker for all English restaurants."""
    
    # Load English restaurants from JSON
    json_file = Path(__file__).parent / 'v2_restaurants_english.json'
    with open(json_file, 'r', encoding='utf-8') as f:
        restaurants = json.load(f)
    
    # Setup logging
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    log_dir = Path(__file__).parent / 'logs'
    log_file = log_dir / f'combo_dish_linker_english_{timestamp}.log'
    setup_logging(str(log_file))
    
    logger = logging.getLogger('run_english')
    logger.info(f"Starting V2 Combo Dish Linker for {len(restaurants)} English restaurants")
    
    # Track results
    all_stats: List[Dict] = []
    
    for restaurant in restaurants:
        restaurant_id = restaurant['db_restaurant_id']
        v2_id = restaurant['v2_restaurant_id']
        name = restaurant['name']
        
        logger.info("=" * 60)
        logger.info(f"Processing: {name}")
        logger.info(f"  V3 ID: {restaurant_id}, V2 ID: {v2_id}")
        logger.info("=" * 60)
        
        try:
            stats = await run_scraper(restaurant_id, v2_id, 'en', name)
            stats['restaurant'] = name
            stats['restaurant_id'] = restaurant_id
            all_stats.append(stats)
            
            logger.info(f"  Completed: {stats['links_created']} links created, {stats['errors']} errors")
        except Exception as e:
            logger.error(f"  FAILED: {e}")
            all_stats.append({
                'restaurant': name,
                'restaurant_id': restaurant_id,
                'error': str(e)
            })
            
        # Small delay between restaurants
        await asyncio.sleep(1)
    
    # Print final summary
    print("\n" + "=" * 80)
    print("ENGLISH RESTAURANTS - FINAL SUMMARY")
    print("=" * 80)
    
    total_links = 0
    total_errors = 0
    
    for stats in all_stats:
        name = stats.get('restaurant', 'Unknown')
        if 'error' in stats:
            print(f"  ❌ {name}: FAILED - {stats['error']}")
            total_errors += 1
        else:
            links = stats.get('links_created', 0)
            errors = stats.get('errors', 0)
            combos = stats.get('combo_dishes', 0)
            total_links += links
            total_errors += errors
            print(f"  ✅ {name}: {combos} combo dishes, {links} links created, {errors} errors")
    
    print("-" * 80)
    print(f"TOTAL: {total_links} links created, {total_errors} errors")
    print(f"Log file: {log_file}")
    print("=" * 80)
    
    return all_stats


if __name__ == '__main__':
    asyncio.run(run_all_english())



