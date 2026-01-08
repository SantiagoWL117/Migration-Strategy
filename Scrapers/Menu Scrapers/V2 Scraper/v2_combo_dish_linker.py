"""
V2 Combo Dish Linker Scraper

Scrapes the V2 CRM to find combo dishes and link them to their assigned combo groups
in the V3 database via the dish_combo_groups junction table.

Usage:
    python v2_combo_dish_linker.py --restaurant-id 973 --v2-id 1670 --language en
"""

import asyncio
import argparse
import logging
import subprocess
import tempfile
import re
import json
from datetime import datetime
from pathlib import Path
from typing import List, Dict, Tuple, Optional

from playwright.async_api import async_playwright, Page, Browser

# Add parent directory to path for config import
import sys
sys.path.insert(0, str(Path(__file__).parent.parent))
from config import (
    CRM_V2_BASE_URL, CRM_V2_USERNAME, CRM_V2_PASSWORD,
    DB_CONNECTION_STRING, PSQL_PATH, SCHEMA
)


class V2ComboDishLinker:
    """Scrapes V2 CRM to link combo dishes to their combo groups."""
    
    def __init__(self, restaurant_id: int, v2_restaurant_id: int, language: str = 'en'):
        self.restaurant_id = restaurant_id
        self.v2_restaurant_id = v2_restaurant_id
        self.language = language
        self.language_id = 1 if language == 'en' else 2
        
        self.browser: Optional[Browser] = None
        self.page: Optional[Page] = None
        self.logger = logging.getLogger(f'V2ComboDishLinker-{restaurant_id}')
        
        # Statistics
        self.stats = {
            'dishes_found': 0,
            'combo_dishes': 0,
            'links_created': 0,
            'links_skipped': 0,
            'errors': 0,
        }
        
        # Cache for V3 lookups
        self._dish_cache: Dict[int, int] = {}  # source_id -> v3_id
        self._combo_group_cache: Dict[int, int] = {}  # source_id -> v3_id
        
    async def setup(self):
        """Initialize browser and login to V2 CRM."""
        playwright = await async_playwright().start()
        self.browser = await playwright.chromium.launch(headless=True)
        self.page = await self.browser.new_page()
        
        # Login to V2 CRM
        await self._login()
        
    async def cleanup(self):
        """Close browser."""
        if self.browser:
            await self.browser.close()
            
    async def _login(self):
        """Login to V2 CRM."""
        login_url = f"{CRM_V2_BASE_URL}/auth/index"
        self.logger.info(f"Logging in to V2 CRM: {login_url}")
        
        await self.page.goto(login_url)
        await self.page.wait_for_load_state('networkidle')
        
        # Fill login form
        await self.page.fill('input[name="email"]', CRM_V2_USERNAME)
        await self.page.fill('input[name="password"]', CRM_V2_PASSWORD)
        await self.page.click('button[type="submit"]')
        
        # Wait for redirect after login
        await self.page.wait_for_load_state('networkidle')
        await asyncio.sleep(1)
        
        # Verify login success
        current_url = self.page.url
        if 'auth' in current_url.lower():
            raise Exception("Login failed - still on auth page")
            
        self.logger.info("Login successful")
        
    async def scrape_restaurant(self) -> Dict:
        """Scrape all combo dishes for the restaurant and link them to combo groups."""
        # Navigate to menu page
        menu_url = f"{CRM_V2_BASE_URL}/restaurants/edit/{self.v2_restaurant_id}/menu/{self.language_id}/restaurant"
        self.logger.info(f"Navigating to menu page: {menu_url}")
        
        await self.page.goto(menu_url)
        await self.page.wait_for_load_state('networkidle')
        await asyncio.sleep(1)
        
        # Load caches
        await self._load_dish_cache()
        await self._load_combo_group_cache()
        
        # Collect dish data (IDs and metadata) first - these are strings that won't become stale
        combo_dishes_data = await self._collect_combo_dishes_data()
        self.stats['dishes_found'] = len(combo_dishes_data['all_dishes'])
        self.stats['combo_dishes'] = len(combo_dishes_data['combo_dishes'])
        
        self.logger.info(f"Found {self.stats['dishes_found']} total dishes, {self.stats['combo_dishes']} combo dishes")
        
        # Process each combo dish by re-querying the element each time
        for dish_info in combo_dishes_data['combo_dishes']:
            try:
                await self._process_combo_dish_by_id(dish_info)
            except Exception as e:
                self.logger.error(f"Error processing dish {dish_info.get('name', 'unknown')}: {e}")
                self.stats['errors'] += 1
                
        return self.stats
        
    async def _collect_combo_dishes_data(self) -> Dict:
        """Collect dish metadata as plain data (not element references) to avoid stale handles."""
        all_dishes = []
        combo_dishes = []
        
        # Use JavaScript to extract data directly - more reliable than ElementHandles
        data = await self.page.evaluate("""
            () => {
                const dishes = document.querySelectorAll('#sortable tr.sort');
                const result = { all_dishes: [], combo_dishes: [] };
                
                dishes.forEach(dish => {
                    const id = dish.getAttribute('data-id');
                    const name = dish.getAttribute('data-dish');
                    const editBtn = dish.querySelector('a.edit_dish');
                    const href = editBtn ? editBtn.getAttribute('href') : '';
                    
                    const dishInfo = { id, name, href };
                    result.all_dishes.push(dishInfo);
                    
                    if (href && href.includes('edit_combo')) {
                        result.combo_dishes.push(dishInfo);
                    }
                });
                
                return result;
            }
        """)
        
        return data
        
    async def _process_combo_dish_by_id(self, dish_info: Dict):
        """Process a combo dish by finding it fresh in the DOM each time."""
        dish_id = dish_info.get('id')
        dish_name = dish_info.get('name', 'Unknown')
        
        if not dish_id:
            return
            
        self.logger.info(f"Processing combo dish: {dish_name} (source_id: {dish_id})")
        
        # Re-query the specific dish element to get a fresh reference
        dish_element = await self.page.query_selector(f'#sortable tr.sort[data-id="{dish_id}"]')
        if not dish_element:
            self.logger.warning(f"Could not find dish element in DOM: {dish_name} ({dish_id})")
            self.stats['errors'] += 1
            return
            
        # Find the edit button within this dish
        edit_btn = await dish_element.query_selector('a.edit_dish')
        if not edit_btn:
            self.logger.warning(f"Could not find edit button for dish: {dish_name}")
            self.stats['errors'] += 1
            return
        
        # Click edit button to open modal
        await edit_btn.click()
        await asyncio.sleep(0.5)
        
        # Wait for modal to load
        try:
            await self.page.wait_for_selector('.modal-body ul.ul-dish', timeout=5000)
        except:
            self.logger.warning(f"No combo groups found for dish: {dish_name}")
            await self._close_modal()
            return
            
        # Extract combo groups from modal
        combo_groups = await self._extract_combo_groups()
        
        if combo_groups:
            self.logger.info(f"  Found {len(combo_groups)} combo groups: {[cg['name'] for cg in combo_groups]}")
            
            # Link dish to combo groups
            await self._link_dish_to_combo_groups(int(dish_id), combo_groups)
        else:
            self.logger.warning(f"  No combo groups found in modal for: {dish_name}")
            
        # Close modal and wait for page to stabilize
        await self._close_modal()
        await asyncio.sleep(0.3)  # Allow page to settle after modal close
        
    async def _extract_combo_groups(self) -> List[Dict]:
        """Extract combo group assignments from the modal."""
        combo_groups = []
        
        # Find all combo group items in the ul.ul-dish
        items = await self.page.query_selector_all('.modal-body ul.ul-dish li.alert-info')
        
        for item in items:
            try:
                # Get group_id from hidden input
                group_id_input = await item.query_selector('input[name*="group_id"]')
                group_name_input = await item.query_selector('input[name*="group_name"]')
                
                if group_id_input and group_name_input:
                    group_id = await group_id_input.get_attribute('value')
                    group_name = await group_name_input.get_attribute('value')
                    
                    if group_id:
                        combo_groups.append({
                            'source_id': int(group_id),
                            'name': group_name or ''
                        })
            except Exception as e:
                self.logger.error(f"Error extracting combo group: {e}")
                
        return combo_groups
        
    async def _close_modal(self):
        """Close the currently open modal."""
        try:
            close_btn = await self.page.query_selector('.modal.in button.close, .modal.show button.close')
            if close_btn:
                await close_btn.click()
                await asyncio.sleep(0.3)
        except:
            # Try pressing Escape
            await self.page.keyboard.press('Escape')
            await asyncio.sleep(0.3)
            
    async def _load_dish_cache(self):
        """Load dish source_id to v3_id mapping from database."""
        sql = f"""
        SELECT source_id, id FROM {SCHEMA}.dishes 
        WHERE restaurant_id = {self.restaurant_id} 
        AND source_id IS NOT NULL;
        """
        result = self._run_sql(sql)
        
        for line in result.strip().split('\n'):
            if '|' in line:
                parts = [p.strip() for p in line.split('|')]
                if len(parts) >= 2 and parts[0].isdigit():
                    source_id = int(parts[0])
                    v3_id = int(parts[1])
                    self._dish_cache[source_id] = v3_id
                    
        self.logger.info(f"Loaded {len(self._dish_cache)} dishes into cache")
        
    async def _load_combo_group_cache(self):
        """Load combo_group source_id to v3_id mapping from database."""
        sql = f"""
        SELECT source_id, id FROM {SCHEMA}.combo_groups 
        WHERE restaurant_id = {self.restaurant_id} 
        AND source_id IS NOT NULL;
        """
        result = self._run_sql(sql)
        
        for line in result.strip().split('\n'):
            if '|' in line:
                parts = [p.strip() for p in line.split('|')]
                if len(parts) >= 2 and parts[0].isdigit():
                    source_id = int(parts[0])
                    v3_id = int(parts[1])
                    self._combo_group_cache[source_id] = v3_id
                    
        self.logger.info(f"Loaded {len(self._combo_group_cache)} combo groups into cache")
        
    async def _link_dish_to_combo_groups(self, dish_source_id: int, combo_groups: List[Dict]):
        """Create dish_combo_groups entries for the dish."""
        # Get V3 dish ID
        v3_dish_id = self._dish_cache.get(dish_source_id)
        if not v3_dish_id:
            self.logger.warning(f"  No V3 dish found for source_id: {dish_source_id}")
            self.stats['errors'] += 1
            return
            
        for cg in combo_groups:
            v3_combo_group_id = self._combo_group_cache.get(cg['source_id'])
            if not v3_combo_group_id:
                self.logger.warning(f"  No V3 combo_group found for source_id: {cg['source_id']} ({cg['name']})")
                self.stats['errors'] += 1
                continue
                
            # Insert into dish_combo_groups (with ON CONFLICT DO NOTHING)
            sql = f"""
            INSERT INTO {SCHEMA}.dish_combo_groups (dish_id, combo_group_id, is_active)
            VALUES ({v3_dish_id}, {v3_combo_group_id}, TRUE)
            ON CONFLICT (dish_id, combo_group_id) DO NOTHING;
            """
            
            try:
                self._run_sql(sql)
                self.logger.info(f"  Linked dish {v3_dish_id} to combo_group {v3_combo_group_id} ({cg['name']})")
                self.stats['links_created'] += 1
            except Exception as e:
                if 'already exists' in str(e).lower() or 'duplicate' in str(e).lower():
                    self.logger.debug(f"  Link already exists: dish {v3_dish_id} -> combo_group {v3_combo_group_id}")
                    self.stats['links_skipped'] += 1
                else:
                    self.logger.error(f"  Error linking dish to combo_group: {e}")
                    self.stats['errors'] += 1
                    
    def _run_sql(self, sql: str) -> str:
        """Execute SQL using psql and return output."""
        with tempfile.NamedTemporaryFile(mode='w', suffix='.sql', delete=False, encoding='utf-8') as f:
            f.write(sql)
            sql_file = f.name
            
        try:
            result = subprocess.run(
                [PSQL_PATH, DB_CONNECTION_STRING, '-f', sql_file, '-t', '-A'],
                capture_output=True,
                text=True,
                timeout=30
            )
            if result.returncode != 0 and result.stderr:
                if 'ERROR' in result.stderr:
                    raise Exception(result.stderr)
            return result.stdout
        finally:
            Path(sql_file).unlink(missing_ok=True)


async def run_scraper(
    restaurant_id: int,
    v2_restaurant_id: int,
    language: str = 'en',
    restaurant_name: str = ''
) -> Dict:
    """Run the scraper for a single restaurant."""
    linker = V2ComboDishLinker(restaurant_id, v2_restaurant_id, language)
    
    try:
        await linker.setup()
        stats = await linker.scrape_restaurant()
        return stats
    finally:
        await linker.cleanup()


def setup_logging(log_file: str = None):
    """Configure logging."""
    log_format = '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    
    handlers = [logging.StreamHandler()]
    
    if log_file:
        Path(log_file).parent.mkdir(parents=True, exist_ok=True)
        handlers.append(logging.FileHandler(log_file, encoding='utf-8'))
        
    logging.basicConfig(
        level=logging.INFO,
        format=log_format,
        handlers=handlers
    )


def main():
    parser = argparse.ArgumentParser(description='V2 Combo Dish Linker Scraper')
    parser.add_argument('--restaurant-id', type=int, required=True, help='V3 restaurant ID')
    parser.add_argument('--v2-id', type=int, required=True, help='V2 restaurant ID')
    parser.add_argument('--language', type=str, default='en', choices=['en', 'fr'], help='Menu language')
    parser.add_argument('--name', type=str, default='', help='Restaurant name (for logging)')
    parser.add_argument('--log-file', type=str, help='Log file path')
    
    args = parser.parse_args()
    
    # Setup logging
    if args.log_file:
        setup_logging(args.log_file)
    else:
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        log_dir = Path(__file__).parent / 'logs'
        log_file = log_dir / f'combo_dish_linker_{args.restaurant_id}_{timestamp}.log'
        setup_logging(str(log_file))
        
    logger = logging.getLogger('main')
    logger.info(f"Starting V2 Combo Dish Linker for restaurant {args.restaurant_id} ({args.name})")
    logger.info(f"V2 ID: {args.v2_id}, Language: {args.language}")
    
    # Run scraper
    stats = asyncio.run(run_scraper(
        args.restaurant_id,
        args.v2_id,
        args.language,
        args.name
    ))
    
    # Print summary
    logger.info("=" * 60)
    logger.info("SCRAPING COMPLETE")
    logger.info("=" * 60)
    logger.info(f"  Dishes found: {stats['dishes_found']}")
    logger.info(f"  Combo dishes: {stats['combo_dishes']}")
    logger.info(f"  Links created: {stats['links_created']}")
    logger.info(f"  Links skipped (existing): {stats['links_skipped']}")
    logger.info(f"  Errors: {stats['errors']}")
    logger.info("=" * 60)
    
    return stats


if __name__ == '__main__':
    main()

