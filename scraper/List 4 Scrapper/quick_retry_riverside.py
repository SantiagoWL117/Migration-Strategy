from scraper_french import FrenchMenuScraper
from database import DatabaseManager

print("="*80)
print("RETRY: Riverside Pizzeria (DB:133, CRM:257)")
print("="*80)

db = DatabaseManager()
db.connect()
print("Database connected")

s = FrenchMenuScraper()
s.start()
print("Scraper started and logged in")

print("\nScraping Riverside Pizzeria (CRM:257)...")
menu = s.scrape_restaurant_menu(257, 'en')
courses = menu.get('courses', [])
print(f"Found {len(courses)} courses")

total_dishes = sum(len(c.get('dishes', [])) for c in courses)
print(f"Found {total_dishes} dishes")

if len(courses) == 0:
    print("\nNo menu data found!")
    s.stop()
    db.close()
    exit(1)

print("\nInserting into database...")
course_ids = []
for c in courses:
    cid = db.insert_course(133, c['name'], c.get('description', ''), c['display_order'])
    course_ids.append(cid)
    print(f"  Course: {c['name']}")

dishes_inserted = 0
for c in courses:
    if c['display_order'] < len(course_ids) and course_ids[c['display_order']] is not None:
        for d in c.get('dishes', []):
            db.insert_dish(133, course_ids[c['display_order']], d['name'], 
                          d.get('description', ''), d['display_order'], d.get('menu_entry_id'))
            dishes_inserted += 1

print(f"\n{'='*80}")
print("RESULTS:")
print(f"{'='*80}")
print(f"Courses inserted: {len(course_ids)}")
print(f"Dishes inserted: {dishes_inserted}")
print(f"{'='*80}")
print("✅ SUCCESS!")
print(f"{'='*80}")

s.stop()
db.close()

