"""Menu scraper for CRM data extraction."""
import time
import logging
from typing import Dict, List, Optional, Tuple
from bs4 import BeautifulSoup
from playwright.sync_api import sync_playwright, Browser, Page
from config import (
    CRM_BASE_URL, CRM_USERNAME, CRM_PASSWORD,
    SCRAPE_DELAY, MENU_URL_PATTERN, DISH_DETAIL_URL_PATTERN
)

logger = logging.getLogger(__name__)


class MenuScraper:
    """Scrapes menu data from the CRM."""

    def __init__(self):
        self.base_url = CRM_BASE_URL
        self.username = CRM_USERNAME
        self.password = CRM_PASSWORD
        self.delay = SCRAPE_DELAY
        self.playwright = None
        self.browser = None
        self.page = None

    def start(self):
        """Start the browser and login."""
        self.playwright = sync_playwright().start()
        self.browser = self.playwright.chromium.launch(headless=True)
        self.page = self.browser.new_page()
        logger.info("Browser started")
        self._login()

    def stop(self):
        """Stop the browser."""
        if self.page:
            self.page.close()
        if self.browser:
            self.browser.close()
        if self.playwright:
            self.playwright.stop()
        logger.info("Browser stopped")

    def __enter__(self):
        self.start()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.stop()

    def _login(self):
        """Login to the CRM."""
        try:
            logger.info("Logging in to CRM...")
            self.page.goto(self.base_url)

            # Wait for login form
            self.page.wait_for_selector('input[name="username"], input[name="user"], input[type="text"]', timeout=10000)

            # Fill in credentials (adjust selectors as needed)
            self.page.fill('input[name="username"], input[name="user"], input[type="text"]', self.username)
            self.page.fill('input[name="password"], input[type="password"]', self.password)

            # Submit form
            self.page.click('input[type="submit"], button[type="submit"]')

            # Wait for navigation
            self.page.wait_for_load_state('networkidle')

            logger.info("Login successful")
        except Exception as e:
            logger.error(f"Login failed: {e}")
            raise

    def scrape_restaurant_menu(self, restaurant_id: int) -> Dict[str, List[Dict]]:
        """
        Scrape menu for a single restaurant.

        Returns:
            Dict with structure:
            {
                'restaurant_id': int,
                'courses': [
                    {
                        'name': str,
                        'description': str,
                        'display_order': int,
                        'dishes': [
                            {
                                'name': str,
                                'description': str,
                                'display_order': int,
                                'menu_entry_id': int
                            }
                        ]
                    }
                ]
            }
        """
        url = MENU_URL_PATTERN.format(base_url=self.base_url, restaurant_id=restaurant_id)
        logger.info(f"Scraping menu for restaurant {restaurant_id}")

        try:
            self.page.goto(url, wait_until='networkidle')
            time.sleep(self.delay)

            html_content = self.page.content()
            soup = BeautifulSoup(html_content, 'html.parser')

            courses_data = []
            course_uls = soup.find_all('ul', style=lambda value: value and 'list-style-type: none' in value, id=lambda x: x and x.startswith('course_'))

            for course_index, course_ul in enumerate(course_uls):
                # Extract course name from h3
                h3 = course_ul.find('h3')
                if not h3:
                    continue

                course_name = h3.get_text(strip=True)

                # Extract dishes
                dishes = []
                dish_lis = course_ul.find_all('li', id=lambda x: x and x.startswith('li_'))

                for dish_index, dish_li in enumerate(dish_lis):
                    # Extract menu entry ID from li id="li_77442"
                    li_id = dish_li.get('id', '')
                    menu_entry_id = li_id.replace('li_', '') if li_id else None

                    # Extract dish link and description
                    dish_link = dish_li.find('a')
                    if not dish_link:
                        continue

                    dish_name = dish_link.get_text(strip=True)

                    # Description is the text after the link
                    description_text = dish_li.get_text(strip=True)
                    # Remove the dish name and " - " prefix
                    description = description_text.replace(dish_name, '').strip()
                    if description.startswith(' - '):
                        description = description[3:].strip()

                    dishes.append({
                        'name': dish_name,
                        'description': description,
                        'display_order': dish_index,
                        'menu_entry_id': int(menu_entry_id) if menu_entry_id else None
                    })

                courses_data.append({
                    'name': course_name,
                    'description': '',  # Courses don't have descriptions in the list view
                    'display_order': course_index,
                    'dishes': dishes
                })

            logger.info(f"Found {len(courses_data)} courses with {sum(len(c['dishes']) for c in courses_data)} dishes")

            return {
                'restaurant_id': restaurant_id,
                'courses': courses_data
            }

        except Exception as e:
            logger.error(f"Failed to scrape menu for restaurant {restaurant_id}: {e}")
            raise

    def scrape_dish_details(self, restaurant_id: int, menu_entry_id: int, language: str = 'en') -> Optional[Dict]:
        """
        Scrape detailed information for a specific dish.

        Args:
            restaurant_id: CRM restaurant ID
            menu_entry_id: CRM menu entry ID
            language: Language code ('en' or 'fr'), default 'en'

        Returns:
            {
                'prices': [
                    {'size_variant': 'Small', 'price': 16.80, 'display_order': 0},
                    {'size_variant': 'Medium', 'price': 26.90, 'display_order': 1}
                ],
                'modifiers': [
                    {
                        'name': 'Crust Type',
                        'type_code': 'br',
                        'is_required': True,
                        'min_selections': 1,
                        'max_selections': 1,
                        'display_order': 1,
                        'items': [
                            {'name': 'Regular Crust', 'price': 0.00, 'display_order': 0},
                            {'name': 'Thick Crust', 'price': 0.00, 'display_order': 1}
                        ]
                    }
                ]
            }
        """
        # Build URL with language parameter
        url = f"{self.base_url}/?p=restaurants&display=editRestaurant&restaurant={restaurant_id}" \
              f"&load=editDish&showLang={language}&menuEntry={menu_entry_id}"

        try:
            self.page.goto(url, wait_until='networkidle')
            time.sleep(self.delay)

            html_content = self.page.content()
            soup = BeautifulSoup(html_content, 'html.parser')

            # Extract prices
            prices = self._extract_prices(soup)
            
            # Extract modifiers
            modifiers = self._extract_modifiers(soup)

            logger.info(f"Scraped details for menu entry {menu_entry_id}: {len(prices)} prices, {len(modifiers)} modifier groups")
            
            return {
                'prices': prices,
                'modifiers': modifiers
            }

        except Exception as e:
            logger.error(f"Failed to scrape dish details for entry {menu_entry_id}: {e}")
            return None

    def _extract_prices(self, soup: BeautifulSoup) -> List[Dict]:
        """Extract price and size information from dish detail page."""
        prices = []
        
        # Find price and quantity inputs
        price_input = soup.find('input', {'name': 'price', 'id': 'price'})
        quantity_input = soup.find('input', {'name': 'quantity', 'id': 'quantity'})
        
        if not price_input:
            return prices
        
        # Parse comma-separated values
        price_values = [p.strip() for p in price_input.get('value', '').split(',') if p.strip()]
        
        # Get size variants if available
        quantity_values = []
        if quantity_input:
            quantity_values = [q.strip() for q in quantity_input.get('value', '').split(',') if q.strip()]
        
        # Create price entries
        for i, price_str in enumerate(price_values):
            try:
                price_float = float(price_str)
                size_variant = quantity_values[i] if i < len(quantity_values) else None
                
                prices.append({
                    'size_variant': size_variant,
                    'price': price_float,
                    'display_order': i
                })
            except (ValueError, IndexError) as e:
                logger.warning(f"Failed to parse price '{price_str}': {e}")
                continue
        
        return prices

    def _extract_modifiers(self, soup: BeautifulSoup) -> List[Dict]:
        """Extract modifier groups and items from dish detail page."""
        modifiers = []
        
        # Modifier type mappings
        modifier_types = {
            'br': {'name': 'hasBread', 'header': 'breadHeader', 'min': 'minbread', 'max': 'maxbread', 'order': 'displayOrderBread'},
            'ci': {'name': 'hasCustomisation', 'header': 'ciHeader', 'min': 'minci', 'max': 'maxci', 'order': 'displayOrderCI'},
            'dr': {'name': 'hasDressing', 'header': 'dressingHeader', 'min': 'mindressing', 'max': 'maxdressing', 'order': 'displayOrderDressing'},
            'sa': {'name': 'hasSauce', 'header': 'sauceHeader', 'min': 'minsauce', 'max': 'maxsauce', 'order': 'displayOrderSauce'},
            'sd': {'name': 'hasSideDish', 'header': 'sideDishHeader', 'min': 'minsd', 'max': 'maxsd', 'order': 'displayOrderSD'},
            'd': {'name': 'hasDrinks', 'header': 'drinksHeader', 'min': 'mindrink', 'max': 'maxdrink', 'order': 'displayOrderDrink'},
            'e': {'name': 'hasExtras', 'header': 'extraHeader', 'min': 'minextras', 'max': 'maxextras', 'order': 'displayOrderExtras'},
            'cm': {'name': 'hasCookMethod', 'header': 'cmHeader', 'min': None, 'max': None, 'order': 'displayOrderCM'}
        }
        
        for type_code, config in modifier_types.items():
            # Check if this modifier type is enabled
            checkbox = soup.find('input', {'id': config['name'], 'type': 'checkbox'})
            if not checkbox or not checkbox.has_attr('checked'):
                continue
            
            # Get modifier group header/name
            header_input = soup.find('input', {'id': config['header']})
            group_name = header_input.get('value', '') if header_input else f"Modifier {type_code}"
            
            # Get min/max selections
            min_selections = 0
            max_selections = 1
            if config['min']:
                min_input = soup.find('input', {'id': config['min']})
                if min_input:
                    try:
                        min_selections = int(min_input.get('value', 0))
                    except ValueError:
                        pass
            
            if config['max']:
                max_input = soup.find('input', {'id': config['max']})
                if max_input:
                    try:
                        max_selections = int(max_input.get('value', 1))
                    except ValueError:
                        pass
            
            # Get display order
            display_order = 0
            if config['order']:
                order_input = soup.find('input', {'id': config['order']})
                if order_input:
                    try:
                        display_order = int(order_input.get('value', 0))
                    except ValueError:
                        pass
            
            # Extract modifier items for this type
            items = self._extract_modifier_items(soup, type_code)
            
            if items:  # Only add if there are items
                modifiers.append({
                    'name': group_name,
                    'type_code': type_code,
                    'is_required': min_selections > 0,
                    'min_selections': min_selections,
                    'max_selections': max_selections,
                    'display_order': display_order,
                    'items': items
                })
        
        return modifiers

    def _extract_modifier_items(self, soup: BeautifulSoup, type_code: str) -> List[Dict]:
        """Extract individual modifier items for a given modifier type.
        
        FIXED: Now extracts ALL sub-groups, not just the first one.
        FIXED: Now extracts ALL price variants for each item, not just the first.
        """
        items = []
        
        # Find the container for this modifier type
        container_id = f"ul{type_code}"
        container = soup.find('ul', {'id': container_id})
        
        if not container:
            return items
        
        # Find ALL groups (radio button groups) within this modifier type
        # CRITICAL FIX: Extract from ALL groups, not just the first one
        radio_buttons = container.find_all('input', {'type': 'radio', 'name': f'{type_code}_radio'})
        
        all_group_uls = []
        
        if radio_buttons:
            # Extract items from ALL radio button groups
            for radio in radio_buttons:
                radio_value = radio.get('value')
                if radio_value:
                    group_ul = soup.find('ul', {'id': f'list_{type_code}_{radio_value}'})
                    if group_ul:
                        all_group_uls.append(group_ul)
        else:
            # No radio buttons - try to get all groups by class
            all_group_uls = container.find_all('ul', {'class': type_code})
        
        if not all_group_uls:
            return items
        
        # Track item names to avoid duplicates across sub-groups
        seen_items = set()
        
        # Extract items from ALL groups
        for group_ul in all_group_uls:
            item_lis = group_ul.find_all('li', recursive=False)
            
            for idx, li in enumerate(item_lis):
                # Find the input field with prices
                input_field = li.find('input', {'type': 'text'})
                if not input_field:
                    continue
                
                # Extract item name (text before the input)
                item_name = li.get_text(strip=True)
                # Remove the input value from the name
                if input_field.get('value'):
                    item_name = item_name.replace(input_field.get('value', ''), '').strip()
                
                # Skip duplicates (same item in multiple sub-groups)
                if item_name in seen_items:
                    continue
                seen_items.add(item_name)
                
                # CRITICAL FIX: Parse ALL prices (comma-separated for different sizes)
                price_value_str = input_field.get('value', '')
                price_values = [p.strip() for p in price_value_str.split(',') if p.strip()]
                
                # Convert all price strings to floats
                prices = []
                for p_val in price_values:
                    try:
                        prices.append(float(p_val))
                    except ValueError:
                        prices.append(0.0)
                
                # If no prices found, default to single 0.0
                if not prices:
                    prices = [0.0]
                
                items.append({
                    'name': item_name,
                    'prices': prices,  # Now stores ALL prices, not just first
                    'display_order': idx,
                    'is_default': False  # CRM doesn't seem to mark defaults in the HTML
                })
        
        return items
