"""
Fix the report by adding addresses column properly
"""
import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from database import DatabaseManager
from config import SCHEMA
from pathlib import Path

# Restaurant mapping: DB ID -> (name, crm_id, dishes)
RESTAURANT_DATA = {
    7: ("Imilio's Pizzeria", 89, 131),
    8: ("Lucky Star Chinese Food", 90, 138),
    19: ("Milano INACTIVE Baxter - Iris - Cobden 3", 112, 119),
    31: ("Milano", 127, 166),
    42: ("Cypress Garden", 140, 166),
    47: ("Mr Mozzarella - Nepean", 145, 213),
    57: ("Milano", 164, 231),
    59: ("Milano", 172, 251),
    62: ("Vanier Pizza & Subs", 175, 155),
    65: ("Number One Chinese Take Out", 179, 122),
    69: ("Aylmer BBQ", 183, 221),
    72: ("Cathay Restaurants", 187, 150),
    74: ("Andiamo Pizzeria", 189, 165),
    83: ("Season's Pizza", 199, 168),
    87: ("Champa Thai Cuisine", 203, 82),
    89: ("Milano", 205, 197),
    90: ("Milano", 206, 160),
    91: ("Milano", 207, 239),
    93: ("Milano", 209, 246),
    95: ("Milano", 211, 237),
    117: ("Shawarma King", 237, 85),
    118: ("Mano City Pizza", 238, 223),
    119: ("Hung Mein", 239, 178),
    124: ("Carlo's Pizza", 246, 103),
    126: ("Milano", 248, 204),
    131: ("Centertown Donair & Pizza", 255, 68),
    147: ("Pho Dau Bo Restaurant - Kitchener", 280, 225),
    174: ("Lucky King Take Out", 312, 144),
    180: ("Indian Punjabi Clay Oven", 318, 116),
    190: ("Milano", 328, 165),
    197: ("Aahar The Taste of India", 335, 108),
    205: ("Mont Liban Bakery & Shawarma", 344, 123),
    241: ("Beneci Pizza", 383, 64),
    245: ("Orchid Sushi", 387, 140),
    248: ("Le Tandoor", 392, 116),
    260: ("Sushi Presse", 406, 177),
    269: ("Shaan Tandoori", 415, 117),
    349: ("Milano", 512, 196),
    350: ("Milano", 513, 141),
    486: ("Wandee Thai Cuisine Sept 2022", 686, 98),
    491: ("Light of India", 695, 66),
    502: ("New Hong Kong", 707, 185),
    511: ("Egg Roll Factory", 716, 103),
    515: ("Napolis", 721, 91),
    546: ("Burger Lovers", 764, 61),
    547: ("POS SIMPLICITY", 766, 61),
    561: ("Aahar The Taste of India", 781, 108),
    565: ("Milano", 785, 228),
    569: ("Milano", 789, 299),
    584: ("Crispy's", 805, 123),
    586: ("Milano", 807, 191),
    587: ("Milano", 808, 229),
    593: ("Milano", 815, 86),
    595: ("Supreme Pizzeria", 817, 112),
    596: ("Sushi Fleury", 818, 169),
    601: ("Milano", 824, 183),
    607: ("Aroy Thai", 830, 39),
    610: ("Milano", 833, 179),
    624: ("Milano", 850, 122),
    630: ("Asia Garden Ottawa", 856, 156),
    636: ("Joes Family Pizzeria", 863, 371),
    638: ("Digby's Restaurant", 865, 89),
    641: ("China Moon", 869, 157),
    646: ("JC Royal Thai Cuisine", 874, 152),
    647: ("Papaye Verte Call Centre", 875, 75),
    650: ("Pizza Run", 878, 133),
    651: ("Milano", 879, 321),
    660: ("Milano", 889, 167),
    662: ("La Maison Szechuan", 892, 89),
    679: ("Pizza Corner", 912, 134),
    680: ("Milano", 913, 306),
    688: ("Pizza Riverview", 921, 51),
}

def get_restaurant_addresses():
    """Get addresses for all restaurant IDs."""
    db = DatabaseManager()
    db.connect()
    
    try:
        ids_str = ','.join(map(str, RESTAURANT_DATA.keys()))
        query = f"""
            SELECT DISTINCT
                r.id as restaurant_id,
                COALESCE(
                    STRING_AGG(
                        DISTINCT rl.street_address, 
                        ', '
                    ),
                    'No address found'
                ) as address
            FROM {SCHEMA}.restaurants r
            LEFT JOIN {SCHEMA}.restaurant_locations rl ON r.id = rl.restaurant_id 
                AND rl.deleted_at IS NULL
            WHERE r.id IN ({ids_str})
            GROUP BY r.id
        """
        db.cursor.execute(query)
        results = db.cursor.fetchall()
        
        return {row['restaurant_id']: row['address'] or 'No address found' for row in results}
    finally:
        db.close()

def generate_table_rows():
    """Generate table rows with addresses."""
    addresses = get_restaurant_addresses()
    
    rows = []
    rows.append("| #   | Restaurant Name                          | Address                                    | DB ID | CRM ID | Dishes Completed |")
    rows.append("| --- | ---------------------------------------- | ------------------------------------------ | ----- | ------ | ---------------- |")
    
    for idx, (db_id, (name, crm_id, dishes)) in enumerate(sorted(RESTAURANT_DATA.items()), 1):
        address = addresses.get(db_id, 'No address found')
        # Truncate if too long
        if len(address) > 42:
            address = address[:39] + "..."
        rows.append(f"| {idx:<4} | {name:<40} | {address:<42} | {db_id:<6} | {crm_id:<7} | {dishes:<17} |")
    
    return '\n'.join(rows)

def main():
    report_file = Path('ENGLISH_SCRAPER_RESTAURANTS_REPORT.md')
    content = report_file.read_text(encoding='utf-8')
    
    # Replace the table section
    import re
    pattern = r'(\| #\s+\| Restaurant Name.*?\| Pizza Riverview.*?\|)'
    
    new_table = generate_table_rows()
    
    content = re.sub(pattern, new_table, content, flags=re.DOTALL)
    
    report_file.write_text(content, encoding='utf-8')
    print(f"\n[SUCCESS] Updated {report_file} with addresses")
    print(f"Updated table with addresses for {len(RESTAURANT_DATA)} restaurants")

if __name__ == "__main__":
    main()

