"""
Validate Scraper Data Against Database
Verifies that scraped data from batch_scrape.log exists in menuca_v3 schema
"""

import re
import psycopg2
from database import DatabaseManager
import logging
from typing import List, Dict, Tuple

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

class ScraperDataValidator:
    def __init__(self):
        self.db = DatabaseManager()
        self.validation_errors = []
        self.validation_warnings = []

    def parse_log_file(self, log_file_path: str) -> List[Dict]:
        """Parse batch_scrape.log and extract ONLY successful scrapes (skip ERROR entries)."""
        successful_scrapes = []

        with open(log_file_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()

        i = 0
        while i < len(lines):
            line = lines[i]

            # Look for processing line: [X/165] Processing: Restaurant Name
            processing_match = re.match(r'\[(\d+)/\d+\] Processing: (.+)', line)
            if processing_match:
                sequence = int(processing_match.group(1))
                name = processing_match.group(2).strip()

                # Look ahead for the scraping info and result
                db_id = None
                crm_id = None
                courses = None
                dishes = None
                has_error = False
                has_success = False

                # Check next ~10 lines for this restaurant's data
                for j in range(i+1, min(i+15, len(lines))):
                    check_line = lines[j]

                    # Check for ERROR flag - skip this restaurant if found
                    if 'ERROR' in check_line and (name in check_line or str(crm_id) in check_line if crm_id else False):
                        has_error = True
                        break

                    # Extract DB and CRM IDs
                    scraping_match = re.search(r'Scraping: .+? \(DB:(\d+), CRM:(\d+)\)', check_line)
                    if scraping_match:
                        db_id = int(scraping_match.group(1))
                        crm_id = int(scraping_match.group(2))

                    # Extract success line
                    success_match = re.search(r'Success: (\d+) courses, (\d+) dishes', check_line)
                    if success_match:
                        courses = int(success_match.group(1))
                        dishes = int(success_match.group(2))
                        has_success = True
                        break

                # Only add if we found success and NO errors
                if has_success and not has_error and db_id and crm_id and courses is not None and dishes is not None:
                    scrape_data = {
                        'sequence': sequence,
                        'name': name,
                        'db_id': db_id,
                        'crm_id': crm_id,
                        'courses_found': courses,
                        'dishes_found': dishes,
                        'courses_success': courses,
                        'dishes_success': dishes
                    }
                    successful_scrapes.append(scrape_data)

            i += 1

        logger.info(f"Parsed {len(successful_scrapes)} successful scrapes from log file (skipped ERROR entries)")
        return successful_scrapes

    def verify_restaurant_data(self, scrape_data: Dict) -> Tuple[bool, str]:
        """Verify that scraped data exists in database for a single restaurant."""
        restaurant_id = scrape_data['db_id']
        expected_courses = scrape_data['courses_success']
        expected_dishes = scrape_data['dishes_success']

        try:
            # Use existing database methods
            actual_courses = self.db.get_course_count(restaurant_id)
            actual_dishes = self.db.get_dish_count(restaurant_id)

            # Validate
            if actual_courses == 0 and actual_dishes == 0:
                return False, f"❌ CRITICAL: No data found in database (Expected: {expected_courses} courses, {expected_dishes} dishes)"

            if actual_courses != expected_courses or actual_dishes != expected_dishes:
                return False, f"⚠️  MISMATCH: Expected {expected_courses} courses/{expected_dishes} dishes, Found {actual_courses} courses/{actual_dishes} dishes"

            return True, f"✅ VERIFIED: {actual_courses} courses, {actual_dishes} dishes"

        except Exception as e:
            return False, f"❌ ERROR: Database query failed - {str(e)}"

    def validate_all(self, log_file_path: str):
        """Validate all successful scrapes from log file."""
        logger.info("=" * 80)
        logger.info("SCRAPER DATA VALIDATION")
        logger.info("=" * 80)

        # Connect to database
        try:
            self.db.connect()
        except Exception as e:
            logger.error(f"Failed to connect to database: {e}")
            return False

        # Parse log file
        successful_scrapes = self.parse_log_file(log_file_path)

        if not successful_scrapes:
            logger.warning("No successful scrapes found in log file")
            return

        logger.info(f"\nValidating {len(successful_scrapes)} restaurants...\n")

        # Validate each restaurant
        validation_passed = 0
        validation_failed = 0
        validation_mismatched = 0

        for i, scrape in enumerate(successful_scrapes, 1):
            is_valid, message = self.verify_restaurant_data(scrape)

            log_line = f"[{i}/{len(successful_scrapes)}] {scrape['name']} (DB:{scrape['db_id']}, CRM:{scrape['crm_id']})"

            if is_valid:
                logger.info(f"{log_line}: {message}")
                validation_passed += 1
            elif "MISMATCH" in message:
                logger.warning(f"{log_line}: {message}")
                validation_mismatched += 1
                self.validation_warnings.append({
                    'restaurant': scrape['name'],
                    'db_id': scrape['db_id'],
                    'message': message
                })
            else:
                logger.error(f"{log_line}: {message}")
                validation_failed += 1
                self.validation_errors.append({
                    'restaurant': scrape['name'],
                    'db_id': scrape['db_id'],
                    'message': message
                })

                # STOP on critical error
                logger.error("\n" + "!" * 80)
                logger.error("CRITICAL ERROR DETECTED - STOPPING VALIDATION")
                logger.error("!" * 80)
                logger.error(f"\nRestaurant: {scrape['name']} (DB ID: {scrape['db_id']})")
                logger.error(f"Expected: {scrape['courses_success']} courses, {scrape['dishes_success']} dishes")
                logger.error(f"Issue: {message}")
                logger.error("\nPlease investigate this issue before continuing.")
                break

        # Summary
        logger.info("\n" + "=" * 80)
        logger.info("VALIDATION SUMMARY")
        logger.info("=" * 80)
        logger.info(f"Total Validated: {validation_passed + validation_failed + validation_mismatched}")
        logger.info(f"✅ Passed: {validation_passed}")
        logger.info(f"⚠️  Mismatched: {validation_mismatched}")
        logger.info(f"❌ Failed: {validation_failed}")

        if validation_failed > 0:
            logger.error("\n⚠️  VALIDATION FAILED - Critical errors detected")
            logger.error("Review errors above before proceeding")
            return False

        if validation_mismatched > 0:
            logger.warning("\n⚠️  Some data mismatches detected")
            logger.warning("Review warnings above")

        if validation_failed == 0 and validation_mismatched == 0:
            logger.info("\n✅ ALL VALIDATIONS PASSED")
            logger.info("Scraped data matches database records")

        # Disconnect
        self.db.close()

        return validation_failed == 0

if __name__ == "__main__":
    validator = ScraperDataValidator()
    log_file = "batch_scrape.log"

    success = validator.validate_all(log_file)

    if not success:
        exit(1)

    exit(0)
