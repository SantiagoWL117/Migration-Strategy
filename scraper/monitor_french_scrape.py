#!/usr/bin/env python3
"""
Real-time progress monitor for batch_scrape_french.py
Shows current status, progress, and estimated completion time.
"""

import json
import time
from pathlib import Path
from datetime import datetime, timedelta

PROGRESS_FILE = 'french_scrape_progress.json'
RESULTS_FILE = 'french_scrape_results.json'
LOG_FILE = 'batch_scrape_french.log'

def read_progress():
    """Read current progress."""
    if not Path(PROGRESS_FILE).exists():
        return None
    
    with open(PROGRESS_FILE, 'r') as f:
        return json.load(f)

def read_results():
    """Read detailed results."""
    if not Path(RESULTS_FILE).exists():
        return {}
    
    with open(RESULTS_FILE, 'r') as f:
        return json.load(f)

def get_last_log_lines(n=10):
    """Get last N lines from log file."""
    if not Path(LOG_FILE).exists():
        return []
    
    with open(LOG_FILE, 'r', encoding='utf-8', errors='ignore') as f:
        lines = f.readlines()
        return lines[-n:] if len(lines) > n else lines

def display_progress():
    """Display current progress."""
    progress = read_progress()
    results = read_results()
    
    if not progress:
        print("\n[INFO] Scraper not started yet or progress file not created.")
        print("Waiting for scraper to start...")
        return False
    
    completed = set(progress.get('completed', []))
    failed = set(progress.get('failed', []))
    total = 26  # Total French restaurants
    
    # Calculate statistics
    total_processed = len(completed) + len(failed)
    success_count = len(completed)
    failed_count = len(failed)
    remaining = total - total_processed
    
    # Calculate totals from results
    total_courses = 0
    total_dishes = 0
    
    for crm_id in completed:
        crm_id_str = str(crm_id)
        if crm_id_str in results:
            result = results[crm_id_str]
            total_courses += result.get('courses', 0)
            total_dishes += result.get('dishes', 0)
    
    # Progress percentage
    progress_pct = (total_processed / total * 100) if total > 0 else 0
    
    # Display
    print("\n" + "="*80)
    print("FRENCH RESTAURANTS SCRAPER - PHASE 1 (COURSES & DISHES)")
    print("="*80)
    print(f"Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()
    print(f"Progress: {total_processed}/{total} restaurants ({progress_pct:.1f}%)")
    
    # Progress bar
    bar_length = 50
    filled = int(bar_length * total_processed / total)
    bar = '=' * filled + '-' * (bar_length - filled)
    print(f"[{bar}]")
    print()
    
    print(f"Status:")
    print(f"  Completed:  {success_count}")
    print(f"  Failed:     {failed_count}")
    print(f"  Remaining:  {remaining}")
    print()
    
    print(f"Data Inserted:")
    print(f"  Courses:    {total_courses}")
    print(f"  Dishes:     {total_dishes}")
    print()
    
    # Show last processed restaurant
    if results:
        last_crm_id = str(list(results.keys())[-1]) if results else None
        if last_crm_id and last_crm_id in results:
            last_result = results[last_crm_id]
            print(f"Last Processed:")
            print(f"  Restaurant: {last_result.get('name', 'Unknown')}")
            print(f"  Status:     {last_result.get('status', 'unknown')}")
            if last_result.get('status') == 'success':
                print(f"  Courses:    {last_result.get('courses', 0)}")
                print(f"  Dishes:     {last_result.get('dishes', 0)}")
            elif last_result.get('error'):
                print(f"  Error:      {last_result.get('error', 'Unknown error')}")
    
    # Show recent log activity
    print()
    print("Recent Activity (last 5 log lines):")
    print("-" * 80)
    recent_lines = get_last_log_lines(5)
    for line in recent_lines:
        # Clean up the line
        line = line.strip()
        if line:
            # Truncate long lines
            if len(line) > 78:
                line = line[:75] + "..."
            print(f"  {line}")
    
    print("="*80)
    
    # Check if complete
    if remaining == 0:
        print()
        print("[COMPLETE] All restaurants processed!")
        print()
        if failed_count > 0:
            print(f"[WARNING] {failed_count} restaurant(s) failed. Check log for details.")
        print()
        print(f"SUMMARY:")
        print(f"  Total restaurants: {total}")
        print(f"  Successful:        {success_count}")
        print(f"  Failed:            {failed_count}")
        print(f"  Total courses:     {total_courses}")
        print(f"  Total dishes:      {total_dishes}")
        print()
        print("Ready to proceed with Phase 2 (Prices & Modifiers)!")
        print("="*80)
        return True
    
    return False

def main():
    """Main monitoring loop."""
    print("\n" + "="*80)
    print("FRENCH SCRAPER PROGRESS MONITOR - PHASE 1")
    print("="*80)
    print("\nMonitoring batch_scrape_french.py progress...")
    print("Press Ctrl+C to stop monitoring (scraper will continue running)")
    print()
    
    try:
        while True:
            completed = display_progress()
            
            if completed:
                break
            
            # Wait before next update
            time.sleep(10)  # Update every 10 seconds
    
    except KeyboardInterrupt:
        print("\n\n[INFO] Monitoring stopped by user.")
        print("The scraper is still running in the background.")
        print("Run this script again to resume monitoring.")

if __name__ == "__main__":
    main()

