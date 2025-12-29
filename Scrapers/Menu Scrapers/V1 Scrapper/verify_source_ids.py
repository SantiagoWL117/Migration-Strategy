"""
Verify that all 147 restaurants have dishes with source_id in menuca_v3.dishes
"""

import logging
from datetime import datetime
from pathlib import Path
import psycopg2

# Database connection string
DB_CONNECTION_STRING = "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres"

# All 147 restaurants (V3_ID, Name, Legacy_V1_ID)
ALL_RESTAURANTS = [
    (561, "Aahar The Taste of India", 781),
    (833, "All Out Burger", 1080),
    (841, "All Out Burger", 1088),
    (735, "Amicci Pizza", 973),
    (630, "Asia Garden Ottawa", 856),
    (69, "Aylmer BBQ", 183),
    (241, "Beneci Pizza", 383),
    (45, "Bobbie's Pizza & Subs", 143),
    (124, "Carlo's Pizza", 246),
    (72, "Cathay Restaurants", 187),
    (131, "Centertown Donair & Pizza", 255),
    (943, "Charm Thai Cuisine", 323),
    (641, "China Moon", 869),
    (196, "Colonnade Pizza", 334),
    (783, "Colonnade Pizza", 1025),
    (784, "Colonnade Pizza", 1027),
    (785, "Colonnade Pizza", 1028),
    (584, "Crispy's", 805),
    (806, "Crispy's Bank Street", 1050),
    (638, "Digby's Restaurant", 865),
    (792, "Dumpling Bowl", 1035),
    (28, "Eastview Pizza", 124),
    (1009, "Econo Pizza", 1095),
    (511, "Egg Roll Factory", 716),
    (211, "Erman Pizza", 350),
    (730, "Friendly Restaurant and Pizzeria", 968),
    (815, "Golden Center Pizza", 1059),
    (736, "Greber Pizza et Shawarma", 974),
    (519, "HaNoi Pho", 727),
    (22, "House of Lasagna", 117),
    (479, "iCook Pho You", 669),
    (7, "Imilio's Pizzeria", 89),
    (180, "Indian Punjabi Clay Oven", 318),
    (646, "JC Royal Thai Cuisine", 874),
    (328, "JN Pizza", 489),
    (636, "Joes Family Pizzeria", 863),
    (798, "Kabylie Pizza", 1042),
    (44, "Kiki Lebanese Pineview Pizza", 142),
    (984, "La Famiglia on the Danforth", 364),
    (727, "La Maison du Burger", 965),
    (721, "La Maison Pho", 959),
    (715, "La Poutinerie Ogilvie", 952),
    (1010, "Lemongrass Thai Cuisine", 219),
    (756, "Little Gyros Greek Grill", 998),
    (77, "Lorenzo's Pizzeria - Vanier", 192),
    (267, "Lucky Fortune", 413),
    (174, "Lucky King Take Out", 312),
    (12, "Mama Rosa", 94),
    (118, "Mano City Pizza", 238),
    (614, "Marina Pizza des Flandres", 838),
    (48, "Merivale Pizza & Wings", 146),
    (31, "Milano", 127),
    (55, "Milano", 161),
    (57, "Milano", 164),
    (59, "Milano", 172),
    (75, "Milano", 190),
    (88, "Milano", 204),
    (89, "Milano", 205),
    (90, "Milano", 206),
    (91, "Milano", 207),
    (92, "Milano", 208),
    (93, "Milano", 209),
    (95, "Milano", 211),
    (97, "Milano", 213),
    (123, "Milano", 245),
    (126, "Milano", 248),
    (190, "Milano", 328),
    (265, "Milano", 411),
    (349, "Milano", 512),
    (350, "Milano", 513),
    (565, "Milano", 785),
    (569, "Milano", 789),
    (586, "Milano", 807),
    (593, "Milano", 815),
    (601, "Milano", 824),
    (624, "Milano", 850),
    (651, "Milano", 879),
    (660, "Milano", 889),
    (680, "Milano", 913),
    (701, "Milano", 937),
    (749, "Milano", 987),
    (751, "Milano", 989),
    (818, "Milano", 1062),
    (819, "Milano", 1063),
    (821, "Milano", 1065),
    (835, "Milano", 1082),
    (837, "Milano", 1084),
    (840, "Milano", 1087),
    (842, "Milano", 1089),
    (205, "Mont Liban Bakery & Shawarma", 344),
    (1011, "Mozza Pizza Gatineau", 132),
    (644, "Mozza Pizza Hull", 872),
    (47, "Mr Mozzarella - Nepean", 145),
    (801, "Nachos Loco Gatineau", 1045),
    (790, "Nachos Loco Hull", 1033),
    (515, "Napolis", 721),
    (15, "New Mee Fung Restaurant", 101),
    (65, "Number One Chinese Take Out", 179),
    (714, "Ogilvie Pizza", 951),
    (807, "Oh My Grill", 1051),
    (681, "Oka's Hull", 914),
    (245, "Orchid Sushi", 387),
    (521, "Palermo Pizzeria", 729),
    (797, "Papa Burger", 1041),
    (822, "Papa Burger Maloney", 1066),
    (810, "Papa Grecque Cantley", 1054),
    (540, "Papa Grecque des Flandres", 758),
    (616, "Papa Grecque Maloney", 840),
    (437, "Papa Joe's Fried Chicken - Downtown", 612),
    (13, "Papa Joe's Pizza - Downtown", 95),
    (70, "Papa Pizza - Hull", 184),
    (602, "Papa Pizza Cantley", 825),
    (795, "Papa Pizza Chem. de Masson", 1039),
    (1012, "Papa Pizza Des Flandres", 231),
    (1013, "Papa Pizza Maloney", 346),
    (1014, "Papa Pizza Val-Des-Monts", 703),
    (712, "Patate Lou Lou", 948),
    (199, "Pho Bo Ga King - Somerset", 337),
    (139, "Pizza Bravo", 264),
    (562, "Pizza des Hautes Plaines", 782),
    (726, "Pizza Joanna", 964),
    (507, "Pizza Lovers Hunt Club", 712),
    (696, "Pizza Maisonneuve", 930),
    (829, "Pizzalicious", 1074),
    (716, "PizzaRama", 953),
    (1015, "Poutinerie Québecurds Gatineau", 1046),
    (789, "Poutinerie Québecurds Hull", 1032),
    (824, "Prima Pizza", 1069),
    (497, "Rangoli", 701),
    (109, "Restaurant Chez Gerry", 228),
    (106, "Restaurant Le Choix", 225),
    (1016, "Roulas Grecque et Pizza", 173),
    (745, "Sala Thai", 983),
    (83, "Season's Pizza", 199),
    (836, "Souvlaki Souvlaki", 1083),
    (595, "Supreme Pizzeria", 817),
    (711, "Supreme Pizzeria", 947),
    (1017, "Sushi Express Chambly", 511),
    (596, "Sushi Fleury", 818),
    (847, "Sushiyana", 1094),
    (84, "The Original Georgie's", 200),
    (941, "Ting's Kitchen", 694),
    (143, "Tony's Pizza", 275),
    (62, "Vanier Pizza & Subs", 175),
    (820, "Vieux Hull Pizza", 1064),
    (367, "Xtreme Pizza", 532),
    (985, "Yorgo's - Nepean", 547),
]

# Setup logging
script_dir = Path(__file__).parent
log_dir = script_dir / "logs"
log_dir.mkdir(exist_ok=True)

timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
log_file = log_dir / f"verify_source_ids_{timestamp}.log"

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(log_file, encoding='utf-8'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)


def main():
    """Verify source_id for all restaurants."""
    logger.info("=" * 80)
    logger.info("Verifying source_id in menuca_v3.dishes for 147 restaurants")
    logger.info("=" * 80)
    
    # Database connection
    conn = psycopg2.connect(DB_CONNECTION_STRING)
    cursor = conn.cursor()
    
    has_source_id = []
    no_source_id = []
    no_dishes = []
    
    for v3_id, name, v1_id in ALL_RESTAURANTS:
        # Count dishes with source_id
        cursor.execute("""
            SELECT 
                COUNT(*) as total_dishes,
                COUNT(source_id) as dishes_with_source_id
            FROM menuca_v3.dishes
            WHERE restaurant_id = %s AND deleted_at IS NULL
        """, (v3_id,))
        
        total, with_source_id = cursor.fetchone()
        
        if total == 0:
            logger.warning(f"[{v3_id}] {name} (V1:{v1_id}) - NO DISHES FOUND")
            no_dishes.append((v3_id, name, v1_id, 0, 0))
        elif with_source_id == 0:
            logger.warning(f"[{v3_id}] {name} (V1:{v1_id}) - {total} dishes, NONE have source_id")
            no_source_id.append((v3_id, name, v1_id, total, 0))
        elif with_source_id < total:
            logger.info(f"[{v3_id}] {name} (V1:{v1_id}) - {with_source_id}/{total} dishes have source_id (PARTIAL)")
            has_source_id.append((v3_id, name, v1_id, total, with_source_id))
        else:
            logger.info(f"[{v3_id}] {name} (V1:{v1_id}) - {with_source_id}/{total} dishes have source_id ✓")
            has_source_id.append((v3_id, name, v1_id, total, with_source_id))
    
    cursor.close()
    conn.close()
    
    # Summary
    logger.info("")
    logger.info("=" * 80)
    logger.info("SUMMARY")
    logger.info("=" * 80)
    logger.info(f"Restaurants with source_id: {len(has_source_id)}")
    logger.info(f"Restaurants WITHOUT source_id: {len(no_source_id)}")
    logger.info(f"Restaurants with NO dishes: {len(no_dishes)}")
    
    if no_source_id:
        logger.info("")
        logger.info("=" * 80)
        logger.info("RESTAURANTS WITHOUT SOURCE_ID (dishes exist but no source_id)")
        logger.info("=" * 80)
        for v3_id, name, v1_id, total, with_sid in no_source_id:
            logger.info(f"| {v3_id} | {name} | {v1_id} | {total} dishes |")
    
    if no_dishes:
        logger.info("")
        logger.info("=" * 80)
        logger.info("RESTAURANTS WITH NO DISHES")
        logger.info("=" * 80)
        for v3_id, name, v1_id, total, with_sid in no_dishes:
            logger.info(f"| {v3_id} | {name} | {v1_id} |")
    
    # Stats on partial source_id coverage
    partial = [(v3_id, name, v1_id, total, with_sid) 
               for v3_id, name, v1_id, total, with_sid in has_source_id 
               if with_sid < total]
    
    if partial:
        logger.info("")
        logger.info("=" * 80)
        logger.info("RESTAURANTS WITH PARTIAL SOURCE_ID COVERAGE")
        logger.info("=" * 80)
        for v3_id, name, v1_id, total, with_sid in partial:
            logger.info(f"| {v3_id} | {name} | {v1_id} | {with_sid}/{total} dishes |")
    
    logger.info("")
    logger.info(f"Log saved to: {log_file}")


if __name__ == "__main__":
    main()

