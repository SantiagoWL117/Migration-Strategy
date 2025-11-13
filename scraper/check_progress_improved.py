#!/usr/bin/env python3
"""
Improved progress checker that dynamically reads actual totals from log file.
More accurate than check_progress.py which has hardcoded values.
"""
import json
import re
from datetime import datetime, timedelta
from pathlib import Path

PROGRESS_FILE = 'prices_modifiers_progress.json'
LOG_FILE = 'batch_scrape_prices_modifiers.log'

def get_total_dishes_from_log():
    """Extract total dishes count from the most recent log entry."""
    if not Path(LOG_FILE).exists():
        return None
    
    try:
        with open(LOG_FILE, 'r', encoding='utf-8', errors='ignore') as f:
            lines = f.readlines()
            # Search from the end backwards for the most recent "Found X dishes to process"
            for line in reversed(lines):
                if 'Found' in line and 'dishes to process' in line:
                    # Extract number: "Found 21410 dishes to process"
                    match = re.search(r'Found\s+(\d+)\s+dishes to process', line)
                    if match:
                        return int(match.group(1))
    except Exception as e:
        print(f"Warning: Could not read log file: {e}")
    
    return None

def get_start_time_from_log():
    """Extract the start time from the most recent scraper run."""
    if not Path(LOG_FILE).exists():
        return None
    
    try:
        with open(LOG_FILE, 'r', encoding='utf-8', errors='ignore') as f:
            lines = f.readlines()
            # Find the most recent "Found X dishes to process" and get its timestamp
            for i in range(len(lines) - 1, -1, -1):
                if 'Found' in lines[i] and 'dishes to process' in lines[i]:
                    # Extract timestamp from the line before or the same line
                    timestamp_match = re.search(r'(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})', lines[i])
                    if timestamp_match:
                        return datetime.strptime(timestamp_match.group(1), '%Y-%m-%d %H:%M:%S')
    except Exception as e:
        print(f"Warning: Could not extract start time: {e}")
    
    return None

def check_progress():
    """Display current progress with accurate ETA calculation."""
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
    
    # Get actual total from log (more accurate than hardcoded value)
    total_dishes = get_total_dishes_from_log()
    if total_dishes is None:
        print("⚠️  Warning: Could not determine total dishes from log.")
        print("   Using estimated total of 21,410 (from last known run)")
        total_dishes = 21410  # Fallback to known value
    
    remaining = total_dishes - total_processed
    percent = (total_processed / total_dishes * 100) if total_dishes > 0 else 0
    
    # Get start time from log
    start_time = get_start_time_from_log()
    if start_time is None:
        # Fallback: look for "Already completed" line which shows when scraper resumed
        # This gives us a better estimate
        try:
            with open(LOG_FILE, 'r', encoding='utf-8', errors='ignore') as f:
                lines = f.readlines()
                for i in range(len(lines) - 1, -1, -1):
                    if 'Already completed' in lines[i]:
                        timestamp_match = re.search(r'(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})', lines[i])
                        if timestamp_match:
                            start_time = datetime.strptime(timestamp_match.group(1), '%Y-%m-%d %H:%M:%S')
                            break
        except:
            pass
        
        if start_time is None:
            # Last resort: find the most recent "Found X dishes" line timestamp
            try:
                with open(LOG_FILE, 'r', encoding='utf-8', errors='ignore') as f:
                    lines = f.readlines()
                    for i in range(len(lines) - 1, -1, -1):
                        if 'Found' in lines[i] and 'dishes to process' in lines[i]:
                            timestamp_match = re.search(r'(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})', lines[i])
                            if timestamp_match:
                                start_time = datetime.strptime(timestamp_match.group(1), '%Y-%m-%d %H:%M:%S')
                                break
            except:
                pass
            
            if start_time is None:
                print("[WARN] Could not determine exact start time from log.")
                print("   ETA calculation may be inaccurate.")
                start_time = datetime.now() - timedelta(minutes=10)  # Assume 10 min ago as fallback
    
    # Get initial completed count from log (when scraper resumed)
    initial_completed = None
    try:
        with open(LOG_FILE, 'r', encoding='utf-8', errors='ignore') as f:
            lines = f.readlines()
            for i in range(len(lines) - 1, -1, -1):
                if 'Already completed:' in lines[i]:
                    match = re.search(r'Already completed:\s*(\d+)', lines[i])
                    if match:
                        initial_completed = int(match.group(1))
                        # Get timestamp from this line for accurate start time
                        timestamp_match = re.search(r'(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})', lines[i])
                        if timestamp_match:
                            start_time = datetime.strptime(timestamp_match.group(1), '%Y-%m-%d %H:%M:%S')
                        break
    except:
        pass
    
    # Calculate ETA
    now = datetime.now()
    elapsed = (now - start_time).total_seconds() / 60  # minutes
    
    print("=" * 70)
    print("ENGLISH SCRAPER PROGRESS REPORT")
    print("=" * 70)
    print(f"")
    print(f"[OK] Completed:  {completed:>6,} / {total_dishes:,} ({percent:.2f}%)")
    print(f"[!!] Failed:     {failed:>6,}")
    print(f"[>>] Skipped:    {skipped:>6,}")
    print(f"   {'-' * 50}")
    print(f"[**] Total:      {total_processed:>6,}")
    print(f"[..] Remaining:  {remaining:>6,}")
    
    if completed > 0 and elapsed > 0:
        # Calculate rate based on dishes processed since resume
        if initial_completed is not None:
            dishes_since_resume = completed - initial_completed
            rate = dishes_since_resume / elapsed if elapsed > 0 else 0
        else:
            # Fallback: use total completed (less accurate)
            rate = completed / elapsed
        rate_per_hour = rate * 60
        
        if remaining > 0 and rate > 0:
            eta_minutes = remaining / rate
            eta_time = now + timedelta(minutes=eta_minutes)
            eta_hours = eta_minutes / 60
            eta_days = eta_hours / 24
            
            print(f"")
            print(f"PERFORMANCE")
            print(f"   {'-' * 50}")
            print(f"   Rate:       {rate:.2f} dishes/min ({rate_per_hour:.0f}/hour)")
            print(f"   Avg Time:   {60/rate:.1f} seconds per dish")
            print(f"")
            print(f"ESTIMATED COMPLETION")
            print(f"   {'-' * 50}")
            
            if eta_days >= 1:
                print(f"   Time Left:  {eta_days:.1f} days ({eta_hours:.1f} hours)")
            elif eta_hours >= 1:
                print(f"   Time Left:  {eta_hours:.1f} hours ({eta_minutes:.0f} minutes)")
            else:
                print(f"   Time Left:  {eta_minutes:.0f} minutes")
            
            print(f"   ETA:        {eta_time.strftime('%B %d, %Y at %H:%M')}")
    
    # File modification time
    mod_time = datetime.fromtimestamp(Path(PROGRESS_FILE).stat().st_mtime)
    time_since_update = (now - mod_time).total_seconds()
    
    print(f"")
    print(f"FILE INFO")
    print(f"   {'-' * 50}")
    print(f"   Last Update: {mod_time.strftime('%H:%M:%S')}")
    
    if time_since_update < 60:
        print(f"   Status:      [OK] Active ({time_since_update:.0f}s ago)")
    elif time_since_update < 300:
        print(f"   Status:      [~~] Running ({time_since_update/60:.0f}m ago)")
    else:
        print(f"   Status:      [!!] Possibly stopped ({time_since_update/60:.0f}m ago)")
    
    print(f"")
    print("=" * 70)
    
    # Show warning if failed count is high
    if failed > 10:
        print(f"")
        print(f"[!!] WARNING: {failed} failed dishes detected!")
        print(f"    Check logs: batch_scrape_prices_modifiers.log")
    
    # Show accuracy note
    if total_dishes != 19349:
        print(f"")
        print(f"[INFO] Note: Total dishes ({total_dishes:,}) read from log file.")
        print(f"   (Old script had hardcoded 19,349 which was inaccurate)")

if __name__ == "__main__":
    try:
        check_progress()
    except KeyboardInterrupt:
        print("\n\nInterrupted by user")
    except Exception as e:
        print(f"Error: {e}")

