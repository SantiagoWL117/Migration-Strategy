"""Special Combo Sections Scraper using Playwright for browser automation."""
import re
import time
import logging
from typing import Optional, Dict, List, Any, Tuple
from bs4 import BeautifulSoup
from playwright.sync_api import sync_playwright, Page, Browser, BrowserContext

import sys
import os

# Add parent directories to path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

from combo_config import (
    CRM_LOGIN_URL, CRM_RESTAURANTS_URL, COMBO_GROUPS_URL_PATTERN,
    COMBO_AJAX_URL, CRM_USERNAME, CRM_PASSWORD,
    TIMEOUT, NAVIGATION_TIMEOUT, SCRAPE_DELAY
)
from special_combo_database import SpecialComboDatabase

logger = logging.getLogger(__name__)

# Size mapping: index → name (for logging)
SIZE_NAMES = {0: 'Small', 1: 'Medium', 2: 'Large', 3: 'X-Large'}


class SpecialComboScraper:
    """Scraper for special combo sections that reference actual dishes."""

    def __init__(self, headless: bool = True):
        self.headless = headless
        self.playwright = None
        self.browser: Optional[Browser] = None
        self.context: Optional[BrowserContext] = None
        self.page: Optional[Page] = None
        self.db: Optional[SpecialComboDatabase] = None

    def start(self):
        """Initialize browser and database connections."""
        logger.info("Starting Special Combo Scraper...")

        # Start Playwright
        self.playwright = sync_playwright().start()
        self.browser = self.playwright.chromium.launch(headless=self.headless)
        self.context = self.browser.new_context()
        self.page = self.context.new_page()
        self.page.set_default_timeout(TIMEOUT)
        self.page.set_default_navigation_timeout(NAVIGATION_TIMEOUT)

        # Connect to database
        self.db = SpecialComboDatabase()
        self.db.connect()

        logger.info("Browser and database connections established")

    def stop(self):
        """Close all connections."""
        logger.info("Stopping Special Combo Scraper...")

        if self.page:
            self.page.close()
        if self.context:
            self.context.close()
        if self.browser:
            self.browser.close()
        if self.playwright:
            self.playwright.stop()
        if self.db:
            self.db.close()

        logger.info("All connections closed")

    def __enter__(self):
        self.start()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.stop()

    # =========================================================================
    # Login (reused from ComboScraper)
    # =========================================================================

    def login(self) -> bool:
        """Login to V1 CRM."""
        logger.info(f"Logging in to {CRM_LOGIN_URL}...")

        try:
            self.page.goto(CRM_LOGIN_URL, wait_until='domcontentloaded')
            self.page.wait_for_load_state('networkidle', timeout=15000)
            time.sleep(1)

            # Try login form with name="username"
            try:
                self.page.wait_for_selector('input[name="username"]', state='visible', timeout=5000)
                logger.info("Found login form with name='username'")
                self.page.fill('input[name="username"]', CRM_USERNAME)
                self.page.fill('input[name="password"]', CRM_PASSWORD)
                self.page.click('input[type="submit"]')
            except:
                try:
                    # Try name="user" (older form)
                    self.page.wait_for_selector('input[name="user"]', state='visible', timeout=3000)
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
            if 'menuadmin.menu.ca' in current_url and 'p=login' not in current_url:
                logger.info("Login successful")
                return True
            else:
                logger.error("Login failed - still on login page")
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
        logger.info(f"Navigating to combo groups: {url}")

        try:
            self.page.goto(url)
            self.page.wait_for_load_state('networkidle')

            # Wait for combo group elements to load
            try:
                self.page.wait_for_selector(
                    'p[style*="background-color"] a[onclick*="editGroupJS"]',
                    timeout=10000
                )
                logger.info("Combo group elements detected")
            except:
                logger.info("No combo group elements detected")

            time.sleep(SCRAPE_DELAY)
            return True
        except Exception as e:
            logger.error(f"Failed to navigate to combo groups: {e}")
            return False

    def get_combo_group_links(self) -> List[Dict[str, Any]]:
        """Get all combo group links from the page."""
        combo_groups = []
        html_content = self.page.content()

        soup = BeautifulSoup(html_content, 'html.parser')
        for a_tag in soup.find_all('a', onclick=True):
            onclick = a_tag.get('onclick', '')
            if 'editGroupJS' in onclick:
                name = a_tag.get_text().strip()
                match = re.search(r"editGroupJS\(['\"](\d+)['\"]\)", onclick)
                if match:
                    source_id = int(match.group(1))
                    combo_groups.append({
                        'name': name,
                        'source_id': source_id
                    })
                    logger.debug(f"Found combo group: {name} (source_id={source_id})")

        logger.info(f"Found {len(combo_groups)} combo groups")
        return combo_groups

    def fetch_combo_group_details(self, v1_id: int, source_id: int) -> Optional[str]:
        """Fetch combo group details via AJAX POST request."""
        ajax_url = f"{COMBO_AJAX_URL}?restaurant={v1_id}&showLang=en"

        try:
            response = self.page.request.post(
                ajax_url,
                form={"arr": str(source_id)},
                timeout=TIMEOUT
            )

            if response.ok:
                html = response.text()
                logger.debug(f"AJAX response: {len(html)} bytes")
                return html
            else:
                logger.warning(f"AJAX request failed: {response.status}")
                return None
        except Exception as e:
            logger.error(f"Error fetching combo group details: {e}")
            return None

    # =========================================================================
    # Parsing Special Dish Selections
    # =========================================================================

    @staticmethod
    def parse_dish_value(value: str) -> Tuple[int, Optional[int]]:
        """
        Parse dish value attribute to extract source_id and size.
        
        Examples:
            "105965.2" → (105965, 2)  # Large
            "105962"   → (105962, None)  # No size
        
        Returns:
            Tuple of (source_id, size) where size is 0-3 or None
        """
        if '.' in value:
            parts = value.split('.')
            source_id = int(parts[0])
            size = int(parts[1])
            return source_id, size
        else:
            return int(value), None

    def parse_special_dish_selections(self, html: str) -> List[Dict[str, Any]]:
        """
        Parse #dishes div for checked items.
        
        Returns list of dicts with:
            - source_id: V1 dish source ID
            - size: Size index (0-3) or None
            - dish_display_name: Label text
        """
        soup = BeautifulSoup(html, 'html.parser')
        selections = []

        # Find the #dishes div
        dishes_div = soup.find('ul', {'id': 'dishes'})
        if not dishes_div:
            return selections

        # Find all checked checkboxes with name="items[]"
        for checkbox in dishes_div.find_all('input', {'type': 'checkbox', 'name': 'items[]'}):
            if not checkbox.has_attr('checked'):
                continue

            value = checkbox.get('value', '')
            if not value:
                continue

            try:
                source_id, size = self.parse_dish_value(value)
            except (ValueError, IndexError) as e:
                logger.warning(f"Failed to parse value '{value}': {e}")
                continue

            # Get display name from label
            checkbox_id = checkbox.get('id', '')
            label = soup.find('label', {'for': checkbox_id})
            dish_display_name = label.get_text().strip() if label else ''

            selections.append({
                'source_id': source_id,
                'size': size,
                'dish_display_name': dish_display_name
            })

            size_name = SIZE_NAMES.get(size, 'No size') if size is not None else 'No size'
            logger.debug(f"Found checked dish: {dish_display_name} (source_id={source_id}, size={size_name})")

        return selections

    def has_special_section(self, html: str) -> bool:
        """Check if combo group has any checked dishes in #dishes div."""
        soup = BeautifulSoup(html, 'html.parser')
        dishes_div = soup.find('ul', {'id': 'dishes'})
        if not dishes_div:
            return False

        # Check for any checked checkbox
        for checkbox in dishes_div.find_all('input', {'type': 'checkbox', 'name': 'items[]'}):
            if checkbox.has_attr('checked'):
                return True

        return False

    # =========================================================================
    # Main Scraping Logic
    # =========================================================================

    def scrape_special_combos(self, restaurant_id: int, v1_id: int) -> Dict[str, int]:
        """
        Scrape special combo sections for a restaurant.
        
        Args:
            restaurant_id: V3 restaurant ID
            v1_id: V1 restaurant ID
            
        Returns:
            Stats dict with counts
        """
        stats = {
            'combo_groups_processed': 0,
            'special_combos_found': 0,
            'dish_selections_inserted': 0,
            'dish_lookups_failed': 0
        }

        # Navigate to combo groups page
        if not self.navigate_to_combo_groups(v1_id):
            return stats

        # Get list of combo groups from page
        combo_group_links = self.get_combo_group_links()

        if not combo_group_links:
            logger.info(f"No combo groups found for restaurant {restaurant_id}")
            return stats

        # Process each combo group
        for cg_info in combo_group_links:
            cg_name = cg_info['name']
            cg_source_id = cg_info['source_id']
            
            logger.info(f"Processing combo group: {cg_name} (source_id={cg_source_id})")
            stats['combo_groups_processed'] += 1

            # Fetch details via AJAX
            html = self.fetch_combo_group_details(v1_id, cg_source_id)
            if not html:
                continue

            # Check if this combo has special sections
            if not self.has_special_section(html):
                logger.debug(f"No special section for: {cg_name}")
                continue

            logger.info(f"Found special section in: {cg_name}")
            stats['special_combos_found'] += 1

            # Get or lookup the combo group in V3
            combo_group = self.db.get_combo_group_by_source_id(restaurant_id, cg_source_id)
            if not combo_group:
                logger.warning(f"Combo group not found in V3: source_id={cg_source_id}")
                continue

            combo_group_id = combo_group['id']

            # Set has_special_section flag
            self.db.update_combo_group_has_special_section(combo_group_id, True)

            # Parse dish selections
            selections = self.parse_special_dish_selections(html)
            logger.info(f"Found {len(selections)} checked dishes in {cg_name}")

            # Insert each selection
            for sel in selections:
                source_id = sel['source_id']
                size = sel['size']
                display_name = sel['dish_display_name']

                # Lookup V3 dish by source_id (also gets course_id)
                dish = self.db.get_dish_by_source_id(restaurant_id, source_id)
                if not dish:
                    logger.warning(f"Dish not found: source_id={source_id}")
                    stats['dish_lookups_failed'] += 1
                    continue

                dish_id = dish['id']
                course_id = dish.get('course_id')
                dish_name = dish.get('name', '')

                # Only store display_name if different from dish.name
                final_display_name = None
                if display_name and display_name != dish_name:
                    final_display_name = display_name

                # Insert dish selection
                result = self.db.insert_combo_group_dish_selection(
                    combo_group_id=combo_group_id,
                    dish_id=dish_id,
                    size=size,
                    course_id=course_id,
                    dish_display_name=final_display_name
                )

                if result:
                    stats['dish_selections_inserted'] += 1

            time.sleep(SCRAPE_DELAY)

        return stats

