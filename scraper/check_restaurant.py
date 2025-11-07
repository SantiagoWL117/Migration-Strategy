"""Quick script to check if Aahar restaurant exists in the database."""
import psycopg2
from psycopg2.extras import RealDictCursor
from config import DB_CONNECTION_STRING, SCHEMA

def check_restaurant():
    """Check if Aahar exists in database."""
    try:
        conn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = conn.cursor(cursor_factory=RealDictCursor)

        # Search for Aahar
        query = f"""
            SELECT id, name, legacy_v1_id, legacy_v2_id, status
            FROM {SCHEMA}.restaurants
            WHERE name ILIKE '%aahar%' AND deleted_at IS NULL
        """
        cursor.execute(query)
        restaurants = cursor.fetchall()

        if restaurants:
            print(f"\n✅ Found {len(restaurants)} restaurant(s):\n")
            for r in restaurants:
                print(f"  ID: {r['id']}")
                print(f"  Name: {r['name']}")
                print(f"  Status: {r['status']}")
                print(f"  Legacy V1 ID: {r['legacy_v1_id']}")
                print(f"  Legacy V2 ID: {r['legacy_v2_id']}")
                print()

            # Check for menu data
            restaurant_id = restaurants[0]['id']
            cursor.execute(f"SELECT COUNT(*) as count FROM {SCHEMA}.courses WHERE restaurant_id = %s AND deleted_at IS NULL", (restaurant_id,))
            course_count = cursor.fetchone()['count']

            cursor.execute(f"SELECT COUNT(*) as count FROM {SCHEMA}.dishes WHERE restaurant_id = %s AND deleted_at IS NULL", (restaurant_id,))
            dish_count = cursor.fetchone()['count']

            print(f"  Current Menu Data:")
            print(f"    Courses: {course_count}")
            print(f"    Dishes: {dish_count}")
            print()

            if course_count == 0 and dish_count == 0:
                print("  ℹ️  No menu data found - ready for scraping!")
            else:
                print("  ⚠️  Existing menu data will be updated")
        else:
            print("\n❌ Restaurant 'Aahar' not found in database")
            print("\nSearching for any active restaurants...")

            cursor.execute(f"""
                SELECT COUNT(*) as count FROM {SCHEMA}.restaurants
                WHERE deleted_at IS NULL AND status = 'active'
            """)
            total = cursor.fetchone()['count']
            print(f"  Total active restaurants in database: {total}")

            if total == 0:
                print("\n⚠️  No restaurants found. You may need to:")
                print("  1. Run the restaurant migration script first")
                print("  2. Or manually insert the restaurant record")

        cursor.close()
        conn.close()

    except Exception as e:
        print(f"\n❌ Error: {e}")


if __name__ == '__main__':
    print("="*60)
    print("Restaurant Database Check")
    print("="*60)
    check_restaurant()
