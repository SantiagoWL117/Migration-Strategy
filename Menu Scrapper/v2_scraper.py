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
    
    def scrape_restaurant_menu(self, v2_restaurant_id: int, db_restaurant_id: int, language_id: int = 2) -> Optional[Dict]:
        """
        Scrape courses and dishes for a V2 restaurant.
        
        Args:
            v2_restaurant_id: V2 restaurant ID (legacy_v2_id)
            db_restaurant_id: menuca_v3 restaurant ID
            language_id: Language ID (2 = French, 1 = English). Default is 2 (French).
        
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
            # Try URL without language_id first (for some restaurants like Cosenza, Pachino)
            menu_url_no_lang = f"{self.base_url}/index.php/restaurants/edit/{v2_restaurant_id}/menu/restaurant"
            logger.info(f"Trying URL without language ID: {menu_url_no_lang}")
            
            self.page.goto(menu_url_no_lang, wait_until='networkidle', timeout=30000)
            time.sleep(2)  # Wait for dynamic content
            
            # Get page content
            html = self.page.content()
            soup = BeautifulSoup(html, 'lxml')
            
            # Detect menu structure type
            is_english_menu = soup.find('div', id='sortable') is not None
            is_french_menu = soup.find('div', class_='course-listing') is not None
            
            # If no valid menu structure detected, try with language_id
            if not is_english_menu and not is_french_menu:
                logger.info(f"No menu found without language ID, trying with language_id={language_id}")
                menu_url = f"{self.base_url}/index.php/restaurants/edit/{v2_restaurant_id}/menu/{language_id}/restaurant"
                logger.info(f"Navigating to: {menu_url}")
                
                self.page.goto(menu_url, wait_until='networkidle', timeout=30000)
                time.sleep(2)  # Wait for dynamic content
                
                # Get page content again
                html = self.page.content()
                soup = BeautifulSoup(html, 'lxml')
                
                # Detect menu structure type again
                is_english_menu = soup.find('div', id='sortable') is not None
                is_french_menu = soup.find('div', class_='course-listing') is not None
            
            logger.info(f"Menu structure detected: {'English' if is_english_menu else 'French' if is_french_menu else 'Unknown'}")
            
            # Extract courses based on menu type
            courses = []
            
            if is_english_menu:
                # English menu structure: div#sortable > div.jarviswidget
                logger.info("Processing English menu structure...")
                
                # Expand all collapsed course sections using JavaScript
                logger.debug("Expanding all collapsed courses...")
                self.page.evaluate('''() => {
                    const widgets = document.querySelectorAll('.jarviswidget-collapsed');
                    widgets.forEach(widget => {
                        const toggleBtn = widget.querySelector('.jarviswidget-toggle-btn');
                        if (toggleBtn) {
                            toggleBtn.click();
                        }
                    });
                }''')
                time.sleep(1)  # Wait for expansion animation
                
                # Re-get the HTML after expanding
                html = self.page.content()
                soup = BeautifulSoup(html, 'lxml')
            
                sortable_div = soup.find('div', id='sortable')
                if not sortable_div:
                    logger.error("Sortable div not found after expansion")
                    return None
                
                # Find all jarviswidget divs that are direct children of sortable
                # These represent courses - they have data-id attribute (NOT data-course-id)
                course_widgets = sortable_div.find_all('div', class_='jarviswidget', attrs={'data-id': True}, recursive=False)
                logger.info(f"Found {len(course_widgets)} course widgets")
                
                for course_idx, widget in enumerate(course_widgets):
                    # Extract course name from header
                    header = widget.find('header')
                    if not header:
                        logger.warning(f"No header found for course widget {course_idx}")
                        continue
                    
                    course_name_span = header.find('span', class_='widget-icon')
                    if course_name_span and course_name_span.find_next_sibling(string=True):
                        course_name = course_name_span.find_next_sibling(string=True).strip()
                    else:
                        # Fallback: get all text from header and clean it
                        course_name = header.get_text(strip=True)
                        # Remove any button text or extra whitespace
                        course_name = course_name.split('\n')[0].strip()
                    
                    # Extract V2 course ID from data-id attribute (not data-course-id!)
                    course_v2_id = widget.get('data-id', '')
                    
                    if not course_v2_id:
                        logger.warning(f"No course ID found for course: {course_name}")
                        continue
                    
                    logger.debug(f"Processing course: {course_name} (ID: {course_v2_id})")
                    
                    # Find the widget content (dishes table)
                    widget_body = widget.find('div', class_='widget-body')
                    if not widget_body:
                        logger.warning(f"No widget body found for course: {course_name}")
                        continue
                    
                    # Find dishes table
                    dishes_table = widget_body.find('table', class_='table')
                    if not dishes_table:
                        logger.warning(f"No dishes table found for course: {course_name}")
                        continue
                    
                    # Extract dishes from the table
                    dishes = []
                    tbody = dishes_table.find('tbody')
                    if not tbody:
                        logger.warning(f"No tbody found for course: {course_name}")
                        continue
                    
                    dish_rows = tbody.find_all('tr', class_='sort', attrs={'data-id': True})
                    
                    for dish_idx, dish_row in enumerate(dish_rows):
                        # Get dish ID from data-id attribute
                        v2_dish_id = dish_row.get('data-id')
                        if not v2_dish_id:
                            continue
                        
                        # Extract dish name from input with name="name[{dish_id}]"
                        name_input = dish_row.find('input', attrs={'name': f'name[{v2_dish_id}]'})
                        dish_name = name_input.get('value', '').strip() if name_input else ''
                        
                        if not dish_name:
                            logger.debug(f"Could not extract dish name from row with ID {v2_dish_id}")
                            continue
                        
                        # Extract description from input with name="desc[{dish_id}]"
                        desc_input = dish_row.find('input', attrs={'name': f'desc[{v2_dish_id}]'})
                        dish_description = desc_input.get('value', '').strip() if desc_input else ''
                        
                        # Extract size from input with name="size[{dish_id}]"
                        size_input = dish_row.find('input', attrs={'name': f'size[{v2_dish_id}]'})
                        size_str = size_input.get('value', '').strip() if size_input else ''
                        
                        # Extract price from input with name="price[{dish_id}]"
                        price_input = dish_row.find('input', attrs={'name': f'price[{v2_dish_id}]'})
                        price_str = price_input.get('value', '').strip() if price_input else ''
                        
                        # Parse sizes and prices
                        # They can be comma-separated for multiple size variants
                        size_variants = [s.strip() for s in size_str.split(',') if s.strip()] if size_str else ['standard']
                        
                        prices = []
                        if price_str:
                            price_values = [p.strip() for p in price_str.split(',') if p.strip()]
                            # Match sizes to prices
                            for idx, (size, price) in enumerate(zip(size_variants, price_values)):
                                try:
                                    price_val = float(price)
                                    prices.append({
                                        'size_variant': size,
                                        'price': price_val,
                                        'display_order': idx
                                    })
                                except ValueError:
                                    logger.warning(f"Could not parse price '{price}' for dish {dish_name}")
                        
                        # If no prices parsed, use default
                        if not prices:
                            prices = [{'size_variant': 'standard', 'price': 0.0, 'display_order': 0}]
                        
                        # Get display order from data-display_order attribute
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
                            'description': '',  # English menus don't have course descriptions in this view
                            'display_order': course_idx,
                            'v2_course_id': course_v2_id,
                            'dishes': dishes
                        })
            
            elif is_french_menu:
                # French menu structure: div.course-listing
                logger.info("Processing French menu structure...")
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
            
            else:
                logger.error("Unknown menu structure - could not detect English or French format")
                return None
            
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
    
    def scrape_menu(self, v2_restaurant_id: int, language_id: int = 2) -> Optional[Dict]:
        """
        Scrape menu without needing db_restaurant_id (simplified version).
        This is an alias for scrape_restaurant_menu for compatibility.
        
        Args:
            v2_restaurant_id: V2 restaurant ID
            language_id: Language ID (2 = French, 1 = English). Default is 2 (French).
        
        Returns:
            Dictionary with courses and dishes (without db_restaurant_id)
        """
        # Call the main method with a placeholder db_restaurant_id
        result = self.scrape_restaurant_menu(v2_restaurant_id, 0, language_id)
        if result:
            # Remove db_restaurant_id from result
            result.pop('db_restaurant_id', None)
        return result
    
    def scrape_dish_details(self, v2_dish_id: int, v2_restaurant_id: int, language_id: int = 2) -> Optional[Dict]:
        """
        Scrape modifiers for a V2 dish by navigating to menu page and clicking edit button.
        
        Args:
            v2_dish_id: V2 dish ID
            v2_restaurant_id: V2 restaurant ID
            language_id: Language ID (2 = French, 1 = English). Default is 2 (French).
        
        Returns:
            {
                'v2_dish_id': '9001',
                'modifier_groups': [
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
                                'prices': [2.00, 3.50],  # Can have multiple prices for different sizes
                                'display_order': 0
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
            # Navigate to the main menu page (try without language_id first, then with it)
            # self.base_url may or may not end with /index.php/, so normalize it
            base = self.base_url.rstrip('/')
            if not base.endswith('/index.php'):
                base = f"{base}/index.php"
            
            menu_url_no_lang = f"{base}/restaurants/edit/{v2_restaurant_id}/menu/restaurant"
            logger.info(f"Navigating to menu page: {menu_url_no_lang}")
            self.page.goto(menu_url_no_lang, wait_until="networkidle", timeout=30000)
            
            # Check if this URL works (page has menu structure)
            has_menu = self.page.evaluate('''() => {
                return document.querySelector('.jarviswidget') !== null;
            }''')
            
            if not has_menu:
                # Try with language_id
                menu_url = f"{base}/restaurants/edit/{v2_restaurant_id}/menu/{language_id}/restaurant"
                logger.debug(f"No menu found, trying with language ID: {menu_url}")
                self.page.goto(menu_url, wait_until="networkidle", timeout=30000)
            
            # Find the edit button for this dish using JavaScript to handle visibility
            logger.info(f"Looking for edit button for dish {v2_dish_id}")
            
            # Use JavaScript to find, expand parent if needed, and click
            clicked = self.page.evaluate('''(dishId) => {
                // Find the edit button
                const button = document.querySelector(`a.edit_dish[data-dish="${dishId}"]`);
                if (!button) return false;
                
                // Find parent course widget
                const widget = button.closest('.jarviswidget');
                if (widget) {
                    // Check if widget is collapsed (has jarviswidget-collapsed class)
                    if (widget.classList.contains('jarviswidget-collapsed')) {
                        // Find and click the toggle button to expand
                        const toggleBtn = widget.querySelector('.jarviswidget-toggle-btn');
                        if (toggleBtn) {
                            toggleBtn.click();
                            // Wait a moment for expansion
                        }
                    }
                }
                
                // Scroll button into view
                button.scrollIntoView({behavior: 'auto', block: 'center'});
                
                // Click the button
                button.click();
                return true;
            }''', str(v2_dish_id))
            
            if not clicked:
                logger.warning(f"Could not find or click edit button for dish {v2_dish_id}")
                return {'v2_dish_id': v2_dish_id, 'modifier_groups': []}
            
            time.sleep(1)  # Wait for click and potential expansion animation
            
            # Wait for modal to appear and load
            logger.info(f"Waiting for modal to load...")
            self.page.wait_for_selector("#mod_edit_dish .modal-body", state="visible", timeout=10000)
            time.sleep(1.5)  # Allow AJAX content to fully load
            
            # Get the modal HTML
            modal_body = self.page.query_selector("#mod_edit_dish .modal-body")
            if not modal_body:
                logger.warning("Modal body not found")
                return {'v2_dish_id': v2_dish_id, 'modifier_groups': []}
            
            modal_html = modal_body.inner_html()
            soup = BeautifulSoup(modal_html, 'lxml')
            
            # Extract modifiers
            modifier_groups = []
            
            # Find the customization container
            customization_container = soup.select_one('#group_dish_customization')
            if not customization_container:
                logger.warning("No customization container found")
                # Close modal before returning
                self.page.keyboard.press("Escape")
                time.sleep(0.3)
                return {'v2_dish_id': v2_dish_id, 'modifier_groups': []}
            
            # Find all ACTIVE modifier type panels (direct children with panel-success class)
            # Only panels with 'panel-success' are enabled/active for this dish
            # Panels with 'panel-default' are available but not active
            modifier_panels = customization_container.select(':scope > .panel.panel-success')
            
            logger.info(f"Found {len(modifier_panels)} active modifier type panels")
            
            for panel in modifier_panels:
                # Get the panel collapse div to determine the type
                panel_collapse = panel.select_one('.panel-collapse')
                if not panel_collapse:
                    continue
                
                type_code = panel_collapse.get('id', '')  # 'extra', 'custom_ingredient', 'premium_toppings', etc.
                if not type_code:
                    continue
                
                logger.debug(f"Processing modifier type: {type_code}")
                
                # Note: We scrape ALL modifier groups regardless of enabled/disabled status
                # The V2 system may have groups configured but not currently enabled
                # We want to capture all available modifiers for the dish
                
                # Get configuration values
                min_input = panel_collapse.select_one(f'input[name="customization[{type_code}][min]"]')
                max_input = panel_collapse.select_one(f'input[name="customization[{type_code}][max]"]')
                display_input = panel_collapse.select_one(f'input[name="customization[{type_code}][display_order]"]')
                title_input = panel_collapse.select_one(f'input[name="customization[{type_code}][title_paid]"]')
                
                # Find ALL available groups for this modifier type
                # We process all groups, not just the one that's currently selected
                all_group_radios = panel_collapse.select(f'input.selected_group[data-type="{type_code}"]')
                if not all_group_radios:
                    logger.debug(f"  No group radio buttons found for {type_code}")
                    continue
                
                logger.debug(f"  Found {len(all_group_radios)} available groups for {type_code}")
                
                # Process each available group for this modifier type
                for group_radio in all_group_radios:
                    group_id = group_radio.get('value')
                    group_name_label = group_radio.find_parent('label')
                    group_name = group_name_label.get_text(strip=True) if group_name_label else type_code.replace('_', ' ').title()
                    
                    logger.debug(f"  Processing group: {group_name} (ID: {group_id})")
                    
                    # Find the panel for this group
                    group_panel = panel_collapse.select_one(f'#dishes_{group_id}')
                    if not group_panel:
                        logger.debug(f"    No panel found for group {group_id}")
                        continue
                        
                    # Extract items from the group
                    # Items are in inputs with name pattern: item[{group_id}][{hash}]
                    item_inputs = group_panel.select(f'input[name^="item[{group_id}]"]')
                    logger.debug(f"    Found {len(item_inputs)} items in group")
                    
                    if not item_inputs:
                        logger.debug(f"    Skipping group {group_id} - no items")
                        continue
                    
                    # Create modifier group
                    modifier_group = {
                        'name': title_input.get('value', group_name).strip() if title_input else group_name,
                        'type_code': type_code,
                        'v2_group_id': group_id,
                        'is_required': int(min_input.get('value', 0)) > 0 if min_input else False,
                        'min_selections': int(min_input.get('value', 0)) if min_input else 0,
                        'max_selections': int(max_input.get('value', 1)) if max_input else 1,
                        'display_order': int(display_input.get('value', 0)) if display_input else 0,
                        'items': []
                    }
                    
                    for idx, item_input in enumerate(item_inputs):
                        item_id = item_input.get('id', '')
                        
                        # Find the label for this item
                        item_label = group_panel.select_one(f'label[for="{item_id}"]')
                        item_name = item_label.get_text(strip=True) if item_label else f"Item {idx}"
                        
                        # Get prices - can be comma-separated for multiple sizes
                        price_value = item_input.get('value', '0').strip()
                        prices = []
                        
                        if price_value:
                            # Split by comma for multiple prices
                            price_parts = [p.strip() for p in price_value.split(',')]
                            for price_str in price_parts:
                                try:
                                    prices.append(float(price_str))
                                except (ValueError, TypeError):
                                    prices.append(0.0)
                        
                        if not prices:
                            prices = [0.0]
                        
                        modifier_group['items'].append({
                            'name': item_name,
                            'prices': prices,
                            'display_order': idx
                        })
                    
                    # Only add if it has items
                    if modifier_group['items']:
                        logger.debug(f"    Added group {group_name} with {len(modifier_group['items'])} items")
                        modifier_groups.append(modifier_group)
            
            # Close the modal
            self.page.keyboard.press("Escape")
            time.sleep(0.3)
            
            logger.info(f"✓ Scraped {len(modifier_groups)} modifier groups for dish {v2_dish_id}")
            for mg in modifier_groups:
                logger.info(f"  - {mg['name']}: {len(mg['items'])} items")
            
            return {
                'v2_dish_id': v2_dish_id,
                'modifier_groups': modifier_groups
            }
            
        except PlaywrightTimeout as e:
            logger.error(f"Timeout error scraping dish details: {e}")
            return {'v2_dish_id': v2_dish_id, 'modifier_groups': []}
        except Exception as e:
            logger.error(f"Error scraping dish details for dish {v2_dish_id}: {e}")
            import traceback
            logger.error(traceback.format_exc())
            return {'v2_dish_id': v2_dish_id, 'modifier_groups': []}

