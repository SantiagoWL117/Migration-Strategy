"""Combo Modifiers Scraper using Playwright for browser automation."""
import re
import time
import logging
from typing import Optional, Dict, List, Any
from bs4 import BeautifulSoup
from playwright.sync_api import sync_playwright, Page, Browser, BrowserContext

from combo_config import (
    CRM_LOGIN_URL, CRM_RESTAURANTS_URL, COMBO_GROUPS_URL_PATTERN,
    MENU_URL_PATTERN, COMBO_DISH_URL_PATTERN, COMBO_AJAX_URL,
    CRM_USERNAME, CRM_PASSWORD,
    SECTION_CHECKBOX_MAPPING, DAY_OF_WEEK_MAPPING, SIZE_VARIANTS,
    TIMEOUT, NAVIGATION_TIMEOUT, SCRAPE_DELAY
)
from combo_database import ComboDatabase

logger = logging.getLogger(__name__)


class ComboScraper:
    """Scraper for combo groups and modifiers from V1 CRM."""

    def __init__(self, headless: bool = True):
        self.headless = headless
        self.playwright = None
        self.browser: Optional[Browser] = None
        self.context: Optional[BrowserContext] = None
        self.page: Optional[Page] = None
        self.db: Optional[ComboDatabase] = None
        self.current_restaurant = None

    def start(self):
        """Initialize browser and database connections."""
        logger.info("Starting Combo Scraper...")
        
        # Start Playwright
        self.playwright = sync_playwright().start()
        self.browser = self.playwright.chromium.launch(headless=self.headless)
        self.context = self.browser.new_context()
        self.page = self.context.new_page()
        self.page.set_default_timeout(TIMEOUT)
        self.page.set_default_navigation_timeout(NAVIGATION_TIMEOUT)
        
        # Connect to database
        self.db = ComboDatabase()
        self.db.connect()
        
        logger.info("Browser and database connections established")

    def stop(self):
        """Close all connections."""
        logger.info("Stopping Combo Scraper...")
        
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
            # Try the actual HTML form first
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
                    # Fallback: Use role-based selectors
                    logger.info("Using role-based selectors for login form")
                    self.page.wait_for_selector('text=Username', state='visible', timeout=10000)
                    time.sleep(0.5)
                    self.page.get_by_role('textbox', name='Username').fill(CRM_USERNAME)
                    self.page.get_by_role('textbox', name='Password').fill(CRM_PASSWORD)
                    self.page.get_by_role('button', name='Login').click()
            
            # Wait for navigation after login
            self.page.wait_for_load_state('networkidle', timeout=30000)
            time.sleep(2)
            
            # Log current URL for debugging
            current_url = self.page.url
            logger.info(f"Current URL after login: {current_url}")
            
            # Check if we're still on the login page
            if 'p=login' in current_url or self.page.query_selector('input[name="username"]'):
                # Check for error messages
                page_content = self.page.content()
                if 'error' in page_content.lower() or 'invalid' in page_content.lower() or 'wrong' in page_content.lower():
                    logger.error("Login failed - error message detected on page")
                else:
                    logger.error("Still on login page - form may not have submitted correctly")
                # Save the page for debugging
                with open('debug_login_failed.html', 'w', encoding='utf-8') as f:
                    f.write(page_content)
                logger.info("Saved failed login page to debug_login_failed.html")
                return False
            
            # Check if login successful (should see restaurants list or main page)
            if self.page.query_selector('ul#active') or self.page.query_selector('.restaurantList'):
                logger.info("Login successful - found restaurant list")
                return True
            elif 'restaurants' in current_url:
                logger.info("Login successful - on restaurants page")
                return True
            else:
                # Save the page for debugging
                with open('debug_after_login.html', 'w', encoding='utf-8') as f:
                    f.write(self.page.content())
                logger.warning(f"Login status unclear - page saved to debug_after_login.html")
                # Continue anyway if we're on the site
                return 'menuadmin.menu.ca' in current_url
                
        except Exception as e:
            logger.error(f"Login failed: {e}")
            return False

    # =========================================================================
    # Phase 1: Scrape Combo Groups
    # =========================================================================

    def navigate_to_combo_groups(self, v1_id: int) -> bool:
        """Navigate to combo groups page for a restaurant."""
        url = COMBO_GROUPS_URL_PATTERN.format(v1_id=v1_id)
        logger.info(f"Navigating to combo groups: {url}")
        
        try:
            self.page.goto(url)
            self.page.wait_for_load_state('networkidle')
            
            # Wait for combo group elements to load (instruction #4)
            # Combo groups are <p> elements with specific style containing editGroupJS links
            # Style: margin-top:1px;height:20px;line-height:1.5;background-color: #ccc;padding-left:20px;border:1px solid #aaa
            try:
                self.page.wait_for_selector(
                    'p[style*="background-color"] a[onclick*="editGroupJS"]',
                    timeout=10000  # 10 seconds to allow JS rendering
                )
                logger.info("Combo group elements detected - page fully loaded")
            except:
                # No combo groups found after waiting - this is valid (restaurant may not have any)
                logger.info("No combo group elements detected after waiting - page may be empty or have no groups")
            
            time.sleep(SCRAPE_DELAY)
            return True
        except Exception as e:
            logger.error(f"Failed to navigate to combo groups: {e}")
            return False

    def get_combo_group_links(self) -> List[Dict[str, Any]]:
        """Get all combo group links from the page."""
        combo_groups = []
        
        # Debug: Log page content length and URL
        html_content = self.page.content()
        logger.info(f"Page URL after navigation: {self.page.url}")
        logger.info(f"Page HTML length: {len(html_content)} bytes")
        
        # Save HTML for debugging
        with open('debug_page.html', 'w', encoding='utf-8') as f:
            f.write(html_content)
        logger.info("Saved page HTML to debug_page.html")
        
        # Debug: Check for key elements
        if 'editGroupJS' in html_content:
            logger.info("Found 'editGroupJS' in page HTML")
        else:
            logger.info("'editGroupJS' NOT found in page HTML - checking for login form...")
            if 'Username' in html_content or 'Password' in html_content:
                logger.warning("Login form detected! Session may have been lost.")
            
        if 'background-color' in html_content:
            logger.debug("Found 'background-color' in page HTML")
            
        # Find all combo group links with editGroupJS onclick
        # Try multiple selector patterns
        selectors = [
            'p[style*="background-color"] a[onclick*="editGroupJS"]',
            'a[onclick*="editGroupJS"]',
            'p a[href="#"]',
        ]
        
        for selector in selectors:
            links = self.page.query_selector_all(selector)
            if links:
                logger.debug(f"Selector '{selector}' found {len(links)} elements")
                break
            else:
                logger.debug(f"Selector '{selector}' found 0 elements")
        
        # Use the first selector that works, or fall back to parsing HTML
        links = self.page.query_selector_all('a[onclick*="editGroupJS"]')
        
        if not links:
            # Try parsing HTML directly with BeautifulSoup
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
                        logger.debug(f"Found combo group (via BS4): {name} (source_id={source_id})")
        else:
            for link in links:
                onclick = link.get_attribute('onclick') or ''
                name = link.inner_text().strip()
                
                # Extract source_id from editGroupJS('1502')
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

    def parse_combo_group_form(self, html: str) -> Dict[str, Any]:
        """Parse combo group form data from HTML."""
        soup = BeautifulSoup(html, 'html.parser')
        
        data = {
            'name': '',
            'number_of_items': 1,
            'display_header': '',
            'sections': []
        }
        
        # Extract form values
        name_input = soup.find('input', {'id': 'name'})
        if name_input:
            data['name'] = name_input.get('value', '')
        
        itemcount_input = soup.find('input', {'id': 'itemcount'})
        if itemcount_input:
            try:
                data['number_of_items'] = int(itemcount_input.get('value', 1))
            except ValueError:
                data['number_of_items'] = 1
        
        display_header_input = soup.find('input', {'id': 'displayHeader'})
        if display_header_input:
            data['display_header'] = display_header_input.get('value', '')
        
        # Parse sections
        for checkbox_name, section_config in SECTION_CHECKBOX_MAPPING.items():
            checkbox = soup.find('input', {'id': checkbox_name})
            
            if checkbox and checkbox.has_attr('checked'):
                section_data = self._parse_section(soup, section_config)
                if section_data:
                    data['sections'].append(section_data)
        
        return data

    def _parse_section(self, soup: BeautifulSoup, config: Dict) -> Optional[Dict[str, Any]]:
        """Parse a single section's data."""
        section_data = {
            'section_type': config['section_type'],
            'use_header': '',
            'display_order': 0,
            'free_items': 0,
            'min_selection': 0,
            'max_selection': 0,
            'modifier_groups': []
        }
        
        # Get header
        header_input = soup.find('input', {'id': config['header_input']})
        if header_input:
            section_data['use_header'] = header_input.get('value', '')
        
        # Get display order
        order_input = soup.find('input', {'id': config['display_order_input']})
        if order_input:
            try:
                section_data['display_order'] = int(order_input.get('value', 0) or 0)
            except ValueError:
                pass
        
        # Get min/max/free values if applicable
        if config.get('min_input'):
            min_input = soup.find('input', {'id': config['min_input']})
            if min_input:
                try:
                    section_data['min_selection'] = int(min_input.get('value', 0) or 0)
                except ValueError:
                    pass
        
        if config.get('max_input'):
            max_input = soup.find('input', {'id': config['max_input']})
            if max_input:
                try:
                    section_data['max_selection'] = int(max_input.get('value', 0) or 0)
                except ValueError:
                    pass
        
        if config.get('free_input'):
            free_input = soup.find('input', {'id': config['free_input']})
            if free_input:
                try:
                    section_data['free_items'] = int(free_input.get('value', 0) or 0)
                except ValueError:
                    pass
        
        # Get modifier groups from the section's ul
        ul = soup.find('ul', {'id': config['ul_id']})
        if ul:
            section_data['modifier_groups'] = self._parse_modifier_groups(ul, config['section_type'])
        
        return section_data

    def _parse_modifier_groups(self, ul: BeautifulSoup, section_type: str) -> List[Dict[str, Any]]:
        """Parse modifier groups from a section's ul element."""
        modifier_groups = []
        
        # Find all radio inputs in this section
        for li in ul.find_all('li', recursive=False):
            radio = li.find('input', {'type': 'radio'})
            if not radio:
                continue
            
            # Get source_id from value attribute
            source_id = radio.get('value')
            if not source_id:
                continue
            
            try:
                source_id = int(source_id)
            except ValueError:
                continue
            
            # Check if this radio is selected (has checked="" attribute)
            is_selected = radio.has_attr('checked')
            
            # ONLY process modifier groups that are checked/selected
            if not is_selected:
                logger.debug(f"Skipping unchecked modifier group: source_id={source_id}")
                continue
            
            # Get name from label
            label = li.find('label', {'for': radio.get('id')})
            name = label.get_text().strip() if label else ''
            
            # Get type code (radio class attribute)
            type_code = radio.get('class', [''])[0].upper() if radio.get('class') else 'RADIO'
            
            # Parse modifiers from the nested ul
            modifiers = []
            nested_ul = li.find('ul', {'class': type_code.lower() if type_code else None})
            if not nested_ul:
                # Try finding any ul
                nested_ul = li.find('ul')
            
            if nested_ul:
                modifiers = self._parse_modifiers(nested_ul, section_type)
            
            modifier_groups.append({
                'name': name,
                'source_id': source_id,
                'type_code': type_code,
                'is_selected': is_selected,
                'modifiers': modifiers
            })
        
        return modifier_groups

    def _parse_modifiers(self, ul: BeautifulSoup, section_type: str) -> List[Dict[str, Any]]:
        """Parse individual modifiers from a ul element."""
        modifiers = []
        
        for idx, li in enumerate(ul.find_all('li', recursive=False)):
            # Get modifier name (text before input)
            text_content = li.get_text().strip()
            
            # Get price input
            price_input = li.find('input', {'type': 'text'})
            if not price_input:
                continue
            
            # Extract name from input name attribute pattern: ci[2041][9316]
            input_name = price_input.get('name', '')
            name_match = re.search(r'\[(\d+)\]\[(\d+)\]', input_name)
            
            # Get price string
            price_str = price_input.get('value', '0.00')
            
            # Extract name - remove the price from text content
            name = text_content.replace(price_str, '').strip()
            if not name:
                name = f"Modifier {idx + 1}"
            
            # Parse prices
            prices = self._parse_prices(price_str)
            
            modifiers.append({
                'name': name,
                'display_order': idx,
                'prices': prices
            })
        
        return modifiers

    def _parse_prices(self, price_str: str) -> List[Dict[str, Any]]:
        """Parse price string into size variant prices."""
        prices = []
        
        if not price_str:
            return [{'size_variant': 'Standard', 'price': 0.0}]
        
        parts = price_str.split(',')
        
        if len(parts) == 1:
            # Single price - use Standard variant
            try:
                price = float(parts[0].strip() or 0)
                prices.append({'size_variant': 'Standard', 'price': price})
            except ValueError:
                prices.append({'size_variant': 'Standard', 'price': 0.0})
        else:
            # Multiple prices - map to size variants
            for idx, part in enumerate(parts):
                if idx >= len(SIZE_VARIANTS):
                    break
                
                part = part.strip()
                if part:  # Only add if not empty
                    try:
                        price = float(part)
                        prices.append({
                            'size_variant': SIZE_VARIANTS[idx],
                            'price': price
                        })
                    except ValueError:
                        pass
        
        return prices if prices else [{'size_variant': 'Standard', 'price': 0.0}]

    def scrape_combo_groups(self, restaurant_id: int, v1_id: int) -> Dict[str, int]:
        """Scrape all combo groups for a restaurant and save to database."""
        stats = {
            'combo_groups': 0,
            'sections': 0,
            'modifier_groups': 0,
            'modifiers': 0,
            'prices': 0
        }
        
        # Navigate to combo groups page
        if not self.navigate_to_combo_groups(v1_id):
            return stats
        
        # Get list of combo groups
        combo_group_links = self.get_combo_group_links()
        
        if not combo_group_links:
            logger.info(f"No combo groups found for restaurant {restaurant_id}")
            return stats
        
        # Process each combo group
        for cg_info in combo_group_links:
            logger.info(f"Processing combo group: {cg_info['name']} (source_id={cg_info['source_id']})")
            
            # Fetch details via AJAX
            html = self.fetch_combo_group_details(v1_id, cg_info['source_id'])
            if not html:
                continue
            
            # Parse the form data
            cg_data = self.parse_combo_group_form(html)
            cg_data['source_id'] = cg_info['source_id']
            
            # Insert combo group
            combo_group_id = self.db.insert_combo_group(
                restaurant_id=restaurant_id,
                name=cg_data['name'] or cg_info['name'],
                number_of_items=cg_data['number_of_items'],
                display_header=cg_data['display_header'],
                source_id=cg_data['source_id']
            )
            
            if not combo_group_id:
                logger.error(f"Failed to insert combo group: {cg_info['name']}")
                continue
            
            stats['combo_groups'] += 1
            
            # Process sections
            for section in cg_data['sections']:
                section_id = self.db.insert_combo_group_section(
                    combo_group_id=combo_group_id,
                    section_type=section['section_type'],
                    use_header=section['use_header'],
                    display_order=section['display_order'],
                    free_items=section['free_items'],
                    min_selection=section['min_selection'],
                    max_selection=section['max_selection'],
                    is_active=True
                )
                
                if not section_id:
                    logger.error(f"Failed to insert section: {section['section_type']}")
                    continue
                
                stats['sections'] += 1
                
                # Process modifier groups
                for mg in section['modifier_groups']:
                    mg_id = self.db.insert_combo_modifier_group(
                        combo_group_section_id=section_id,
                        name=mg['name'],
                        type_code=mg['type_code'],
                        is_selected=mg['is_selected'],
                        source_id=mg['source_id']
                    )
                    
                    if not mg_id:
                        logger.error(f"Failed to insert modifier group: {mg['name']}")
                        continue
                    
                    stats['modifier_groups'] += 1
                    
                    # Process modifiers
                    for modifier in mg['modifiers']:
                        modifier_id = self.db.insert_combo_modifier(
                            combo_modifier_group_id=mg_id,
                            name=modifier['name'],
                            display_order=modifier['display_order']
                        )
                        
                        if not modifier_id:
                            logger.error(f"Failed to insert modifier: {modifier['name']}")
                            continue
                        
                        stats['modifiers'] += 1
                        
                        # Process prices
                        for price_info in modifier['prices']:
                            price_id = self.db.insert_combo_modifier_price(
                                combo_modifier_id=modifier_id,
                                size_variant=price_info['size_variant'],
                                price=price_info['price']
                            )
                            
                            if price_id:
                                stats['prices'] += 1
            
            time.sleep(SCRAPE_DELAY)
        
        return stats

    # =========================================================================
    # Phase 2: Link Dishes to Combo Groups
    # =========================================================================

    def navigate_to_menu(self, v1_id: int) -> bool:
        """Navigate to menu page for a restaurant."""
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

    def get_combo_dish_links(self) -> List[Dict[str, Any]]:
        """Get all combo dish links from the menu page."""
        combo_dishes = []
        
        # Find all links with combo= in href
        links = self.page.query_selector_all('a[href*="combo="]')
        
        for link in links:
            href = link.get_attribute('href') or ''
            name = link.inner_text().strip()
            
            # Extract combo_id from href
            match = re.search(r'combo=(\d+)', href)
            if match:
                combo_id = match.group(1)
                combo_dishes.append({
                    'name': name,
                    'combo_id': combo_id,
                    'href': href
                })
                logger.debug(f"Found combo dish: {name} (combo_id={combo_id})")
        
        logger.info(f"Found {len(combo_dishes)} combo dishes")
        return combo_dishes

    def navigate_to_combo_dish(self, v1_id: int, combo_id: str) -> bool:
        """Navigate to a specific combo dish page."""
        url = COMBO_DISH_URL_PATTERN.format(v1_id=v1_id, combo_id=combo_id)
        logger.info(f"Navigating to combo dish: {url}")
        
        try:
            self.page.goto(url)
            self.page.wait_for_load_state('networkidle')
            time.sleep(SCRAPE_DELAY)
            return True
        except Exception as e:
            logger.error(f"Failed to navigate to combo dish: {e}")
            return False

    def parse_combo_dish_page(self) -> Dict[str, Any]:
        """Parse combo dish page data."""
        html = self.page.content()
        soup = BeautifulSoup(html, 'html.parser')
        
        data = {
            'name': '',
            'description': '',
            'price': '',
            'assigned_combo_groups': [],
            'hide_on_days': [],
            'drinks_modifiers': []
        }
        
        # Get dish info
        name_input = soup.find('input', {'id': 'name'})
        if name_input:
            data['name'] = name_input.get('value', '')
        
        description_textarea = soup.find('textarea', {'id': 'ingredients'})
        if description_textarea:
            data['description'] = description_textarea.get_text().strip()
        
        price_input = soup.find('input', {'id': 'price'})
        if price_input:
            data['price'] = price_input.get('value', '')
        
        # Get assigned combo groups (checked checkboxes)
        for checkbox in soup.find_all('input', {'type': 'checkbox', 'name': 'group[]'}):
            if checkbox.has_attr('checked'):
                source_id = checkbox.get('value')
                label = soup.find('label', {'for': checkbox.get('id')})
                name = label.get_text().strip() if label else ''
                
                if source_id:
                    try:
                        data['assigned_combo_groups'].append({
                            'source_id': int(source_id),
                            'name': name
                        })
                    except ValueError:
                        pass
        
        # Get hide on days (checked checkboxes)
        for checkbox in soup.find_all('input', {'type': 'checkbox', 'name': 'hideOnDays[]'}):
            if checkbox.has_attr('checked'):
                day_value = checkbox.get('value')
                if day_value and day_value in DAY_OF_WEEK_MAPPING:
                    data['hide_on_days'].append(day_value)
        
        # Check for drinks section
        drinks_header = soup.find('p', string=re.compile(r'Drinks', re.IGNORECASE))
        if drinks_header:
            # Parse drinks modifiers similar to other sections
            drinks_div = drinks_header.find_next_sibling('div')
            if drinks_div:
                data['drinks_modifiers'] = self._parse_drinks_section(drinks_div)
        
        return data

    def _parse_drinks_section(self, div: BeautifulSoup) -> List[Dict[str, Any]]:
        """Parse drinks modifier section."""
        modifiers = []
        
        # Find the checked radio button
        checked_radio = div.find('input', {'type': 'radio', 'checked': True})
        if not checked_radio:
            return modifiers
        
        # Find the associated ul
        ul_id = f"list_d_{checked_radio.get('value')}"
        ul = div.find('ul', {'id': ul_id})
        if not ul:
            return modifiers
        
        # Parse each modifier
        for li in ul.find_all('li'):
            text = li.get_text().strip()
            price_input = li.find('input', {'type': 'text'})
            
            if price_input:
                price_str = price_input.get('value', '0.00')
                name = text.replace(price_str, '').strip()
                
                try:
                    price = float(price_str.strip() or 0)
                except ValueError:
                    price = 0.0
                
                if name:
                    modifiers.append({
                        'name': name,
                        'price': price
                    })
        
        return modifiers

    def scrape_combo_dishes(self, restaurant_id: int, v1_id: int) -> Dict[str, int]:
        """Scrape all combo dishes for a restaurant and link to combo groups."""
        stats = {
            'dishes_processed': 0,
            'combo_links_created': 0,
            'hide_days_set': 0,
            'drinks_modifiers': 0
        }
        
        # Navigate to menu page
        if not self.navigate_to_menu(v1_id):
            return stats
        
        # Get list of combo dishes
        combo_dishes = self.get_combo_dish_links()
        
        if not combo_dishes:
            logger.info(f"No combo dishes found for restaurant {restaurant_id}")
            return stats
        
        # Process each combo dish
        for dish_info in combo_dishes:
            logger.info(f"Processing combo dish: {dish_info['name']} (combo_id={dish_info['combo_id']})")
            
            # Navigate to dish page
            if not self.navigate_to_combo_dish(v1_id, dish_info['combo_id']):
                continue
            
            # Parse dish data
            dish_data = self.parse_combo_dish_page()
            
            # Find dish in database
            dish = self.db.get_dish_by_name(restaurant_id, dish_data['name'] or dish_info['name'])
            if not dish:
                logger.warning(f"Dish not found in database: {dish_data['name']}")
                continue
            
            dish_id = dish['id']
            stats['dishes_processed'] += 1
            
            # Link to combo groups
            for cg in dish_data['assigned_combo_groups']:
                combo_group = self.db.get_combo_group_by_source_id(restaurant_id, cg['source_id'])
                if combo_group:
                    result = self.db.insert_dish_combo_group(dish_id, combo_group['id'])
                    if result:
                        stats['combo_links_created'] += 1
                else:
                    logger.warning(f"Combo group not found: source_id={cg['source_id']}")
            
            # Handle hide on days
            if dish_data['hide_on_days']:
                self.db.update_dish_hide_option(dish_id, True)
                
                for day_value in dish_data['hide_on_days']:
                    day_of_week = DAY_OF_WEEK_MAPPING[day_value]
                    result = self.db.insert_dish_availability(dish_id, day_of_week, True)
                    if result:
                        stats['hide_days_set'] += 1
            
            # Handle drinks modifiers (TODO: implement if needed)
            stats['drinks_modifiers'] += len(dish_data['drinks_modifiers'])
            
            time.sleep(SCRAPE_DELAY)
        
        return stats

