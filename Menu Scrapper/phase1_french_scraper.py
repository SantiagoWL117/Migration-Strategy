#!/usr/bin/env python3
"""
Phase 1 French Menu Scraper
Scrapes courses, dishes, and prices for French-menu V2 restaurants
Target restaurants: Chicco Pizza de l'Hopital (966), Chicco Pizza Shawarma Anger (963)
"""
import os
import sys
import json
import logging
import psycopg2
import re
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
        logging.FileHandler('phase1_french_scraper.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# Target restaurants - V2 IDs will be discovered dynamically
RESTAURANTS = [
    {
        'name': 'La Nawab',
        'db_restaurant_id': 825,
        'v2_restaurant_id': None,  # Will be discovered
        'language': 'fr'
    },
    {
        'name': 'Cuisine Bombay Indienne',
        'db_restaurant_id': 960,
        'v2_restaurant_id': None,  # Will be discovered
        'language': 'fr'
    },
    {
        'name': 'Chicco Shawarma Cantley',
        'db_restaurant_id': 961,
        'v2_restaurant_id': None,  # Will be discovered
        'language': 'fr'
    },
    {
        'name': 'Chicco Pizza Maloney',
        'db_restaurant_id': 964,
        'v2_restaurant_id': None,  # Will be discovered
        'language': 'fr'
    },
    {
        'name': 'Chicco Shawarma Maloney',
        'db_restaurant_id': 965,
        'v2_restaurant_id': None,  # Will be discovered
        'language': 'fr'
    },
    {
        'name': 'Chicco Pizza St-Louis',
        'db_restaurant_id': 967,
        'v2_restaurant_id': None,  # Will be discovered
        'language': 'fr'
    },
    {
        'name': 'Pizza Marie',
        'db_restaurant_id': 976,
        'v2_restaurant_id': None,  # Will be discovered
        'language': 'fr'
    }
]

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

def discover_v2_restaurant_ids(scraper, restaurants):
    """
    Dynamically discover V2 restaurant IDs from the restaurant list page.
    
    Args:
        scraper: V2MenuScraper instance (must be logged in)
        restaurants: List of restaurant dictionaries with 'name' key
    
    Returns:
        Updated restaurants list with v2_restaurant_id populated
    """
    logger.info("\n" + "=" * 80)
    logger.info("DISCOVERING V2 RESTAURANT IDs")
    logger.info("=" * 80)
    
    try:
        # Navigate to restaurant list page
        list_url = f"{V2_BASE_URL}/index.php/restaurants/show/active"
        logger.info(f"Navigating to: {list_url}")
        scraper.page.goto(list_url, timeout=60000)
        scraper.page.wait_for_load_state('networkidle', timeout=30000)
        
        # Get page HTML
        html_content = scraper.page.content()
        soup = BeautifulSoup(html_content, 'lxml')
        
        # Find the restaurant table
        restaurant_table = soup.find('table', {'id': 'restaurantList'})
        if not restaurant_table:
            logger.error("Could not find restaurant list table (id='restaurantList')")
            return restaurants
        
        logger.info("✓ Restaurant list table found")
        
        # Parse each row to find our target restaurants
        rows = restaurant_table.find('tbody').find_all('tr') if restaurant_table.find('tbody') else restaurant_table.find_all('tr')
        
        logger.info(f"Found {len(rows)} restaurants in table")
        logger.info("\nSearching for target restaurants...")
        
        for restaurant in restaurants:
            target_name = restaurant['name']
            found = False
            
            for row in rows:
                # Get all <td> elements in the row
                cells = row.find_all('td')
                if len(cells) < 2:
                    continue
                
                # The restaurant name is typically in the second <td>
                restaurant_name_cell = cells[1] if len(cells) > 1 else None
                if not restaurant_name_cell:
                    continue
                
                restaurant_name = restaurant_name_cell.get_text(strip=True)
                
                # Check if this is our target restaurant
                if restaurant_name == target_name:
                    # Find the edit button link in the first <td>
                    edit_link = cells[0].find('a', href=True)
                    if edit_link:
                        # Extract V2 ID from URL: /restaurants/edit/{ID}/info
                        href = edit_link['href']
                        match = re.search(r'/restaurants/edit/(\d+)/info', href)
                        if match:
                            v2_id = int(match.group(1))
                            restaurant['v2_restaurant_id'] = v2_id
                            found = True
                            logger.info(f"  ✓ {target_name}")
                            logger.info(f"    V2 ID: {v2_id}")
                            logger.info(f"    Edit URL: {href}")
                            break
            
            if not found:
                logger.error(f"  ✗ {target_name} - NOT FOUND in restaurant list")
                logger.error(f"    This restaurant may not exist in the V2 system")
        
        # Summary
        logger.info("\n" + "-" * 80)
        discovered_count = sum(1 for r in restaurants if r['v2_restaurant_id'] is not None)
        logger.info(f"Discovery complete: {discovered_count}/{len(restaurants)} restaurants found")
        logger.info("=" * 80 + "\n")
        
        return restaurants
        
    except Exception as e:
        logger.error(f"Error discovering V2 IDs: {e}", exc_info=True)
        return restaurants

def insert_menu_data(menu_data):
    """
    Insert menu data into menuca_v3 database.
    
    Args:
        menu_data: Dictionary with structure:
        {
            'db_restaurant_id': 963,
            'v2_restaurant_id': 1660,
            'courses': [
                {
                    'name': 'Shawarmas',
                    'description': '',
                    'display_order': 0,
                    'v2_course_id': '1122',
                    'dishes': [
                        {
                            'name': 'Shawarma 6"',
                            'description': '',
                            'display_order': 0,
                            'v2_dish_id': '9000',
                            'prices': [
                                {'size_variant': 'Poulet', 'price': 7.99, 'display_order': 0},
                                {'size_variant': 'Boeuf', 'price': 7.99, 'display_order': 1}
                            ]
                        }
                    ]
                }
            ]
        }
    """
    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        restaurant_id = menu_data['db_restaurant_id']
        restaurant_name = next((r['name'] for r in RESTAURANTS if r['db_restaurant_id'] == restaurant_id), 'Unknown')
        
        logger.info(f"\n{'='*80}")
        logger.info(f"INSERTING DATA FOR: {restaurant_name} (ID: {restaurant_id})")
        logger.info(f"{'='*80}")
        
        total_courses = 0
        total_dishes = 0
        total_prices = 0
        
        for course_idx, course in enumerate(menu_data.get('courses', [])):
            # Insert course
            cur.execute("""
                INSERT INTO menuca_v3.courses 
                (restaurant_id, name, description, display_order, created_at, updated_at)
                VALUES (%s, %s, %s, %s, NOW(), NOW())
                RETURNING id
            """, (
                restaurant_id,
                course['name'],
                course.get('description', ''),
                course.get('display_order', course_idx)
            ))
            
            course_id = cur.fetchone()[0]
            total_courses += 1
            logger.info(f"  ✓ Course inserted: {course['name']} (ID: {course_id})")
            
            # Insert dishes for this course
            for dish_idx, dish in enumerate(course.get('dishes', [])):
                cur.execute("""
                    INSERT INTO menuca_v3.dishes 
                    (restaurant_id, course_id, name, description, display_order, source_id, created_at, updated_at)
                    VALUES (%s, %s, %s, %s, %s, %s, NOW(), NOW())
                    RETURNING id
                """, (
                    restaurant_id,
                    course_id,
                    dish['name'],
                    dish.get('description', ''),
                    dish.get('display_order', dish_idx),
                    dish.get('v2_dish_id', '')
                ))
                
                dish_id = cur.fetchone()[0]
                total_dishes += 1
                logger.info(f"    ✓ Dish inserted: {dish['name']} (ID: {dish_id})")
                
                # Insert prices for this dish
                for price_data in dish.get('prices', []):
                    cur.execute("""
                        INSERT INTO menuca_v3.dish_prices 
                        (dish_id, size_variant, price, display_order, created_at, updated_at)
                        VALUES (%s, %s, %s, %s, NOW(), NOW())
                    """, (
                        dish_id,
                        price_data['size_variant'],
                        price_data['price'],
                        price_data.get('display_order', 0)
                    ))
                    total_prices += 1
                
                if dish.get('prices'):
                    price_summary = ', '.join([f"{p['size_variant']}: ${p['price']}" for p in dish['prices']])
                    logger.info(f"      ✓ Prices inserted: {price_summary}")
        
        # Commit transaction
        conn.commit()
        
        logger.info(f"\n{'='*80}")
        logger.info(f"DATABASE INSERT COMPLETE: {restaurant_name}")
        logger.info(f"{'='*80}")
        logger.info(f"  Courses inserted: {total_courses}")
        logger.info(f"  Dishes inserted:  {total_dishes}")
        logger.info(f"  Prices inserted:  {total_prices}")
        logger.info(f"{'='*80}\n")
        
        return True
        
    except Exception as e:
        if conn:
            conn.rollback()
        logger.error(f"Database insertion error: {e}", exc_info=True)
        return False
        
    finally:
        if cur:
            cur.close()
        if conn:
            conn.close()

def scrape_phase1():
    """Scrape Phase 1 data for French-menu restaurants."""
    start_time = datetime.now()
    
    logger.info("=" * 80)
    logger.info("PHASE 1 FRENCH MENU SCRAPER")
    logger.info("=" * 80)
    logger.info("Target Restaurants:")
    for r in RESTAURANTS:
        logger.info(f"  - {r['name']} (DB ID: {r['db_restaurant_id']}, V2 ID: {r['v2_restaurant_id']})")
    logger.info("=" * 80)
    
    # Create output directory
    output_dir = Path(OUTPUT_DIR) / 'phase1_french_output'
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
    
    success_count = 0
    failure_count = 0
    
    try:
        scraper.start()
        logger.info("Browser started")
        
        if not scraper.login():
            logger.error("Login failed - cannot proceed")
            return
        logger.info("Login successful")
        
        # Discover V2 restaurant IDs dynamically
        restaurants_with_ids = discover_v2_restaurant_ids(scraper, RESTAURANTS)
        
        # Check if all restaurants were found
        missing_ids = [r for r in restaurants_with_ids if r['v2_restaurant_id'] is None]
        if missing_ids:
            logger.error("\n" + "=" * 80)
            logger.error("ERROR: Some restaurants could not be found in V2 system")
            logger.error("=" * 80)
            for r in missing_ids:
                logger.error(f"  - {r['name']} (DB ID: {r['db_restaurant_id']})")
            logger.error("=" * 80)
            logger.error("\nCannot proceed without V2 IDs. Please verify restaurant names.")
            return
        
        # Process each restaurant
        for idx, restaurant in enumerate(restaurants_with_ids, 1):
            logger.info("\n" + "=" * 80)
            logger.info(f"[{idx}/{len(RESTAURANTS)}] SCRAPING: {restaurant['name']}")
            logger.info("=" * 80)
            logger.info(f"DB ID: {restaurant['db_restaurant_id']}")
            logger.info(f"V2 ID: {restaurant['v2_restaurant_id']}")
            logger.info(f"Language: {restaurant['language']}")
            
            try:
                # Scrape menu data (language_id=2 for French)
                menu_data = scraper.scrape_restaurant_menu(
                    v2_restaurant_id=restaurant['v2_restaurant_id'],
                    db_restaurant_id=restaurant['db_restaurant_id'],
                    language_id=2
                )
                
                if not menu_data:
                    logger.error(f"✗ Failed to scrape menu for {restaurant['name']}")
                    failure_count += 1
                    continue
                
                # Count data
                course_count = len(menu_data.get('courses', []))
                dish_count = sum(len(course.get('dishes', [])) for course in menu_data.get('courses', []))
                price_count = sum(
                    len(dish.get('prices', []))
                    for course in menu_data.get('courses', [])
                    for dish in course.get('dishes', [])
                )
                
                logger.info(f"\n✓ SCRAPING COMPLETE:")
                logger.info(f"  Courses: {course_count}")
                logger.info(f"  Dishes:  {dish_count}")
                logger.info(f"  Prices:  {price_count}")
                
                # Save to JSON file
                output_file = output_dir / f"restaurant_{restaurant['v2_restaurant_id']}_menu.json"
                with open(output_file, 'w', encoding='utf-8') as f:
                    json.dump(menu_data, f, indent=2, ensure_ascii=False)
                
                logger.info(f"  JSON saved: {output_file.name}")
                
                # Insert into database
                logger.info(f"\nInserting data into database...")
                if insert_menu_data(menu_data):
                    logger.info(f"✓ Database insertion successful")
                    success_count += 1
                else:
                    logger.error(f"✗ Database insertion failed")
                    failure_count += 1
                
            except Exception as e:
                logger.error(f"✗ Error processing {restaurant['name']}: {e}", exc_info=True)
                failure_count += 1
        
        # Summary
        duration = datetime.now() - start_time
        logger.info("\n" + "=" * 80)
        logger.info("PHASE 1 FRENCH SCRAPER - FINAL SUMMARY")
        logger.info("=" * 80)
        logger.info(f"Duration: {duration}")
        logger.info(f"Successful: {success_count}/{len(RESTAURANTS)}")
        logger.info(f"Failed: {failure_count}/{len(RESTAURANTS)}")
        logger.info(f"Output directory: {output_dir}")
        logger.info(f"Log file: phase1_french_scraper.log")
        logger.info("=" * 80)
        
        if success_count == len(RESTAURANTS):
            logger.info("\n✓ ALL RESTAURANTS PROCESSED SUCCESSFULLY!")
            logger.info("\nNext step: Run Phase 2 scrapers for modifiers:")
            logger.info("  python scraper/V2 Scrapper/v2_scraper_phase2_fr.py")
        elif success_count > 0:
            logger.warning(f"\n⚠ PARTIAL SUCCESS: {success_count} succeeded, {failure_count} failed")
            logger.warning("Review logs and retry failed restaurants")
        else:
            logger.error("\n✗ ALL RESTAURANTS FAILED - Review logs for errors")
        
    except Exception as e:
        logger.error(f"Fatal error: {e}", exc_info=True)
    
    finally:
        if scraper:
            scraper.stop()
            logger.info("\nBrowser stopped")

if __name__ == "__main__":
    scrape_phase1()

