"""
Un-delete all soft-deleted French dishes (set deleted_at = NULL)
"""
import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from database import DatabaseManager

# French restaurant DB IDs
FRENCH_DB_IDS = [35, 540, 562, 570, 602, 614, 615, 616, 644, 681, 696, 712, 
                 716, 726, 727, 736, 743, 777, 795, 797, 798, 810, 816, 820, 822, 825]

def main():
    db = DatabaseManager()
    db.connect()
    
    try:
        db_ids_str = ','.join(map(str, FRENCH_DB_IDS))
        
        # Count soft-deleted dishes before un-deletion
        query_count = f"""
            SELECT COUNT(*) as deleted_count
            FROM menuca_v3.dishes d
            JOIN menuca_v3.restaurants r ON d.restaurant_id = r.id
            WHERE r.id IN ({db_ids_str})
              AND d.source_id IS NOT NULL
              AND d.deleted_at IS NOT NULL
        """
        db.cursor.execute(query_count)
        deleted_count = db.cursor.fetchone()['deleted_count']
        
        print("\n" + "="*80)
        print("UN-DELETING FRENCH DISHES")
        print("="*80)
        print(f"\nFound {deleted_count:,} soft-deleted dishes to restore")
        
        if deleted_count == 0:
            print("\n[INFO] No soft-deleted dishes found. Nothing to do.")
            return
        
        print("\nUn-deleting all soft-deleted French dishes (setting deleted_at = NULL)...")
        
        # Un-delete dishes (set deleted_at = NULL)
        query_undelete = f"""
            UPDATE menuca_v3.dishes
            SET deleted_at = NULL
            WHERE restaurant_id IN ({db_ids_str})
              AND source_id IS NOT NULL
              AND deleted_at IS NOT NULL
        """
        
        db.cursor.execute(query_undelete)
        rows_updated = db.cursor.rowcount
        db.conn.commit()
        
        print(f"\n[SUCCESS] Restored {rows_updated:,} dishes (deleted_at set to NULL)")
        
        # Verify
        query_verify = f"""
            SELECT COUNT(*) as active_count
            FROM menuca_v3.dishes d
            JOIN menuca_v3.restaurants r ON d.restaurant_id = r.id
            WHERE r.id IN ({db_ids_str})
              AND d.source_id IS NOT NULL
              AND d.deleted_at IS NULL
        """
        db.cursor.execute(query_verify)
        active_count = db.cursor.fetchone()['active_count']
        
        print(f"[VERIFY] Total active French dishes: {active_count:,}")
        
        if active_count == 3155 or active_count == 3158:
            print("[OK] All dishes restored successfully!")
        else:
            print(f"[WARNING] Expected ~3,155 dishes, but found {active_count:,}")
        
        print("="*80)
        
    finally:
        db.close()

if __name__ == "__main__":
    main()

