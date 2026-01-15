import psycopg2
from bs4 import BeautifulSoup
import re

# Hardcoded connection string
DB_CONNECTION_STRING = "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres"

# HTML content provided by user
html_content = """
<!-- Your HTML content will go here -->
"""

# Parse HTML
soup = BeautifulSoup(html_content, 'html.parser')

# Connect to database
conn = psycopg2.connect(DB_CONNECTION_STRING)
cur = conn.cursor()

# First, let's verify restaurant 147 exists
cur.execute("""
    SELECT id, name_en, name_fr 
    FROM menuca_v3.restaurants 
    WHERE id = 147;
""")
restaurant = cur.fetchone()

if restaurant:
    print(f"Restaurant found: {restaurant[1]} (ID: {restaurant[0]})")
else:
    print("ERROR: Restaurant ID 147 not found")
    conn.close()
    exit(1)

# Get all dishes for this restaurant
cur.execute("""
    SELECT 
        d.id,
        d.name_en,
        d.name_fr,
        d.is_active,
        d.deleted_at
    FROM menuca_v3.dishes d
    WHERE d.restaurant_id = 147
    ORDER BY d.id;
""")

dishes = cur.fetchall()
print(f"\nTotal dishes for restaurant 147: {len(dishes)}")
print("\nFirst 10 dishes:")
for i, dish in enumerate(dishes[:10]):
    print(f"  {dish[0]}: {dish[1]} (active: {dish[3]}, deleted: {dish[4]})")

conn.close()
print("\nReady to parse HTML and update prices.")
