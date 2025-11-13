#!/usr/bin/env python3
"""
Monitor progress of both Phase 2 scrapers (English and French) in real-time.
"""
import json
import time
import os
from pathlib import Path
from datetime import datetime

def safe_print(text):
    """Print with Unicode error handling."""
    try:
        print(text)
    except UnicodeEncodeError:
        print(text.encode('ascii', 'ignore').decode('ascii'))


def load_json_safe(filepath):
    """Load JSON file safely."""
    try:
        if Path(filepath).exists():
            with open(filepath, 'r') as f:
                return json.load(f)
    except:
        pass
    return None


def get_last_log_lines(logfile, n=5):
    """Get last N lines from log file."""
    try:
        if Path(logfile).exists():
            with open(logfile, 'r', encoding='utf-8', errors='ignore') as f:
                lines = f.readlines()
                return lines[-n:] if len(lines) >= n else lines
    except:
        pass
    return []


def format_duration(seconds):
    """Format seconds into readable duration."""
    hours = int(seconds // 3600)
    minutes = int((seconds % 3600) // 60)
    secs = int(seconds % 60)
    return f"{hours}h {minutes}m {secs}s"


def display_scraper_status(name, progress_file, results_file, log_file, total_dishes):
    """Display status for one scraper."""
    safe_print(f"\n{'='*80}")
    safe_print(f"{name} SCRAPER STATUS")
    safe_print(f"{'='*80}")
    
    # Load progress
    progress = load_json_safe(progress_file)
    if not progress:
        safe_print("[INFO] Not started yet or progress file not created.")
        return
    
    completed = len(progress.get('completed', []))
    failed = len(progress.get('failed', []))
    skipped = len(progress.get('skipped', []))
    total_processed = completed + failed + skipped
    remaining = total_dishes - total_processed if total_dishes > total_processed else 0
    
    # Calculate percentage
    progress_pct = (total_processed / total_dishes * 100) if total_dishes > 0 else 0
    
    safe_print(f"\nProgress: {total_processed}/{total_dishes} dishes (~{progress_pct:.1f}%)")
    safe_print(f"  Completed: {completed}")
    safe_print(f"  Failed: {failed}")
    safe_print(f"  Skipped: {skipped}")
    safe_print(f"  Remaining: ~{remaining}")
    
    # Load results for data stats
    results = load_json_safe(results_file)
    if results:
        total_prices = sum(r.get('prices_count', 0) for r in results)
        total_groups = sum(r.get('modifier_groups_count', 0) for r in results)
        total_items = sum(r.get('modifier_items_count', 0) for r in results)
        total_mod_prices = sum(r.get('modifier_prices_count', 0) for r in results)
        
        safe_print(f"\nData Inserted:")
        safe_print(f"  Dish Prices: {total_prices:,}")
        safe_print(f"  Modifier Groups: {total_groups:,}")
        safe_print(f"  Modifier Items: {total_items:,}")
        safe_print(f"  Modifier Prices: {total_mod_prices:,}")
        
        # Last processed dish
        if results:
            last = results[-1]
            status_emoji = "OK" if last.get('success') else "FAIL"
            safe_print(f"\nLast Processed Dish:")
            safe_print(f"  Name: {last.get('dish_name', 'Unknown')}")
            safe_print(f"  Restaurant: {last.get('restaurant_name', 'Unknown')}")
            safe_print(f"  Status: {status_emoji}")
            safe_print(f"  Prices: {last.get('prices_count', 0)}, Modifier Groups: {last.get('modifier_groups_count', 0)}")
    
    # Show recent log activity
    log_lines = get_last_log_lines(log_file, 3)
    if log_lines:
        safe_print(f"\nRecent Activity (last 3 log lines):")
        for line in log_lines:
            safe_print(f"  {line.strip()}")


def main():
    """Main monitoring loop."""
    # File paths
    english_progress = 'list4_prices_english_progress.json'
    english_results = 'list4_prices_english_results.json'
    english_log = 'batch_scrape_list4_prices_english.log'
    
    french_progress = 'list4_prices_french_progress.json'
    french_results = 'list4_prices_french_results.json'
    french_log = 'batch_scrape_list4_prices_french.log'
    
    # Estimated dish counts (from Phase 1)
    ENGLISH_DISHES = 7262  # Approximate
    FRENCH_DISHES = 1484   # Approximate
    
    safe_print("=" * 80)
    safe_print("LIST 4 PHASE 2 - PROGRESS MONITOR")
    safe_print("=" * 80)
    safe_print(f"Started: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    safe_print("\nMonitoring both English and French scrapers...")
    safe_print("Press Ctrl+C to exit monitor (scrapers will continue running)")
    
    try:
        while True:
            # Clear screen (optional - comment out if you prefer scrolling)
            os.system('cls' if os.name == 'nt' else 'clear')
            
            safe_print("=" * 80)
            safe_print(f"LIST 4 PHASE 2 - REAL-TIME PROGRESS")
            safe_print(f"Updated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
            safe_print("=" * 80)
            
            # Display English scraper status
            display_scraper_status(
                "ENGLISH",
                english_progress,
                english_results,
                english_log,
                ENGLISH_DISHES
            )
            
            # Display French scraper status
            display_scraper_status(
                "FRENCH",
                french_progress,
                french_results,
                french_log,
                FRENCH_DISHES
            )
            
            # Overall status
            english_prog = load_json_safe(english_progress)
            french_prog = load_json_safe(french_progress)
            
            if english_prog and french_prog:
                eng_total = len(english_prog.get('completed', [])) + len(english_prog.get('failed', [])) + len(english_prog.get('skipped', []))
                fr_total = len(french_prog.get('completed', [])) + len(french_prog.get('failed', [])) + len(french_prog.get('skipped', []))
                overall_total = eng_total + fr_total
                overall_dishes = ENGLISH_DISHES + FRENCH_DISHES
                overall_pct = (overall_total / overall_dishes * 100) if overall_dishes > 0 else 0
                
                safe_print(f"\n{'='*80}")
                safe_print(f"OVERALL PROGRESS: {overall_total}/{overall_dishes} dishes ({overall_pct:.1f}%)")
                safe_print(f"{'='*80}")
            
            safe_print("\nRefreshing in 30 seconds... (Ctrl+C to exit)")
            time.sleep(30)
            
    except KeyboardInterrupt:
        safe_print("\n\nMonitor stopped. Scrapers continue running in their windows.")


if __name__ == "__main__":
    main()

