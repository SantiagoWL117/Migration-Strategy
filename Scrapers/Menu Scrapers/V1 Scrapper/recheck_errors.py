"""
Re-check the 7 restaurants that had network errors
"""

import asyncio
import logging
from datetime import datetime
from pathlib import Path
from playwright.async_api import async_playwright

# Configuration
CRM_BASE_URL = "https://menuadmin.menu.ca"
CRM_USERNAME = "santiago@worklocal.ca"
CRM_PASSWORD = "542sfgsgeerg4%$"

# Error restaurants to re-check
ERROR_RESTAURANTS = [
    (727, "La Maison du Burger", 965),
    (721, "La Maison Pho", 959),
    (715, "La Poutinerie Ogilvie", 952),
    (756, "Little Gyros Greek Grill", 998),
    (1011, "Mozza Pizza Gatineau", 132),
    (644, "Mozza Pizza Hull", 872),
    (47, "Mr Mozzarella - Nepean", 145),
]

# Setup logging
script_dir = Path(__file__).parent
log_dir = script_dir / "logs"
log_dir.mkdir(exist_ok=True)

timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
log_file = log_dir / f"recheck_errors_{timestamp}.log"

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(log_file, encoding='utf-8'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)


async def check_menu_language(page, v3_id: int, name: str, v1_id: int) -> str:
    """Check if a restaurant has an English or French menu."""
    import re
    
    url = f"{CRM_BASE_URL}/?p=restaurants&display=editRestaurant&restaurant={v1_id}&load=menu&showLang=en"
    
    try:
        await page.goto(url, wait_until='networkidle', timeout=60000)  # Longer timeout
        await page.wait_for_timeout(2000)  # Longer delay
        
        menu_div = await page.query_selector('div[style*="width:500px"][style*="float: left"]')
        
        if not menu_div:
            logger.warning(f"[{v3_id}] {name} (V1:{v1_id}) - No menu div found")
            return 'ERROR'
        
        inner_html = await menu_div.inner_html()
        
        if inner_html.strip() == '':
            logger.info(f"[{v3_id}] {name} (V1:{v1_id}) - FRENCH (empty menu div)")
            return 'FRENCH'
        
        if 'No Course' in inner_html:
            empty_links = re.findall(r'<a[^>]*href="[^"]*menuEntry=\d+"[^>]*></a>', inner_html)
            total_dish_links = re.findall(r'<a[^>]*href="[^"]*menuEntry=\d+"[^>]*>[^<]*</a>', inner_html)
            
            if len(empty_links) > len(total_dish_links) / 2:
                logger.info(f"[{v3_id}] {name} (V1:{v1_id}) - FRENCH (No Course with empty dishes)")
                return 'FRENCH'
        
        course_names = re.findall(r'<h3>([^<]+)</h3>', inner_html)
        valid_courses = [c for c in course_names if c != 'No Course' and c.strip()]
        
        if valid_courses:
            dish_links = re.findall(r'<a[^>]*href="[^"]*menuEntry=\d+"[^>]*>([^<]+)</a>', inner_html)
            actual_dishes = [d for d in dish_links if d.strip()]
            
            if actual_dishes:
                logger.info(f"[{v3_id}] {name} (V1:{v1_id}) - ENGLISH ({len(valid_courses)} courses, {len(actual_dishes)} dishes)")
                return 'ENGLISH'
        
        logger.info(f"[{v3_id}] {name} (V1:{v1_id}) - FRENCH (no valid courses/dishes found)")
        return 'FRENCH'
        
    except Exception as e:
        logger.error(f"[{v3_id}] {name} (V1:{v1_id}) - ERROR: {str(e)}")
        return 'ERROR'


async def main():
    """Re-check error restaurants."""
    logger.info("=" * 80)
    logger.info("Re-checking 7 Error Restaurants")
    logger.info("=" * 80)
    
    results = {'ENGLISH': [], 'FRENCH': [], 'ERROR': []}
    
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        context = await browser.new_context()
        page = await context.new_page()
        
        # Login
        logger.info("Logging into V1 CRM...")
        await page.goto(f"{CRM_BASE_URL}/?p=restaurants")
        await page.fill('#username', CRM_USERNAME)
        await page.fill('#password', CRM_PASSWORD)
        await page.click('input[type="submit"]')
        await page.wait_for_load_state('networkidle')
        logger.info("Login successful!")
        
        # Check each restaurant
        for i, (v3_id, name, v1_id) in enumerate(ERROR_RESTAURANTS, 1):
            logger.info(f"[{i}/{len(ERROR_RESTAURANTS)}] Checking {name} (V3:{v3_id}, V1:{v1_id})...")
            
            result = await check_menu_language(page, v3_id, name, v1_id)
            results[result].append((v3_id, name, v1_id))
            
            await page.wait_for_timeout(1000)  # Delay between requests
        
        await browser.close()
    
    # Summary
    logger.info("")
    logger.info("=" * 80)
    logger.info("RESULTS")
    logger.info("=" * 80)
    
    for category, restaurants in results.items():
        if restaurants:
            logger.info(f"\n{category}:")
            for v3_id, name, v1_id in restaurants:
                logger.info(f"  | {v3_id} | {name} | {v1_id} |")
    
    logger.info(f"\nLog saved to: {log_file}")


if __name__ == "__main__":
    asyncio.run(main())

