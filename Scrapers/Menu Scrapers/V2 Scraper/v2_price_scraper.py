"""
V2 Price Scraper

Scrapes the V2 CRM to extract dish prices and update the V3 database.
Matches dishes by exact name_en match (not source_id, as source_id is incorrect for this restaurant).

Usage:
    python v2_price_scraper.py --restaurant-id 147 --v2-id 1171 --language en
"""

import asyncio
import argparse
import logging
import subprocess
import tempfile
import re
from datetime import datetime
from pathlib import Path
from typing import List, Dict, Tuple, Optional

from playwright.async_api import async_playwright, Page, Browser

# Add parent directory to path for config import
import sys
sys.path.insert(0, str(Path(__file__).parent.parent))
from config import (
    CRM_V2_BASE_URL, CRM_V2_USERNAME, CRM_V2_PASSWORD,
    DB_CONNECTION_STRING, PSQL_PATH, SCHEMA
)


class V2PriceScraper:
    """Scrapes V2 CRM to extract dish prices and update V3 database."""
    
    def __init__(self, restaurant_id: int, v2_restaurant_id: int, language: str = 'en'):
        self.restaurant_id = restaurant_id
        self.v2_restaurant_id = v2_restaurant_id
        self.language = language
        self.language_id = 1 if language == 'en' else 2
        
        self.browser: Optional[Browser] = None
        self.page: Optional[Page] = None
        self.logger = logging.getLogger(f'V2PriceScraper-{restaurant_id}')
        
        # Statistics
        self.stats = {
            'dishes_scraped': 0,
            'dishes_matched': 0,
            'dishes_unmatched': 0,
            'prices_deleted': 0,
            'prices_inserted': 0,
            'errors': 0,
        }
        
        # Cache for V3 lookups (indexed by name_en)
        self._dish_cache: Dict[str, int] = {}  # name_en -> v3_dish_id
        self._size_variant_cache: Dict[str, int] = {}  # name_en -> v3_size_variant_id
        
    async def setup(self):
        """Initialize browser and login to V2 CRM."""
        playwright = await async_playwright().start()
        self.browser = await playwright.chromium.launch(headless=True)
        self.page = await self.browser.new_page()
        
        # Login to V2 CRM
        await self._login()
        
    async def cleanup(self):
        """Close browser."""
        if self.browser:
            await self.browser.close()
            
    async def _login(self):
        """Login to V2 CRM."""
        login_url = f"{CRM_V2_BASE_URL}/auth/index"
        self.logger.info(f"Logging in to V2 CRM: {login_url}")
        
        await self.page.goto(login_url)
        await self.page.wait_for_load_state('networkidle')
        
        # Fill login form
        await self.page.fill('input[name="email"]', CRM_V2_USERNAME)
        await self.page.fill('input[name="password"]', CRM_V2_PASSWORD)
        await self.page.click('button[type="submit"]')
        
        # Wait for redirect after login
        await self.page.wait_for_load_state('networkidle')
        await asyncio.sleep(1)
        
        # Verify login success
        current_url = self.page.url
        if 'auth' in current_url.lower():
            raise Exception("Login failed - still on auth page")
            
        self.logger.info("Login successful")
        
    async def scrape_restaurant(self) -> Dict:
        """Scrape all dishes for the restaurant and update prices in V3."""
        # Navigate to menu page
        menu_url = f"{CRM_V2_BASE_URL}/restaurants/edit/{self.v2_restaurant_id}/menu/{self.language_id}/restaurant"
        self.logger.info(f"Navigating to menu page: {menu_url}")
        
        await self.page.goto(menu_url)
        await self.page.wait_for_load_state('networkidle')
        await asyncio.sleep(1)
        
        # Load caches
        await self._load_dish_cache()
        await self._load_size_variant_cache()
        
        # Extract all dishes from the page
        dishes_data = await self._extract_dishes()
        self.stats['dishes_scraped'] = len(dishes_data)
        
        self.logger.info(f"Found {self.stats['dishes_scraped']} dishes on page")
        self.logger.info(f"Loaded {len(self._dish_cache)} dishes from V3 (indexed by name_en)")
        
        # Process each dish
        for dish_data in dishes_data:
            try:
                await self._process_dish(dish_data)
            except Exception as e:
                self.logger.error(f"Error processing dish {dish_data.get('name', 'unknown')}: {e}")
                self.stats['errors'] += 1
                
        return self.stats
        
    async def _extract_dishes(self) -> List[Dict]:
        """Extract all dish data from the page using JavaScript."""
        dishes = await self.page.evaluate("""
            () => {
                const dishes = document.querySelectorAll('#sortable tr.sort');
                const result = [];
                
                dishes.forEach(dish => {
                    const v2_id = dish.getAttribute('data-id');
                    
                    // Extract name
                    const nameInput = dish.querySelector('input[name^="name"]');
                    const name = nameInput ? nameInput.value.trim() : '';
                    
                    // Extract sizes
                    const sizeInput = dish.querySelector('input[name^="size"]');
                    const sizeStr = sizeInput ? sizeInput.value.trim() : '';
                    const sizes = sizeStr ? sizeStr.split(',').map(s => s.trim()).filter(s => s) : [];
                    
                    // Extract prices
                    const priceInput = dish.querySelector('input[name^="price"]');
                    const priceStr = priceInput ? priceInput.value.trim() : '';
                    const prices = priceStr ? priceStr.split(',').map(p => parseFloat(p.trim())).filter(p => !isNaN(p)) : [];
                    
                    if (name) {
                        result.push({
                            v2_id: v2_id,
                            name: name,
                            sizes: sizes,
                            prices: prices
                        });
                    }
                });
                
                return result;
            }
        """)
        
        return dishes
        
    async def _load_dish_cache(self):
        """Load V3 dishes for this restaurant, indexed by name_en."""
        query = f"""
            SELECT id, name_en
            FROM {SCHEMA}.dishes
            WHERE restaurant_id = {self.restaurant_id}
        """
        
        result = self._run_query(query)
        
        # Parse output and build cache
        for line in result.stdout.split('\n'):
            line = line.strip()
            if not line or line.startswith('-') or line.startswith('id') or line.startswith('('):
                continue
            
            parts = line.split('|')
            if len(parts) >= 2:
                dish_id = parts[0].strip()
                name_en = parts[1].strip()
                if dish_id.isdigit():
                    self._dish_cache[name_en] = int(dish_id)
        
        self.logger.info(f"Loaded {len(self._dish_cache)} dishes into cache")
        
    async def _load_size_variant_cache(self):
        """Load all size variants, indexed by name_en."""
        query = f"""
            SELECT id, name_en
            FROM {SCHEMA}.dish_size_variants
        """
        
        result = self._run_query(query)
        
        # Parse output and build cache
        for line in result.stdout.split('\n'):
            line = line.strip()
            if not line or line.startswith('-') or line.startswith('id') or line.startswith('('):
                continue
            
            parts = line.split('|')
            if len(parts) >= 2:
                variant_id = parts[0].strip()
                name_en = parts[1].strip()
                if variant_id.isdigit():
                    self._size_variant_cache[name_en] = int(variant_id)
        
        self.logger.info(f"Loaded {len(self._size_variant_cache)} size variants into cache")
        
    async def _process_dish(self, dish_data: Dict):
        """Process a single dish: match by name and update prices."""
        name = dish_data['name']
        sizes = dish_data['sizes']
        prices = dish_data['prices']
        
        # Match dish by exact name_en
        v3_dish_id = self._dish_cache.get(name)
        
        if v3_dish_id is None:
            self.logger.warning(f"✗ Unmatched: '{name}' (not found in V3 by name)")
            self.stats['dishes_unmatched'] += 1
            return
        
        # Delete existing prices
        deleted_count = self._delete_dish_prices(v3_dish_id)
        self.stats['prices_deleted'] += deleted_count
        
        # Handle case where sizes is empty but prices exist
        # Use "Regular" as default size for single-price dishes
        if not sizes and prices:
            sizes = ['Regular'] * len(prices)
            self.logger.debug(f"  → Using 'Regular' size for dish with {len(prices)} price(s)")
        
        # Insert new prices
        inserted_count = 0
        price_details = []
        
        for size, price in zip(sizes, prices):
            # Get size variant ID
            size_variant_id = self._size_variant_cache.get(size)
            
            if size_variant_id is None:
                self.logger.warning(f"  ⚠ Size variant '{size}' not found in database, skipping")
                continue
            
            # Insert price
            self._insert_dish_price(v3_dish_id, size_variant_id, price)
            inserted_count += 1
            price_details.append(f"{size}: ${price:.2f}")
        
        self.stats['prices_inserted'] += inserted_count
        self.stats['dishes_matched'] += 1
        
        price_str = ", ".join(price_details) if price_details else "no prices"
        self.logger.info(f"✓ Dish {v3_dish_id} ('{name}'): Matched by name, updated {inserted_count} prices ({price_str})")
        
    def _delete_dish_prices(self, dish_id: int) -> int:
        """Delete all existing prices for a dish."""
        query = f"""
            DELETE FROM {SCHEMA}.dish_prices
            WHERE dish_id = {dish_id}
        """
        
        result = self._run_query(query)
        
        # Parse DELETE output to get count
        for line in result.stdout.split('\n'):
            if line.startswith('DELETE'):
                parts = line.split()
                if len(parts) >= 2:
                    try:
                        return int(parts[1])
                    except ValueError:
                        pass
        return 0
        
    def _insert_dish_price(self, dish_id: int, size_variant_id: int, price: float):
        """Insert a new dish price."""
        query = f"""
            INSERT INTO {SCHEMA}.dish_prices (dish_id, dish_size_variant_id, price)
            VALUES ({dish_id}, {size_variant_id}, {price})
        """
        
        self._run_query(query)
        
    def _run_query(self, query: str):
        """Execute a SQL query using psql."""
        result = subprocess.run(
            [PSQL_PATH, DB_CONNECTION_STRING, '-c', query],
            capture_output=True,
            text=True
        )
        
        if result.returncode != 0:
            raise Exception(f"Query failed: {result.stderr}")
        
        return result


async def main():
    """Main execution function."""
    parser = argparse.ArgumentParser(description='Scrape V2 CRM dish prices and update V3 database')
    parser.add_argument('--restaurant-id', type=int, required=True, help='V3 restaurant ID')
    parser.add_argument('--v2-id', type=int, required=True, help='V2 restaurant ID')
    parser.add_argument('--language', type=str, default='en', choices=['en', 'fr'], help='Language')
    
    args = parser.parse_args()
    
    # Setup logging
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )
    
    logger = logging.getLogger('main')
    logger.info("=" * 80)
    logger.info(f"Starting V2 Price Scraper for Restaurant {args.restaurant_id}")
    logger.info("=" * 80)
    
    # Create scraper
    scraper = V2PriceScraper(
        restaurant_id=args.restaurant_id,
        v2_restaurant_id=args.v2_id,
        language=args.language
    )
    
    try:
        await scraper.setup()
        stats = await scraper.scrape_restaurant()
        
        # Print summary
        logger.info("")
        logger.info("=" * 80)
        logger.info("SUMMARY")
        logger.info("=" * 80)
        logger.info(f"Total V2 dishes scraped: {stats['dishes_scraped']}")
        logger.info(f"Successfully matched by name: {stats['dishes_matched']}")
        logger.info(f"Unmatched (name not found in V3): {stats['dishes_unmatched']}")
        logger.info(f"Total prices deleted: {stats['prices_deleted']}")
        logger.info(f"Total prices inserted: {stats['prices_inserted']}")
        logger.info(f"Errors: {stats['errors']}")
        logger.info("=" * 80)
        logger.info("✓ Price update completed successfully!")
        
    except Exception as e:
        logger.error(f"Error during scraping: {e}")
        raise
    finally:
        await scraper.cleanup()


if __name__ == '__main__':
    asyncio.run(main())
