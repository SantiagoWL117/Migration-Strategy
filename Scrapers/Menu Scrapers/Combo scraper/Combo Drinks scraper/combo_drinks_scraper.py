"""Combo Drinks Modifier Group Scraper using Playwright for browser automation."""
import re
import time
import logging
from typing import Optional, Dict, List, Any, Tuple
from bs4 import BeautifulSoup
from playwright.sync_api import sync_playwright, Page, Browser, BrowserContext

from combo_drinks_config import (
    CRM_LOGIN_URL, MENU_URL_PATTERN, COMBO_DISH_URL_PATTERN,
    CRM_USERNAME, CRM_PASSWORD,
    DRINKS_SECTION_CONFIG, TIMEOUT, NAVIGATION_TIMEOUT, SCRAPE_DELAY
)
from combo_drinks_database import ComboDrinksDatabase

logger = logging.getLogger(__name__)


class ComboDrinksScraper:
    """Scraper for drinks modifier groups from combo dishes in V1 CRM."""

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
        logger.info("Starting Combo Drinks Scraper...")

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
        logger.info("Stopping Combo Drinks Scraper...")

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

            # The form uses name="username" and name="password" with a submit button
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
                    # Fallback: Use role-based selectors
                    logger.info("Using role-based selectors for login form")
                    self.page.wait_for_selector(
                        'text=Username', state='visible', timeout=10000)
                    time.sleep(0.5)
                    self.page.get_by_role(
                        'textbox', name='Username').fill(CRM_USERNAME)
                    self.page.get_by_role(
                        'textbox', name='Password').fill(CRM_PASSWORD)
                    self.page.get_by_role('button', name='Login').click()

            # Wait for navigation after login
            self.page.wait_for_load_state('networkidle', timeout=30000)
            time.sleep(2)

            # Log current URL for debugging
            current_url = self.page.url
            logger.info(f"Current URL after login: {current_url}")

            # Check if we're still on the login page
            if 'p=login' in current_url or self.page.query_selector('input[name="username"]'):
                page_content = self.page.content()
                if 'error' in page_content.lower() or 'invalid' in page_content.lower():
                    logger.error("Login failed - error message detected on page")
                else:
                    logger.error("Still on login page - form may not have submitted correctly")
                return False

            # Check if login successful
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
        """
        Extract combo dish links from menu page.
        
        Looks for links with 'combo=' in href.
        
        Returns:
            List of dicts with combo_id and dish_name
        """
        if not self.navigate_to_menu(v1_id):
            return []
        
        html = self.page.content()
        soup = BeautifulSoup(html, 'html.parser')
        
        combo_dishes = []
        
        # Find all links with combo= in href
        for link in soup.find_all('a', href=re.compile(r'combo=\d+')):
            href = link.get('href', '')
            match = re.search(r'combo=(\d+)', href)
            if match:
                combo_id = int(match.group(1))
                dish_name = link.get_text(strip=True)
                
                # Get description if present (text after ' - ')
                parent_li = link.find_parent('li')
                description = ''
                if parent_li:
                    full_text = parent_li.get_text(strip=True)
                    if ' - ' in full_text:
                        description = full_text.split(' - ', 1)[1]
                
                combo_dishes.append({
                    'combo_id': combo_id,
                    'name': dish_name,
                    'description': description
                })
        
        logger.info(f"Found {len(combo_dishes)} combo dishes for V1 restaurant {v1_id}")
        return combo_dishes

    def parse_drinks_section(self, html: str) -> Optional[Dict[str, Any]]:
        """
        Parse drinks section from combo dish page HTML.
        
        Skip conditions (returns None):
        1. div#d_id not found
        2. div#d_id has style="display: none" (hidden)
        3. input#hasDrinks checkbox not found or not checked
        4. No radio button is checked (no modifier group selected)
        
        Returns:
            Dict with modifier_group_name, min, max, free_items or None if no drinks section
        """
        soup = BeautifulSoup(html, 'html.parser')
        
        # CONDITION 1: Check if drinks section div exists
        drinks_div = soup.find('div', id=DRINKS_SECTION_CONFIG['div_id'])
        if not drinks_div:
            return None
        
        # CONDITION 2: Check if drinks div is visible
        # style="" means visible, style="display: none" means hidden
        style_attr = drinks_div.get('style', '')
        if 'display' in style_attr.lower() and 'none' in style_attr.lower():
            # Div is hidden (style="display: none"), skip this dish
            return None
        
        # CONDITION 3: Check if hasDrinks checkbox exists and is checked
        has_drinks_checkbox = soup.find('input', id=DRINKS_SECTION_CONFIG['checkbox_id'])
        if not has_drinks_checkbox:
            # Checkbox not found, skip
            return None
        
        # Check if checkbox is checked (handles both checked="" and checked attributes)
        is_checked = has_drinks_checkbox.get('checked') is not None or 'checked' in str(has_drinks_checkbox)
        if not is_checked:
            # Checkbox exists but is not checked, skip
            return None
        
        # CONDITION 4: Find checked radio button for modifier group
        # Radio buttons have name="d_radio" and the active one must be checked
        radio_buttons = soup.find_all('input', {'type': 'radio', 'name': DRINKS_SECTION_CONFIG['radio_name']})
        
        modifier_group_name = None
        for radio in radio_buttons:
            radio_is_checked = radio.get('checked') is not None or 'checked' in str(radio)
            if radio_is_checked:
                # Find the label for this radio button
                radio_id = radio.get('id')
                if radio_id:
                    label = soup.find('label', {'for': radio_id})
                    if label:
                        modifier_group_name = label.get_text(strip=True)
                        break
                # Fallback: check for label as next sibling
                label = radio.find_next('label')
                if label:
                    modifier_group_name = label.get_text(strip=True)
                    break
        
        # If no radio button is checked, skip this dish
        if not modifier_group_name:
            return None
        
        result = {
            'modifier_group_name': modifier_group_name,  # Radio button label - used to find existing modifier group
            'title': None,                               # drinksHeader value - becomes new modifier_groups.name
            'min_selections': 0,
            'max_selections': 1,
            'free_items': 0,
            'display_order': None
        }
        
        # Get title from drinksHeader input
        title_input = soup.find('input', {'name': DRINKS_SECTION_CONFIG['header_input']})
        if title_input:
            result['title'] = title_input.get('value', '')
        
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
        
        # All validations passed, return the result
        # (modifier_group_name is guaranteed to be set due to earlier check)
        return result

    # =========================================================================
    # Main Scraping Logic
    # =========================================================================

    def scrape_combo_dish(
        self, 
        restaurant_id: int, 
        v1_id: int, 
        combo_id: int, 
        dish_name: str
    ) -> Optional[Dict[str, Any]]:
        """
        Scrape drinks modifier settings for a single combo dish.
        
        Args:
            restaurant_id: V3 restaurant ID
            v1_id: V1 restaurant ID
            combo_id: V1 combo ID (from URL)
            dish_name: Dish name for logging
            
        Returns:
            Dict with update result or None if no drinks section
        """
        # Navigate to combo dish page
        if not self.navigate_to_combo_dish(v1_id, combo_id):
            logger.warning(f"  Could not navigate to combo dish {combo_id}")
            return None
        
        # Parse drinks section
        html = self.page.content()
        drinks_data = self.parse_drinks_section(html)
        
        if not drinks_data:
            logger.debug(f"  No drinks section for: {dish_name}")
            return None
        
        logger.info(f"  Found drinks section for: {dish_name}")
        logger.info(f"    Modifier group (radio): {drinks_data['modifier_group_name']}")
        logger.info(f"    Title (new name): {drinks_data['title']}")
        logger.info(f"    Min: {drinks_data['min_selections']}, Max: {drinks_data['max_selections']}, Free: {drinks_data['free_items']}, Order: {drinks_data['display_order']}")
        
        # Find V3 dish by combo source_id
        dish = self.db.get_dish_by_combo_source_id(restaurant_id, combo_id)
        if not dish:
            logger.warning(f"  V3 dish not found for combo_id {combo_id} ({dish_name})")
            return None
        
        dish_id = dish['id']
        
        # Find modifier group by name
        modifier_group = self.db.get_modifier_group_by_name(dish_id, drinks_data['modifier_group_name'])
        
        if not modifier_group:
            # Try to find any drinks modifier group
            modifier_group = self.db.find_drinks_modifier_group(dish_id)
            if modifier_group:
                logger.info(f"    Found alternative drinks modifier: {modifier_group['name']}")
        
        if not modifier_group:
            logger.warning(f"  Modifier group '{drinks_data['modifier_group_name']}' not found for dish {dish_id}")
            return None
        
        # Determine the new name - use title from drinksHeader if available
        new_name = drinks_data['title'] if drinks_data['title'] else modifier_group['name']
        
        # Update modifier group settings
        success = self.db.update_modifier_group_drinks_settings(
            modifier_group_id=modifier_group['id'],
            name=new_name,
            min_selections=drinks_data['min_selections'],
            max_selections=drinks_data['max_selections'],
            free_items=drinks_data['free_items'],
            display_order=drinks_data['display_order']
        )
        
        if success:
            logger.info(f"    Updated modifier_group {modifier_group['id']}: name='{new_name}', order={drinks_data['display_order']}")
            return {
                'dish_id': dish_id,
                'dish_name': dish_name,
                'modifier_group_id': modifier_group['id'],
                'modifier_group_name': new_name,
                'min_selections': drinks_data['min_selections'],
                'max_selections': drinks_data['max_selections'],
                'free_items': drinks_data['free_items'],
                'display_order': drinks_data['display_order']
            }
        else:
            logger.error(f"    Failed to update modifier_group {modifier_group['id']}")
            return None

    def scrape_restaurant(self, restaurant_id: int, v1_id: int, restaurant_name: str = '') -> Dict[str, Any]:
        """
        Scrape all combo dishes for a restaurant.
        
        Args:
            restaurant_id: V3 restaurant ID
            v1_id: V1 restaurant ID
            restaurant_name: Restaurant name for logging
            
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
            'drinks_sections_found': 0,
            'modifier_groups_updated': 0,
            'errors': 0
        }
        
        logger.info(f"Scraping combo drinks for: {restaurant_name} (V3: {restaurant_id}, V1: {v1_id})")
        
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
                
                if result:
                    stats['drinks_sections_found'] += 1
                    stats['modifier_groups_updated'] += 1
                    
            except Exception as e:
                logger.error(f"  Error processing {combo_dish['name']}: {e}")
                stats['errors'] += 1
        
        logger.info(f"  Completed: {stats['drinks_sections_found']} drinks sections, {stats['modifier_groups_updated']} modifier groups updated")
        
        return stats

