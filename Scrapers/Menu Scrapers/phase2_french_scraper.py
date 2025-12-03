#!/usr/bin/env python3
"""
Phase 2 French Menu Scraper
Scrapes modifiers and modifier prices for French-menu V2 restaurants
Target: All dishes that have been imported in Phase 1
"""
import os
import sys
import json
import logging
import psycopg2
import time
from pathlib import Path
from datetime import datetime
from dotenv import load_dotenv
from bs4 import BeautifulSoup

# Load .env file
env_path = Path(__file__).parent / 'V2 Scrapper' / '.env'
load_dotenv(dotenv_path=env_path)

# Verify environment variables
if not os.getenv('V2_USERNAME') or not os.getenv('V2_PASSWORD'):
    print("ERROR: V2_USERNAME and V2_PASSWORD not found in .env file")
    print(f"Looking for .env at: {env_path}")
    sys.exit(1)

from v2_scraper import V2MenuScraper
from v2_config import V2_BASE_URL, V2_USERNAME, V2_PASSWORD, OUTPUT_DIR

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('phase2_french_scraper.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# Database connection
DB_HOST = os.getenv('SUPABASE_DB_HOST', 'db.nthpbtdjhhnwfxqsxbvy.supabase.co')
DB_PORT = os.getenv('SUPABASE_DB_PORT', '5432')
DB_NAME = os.getenv('SUPABASE_DB_NAME', 'postgres')
DB_USER = os.getenv('SUPABASE_DB_USER', 'postgres')
DB_PASSWORD = os.getenv('SUPABASE_DB_PASSWORD', 'Gz35CPTom1RnsmGM')

def get_db_connection():
    """Get PostgreSQL database connection."""
    return psycopg2.connect(
        host=DB_HOST,
        port=DB_PORT,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD
    )

def get_french_restaurants():
    """Get all French-menu restaurants from the database that need Phase 2 scraping."""
    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        # Get restaurants that have dishes but might not have modifiers yet
        # Target all 10 restaurants specified by user
        cur.execute("""
            SELECT DISTINCT r.id, r.name
            FROM menuca_v3.restaurants r
            INNER JOIN menuca_v3.dishes d ON d.restaurant_id = r.id
            WHERE r.id IN (966, 964, 963, 967, 961, 965, 960, 825, 976, 1020)
            ORDER BY r.id
        """)
        
        restaurants = []
        for row in cur.fetchall():
            restaurants.append({
                'db_restaurant_id': row[0],
                'name': row[1],
                'language': 'fr'
            })
        
        cur.close()
        conn.close()
        
        return restaurants
        
    except Exception as e:
        logger.error(f"Error fetching restaurants: {e}", exc_info=True)
        if conn:
            conn.close()
        return []

def get_dishes_for_restaurant(restaurant_id):
    """
    Get all dishes for a restaurant that need modifier scraping.
    
    Returns:
        List of dicts with: dish_id, dish_name, source_id (V2 dish ID), course_name
    """
    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        cur.execute("""
            SELECT 
                d.id as dish_id,
                d.name as dish_name,
                d.source_id as v2_dish_id,
                c.name as course_name
            FROM menuca_v3.dishes d
            INNER JOIN menuca_v3.courses c ON c.id = d.course_id
            WHERE d.restaurant_id = %s
              AND d.source_id IS NOT NULL
            ORDER BY c.display_order, d.display_order
        """, (restaurant_id,))
        
        dishes = []
        for row in cur.fetchall():
            dishes.append({
                'dish_id': row[0],
                'dish_name': row[1],
                'v2_dish_id': row[2],
                'course_name': row[3]
            })
        
        cur.close()
        conn.close()
        
        return dishes
        
    except Exception as e:
        logger.error(f"Error fetching dishes: {e}", exc_info=True)
        if conn:
            conn.close()
        return []

def scrape_dish_modifiers(scraper, v2_restaurant_id, v2_dish_id, dish_name):
    """
    Scrape modifiers for a specific dish by opening its edit modal.
    
    Args:
        scraper: V2MenuScraper instance
        v2_restaurant_id: V2 restaurant ID
        v2_dish_id: V2 dish ID
        dish_name: Display name for logging
    
    Returns:
        List of modifier groups with structure:
        [
            {
                'name': 'Extras',
                'type_code': 'extra',
                'is_required': False,
                'min_selections': 1,
                'max_selections': 5,
                'free_selections': 0,
                'display_order': 9,
                'title_free': 'Extras',
                'title_paid': 'Extras',
                'items': [
                    {
                        'name': 'Ajouter une autre personne',
                        'price': 12.99,
                        'display_order': 0,
                        'is_default': False
                    }
                ]
            }
        ]
    """
    try:
        # Navigate to restaurant menu page first
        menu_url = f"{V2_BASE_URL}/index.php/restaurants/edit/{v2_restaurant_id}/menu/2/restaurant"
        logger.debug(f"    Navigating to menu page: {menu_url}")
        
        scraper.page.goto(menu_url, timeout=30000)
        
        # Wait for the page to fully load - wait for course listings
        try:
            scraper.page.wait_for_selector('.course-listing', timeout=10000)
            time.sleep(2)  # Extra wait for dynamic content
        except:
            logger.warning(f"    Timeout waiting for course listings to load")
        
        # Click the edit button for this dish
        # The edit button has: href="/ajax/restaurant_menu/edit_dish/{v2_dish_id}/..." data-dish="{v2_dish_id}"
        try:
            # First, use JavaScript to find and click the button (bypasses visibility checks)
            logger.debug(f"    Using JavaScript to click edit button for dish {v2_dish_id}")
            
            js_click = f"""
            () => {{
                const button = document.querySelector('a.edit_dish[data-dish="{v2_dish_id}"]');
                if (button) {{
                    button.click();
                    return true;
                }}
                return false;
            }}
            """
            
            result = scraper.page.evaluate(js_click)
            
            if not result:
                logger.error(f"    ✗ Could not find edit button for dish {v2_dish_id}")
                return []
            
            logger.debug(f"    ✓ Clicked edit button via JavaScript")
            
            # Wait for modal to open
            time.sleep(1.5)
            scraper.page.wait_for_selector('#mod_edit_dish', timeout=10000, state='attached')
            time.sleep(1.5)  # Extra wait for modal content to populate
            
        except Exception as e:
            logger.error(f"    ✗ Error clicking edit button or waiting for modal: {e}")
            return []
        
        # Parse HTML
        html = scraper.page.content()
        soup = BeautifulSoup(html, 'lxml')
        
        # Extract modifiers
        modifiers = []
        
        # Find the customization panel group
        customization_group = soup.find('div', id='group_dish_customization')
        if not customization_group:
            logger.debug(f"    No customization group found for dish {dish_name}")
            return []
        
        # Find all modifier type panels (extra, side_dish, drink, sauce, etc.)
        modifier_panels = customization_group.find_all('div', class_='panel', recursive=False)
        
        for panel in modifier_panels:
            # Get the panel-collapse div which has the type ID
            panel_collapse = panel.find('div', class_='panel-collapse')
            if not panel_collapse:
                continue
            
            type_code = panel_collapse.get('id', '')  # e.g., 'extra', 'side_dish', 'drink'
            if not type_code:
                continue
            
            # Check if this modifier type is enabled
            enabled_checkbox = panel.find('input', attrs={'name': f'customization[{type_code}][use]', 'type': 'checkbox'})
            if not enabled_checkbox or not enabled_checkbox.has_attr('checked'):
                logger.debug(f"    Modifier type '{type_code}' is not enabled, skipping")
                continue
            
            # Extract configuration
            min_input = panel.find('input', attrs={'name': f'customization[{type_code}][min]'})
            max_input = panel.find('input', attrs={'name': f'customization[{type_code}][max]'})
            free_input = panel.find('input', attrs={'name': f'customization[{type_code}][free]'})
            display_input = panel.find('input', attrs={'name': f'customization[{type_code}][display_order]'})
            title_free_input = panel.find('input', attrs={'name': f'customization[{type_code}][title_free]'})
            title_paid_input = panel.find('input', attrs={'name': f'customization[{type_code}][title_paid]'})
            
            min_selections = int(min_input.get('value', 0)) if min_input else 0
            max_selections = int(max_input.get('value', 1)) if max_input else 1
            free_selections = int(free_input.get('value', 0)) if free_input else 0
            display_order = int(display_input.get('value', 0)) if display_input else 0
            
            title_free = title_free_input.get('value', '') if title_free_input else type_code.replace('_', ' ').title()
            title_paid = title_paid_input.get('value', '') if title_paid_input else type_code.replace('_', ' ').title()
            
            # Use title_paid as the main name
            modifier_name = title_paid if title_paid else title_free
            
            modifier_group = {
                'name': modifier_name,
                'type_code': type_code,
                'is_required': min_selections > 0,
                'min_selections': min_selections,
                'max_selections': max_selections,
                'free_selections': free_selections,
                'display_order': display_order,
                'title_free': title_free,
                'title_paid': title_paid,
                'items': []
            }
            
            # Find the selected group (checked radio button)
            selected_group_radio = panel.find('input', attrs={
                'name': f'customization[{type_code}][group]',
                'type': 'radio',
                'checked': True
            })
            
            if not selected_group_radio:
                logger.debug(f"    No selected group found for modifier type '{type_code}'")
                continue
            
            group_id = selected_group_radio.get('value')
            if not group_id:
                continue
            
            logger.debug(f"    Found modifier group '{modifier_name}' (type: {type_code}, group ID: {group_id})")
            
            # Find all modifier items in this group
            # Items are input fields with name pattern: item[{group_id}][hash]
            item_inputs = panel.find_all('input', attrs={'name': lambda x: x and x.startswith(f'item[{group_id}]')})
            
            for idx, item_input in enumerate(item_inputs):
                item_id = item_input.get('id', '')
                
                # Find the label for this item
                item_label = panel.find('label', attrs={'for': item_id})
                item_name = item_label.get_text(strip=True) if item_label else f'Item {idx}'
                
                # Get price
                try:
                    item_price = float(item_input.get('value', '0'))
                except (ValueError, TypeError):
                    item_price = 0.0
                
                # V2 doesn't have default item markers in this structure
                is_default = False
                
                modifier_group['items'].append({
                    'name': item_name,
                    'price': item_price,
                    'display_order': idx,
                    'is_default': is_default
                })
            
            if modifier_group['items']:
                logger.debug(f"    ✓ Extracted {len(modifier_group['items'])} items for '{modifier_name}'")
                modifiers.append(modifier_group)
        
        return modifiers
        
    except Exception as e:
        logger.error(f"    ✗ Error scraping modifiers for dish {v2_dish_id} ({dish_name}): {e}", exc_info=True)
        return []

def insert_modifier_data(restaurant_id, dish_id, dish_name, modifiers):
    """
    Insert modifier data into menuca_v3 database.
    
    Args:
        restaurant_id: menuca_v3 restaurant ID
        dish_id: menuca_v3 dish ID
        dish_name: Dish name (for logging)
        modifiers: List of modifier group dictionaries
    
    Returns:
        True if successful, False otherwise
    """
    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        total_groups = 0
        total_items = 0
        
        for modifier_group in modifiers:
            # Insert modifier group
            cur.execute("""
                INSERT INTO menuca_v3.modifier_groups 
                (dish_id, name, is_required, min_selections, max_selections, 
                 display_order, created_at, updated_at)
                VALUES (%s, %s, %s, %s, %s, %s, NOW(), NOW())
                RETURNING id
            """, (
                dish_id,
                modifier_group['name'],
                modifier_group['is_required'],
                modifier_group['min_selections'],
                modifier_group['max_selections'],
                modifier_group['display_order']
            ))
            
            modifier_group_id = cur.fetchone()[0]
            total_groups += 1
            
            # Insert modifier items (dish_modifiers table)
            for item in modifier_group['items']:
                # Map V2 type_code to valid modifier_type values
                # Valid values: custom_ingredients, extras, side_dishes, drinks, sauces, bread, dressing, cooking_method, other
                type_code_map = {
                    'extra': 'extras',
                    'side_dish': 'side_dishes',
                    'drink': 'drinks',
                    'sauce': 'sauces',
                    'bread': 'bread',
                    'dressing': 'dressing',
                    'cooking_method': 'cooking_method'
                }
                modifier_type = type_code_map.get(modifier_group['type_code'], 'other')
                
                # First, insert the dish_modifier record
                cur.execute("""
                    INSERT INTO menuca_v3.dish_modifiers 
                    (restaurant_id, dish_id, modifier_group_id, name, modifier_type, 
                     display_order, is_default, source_system, created_at, updated_at)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, NOW(), NOW())
                    RETURNING id
                """, (
                    restaurant_id,
                    dish_id,
                    modifier_group_id,
                    item['name'],
                    modifier_type,
                    item['display_order'],
                    item.get('is_default', False),
                    'v2'
                ))
                
                dish_modifier_id = cur.fetchone()[0]
                
                # Then, insert the price for this modifier item
                cur.execute("""
                    INSERT INTO menuca_v3.dish_modifier_prices 
                    (dish_modifier_id, dish_id, restaurant_id, price, 
                     display_order, source_system, created_at, updated_at)
                    VALUES (%s, %s, %s, %s, %s, %s, NOW(), NOW())
                """, (
                    dish_modifier_id,
                    dish_id,
                    restaurant_id,
                    item['price'],
                    item['display_order'],
                    'v2'
                ))
                
                total_items += 1
        
        # Commit transaction
        conn.commit()
        
        logger.info(f"      ✓ Inserted {total_groups} modifier groups, {total_items} items")
        
        cur.close()
        conn.close()
        
        return True
        
    except Exception as e:
        if conn:
            conn.rollback()
            conn.close()
        logger.error(f"      ✗ Database insertion error: {e}", exc_info=True)
        return False

def scrape_phase2():
    """Scrape Phase 2 data (modifiers) for French-menu restaurants."""
    start_time = datetime.now()
    
    logger.info("=" * 80)
    logger.info("PHASE 2 FRENCH MENU SCRAPER (MODIFIERS)")
    logger.info("=" * 80)
    
    # Get restaurants to process
    restaurants = get_french_restaurants()
    
    if not restaurants:
        logger.error("No French restaurants found to process")
        return
    
    logger.info("Target Restaurants:")
    for r in restaurants:
        logger.info(f"  - {r['name']} (DB ID: {r['db_restaurant_id']})")
    logger.info("=" * 80)
    
    # Create output directory
    output_dir = Path(OUTPUT_DIR) / 'phase2_french_output'
    output_dir.mkdir(parents=True, exist_ok=True)
    logger.info(f"Output directory: {output_dir}")
    
    # Initialize scraper
    logger.info("\nInitializing scraper...")
    scraper = V2MenuScraper(
        base_url=V2_BASE_URL,
        username=V2_USERNAME,
        password=V2_PASSWORD,
        headless=False  # Set to True for production
    )
    
    total_success = 0
    total_failure = 0
    total_dishes_processed = 0
    total_modifiers_found = 0
    
    try:
        scraper.start()
        logger.info("Browser started")
        
        if not scraper.login():
            logger.error("Login failed - cannot proceed")
            return
        logger.info("Login successful")
        
        # We need to discover V2 IDs again since we're working from the database
        # Let's get them from the source_id field in the dishes table
        
        # Process each restaurant
        for idx, restaurant in enumerate(restaurants, 1):
            logger.info("\n" + "=" * 80)
            logger.info(f"[{idx}/{len(restaurants)}] PROCESSING: {restaurant['name']}")
            logger.info("=" * 80)
            logger.info(f"DB ID: {restaurant['db_restaurant_id']}")
            
            # Get dishes for this restaurant
            dishes = get_dishes_for_restaurant(restaurant['db_restaurant_id'])
            
            if not dishes:
                logger.warning(f"No dishes found for {restaurant['name']}")
                continue
            
            logger.info(f"Found {len(dishes)} dishes to process")
            
            # V2 restaurant ID mapping (discovered from V2 system on 2025-11-18)
            v2_restaurant_id_map = {
                825: 1642,  # La Nawab
                960: 1657,  # Cuisine Bombay Indienne
                961: 1658,  # Chicco Shawarma Cantley
                963: 1660,  # Chicco Pizza Shawarma Anger
                964: 1661,  # Chicco Pizza Maloney
                965: 1662,  # Chicco Shawarma Maloney
                966: 1663,  # Chicco Pizza de l'Hopital
                967: 1664,  # Chicco Pizza St-Louis
                976: 1673,  # Pizza Marie
                1020: 1285  # Sushi Presse
            }
            
            v2_restaurant_id = v2_restaurant_id_map.get(restaurant['db_restaurant_id'])
            if not v2_restaurant_id:
                logger.error(f"Could not determine V2 restaurant ID for {restaurant['name']}")
                continue
            
            logger.info(f"V2 Restaurant ID: {v2_restaurant_id}")
            
            # Store all modifier data for JSON output
            restaurant_modifiers = []
            
            # Process each dish
            dishes_success = 0
            dishes_failure = 0
            
            for dish_idx, dish in enumerate(dishes, 1):
                logger.info(f"\n  [{dish_idx}/{len(dishes)}] {dish['dish_name']} (Course: {dish['course_name']})")
                logger.info(f"    DB Dish ID: {dish['dish_id']}, V2 Dish ID: {dish['v2_dish_id']}")
                
                try:
                    # Scrape modifiers for this dish
                    modifiers = scrape_dish_modifiers(
                        scraper,
                        v2_restaurant_id,
                        dish['v2_dish_id'],
                        dish['dish_name']
                    )
                    
                    if not modifiers:
                        logger.info(f"    No modifiers found for this dish")
                        dishes_success += 1  # Not an error, just no modifiers
                        continue
                    
                    logger.info(f"    ✓ Found {len(modifiers)} modifier groups")
                    
                    # Store for JSON
                    restaurant_modifiers.append({
                        'dish_id': dish['dish_id'],
                        'dish_name': dish['dish_name'],
                        'v2_dish_id': dish['v2_dish_id'],
                        'modifiers': modifiers
                    })
                    
                    # Insert into database
                    if insert_modifier_data(restaurant['db_restaurant_id'], dish['dish_id'], dish['dish_name'], modifiers):
                        dishes_success += 1
                        total_modifiers_found += len(modifiers)
                    else:
                        dishes_failure += 1
                    
                    # Small delay between dishes
                    time.sleep(0.5)
                    
                except Exception as e:
                    logger.error(f"    ✗ Error processing dish: {e}", exc_info=True)
                    dishes_failure += 1
            
            # Save JSON output for this restaurant
            output_file = output_dir / f"restaurant_{restaurant['db_restaurant_id']}_modifiers.json"
            with open(output_file, 'w', encoding='utf-8') as f:
                json.dump(restaurant_modifiers, f, indent=2, ensure_ascii=False)
            
            logger.info(f"\n✓ Restaurant complete: {dishes_success} succeeded, {dishes_failure} failed")
            logger.info(f"  JSON saved: {output_file.name}")
            
            total_dishes_processed += len(dishes)
            total_success += dishes_success
            total_failure += dishes_failure
        
        # Summary
        duration = datetime.now() - start_time
        logger.info("\n" + "=" * 80)
        logger.info("PHASE 2 FRENCH SCRAPER - FINAL SUMMARY")
        logger.info("=" * 80)
        logger.info(f"Duration: {duration}")
        logger.info(f"Restaurants processed: {len(restaurants)}")
        logger.info(f"Total dishes processed: {total_dishes_processed}")
        logger.info(f"Successful: {total_success}")
        logger.info(f"Failed: {total_failure}")
        logger.info(f"Total modifier groups found: {total_modifiers_found}")
        logger.info(f"Output directory: {output_dir}")
        logger.info(f"Log file: phase2_french_scraper.log")
        logger.info("=" * 80)
        
        if total_failure == 0:
            logger.info("\n✓ ALL DISHES PROCESSED SUCCESSFULLY!")
        elif total_success > 0:
            logger.warning(f"\n⚠ PARTIAL SUCCESS: {total_success} succeeded, {total_failure} failed")
        else:
            logger.error("\n✗ ALL DISHES FAILED - Review logs for errors")
        
    except Exception as e:
        logger.error(f"Fatal error: {e}", exc_info=True)
    
    finally:
        if scraper:
            scraper.stop()
            logger.info("\nBrowser stopped")

if __name__ == "__main__":
    scrape_phase2()

