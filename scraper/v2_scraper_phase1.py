#!/usr/bin/env python3
"""
V2 Restaurant Scraper - Phase 1: Courses & Dishes
HYBRID APPROACH: Scrapes to JSON files, NO database operations
"""
import sys
import os
import json
import logging
import time
from datetime import datetime
from pathlib import Path

# Add current directory to path for imports
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from v2_config import (
    V2_BASE_URL, V2_USERNAME, V2_PASSWORD, SCRAPE_DELAY,
    RESTAURANTS_FILE, PHASE1_OUTPUT_DIR, PHASE1_PROGRESS_FILE
)
from v2_scraper import V2MenuScraper

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('V2 Scrapper/v2_scraper_phase1.log', encoding='utf-8'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

def safe_print(text):
    """Print with Unicode error handling."""
    try:
        print(text)
    except UnicodeEncodeError:
        print(text.encode('ascii', 'ignore').decode('ascii'))

def load_progress():
    """Load scraping progress from file."""
    progress_file = Path(PHASE1_PROGRESS_FILE)
    if progress_file.exists():
        with open(progress_file, 'r', encoding='utf-8') as f:
            return json.load(f)
    return {'completed': [], 'failed': [], 'skipped': []}

def save_progress(progress):
    """Save scraping progress to file."""
    with open(PHASE1_PROGRESS_FILE, 'w', encoding='utf-8') as f:
        json.dump(progress, f, indent=2)

def load_restaurants():
    """Load V2 restaurants from JSON file."""
    with open(RESTAURANTS_FILE, 'r', encoding='utf-8') as f:
        content = f.read().strip()
        # Handle both array format and newline-separated format
        if content.startswith('['):
            restaurants = json.loads(content)
        else:
            # Multiple JSON objects on separate lines
            restaurants = []
            for line in content.split('\n'):
                if line.strip():
                    restaurants.extend(json.loads(line))
        return restaurants

def save_restaurant_menu(menu_data: dict, restaurant_id: int):
    """Save restaurant menu data to JSON file."""
    output_file = Path(PHASE1_OUTPUT_DIR) / f"restaurant_{restaurant_id}_menu.json"
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(menu_data, f, indent=2, ensure_ascii=False)
    logger.debug(f"Saved menu data to {output_file}")

def main():
    start_time = datetime.now()
    
    logger.info("=" * 80)
    logger.info("V2 RESTAURANT SCRAPER - PHASE 1 (Courses & Dishes)")
    logger.info("HYBRID APPROACH: Outputs to JSON, NO database operations")
    logger.info("=" * 80)
    
    # Check credentials
    if not V2_USERNAME or not V2_PASSWORD:
        logger.error("✗ V2 credentials not configured!")
        logger.error("Please set V2_USERNAME and V2_PASSWORD in .env file")
        return 1
    
    # Load V2 restaurants
    try:
        v2_restaurants = load_restaurants()
        logger.info(f"✓ Loaded {len(v2_restaurants)} V2 restaurants from {RESTAURANTS_FILE}")
    except Exception as e:
        logger.error(f"✗ Failed to load restaurants: {e}")
        return 1
    
    # Load progress
    progress = load_progress()
    completed = set(progress.get('completed', []))
    failed = set(progress.get('failed', []))
    skipped = set(progress.get('skipped', []))
    
    # Filter to process
    to_process = [r for r in v2_restaurants if r['id'] not in completed]
    logger.info(f"✓ Already completed: {len(completed)}")
    logger.info(f"✓ Remaining to process: {len(to_process)}")
    
    if not to_process:
        logger.info("✓ All restaurants already processed!")
        return 0
    
    # Initialize scraper
    logger.info(f"Initializing V2 scraper for {V2_BASE_URL}")
    scraper = V2MenuScraper(V2_BASE_URL, V2_USERNAME, V2_PASSWORD, headless=True)
    scraper.start()
    
    # Login
    if not scraper.login():
        logger.error("✗ Failed to login. Exiting.")
        scraper.stop()
        return 1
    
    # Track statistics
    total_courses = 0
    total_dishes = 0
    successful = 0
    
    try:
        for idx, restaurant in enumerate(to_process, 1):
            db_id = restaurant['id']
            v2_id = restaurant.get('v2_id')
            name = restaurant['name']
            
            # Skip if V2 ID not discovered yet
            if not v2_id:
                logger.warning(f"⚠ Skipping {name}: V2 ID not found")
                logger.warning("  Run v2_discover_ids.py first to discover V2 IDs")
                skipped.add(db_id)
                progress['skipped'] = list(skipped)
                save_progress(progress)
                continue
            
            logger.info("")
            logger.info("=" * 80)
            logger.info(f"[{idx}/{len(to_process)}] Processing: {name}")
            logger.info(f"  DB ID: {db_id} | V2 ID: {v2_id}")
            logger.info("=" * 80)
            
            try:
                # Scrape menu
                menu_data = scraper.scrape_restaurant_menu(v2_id, db_id)
                
                if not menu_data or not menu_data.get('courses'):
                    logger.warning(f"✗ No menu data for {name}")
                    skipped.add(db_id)
                    progress['skipped'] = list(skipped)
                    save_progress(progress)
                    continue
                
                # Count items
                courses_count = len(menu_data['courses'])
                dishes_count = sum(len(course['dishes']) for course in menu_data['courses'])
                total_courses += courses_count
                total_dishes += dishes_count
                
                # Save to JSON file
                save_restaurant_menu(menu_data, db_id)
                
                logger.info(f"✓ SUCCESS: {courses_count} courses, {dishes_count} dishes extracted")
                logger.info(f"✓ Saved to: {PHASE1_OUTPUT_DIR}/restaurant_{db_id}_menu.json")
                successful += 1
                
                # Mark completed
                completed.add(db_id)
                progress['completed'] = list(completed)
                save_progress(progress)
                
                # Delay between restaurants
                if idx < len(to_process):  # Don't delay after last restaurant
                    logger.debug(f"Waiting {SCRAPE_DELAY} seconds before next restaurant...")
                    time.sleep(SCRAPE_DELAY)
                
            except Exception as e:
                logger.error(f"✗ FAILED: {e}")
                import traceback
                traceback.print_exc()
                failed.add(db_id)
                progress['failed'] = list(failed)
                save_progress(progress)
    
    finally:
        scraper.stop()
    
    # Summary
    duration = datetime.now() - start_time
    logger.info("")
    logger.info("=" * 80)
    logger.info("PHASE 1 SUMMARY")
    logger.info("=" * 80)
    logger.info(f"Duration:         {duration}")
    logger.info(f"Successful:       {successful}/{len(to_process)}")
    logger.info(f"Failed:           {len(failed)}")
    logger.info(f"Skipped:          {len(skipped)}")
    logger.info(f"Total courses:    {total_courses}")
    logger.info(f"Total dishes:     {total_dishes}")
    logger.info(f"Output directory: {PHASE1_OUTPUT_DIR}/")
    logger.info(f"Progress file:    {PHASE1_PROGRESS_FILE}")
    logger.info("=" * 80)
    
    # Next steps
    logger.info("")
    logger.info("NEXT STEPS:")
    logger.info("1. Review the JSON files in the output directory")
    logger.info("2. Run the SQL import scripts to load data into menuca_v3")
    logger.info("3. Run verification queries to check data integrity")
    logger.info("")
    
    return 0

if __name__ == "__main__":
    sys.exit(main())

