#!/usr/bin/env python3
"""
Real-time progress monitor for List 4 scrapers (Phase 1 and Phase 2).
Shows detailed progress, statistics, and estimated completion time.
"""

import json
import time
from pathlib import Path
from datetime import datetime, timedelta
import re

# Phase 1 files
PHASE1_PROGRESS_FILE = 'list4_scrape_progress.json'
PHASE1_RESULTS_FILE = 'list4_scrape_results.json'
PHASE1_LOG_FILE = 'batch_scrape_list4.log'

# Phase 2 files
PHASE2_PROGRESS_FILE = 'list4_prices_progress.json'
PHASE2_RESULTS_FILE = 'list4_prices_results.json'
PHASE2_LOG_FILE = 'batch_scrape_list4_prices.log'


def read_progress(progress_file):
    """Read current progress."""
    if not Path(progress_file).exists():
        return None
    
    try:
        with open(progress_file, 'r') as f:
            content = f.read().strip()
            if not content:
                return None
            return json.loads(content)
    except (json.JSONDecodeError, ValueError) as e:
        # File might be being written to - try reading again after a short delay
        import time
        time.sleep(0.5)
        try:
            with open(progress_file, 'r') as f:
                content = f.read().strip()
                if not content:
                    return None
                return json.loads(content)
        except:
            return None


def read_results(results_file):
    """Read detailed results."""
    if not Path(results_file).exists():
        return []
    
    try:
        with open(results_file, 'r') as f:
            return json.load(f)
    except:
        return []


def get_last_log_lines(log_file, n=5):
    """Get last N lines from log file."""
    if not Path(log_file).exists():
        return []
    
    try:
        with open(log_file, 'r', encoding='utf-8', errors='ignore') as f:
            lines = f.readlines()
            return lines[-n:] if len(lines) > n else lines
    except:
        return []


def display_phase1_progress():
    """Display Phase 1 progress (courses and dishes)."""
    progress = read_progress(PHASE1_PROGRESS_FILE)
    results = read_results(PHASE1_RESULTS_FILE)
    
    if not progress:
        print("\n[INFO] Phase 1 not started yet or progress file not created.")
        return False
    
    completed_ids = set(progress.get('completed', []))
    failed_ids = set(progress.get('failed', []))
    skipped_ids = set(progress.get('skipped', []))
    
    total_restaurants = 50  # From extraction script
    total_processed = len(completed_ids) + len(failed_ids) + len(skipped_ids)
    
    stats = {
        'completed': len(completed_ids),
        'failed': len(failed_ids),
        'skipped': len(skipped_ids),
        'total_courses': 0,
        'total_dishes': 0
    }
    
    for result in results:
        if result.get('status') == 'success':
            stats['total_courses'] += result.get('courses', 0)
            stats['total_dishes'] += result.get('dishes', 0)
    
    progress_pct = (total_processed / total_restaurants * 100) if total_restaurants > 0 else 0
    
    print("\n" + "="*100)
    print("LIST 4 SCRAPER - PHASE 1 (Courses & Dishes)")
    print("="*100)
    print(f"Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()
    print(f"Progress: {total_processed}/{total_restaurants} restaurants (~{progress_pct:.1f}%)")
    
    bar_length = 60
    filled = int(bar_length * total_processed / total_restaurants) if total_restaurants > 0 else 0
    bar = '=' * filled + '-' * (bar_length - filled)
    print(f"[{bar}]")
    print()
    
    print(f"Status:")
    print(f"  Completed:  {stats['completed']:,}")
    print(f"  Failed:     {stats['failed']:,}")
    print(f"  Skipped:    {stats['skipped']:,}")
    print(f"  Remaining:  ~{(total_restaurants - total_processed):,}")
    print()
    
    print(f"Data Inserted:")
    print(f"  Courses:               {stats['total_courses']:,}")
    print(f"  Dishes:                {stats['total_dishes']:,}")
    print()
    
    if results:
        last_result = results[-1]
        print(f"Last Processed Restaurant:")
        print(f"  Name: {last_result.get('name', 'Unknown')}")
        print(f"  Status: {last_result.get('status', 'Unknown')}")
        if last_result.get('status') == 'success':
            print(f"  Courses: {last_result.get('courses', 0)}, Dishes: {last_result.get('dishes', 0)}")
        elif last_result.get('status') == 'error':
            print(f"  Error: {last_result.get('error', 'Unknown error')}")
    
    print()
    print("Recent Activity (last 5 log lines):")
    print("-" * 100)
    recent_lines = get_last_log_lines(PHASE1_LOG_FILE, 5)
    for line in recent_lines:
        line = line.strip()
        if line:
            if len(line) > 98:
                line = line[:95] + "..."
            print(f"  {line}")
    
    print("="*100)
    
    if total_processed >= total_restaurants:
        print()
        print("[COMPLETED] Phase 1 has finished!")
        return True
    
    return False


def display_phase2_progress():
    """Display Phase 2 progress (prices and modifiers)."""
    progress = read_progress(PHASE2_PROGRESS_FILE)
    results = read_results(PHASE2_RESULTS_FILE)
    
    if not progress:
        print("\n[INFO] Phase 2 not started yet or progress file not created.")
        return False
    
    completed_ids = set(progress.get('completed', []))
    failed_ids = set(progress.get('failed', []))
    skipped_ids = set(progress.get('skipped', []))
    
    # Try to get total dishes from Phase 1 results
    phase1_results = read_results(PHASE1_RESULTS_FILE)
    total_dishes = sum(r.get('dishes', 0) for r in phase1_results if r.get('status') == 'success')
    
    total_processed = len(completed_ids) + len(failed_ids) + len(skipped_ids)
    
    stats = {
        'completed': len(completed_ids),
        'failed': len(failed_ids),
        'skipped': len(skipped_ids),
        'total_prices': 0,
        'total_modifier_groups': 0,
        'total_modifier_items': 0,
        'total_modifier_prices': 0,
        'dishes_with_modifiers': 0,
        'dishes_without_modifiers': 0
    }
    
    for result in results:
        if result.get('status') == 'success':
            stats['total_prices'] += result.get('prices_count', 0)
            stats['total_modifier_groups'] += result.get('modifier_groups_count', 0)
            stats['total_modifier_items'] += result.get('modifier_items_count', 0)
            stats['total_modifier_prices'] += result.get('modifier_prices_count', 0)
            
            if result.get('modifier_groups_count', 0) > 0:
                stats['dishes_with_modifiers'] += 1
            else:
                stats['dishes_without_modifiers'] += 1
    
    progress_pct = (total_processed / total_dishes * 100) if total_dishes > 0 else 0
    
    print("\n" + "="*100)
    print("LIST 4 SCRAPER - PHASE 2 (Prices & Modifiers)")
    print("="*100)
    print(f"Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()
    print(f"Progress: {total_processed}/{total_dishes} dishes (~{progress_pct:.1f}%)")
    
    bar_length = 60
    filled = int(bar_length * total_processed / total_dishes) if total_dishes > 0 else 0
    bar = '=' * filled + '-' * (bar_length - filled)
    print(f"[{bar}]")
    print()
    
    print(f"Status:")
    print(f"  Completed:  {stats['completed']:,}")
    print(f"  Failed:     {stats['failed']:,}")
    print(f"  Skipped:    {stats['skipped']:,}")
    print(f"  Remaining:  ~{(total_dishes - total_processed):,}")
    print()
    
    print(f"Data Inserted:")
    print(f"  Dish Prices:           {stats['total_prices']:,}")
    print(f"  Modifier Groups:       {stats['total_modifier_groups']:,}")
    print(f"  Modifier Items:        {stats['total_modifier_items']:,}")
    print(f"  Modifier Prices:       {stats['total_modifier_prices']:,}")
    print()
    
    print(f"Dish Types:")
    print(f"  With Modifiers:        {stats['dishes_with_modifiers']:,}")
    print(f"  Without Modifiers:     {stats['dishes_without_modifiers']:,}")
    print()
    
    if results:
        last_result = results[-1]
        print(f"Last Processed Dish:")
        print(f"  Name: {last_result.get('dish_name', 'Unknown')}")
        print(f"  Restaurant: {last_result.get('restaurant_name', 'Unknown')}")
        if last_result.get('status') == 'success':
            print(f"  Prices: {last_result.get('prices_count', 0)}, " +
                  f"Groups: {last_result.get('modifier_groups_count', 0)}, " +
                  f"Items: {last_result.get('modifier_items_count', 0)}, " +
                  f"Mod Prices: {last_result.get('modifier_prices_count', 0)}")
        else:
            print(f"  Status: {last_result.get('error', 'Unknown error')}")
    
    print()
    print("Recent Activity (last 5 log lines):")
    print("-" * 100)
    recent_lines = get_last_log_lines(PHASE2_LOG_FILE, 5)
    for line in recent_lines:
        line = line.strip()
        if line:
            if len(line) > 98:
                line = line[:95] + "..."
            print(f"  {line}")
    
    print("="*100)
    
    if total_processed >= total_dishes:
        print()
        print("[COMPLETED] Phase 2 has finished!")
        return True
    
    return False


def main():
    """Main monitoring loop."""
    print("\n" + "="*100)
    print("LIST 4 SCRAPER PROGRESS MONITOR")
    print("="*100)
    print("\nMonitoring List 4 scraper progress...")
    print("Press Ctrl+C to stop monitoring (scraper will continue running)")
    print()
    
    try:
        while True:
            # Check Phase 1
            phase1_complete = display_phase1_progress()
            
            # If Phase 1 is complete, check Phase 2
            if phase1_complete or Path(PHASE2_PROGRESS_FILE).exists():
                print()  # Add spacing
                phase2_complete = display_phase2_progress()
                
                if phase2_complete:
                    break
            
            time.sleep(15)
    
    except KeyboardInterrupt:
        print("\n\n[INFO] Monitoring stopped by user.")
        print("The scraper is still running in the background.")
        print("Run this script again to resume monitoring.")


if __name__ == "__main__":
    main()



