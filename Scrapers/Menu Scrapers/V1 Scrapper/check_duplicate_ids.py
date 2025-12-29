"""Check if multiple groups have the same modifier IDs with different names."""
import psycopg2

DB_CONNECTION_STRING = "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres"

def main():
    conn = psycopg2.connect(DB_CONNECTION_STRING)
    cur = conn.cursor()
    
    # Check for source_ids 46829, 46826, 46827, etc. across all groups for Little Gyros
    source_ids = ['46829', '46826', '46827', '46828', '46830', '46831', '46832', '53426']
    
    print("=" * 80)
    print("CHECKING DUPLICATE SOURCE IDS ACROSS GROUPS FOR LITTLE GYROS (V3: 756)")
    print("=" * 80)
    
    for source_id in source_ids:
        cur.execute("""
            SELECT mg.name as group_name, mg.id as group_id, m.name as modifier_name, m.source_id
            FROM menuca_v3.modifiers m
            JOIN menuca_v3.modifier_groups mg ON m.modifier_group_id = mg.id
            WHERE mg.restaurant_id = 756 AND m.source_id = %s
            ORDER BY mg.name
        """, (source_id,))
        
        results = cur.fetchall()
        
        if len(results) > 1:
            print(f"\n[DUPLICATE] Source ID {source_id} appears in {len(results)} groups:")
            for group_name, group_id, mod_name, sid in results:
                print(f"  - Group '{group_name}' (ID: {group_id}): '{mod_name}'")
        elif len(results) == 1:
            group_name, group_id, mod_name, sid = results[0]
            print(f"\n[SINGLE] Source ID {source_id}: '{mod_name}' in '{group_name}'")
        else:
            print(f"\n[NOT FOUND] Source ID {source_id}")
    
    cur.close()
    conn.close()

if __name__ == "__main__":
    main()






