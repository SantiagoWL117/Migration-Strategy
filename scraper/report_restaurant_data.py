"""Generate detailed report for a specific restaurant."""
from database import DatabaseManager
from config import SCHEMA

def report_restaurant(restaurant_id):
    db = DatabaseManager()
    db.connect()

    print('=' * 80)
    print(f'RESTAURANT DATA REPORT - ID: {restaurant_id}')
    print('=' * 80)

    # Get restaurant info
    db.cursor.execute(f'''
        SELECT name, legacy_v1_id 
        FROM {SCHEMA}.restaurants 
        WHERE id = %s
    ''', (restaurant_id,))
    restaurant = db.cursor.fetchone()
    print(f'\nRestaurant: {restaurant["name"]}')
    print(f'CRM ID: {restaurant["legacy_v1_id"]}')

    # Get courses
    db.cursor.execute(f'''
        SELECT id, name, description, display_order
        FROM {SCHEMA}.courses
        WHERE restaurant_id = %s AND deleted_at IS NULL
        ORDER BY display_order
    ''', (restaurant_id,))
    courses = db.cursor.fetchall()

    print(f'\nTOTAL COURSES: {len(courses)}')

    for course in courses:
        print(f'\n' + '-' * 80)
        print(f'COURSE #{course["display_order"] + 1}: {course["name"]}')
        if course['description']:
            print(f'Description: {course["description"]}')
        
        # Get dishes for this course
        db.cursor.execute(f'''
            SELECT id, name, description, source_id, display_order
            FROM {SCHEMA}.dishes
            WHERE restaurant_id = %s AND course_id = %s AND deleted_at IS NULL
            ORDER BY display_order
        ''', (restaurant_id, course['id']))
        dishes = db.cursor.fetchall()
        
        print(f'  Dishes in this course: {len(dishes)}')
        
        for dish in dishes:
            print(f'\n  DISH: {dish["name"]}')
            print(f'     ID: {dish["id"]} | Source ID: {dish["source_id"]}')
            if dish['description']:
                print(f'     Description: {dish["description"][:100]}...')
            
            # Get dish prices
            db.cursor.execute(f'''
                SELECT size_variant, price, display_order
                FROM {SCHEMA}.dish_prices
                WHERE dish_id = %s AND deleted_at IS NULL
                ORDER BY display_order
            ''', (dish['id'],))
            prices = db.cursor.fetchall()
            
            if prices:
                print(f'     PRICES: ({len(prices)} variants)')
                for price in prices:
                    print(f'        - {price["size_variant"]}: ${price["price"]:.2f}')
            else:
                print(f'     PRICES: None found')
            
            # Get modifier groups
            db.cursor.execute(f'''
                SELECT id, name, is_required, min_selections, max_selections
                FROM {SCHEMA}.modifier_groups
                WHERE dish_id = %s
                ORDER BY display_order
            ''', (dish['id'],))
            mod_groups = db.cursor.fetchall()
            
            if mod_groups:
                print(f'     MODIFIER GROUPS: {len(mod_groups)}')
                for mg in mod_groups:
                    req = 'Required' if mg['is_required'] else 'Optional'
                    print(f'        Group: {mg["name"]} ({req}, Min:{mg["min_selections"]}, Max:{mg["max_selections"]})')
                    
                    # Get modifiers in this group
                    db.cursor.execute(f'''
                        SELECT dm.id, dm.name, dm.modifier_type
                        FROM {SCHEMA}.dish_modifiers dm
                        WHERE dm.modifier_group_id = %s
                        ORDER BY dm.display_order
                    ''', (mg['id'],))
                    modifiers = db.cursor.fetchall()
                    
                    for mod in modifiers:
                        # Get modifier prices
                        db.cursor.execute(f'''
                            SELECT size_variant, price
                            FROM {SCHEMA}.dish_modifier_prices
                            WHERE dish_modifier_id = %s
                            ORDER BY display_order
                        ''', (mod['id'],))
                        mod_prices = db.cursor.fetchall()
                        
                        price_str = ', '.join([f'{mp["size_variant"]}:${mp["price"]:.2f}' for mp in mod_prices]) if mod_prices else 'No price'
                        print(f'           - {mod["name"]} ({mod["modifier_type"]}) [{price_str}]')

    print('\n' + '=' * 80)

    # Summary statistics
    db.cursor.execute(f'''
        SELECT COUNT(DISTINCT c.id) as courses,
               COUNT(DISTINCT d.id) as dishes,
               COUNT(DISTINCT dp.id) as prices,
               COUNT(DISTINCT mg.id) as mod_groups,
               COUNT(DISTINCT dm.id) as modifiers
        FROM {SCHEMA}.restaurants r
        LEFT JOIN {SCHEMA}.courses c ON c.restaurant_id = r.id AND c.deleted_at IS NULL
        LEFT JOIN {SCHEMA}.dishes d ON d.restaurant_id = r.id AND d.deleted_at IS NULL
        LEFT JOIN {SCHEMA}.dish_prices dp ON dp.dish_id = d.id AND dp.deleted_at IS NULL
        LEFT JOIN {SCHEMA}.modifier_groups mg ON mg.dish_id = d.id
        LEFT JOIN {SCHEMA}.dish_modifiers dm ON dm.dish_id = d.id
        WHERE r.id = %s
    ''', (restaurant_id,))
    stats = db.cursor.fetchone()

    print(f'\nSUMMARY STATISTICS:')
    print(f'   Courses: {stats["courses"]}')
    print(f'   Dishes: {stats["dishes"]}')
    print(f'   Dish Prices: {stats["prices"]}')
    print(f'   Modifier Groups: {stats["mod_groups"]}')
    print(f'   Modifier Items: {stats["modifiers"]}')
    print('=' * 80)

    db.close()


if __name__ == "__main__":
    import sys
    restaurant_id = int(sys.argv[1]) if len(sys.argv) > 1 else 35
    report_restaurant(restaurant_id)

