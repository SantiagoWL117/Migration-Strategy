"""Scanner to identify combo groups with special item selections (checked checkboxes).

This scanner identifies restaurants that have combo groups where specific dish items
are pre-selected (checked checkboxes in the items list). These require special handling
during migration because the V1 system allows linking specific dish sizes to combo groups.
"""
import re
import time
import logging
from typing import Optional, Dict, List, Any
from bs4 import BeautifulSoup
from playwright.sync_api import sync_playwright, Page, Browser, BrowserContext

import sys
import os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from combo_config import (
    CRM_LOGIN_URL, COMBO_GROUPS_URL_PATTERN,
    CRM_USERNAME, CRM_PASSWORD,
    TIMEOUT, NAVIGATION_TIMEOUT, SCRAPE_DELAY
)

logger = logging.getLogger(__name__)


class SpecialComboScanner:
    """Scanner for identifying combo groups with special item selections."""

    def __init__(self, headless: bool = True):
        self.headless = headless
        self.playwright = None
        self.browser: Optional[Browser] = None
        self.context: Optional[BrowserContext] = None
        self.page: Optional[Page] = None
        
        # Results tracking
        self.special_combo_groups = []  # List of {restaurant, combo_group, checked_items}
        self.restaurants_with_specials = set()

    def start(self):
        """Initialize browser connection."""
        logger.info("Starting Special Combo Scanner...")

        # Start Playwright
        self.playwright = sync_playwright().start()
        self.browser = self.playwright.chromium.launch(headless=self.headless)
        self.context = self.browser.new_context()
        self.page = self.context.new_page()
        self.page.set_default_timeout(TIMEOUT)
        self.page.set_default_navigation_timeout(NAVIGATION_TIMEOUT)

        logger.info("Browser connection established")

    def stop(self):
        """Close all connections."""
        logger.info("Stopping Special Combo Scanner...")

        if self.page:
            self.page.close()
        if self.context:
            self.context.close()
        if self.browser:
            self.browser.close()
        if self.playwright:
            self.playwright.stop()

        logger.info("All connections closed")

    def __enter__(self):
        self.start()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.stop()

    # =========================================================================
    # Login (recycled from combo_scraper.py)
    # =========================================================================

    def login(self) -> bool:
        """Login to V1 CRM."""
        logger.info(f"Logging in to {CRM_LOGIN_URL}...")

        try:
            self.page.goto(CRM_LOGIN_URL, wait_until='domcontentloaded')
            self.page.wait_for_load_state('networkidle', timeout=15000)
            time.sleep(1)

            # Try the actual HTML form first
            try:
                self.page.wait_for_selector(
                    'input[name="username"]', state='visible', timeout=5000)
                logger.info("Found login form with name='username'")
                self.page.fill('input[name="username"]', CRM_USERNAME)
                self.page.fill('input[name="password"]', CRM_PASSWORD)
                self.page.click('input[type="submit"]')
            except:
                try:
                    # Try name="user" (older form)
                    self.page.wait_for_selector(
                        'input[name="user"]', state='visible', timeout=3000)
                    logger.info("Found login form with name='user'")
                    self.page.fill('input[name="user"]', CRM_USERNAME)
                    self.page.fill('input[name="password"]', CRM_PASSWORD)
                    self.page.click('input[type="submit"]')
                except:
                    logger.error("Could not find login form")
                    return False

            # Wait for navigation after login
            self.page.wait_for_load_state('networkidle', timeout=30000)
            time.sleep(2)

            current_url = self.page.url
            logger.info(f"Current URL after login: {current_url}")

            # Check if login successful
            if self.page.query_selector('ul#active') or 'restaurants' in current_url:
                logger.info("Login successful")
                return True
            else:
                logger.error("Login failed - could not verify success")
                return False

        except Exception as e:
            logger.error(f"Login failed: {e}")
            return False

    # =========================================================================
    # Navigation
    # =========================================================================

    def navigate_to_combo_groups(self, v1_id: int) -> bool:
        """Navigate to combo groups page for a restaurant."""
        url = COMBO_GROUPS_URL_PATTERN.format(v1_id=v1_id)
        logger.debug(f"Navigating to combo groups: {url}")

        try:
            self.page.goto(url, wait_until='domcontentloaded')
            self.page.wait_for_load_state('networkidle', timeout=15000)
            time.sleep(SCRAPE_DELAY)
            return True
        except Exception as e:
            logger.error(f"Failed to navigate to combo groups: {e}")
            return False

    def get_combo_group_links(self) -> List[Dict[str, Any]]:
        """Get all combo group links from the page."""
        combo_groups = []
        html = self.page.content()
        soup = BeautifulSoup(html, 'html.parser')

        # Find all editGroupJS links
        # Pattern: <a href="#" onclick="editGroupJS('8164');return false;">1 Large Pizza from Menu</a>
        links = soup.find_all('a', onclick=re.compile(r"editGroupJS\('\d+'\)"))

        for link in links:
            onclick = link.get('onclick', '')
            match = re.search(r"editGroupJS\('(\d+)'\)", onclick)
            if match:
                source_id = int(match.group(1))
                name = link.get_text(strip=True)
                combo_groups.append({
                    'source_id': source_id,
                    'name': name
                })

        return combo_groups

    def click_combo_group_link(self, v1_id: int, source_id: int) -> bool:
        """Click on a combo group link to view its details."""
        # Re-navigate to ensure clean state
        url = COMBO_GROUPS_URL_PATTERN.format(v1_id=v1_id)
        self.page.goto(url, wait_until='domcontentloaded')
        self.page.wait_for_load_state('networkidle', timeout=15000)
        time.sleep(SCRAPE_DELAY)

        selector = f"a[onclick*=\"editGroupJS('{source_id}')\"]"
        try:
            self.page.wait_for_selector(selector, state='visible', timeout=10000)
            self.page.click(selector)
            self.page.wait_for_load_state('domcontentloaded')
            self.page.wait_for_load_state('networkidle', timeout=15000)
            time.sleep(SCRAPE_DELAY)
            return True
        except Exception as e:
            logger.warning(f"Could not click combo group link for source_id={source_id}: {e}")
            return False

    # =========================================================================
    # Special Combo Detection
    # =========================================================================

    def check_for_checked_items(self) -> List[Dict[str, Any]]:
        """Check if the current combo group detail page has checked item checkboxes.
        
        Looks for: <ul id="dishes"> containing <input type="checkbox" name="items[]" checked="">
        
        Returns list of checked items with their details.
        """
        checked_items = []
        html = self.page.content()
        soup = BeautifulSoup(html, 'html.parser')

        # Find the dishes list
        dishes_ul = soup.find('ul', {'id': 'dishes'})
        if not dishes_ul:
            return checked_items

        # Find all checked checkboxes
        # Pattern: <input checked="" type="checkbox" name="items[]" value="105963.2" id="items_105963.2">
        checkboxes = dishes_ul.find_all('input', {'type': 'checkbox', 'name': 'items[]'})

        for checkbox in checkboxes:
            if checkbox.has_attr('checked'):
                item_value = checkbox.get('value', '')
                item_id = checkbox.get('id', '')
                
                # Get the label text
                label = dishes_ul.find('label', {'for': item_id})
                item_name = label.get_text(strip=True) if label else f"Item {item_value}"
                
                # Find the course/category (h4 element in parent li)
                parent_li = checkbox.find_parent('li')
                if parent_li:
                    # Go up to find the category li with h4
                    category_li = parent_li.find_parent('li')
                    if category_li:
                        h4 = category_li.find('h4')
                        category = h4.get_text(strip=True) if h4 else "Unknown"
                    else:
                        category = "Unknown"
                else:
                    category = "Unknown"

                checked_items.append({
                    'value': item_value,
                    'name': item_name,
                    'category': category
                })

        return checked_items

    # =========================================================================
    # Main Scanning Logic
    # =========================================================================

    def scan_restaurant(self, v3_id: int, v1_id: int, name: str) -> Dict[str, Any]:
        """Scan a single restaurant for special combo sections.
        
        Returns dict with restaurant info and list of special combo groups found.
        """
        result = {
            'v3_id': v3_id,
            'v1_id': v1_id,
            'name': name,
            'total_combo_groups': 0,
            'special_combo_groups': [],
            'total_checked_items': 0
        }

        # Navigate to combo groups page
        if not self.navigate_to_combo_groups(v1_id):
            logger.error(f"Failed to navigate to combo groups for {name}")
            return result

        # Get all combo group links
        combo_groups = self.get_combo_group_links()
        result['total_combo_groups'] = len(combo_groups)

        if not combo_groups:
            logger.info(f"No combo groups found for {name}")
            return result

        logger.info(f"Found {len(combo_groups)} combo groups for {name}")

        # Check each combo group for checked items
        for cg in combo_groups:
            if not self.click_combo_group_link(v1_id, cg['source_id']):
                continue

            checked_items = self.check_for_checked_items()

            if checked_items:
                special_group = {
                    'source_id': cg['source_id'],
                    'name': cg['name'],
                    'checked_items': checked_items,
                    'checked_count': len(checked_items)
                }
                result['special_combo_groups'].append(special_group)
                result['total_checked_items'] += len(checked_items)

                logger.info(f"  [SPECIAL] {cg['name']} (source_id={cg['source_id']}): "
                           f"{len(checked_items)} checked items")

                # Track globally
                self.special_combo_groups.append({
                    'restaurant': {'v3_id': v3_id, 'v1_id': v1_id, 'name': name},
                    'combo_group': cg,
                    'checked_items': checked_items
                })
                self.restaurants_with_specials.add(v3_id)

        return result

    def scan_restaurants(self, restaurants: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Scan multiple restaurants for special combo sections.
        
        Args:
            restaurants: List of dicts with 'v3_id', 'v1_id', 'name' keys
            
        Returns:
            List of scan results for each restaurant
        """
        results = []
        total = len(restaurants)

        for idx, restaurant in enumerate(restaurants, 1):
            v3_id = restaurant['v3_id']
            v1_id = restaurant['v1_id']
            name = restaurant['name']

            logger.info(f"\n{'='*60}")
            logger.info(f"[{idx}/{total}] Scanning: {name} (V3: {v3_id}, V1: {v1_id})")
            logger.info(f"{'='*60}")

            try:
                result = self.scan_restaurant(v3_id, v1_id, name)
                results.append(result)

                # Log summary for this restaurant
                if result['special_combo_groups']:
                    logger.info(f"  FOUND {len(result['special_combo_groups'])} special combo groups "
                               f"with {result['total_checked_items']} total checked items")
                else:
                    logger.info(f"  No special combo groups found")

            except Exception as e:
                logger.error(f"Error scanning {name}: {e}")
                results.append({
                    'v3_id': v3_id,
                    'v1_id': v1_id,
                    'name': name,
                    'error': str(e)
                })

        return results

    def get_summary(self) -> Dict[str, Any]:
        """Get summary of all scanned restaurants."""
        return {
            'total_restaurants_with_specials': len(self.restaurants_with_specials),
            'total_special_combo_groups': len(self.special_combo_groups),
            'restaurants_with_specials': list(self.restaurants_with_specials),
            'special_combo_groups': self.special_combo_groups
        }


