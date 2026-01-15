"""
Test script to scrape prices for a single restaurant.

Usage:
    python test_single_restaurant.py 234   # Scrape New Mukut (17 dishes)
    python test_single_restaurant.py 55    # Scrape Milano (1 dish)
"""

import asyncio
import sys
from pathlib import Path

# Add parent to path for imports
sys.path.insert(0, str(Path(__file__).parent))
sys.path.insert(0, str(Path(__file__).parent.parent))

from v1_price_scraper import V1PriceScraper


async def main():
    if len(sys.argv) < 2:
        print("Usage: python test_single_restaurant.py <restaurant_id>")
        print("\nSuggested test restaurants:")
        print("  234 - New Mukut Restaurant Indian Cuisine (17 dishes)")
        print("  55  - Milano (1 dish)")
        print("  118 - Mano City Pizza (1 dish)")
        print("  87  - Champa Thai Cuisine (2 dishes)")
        print("  328 - JN Pizza (2 dishes)")
        return
    
    restaurant_id = int(sys.argv[1])
    print(f"Testing V1 Price Scraper for restaurant ID: {restaurant_id}")
    
    scraper = V1PriceScraper(
        restaurant_ids=[restaurant_id],
        language='english'
    )
    
    await scraper.run()


if __name__ == "__main__":
    asyncio.run(main())





