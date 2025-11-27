"""
Verify data integrity for all 166 V1 restaurants
Checks: courses, dishes, dish_prices existence and orphan data
"""
import csv
import subprocess
import json

# Connection details
CONN_STRING = "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres"
PSQL_PATH = r"C:\Program Files\PostgreSQL\17\bin\psql.exe"

# Read V1 restaurant IDs from mapping file
v1_restaurants = []
with open('scraper/V1 Scrapper/v1_v3_id_mapping.csv', 'r', encoding='utf-8') as f:
    reader = csv.DictReader(f)
    for row in reader:
        v1_restaurants.append({
            'v3_id': int(row['v3_id']),
            'v1_id': int(row['v1_id']),
            'name': row['name'],
            'address': row['address']
        })

print("="*80)
print("V1 RESTAURANTS DATA INTEGRITY VERIFICATION")
print("="*80)
print(f"Total V1 restaurants to verify: {len(v1_restaurants)}\n")

# Convert to list of IDs for SQL
v1_ids = [r['v3_id'] for r in v1_restaurants]
v1_ids_str = ','.join(map(str, v1_ids))

def run_query(query, description):
    """Run a psql query and return results"""
    print(f"\n{description}")
    print("-" * 80)
    
    try:
        result = subprocess.run(
            [PSQL_PATH, CONN_STRING, "-c", query, "-t", "-A", "-F,"],
            capture_output=True,
            text=True,
            encoding='utf-8'
        )
        
        if result.returncode != 0:
            print(f"ERROR: {result.stderr}")
            return None
        
        output = result.stdout.strip()
        if output:
            return output
        else:
            return "No results"
    except Exception as e:
        print(f"ERROR running query: {e}")
        return None

# ================================================================================
# 1. SUMMARY STATISTICS
# ================================================================================
query1 = f"""
SELECT 
    (SELECT COUNT(DISTINCT id) FROM menuca_v3.restaurants 
     WHERE id IN ({v1_ids_str})) as total_v1_restaurants,
    (SELECT COUNT(DISTINCT restaurant_id) FROM menuca_v3.courses 
     WHERE restaurant_id IN ({v1_ids_str})) as restaurants_with_courses,
    (SELECT COUNT(DISTINCT restaurant_id) FROM menuca_v3.dishes 
     WHERE restaurant_id IN ({v1_ids_str})) as restaurants_with_dishes,
    (SELECT COUNT(DISTINCT d.restaurant_id) 
     FROM menuca_v3.dishes d
     INNER JOIN menuca_v3.dish_prices dp ON d.id = dp.dish_id
     WHERE d.restaurant_id IN ({v1_ids_str})) as restaurants_with_dish_prices;
"""
result1 = run_query(query1, "[SUMMARY STATISTICS]")
if result1 and result1 != "No results":
    parts = result1.split(',')
    if len(parts) == 4:
        print(f"  Total V1 Restaurants:              {parts[0]}")
        print(f"  Restaurants with Courses:          {parts[1]}")
        print(f"  Restaurants with Dishes:           {parts[2]}")
        print(f"  Restaurants with Dish Prices:      {parts[3]}")

# ================================================================================
# 2. V1 Restaurants WITHOUT Courses
# ================================================================================
query2 = f"""
SELECT r.id, r.name, r.address
FROM menuca_v3.restaurants r
WHERE r.id IN ({v1_ids_str})
  AND NOT EXISTS (SELECT 1 FROM menuca_v3.courses c WHERE c.restaurant_id = r.id)
ORDER BY r.name;
"""
result2 = run_query(query2, "[V1 RESTAURANTS WITHOUT COURSES]")
if result2 and result2 != "No results":
    lines = result2.split('\n')
    print(f"  Found {len(lines)} restaurant(s) without courses:")
    for i, line in enumerate(lines[:20], 1):  # Show first 20
        if line:
            parts = line.split(',')
            if len(parts) >= 2:
                print(f"  {i}. ID {parts[0]}: {parts[1]}")
    if len(lines) > 20:
        print(f"  ... and {len(lines) - 20} more")
else:
    print(f"  [OK] All V1 restaurants have courses!")

# ================================================================================
# 3. V1 Restaurants WITHOUT Dishes
# ================================================================================
query3 = f"""
SELECT r.id, r.name, r.address
FROM menuca_v3.restaurants r
WHERE r.id IN ({v1_ids_str})
  AND NOT EXISTS (SELECT 1 FROM menuca_v3.dishes d WHERE d.restaurant_id = r.id)
ORDER BY r.name;
"""
result3 = run_query(query3, "[V1 RESTAURANTS WITHOUT DISHES]")
if result3 and result3 != "No results":
    lines = result3.split('\n')
    print(f"  Found {len(lines)} restaurant(s) without dishes:")
    for i, line in enumerate(lines[:20], 1):
        if line:
            parts = line.split(',')
            if len(parts) >= 2:
                print(f"  {i}. ID {parts[0]}: {parts[1]}")
    if len(lines) > 20:
        print(f"  ... and {len(lines) - 20} more")
else:
    print(f"  [OK] All V1 restaurants have dishes!")

# ================================================================================
# 4. V1 Restaurants WITHOUT Dish Prices
# ================================================================================
query4 = f"""
SELECT r.id, r.name, 
       (SELECT COUNT(*) FROM menuca_v3.dishes d WHERE d.restaurant_id = r.id) as dish_count
FROM menuca_v3.restaurants r
WHERE r.id IN ({v1_ids_str})
  AND EXISTS (SELECT 1 FROM menuca_v3.dishes d WHERE d.restaurant_id = r.id)
  AND NOT EXISTS (
      SELECT 1 
      FROM menuca_v3.dishes d
      INNER JOIN menuca_v3.dish_prices dp ON d.id = dp.dish_id
      WHERE d.restaurant_id = r.id
  )
ORDER BY r.name;
"""
result4 = run_query(query4, "[V1 RESTAURANTS WITH DISHES BUT NO DISH PRICES]")
if result4 and result4 != "No results":
    lines = result4.split('\n')
    print(f"  Found {len(lines)} restaurant(s) with dishes but no prices:")
    for i, line in enumerate(lines[:20], 1):
        if line:
            parts = line.split(',')
            if len(parts) >= 3:
                print(f"  {i}. ID {parts[0]}: {parts[1]} ({parts[2]} dishes)")
    if len(lines) > 20:
        print(f"  ... and {len(lines) - 20} more")
else:
    print(f"  [OK] All V1 restaurants with dishes have prices!")

# ================================================================================
# 5. Orphan Courses (courses without valid restaurant)
# ================================================================================
query5 = """
SELECT c.id, c.name, c.restaurant_id
FROM menuca_v3.courses c
WHERE NOT EXISTS (SELECT 1 FROM menuca_v3.restaurants r WHERE r.id = c.restaurant_id)
LIMIT 50;
"""
result5 = run_query(query5, "[ORPHAN COURSES - courses without valid restaurant]")
if result5 and result5 != "No results":
    lines = result5.split('\n')
    print(f"  Found {len(lines)} orphan course(s):")
    for i, line in enumerate(lines[:10], 1):
        if line:
            parts = line.split(',')
            if len(parts) >= 3:
                print(f"  {i}. Course ID {parts[0]}: {parts[1]} (Restaurant ID: {parts[2]})")
else:
    print(f"  [OK] No orphan courses found!")

# ================================================================================
# 6. Orphan Dishes (dishes without valid restaurant)
# ================================================================================
query6 = """
SELECT d.id, d.name, d.restaurant_id
FROM menuca_v3.dishes d
WHERE NOT EXISTS (SELECT 1 FROM menuca_v3.restaurants r WHERE r.id = d.restaurant_id)
LIMIT 50;
"""
result6 = run_query(query6, "[ORPHAN DISHES - dishes without valid restaurant]")
if result6 and result6 != "No results":
    lines = result6.split('\n')
    print(f"  Found {len(lines)} orphan dish(es):")
    for i, line in enumerate(lines[:10], 1):
        if line:
            parts = line.split(',')
            if len(parts) >= 3:
                print(f"  {i}. Dish ID {parts[0]}: {parts[1]} (Restaurant ID: {parts[2]})")
else:
    print(f"  [OK] No orphan dishes found!")

# ================================================================================
# 7. Orphan Dish Prices (prices without valid dish)
# ================================================================================
query7 = """
SELECT dp.id, dp.dish_id, dp.price
FROM menuca_v3.dish_prices dp
WHERE NOT EXISTS (SELECT 1 FROM menuca_v3.dishes d WHERE d.id = dp.dish_id)
LIMIT 50;
"""
result7 = run_query(query7, "[ORPHAN DISH PRICES - prices without valid dish]")
if result7 and result7 != "No results":
    lines = result7.split('\n')
    print(f"  Found {len(lines)} orphan dish price(s):")
    for i, line in enumerate(lines[:10], 1):
        if line:
            parts = line.split(',')
            if len(parts) >= 3:
                print(f"  {i}. Price ID {parts[0]}: Dish ID {parts[1]}, Price: ${parts[2]}")
else:
    print(f"  [OK] No orphan dish prices found!")

# ================================================================================
# 8. Count Summary (process in chunks to avoid memory issues)
# ================================================================================
print(f"\n[DETAILED COUNTS PER RESTAURANT - Processing in chunks...]")
print("-" * 80)

CHUNK_SIZE = 20
for chunk_start in range(0, len(v1_ids), CHUNK_SIZE):
    chunk_end = min(chunk_start + CHUNK_SIZE, len(v1_ids))
    chunk_ids = v1_ids[chunk_start:chunk_end]
    chunk_ids_str = ','.join(map(str, chunk_ids))
    
    query8 = f"""
    SELECT 
        r.id,
        r.name,
        COALESCE((SELECT COUNT(*) FROM menuca_v3.courses WHERE restaurant_id = r.id), 0) as courses,
        COALESCE((SELECT COUNT(*) FROM menuca_v3.dishes WHERE restaurant_id = r.id), 0) as dishes,
        COALESCE((SELECT COUNT(dp.id) 
                  FROM menuca_v3.dishes d
                  INNER JOIN menuca_v3.dish_prices dp ON d.id = dp.dish_id
                  WHERE d.restaurant_id = r.id), 0) as prices
    FROM menuca_v3.restaurants r
    WHERE r.id IN ({chunk_ids_str})
    ORDER BY r.name;
    """
    
    print(f"\n  Chunk {chunk_start//CHUNK_SIZE + 1} (Restaurants {chunk_start + 1}-{chunk_end}):")
    result8 = run_query(query8, "")
    
    if result8 and result8 != "No results":
        lines = result8.split('\n')
        for line in lines:
            if line:
                parts = line.split(',')
                if len(parts) >= 5:
                    print(f"    ID {parts[0]}: {parts[1][:35]:35} | Courses: {parts[2]:3} | Dishes: {parts[3]:4} | Prices: {parts[4]:4}")

print("\n" + "="*80)
print("VERIFICATION COMPLETE!")
print("="*80)

