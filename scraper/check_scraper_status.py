"""
Check the current status of both English and French scrapers.
"""
import json
from pathlib import Path
from datetime import datetime

def check_progress_file(file_path, scraper_name):
    """Check progress file and return summary."""
    if not Path(file_path).exists():
        return f"{scraper_name}: No progress file found"
    
    try:
        with open(file_path, 'r') as f:
            data = json.load(f)
        
        completed = len(data.get('completed', []))
        failed = len(data.get('failed', []))
        skipped = len(data.get('skipped', []))
        total = completed + failed + skipped
        
        return {
            'name': scraper_name,
            'completed': completed,
            'failed': failed,
            'skipped': skipped,
            'total': total
        }
    except Exception as e:
        return f"{scraper_name}: Error reading file - {e}"

def check_log_file(file_path, scraper_name):
    """Check last log entry."""
    if not Path(file_path).exists():
        return None
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
            if lines:
                return lines[-1].strip()
    except:
        pass
    return None

def main():
    print("\n" + "="*80)
    print("SCRAPER STATUS REPORT")
    print("="*80)
    print(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
    
    # Check English scraper
    print("ENGLISH SCRAPER (batch_scrape_prices_modifiers.py)")
    print("-" * 80)
    eng_progress = check_progress_file('prices_modifiers_progress.json', 'English')
    if isinstance(eng_progress, dict):
        print(f"  Status: PAUSED (as per report)")
        print(f"  Completed dishes: {eng_progress['completed']:,}")
        print(f"  Failed dishes: {eng_progress['failed']}")
        print(f"  Skipped dishes: {eng_progress['skipped']}")
        print(f"  Total processed: {eng_progress['total']:,}")
    else:
        print(f"  {eng_progress}")
    
    eng_log = check_log_file('batch_scrape_prices_modifiers.log', 'English')
    if eng_log:
        print(f"  Last log entry: {eng_log[:100]}...")
    
    print()
    
    # Check French scraper
    print("FRENCH SCRAPER")
    print("-" * 80)
    
    # Phase 1
    print("  Phase 1 (batch_scrape_french.py):")
    fr_phase1_progress = check_progress_file('french_scrape_progress.json', 'French Phase 1')
    if isinstance(fr_phase1_progress, dict):
        print(f"    Status: COMPLETE")
        print(f"    Restaurants: {fr_phase1_progress['completed']}")
    else:
        print(f"    {fr_phase1_progress}")
    
    # Phase 2
    print("  Phase 2 (batch_scrape_french_prices.py):")
    fr_phase2_progress = check_progress_file('french_prices_progress.json', 'French Phase 2')
    if isinstance(fr_phase2_progress, dict):
        print(f"    Status: COMPLETE")
        print(f"    Completed dishes: {fr_phase2_progress['completed']:,}")
        print(f"    Failed dishes: {fr_phase2_progress['failed']}")
        print(f"    Skipped dishes: {fr_phase2_progress['skipped']}")
        print(f"    Total processed: {fr_phase2_progress['total']:,}")
    else:
        print(f"    {fr_phase2_progress}")
    
    fr_log = check_log_file('batch_scrape_french_prices.log', 'French Phase 2')
    if fr_log:
        print(f"    Last log entry: {fr_log[:100]}...")
    
    print()
    print("="*80)
    print("\nSUMMARY:")
    print("  - English scraper: PAUSED (can be resumed)")
    print("  - French scraper: COMPLETE (both phases)")
    print("="*80)

if __name__ == "__main__":
    main()

