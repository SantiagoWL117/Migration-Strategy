"""
V1 Price Scraper

Scrapes dish prices from V1 CRM for dishes that are missing prices in V3.

For each dish without prices:
1. Navigate to the dish edit page (or combo edit page for combos)
2. Extract price from input#price
3. Extract quantity/size from input#quantity
4. Parse and insert into menuca_v3.dish_prices
"""

import asyncio
import sys
from pathlib import Path
from typing import List, Dict, Optional

from playwright.async_api import async_playwright, Page

# Add parent to path
sys.path.insert(0, str(Path(__file__).parent.parent))

from price_scraper_utils import (
    setup_logging,
    DatabaseConnection,
    login_to_crm,
    get_dishes_without_prices,
    insert_dish_price,
    parse_price_quantity_strings,
    get_dish_size_variant_id,
    CRM_BASE_URL,
)


class V1PriceScraper:
    """Scraper for V1 dish prices."""
    
    def __init__(self, restaurant_ids: List[int] = None, language: str = 'english',
                 log_dir: str = None):
        """
        Initialize the scraper.
        
        Args:
            restaurant_ids: List of V3 restaurant IDs to scrape (None = all)
            language: 'english' or 'french' for default size names
            log_dir: Directory for log files
        """
        self.restaurant_ids = restaurant_ids
        self.language = language
        self.log_dir = log_dir or str(Path(__file__).parent / "logs")
        
        self.logger = setup_logging("v1_price_scraper", self.log_dir)
        self.db = DatabaseConnection(logger=self.logger)
        
        # Statistics
        self.stats = {
            'dishes_found': 0,
            'dishes_scraped': 0,
            'dishes_failed': 0,
            'prices_inserted': 0,
            'prices_updated': 0,
        }
    
    async def run(self):
        """Run the price scraper."""
        self.logger.info("=" * 60)
        self.logger.info("V1 PRICE SCRAPER")
        self.logger.info("=" * 60)
        
        # Get dishes without prices
        self.logger.info("Fetching dishes without prices...")
        dishes = get_dishes_without_prices(self.db, self.restaurant_ids, self.logger)
        self.stats['dishes_found'] = len(dishes)
        
        if not dishes:
            self.logger.info("No dishes found without prices!")
            return
        
        self.logger.info(f"Found {len(dishes)} dishes without prices")
        
        # Group by restaurant for efficient scraping
        dishes_by_restaurant = {}
        for dish in dishes:
            rest_id = dish['restaurant_id']
            if rest_id not in dishes_by_restaurant:
                dishes_by_restaurant[rest_id] = {
                    'name': dish['restaurant_name'],
                    'legacy_v1_id': dish['legacy_v1_id'],
                    'dishes': []
                }
            dishes_by_restaurant[rest_id]['dishes'].append(dish)
        
        self.logger.info(f"Dishes spread across {len(dishes_by_restaurant)} restaurants")
        
        # Launch browser and scrape
        async with async_playwright() as p:
            browser = await p.chromium.launch(headless=False)
            context = await browser.new_context()
            page = await context.new_page()
            
            # Login to CRM
            if not await login_to_crm(page, self.logger):
                self.logger.error("Failed to login to V1 CRM. Aborting.")
                await browser.close()
                return
            
            # Process each restaurant
            for rest_id, rest_data in dishes_by_restaurant.items():
                await self._process_restaurant(page, rest_id, rest_data)
            
            await browser.close()
        
        # Print summary
        self._print_summary()
    
    async def _process_restaurant(self, page: Page, rest_id: int, rest_data: Dict):
        """Process all dishes for a single restaurant."""
        rest_name = rest_data['name']
        legacy_v1_id = rest_data['legacy_v1_id']
        dishes = rest_data['dishes']
        
        self.logger.info("-" * 50)
        self.logger.info(f"Restaurant: {rest_name} (V3: {rest_id}, V1: {legacy_v1_id})")
        self.logger.info(f"Dishes to scrape: {len(dishes)}")
        
        for i, dish in enumerate(dishes):
            try:
                self.logger.info(f"  [{i+1}/{len(dishes)}] {dish['dish_name']} (ID: {dish['dish_id']})")
                
                await self._scrape_dish_price(page, dish, legacy_v1_id)
                self.stats['dishes_scraped'] += 1
                
                # Small delay between dishes
                await page.wait_for_timeout(500)
                
            except Exception as e:
                self.logger.error(f"  ERROR scraping dish {dish['dish_id']}: {e}")
                self.stats['dishes_failed'] += 1
    
    async def _scrape_dish_price(self, page: Page, dish: Dict, legacy_v1_id: int):
        """
        Scrape price for a single dish.
        
        For regular dishes:
          URL: /?p=restaurants&display=editRestaurant&restaurant=[v1_id]&load=editDish&showLang=en&menuEntry=[source_id]
        
        For combo dishes:
          URL: /?p=restaurants&display=editRestaurant&restaurant=[v1_id]&load=editCombo&showLang=en&combo=[source_id]
        """
        dish_id = dish['dish_id']
        source_id = dish['source_id']
        is_combo = dish['is_combo']
        
        # Build URL based on dish type
        lang_param = "fr" if self.language == 'french' else "en"
        
        if is_combo:
            url = f"{CRM_BASE_URL}/?p=restaurants&display=editRestaurant&restaurant={legacy_v1_id}&load=editCombo&showLang={lang_param}&combo={source_id}"
        else:
            url = f"{CRM_BASE_URL}/?p=restaurants&display=editRestaurant&restaurant={legacy_v1_id}&load=editDish&showLang={lang_param}&menuEntry={source_id}"
        
        self.logger.debug(f"    URL: {url}")
        
        # Navigate to dish edit page
        try:
            await page.goto(url, wait_until='networkidle', timeout=30000)
            await page.wait_for_timeout(500)
        except Exception as e:
            self.logger.warning(f"    Navigation timeout, retrying: {e}")
            await page.goto(url, wait_until='domcontentloaded', timeout=30000)
        
        # Extract price from input#price
        price_str = await self._get_input_value(page, 'input#price, input[name="price"]')
        
        # Extract quantity/size from input#quantity
        quantity_str = await self._get_input_value(page, 'input#quantity, input[name="quantity"]')
        
        self.logger.debug(f"    Price: '{price_str}', Quantity: '{quantity_str}'")
        
        if not price_str:
            self.logger.warning(f"    No price found for dish {dish_id}")
            return
        
        # Parse prices
        parsed_prices = parse_price_quantity_strings(price_str, quantity_str, self.language)
        
        if not parsed_prices:
            self.logger.warning(f"    Could not parse prices for dish {dish_id}")
            return
        
        # Insert prices into database
        for price_data in parsed_prices:
            size_variant = price_data['size_variant']
            price = price_data['price']
            display_order = price_data['display_order']
            
            # Look up dish_size_variant_id
            dish_size_variant_id = get_dish_size_variant_id(self.db, size_variant, self.logger)
            
            # Insert/update price
            price_id = insert_dish_price(
                self.db, dish_id, size_variant, price, display_order,
                dish_size_variant_id, self.logger
            )
            
            if price_id:
                self.stats['prices_inserted'] += 1
                self.logger.info(f"    ✓ {size_variant}: ${price:.2f} (dsv_id: {dish_size_variant_id})")
    
    async def _get_input_value(self, page: Page, selector: str) -> str:
        """Get the value attribute of an input element."""
        try:
            elem = await page.query_selector(selector)
            if elem:
                value = await elem.get_attribute('value')
                return value.strip() if value else ''
        except Exception as e:
            self.logger.debug(f"    Could not get input value for {selector}: {e}")
        return ''
    
    def _print_summary(self):
        """Print scraping summary."""
        self.logger.info("=" * 60)
        self.logger.info("SCRAPING COMPLETE")
        self.logger.info("=" * 60)
        self.logger.info(f"Dishes found without prices: {self.stats['dishes_found']}")
        self.logger.info(f"Dishes scraped successfully: {self.stats['dishes_scraped']}")
        self.logger.info(f"Dishes failed:               {self.stats['dishes_failed']}")
        self.logger.info(f"Prices inserted/updated:     {self.stats['prices_inserted']}")
        self.logger.info("=" * 60)


async def main():
    """Main entry point."""
    # Target restaurants (the 10 with missing prices)
    target_restaurants = [133, 90, 234, 31, 91, 93, 87, 328, 118, 55]
    
    scraper = V1PriceScraper(
        restaurant_ids=target_restaurants,
        language='english'
    )
    
    await scraper.run()


if __name__ == "__main__":
    asyncio.run(main())





