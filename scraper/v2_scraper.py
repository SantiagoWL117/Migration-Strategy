#!/usr/bin/env python3
"""
V2 Menu Scraper - Scrapes menu data from aggregator-admin.menu.ca
HYBRID APPROACH: Outputs to JSON files, NO direct database connections
"""
import logging
import time
from playwright.sync_api import sync_playwright, Page, TimeoutError as PlaywrightTimeout
from bs4 import BeautifulSoup
from typing import Optional, Dict, List

logger = logging.getLogger(__name__)

class V2MenuScraper:
    """Scraper for V2 admin system (aggregator-admin.menu.ca)"""
    
    def __init__(self, base_url: str, username: str, password: str, headless: bool = True):
        self.base_url = base_url
        self.username = username
        self.password = password
        self.headless = headless
        self.playwright = None
        self.browser = None
        self.context = None
        self.page = None
        self.logged_in = False
    
    def start(self):
        """Initialize Playwright browser."""
        logger.info("Starting browser...")
        self.playwright = sync_playwright().start()
        self.browser = self.playwright.chromium.launch(headless=self.headless)
        self.context = self.browser.new_context()
        self.page = self.context.new_page()
        logger.info("Browser started successfully")
    
    def stop(self):
        """Close browser and cleanup."""
        if self.browser:
            self.browser.close()
        if self.playwright:
            self.playwright.stop()
        logger.info("Browser stopped")
    
    def login(self) -> bool:
        """Login to V2 admin system."""
        try:
            logger.info("Logging in to V2 admin...")
            login_url = self.base_url  # Root URL has the login form
            
            self.page.goto(login_url, timeout=60000)
            self.page.fill('input[name="email"]', self.username)
            self.page.fill('input[name="password"]', self.password)
            self.page.click('button[type="submit"]')
            
            # Wait for navigation after login
            self.page.wait_for_load_state('networkidle', timeout=30000)
            
            # Check if login successful
            page_content = self.page.content().lower()
            current_url = self.page.url.lower()
            
            # Successful login redirects away from login page
            if 'restaurants' in current_url or 'dashboard' in current_url or 'logout' in page_content:
                self.logged_in = True
                logger.info("✓ Login successful")
                logger.info(f"  Current URL: {self.page.url}")
                return True
            else:
                logger.error("✗ Login failed - check credentials")
                logger.error(f"  Current URL: {self.page.url}")
                return False
                
        except Exception as e:
            logger.error(f"✗ Login error: {e}")
            return False
    
    def scrape_restaurant_menu(self, v2_restaurant_id: int, db_restaurant_id: int) -> Optional[Dict]:
        """
        Scrape courses and dishes for a V2 restaurant.
        
        Args:
            v2_restaurant_id: V2 restaurant ID (legacy_v2_id)
            db_restaurant_id: menuca_v3 restaurant ID
        
        Returns:
            {
                'db_restaurant_id': 949,
                'v2_restaurant_id': 1636,
                'courses': [
                    {
                        'name': 'Shawarmas',
                        'description': '',
                        'display_order': 0,
                        'v2_course_id': '1122',
                        'dishes': [
                            {
                                'name': 'Shawarma 6" TRIO',
                                'description': 'Avec patate...',
                                'display_order': 0,
                                'v2_dish_id': '9001',
                                'prices': [
                                    {'size_variant': 'Poulet', 'price': 12.98, 'display_order': 0},
                                    {'size_variant': 'Boeuf', 'price': 12.98, 'display_order': 1},
                                    {'size_variant': 'Mixte', 'price': 13.69, 'display_order': 2}
                                ]
                            }
                        ]
                    }
                ]
            }
        """
        if not self.logged_in:
            logger.error("Not logged in")
            return None
        
        try:
            # Navigate to restaurant menu page (English first)
            menu_url = f"{self.base_url}/index.php/restaurants/edit/{v2_restaurant_id}/menu/restaurant"
            logger.info(f"Navigating to: {menu_url}")
            
            self.page.goto(menu_url, wait_until='networkidle', timeout=30000)
            time.sleep(2)  # Wait for dynamic content
            
            # Check if English or French menu
            html = self.page.content()
            soup = BeautifulSoup(html, 'lxml')
            
            # Check for sortable div (indicates English menu)
            sortable_div = soup.find('div', id='sortable')
            
            if not sortable_div:
                # French menu - navigate to French version
                logger.info("French menu detected, navigating to French version")
                french_url = f"{self.base_url}/index.php/restaurants/edit/{v2_restaurant_id}/menu/2/restaurant"
                self.page.goto(french_url, wait_until='networkidle', timeout=30000)
                time.sleep(2)
                html = self.page.content()
                soup = BeautifulSoup(html, 'lxml')
            
            # Extract courses
            courses = []
            course_divs = soup.find_all('div', class_='course-listing', attrs={'data-id': True})
            
            for course_idx, course_div in enumerate(course_divs):
                course_v2_id = course_div.get('data-id')
                course_name = course_div.get('data-course', '')
                
                # Get course description
                desc_textarea = course_div.find('textarea', attrs={'name': 'desc'})
                course_description = desc_textarea.text.strip() if desc_textarea else ''
                
                # Find dishes table
                dishes_table = course_div.find('table', class_='show-dishes')
                if not dishes_table:
                    logger.warning(f"No dishes table found for course: {course_name}")
                    continue
                
                # Extract dishes
                dishes = []
                dish_rows = dishes_table.find('tbody').find_all('tr', class_='sort') if dishes_table.find('tbody') else []
                
                for dish_idx, dish_row in enumerate(dish_rows):
                    v2_dish_id = dish_row.get('data-id')
                    if not v2_dish_id:
                        continue
                    
                    # Dish name
                    name_input = dish_row.find('input', attrs={'name': f'name[{v2_dish_id}]'})
                    dish_name = name_input.get('value', '').strip() if name_input else ''
                    
                    if not dish_name:
                        continue
                    
                    # Dish description
                    desc_input = dish_row.find('input', attrs={'name': f'desc[{v2_dish_id}]'})
                    dish_description = desc_input.get('value', '').strip() if desc_input else ''
                    
                    # Size variants (comma-separated)
                    size_input = dish_row.find('input', class_='size')
                    sizes_str = size_input.get('value', '').strip() if size_input else ''
                    size_variants = [s.strip() for s in sizes_str.split(',') if s.strip()] if sizes_str else ['standard']
                    
                    # Prices (comma-separated)
                    price_input = dish_row.find('input', class_='price')
                    prices_str = price_input.get('value', '').strip() if price_input else ''
                    price_values = [float(p.strip()) for p in prices_str.split(',') if p.strip()] if prices_str else [0.0]
                    
                    # Match sizes to prices
                    prices = []
                    for idx, (size, price) in enumerate(zip(size_variants, price_values)):
                        prices.append({
                            'size_variant': size,
                            'price': price,
                            'display_order': idx
                        })
                    
                    # Display order
                    display_order = int(dish_row.get('data-display_order', dish_idx))
                    
                    dishes.append({
                        'name': dish_name,
                        'description': dish_description,
                        'display_order': display_order,
                        'v2_dish_id': v2_dish_id,
                        'prices': prices
                    })
                
                if dishes:
                    courses.append({
                        'name': course_name,
                        'description': course_description,
                        'display_order': course_idx,
                        'v2_course_id': course_v2_id,
                        'dishes': dishes
                    })
            
            logger.info(f"✓ Extracted {len(courses)} courses with {sum(len(c['dishes']) for c in courses)} dishes")
            
            return {
                'db_restaurant_id': db_restaurant_id,
                'v2_restaurant_id': v2_restaurant_id,
                'courses': courses
            }
            
        except PlaywrightTimeout as e:
            logger.error(f"✗ Timeout error scraping restaurant menu: {e}")
            return None
        except Exception as e:
            logger.error(f"✗ Error scraping restaurant menu: {e}")
            import traceback
            traceback.print_exc()
            return None
    
    def scrape_dish_details(self, v2_dish_id: int, v2_restaurant_id: int) -> Optional[Dict]:
        """
        Scrape modifiers for a V2 dish.
        
        Args:
            v2_dish_id: V2 dish ID
            v2_restaurant_id: V2 restaurant ID (needed for modal URL)
        
        Returns:
            {
                'v2_dish_id': '9001',
                'modifiers': [
                    {
                        'name': 'Extras',
                        'type_code': 'extra',
                        'is_required': False,
                        'min_selections': 1,
                        'max_selections': 5,
                        'display_order': 0,
                        'items': [
                            {
                                'name': 'Extra Cheese',
                                'price': 2.00,
                                'display_order': 0,
                                'is_default': False
                            }
                        ]
                    }
                ]
            }
        """
        if not self.logged_in:
            logger.error("Not logged in")
            return None
        
        try:
            # Open dish edit modal
            logger.debug(f"Opening dish {v2_dish_id}")
            modal_url = f"{self.base_url}/index.php/ajax/restaurant_menu/edit_dish/{v2_dish_id}/{v2_restaurant_id}/2"
            
            self.page.goto(modal_url, timeout=30000)
            time.sleep(1)  # Wait for modal to render
            
            # Parse modal HTML
            html = self.page.content()
            soup = BeautifulSoup(html, 'lxml')
            
            # Extract modifiers
            modifiers = []
            
            # Find all modifier type panels
            modifier_panels = soup.select('.panel-group#group_dish_customization > .panel')
            
            for panel_idx, panel in enumerate(modifier_panels):
                # Get panel type from ID (e.g., #extra, #side_dish, #drink)
                panel_collapse = panel.select_one('.panel-collapse')
                if not panel_collapse:
                    continue
                
                type_code = panel_collapse.get('id', '')  # 'extra', 'side_dish', 'drink', etc.
                
                # Check if this modifier type is enabled
                enabled_checkbox = soup.select_one(f'input[name="customization[{type_code}][use]"]')
                if not enabled_checkbox or not enabled_checkbox.has_attr('checked'):
                    continue
                
                # Get configuration
                min_input = soup.select_one(f'input[name="customization[{type_code}][min]"]')
                max_input = soup.select_one(f'input[name="customization[{type_code}][max]"]')
                display_input = soup.select_one(f'input[name="customization[{type_code}][display_order]"]')
                title_input = soup.select_one(f'input[name="customization[{type_code}][title_paid]"]')
                
                modifier_group = {
                    'name': title_input.get('value', type_code.replace('_', ' ').title()) if title_input else type_code.replace('_', ' ').title(),
                    'type_code': type_code,
                    'is_required': int(min_input.get('value', 0)) > 0 if min_input else False,
                    'min_selections': int(min_input.get('value', 0)) if min_input else 0,
                    'max_selections': int(max_input.get('value', 1)) if max_input else 1,
                    'display_order': int(display_input.get('value', panel_idx)) if display_input else panel_idx,
                    'items': []
                }
                
                # Find selected group (checked radio button)
                selected_group_radio = soup.select_one(f'input[name="customization[{type_code}][group]"][checked]')
                if selected_group_radio:
                    group_id = selected_group_radio.get('value')
                    
                    # Find all items in this group
                    # Items are in text inputs with pattern: name="item[{group_id}][hash]"
                    item_inputs = soup.select(f'input[name^="item[{group_id}]"]')
                    
                    for idx, item_input in enumerate(item_inputs):
                        item_id = item_input.get('id', '')
                        
                        # Find the label for this item (item name)
                        item_label = soup.select_one(f'label[for="{item_id}"]')
                        item_name = item_label.get_text(strip=True) if item_label else f"Item {idx}"
                        
                        # Get price from the value attribute
                        try:
                            item_price = float(item_input.get('value', 0))
                        except (ValueError, TypeError):
                            item_price = 0.0
                        
                        # V2 doesn't mark default items in this structure
                        is_default = False
                        
                        modifier_group['items'].append({
                            'name': item_name,
                            'price': item_price,
                            'display_order': idx,
                            'is_default': is_default
                        })
                
                if modifier_group['items']:
                    modifiers.append(modifier_group)
            
            return {
                'v2_dish_id': v2_dish_id,
                'modifiers': modifiers
            }
            
        except PlaywrightTimeout as e:
            logger.error(f"✗ Timeout error scraping dish details: {e}")
            return None
        except Exception as e:
            logger.error(f"✗ Error scraping dish details for dish {v2_dish_id}: {e}")
            return None

