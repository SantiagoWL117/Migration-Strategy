"""Combo Drinks Upsert Scraper - Only updates when data differs from V3."""
import re
import time
import logging
from typing import Optional, Dict, List, Any
from bs4 import BeautifulSoup
from playwright.sync_api import sync_playwright, Page, Browser, BrowserContext

from combo_drinks_config import (
    CRM_LOGIN_URL, MENU_URL_PATTERN, COMBO_DISH_URL_PATTERN,
    CRM_USERNAME, CRM_PASSWORD,
    DRINKS_SECTION_CONFIG, TIMEOUT, NAVIGATION_TIMEOUT, SCRAPE_DELAY
)
from combo_drinks_database import ComboDrinksDatabase

logger = logging.getLogger(__name__)


# V1 IDs of restaurants that have combo dishes (extracted from Combo Drinks Scraper.log)
V1_IDS_WITH_COMBO_DISHES = [
    255, 204, 205, 207, 209, 211, 213, 225, 228, 238,
    245, 246, 248, 275, 328, 334, 383, 387, 411, 489,
    512, 513, 532, 701, 712, 721, 729, 785, 789, 807,
    815, 817, 824, 850, 879, 889, 913, 937, 947, 951,
    952, 973, 987, 989, 998, 1025, 1027, 1028, 1032, 1033,
    1045, 1059, 1062, 1063, 1065, 1069, 1080, 1082, 1087, 1095
]


class ComboDrinksUpsertScraper:
    """Scraper that only updates drinks modifier groups when data differs from V3."""

    def __init__(self, headless: bool = True):
        self.headless = headless
        self.playwright = None
        self.browser: Optional[Browser] = None
        self.context: Optional[BrowserContext] = None
        self.page: Optional[Page] = None
        self.db: Optional[ComboDrinksDatabase] = None
        self.current_restaurant = None

    def start(self):
        """Initialize browser and database connections."""
        logger.info("Starting Combo Drinks Upsert Scraper...")

        # Start Playwright
        self.playwright = sync_playwright().start()
        self.browser = self.playwright.chromium.launch(headless=self.headless)
        self.context = self.browser.new_context()
        self.page = self.context.new_page()
        self.page.set_default_timeout(TIMEOUT)
        self.page.set_default_navigation_timeout(NAVIGATION_TIMEOUT)

        # Connect to database
        self.db = ComboDrinksDatabase()
        self.db.connect()

        logger.info("Browser and database connections established")

    def stop(self):
        """Close all connections."""
        logger.info("Stopping Combo Drinks Upsert Scraper...")

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
    # Login
    # =========================================================================

    def login(self) -> bool:
        """Login to V1 CRM."""
        logger.info(f"Logging in to {CRM_LOGIN_URL}...")

        try:
            self.page.goto(CRM_LOGIN_URL, wait_until='domcontentloaded')
            self.page.wait_for_load_state('networkidle', timeout=15000)
            time.sleep(1)

            try:
                self.page.wait_for_selector(
                    'input[name="username"]', state='visible', timeout=5000)
                self.page.fill('input[name="username"]', CRM_USERNAME)
                self.page.fill('input[name="password"]', CRM_PASSWORD)
                self.page.click('input[type="submit"]')
            except:
                try:
                    self.page.wait_for_selector(
                        'input[name="user"]', state='visible', timeout=3000)
                    self.page.fill('input[name="user"]', CRM_USERNAME)
                    self.page.fill('input[name="password"]', CRM_PASSWORD)
                    self.page.click('input[type="submit"]')
                except:
                    self.page.wait_for_selector(
                        'text=Username', state='visible', timeout=10000)
                    time.sleep(0.5)
                    self.page.get_by_role(
                        'textbox', name='Username').fill(CRM_USERNAME)
                    self.page.get_by_role(
                        'textbox', name='Password').fill(CRM_PASSWORD)
                    self.page.get_by_role('button', name='Login').click()

            self.page.wait_for_load_state('networkidle', timeout=30000)
            time.sleep(2)

            current_url = self.page.url
            logger.info(f"Current URL after login: {current_url}")

            if 'p=login' in current_url or self.page.query_selector('input[name="username"]'):
                page_content = self.page.content()
                if 'error' in page_content.lower() or 'invalid' in page_content.lower():
                    logger.error("Login failed - error message detected on page")
                else:
                    logger.error("Still on login page - form may not have submitted correctly")
                return False

            if self.page.query_selector('ul#active') or self.page.query_selector('.restaurantList'):
                logger.info("Login successful - found restaurant list")
                return True
            elif 'restaurants' in current_url:
                logger.info("Login successful - on restaurants page")
                return True
            else:
                logger.info("Login appears successful")
                return True

        except Exception as e:
            logger.error(f"Login failed with exception: {e}")
            return False

    # =========================================================================
    # Navigation
    # =========================================================================

    def navigate_to_menu(self, v1_id: int) -> bool:
        """Navigate to restaurant menu page."""
        url = MENU_URL_PATTERN.format(v1_id=v1_id)
        logger.debug(f"Navigating to menu: {url}")
        
        try:
            self.page.goto(url, wait_until='domcontentloaded')
            self.page.wait_for_load_state('networkidle', timeout=15000)
            time.sleep(SCRAPE_DELAY)
            return True
        except Exception as e:
            logger.error(f"Failed to navigate to menu: {e}")
            return False

    def navigate_to_combo_dish(self, v1_id: int, combo_id: int) -> bool:
        """Navigate to combo dish details page."""
        url = COMBO_DISH_URL_PATTERN.format(v1_id=v1_id, combo_id=combo_id)
        logger.debug(f"Navigating to combo dish: {url}")
        
        try:
            self.page.goto(url, wait_until='domcontentloaded')
            self.page.wait_for_load_state('networkidle', timeout=15000)
            time.sleep(SCRAPE_DELAY)
            return True
        except Exception as e:
            logger.error(f"Failed to navigate to combo dish: {e}")
            return False

    # =========================================================================
    # Extraction
    # =========================================================================

    def get_combo_dish_links(self, v1_id: int) -> List[Dict[str, Any]]:
        """Extract combo dish links from menu page."""
        if not self.navigate_to_menu(v1_id):
            return []
        
        html = self.page.content()
        soup = BeautifulSoup(html, 'html.parser')
        
        combo_dishes = []
        
        for link in soup.find_all('a', href=re.compile(r'combo=\d+')):
            href = link.get('href', '')
            match = re.search(r'combo=(\d+)', href)
            if match:
                combo_id = int(match.group(1))
                dish_name = link.get_text(strip=True)
                
                combo_dishes.append({
                    'combo_id': combo_id,
                    'name': dish_name
                })
        
        logger.info(f"Found {len(combo_dishes)} combo dishes for V1 restaurant {v1_id}")
        return combo_dishes

    def parse_drinks_section(self, html: str) -> Optional[Dict[str, Any]]:
        """
        Parse drinks section from combo dish page HTML.
        
        Returns dict with title (from drinksHeader), min, max, free_items, display_order
        or None if no valid drinks section found.
        """
        soup = BeautifulSoup(html, 'html.parser')
        
        # CONDITION 1: Check if drinks section div exists
        drinks_div = soup.find('div', id=DRINKS_SECTION_CONFIG['div_id'])
        if not drinks_div:
            return None
        
        # CONDITION 2: Check if drinks div is visible
        style_attr = drinks_div.get('style', '')
        if 'display' in style_attr.lower() and 'none' in style_attr.lower():
            return None
        
        # CONDITION 3: Check if hasDrinks checkbox exists and is checked
        has_drinks_checkbox = soup.find('input', id=DRINKS_SECTION_CONFIG['checkbox_id'])
        if not has_drinks_checkbox:
            return None
        
        is_checked = has_drinks_checkbox.get('checked') is not None or 'checked' in str(has_drinks_checkbox)
        if not is_checked:
            return None
        
        # CONDITION 4: Find checked radio button
        radio_buttons = soup.find_all('input', {'type': 'radio', 'name': DRINKS_SECTION_CONFIG['radio_name']})
        
        has_checked_radio = False
        for radio in radio_buttons:
            if radio.get('checked') is not None or 'checked' in str(radio):
                has_checked_radio = True
                break
        
        if not has_checked_radio:
            return None
        
        # Get title from drinksHeader - THIS IS THE KEY LOOKUP VALUE
        title_input = soup.find('input', {'name': DRINKS_SECTION_CONFIG['header_input']})
        title = None
        if title_input:
            title = title_input.get('value', '').strip()
        
        if not title:
            # No title means we can't look up the modifier group
            return None
        
        result = {
            'title': title,  # This becomes modifier_groups.name and is used for lookup
            'min_selections': 0,
            'max_selections': 1,
            'free_items': 0,
            'display_order': None
        }
        
        # Get min selections
        min_input = soup.find('input', {'name': DRINKS_SECTION_CONFIG['min_input']})
        if min_input:
            try:
                result['min_selections'] = int(min_input.get('value', 0))
            except (ValueError, TypeError):
                result['min_selections'] = 0
        
        # Get max selections
        max_input = soup.find('input', {'name': DRINKS_SECTION_CONFIG['max_input']})
        if max_input:
            try:
                result['max_selections'] = int(max_input.get('value', 1))
            except (ValueError, TypeError):
                result['max_selections'] = 1
        
        # Get free items
        free_input = soup.find('input', {'name': DRINKS_SECTION_CONFIG['free_input']})
        if free_input:
            try:
                result['free_items'] = int(free_input.get('value', 0))
            except (ValueError, TypeError):
                result['free_items'] = 0
        
        # Get display order
        display_order_input = soup.find('input', {'name': DRINKS_SECTION_CONFIG['display_order_input']})
        if display_order_input:
            try:
                result['display_order'] = int(display_order_input.get('value', 0))
            except (ValueError, TypeError):
                result['display_order'] = None
        
        return result

    # =========================================================================
    # Comparison Logic
    # =========================================================================

    def needs_update(self, v1_data: Dict[str, Any], v3_modifier_group: Dict[str, Any]) -> bool:
        """
        Compare V1 scraped data with V3 database data.
        
        Returns True if any field differs and an update is needed.
        """
        # Compare name (title)
        if v1_data['title'] != v3_modifier_group.get('name'):
            logger.debug(f"  Name differs: V1='{v1_data['title']}' vs V3='{v3_modifier_group.get('name')}'")
            return True
        
        # Compare min_selections
        if v1_data['min_selections'] != v3_modifier_group.get('min_selections', 0):
            logger.debug(f"  min_selections differs: V1={v1_data['min_selections']} vs V3={v3_modifier_group.get('min_selections')}")
            return True
        
        # Compare max_selections
        if v1_data['max_selections'] != v3_modifier_group.get('max_selections', 1):
            logger.debug(f"  max_selections differs: V1={v1_data['max_selections']} vs V3={v3_modifier_group.get('max_selections')}")
            return True
        
        # Compare free_items
        if v1_data['free_items'] != v3_modifier_group.get('free_items', 0):
            logger.debug(f"  free_items differs: V1={v1_data['free_items']} vs V3={v3_modifier_group.get('free_items')}")
            return True
        
        # Compare display_order (only if V1 has a value)
        if v1_data['display_order'] is not None:
            if v1_data['display_order'] != v3_modifier_group.get('display_order'):
                logger.debug(f"  display_order differs: V1={v1_data['display_order']} vs V3={v3_modifier_group.get('display_order')}")
                return True
        
        return False

    # =========================================================================
    # Main Scraping Logic
    # =========================================================================

    def scrape_combo_dish(
        self, 
        restaurant_id: int, 
        v1_id: int, 
        combo_id: int, 
        dish_name: str
    ) -> Dict[str, Any]:
        """
        Scrape and conditionally update drinks modifier settings for a single combo dish.
        
        Returns:
            Dict with status: 'updated', 'skipped_no_change', 'skipped_no_drinks', 
                             'skipped_no_dish', 'skipped_no_mg', 'error'
        """
        result = {
            'status': 'skipped_no_drinks',
            'dish_name': dish_name,
            'combo_id': combo_id
        }
        
        # Navigate to combo dish page
        if not self.navigate_to_combo_dish(v1_id, combo_id):
            result['status'] = 'error'
            return result
        
        # Parse drinks section
        html = self.page.content()
        drinks_data = self.parse_drinks_section(html)
        
        if not drinks_data:
            # No drinks section - skip silently
            return result
        
        logger.debug(f"  Found drinks section for: {dish_name}")
        logger.debug(f"    Title: {drinks_data['title']}, Min: {drinks_data['min_selections']}, Max: {drinks_data['max_selections']}, Free: {drinks_data['free_items']}")
        
        # Find V3 dish by combo source_id
        dish = self.db.get_dish_by_combo_source_id(restaurant_id, combo_id)
        if not dish:
            # Dish not found in V3 - skip silently
            result['status'] = 'skipped_no_dish'
            return result
        
        dish_id = dish['id']
        
        # Find modifier group by title (drinksHeader value)
        # This is the key difference from original scraper
        modifier_group = self.db.get_modifier_group_by_name(dish_id, drinks_data['title'])
        
        if not modifier_group:
            # Try fallback - find any drinks modifier group
            modifier_group = self.db.find_drinks_modifier_group(dish_id)
        
        if not modifier_group:
            # No modifier group found - skip silently (no warning)
            result['status'] = 'skipped_no_mg'
            return result
        
        # Compare V1 data with V3 data
        if not self.needs_update(drinks_data, modifier_group):
            # Data is the same - skip
            logger.debug(f"    No update needed for: {dish_name}")
            result['status'] = 'skipped_no_change'
            result['modifier_group_id'] = modifier_group['id']
            return result
        
        # Update modifier group settings
        success = self.db.update_modifier_group_drinks_settings(
            modifier_group_id=modifier_group['id'],
            name=drinks_data['title'],
            min_selections=drinks_data['min_selections'],
            max_selections=drinks_data['max_selections'],
            free_items=drinks_data['free_items'],
            display_order=drinks_data['display_order']
        )
        
        if success:
            logger.info(f"  Updated: {dish_name} -> modifier_group {modifier_group['id']}: name='{drinks_data['title']}', min={drinks_data['min_selections']}, max={drinks_data['max_selections']}, free={drinks_data['free_items']}, order={drinks_data['display_order']}")
            result['status'] = 'updated'
            result['modifier_group_id'] = modifier_group['id']
            result['new_values'] = drinks_data
        else:
            result['status'] = 'error'
        
        return result

    def scrape_restaurant(self, restaurant_id: int, v1_id: int, restaurant_name: str = '') -> Dict[str, Any]:
        """
        Scrape all combo dishes for a restaurant using upsert logic.
        
        Returns:
            Dict with scraping statistics
        """
        self.current_restaurant = {
            'id': restaurant_id,
            'v1_id': v1_id,
            'name': restaurant_name
        }
        
        stats = {
            'combo_dishes_found': 0,
            'updated': 0,
            'skipped_no_change': 0,
            'skipped_no_drinks': 0,
            'skipped_no_dish': 0,
            'skipped_no_mg': 0,
            'errors': 0
        }
        
        logger.info(f"Scraping: {restaurant_name} (V3: {restaurant_id}, V1: {v1_id})")
        
        # Get combo dish links from menu page
        combo_dishes = self.get_combo_dish_links(v1_id)
        stats['combo_dishes_found'] = len(combo_dishes)
        
        if not combo_dishes:
            logger.info(f"  No combo dishes found")
            return stats
        
        # Process each combo dish
        for combo_dish in combo_dishes:
            try:
                result = self.scrape_combo_dish(
                    restaurant_id=restaurant_id,
                    v1_id=v1_id,
                    combo_id=combo_dish['combo_id'],
                    dish_name=combo_dish['name']
                )
                
                status = result['status']
                if status == 'updated':
                    stats['updated'] += 1
                elif status == 'skipped_no_change':
                    stats['skipped_no_change'] += 1
                elif status == 'skipped_no_drinks':
                    stats['skipped_no_drinks'] += 1
                elif status == 'skipped_no_dish':
                    stats['skipped_no_dish'] += 1
                elif status == 'skipped_no_mg':
                    stats['skipped_no_mg'] += 1
                elif status == 'error':
                    stats['errors'] += 1
                    
            except Exception as e:
                logger.error(f"  Error processing {combo_dish['name']}: {e}")
                stats['errors'] += 1
        
        logger.info(f"  Results: {stats['updated']} updated, {stats['skipped_no_change']} no change, {stats['skipped_no_mg']} no MG")
        
        return stats

