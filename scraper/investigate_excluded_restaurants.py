#!/usr/bin/env python3
"""
Investigate why 16 restaurants from List 4 are excluded.
Check if they exist in database and what their CRM ID status is.
"""
import sys
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
    """Investigate excluded restaurants."""
    
    # List of excluded restaurants from extraction output
    excluded = [
        ("All Out Burger", "2560 Bank Street"),
        ("All Out Burger", "585 Montreal Road"),
        ("All Out Burger", "714 Gladstone Ave"),
        ("Aroy Thai", "1 Rideaucrest Drive"),
        ("Charm Thai Cuisine", "121 Preston St"),
        ("Dépanneur Généreux", "428 Rue Généreux"),
        ("Econo Pizza", "425, boul La Vérendrye E"),
        ("Lemongrass Thai Cuisine", "331 Elgin St"),
        ("Mozza Pizza Gatineau", "425, boul La Vérendrye E"),
        ("Papa Pizza Des Flandres", "22, rue des Flandres"),
        ("Papa Pizza Maloney", "253, boul Maloney"),
        ("Papa Pizza Val-Des-Monts", "1797, rte du Carrefour"),
        ("Poutinerie Québecurds Gatineau", "643 Boulevard Saint-René O"),
        ("Roulas Grecque et Pizza", "245, rue de Cannes"),
        ("Sushi Express Chambly", "886 ch de Chambly"),
        ("Ting's Kitchen", "3-701 Eagleson Rd")
    ]
    
    safe_print("=" * 100)
    safe_print("INVESTIGATING 16 EXCLUDED RESTAURANTS")
    safe_print("=" * 100)
    
    # Connect to database
    db = DatabaseManager()
    db.connect()
    
    results = []
    
    for name, address in excluded:
        safe_print(f"\n{'='*100}")
        safe_print(f"Restaurant: {name}")
        safe_print(f"Address: {address}")
        safe_print("-" * 100)
        
        # Search by name
        query = f"""
            SELECT 
                r.id AS db_id,
                r.name AS db_name,
                r.legacy_v1_id AS crm_v1_id,
                r.legacy_v2_id AS crm_v2_id,
                r.deleted_at,
                rl.street_address AS db_address
            FROM {SCHEMA}.restaurants r
            LEFT JOIN {SCHEMA}.restaurant_locations rl ON r.id = rl.restaurant_id
            WHERE LOWER(r.name) LIKE %s
            ORDER BY r.deleted_at IS NULL DESC, r.id
        """
        
        db.cursor.execute(query, (f"%{name.lower()}%",))
        matches = db.cursor.fetchall()
        
        if not matches:
            safe_print(f"[NOT FOUND] No restaurant found in database matching '{name}'")
            results.append({
                'name': name,
                'address': address,
                'status': 'NOT_FOUND',
                'db_id': None,
                'crm_v1_id': None,
                'crm_v2_id': None
            })
        else:
            safe_print(f"[FOUND] {len(matches)} match(es) found:")
            for match in matches:
                safe_print(f"  DB ID: {match['db_id']}")
                safe_print(f"  DB Name: {match['db_name']}")
                safe_print(f"  DB Address: {match['db_address']}")
                safe_print(f"  CRM V1 ID (legacy_v1_id): {match['crm_v1_id'] if match['crm_v1_id'] else '[MISSING]'}")
                safe_print(f"  CRM V2 ID (legacy_v2_id): {match['crm_v2_id'] if match['crm_v2_id'] else '[MISSING]'}")
                safe_print(f"  Deleted: {'YES' if match['deleted_at'] else 'NO'}")
                
                # Determine reason for exclusion
                if match['deleted_at']:
                    reason = "SOFT_DELETED"
                elif not match['crm_v1_id'] and not match['crm_v2_id']:
                    reason = "NO_CRM_ID"
                elif match['crm_v2_id'] and not match['crm_v1_id']:
                    reason = "V2_ONLY"
                else:
                    reason = "UNKNOWN"
                
                safe_print(f"  Exclusion Reason: {reason}")
                safe_print("")
                
                results.append({
                    'name': name,
                    'address': address,
                    'status': 'FOUND',
                    'db_id': match['db_id'],
                    'db_name': match['db_name'],
                    'db_address': match['db_address'],
                    'crm_v1_id': match['crm_v1_id'],
                    'crm_v2_id': match['crm_v2_id'],
                    'deleted': bool(match['deleted_at']),
                    'reason': reason
                })
    
    db.close()
    
    # Summary
    safe_print("\n" + "="*100)
    safe_print("SUMMARY OF EXCLUSION REASONS")
    safe_print("="*100)
    
    not_found = [r for r in results if r['status'] == 'NOT_FOUND']
    no_crm_id = [r for r in results if r.get('reason') == 'NO_CRM_ID']
    v2_only = [r for r in results if r.get('reason') == 'V2_ONLY']
    soft_deleted = [r for r in results if r.get('reason') == 'SOFT_DELETED']
    unknown = [r for r in results if r.get('reason') == 'UNKNOWN']
    
    safe_print(f"\nTotal Excluded: 16")
    safe_print(f"  NOT FOUND in database: {len(not_found)}")
    safe_print(f"  FOUND but NO CRM ID (legacy_v1_id): {len(no_crm_id)}")
    safe_print(f"  FOUND but V2 ONLY (has legacy_v2_id, no legacy_v1_id): {len(v2_only)}")
    safe_print(f"  FOUND but SOFT DELETED: {len(soft_deleted)}")
    safe_print(f"  UNKNOWN reason: {len(unknown)}")
    
    if not_found:
        safe_print(f"\n[NOT FOUND] Restaurants not in database:")
        for r in not_found:
            safe_print(f"  - {r['name']} | {r['address']}")
    
    if no_crm_id:
        safe_print(f"\n[NO CRM ID] Restaurants missing legacy_v1_id:")
        for r in no_crm_id:
            safe_print(f"  - {r['name']} (DB ID: {r['db_id']}) | {r['address']}")
    
    if v2_only:
        safe_print(f"\n[V2 ONLY] Restaurants with V2 ID only (not V1):")
        for r in v2_only:
            safe_print(f"  - {r['name']} (DB ID: {r['db_id']}, V2 ID: {r['crm_v2_id']}) | {r['address']}")
    
    if soft_deleted:
        safe_print(f"\n[SOFT DELETED] Restaurants marked as deleted:")
        for r in soft_deleted:
            safe_print(f"  - {r['name']} (DB ID: {r['db_id']}) | {r['address']}")
    
    safe_print("\n" + "="*100)
    safe_print("RECOMMENDATION")
    safe_print("="*100)
    safe_print("\n1. NOT FOUND restaurants:")
    safe_print("   - These need to be added to the database first")
    safe_print("   - May require manual research or client confirmation")
    safe_print("\n2. NO CRM ID restaurants:")
    safe_print("   - These exist in the database but don't have a CRM mapping")
    safe_print("   - Need to find them in menuadmin.menu.ca and update legacy_v1_id")
    safe_print("\n3. V2 ONLY restaurants:")
    safe_print("   - These are V2 restaurants, not V1")
    safe_print("   - Should NOT be in List 4 (V1 active clients)")
    safe_print("   - May need to be removed from active client list or moved to V2 list")
    safe_print("\n4. SOFT DELETED restaurants:")
    safe_print("   - These have been deleted from the system")
    safe_print("   - Need to be un-deleted first (set deleted_at = NULL)")
    safe_print("\n" + "="*100)

if __name__ == "__main__":
    main()



