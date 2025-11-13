"""
Continuous Monitoring and Validation Script
Checks batch_scrape.log every 10 minutes for new entries and validates them
"""

import time
import json
import os
from datetime import datetime
from validate_scrape_data import ScraperDataValidator
import logging

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('validation_monitor.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# State file to track last validated restaurant
STATE_FILE = 'validation_state.json'
LOG_FILE = 'batch_scrape.log'
CHECK_INTERVAL = 600  # 10 minutes in seconds

class ValidationMonitor:
    def __init__(self):
        self.state = self.load_state()
        self.validator = ScraperDataValidator()

    def load_state(self):
        """Load the last validation state."""
        if os.path.exists(STATE_FILE):
            try:
                with open(STATE_FILE, 'r') as f:
                    return json.load(f)
            except Exception as e:
                logger.warning(f"Could not load state file: {e}")

        # Default state
        return {
            'last_validated_sequence': 0,
            'last_validated_name': None,
            'last_validated_db_id': None,
            'total_validated': 0,
            'last_check_time': None
        }

    def save_state(self, sequence, name, db_id, total_validated):
        """Save the current validation state."""
        self.state = {
            'last_validated_sequence': sequence,
            'last_validated_name': name,
            'last_validated_db_id': db_id,
            'total_validated': total_validated,
            'last_check_time': datetime.now().isoformat()
        }

        try:
            with open(STATE_FILE, 'w') as f:
                json.dump(self.state, f, indent=2)
            logger.info(f"State saved: Last validated #{sequence} - {name}")
        except Exception as e:
            logger.error(f"Could not save state: {e}")

    def get_new_entries(self):
        """Parse log file and return only new entries since last validation."""
        try:
            # Get all successful scrapes from log
            all_scrapes = self.validator.parse_log_file(LOG_FILE)

            # Filter to only new entries
            last_sequence = self.state['last_validated_sequence']
            new_scrapes = [s for s in all_scrapes if s['sequence'] > last_sequence]

            return new_scrapes
        except Exception as e:
            logger.error(f"Error parsing log file: {e}")
            return []

    def validate_new_entries(self):
        """Validate any new entries found in the log."""
        logger.info("=" * 80)
        logger.info(f"Checking for new entries at {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        logger.info("=" * 80)

        # Check for new entries
        new_scrapes = self.get_new_entries()

        if not new_scrapes:
            last_validated = self.state.get('last_validated_name', 'None')
            logger.info(f"No new entries found. Last validated: {last_validated}")
            return True

        logger.info(f"Found {len(new_scrapes)} new restaurants to validate")
        logger.info("")

        # Connect to database
        try:
            self.validator.db.connect()
        except Exception as e:
            logger.error(f"Failed to connect to database: {e}")
            return False

        # Validate each new entry
        validation_passed = 0
        validation_failed = 0
        validation_mismatched = 0

        for i, scrape in enumerate(new_scrapes, 1):
            is_valid, message = self.validator.verify_restaurant_data(scrape)

            log_line = f"[{scrape['sequence']}/165] {scrape['name']} (DB:{scrape['db_id']}, CRM:{scrape['crm_id']})"

            if is_valid:
                logger.info(f"✅ {log_line}: {message}")
                validation_passed += 1
            elif "MISMATCH" in message:
                logger.warning(f"⚠️  {log_line}: {message}")
                validation_mismatched += 1
            else:
                logger.error(f"❌ {log_line}: {message}")
                validation_failed += 1

                # STOP on critical error
                logger.error("\n" + "!" * 80)
                logger.error("CRITICAL ERROR DETECTED - STOPPING MONITORING")
                logger.error("!" * 80)
                logger.error(f"\nRestaurant: {scrape['name']} (DB ID: {scrape['db_id']})")
                logger.error(f"Expected: {scrape['courses_success']} courses, {scrape['dishes_success']} dishes")
                logger.error(f"Issue: {message}")
                logger.error("\nPlease investigate this issue before continuing.")

                self.validator.db.close()
                return False

            # Save state after each successful validation
            if is_valid or "MISMATCH" in message:
                total_validated = self.state['total_validated'] + i
                self.save_state(
                    scrape['sequence'],
                    scrape['name'],
                    scrape['db_id'],
                    total_validated
                )

        # Summary
        logger.info("\n" + "-" * 80)
        logger.info("VALIDATION SUMMARY FOR THIS BATCH")
        logger.info("-" * 80)
        logger.info(f"New restaurants validated: {len(new_scrapes)}")
        logger.info(f"✅ Passed: {validation_passed}")
        logger.info(f"⚠️  Mismatched: {validation_mismatched}")
        logger.info(f"❌ Failed: {validation_failed}")
        logger.info(f"Total validated so far: {self.state['total_validated']}")
        logger.info("-" * 80)

        # Disconnect
        self.validator.db.close()

        return validation_failed == 0

    def run_continuous(self):
        """Run continuous monitoring every 10 minutes."""
        logger.info("=" * 80)
        logger.info("STARTING CONTINUOUS VALIDATION MONITOR")
        logger.info("=" * 80)
        logger.info(f"Check interval: {CHECK_INTERVAL} seconds (10 minutes)")
        logger.info(f"Log file: {LOG_FILE}")
        logger.info(f"State file: {STATE_FILE}")

        if self.state['last_validated_name']:
            logger.info(f"Resuming from: #{self.state['last_validated_sequence']} - {self.state['last_validated_name']}")
        else:
            logger.info("Starting fresh validation")

        logger.info("=" * 80)
        logger.info("")

        try:
            while True:
                # Run validation
                success = self.validate_new_entries()

                if not success:
                    logger.error("Validation failed with critical error. Stopping monitor.")
                    break

                # Wait for next check
                logger.info(f"\nNext check in {CHECK_INTERVAL} seconds (10 minutes)...")
                logger.info(f"Press Ctrl+C to stop monitoring\n")
                time.sleep(CHECK_INTERVAL)

        except KeyboardInterrupt:
            logger.info("\n\nMonitoring stopped by user (Ctrl+C)")
            logger.info(f"Last validated: #{self.state['last_validated_sequence']} - {self.state['last_validated_name']}")
            logger.info("State has been saved. You can resume monitoring later.")
        except Exception as e:
            logger.error(f"Unexpected error: {e}")
            raise

if __name__ == "__main__":
    monitor = ValidationMonitor()

    # Check if user wants to run once or continuously
    import sys

    if len(sys.argv) > 1 and sys.argv[1] == '--once':
        # Run validation once
        logger.info("Running single validation check...")
        success = monitor.validate_new_entries()
        exit(0 if success else 1)
    else:
        # Run continuous monitoring
        monitor.run_continuous()
