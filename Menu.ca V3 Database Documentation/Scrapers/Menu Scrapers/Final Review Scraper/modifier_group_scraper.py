"""Modifier Group Details Scraper using Playwright for browser automation."""
import re
import time
import logging
from typing import Optional, Dict, List, Any
from bs4 import BeautifulSoup
from playwright.sync_api import sync_playwright, Page, Browser, BrowserContext

from modifier_group_config import (
    CRM_LOGIN_URL,
    MENU_URL_PATTERN, DISH_DETAIL_URL_PATTERN,
    CRM_USERNAME, CRM_PASSWORD,
    TIMEOUT, NAVIGATION_TIMEOUT, SCRAPE_DELAY,
    SECTION_CONFIG, DAY_MAPPING
)
from modifier_group_database import ModifierGroupDatabase

logger = logging.getLogger(__name__)


class ModifierGroupScraper:
    """Scraper for modifier group details and dish availability."""

    def __init__(self, headless: bool = True):
        self.headless = headless
        self.playwright = None
        self.browser: Optional[Browser] = None
        self.context: Optional[BrowserContext] = None
        self.page: Optional[Page] = None
        self.db: Optional[ModifierGroupDatabase] = None

    def start(self):
        """Initialize browser and database connections."""
        logger.info("Starting Modifier Group Details Scraper...")

        # Start Playwright
        self.playwright = sync_playwright().start()
        self.browser = self.playwright.chromium.launch(headless=self.headless)
        self.context = self.browser.new_context()
        self.page = self.context.new_page()
        self.page.set_default_timeout(TIMEOUT)
        self.page.set_default_navigation_timeout(NAVIGATION_TIMEOUT)

        # Connect to database
        self.db = ModifierGroupDatabase()
        self.db.connect()

        logger.info("Browser and database connections established")

    def stop(self):
        """Close all connections."""
        logger.info("Stopping Modifier Group Details Scraper...")

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

    def navigate_to_menu(self, v1_id: int) -> bool:
        """Navigate to the menu page for a restaurant."""
        url = MENU_URL_PATTERN.format(v1_id=v1_id)
        logger.info(f"Navigating to menu: {url}")

        try:
            self.page.goto(url)
            self.page.wait_for_load_state('networkidle')
            time.sleep(SCRAPE_DELAY)
            return True
        except Exception as e:
            logger.error(f"Failed to navigate to menu: {e}")
            return False

    def navigate_to_dish_details(self, v1_id: int, menu_entry_id: int) -> bool:
        """Navigate to the dish details page."""
        url = DISH_DETAIL_URL_PATTERN.format(
            v1_id=v1_id,
            menu_entry_id=menu_entry_id
        )
        logger.debug(f"Navigating to dish details: {url}")

        try:
            self.page.goto(url)
            self.page.wait_for_load_state('networkidle')
            time.sleep(SCRAPE_DELAY)
            return True
        except Exception as e:
            logger.error(f"Failed to navigate to dish details: {e}")
            return False

    # =========================================================================
    # Menu Page Parsing
    # =========================================================================

    def get_dish_links(self) -> List[Dict[str, Any]]:
        """
        Get all non-combo dish links from the menu page.
        
        Returns list of dicts with:
            - name: Dish name
            - menu_entry_id: V1 menuEntry ID (source_id)
        """
        dishes = []
        html_content = self.page.content()
        soup = BeautifulSoup(html_content, 'html.parser')

        # Find the menu div
        menu_div = soup.find('div', {'style': lambda x: x and 'width:500px' in x and 'float: left' in x})
        if not menu_div:
            logger.warning("Could not find menu div")
            return dishes

        # Find all dish links (non-combo)
        for a_tag in menu_div.find_all('a', href=True):
            href = a_tag.get('href', '')
            
            # Skip combo dishes (href contains 'combo=')
            if 'combo=' in href:
                continue

            # Match normal dishes (href contains 'menuEntry=')
            match = re.search(r'menuEntry=(\d+)', href)
            if match:
                menu_entry_id = int(match.group(1))
                name = a_tag.get_text().strip()
                dishes.append({
                    'name': name,
                    'menu_entry_id': menu_entry_id
                })
                logger.debug(f"Found dish: {name} (menuEntry={menu_entry_id})")

        logger.info(f"Found {len(dishes)} non-combo dishes")
        return dishes

    # =========================================================================
    # Dish Details Page Parsing
    # =========================================================================

    def parse_section_settings(self, html: str) -> Dict[str, Dict[str, Any]]:
        """
        Parse section settings from dish details page.
        
        Returns dict keyed by section_id (e.g., 'ci_id') with values:
            - enabled: bool (checkbox is checked)
            - header: str (use_header value)
            - min_selections: int or None
            - max_selections: int or None
            - free_items: int or None
            - display_order: int
            - active_modifier_group: str or None (name of checked modifier group)
        """
        soup = BeautifulSoup(html, 'html.parser')
        sections = {}

        for section_id, config in SECTION_CONFIG.items():
            section_data = {
                'enabled': False,
                'header': None,
                'min_selections': None,
                'max_selections': None,
                'free_items': None,
                'display_order': None,
                'active_modifier_group': None,
            }

            # Check if section is enabled (checkbox is checked)
            checkbox = soup.find('input', {'id': config['checkbox_id']})
            if checkbox and checkbox.has_attr('checked'):
                section_data['enabled'] = True

                # Get header value
                header_input = soup.find('input', {'name': config['header_name']})
                if header_input:
                    section_data['header'] = header_input.get('value', '').strip()

                # Get min/max/free values (if applicable)
                if config['min_name']:
                    min_input = soup.find('input', {'name': config['min_name']})
                    if min_input:
                        val = min_input.get('value', '0')
                        # Handle comma-separated values (take first)
                        section_data['min_selections'] = self._parse_numeric_value(val)

                if config['max_name']:
                    max_input = soup.find('input', {'name': config['max_name']})
                    if max_input:
                        val = max_input.get('value', '0')
                        section_data['max_selections'] = self._parse_numeric_value(val)

                if config['free_name']:
                    free_input = soup.find('input', {'name': config['free_name']})
                    if free_input:
                        val = free_input.get('value', '0')
                        section_data['free_items'] = self._parse_numeric_value(val)

                # Get display order
                order_input = soup.find('input', {'name': config['order_name']})
                if order_input:
                    val = order_input.get('value', '0')
                    section_data['display_order'] = self._parse_numeric_value(val)

                # Get active modifier group (checked radio button)
                section_div = soup.find('div', {'id': section_id})
                if section_div:
                    active_radio = section_div.find('input', {'type': 'radio', 'checked': True})
                    if active_radio:
                        # Find the label for this radio
                        radio_id = active_radio.get('id', '')
                        label = soup.find('label', {'for': radio_id})
                        if label:
                            section_data['active_modifier_group'] = label.get_text().strip()

            sections[section_id] = section_data

        return sections

    @staticmethod
    def _parse_numeric_value(value: str) -> int:
        """Parse numeric value, handling comma-separated lists (take first value)."""
        if not value:
            return 0
        try:
            # Handle comma-separated values (e.g., "1,2,3,3" for drinks)
            if ',' in value:
                value = value.split(',')[0]
            return int(value.strip())
        except (ValueError, IndexError):
            return 0

    def parse_dish_availability(self, html: str) -> List[int]:
        """
        Parse dish availability (hide-on-days) from dish details page.
        
        Returns list of day_of_week integers (0=Sunday, 1=Monday, etc.)
        for days that are checked (hidden).
        """
        soup = BeautifulSoup(html, 'html.parser')
        hidden_days = []

        # Find all hide-on-days checkboxes
        for checkbox in soup.find_all('input', {'name': 'hideOnDays[]'}):
            if checkbox.has_attr('checked'):
                day_value = checkbox.get('value', '')
                if day_value in DAY_MAPPING:
                    hidden_days.append(DAY_MAPPING[day_value])

        return hidden_days

    # =========================================================================
    # Main Scraping Logic
    # =========================================================================

    def scrape_restaurant(self, restaurant_id: int, v1_id: int) -> Dict[str, int]:
        """
        Scrape modifier group details for a restaurant.
        
        Args:
            restaurant_id: V3 restaurant ID
            v1_id: V1 restaurant ID
            
        Returns:
            Stats dict with counts
        """
        stats = {
            'dishes_processed': 0,
            'modifier_groups_updated': 0,
            'dish_availability_updated': 0,
            'errors': 0
        }

        # Get dishes from database (to get V3 dish IDs)
        db_dishes = self.db.get_dishes_by_restaurant(restaurant_id)
        if not db_dishes:
            logger.warning(f"No dishes found in database for restaurant {restaurant_id}")
            return stats

        # Create lookup by source_id
        dish_lookup = {d['source_id']: d for d in db_dishes}
        logger.info(f"Found {len(db_dishes)} dishes in database for restaurant {restaurant_id}")

        # Navigate to menu page
        if not self.navigate_to_menu(v1_id):
            return stats

        # Get dish links from page
        dish_links = self.get_dish_links()
        logger.info(f"Found {len(dish_links)} dish links on menu page")

        # Process each dish
        for dish_info in dish_links:
            menu_entry_id = dish_info['menu_entry_id']
            dish_name = dish_info['name']

            # Find matching V3 dish
            v3_dish = dish_lookup.get(menu_entry_id)
            if not v3_dish:
                logger.debug(f"Dish not in database: {dish_name} (menuEntry={menu_entry_id})")
                continue

            dish_id = v3_dish['id']
            logger.debug(f"Processing dish: {dish_name} (V3 ID={dish_id})")

            try:
                # Navigate to dish details
                if not self.navigate_to_dish_details(v1_id, menu_entry_id):
                    stats['errors'] += 1
                    continue

                # Get page HTML
                html_content = self.page.content()

                # Parse section settings
                sections = self.parse_section_settings(html_content)

                # Update modifier groups for each enabled section
                for section_id, section_data in sections.items():
                    if not section_data['enabled']:
                        continue

                    # Get the header value - this is what's stored as modifier_groups.name in V3
                    header_name = section_data['header']
                    if not header_name:
                        continue

                    # Find matching modifier group in V3 by header name
                    mg = self.db.get_modifier_group_by_name(dish_id, header_name)
                    if not mg:
                        logger.debug(f"Modifier group not found: '{header_name}' for dish {dish_id}")
                        continue

                    # Update modifier group details
                    updated = self.db.update_modifier_group_details(
                        modifier_group_id=mg['id'],
                        min_selections=section_data['min_selections'],
                        max_selections=section_data['max_selections'],
                        free_items=section_data['free_items'],
                        display_order=section_data['display_order']
                    )
                    if updated:
                        stats['modifier_groups_updated'] += 1
                        logger.debug(f"Updated modifier_group '{header_name}' (ID={mg['id']})")

                # Parse and update dish availability
                hidden_days = self.parse_dish_availability(html_content)
                
                if hidden_days:
                    # Set hide_option_enabled flag
                    self.db.update_dish_hide_option(dish_id, True)
                    
                    # Clear existing and insert new
                    self.db.clear_dish_availability(dish_id)
                    for day in hidden_days:
                        self.db.upsert_dish_availability(dish_id, day, is_hidden=True)
                        stats['dish_availability_updated'] += 1
                else:
                    # No hidden days - ensure flag is false
                    self.db.update_dish_hide_option(dish_id, False)

                stats['dishes_processed'] += 1

            except Exception as e:
                logger.error(f"Error processing dish {dish_name}: {e}", exc_info=True)
                stats['errors'] += 1

        return stats

