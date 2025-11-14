#!/usr/bin/env python3
"""
V2 ID Discovery Script
Scrapes the V2 dashboard restaurant list to discover V2 IDs from edit links
Updates v2_restaurants.json with discovered IDs
"""
import sys
import os
import json
import logging
import time
from pathlib import Path

# Add current directory to path for imports
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from v2_config import V2_BASE_URL, V2_USERNAME, V2_PASSWORD, RESTAURANTS_FILE
from v2_scraper import V2MenuScraper

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

def discover_v2_ids(scraper):
    """
    Scrape the restaurant list page and extract V2 IDs from edit links.
    
    Returns:
        dict: Mapping of restaurant names to V2 IDs
    """
    from bs4 import BeautifulSoup
    
    try:
        # Navigate to active restaurants list
        list_url = f"{V2_BASE_URL}/index.php/restaurants/show/active"
        logger.info(f"Navigating to: {list_url}")
        
        scraper.page.goto(list_url, wait_until='networkidle', timeout=30000)
        time.sleep(2)
        
        # Parse HTML
        html = scraper.page.content()
        soup = BeautifulSoup(html, 'lxml')
        
        # Find restaurant table
        table = soup.find('table', id='restaurantList')
        if not table:
            logger.error("Restaurant list table not found!")
            return {}
        
        # Extract restaurant data
        v2_mapping = {}
        rows = table.find('tbody').find_all('tr') if table.find('tbody') else []
        
        logger.info(f"Found {len(rows)} restaurant rows")
        
        for row in rows:
            cells = row.find_all('td')
            if len(cells) < 3:
                continue
            
            # First cell has the edit link
            edit_link = cells[0].find('a', class_='btn')
            if not edit_link:
                continue
            
            # Extract V2 ID from href
            # href format: /index.php/restaurants/edit/{V2_ID}/info
            href = edit_link.get('href', '')
            if '/restaurants/edit/' in href:
                v2_id = href.split('/restaurants/edit/')[1].split('/')[0]
                
                # Restaurant name is in second cell
                name = cells[1].get_text(strip=True)
                
                # Address is in third cell
                address = cells[2].get_text(strip=True)
                
                v2_mapping[name] = {
                    'v2_id': int(v2_id),
                    'address': address
                }
                
                logger.info(f"  {name}: V2 ID = {v2_id}")
        
        logger.info(f"✓ Discovered {len(v2_mapping)} V2 IDs")
        return v2_mapping
        
    except Exception as e:
        logger.error(f"✗ Error discovering V2 IDs: {e}")
        import traceback
        traceback.print_exc()
        return {}

def update_restaurant_json(v2_mapping):
    """
    Update v2_restaurants.json with discovered V2 IDs.
    """
    try:
        # Load existing data
        with open(RESTAURANTS_FILE, 'r', encoding='utf-8') as f:
            restaurants = json.load(f)
        
        # Update with discovered V2 IDs
        updated_count = 0
        for restaurant in restaurants:
            name = restaurant['name']
            
            # Try exact match
            if name in v2_mapping:
                restaurant['v2_id'] = v2_mapping[name]['v2_id']
                updated_count += 1
                logger.info(f"✓ Updated {name}: V2 ID = {restaurant['v2_id']}")
            else:
                # Try fuzzy match (handle slight name differences)
                for v2_name, v2_data in v2_mapping.items():
                    if name.lower() in v2_name.lower() or v2_name.lower() in name.lower():
                        restaurant['v2_id'] = v2_data['v2_id']
                        updated_count += 1
                        logger.info(f"✓ Updated {name} (matched to {v2_name}): V2 ID = {restaurant['v2_id']}")
                        break
                else:
                    logger.warning(f"⚠ No V2 ID found for {name}")
        
        # Save updated data
        with open(RESTAURANTS_FILE, 'w', encoding='utf-8') as f:
            json.dump(restaurants, f, indent=2, ensure_ascii=False)
        
        logger.info(f"✓ Updated {updated_count}/{len(restaurants)} restaurants")
        
        # Show any missing
        missing = [r for r in restaurants if not r.get('v2_id')]
        if missing:
            logger.warning(f"⚠ {len(missing)} restaurants still missing V2 IDs:")
            for r in missing:
                logger.warning(f"  - {r['name']}")
        
        return updated_count
        
    except Exception as e:
        logger.error(f"✗ Error updating restaurant JSON: {e}")
        import traceback
        traceback.print_exc()
        return 0

def main():
    logger.info("=" * 80)
    logger.info("V2 ID DISCOVERY SCRIPT")
    logger.info("Discovering V2 restaurant IDs from dashboard")
    logger.info("=" * 80)
    logger.info("")
    
    # Check credentials
    if not V2_USERNAME or not V2_PASSWORD:
        logger.error("✗ V2 credentials not configured!")
        logger.error("Please set V2_USERNAME and V2_PASSWORD in .env file")
        return 1
    
    # Initialize scraper
    scraper = V2MenuScraper(V2_BASE_URL, V2_USERNAME, V2_PASSWORD, headless=True)
    scraper.start()
    
    # Login
    if not scraper.login():
        logger.error("✗ Failed to login. Exiting.")
        scraper.stop()
        return 1
    
    try:
        # Discover V2 IDs
        v2_mapping = discover_v2_ids(scraper)
        
        if not v2_mapping:
            logger.error("✗ No V2 IDs discovered")
            return 1
        
        # Update JSON file
        updated_count = update_restaurant_json(v2_mapping)
        
        logger.info("")
        logger.info("=" * 80)
        logger.info("V2 ID DISCOVERY COMPLETE")
        logger.info(f"Updated {updated_count} restaurants with V2 IDs")
        logger.info("=" * 80)
        logger.info("")
        logger.info("Next step: Run v2_scraper_phase1.py to scrape menus")
        logger.info("")
        
        return 0
        
    finally:
        scraper.stop()

if __name__ == "__main__":
    sys.exit(main())

