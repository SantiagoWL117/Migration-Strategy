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

    def scrape_dish_details(self, restaurant_id: int, menu_entry_id: int) -> Optional[Dict]:
        """
        Scrape detailed information for a specific dish.

        This would fetch pricing, modifiers, ingredients, etc.
        Returns:
            {
                'prices': [{'size': str, 'price': float}],
                'ingredients': [...],
                'modifiers': [...]
            }
        """
        url = DISH_DETAIL_URL_PATTERN.format(
            base_url=self.base_url,
            restaurant_id=restaurant_id,
            menu_entry_id=menu_entry_id
        )

        try:
            self.page.goto(url, wait_until='networkidle')
            time.sleep(self.delay)

            html_content = self.page.content()
            # Parse detail page HTML here
            # This will be implemented once we see the detail page structure

            logger.info(f"Scraped details for menu entry {menu_entry_id}")
            return {}

        except Exception as e:
            logger.error(f"Failed to scrape dish details for entry {menu_entry_id}: {e}")
            return None
