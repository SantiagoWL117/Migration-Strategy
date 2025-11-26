"""
Phase 1: Scrape Menu Structure for 8 English Restaurants (CORRECTED V2 IDs)

This script scrapes courses, dishes, and dish prices from the V2 admin panel
for 8 English restaurants using their CORRECT V2 IDs.

Capri Pizza is excluded as it already has valid data.

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
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options

# Load environment
root_env = Path(__file__).parent.parent / '.env'
load_dotenv(dotenv_path=root_env)
DATABASE_URL = os.getenv('DB_CONNECTION_STRING')

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
log_file = log_dir / f'phase1_english_corrected_{timestamp}.log'

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

def setup_driver():
    """Setup Chrome driver"""
    chrome_options = Options()
    chrome_options.add_argument('--headless')
    chrome_options.add_argument('--disable-gpu')
    chrome_options.add_argument('--no-sandbox')
    chrome_options.add_argument('--disable-dev-shm-usage')
    chrome_options.add_argument('--window-size=1920,1080')
    return webdriver.Chrome(options=chrome_options)

def login_to_admin(driver):
    """Login to the admin panel"""
    logging.info("Logging into admin panel...")
    
    driver.get("https://aggregator-admin.menu.ca/index.php/dashboard/login")
    
    # Wait for page to load
    wait = WebDriverWait(driver, 10)
    
    # Wait for username field to be present
    username = wait.until(EC.presence_of_element_located((By.NAME, "username")))
    password = driver.find_element(By.NAME, "password")
    
    username.send_keys(os.getenv('ADMIN_USERNAME'))
    password.send_keys(os.getenv('ADMIN_PASSWORD'))
    
    # Submit
    login_button = driver.find_element(By.CSS_SELECTOR, "button[type='submit']")
    login_button.click()
    time.sleep(3)
    
    logging.info("Login successful")

def detect_menu_format(driver):
    """Detect if menu is English or French format"""
    try:
        # Look for English format indicators
        english_indicators = driver.find_elements(By.CSS_SELECTOR, "th.dish-name, th.dish-desc, th.dish-size, th.dish-price")
        
        if len(english_indicators) >= 3:
            logging.info("  Detected: ENGLISH menu format")
            return 'english'
        
        # Look for French format indicators  
        french_indicators = driver.find_elements(By.CSS_SELECTOR, "input[name^='dish_name_'], input[name^='dish_description_']")
        
        if len(french_indicators) > 0:
            logging.info("  Detected: FRENCH menu format")
            return 'french'
        
        logging.warning("  Could not detect menu format - defaulting to English")
        return 'english'
        
    except Exception as e:
        logging.error(f"  Error detecting format: {e}")
        return 'english'

def scrape_courses_english(driver, v2_restaurant_id):
    """Scrape courses for English format menu"""
    logging.info(f"  Scraping courses (V2 ID: {v2_restaurant_id})...")
    
    # Navigate to menu page
    menu_url = f"https://aggregator-admin.menu.ca/index.php/restaurants/edit/{v2_restaurant_id}/menu/restaurant"
    driver.get(menu_url)
    time.sleep(3)
    
    # Detect format
    menu_format = detect_menu_format(driver)
    
    if menu_format != 'english':
        raise Exception(f"Expected English format but detected {menu_format}")
    
    courses = []
    
    # Find all course widgets
    course_widgets = driver.find_elements(By.CSS_SELECTOR, "div.course-listing")
    logging.info(f"  Found {len(course_widgets)} courses")
    
    for widget in course_widgets:
        try:
            course_id = widget.get_attribute('data-id')
            course_name = widget.get_attribute('data-course')
            
            if not course_id or not course_name:
                continue
            
            # Get course description if available
            try:
                desc_textarea = widget.find_element(By.CSS_SELECTOR, f"textarea[id*='course_desc_{course_id}']")
                description = desc_textarea.get_attribute('value') or ''
            except:
                description = ''
            
            courses.append({
                'source_id': int(course_id),
                'name': course_name.strip(),
                'description': description.strip()
            })
            
            logging.info(f"    Course: {course_name} (ID: {course_id})")
            
        except Exception as e:
            logging.error(f"    Error parsing course: {e}")
            continue
    
    return courses

def scrape_dishes_for_course_english(driver, v2_restaurant_id, course_source_id):
    """Scrape dishes for a specific course (English format)"""
    dishes = []
    
    try:
        # Find the table for this course
        table = driver.find_element(By.CSS_SELECTOR, f"table#table_{course_source_id}")
        rows = table.find_elements(By.CSS_SELECTOR, "tbody tr.sort")
        
        logging.info(f"    Found {len(rows)} dishes in course {course_source_id}")
        
        for row in rows:
            try:
                dish_id = row.get_attribute('data-id')
                
                if not dish_id:
                    continue
                
                # Get dish details from input fields
                name_input = row.find_element(By.CSS_SELECTOR, f"input[name='name[{dish_id}]']")
                desc_input = row.find_element(By.CSS_SELECTOR, f"input[name='desc[{dish_id}]']")
                size_input = row.find_element(By.CSS_SELECTOR, f"input[name='size[{dish_id}]']")
                price_input = row.find_element(By.CSS_SELECTOR, f"input[name='price[{dish_id}]']")
                
                dish_name = name_input.get_attribute('value') or ''
                dish_desc = desc_input.get_attribute('value') or ''
                size_value = size_input.get_attribute('value') or ''
                price_value = price_input.get_attribute('value') or ''
                
                # Parse sizes and prices
                sizes = [s.strip() for s in size_value.split(',') if s.strip()] if size_value else []
                prices = [p.strip() for p in price_value.split(',') if p.strip()] if price_value else []
                
                # Create dish prices list
                dish_prices = []
                if len(sizes) > 0 and len(sizes) == len(prices):
                    # Multiple sizes
                    for size, price in zip(sizes, prices):
                        dish_prices.append({
                            'size_variant': size,
                            'price': float(price)
                        })
                elif len(prices) > 0:
                    # Single price (no size or size mismatch)
                    dish_prices.append({
                        'size_variant': sizes[0] if sizes else None,
                        'price': float(prices[0])
                    })
                
                dishes.append({
                    'source_id': int(dish_id),
                    'name': dish_name.strip(),
                    'description': dish_desc.strip(),
                    'prices': dish_prices
                })
                
                logging.info(f"      Dish: {dish_name} ({len(dish_prices)} prices)")
                
            except Exception as e:
                logging.error(f"      Error parsing dish {dish_id}: {e}")
                continue
        
    except Exception as e:
        logging.error(f"    Error finding dishes for course {course_source_id}: {e}")
    
    return dishes

def insert_course(conn, v3_restaurant_id, course_data):
    """Insert course into V3 database"""
    cur = conn.cursor()
    
    cur.execute("""
        INSERT INTO menuca_v3.courses (restaurant_id, name, description, source_id)
        VALUES (%s, %s, %s, %s)
        RETURNING id
    """, (
        v3_restaurant_id,
        course_data['name'],
        course_data['description'],
        course_data['source_id']
    ))
    
    course_id = cur.fetchone()[0]
    conn.commit()
    cur.close()
    
    return course_id

def insert_dish(conn, v3_restaurant_id, v3_course_id, dish_data):
    """Insert dish and its prices into V3 database"""
    cur = conn.cursor()
    
    # Insert dish
    cur.execute("""
        INSERT INTO menuca_v3.dishes (restaurant_id, course_id, name, description, source_id)
        VALUES (%s, %s, %s, %s, %s)
        RETURNING id
    """, (
        v3_restaurant_id,
        v3_course_id,
        dish_data['name'],
        dish_data['description'],
        dish_data['source_id']
    ))
    
    dish_id = cur.fetchone()[0]
    
    # Insert dish prices
    for price_data in dish_data['prices']:
        cur.execute("""
            INSERT INTO menuca_v3.dish_prices (dish_id, price, size_variant)
            VALUES (%s, %s, %s)
        """, (
            dish_id,
            price_data['price'],
            price_data['size_variant']
        ))
    
    conn.commit()
    cur.close()
    
    return dish_id

def scrape_restaurant(driver, conn, restaurant_info):
    """Scrape a single restaurant"""
    v3_id = restaurant_info['v3_id']
    v2_id = restaurant_info['v2_id']
    name = restaurant_info['name']
    
    logging.info(f"\n{'='*80}")
    logging.info(f"Scraping: {name}")
    logging.info(f"V3 ID: {v3_id} | V2 ID: {v2_id}")
    logging.info(f"{'='*80}")
    
    try:
        # Scrape courses
        courses = scrape_courses_english(driver, v2_id)
        
        if not courses:
            logging.warning(f"  No courses found for {name}")
            return {'success': False, 'error': 'No courses found'}
        
        total_dishes = 0
        total_prices = 0
        
        # Process each course
        for course_data in courses:
            # Insert course
            v3_course_id = insert_course(conn, v3_id, course_data)
            logging.info(f"    Inserted course: {course_data['name']} (V3 ID: {v3_course_id})")
            
            # Scrape dishes for this course
            dishes = scrape_dishes_for_course_english(driver, v2_id, course_data['source_id'])
            
            # Insert dishes
            for dish_data in dishes:
                insert_dish(conn, v3_id, v3_course_id, dish_data)
                total_dishes += 1
                total_prices += len(dish_data['prices'])
        
        logging.info(f"\n  ✓ {name} Complete:")
        logging.info(f"    Courses: {len(courses)}")
        logging.info(f"    Dishes: {total_dishes}")
        logging.info(f"    Prices: {total_prices}")
        
        return {
            'success': True,
            'courses': len(courses),
            'dishes': total_dishes,
            'prices': total_prices
        }
        
    except Exception as e:
        logging.error(f"  ✗ Error scraping {name}: {e}")
        import traceback
        logging.error(traceback.format_exc())
        return {'success': False, 'error': str(e)}

def main():
    logging.info("="*80)
    logging.info("PHASE 1: English Restaurants - CORRECTED V2 IDs")
    logging.info("="*80)
    logging.info(f"\nRestaurants to scrape: {len(RESTAURANTS_TO_SCRAPE)}")
    for r in RESTAURANTS_TO_SCRAPE:
        logging.info(f"  - {r['name']} (V3: {r['v3_id']}, V2: {r['v2_id']})")
    
    driver = None
    conn = None
    
    try:
        # Setup
        driver = setup_driver()
        conn = get_db_connection()
        
        # Login
        login_to_admin(driver)
        
        # Track results
        results = []
        
        # Scrape each restaurant
        for restaurant in RESTAURANTS_TO_SCRAPE:
            result = scrape_restaurant(driver, conn, restaurant)
            results.append({
                'restaurant': restaurant['name'],
                **result
            })
            time.sleep(2)  # Be nice to the server
        
        # Summary
        logging.info("\n" + "="*80)
        logging.info("PHASE 1 COMPLETE - SUMMARY")
        logging.info("="*80)
        
        successful = [r for r in results if r['success']]
        failed = [r for r in results if not r['success']]
        
        logging.info(f"\nSuccessful: {len(successful)}/{len(RESTAURANTS_TO_SCRAPE)}")
        for r in successful:
            logging.info(f"  ✓ {r['restaurant']}: {r['courses']} courses, {r['dishes']} dishes, {r['prices']} prices")
        
        if failed:
            logging.info(f"\nFailed: {len(failed)}")
            for r in failed:
                logging.info(f"  ✗ {r['restaurant']}: {r.get('error', 'Unknown error')}")
        
        logging.info(f"\nLog file: {log_file}")
        
    except Exception as e:
        logging.error(f"Fatal error: {e}")
        import traceback
        logging.error(traceback.format_exc())
    
    finally:
        if driver:
            driver.quit()
        if conn:
            conn.close()

if __name__ == "__main__":
    main()

