"""French menu scraper for CRM data extraction."""
import time
import logging
from typing import Dict, List, Optional, Tuple
from bs4 import BeautifulSoup
from playwright.sync_api import sync_playwright, Browser, Page
from config import (
    CRM_BASE_URL, CRM_USERNAME, CRM_PASSWORD,
    SCRAPE_DELAY
)

logger = logging.getLogger(__name__)


class FrenchMenuScraper:
    """Scrapes French menu data from the CRM."""

    def __init__(self):
        self.base_url = CRM_BASE_URL
        self.username = CRM_USERNAME
        self.password = CRM_PASSWORD
        self.delay = SCRAPE_DELAY
        self.playwright = None
        self.browser = None
        self.page = None
        # French menu URL pattern
        self.menu_url_pattern = "{base_url}/?p=restaurants&display=editRestaurant&restaurant={restaurant_id}&load=menu&showLang=fr"

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

    def scrape_restaurant_menu(self, restaurant_id: int) -> Tuple[List[Dict], List[Dict]]:
        """
        Scrape courses and dishes for a restaurant (French menu).

        Args:
            restaurant_id: CRM restaurant ID

        Returns:
            Tuple of (courses_list, dishes_list)
        """
        url = self.menu_url_pattern.format(base_url=self.base_url, restaurant_id=restaurant_id)
        logger.info(f"Scraping French menu for restaurant {restaurant_id}")

        try:
            self.page.goto(url, wait_until='networkidle')
            time.sleep(self.delay)

            html_content = self.page.content()
            soup = BeautifulSoup(html_content, 'html.parser')

            courses = []
            dishes = []
            
            # Use same parsing logic as original scraper
            course_uls = soup.find_all('ul', style=lambda value: value and 'list-style-type: none' in value, id=lambda x: x and x.startswith('course_'))

            for course_index, course_ul in enumerate(course_uls):
                # Extract course name from h3
                h3 = course_ul.find('h3')
                if not h3:
                    continue

                course_name = h3.get_text(strip=True)
                if not course_name:
                    continue

                # Add course
                course_data = {
                    'name': course_name,
                    'description': '',  # Course descriptions are not in the listing page
                    'display_order': course_index
                }
                courses.append(course_data)

                # Extract dishes
                dish_lis = course_ul.find_all('li', id=lambda x: x and x.startswith('li_'))

                for dish_index, dish_li in enumerate(dish_lis):
                    # Extract menu entry ID from li id="li_77442"
                    li_id = dish_li.get('id', '')
                    menu_entry_id = li_id.replace('li_', '') if li_id else None
                    if menu_entry_id:
                        try:
                            menu_entry_id = int(menu_entry_id)
                        except (ValueError, TypeError):
                            menu_entry_id = None

                    # Extract dish name
                    # Look for the dish name in the <a> tag or <div>
                    dish_name = None
                    
                    # Try to find anchor tag with dish name (accept both editDish and editCombo)
                    a_tag = dish_li.find('a', href=lambda x: x and ('editDish' in x or 'editCombo' in x))
                    if a_tag:
                        dish_name = a_tag.get_text(strip=True)
                    
                    # Fallback: get text from div
                    if not dish_name:
                        div = dish_li.find('div')
                        if div:
                            dish_name = div.get_text(strip=True)
                    
                    if not dish_name:
                        continue

                    dish_data = {
                        'course_index': course_index,
                        'name': dish_name,
                        'description': '',  # Descriptions are in detail pages
                        'display_order': dish_index,
                        'source_id': menu_entry_id
                    }
                    dishes.append(dish_data)

            logger.info(f"Found {len(courses)} courses with {len(dishes)} dishes")
            return courses, dishes

        except Exception as e:
            logger.error(f"Error scraping restaurant {restaurant_id}: {e}")
            raise

