#!/usr/bin/env python3
"""
Real-time progress monitor for Phase 2: batch_scrape_french_prices.py
Shows detailed progress, statistics, and estimated completion time.
"""

import json
import time
from pathlib import Path
from datetime import datetime, timedelta

PROGRESS_FILE = 'french_prices_progress.json'
RESULTS_FILE = 'french_prices_results.json'
LOG_FILE = 'batch_scrape_french_prices.log'

def read_progress():
    """Read current progress."""
    if not Path(PROGRESS_FILE).exists():
        return None
    
    try:
        with open(PROGRESS_FILE, 'r') as f:
            content = f.read().strip()
            if not content:
                return None
            return json.loads(content)
    except (json.JSONDecodeError, ValueError) as e:
        # File might be being written to - try reading again after a short delay
        import time
        time.sleep(0.5)
        try:
            with open(PROGRESS_FILE, 'r') as f:
                content = f.read().strip()
                if not content:
                    return None
                return json.loads(content)
        except:
            return None

def read_results():
    """Read detailed results."""
    if not Path(RESULTS_FILE).exists():
        return []
    
    try:
        with open(RESULTS_FILE, 'r') as f:
            return json.load(f)
    except:
        return []

def get_last_log_lines(n=10):
    """Get last N lines from log file."""
    if not Path(LOG_FILE).exists():
        return []
    
    try:
        with open(LOG_FILE, 'r', encoding='utf-8', errors='ignore') as f:
            lines = f.readlines()
            return lines[-n:] if len(lines) > n else lines
    except:
        return []

def estimate_completion(completed, total, start_time):
    """Estimate completion time based on current progress."""
    if completed == 0:
        return "Calculating..."
    
    elapsed = datetime.now() - start_time
    avg_time_per_dish = elapsed.total_seconds() / completed
    remaining = total - completed
    eta_seconds = avg_time_per_dish * remaining
    
    eta = datetime.now() + timedelta(seconds=eta_seconds)
    return eta.strftime('%H:%M:%S')

def display_progress():
    """Display current progress."""
    progress = read_progress()
    results = read_results()
    
    if not progress:
        print("\n[INFO] Phase 2 not started yet or progress file not created.")
        print("Waiting for scraper to start...")
        return False
    
    completed_ids = set(progress.get('completed', []))
    failed_ids = set(progress.get('failed', []))
    skipped_ids = set(progress.get('skipped', []))
    
    # Estimate total dishes (we know from test: ~3,158)
    total_dishes = 3158  # Approximate
    
    # Calculate statistics from results
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
    
    # Aggregate data from results
    for result in results:
        if result.get('success'):
            stats['total_prices'] += result.get('prices_count', 0)
            stats['total_modifier_groups'] += result.get('modifier_groups_count', 0)
            stats['total_modifier_items'] += result.get('modifier_items_count', 0)
            stats['total_modifier_prices'] += result.get('modifier_prices_count', 0)
            
            if result.get('modifier_groups_count', 0) > 0:
                stats['dishes_with_modifiers'] += 1
            else:
                stats['dishes_without_modifiers'] += 1
    
    # Progress percentage
    progress_pct = (total_processed / total_dishes * 100) if total_dishes > 0 else 0
    
    # Display
    print("\n" + "="*100)
    print("PHASE 2: FRENCH PRICES & MODIFIERS SCRAPER - PROGRESS")
    print("="*100)
    print(f"Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()
    print(f"Progress: {total_processed}/{total_dishes} dishes (~{progress_pct:.1f}%)")
    
    # Progress bar
    bar_length = 60
    filled = int(bar_length * total_processed / total_dishes) if total_dishes > 0 else 0
    bar = '=' * filled + '-' * (bar_length - filled)
    print(f"[{bar}]")
    print()
    
    print(f"Status:")
    print(f"  Completed:  {stats['completed']}")
    print(f"  Failed:     {stats['failed']}")
    print(f"  Skipped:    {stats['skipped']}")
    print(f"  Remaining:  ~{total_dishes - total_processed}")
    print()
    
    print(f"Data Inserted:")
    print(f"  Dish Prices:           {stats['total_prices']:,}")
    print(f"  Modifier Groups:       {stats['total_modifier_groups']:,}")
    print(f"  Modifier Items:        {stats['total_modifier_items']:,}")
    print(f"  Modifier Prices:       {stats['total_modifier_prices']:,}")
    print()
    
    print(f"Dish Types:")
    print(f"  With Modifiers:        {stats['dishes_with_modifiers']}")
    print(f"  Without Modifiers:     {stats['dishes_without_modifiers']}")
    print()
    
    # Show last processed dish
    if results:
        last_result = results[-1]
        print(f"Last Processed Dish:")
        print(f"  Name: {last_result.get('dish_name', 'Unknown')}")
        print(f"  Restaurant: {last_result.get('restaurant_name', 'Unknown')}")
        if last_result.get('success'):
            print(f"  Prices: {last_result.get('prices_count', 0)}, " +
                  f"Groups: {last_result.get('modifier_groups_count', 0)}, " +
                  f"Items: {last_result.get('modifier_items_count', 0)}, " +
                  f"Mod Prices: {last_result.get('modifier_prices_count', 0)}")
        else:
            print(f"  Status: {last_result.get('error', 'Unknown error')}")
    
    # Show recent log activity
    print()
    print("Recent Activity (last 5 log lines):")
    print("-" * 100)
    recent_lines = get_last_log_lines(5)
    for line in recent_lines:
        line = line.strip()
        if line:
            if len(line) > 98:
                line = line[:95] + "..."
            print(f"  {line}")
    
    print("="*100)
    
    # Check if complete
    if total_processed >= total_dishes * 0.95:  # 95% threshold
        print()
        print("[NEAR COMPLETION] Phase 2 is almost complete!")
        print()
        if stats['failed'] > 0:
            print(f"[WARNING] {stats['failed']} dish(es) failed. Check log for details.")
        print()
        print(f"SUMMARY:")
        print(f"  Total dishes processed: {total_processed}")
        print(f"  Successful: {stats['completed']}")
        print(f"  Failed: {stats['failed']}")
        print(f"  Skipped: {stats['skipped']}")
        print(f"  Total data inserted:")
        print(f"    - Prices: {stats['total_prices']:,}")
        print(f"    - Modifier Groups: {stats['total_modifier_groups']:,}")
        print(f"    - Modifier Items: {stats['total_modifier_items']:,}")
        print(f"    - Modifier Prices: {stats['total_modifier_prices']:,}")
        print("="*100)
        return True
    
    return False

def main():
    """Main monitoring loop."""
    print("\n" + "="*100)
    print("PHASE 2 PROGRESS MONITOR - FRENCH PRICES & MODIFIERS")
    print("="*100)
    print("\nMonitoring batch_scrape_french_prices.py progress...")
    print("Press Ctrl+C to stop monitoring (scraper will continue running)")
    print()
    
    try:
        while True:
            completed = display_progress()
            
            if completed:
                break
            
            # Wait before next update
            time.sleep(15)  # Update every 15 seconds
    
    except KeyboardInterrupt:
        print("\n\n[INFO] Monitoring stopped by user.")
        print("The scraper is still running in the background.")
        print("Run this script again to resume monitoring.")

if __name__ == "__main__":
    main()


