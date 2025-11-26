"""
Phase 2: Scrape Modifiers for 8 English Restaurants (CORRECTED V2 IDs)

This script scrapes ACTIVE modifier groups and modifiers for dishes that were scraped in Phase 1.

IMPORTANT: Only scrapes modifiers from panels with 'panel-success' class (active/enabled)
           Panels with 'panel-default' class are available but not active for the dish.

Restaurant Mapping (V3 ID -> V2 ID):
- Al's Drive In: 981 -> 1678
- Capital Bites: 973 -> 1670
- Cosenza: 957 -> 1654
- Kirkwood Pizza: 950 -> 1637
- Little Gyros Greek Grill: 971 -> 1668
- Pachino Pizza: 974 -> 1671
- River Pizza: 952 -> 1639
- Wandee Thai: 954 -> 1641
"""

import os
import sys
import time
import logging
from pathlib import Path
from datetime import datetime
from dotenv import load_dotenv
import psycopg2

# Add parent directory to path for imports
sys.path.append(str(Path(__file__).parent.parent))

from scraper.v2_scraper import V2MenuScraper

# Load environment
root_env = Path(__file__).parent.parent / '.env'
load_dotenv(dotenv_path=root_env)

DATABASE_URL = os.getenv('DB_CONNECTION_STRING')
# Remove trailing /index.php/ from CRM_BASE_URL if present
V2_BASE_URL = os.getenv("CRM_BASE_URL", "https://aggregator-admin.menu.ca").rstrip('/index.php/')
V2_USERNAME = os.getenv("CRM_USERNAME")
V2_PASSWORD = os.getenv("CRM_PASSWORD")

# Restaurant mappings (V3_ID -> V2_ID)
RESTAURANTS_TO_SCRAPE = [
    {'v3_id': 981, 'v2_id': 1678, 'name': "Al's Drive In"},
    {'v3_id': 973, 'v2_id': 1670, 'name': 'Capital Bites'},
    {'v3_id': 957, 'v2_id': 1654, 'name': 'Cosenza'},
    {'v3_id': 950, 'v2_id': 1637, 'name': 'Kirkwood Pizza'},
    {'v3_id': 971, 'v2_id': 1668, 'name': 'Little Gyros Greek Grill'},
    {'v3_id': 974, 'v2_id': 1671, 'name': 'Pachino Pizza'},
    {'v3_id': 952, 'v2_id': 1639, 'name': 'River Pizza'},
    {'v3_id': 954, 'v2_id': 1641, 'name': 'Wandee Thai'}
]

# Setup logging
log_dir = Path(__file__).parent / 'logs'
log_dir.mkdir(exist_ok=True)
timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
log_file = log_dir / f'phase2_english_corrected_{timestamp}.log'

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(log_file, encoding='utf-8'),
        logging.StreamHandler()
    ]
)

def get_db_connection():
    return psycopg2.connect(DATABASE_URL)

def get_dishes_for_restaurant(conn, v3_restaurant_id):
    """Get all dishes with their source_ids for a restaurant"""
    cur = conn.cursor()
    
    cur.execute("""
        SELECT 
            d.id as v3_dish_id,
            d.source_id as v2_dish_id,
            d.name as dish_name,
            c.name as course_name
        FROM menuca_v3.dishes d
        JOIN menuca_v3.courses c ON d.course_id = c.id
        WHERE d.restaurant_id = %s
        AND d.source_id IS NOT NULL
        ORDER BY c.id, d.id
    """, (v3_restaurant_id,))
    
    dishes = cur.fetchall()
    cur.close()
    
    return [
        {
            'v3_dish_id': row[0],
            'v2_dish_id': row[1],
            'dish_name': row[2],
            'course_name': row[3]
        }
        for row in dishes
    ]

def insert_modifier_group(conn, v3_dish_id, group_data):
    """Insert modifier group into V3 database"""
    cur = conn.cursor()
    
    cur.execute("""
        INSERT INTO menuca_v3.modifier_groups (
            dish_id, 
            name, 
            min_selections, 
            max_selections, 
            is_required
        )
        VALUES (%s, %s, %s, %s, %s)
        RETURNING id
    """, (
        v3_dish_id,
        group_data['name'],
        group_data.get('min_selections', 0),
        group_data.get('max_selections', 1),
        group_data.get('is_required', False)
    ))
    
    group_id = cur.fetchone()[0]
    conn.commit()
    cur.close()
    
    return group_id

def insert_modifier_with_prices(conn, v3_group_id, v3_dish_id, v3_restaurant_id, modifier_data):
    """Insert modifier and its prices into V3 database"""
    cur = conn.cursor()
    
    # Insert modifier
    cur.execute("""
        INSERT INTO menuca_v3.dish_modifiers (
            modifier_group_id,
            dish_id,
            restaurant_id,
            name,
            is_default
        )
        VALUES (%s, %s, %s, %s, %s)
        RETURNING id
    """, (
        v3_group_id,
        v3_dish_id,
        v3_restaurant_id,
        modifier_data['name'],
        modifier_data.get('is_default', False)
    ))
    
    modifier_id = cur.fetchone()[0]
    
    # Insert modifier prices if any
    prices = modifier_data.get('prices', [])
    if prices:
        for price in prices:
            if price > 0:  # Only insert non-zero prices
                cur.execute("""
                    INSERT INTO menuca_v3.dish_modifier_prices (
                        dish_modifier_id,
                        dish_id,
                        restaurant_id,
                        price
                    )
                    VALUES (%s, %s, %s, %s)
                """, (
                    modifier_id,
                    v3_dish_id,
                    v3_restaurant_id,
                    price
                ))
    
    conn.commit()
    cur.close()
    
    return modifier_id

def scrape_and_insert_modifiers(scraper, conn, restaurant_info):
    """Scrape modifiers for all dishes in a restaurant"""
    v3_id = restaurant_info['v3_id']
    v2_id = restaurant_info['v2_id']
    name = restaurant_info['name']
    
    logging.info(f"\n{'='*80}")
    logging.info(f"Phase 2: {name}")
    logging.info(f"V3 ID: {v3_id} | V2 ID: {v2_id}")
    logging.info(f"{'='*80}")
    
    try:
        # Get all dishes for this restaurant
        dishes = get_dishes_for_restaurant(conn, v3_id)
        
        if not dishes:
            logging.warning(f"  No dishes found for {name}")
            return {
                'success': True,
                'dishes_processed': 0,
                'groups_added': 0,
                'modifiers_added': 0
            }
        
        logging.info(f"  Found {len(dishes)} dishes to process")
        
        total_groups = 0
        total_modifiers = 0
        dishes_with_modifiers = 0
        
        # Process each dish
        for dish in dishes:
            v3_dish_id = dish['v3_dish_id']
            v2_dish_id = dish['v2_dish_id']
            dish_name = dish['dish_name']
            course_name = dish['course_name']
            
            logging.info(f"\n  Processing: {course_name} > {dish_name} (V2 Dish ID: {v2_dish_id})")
            
            # Scrape modifiers for this dish (language_id=1 for English)
            modifier_data = scraper.scrape_dish_details(
                v2_dish_id=v2_dish_id,
                v2_restaurant_id=v2_id,
                language_id=1
            )
            
            if not modifier_data or not modifier_data.get('modifier_groups'):
                logging.info(f"    No modifiers found")
                continue
            
            # Insert modifier groups and modifiers
            groups = modifier_data.get('modifier_groups', [])
            dishes_with_modifiers += 1
            
            for group_data in groups:
                # Insert group
                v3_group_id = insert_modifier_group(conn, v3_dish_id, group_data)
                total_groups += 1
                
                logging.info(f"    Group: {group_data['name']} (V3 ID: {v3_group_id})")
                
                # Insert modifiers in this group
                # V2MenuScraper returns 'items' not 'modifiers'
                for item in group_data.get('items', []):
                    # Convert item format to modifier format
                    modifier = {
                        'name': item['name'],
                        'prices': item.get('prices', []),
                        'is_default': item.get('is_default', False)
                    }
                    insert_modifier_with_prices(conn, v3_group_id, v3_dish_id, v3_id, modifier)
                    total_modifiers += 1
                    
                    # Log with first price if available
                    price_str = f"(+${modifier['prices'][0]})" if modifier.get('prices') and len(modifier['prices']) > 0 and modifier['prices'][0] > 0 else ""
                    logging.info(f"      - {modifier['name']} {price_str}")
        
        logging.info(f"\n  SUCCESS {name}:")
        logging.info(f"    Dishes processed: {len(dishes)}")
        logging.info(f"    Dishes with modifiers: {dishes_with_modifiers}")
        logging.info(f"    Modifier groups: {total_groups}")
        logging.info(f"    Modifiers: {total_modifiers}")
        
        return {
            'success': True,
            'dishes_processed': len(dishes),
            'dishes_with_modifiers': dishes_with_modifiers,
            'groups_added': total_groups,
            'modifiers_added': total_modifiers
        }
        
    except Exception as e:
        logging.error(f"  ERROR processing {name}: {e}")
        import traceback
        logging.error(traceback.format_exc())
        return {
            'success': False,
            'error': str(e),
            'dishes_processed': 0,
            'groups_added': 0,
            'modifiers_added': 0
        }

def main():
    logging.info("="*80)
    logging.info("PHASE 2: English Restaurants - Scrape Modifiers (CORRECTED V2 IDs)")
    logging.info("="*80)
    logging.info(f"\nRestaurants to process: {len(RESTAURANTS_TO_SCRAPE)}")
    for r in RESTAURANTS_TO_SCRAPE:
        logging.info(f"  - {r['name']} (V3: {r['v3_id']}, V2: {r['v2_id']})")
    
    # Initialize scraper
    scraper = V2MenuScraper(V2_BASE_URL, V2_USERNAME, V2_PASSWORD, headless=True)
    conn = None
    
    try:
        # Start browser
        scraper.start()
        
        # Login
        logging.info("\nLogging in...")
        if not scraper.login():
            logging.error("Login failed!")
            return
        
        # Connect to database
        conn = get_db_connection()
        
        # Track results
        results = []
        
        # Process each restaurant
        for restaurant in RESTAURANTS_TO_SCRAPE:
            result = scrape_and_insert_modifiers(scraper, conn, restaurant)
            results.append({
                'restaurant': restaurant['name'],
                **result
            })
            time.sleep(2)  # Be nice to the server
        
        # Summary
        logging.info("\n" + "="*80)
        logging.info("PHASE 2 COMPLETE - SUMMARY")
        logging.info("="*80)
        
        successful = [r for r in results if r['success']]
        failed = [r for r in results if not r['success']]
        
        total_dishes = sum(r['dishes_processed'] for r in successful)
        total_dishes_with_mods = sum(r['dishes_with_modifiers'] for r in successful)
        total_groups = sum(r['groups_added'] for r in successful)
        total_modifiers = sum(r['modifiers_added'] for r in successful)
        
        logging.info(f"\nSuccessful: {len(successful)}/{len(RESTAURANTS_TO_SCRAPE)}")
        for r in successful:
            logging.info(f"  + {r['restaurant']}: {r['dishes_processed']} dishes, "
                        f"{r['dishes_with_modifiers']} with modifiers, "
                        f"{r['groups_added']} groups, {r['modifiers_added']} modifiers")
        
        if failed:
            logging.info(f"\nFailed: {len(failed)}")
            for r in failed:
                logging.info(f"  - {r['restaurant']}: {r.get('error', 'Unknown error')}")
        
        logging.info(f"\n{'='*80}")
        logging.info("OVERALL TOTALS")
        logging.info(f"{'='*80}")
        logging.info(f"Total dishes processed: {total_dishes}")
        logging.info(f"Dishes with modifiers: {total_dishes_with_mods}")
        logging.info(f"Modifier groups added: {total_groups}")
        logging.info(f"Modifiers added: {total_modifiers}")
        logging.info(f"\nLog file: {log_file}")
        
    except Exception as e:
        logging.error(f"Fatal error: {e}")
        import traceback
        logging.error(traceback.format_exc())
    
    finally:
        if scraper:
            scraper.stop()
        if conn:
            conn.close()

if __name__ == "__main__":
    main()

