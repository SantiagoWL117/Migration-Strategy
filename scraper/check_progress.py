#!/usr/bin/env python3
"""Enhanced progress checker with ETA and rate calculation."""
import json
from datetime import datetime, timedelta
from pathlib import Path

PROGRESS_FILE = 'prices_modifiers_progress.json'
TOTAL_DISHES = 19349
START_TIME = datetime(2025, 11, 9, 16, 43, 44)  # When scraper restarted with fix
DISHES_BEFORE_RESTART = 331  # Completed before the restart

def check_progress():
    """Display current progress with ETA calculation."""
    if not Path(PROGRESS_FILE).exists():
        print("❌ Progress file not found!")
        print("   Make sure you're in the scraper directory.")
        return
    
    with open(PROGRESS_FILE, 'r') as f:
        progress = json.load(f)
    
    completed = len(progress['completed'])
    failed = len(progress['failed'])
    skipped = len(progress['skipped'])
    total_processed = completed + failed + skipped
    remaining = TOTAL_DISHES - total_processed
    percent = (total_processed / TOTAL_DISHES) * 100
    
    # Calculate ETA
    now = datetime.now()
    elapsed = (now - START_TIME).total_seconds() / 60  # minutes
    dishes_since_restart = completed - DISHES_BEFORE_RESTART
    
    print("=" * 60)
    print("SCRAPER PROGRESS REPORT")
    print("=" * 60)
    print(f"")
    print(f"[OK] Completed:  {completed:>6,} / {TOTAL_DISHES:,} ({percent:.2f}%)")
    print(f"[!!] Failed:     {failed:>6,}")
    print(f"[>>] Skipped:    {skipped:>6,}")
    print(f"   {'-' * 40}")
    print(f"[**] Total:      {total_processed:>6,}")
    print(f"[..] Remaining:  {remaining:>6,}")
    
    if dishes_since_restart > 0 and elapsed > 0:
        rate = dishes_since_restart / elapsed  # dishes per minute
        rate_per_hour = rate * 60
        
        if remaining > 0 and rate > 0:
            eta_minutes = remaining / rate
            eta_time = now + timedelta(minutes=eta_minutes)
            eta_hours = eta_minutes / 60
            eta_days = eta_hours / 24
            
            print(f"")
            print(f"PERFORMANCE")
            print(f"   {'-' * 40}")
            print(f"   Rate:       {rate:.2f} dishes/min ({rate_per_hour:.0f}/hour)")
            print(f"   Avg Time:   {60/rate:.1f} seconds per dish")
            print(f"")
            print(f"ESTIMATED COMPLETION")
            print(f"   {'-' * 40}")
            
            if eta_days >= 1:
                print(f"   Time Left:  {eta_days:.1f} days ({eta_hours:.1f} hours)")
            elif eta_hours >= 1:
                print(f"   Time Left:  {eta_hours:.1f} hours")
            else:
                print(f"   Time Left:  {eta_minutes:.0f} minutes")
            
            print(f"   ETA:        {eta_time.strftime('%B %d, %Y at %H:%M')}")
    
    # File modification time
    mod_time = datetime.fromtimestamp(Path(PROGRESS_FILE).stat().st_mtime)
    time_since_update = (now - mod_time).total_seconds()
    
    print(f"")
    print(f"FILE INFO")
    print(f"   {'-' * 40}")
    print(f"   Last Update: {mod_time.strftime('%H:%M:%S')}")
    
    if time_since_update < 60:
        print(f"   Status:      [OK] Active ({time_since_update:.0f}s ago)")
    elif time_since_update < 300:
        print(f"   Status:      [~~] Running ({time_since_update/60:.0f}m ago)")
    else:
        print(f"   Status:      [!!] Possibly stopped ({time_since_update/60:.0f}m ago)")
    
    print(f"")
    print("=" * 60)
    
    # Show warning if failed count is high
    if failed > 10:
        print(f"")
        print(f"[!!] WARNING: {failed} failed dishes detected!")
        print(f"    Check logs: batch_scrape_prices_modifiers.log")

if __name__ == "__main__":
    try:
        check_progress()
    except KeyboardInterrupt:
        print("\n\nInterrupted by user")
    except Exception as e:
        print(f"Error: {e}")

