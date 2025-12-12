"""Analyze Phase 1 and Phase 2 logs to find missing combo groups."""
import re
from collections import defaultdict


def analyze_phase2_warnings(filepath):
    """Extract restaurants with 'Combo group not found' warnings."""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    restaurants = {}
    current_restaurant = None

    for line in content.split('\n'):
        # Match restaurant processing line
        match = re.search(r'Processing: (.+?) \(V3: (\d+), V1: (\d+)\)', line)
        if match:
            current_restaurant = {
                'name': match.group(1),
                'v3': match.group(2),
                'v1': match.group(3),
                'missing_source_ids': set()
            }
            restaurants[match.group(3)] = current_restaurant

        # Match warning
        match = re.search(r'Combo group not found: source_id=(\d+)', line)
        if match and current_restaurant:
            current_restaurant['missing_source_ids'].add(match.group(1))

    # Filter to only restaurants with warnings
    return {k: v for k, v in restaurants.items() if v['missing_source_ids']}


def analyze_phase1_scraped(filepath):
    """Extract restaurants and their scraped combo groups from Phase 1."""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    restaurants = {}
    current_restaurant = None

    for line in content.split('\n'):
        # Match restaurant processing line
        match = re.search(r'Processing: (.+?) \(V3: (\d+), V1: (\d+)\)', line)
        if match:
            current_restaurant = {
                'name': match.group(1),
                'v3': match.group(2),
                'v1': match.group(3),
                'scraped_source_ids': set(),
                'combo_groups_count': 0
            }
            restaurants[match.group(3)] = current_restaurant

        # Match combo group processing
        match = re.search(
            r'Processing combo group: .+? \(source_id=(\d+)\)', line)
        if match and current_restaurant:
            current_restaurant['scraped_source_ids'].add(match.group(1))

        # Match combo groups count
        match = re.search(r'Combo groups: (\d+)', line)
        if match and current_restaurant:
            current_restaurant['combo_groups_count'] = int(match.group(1))

    return restaurants


def main():
    print("Analyzing Phase 2 failed log...")
    problem_restaurants = analyze_phase2_warnings(
        'logs/Combo scraper phase 2 failed.log')

    print("Analyzing Phase 1 successful log...")
    phase1_restaurants = analyze_phase1_scraped(
        'logs/Combo Phase 1 successful.log')

    print()
    print("=" * 80)
    print("RESTAURANTS WITH MISSING COMBO GROUPS")
    print("=" * 80)
    print()

    for v1_id in sorted(problem_restaurants.keys(), key=int):
        r = problem_restaurants[v1_id]
        missing_ids = sorted(r['missing_source_ids'], key=int)

        print(f"{r['name']}")
        print(f"  V3 ID: {r['v3']}, V1 ID: {r['v1']}")
        print(
            f"  Missing source_ids ({len(missing_ids)}): {', '.join(missing_ids)}")

        # Check Phase 1
        if v1_id in phase1_restaurants:
            p1 = phase1_restaurants[v1_id]
            scraped_ids = p1['scraped_source_ids']
            print(
                f"  Phase 1 scraped ({len(scraped_ids)} combo groups): {', '.join(sorted(scraped_ids, key=int)) if scraped_ids else 'NONE'}")

            # Check overlap
            found_in_p1 = r['missing_source_ids'] & scraped_ids
            not_in_p1 = r['missing_source_ids'] - scraped_ids

            if found_in_p1:
                print(
                    f"  [!] Found in Phase 1 (should exist): {', '.join(sorted(found_in_p1, key=int))}")
            if not_in_p1:
                print(
                    f"  [X] NOT scraped in Phase 1: {', '.join(sorted(not_in_p1, key=int))}")
        else:
            print(f"  [!] Restaurant NOT FOUND in Phase 1 log!")

        print()

    print("=" * 80)
    print(
        f"SUMMARY: {len(problem_restaurants)} restaurants with missing combo groups")
    print("=" * 80)

    # Count how many missing source_ids were never scraped in Phase 1
    all_missing = set()
    all_scraped_p1 = set()

    for v1_id, r in problem_restaurants.items():
        all_missing.update(r['missing_source_ids'])
        if v1_id in phase1_restaurants:
            all_scraped_p1.update(
                phase1_restaurants[v1_id]['scraped_source_ids'])

    not_scraped = all_missing - all_scraped_p1

    print(f"Total unique missing source_ids: {len(all_missing)}")
    print(
        f"Source_ids that were scraped in Phase 1: {len(all_missing - not_scraped)}")
    print(f"Source_ids NOT scraped in Phase 1: {len(not_scraped)}")


if __name__ == "__main__":
    main()


