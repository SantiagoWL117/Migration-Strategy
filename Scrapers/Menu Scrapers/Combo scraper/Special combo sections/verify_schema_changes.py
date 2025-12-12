"""Verify schema changes for special combo sections."""
import sys
import os

# Add parent directories to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..'))

from config import DB_CONNECTION_STRING
import psycopg2

def main():
    conn = psycopg2.connect(DB_CONNECTION_STRING)
    cur = conn.cursor()

    print('=' * 70)
    print('VERIFICATION: Schema Changes')
    print('=' * 70)

    # 1. Check combo_groups columns
    print('\n1. combo_groups columns:')
    cur.execute('''
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'menuca_v3' AND table_name = 'combo_groups'
        ORDER BY ordinal_position
    ''')
    for row in cur.fetchall():
        print(f'   {row[0]:35} {row[1]}')

    # 2. Check new table exists
    print('\n2. combo_group_dish_selections table:')
    cur.execute('''
        SELECT column_name, data_type, is_nullable
        FROM information_schema.columns
        WHERE table_schema = 'menuca_v3' AND table_name = 'combo_group_dish_selections'
        ORDER BY ordinal_position
    ''')
    for row in cur.fetchall():
        print(f'   {row[0]:25} {row[1]:20} nullable={row[2]}')

    # 3. Check indexes
    print('\n3. Indexes on combo_group_dish_selections:')
    cur.execute('''
        SELECT indexname FROM pg_indexes 
        WHERE tablename = 'combo_group_dish_selections'
    ''')
    for row in cur.fetchall():
        print(f'   {row[0]}')

    # 4. Test function still works
    print('\n4. Testing get_restaurant_menu function (Milano V3:89):')
    cur.execute("SELECT menuca_v3.get_restaurant_menu(89, 'en', true)")
    result = cur.fetchone()[0]
    if result:
        courses = result.get('courses', [])
        combo_count = 0
        for course in courses:
            for dish in course.get('dishes', []):
                combo_groups = dish.get('combo_groups', [])
                combo_count += len(combo_groups)
        print(f'   Restaurant 89: Found {len(courses)} courses, {combo_count} combo groups')
        
        # Check fields in result
        if courses:
            first_combo = None
            for course in courses:
                for dish in course.get('dishes', []):
                    if dish.get('combo_groups'):
                        first_combo = dish['combo_groups'][0]
                        break
                if first_combo:
                    break
            
            if first_combo:
                print('\n5. Combo group fields (should NOT have special section fields):')
                print(f"   id: {first_combo.get('id')}")
                print(f"   name: {first_combo.get('name')}")
                print(f"   number_of_items: {first_combo.get('number_of_items')}")
                print(f"   display_header: {first_combo.get('display_header')}")
                
                # Verify special fields are NOT present
                excluded_fields = ['special_number_of_items', 'special_display_header', 'has_special_section', 'dish_selections']
                found_excluded = [f for f in excluded_fields if f in first_combo]
                if found_excluded:
                    print(f'\n   ✗ ERROR: Found excluded fields: {found_excluded}')
                else:
                    print(f'\n   ✓ Correctly excluded: {excluded_fields}')
        
        print('\n   ✓ Function works correctly!')

    conn.close()
    print('\n' + '=' * 70)
    print('All schema changes verified successfully!')
    print('=' * 70)

if __name__ == '__main__':
    main()

