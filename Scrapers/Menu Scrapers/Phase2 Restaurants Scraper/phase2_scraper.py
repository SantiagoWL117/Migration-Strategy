"""Core scraping logic for Phase 2 Restaurants Scraper.

Uses Playwright for browser automation and BeautifulSoup for HTML parsing.
"""
import re
import time
import logging
from typing import Dict, List, Optional, Any
from playwright.sync_api import sync_playwright, Browser, Page, TimeoutError as PlaywrightTimeout
from bs4 import BeautifulSoup

from phase2_config import (
    CRM_LOGIN_URL, CRM_USERNAME, CRM_PASSWORD,
    MENU_URL_PATTERN, COMBO_GROUPS_URL_PATTERN,
    DISH_URL_PATTERN, COMBO_DISH_URL_PATTERN,
    SECTION_CHECKBOX_MAPPING, SECTION_TYPE_MAPPING,
    SIZE_VARIANTS, DEFAULT_SIZE, DAY_OF_WEEK_MAPPING,
    TIMEOUT, NAVIGATION_TIMEOUT, SCRAPE_DELAY
)
from phase2_database import Phase2Database

logger = logging.getLogger(__name__)


class Phase2Scraper:
    """Scraper for Phase 2 Restaurants - handles all 3 phases of scraping."""

    def __init__(self, headless: bool = True):
        self.headless = headless
        self.playwright = None
        self.browser: Optional[Browser] = None
        self.page: Optional[Page] = None
        self.db = Phase2Database()

    def __enter__(self):
        self.start()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.stop()

    def start(self):
        """Start browser and database connection."""
        self.playwright = sync_playwright().start()
        self.browser = self.playwright.chromium.launch(headless=self.headless)
        self.page = self.browser.new_page()
        self.page.set_default_timeout(TIMEOUT)
        self.page.set_default_navigation_timeout(NAVIGATION_TIMEOUT)
        self.db.connect()
        logger.info("Scraper started")

    def stop(self):
        """Stop browser and close database connection."""
        if self.page:
            self.page.close()
        if self.browser:
            self.browser.close()
        if self.playwright:
            self.playwright.stop()
        self.db.close()
        logger.info("Scraper stopped")

    def login(self) -> bool:
        """Login to V1 CRM."""
        logger.info(f"Logging in to {CRM_LOGIN_URL}...")

        try:
            self.page.goto(CRM_LOGIN_URL, wait_until='domcontentloaded')
            self.page.wait_for_load_state('networkidle', timeout=15000)
            time.sleep(1)

            # Check if credentials are loaded
            if not CRM_USERNAME or not CRM_PASSWORD:
                logger.error(
                    f"Missing credentials: username={bool(CRM_USERNAME)}, password={bool(CRM_PASSWORD)}")
                return False

            # Try different form input names
            try:
                self.page.wait_for_selector(
                    'input[name="username"]', state='visible', timeout=5000)
                logger.info("Found login form with name='username'")
                self.page.fill('input[name="username"]', CRM_USERNAME)
                self.page.fill('input[name="password"]', CRM_PASSWORD)
                self.page.click('input[type="submit"]')
            except Exception as e1:
                logger.debug(f"username form failed: {e1}")
                try:
                    # Try name="user" (older form)
                    self.page.wait_for_selector(
                        'input[name="user"]', state='visible', timeout=3000)
                    logger.info("Found login form with name='user'")
                    self.page.fill('input[name="user"]', CRM_USERNAME)
                    self.page.fill('input[name="password"]', CRM_PASSWORD)
                    self.page.click('input[type="submit"]')
                except Exception as e2:
                    logger.error(f"Could not find login form: {e2}")
                    return False

            # Wait for navigation after login
            self.page.wait_for_load_state('networkidle', timeout=15000)
            time.sleep(1)

            # Check if login was successful
            if 'restaurants' in self.page.url:
                logger.info("Login successful")
                return True
            else:
                logger.error(f"Login failed - unexpected URL: {self.page.url}")
                return False

        except Exception as e:
            logger.error(f"Login failed: {e}")
            return False

    # =========================================================================
    # PHASE 1: Combo Groups Scraping
    # =========================================================================

    def scrape_combo_groups(self, restaurant_id: int, v1_id: int) -> Dict[str, int]:
        """
        Phase 1: Scrape combo groups, sections, modifier groups, modifiers, and prices.

        Returns statistics about what was scraped.
        """
        stats = {
            'combo_groups': 0,
            'sections': 0,
            'modifier_groups': 0,
            'modifiers': 0,
            'prices': 0
        }

        # Navigate to combo groups page
        url = COMBO_GROUPS_URL_PATTERN.format(v1_id=v1_id)
        logger.info(f"Navigating to combo groups: {url}")

        try:
            self.page.goto(url)
            self.page.wait_for_load_state('networkidle')
        except PlaywrightTimeout:
            logger.warning("Timeout loading combo groups page")
            return stats

        # Get page HTML
        html = self.page.content()
        soup = BeautifulSoup(html, 'html.parser')

        # Find combo group links
        # Look for <p> elements with the specific style containing <a onclick="editGroupJS(...)">
        combo_group_links = soup.select(
            'p[style*="background-color: #ccc"] a[onclick*="editGroupJS"]')

        if not combo_group_links:
            logger.info(
                f"No combo groups found for restaurant {restaurant_id}")
            return stats

        logger.info(f"Found {len(combo_group_links)} combo groups")

        # Collect all combo group info first
        combo_groups_info = []
        for link in combo_group_links:
            onclick = link.get('onclick', '')
            match = re.search(r"editGroupJS\('(\d+)'\)", onclick)
            if match:
                combo_groups_info.append({
                    'source_id': int(match.group(1)),
                    'name': link.get_text(strip=True)
                })

        # Process each combo group (navigate fresh for each to avoid modal blocking)
        for group_info in combo_groups_info:
            source_id = group_info['source_id']
            group_name = group_info['name']

            logger.info(
                f"Processing combo group: {group_name} (source_id={source_id})")

            # Navigate fresh to combo groups page for each group
            try:
                self.page.goto(url)
                self.page.wait_for_load_state('networkidle')
                time.sleep(0.5)

                # Click to load the combo group details
                self.page.click(f'a[onclick*="editGroupJS(\'{source_id}\')"]')
                self.page.wait_for_load_state('networkidle')
                time.sleep(SCRAPE_DELAY)
            except Exception as e:
                logger.warning(f"Could not load combo group {group_name}: {e}")
                continue

            # Parse the combo group details from the updated page
            group_html = self.page.content()
            group_stats = self._parse_combo_group(
                restaurant_id, source_id, group_html)

            stats['combo_groups'] += 1
            stats['sections'] += group_stats['sections']
            stats['modifier_groups'] += group_stats['modifier_groups']
            stats['modifiers'] += group_stats['modifiers']
            stats['prices'] += group_stats['prices']

        return stats

    def _parse_combo_group(self, restaurant_id: int, source_id: int, html: str) -> Dict[str, int]:
        """Parse a single combo group's details from HTML."""
        stats = {'sections': 0, 'modifier_groups': 0,
                 'modifiers': 0, 'prices': 0}

        soup = BeautifulSoup(html, 'html.parser')

        # Get combo group basic info
        name_input = soup.find('input', {'id': 'name'})
        name = name_input.get('value', '') if name_input else ''

        itemcount_input = soup.find('input', {'id': 'itemcount'})
        number_of_items = int(itemcount_input.get(
            'value', '1') or '1') if itemcount_input else 1

        display_header_input = soup.find('input', {'id': 'displayHeader'})
        display_header = display_header_input.get(
            'value', '') if display_header_input else ''

        # Insert combo group
        combo_group_id = self.db.insert_combo_group(
            restaurant_id=restaurant_id,
            name=name,
            number_of_items=number_of_items,
            display_header=display_header or None,
            source_id=source_id
        )

        if not combo_group_id:
            logger.error(f"Failed to insert combo group: {name}")
            return stats

        logger.info(f"Inserted combo group: {name} (ID: {combo_group_id})")

        # Parse sections (only checked ones)
        for checkbox_name, section_config in SECTION_CHECKBOX_MAPPING.items():
            checkbox = soup.find('input', {'id': checkbox_name})
            if not checkbox or not checkbox.has_attr('checked'):
                continue

            section_type = section_config['section_type']
            div_id = section_config['div_id']
            ul_id = section_config['ul_id']

            # Get section config
            header_input = soup.find(
                'input', {'id': section_config['header_input']})
            use_header = header_input.get('value', '') if header_input else ''

            display_order_input = soup.find(
                'input', {'id': section_config['display_order_input']})
            display_order = int(display_order_input.get(
                'value', '0') or '0') if display_order_input else 0

            min_selection = 0
            max_selection = 0
            free_items = 0

            if section_config['min_input']:
                min_input = soup.find(
                    'input', {'id': section_config['min_input']})
                min_selection = int(min_input.get(
                    'value', '0') or '0') if min_input else 0

            if section_config['max_input']:
                max_input = soup.find(
                    'input', {'id': section_config['max_input']})
                max_selection = int(max_input.get(
                    'value', '0') or '0') if max_input else 0

            if section_config['free_input']:
                free_input = soup.find(
                    'input', {'id': section_config['free_input']})
                free_items = int(free_input.get('value', '0')
                                 or '0') if free_input else 0

            # Insert section
            section_id = self.db.insert_combo_group_section(
                combo_group_id=combo_group_id,
                section_type=section_type,
                use_header=use_header or '',
                display_order=display_order,
                free_items=free_items,
                min_selection=min_selection,
                max_selection=max_selection
            )

            if section_id:
                stats['sections'] += 1

                # Parse modifier groups within this section (only checked radio buttons)
                section_div = soup.find('div', {'id': div_id})
                if section_div:
                    mg_stats = self._parse_section_modifier_groups(
                        section_id, section_type, section_div
                    )
                    stats['modifier_groups'] += mg_stats['modifier_groups']
                    stats['modifiers'] += mg_stats['modifiers']
                    stats['prices'] += mg_stats['prices']

        return stats

    def _parse_section_modifier_groups(self, section_id: int, section_type: str,
                                       section_div) -> Dict[str, int]:
        """Parse modifier groups within a combo group section.

        IMPORTANT: Only scrape combo modifier groups that are checked (active).
        In V1, only one radio button per section is checked - this is the active
        modifier group that should be scraped.
        """
        stats = {'modifier_groups': 0, 'modifiers': 0, 'prices': 0}

        # Get type code prefix (e.g., 'ci' for custom_ingredients)
        # SECTION_TYPE_MAPPING: {'ci_id': 'custom_ingredients', ...}
        # We need to reverse it and strip '_id' to get 'ci'
        type_code_map = {v: k.replace('_id', '')
                         for k, v in SECTION_TYPE_MAPPING.items()}
        type_prefix = type_code_map.get(section_type, section_type[:2])

        # Find radio buttons for modifier groups
        # HTML: <input class="ci" checked="" type="radio" name="ci_radio" value="8175">
        radios = section_div.find_all(
            'input', {'type': 'radio', 'name': f'{type_prefix}_radio'})

        for radio in radios:
            # ONLY process checked radio buttons (active combo modifier groups)
            if not radio.has_attr('checked'):
                continue

            source_id = int(radio.get('value', '0'))

            # Get modifier group name from label
            label = section_div.find('label', {'for': radio.get('id', '')})
            group_name = label.get_text(
                strip=True) if label else f"Group {source_id}"

            # Insert modifier group (is_selected=True since we only process checked)
            modifier_group_id = self.db.insert_combo_modifier_group(
                combo_group_section_id=section_id,
                name=group_name,
                type_code=type_prefix,
                is_selected=True,
                source_id=source_id
            )

            if modifier_group_id:
                stats['modifier_groups'] += 1
                logger.debug(
                    f"    Inserted combo modifier group: {group_name} (source_id={source_id})")

                # Parse modifiers within this group
                list_id = f"list_{type_prefix}_{source_id}"
                modifier_list = section_div.find('ul', {'id': list_id})

                if modifier_list:
                    mod_stats = self._parse_modifiers(modifier_group_id, type_prefix,
                                                      source_id, modifier_list)
                    stats['modifiers'] += mod_stats['modifiers']
                    stats['prices'] += mod_stats['prices']

        return stats

    def _parse_modifiers(self, modifier_group_id: int, type_prefix: str,
                         group_source_id: int, modifier_list) -> Dict[str, int]:
        """Parse individual modifiers and their prices."""
        stats = {'modifiers': 0, 'prices': 0}

        # Each modifier is in an <li> with an input for prices
        items = modifier_list.find_all('li')

        for idx, item in enumerate(items):
            # Get modifier name (text before input)
            text_content = item.get_text(strip=True)
            input_elem = item.find('input', {'type': 'text'})

            if not input_elem:
                continue

            # Parse input name to get modifier source_id
            # Format: ci[8173][37052] -> type[group_id][modifier_id]
            input_name = input_elem.get('name', '')
            match = re.search(
                rf'{type_prefix}\[{group_source_id}\]\[(\d+)\]', input_name)

            if not match:
                continue

            modifier_source_id = int(match.group(1))

            # Get modifier name (text before the input value)
            price_value = input_elem.get('value', '0.00')
            modifier_name = text_content.replace(price_value, '').strip()

            if not modifier_name:
                continue

            # Insert modifier
            modifier_id = self.db.insert_combo_modifier(
                combo_modifier_group_id=modifier_group_id,
                name=modifier_name,
                display_order=idx
            )

            if modifier_id:
                stats['modifiers'] += 1

                # Parse prices
                prices = self._parse_price_string(price_value)
                for size_variant, price in prices.items():
                    price_id = self.db.insert_combo_modifier_price(
                        combo_modifier_id=modifier_id,
                        size_variant=size_variant,
                        price=price
                    )
                    if price_id:
                        stats['prices'] += 1

        return stats

    def _parse_price_string(self, price_str: str) -> Dict[str, float]:
        """Parse a price string that may contain multiple comma-separated values."""
        prices = {}

        if not price_str:
            return {DEFAULT_SIZE: 0.0}

        values = [v.strip() for v in price_str.split(',')]

        if len(values) == 1:
            try:
                prices[DEFAULT_SIZE] = float(values[0])
            except ValueError:
                prices[DEFAULT_SIZE] = 0.0
        else:
            for idx, value in enumerate(values):
                if idx < len(SIZE_VARIANTS):
                    try:
                        prices[SIZE_VARIANTS[idx]] = float(value)
                    except ValueError:
                        prices[SIZE_VARIANTS[idx]] = 0.0

        return prices

    # =========================================================================
    # PHASE 2: Courses and Dishes Scraping
    # =========================================================================

    def scrape_menu_structure(self, restaurant_id: int, v1_id: int) -> Dict[str, int]:
        """
        Phase 2: Scrape courses and dishes from the menu page.

        Returns statistics about what was scraped.
        """
        stats = {
            'courses': 0,
            'dishes': 0,
            'combo_dishes': 0,
            'normal_dishes': 0
        }

        # Navigate to menu page
        url = MENU_URL_PATTERN.format(v1_id=v1_id)
        logger.info(f"Navigating to menu: {url}")

        try:
            self.page.goto(url)
            self.page.wait_for_load_state('networkidle')
        except PlaywrightTimeout:
            logger.warning("Timeout loading menu page")
            return stats

        # Get page HTML
        html = self.page.content()
        soup = BeautifulSoup(html, 'html.parser')

        # Find all course lists (ul with id starting with "course_")
        course_lists = soup.find_all(
            'ul', id=lambda x: x and x.startswith('course_'))

        if not course_lists:
            logger.info(f"No courses found for restaurant {restaurant_id}")
            return stats

        logger.info(f"Found {len(course_lists)} courses")

        for course_ul in course_lists:
            course_id_str = course_ul.get('id', '').replace('course_', '')

            try:
                course_source_id = int(course_id_str)
            except ValueError:
                continue

            # Get course name from h3
            course_header = course_ul.find('li', recursive=False)
            h3 = course_header.find('h3') if course_header else None
            course_name = h3.get_text(
                strip=True) if h3 else f"Course {course_source_id}"

            # Insert course
            course_id = self.db.insert_course(
                restaurant_id=restaurant_id,
                name=course_name,
                display_order=stats['courses'],
                source_id=course_source_id
            )

            if not course_id:
                logger.warning(f"Failed to insert course: {course_name}")
                continue

            stats['courses'] += 1
            logger.info(f"Inserted course: {course_name} (ID: {course_id})")

            # Find dish links within this course
            dish_items = course_ul.find_all(
                'li', id=lambda x: x and x.startswith('li_'))

            for dish_item in dish_items:
                dish_link = dish_item.find('a', href=True)
                if not dish_link:
                    continue

                href = dish_link.get('href', '')
                dish_name = dish_link.get_text(strip=True)

                # Determine if combo or normal dish
                is_combo = 'combo=' in href

                # Extract source_id
                if is_combo:
                    match = re.search(r'combo=(\d+)', href)
                else:
                    match = re.search(r'menuEntry=(\d+)', href)

                if not match:
                    continue

                dish_source_id = int(match.group(1))

                # Get description (text after the link within the li)
                description = None
                li_text = dish_item.get_text(strip=True)
                if ' - ' in li_text:
                    parts = li_text.split(' - ', 1)
                    if len(parts) > 1:
                        description = parts[1].strip()

                # Insert dish
                dish_id = self.db.insert_dish(
                    restaurant_id=restaurant_id,
                    course_id=course_id,
                    name=dish_name,
                    description=description,
                    display_order=stats['dishes'],
                    is_combo=is_combo,
                    source_id=dish_source_id
                )

                if dish_id:
                    stats['dishes'] += 1
                    if is_combo:
                        stats['combo_dishes'] += 1
                    else:
                        stats['normal_dishes'] += 1
                    logger.debug(
                        f"Inserted dish: {dish_name} (combo={is_combo})")

        return stats

    # =========================================================================
    # PHASE 3: Dish Details Scraping
    # =========================================================================

    def scrape_dish_details(self, restaurant_id: int, v1_id: int) -> Dict[str, int]:
        """
        Phase 3: Navigate to each dish detail page and scrape prices, modifiers, etc.

        Returns statistics about what was scraped.
        """
        stats = {
            'dishes_processed': 0,
            'dish_prices': 0,
            'combo_links': 0,
            'hide_days': 0,
            'modifier_groups': 0,
            'modifiers': 0,
            'modifier_prices': 0,
            'drinks_modifiers': 0
        }

        # Navigate to menu page first to get list of dishes
        url = MENU_URL_PATTERN.format(v1_id=v1_id)

        try:
            self.page.goto(url)
            self.page.wait_for_load_state('networkidle')
        except PlaywrightTimeout:
            logger.warning("Timeout loading menu page")
            return stats

        # Get page HTML and find all dishes
        html = self.page.content()
        soup = BeautifulSoup(html, 'html.parser')

        # Collect all dish links
        dish_links = []

        course_lists = soup.find_all(
            'ul', id=lambda x: x and x.startswith('course_'))
        for course_ul in course_lists:
            dish_items = course_ul.find_all(
                'li', id=lambda x: x and x.startswith('li_'))

            for dish_item in dish_items:
                link = dish_item.find('a', href=True)
                if not link:
                    continue

                href = link.get('href', '')
                dish_name = link.get_text(strip=True)
                is_combo = 'combo=' in href

                if is_combo:
                    match = re.search(r'combo=(\d+)', href)
                else:
                    match = re.search(r'menuEntry=(\d+)', href)

                if match:
                    source_id = int(match.group(1))
                    dish_links.append({
                        'name': dish_name,
                        'source_id': source_id,
                        'is_combo': is_combo,
                        'href': href
                    })

        logger.info(f"Found {len(dish_links)} dishes to process")

        # Process each dish
        for dish_info in dish_links:
            # Get dish from database by source_id
            dish = self.db.get_dish_by_source_id(
                restaurant_id, dish_info['source_id'])

            if not dish:
                logger.warning(
                    f"Dish not found in database: {dish_info['name']}")
                continue

            dish_id = dish['id']

            logger.info(
                f"Processing dish: {dish_info['name']} (ID: {dish_id}, combo={dish_info['is_combo']})")

            # Navigate to dish detail page
            if dish_info['is_combo']:
                detail_url = COMBO_DISH_URL_PATTERN.format(
                    v1_id=v1_id,
                    combo_id=dish_info['source_id']
                )
            else:
                detail_url = DISH_URL_PATTERN.format(
                    v1_id=v1_id,
                    menu_entry_id=dish_info['source_id']
                )

            try:
                self.page.goto(detail_url)
                self.page.wait_for_load_state('networkidle')
            except PlaywrightTimeout:
                logger.warning(
                    f"Timeout loading dish detail page: {dish_info['name']}")
                continue

            detail_html = self.page.content()

            if dish_info['is_combo']:
                dish_stats = self._parse_combo_dish_detail(
                    restaurant_id, dish_id, detail_html
                )
            else:
                dish_stats = self._parse_normal_dish_detail(
                    restaurant_id, dish_id, detail_html
                )

            stats['dishes_processed'] += 1
            stats['dish_prices'] += dish_stats.get('prices', 0)
            stats['combo_links'] += dish_stats.get('combo_links', 0)
            stats['hide_days'] += dish_stats.get('hide_days', 0)
            stats['modifier_groups'] += dish_stats.get('modifier_groups', 0)
            stats['modifiers'] += dish_stats.get('modifiers', 0)
            stats['modifier_prices'] += dish_stats.get('modifier_prices', 0)
            stats['drinks_modifiers'] += dish_stats.get('drinks_modifiers', 0)

            time.sleep(SCRAPE_DELAY)

        return stats

    def _parse_combo_dish_detail(self, restaurant_id: int, dish_id: int,
                                 html: str) -> Dict[str, int]:
        """Parse combo dish detail page for price, combo links, drinks, hide-on-days."""
        stats = {'prices': 0, 'combo_links': 0,
                 'hide_days': 0, 'drinks_modifiers': 0}

        soup = BeautifulSoup(html, 'html.parser')

        # Get price
        price_input = soup.find('input', {'id': 'price'})
        if price_input:
            price_str = price_input.get('value', '0')
            prices = self._parse_price_string(price_str)

            for size_variant, price in prices.items():
                price_id = self.db.insert_dish_price(
                    dish_id=dish_id,
                    restaurant_id=restaurant_id,
                    price=price,
                    size_variant=size_variant
                )
                if price_id:
                    stats['prices'] += 1

        # Get linked combo groups (checked checkboxes)
        combo_checkboxes = soup.find_all(
            'input', {'name': 'group[]', 'type': 'checkbox'})

        for checkbox in combo_checkboxes:
            if not checkbox.has_attr('checked'):
                continue

            combo_group_source_id = int(checkbox.get('value', '0'))

            # Find combo group in database
            combo_group = self.db.get_combo_group_by_source_id(
                restaurant_id, combo_group_source_id)

            if combo_group:
                link_id = self.db.insert_dish_combo_group(
                    dish_id, combo_group['id'])
                if link_id:
                    stats['combo_links'] += 1
            else:
                logger.warning(
                    f"Combo group not found: source_id={combo_group_source_id}")

        # Handle drinks modifiers
        drinks_stats = self._parse_drinks_modifiers(
            restaurant_id, dish_id, soup)
        stats['drinks_modifiers'] += drinks_stats

        # Handle hide-on-days
        hide_stats = self._parse_hide_on_days(dish_id, soup)
        stats['hide_days'] += hide_stats

        return stats

    def _parse_normal_dish_detail(self, restaurant_id: int, dish_id: int,
                                  html: str) -> Dict[str, int]:
        """Parse normal dish detail page for prices, modifiers, hide-on-days."""
        stats = {
            'prices': 0,
            'modifier_groups': 0,
            'modifiers': 0,
            'modifier_prices': 0,
            'hide_days': 0
        }

        soup = BeautifulSoup(html, 'html.parser')

        # Get price
        price_input = soup.find('input', {'id': 'price'})
        if price_input:
            price_str = price_input.get('value', '0')
            prices = self._parse_price_string(price_str)

            for idx, (size_variant, price) in enumerate(prices.items()):
                price_id = self.db.insert_dish_price(
                    dish_id=dish_id,
                    restaurant_id=restaurant_id,
                    price=price,
                    size_variant=size_variant,
                    display_order=idx + 1
                )
                if price_id:
                    stats['prices'] += 1

        # Parse modifier groups from #groups div
        groups_div = soup.find('div', {'id': 'groups'})

        if groups_div:
            # Log what sections exist in #groups
            found_sections = []
            for div_id in ['br_id', 'ci_id', 'dr_id', 'sa_id', 'sd_id', 'e_id', 'cm_id']:
                if groups_div.find('div', {'id': div_id}):
                    found_sections.append(div_id)

            if found_sections:
                logger.info(f"  #groups has sections: {found_sections}")
            else:
                logger.warning(
                    f"  #groups div exists but has no section divs for dish {dish_id}")

            mod_stats = self._parse_dish_modifier_groups(
                restaurant_id, dish_id, groups_div)
            stats['modifier_groups'] = mod_stats['modifier_groups']
            stats['modifiers'] = mod_stats['modifiers']
            stats['modifier_prices'] = mod_stats['modifier_prices']

            if mod_stats['modifier_groups'] > 0:
                logger.info(f"  Found {mod_stats['modifier_groups']} modifier groups, "
                            f"{mod_stats['modifiers']} modifiers for dish {dish_id}")
        else:
            logger.warning(f"  No #groups div found for dish {dish_id}")

        # Handle hide-on-days
        hide_stats = self._parse_hide_on_days(dish_id, soup)
        stats['hide_days'] = hide_stats

        return stats

    def _parse_dish_modifier_groups(self, restaurant_id: int, dish_id: int,
                                    groups_div) -> Dict[str, int]:
        """Parse modifier groups for a normal dish."""
        stats = {'modifier_groups': 0, 'modifiers': 0, 'modifier_prices': 0}

        # Process each section type
        # SECTION_TYPE_MAPPING: {'br_id': 'bread', 'ci_id': 'custom_ingredients', ...}
        # Keys are div IDs, values are section type names
        for div_id, section_type in SECTION_TYPE_MAPPING.items():
            section_div = groups_div.find('div', {'id': div_id})
            if not section_div:
                continue

            # Get type prefix for input names (e.g., 'ci' from 'ci_id')
            type_prefix = div_id.replace('_id', '')

            # Find radio buttons for this section
            # Radio buttons have name="{type_prefix}_radio" (e.g., "ci_radio", "br_radio")
            radios = section_div.find_all(
                'input', {'type': 'radio', 'name': f'{type_prefix}_radio'})

            # Count checked radios
            checked_radios = [r for r in radios if r.has_attr('checked')]
            if radios:
                logger.info(
                    f"    Section {div_id}: {len(radios)} radios, {len(checked_radios)} checked")

            for radio in radios:
                if not radio.has_attr('checked'):
                    continue

                source_id = int(radio.get('value', '0'))

                # Get modifier group name
                label = section_div.find('label', {'for': radio.get('id', '')})
                group_name = label.get_text(
                    strip=True) if label else f"Group {source_id}"

                # Insert modifier group
                modifier_group_id = self.db.insert_modifier_group(
                    dish_id=dish_id,
                    name=group_name,
                    display_order=stats['modifier_groups']
                )

                if modifier_group_id:
                    stats['modifier_groups'] += 1

                    # Parse modifiers
                    list_id = f"list_{type_prefix}_{source_id}"
                    modifier_list = section_div.find('ul', {'id': list_id})

                    if modifier_list:
                        mod_stats = self._parse_dish_modifiers(
                            restaurant_id, dish_id, modifier_group_id,
                            type_prefix, source_id, modifier_list, section_type
                        )
                        stats['modifiers'] += mod_stats['modifiers']
                        stats['modifier_prices'] += mod_stats['prices']

        return stats

    def _parse_dish_modifiers(self, restaurant_id: int, dish_id: int,
                              modifier_group_id: int, type_prefix: str,
                              group_source_id: int, modifier_list,
                              section_type: str) -> Dict[str, int]:
        """Parse individual dish modifiers and their prices."""
        stats = {'modifiers': 0, 'prices': 0}

        items = modifier_list.find_all('li')

        for idx, item in enumerate(items):
            input_elem = item.find('input', {'type': 'text'})
            if not input_elem:
                continue

            # Parse input name
            input_name = input_elem.get('name', '')
            match = re.search(
                rf'{type_prefix}\[{group_source_id}\]\[(\d+)\]', input_name)

            if not match:
                continue

            modifier_source_id = int(match.group(1))

            # Get modifier name
            text_content = item.get_text(strip=True)
            price_value = input_elem.get('value', '0.00')
            modifier_name = text_content.replace(price_value, '').strip()

            if not modifier_name:
                continue

            # Insert modifier
            modifier_id = self.db.insert_dish_modifier(
                restaurant_id=restaurant_id,
                dish_id=dish_id,
                modifier_group_id=modifier_group_id,
                name=modifier_name,
                modifier_type=section_type,
                display_order=idx,
                source_id=modifier_source_id
            )

            if modifier_id:
                stats['modifiers'] += 1

                # Parse and insert prices
                prices = self._parse_price_string(price_value)
                for size_variant, price in prices.items():
                    price_id = self.db.insert_dish_modifier_price(
                        dish_modifier_id=modifier_id,
                        dish_id=dish_id,
                        restaurant_id=restaurant_id,
                        price=price,
                        size_variant=size_variant
                    )
                    if price_id:
                        stats['prices'] += 1

        return stats

    def _parse_drinks_modifiers(self, restaurant_id: int, dish_id: int,
                                soup) -> int:
        """Parse drinks modifiers for a combo dish."""
        count = 0

        # Look for drinks section
        drinks_div = soup.find('div', {'id': 'd_id'})
        if not drinks_div:
            return count

        # Find checked drink radio buttons
        radios = drinks_div.find_all('input', {'type': 'radio', 'class': 'd'})

        for radio in radios:
            if not radio.has_attr('checked'):
                continue

            source_id = int(radio.get('value', '0'))

            # Get group name
            label = drinks_div.find('label', {'for': radio.get('id', '')})
            group_name = label.get_text(
                strip=True) if label else f"Drinks {source_id}"

            # Insert modifier group
            modifier_group_id = self.db.insert_modifier_group(
                dish_id=dish_id,
                name=group_name,
                display_order=0
            )

            if not modifier_group_id:
                continue

            # Parse drink modifiers
            list_id = f"list_d_{source_id}"
            drink_list = drinks_div.find('ul', {'id': list_id})

            if drink_list:
                items = drink_list.find_all('li')

                for idx, item in enumerate(items):
                    input_elem = item.find('input', {'type': 'text'})
                    if not input_elem:
                        continue

                    # Get modifier name
                    text_content = item.get_text(strip=True)
                    price_value = input_elem.get('value', '0.00')
                    modifier_name = text_content.replace(
                        price_value, '').strip()

                    if not modifier_name:
                        continue

                    # Insert drink modifier
                    modifier_id = self.db.insert_dish_modifier(
                        restaurant_id=restaurant_id,
                        dish_id=dish_id,
                        modifier_group_id=modifier_group_id,
                        name=modifier_name,
                        modifier_type='drinks',
                        display_order=idx
                    )

                    if modifier_id:
                        # Insert price
                        try:
                            price = float(price_value.split(',')[0])
                        except ValueError:
                            price = 0.0

                        self.db.insert_dish_modifier_price(
                            dish_modifier_id=modifier_id,
                            dish_id=dish_id,
                            restaurant_id=restaurant_id,
                            price=price,
                            size_variant=DEFAULT_SIZE
                        )
                        count += 1

        return count

    def _parse_hide_on_days(self, dish_id: int, soup) -> int:
        """Parse hide-on-days checkboxes."""
        count = 0

        hide_checkboxes = soup.find_all('input', {'name': 'hideOnDays[]'})
        hidden_days = []

        for checkbox in hide_checkboxes:
            if checkbox.has_attr('checked'):
                day_value = checkbox.get('value', '')
                if day_value in DAY_OF_WEEK_MAPPING:
                    hidden_days.append(day_value)

        if hidden_days:
            # Update dish hide_option_enabled
            self.db.update_dish_hide_option(dish_id, True)

            # Insert availability records
            for day_value in hidden_days:
                day_of_week = DAY_OF_WEEK_MAPPING[day_value]
                result = self.db.insert_dish_availability(
                    dish_id, day_of_week, True)
                if result:
                    count += 1

        return count

    # =========================================================================
    # Main Scraping Method
    # =========================================================================

    def scrape_restaurant(self, restaurant_id: int, v1_id: int) -> Dict[str, Any]:
        """
        Scrape all data for a restaurant (all 3 phases).

        Args:
            restaurant_id: V3 restaurant ID
            v1_id: V1 legacy ID

        Returns:
            Dictionary with statistics from all phases
        """
        results = {
            'restaurant_id': restaurant_id,
            'v1_id': v1_id,
            'phase1': {},
            'phase2': {},
            'phase3': {},
            'status': 'success',
            'error': None
        }

        try:
            # Phase 1: Combo Groups
            logger.info(f"=== PHASE 1: Combo Groups ===")
            results['phase1'] = self.scrape_combo_groups(restaurant_id, v1_id)
            logger.info(f"Phase 1 complete: {results['phase1']}")

            # Phase 2: Menu Structure
            logger.info(f"=== PHASE 2: Menu Structure ===")
            results['phase2'] = self.scrape_menu_structure(
                restaurant_id, v1_id)
            logger.info(f"Phase 2 complete: {results['phase2']}")

            # Phase 3: Dish Details
            logger.info(f"=== PHASE 3: Dish Details ===")
            results['phase3'] = self.scrape_dish_details(restaurant_id, v1_id)
            logger.info(f"Phase 3 complete: {results['phase3']}")

        except Exception as e:
            logger.error(f"Error scraping restaurant: {e}", exc_info=True)
            results['status'] = 'error'
            results['error'] = str(e)

        return results
