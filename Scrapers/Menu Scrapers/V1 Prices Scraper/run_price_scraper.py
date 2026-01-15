"""
Runner script for V1 Price Scraper.

Usage:
    python run_price_scraper.py                    # Scrape all 10 target restaurants
    python run_price_scraper.py --restaurant 133   # Scrape single restaurant
    python run_price_scraper.py --all              # Scrape ALL dishes without prices
"""

import asyncio
import argparse
import sys
from pathlib import Path

# Add parent to path for imports
sys.path.insert(0, str(Path(__file__).parent))
sys.path.insert(0, str(Path(__file__).parent.parent))

from v1_price_scraper import V1PriceScraper


async def main():
    parser = argparse.ArgumentParser(description='V1 Price Scraper')
    parser.add_argument('--restaurant', '-r', type=int, nargs='+',
                        help='V3 restaurant ID(s) to scrape')
    parser.add_argument('--all', '-a', action='store_true',
                        help='Scrape all dishes without prices (not just target restaurants)')
    parser.add_argument('--language', '-l', choices=['english', 'french'], 
                        default='english', help='Language for default size names')
    
    args = parser.parse_args()
    
    # Determine which restaurants to scrape
    if args.all:
        # Scrape all restaurants with dishes missing prices
        restaurant_ids = None
        print("Scraping ALL dishes without prices...")
    elif args.restaurant:
        restaurant_ids = args.restaurant
        print(f"Scraping restaurants: {restaurant_ids}")
    else:
        # Default: the 10 target restaurants from the analysis
        restaurant_ids = [133, 90, 234, 31, 91, 93, 87, 328, 118, 55]
        print(f"Scraping default target restaurants: {restaurant_ids}")
    
    # Create and run scraper
    scraper = V1PriceScraper(
        restaurant_ids=restaurant_ids,
        language=args.language
    )
    
    await scraper.run()


if __name__ == "__main__":
    asyncio.run(main())





