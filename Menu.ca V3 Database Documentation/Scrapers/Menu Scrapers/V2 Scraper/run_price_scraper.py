"""
Runner script for V2 Price Scraper

Executes the price scraper for restaurant 147.
"""

import asyncio
import logging
from v2_price_scraper import V2PriceScraper


async def main():
    """Run the price scraper for restaurant 147."""
    # Setup logging
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )
    
    logger = logging.getLogger('run_price_scraper')
    logger.info("=" * 80)
    logger.info("Starting V2 Price Scraper for Restaurant 147")
    logger.info("=" * 80)
    logger.info("V3 Restaurant ID: 147")
    logger.info("V2 Restaurant ID: 1171")
    logger.info("Language: English")
    logger.info("=" * 80)
    
    # Create scraper
    scraper = V2PriceScraper(
        restaurant_id=147,
        v2_restaurant_id=1171,
        language='en'
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
        
        if stats['errors'] == 0:
            logger.info("✓ Price update completed successfully!")
        else:
            logger.warning(f"⚠ Completed with {stats['errors']} errors")
        
    except Exception as e:
        logger.error(f"Error during scraping: {e}")
        raise
    finally:
        await scraper.cleanup()


if __name__ == '__main__':
    asyncio.run(main())
