#!/usr/bin/env python3
"""
Update legacy_v1_id (CRM IDs) for the 15 restaurants that were missing them.
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from database import DatabaseManager
from config import SCHEMA

def safe_print(text):
    """Print text safely handling Unicode encoding issues."""
    try:
        print(text)
    except UnicodeEncodeError:
        safe_text = text.encode('ascii', 'replace').decode('ascii')
        print(safe_text)

def main():
    # Mapping of DB ID to CRM ID extracted from HTML
    crm_mappings = {
        924: 1013,   # All Out Burger (2560 Bank Street)
        833: 1071,   # All Out Burger (585 Montreal Road)
        948: 1038,   # All Out Burger (714 Gladstone Ave)
        607: 830,    # Aroy Thai (1 Rideaucrest Drive)
        943: 323,    # Charm Thai Cuisine (121 Preston St)
        1009: 1095,  # Econo Pizza (425, boul La Vérendrye E)
        1010: 219,   # Lemongrass Thai Cuisine (331 Elgin St)
        1011: 132,   # Mozza Pizza Gatineau (425, boul La Vérendrye E)
        1012: 231,   # Papa Pizza Des Flandres (22, rue des Flandres)
        1013: 346,   # Papa Pizza Maloney (253, boul Maloney)
        1014: 703,   # Papa Pizza Val-Des-Monts (1797, rte du Carrefour)
        1015: 1046,  # Poutinerie Québecurds Gatineau (643 Boulevard Saint-René O)
        1016: 173,   # Roulas Grecque et Pizza (245, rue de Cannes)
        1017: 511,   # Sushi Express Chambly (886 ch de Chambly)
        941: 694     # Ting's Kitchen (3-701 Eagleson Rd)
    }
    
    db = DatabaseManager()
    db.connect()
    
    safe_print("=" * 80)
    safe_print("UPDATING CRM IDs FOR 15 RESTAURANTS")
    safe_print("=" * 80)
    safe_print("")
    
    updated_count = 0
    failed_count = 0
    
    for db_id, crm_id in crm_mappings.items():
        try:
            # First, get the restaurant name for logging
            query_name = f"""
                SELECT name
                FROM {SCHEMA}.restaurants
                WHERE id = %s
            """
            db.cursor.execute(query_name, (db_id,))
            result = db.cursor.fetchone()
            
            if not result:
                safe_print(f"[ERROR] Restaurant DB ID {db_id} not found in database")
                failed_count += 1
                continue
            
            restaurant_name = result['name']
            
            # Update the legacy_v1_id
            query_update = f"""
                UPDATE {SCHEMA}.restaurants
                SET legacy_v1_id = %s,
                    updated_at = NOW()
                WHERE id = %s
            """
            db.cursor.execute(query_update, (crm_id, db_id))
            db.conn.commit()
            
            safe_print(f"[OK] DB:{db_id:<4} | CRM:{crm_id:<4} | {restaurant_name}")
            updated_count += 1
            
        except Exception as e:
            safe_print(f"[ERROR] Failed to update DB ID {db_id}: {e}")
            db.conn.rollback()
            failed_count += 1
    
    safe_print("")
    safe_print("=" * 80)
    safe_print("UPDATE SUMMARY")
    safe_print("=" * 80)
    safe_print(f"Successfully updated: {updated_count} restaurants")
    safe_print(f"Failed: {failed_count} restaurants")
    safe_print("")
    safe_print("Next step: Re-run extract_list4_restaurants.py to regenerate list4_restaurants.json")
    safe_print("=" * 80)
    
    db.close()

if __name__ == "__main__":
    main()

