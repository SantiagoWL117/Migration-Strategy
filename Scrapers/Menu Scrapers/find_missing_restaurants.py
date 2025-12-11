"""Find restaurants in Phase 2 that are NOT in Phase 1."""
import re


def get_restaurants_with_warnings(filepath):
    """Extract restaurants that had 'Combo group not found' warnings."""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    restaurants = {}
    current_restaurant = None

    for line in content.split('\n'):
        # Match restaurant processing line
        match = re.search(r'Processing: (.+?) \(V3: (\d+), V1: (\d+)\)', line)
        if match:
            v1_id = match.group(3)
            current_restaurant = {
                'name': match.group(1),
                'v3': match.group(2),
                'v1': v1_id,
                'missing_source_ids': set()
            }
            if v1_id not in restaurants:
                restaurants[v1_id] = current_restaurant
            else:
                current_restaurant = restaurants[v1_id]

        # Match warning
        match = re.search(r'Combo group not found: source_id=(\d+)', line)
        if match and current_restaurant:
            current_restaurant['missing_source_ids'].add(match.group(1))

    # Filter to only restaurants with warnings
    return {k: v for k, v in restaurants.items() if v['missing_source_ids']}


def get_all_restaurants(filepath):
    """Extract all restaurants from a log file."""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    restaurants = set()
    for match in re.finditer(r'Processing: .+? \(V3: \d+, V1: (\d+)\)', content):
        restaurants.add(match.group(1))
    return restaurants


def main():
    phase2_file = 'logs/Combo scraper phase 2 failed.log'
    phase1_file = 'logs/Combo Phase 1 successful.log'

    print("Loading Phase 2 failed log...")
    phase2_warnings = get_restaurants_with_warnings(phase2_file)

    print("Loading Phase 1 successful log...")
    phase1_v1_ids = get_all_restaurants(phase1_file)

    # Find restaurants with warnings in Phase 2 but NOT in Phase 1
    missing = []
    for v1_id, info in phase2_warnings.items():
        if v1_id not in phase1_v1_ids:
            info['missing_count'] = len(info['missing_source_ids'])
            missing.append(info)

    print()
    print("=" * 70)
    print("RESTAURANTS WITH WARNINGS IN PHASE 2 BUT NOT SCRAPED IN PHASE 1")
    print("=" * 70)
    print()

    if missing:
        print(f"{'Restaurant':<40} {'V3 ID':>7} {'V1 ID':>7} {'Missing':>8}")
        print("-" * 70)

        total_missing = 0
        for r in sorted(missing, key=lambda x: int(x['v1'])):
            print(
                f"{r['name']:<40} {r['v3']:>7} {r['v1']:>7} {r['missing_count']:>8}")
            total_missing += r['missing_count']

        print("-" * 70)
        print(f"{'TOTAL':<40} {'':<7} {len(missing):>7} {total_missing:>8}")
    else:
        print("None found - all Phase 2 restaurants with warnings were in Phase 1")

    print()
    print("=" * 70)
    print("SUMMARY")
    print("=" * 70)
    print(f"Restaurants with warnings in Phase 2: {len(phase2_warnings)}")
    print(f"Restaurants scraped in Phase 1: {len(phase1_v1_ids)}")
    print(f"Restaurants needing Phase 1 re-scrape: {len(missing)}")


if __name__ == "__main__":
    main()
