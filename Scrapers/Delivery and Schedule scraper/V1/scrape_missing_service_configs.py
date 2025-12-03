"""
Scraper for V1 restaurants missing service configs.

This script scrapes service config data for 8 V1 restaurants that have
delivery areas but no service configs, then inserts the records.

Target restaurants:
- 1010: Lemongrass Thai Cuisine (V1: 219)
- 1012: Papa Pizza Des Flandres (V1: 231)
- 1013: Papa Pizza Maloney (V1: 346)
- 1014: Papa Pizza Val-Des-Monts (V1: 703)
- 1015: Poutinerie Québecurds Gatineau (V1: 1046)
- 1016: Roulas Grecque et Pizza (V1: 173)
- 1017: Sushi Express Chambly (V1: 511)

Note: Restaurant 1009 (Econo Pizza) is in MVP_EXCLUDED list.
Note: Restaurant 1020 (Sushi Presse) has no V1 ID - manual entry required.
"""
import logging
import json
import sys
from pathlib import Path
from datetime import datetime
from dataclasses import dataclass, asdict
from typing import Optional, List

# Add parent to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent))

from V1.scraper import V1DeliveryScheduleScraper
from V1.config import OUTPUT_DIR, LOG_DIR

# Setup logging
log_file = LOG_DIR / f"missing_service_configs_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log"
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(log_file, encoding='utf-8'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# Restaurants to scrape (V3 ID, V1 ID, Name)
RESTAURANTS_TO_SCRAPE = [
    (1010, 219, "Lemongrass Thai Cuisine"),
    (1012, 231, "Papa Pizza Des Flandres"),
    (1013, 346, "Papa Pizza Maloney"),
    (1014, 703, "Papa Pizza Val-Des-Monts"),
    (1015, 1046, "Poutinerie Québecurds Gatineau"),
    (1016, 173, "Roulas Grecque et Pizza"),
    (1017, 511, "Sushi Express Chambly"),
]

# Default values for service config columns
DEFAULTS = {
    'allows_preorders': False,
    'is_bilingual': False,
    'default_language': 'en',
    'accepts_tips': True,
    'requires_phone': True,
}

@dataclass
class ServiceConfigData:
    """Data scraped for service config creation."""
    v3_id: int
    v1_id: int
    name: str
    # Scraped values
    takeout_time_minutes: Optional[int] = None
    has_delivery_enabled: Optional[bool] = None
    pickup_enabled: Optional[bool] = None
    closing_warning_minutes: Optional[int] = None
    # Status
    scrape_success: bool = False
    error_message: Optional[str] = None


def scrape_restaurants() -> List[ServiceConfigData]:
    """Scrape service config data from V1 CRM for target restaurants."""
    results = []
    
    with V1DeliveryScheduleScraper(headless=True) as scraper:
        if not scraper.login():
            logger.error("Failed to login to V1 CRM")
            return results
        
        for v3_id, v1_id, name in RESTAURANTS_TO_SCRAPE:
            logger.info(f"\n{'='*60}")
            logger.info(f"Scraping: {name} (V3: {v3_id}, V1: {v1_id})")
            logger.info('='*60)
            
            # Use existing scraper method
            restaurant_data = scraper.scrape_restaurant(v3_id, v1_id, name)
            
            # Convert to ServiceConfigData
            config_data = ServiceConfigData(
                v3_id=v3_id,
                v1_id=v1_id,
                name=name,
                takeout_time_minutes=restaurant_data.takeout_time_minutes,
                has_delivery_enabled=restaurant_data.has_delivery_enabled,
                pickup_enabled=restaurant_data.pickup_enabled,
                closing_warning_minutes=restaurant_data.closing_warning_minutes,
                scrape_success=restaurant_data.scrape_success,
                error_message=restaurant_data.error_message
            )
            
            results.append(config_data)
            
            if config_data.scrape_success:
                logger.info(f"  ✓ takeout_time: {config_data.takeout_time_minutes}")
                logger.info(f"  ✓ has_delivery_enabled: {config_data.has_delivery_enabled}")
                logger.info(f"  ✓ pickup_enabled: {config_data.pickup_enabled}")
                logger.info(f"  ✓ closing_warning_minutes: {config_data.closing_warning_minutes}")
            else:
                logger.error(f"  ✗ Failed: {config_data.error_message}")
    
    return results


def save_results(results: List[ServiceConfigData], filename: str):
    """Save scraped results to JSON file."""
    output_file = OUTPUT_DIR / filename
    data = [asdict(r) for r in results]
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    logger.info(f"Results saved to: {output_file}")


def insert_service_configs(results: List[ServiceConfigData], dry_run: bool = False):
    """Insert service config records for successfully scraped restaurants."""
    import psycopg2
    from psycopg2.extras import RealDictCursor
    
    # Database connection
    conn_string = 'postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres'
    
    successful = [r for r in results if r.scrape_success]
    
    if not successful:
        logger.warning("No successful scrapes to insert")
        return
    
    logger.info(f"\n{'='*60}")
    logger.info(f"Inserting {len(successful)} service configs")
    logger.info('='*60)
    
    if dry_run:
        logger.info("DRY RUN - No database changes will be made")
        for r in successful:
            logger.info(f"  Would insert: {r.name} (V3: {r.v3_id})")
            logger.info(f"    takeout_time_minutes: {r.takeout_time_minutes}")
            logger.info(f"    has_delivery_enabled: {r.has_delivery_enabled}")
            logger.info(f"    pickup_enabled: {r.pickup_enabled}")
            logger.info(f"    closing_warning_minutes: {r.closing_warning_minutes}")
        return
    
    try:
        conn = psycopg2.connect(conn_string)
        cursor = conn.cursor(cursor_factory=RealDictCursor)
        
        insert_query = """
            INSERT INTO menuca_v3.restaurant_service_configs (
                restaurant_id,
                has_delivery_enabled,
                pickup_enabled,
                takeout_time_minutes,
                closing_warning_minutes,
                allows_preorders,
                is_bilingual,
                default_language,
                accepts_tips,
                requires_phone,
                created_at
            ) VALUES (
                %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, NOW()
            )
            RETURNING id, restaurant_id;
        """
        
        inserted = 0
        for r in successful:
            try:
                # Use scraped values, with fallbacks
                has_delivery = r.has_delivery_enabled if r.has_delivery_enabled is not None else True
                pickup = r.pickup_enabled if r.pickup_enabled is not None else True
                
                cursor.execute(insert_query, (
                    r.v3_id,
                    has_delivery,
                    pickup,
                    r.takeout_time_minutes,
                    r.closing_warning_minutes,
                    DEFAULTS['allows_preorders'],
                    DEFAULTS['is_bilingual'],
                    DEFAULTS['default_language'],
                    DEFAULTS['accepts_tips'],
                    DEFAULTS['requires_phone'],
                ))
                
                result = cursor.fetchone()
                conn.commit()
                
                logger.info(f"  ✓ Inserted: {r.name} (ID: {result['id']})")
                inserted += 1
                
            except psycopg2.errors.UniqueViolation:
                conn.rollback()
                logger.warning(f"  ⚠ Already exists: {r.name}")
            except Exception as e:
                conn.rollback()
                logger.error(f"  ✗ Failed to insert {r.name}: {e}")
        
        cursor.close()
        conn.close()
        
        logger.info(f"\nInserted {inserted}/{len(successful)} service configs")
        
    except Exception as e:
        logger.error(f"Database error: {e}")


def main():
    """Main entry point."""
    import argparse
    
    parser = argparse.ArgumentParser(description="Scrape V1 restaurants missing service configs")
    parser.add_argument('--dry-run', action='store_true', help="Don't insert into database")
    parser.add_argument('--scrape-only', action='store_true', help="Only scrape, don't insert")
    args = parser.parse_args()
    
    logger.info("="*60)
    logger.info("V1 Missing Service Configs Scraper")
    logger.info("="*60)
    logger.info(f"Target restaurants: {len(RESTAURANTS_TO_SCRAPE)}")
    logger.info(f"Log file: {log_file}")
    
    # Scrape data
    results = scrape_restaurants()
    
    # Save results
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    save_results(results, f"missing_service_configs_{timestamp}.json")
    save_results(results, "missing_service_configs_latest.json")
    
    # Summary
    successful = sum(1 for r in results if r.scrape_success)
    failed = len(results) - successful
    
    logger.info(f"\n{'='*60}")
    logger.info("SCRAPE SUMMARY")
    logger.info('='*60)
    logger.info(f"Total: {len(results)}")
    logger.info(f"Successful: {successful}")
    logger.info(f"Failed: {failed}")
    
    if failed > 0:
        logger.info("\nFailed restaurants:")
        for r in results:
            if not r.scrape_success:
                logger.info(f"  - {r.name}: {r.error_message}")
    
    # Insert into database
    if not args.scrape_only:
        insert_service_configs(results, dry_run=args.dry_run)
    
    logger.info("\nDone!")


if __name__ == "__main__":
    main()

