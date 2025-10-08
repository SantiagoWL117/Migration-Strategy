#!/usr/bin/env python3
"""
Generate ALL 194 UPDATE statements for BLOB deserialization
Single comprehensive script - reads all deals from a SQL export and generates batched SQL
"""
import json
import sys
import phpserialize

def clean(s):
    """Clean escaped quotes from SQL export"""
    if not s: return s
    return s.replace('\\\"', '"').replace('\\"', '"')

def deserialize_php(s):
    """Deserialize PHP serialized array"""
    if not s or s == '' or s == 'a:0:{}': 
        return None
    try:
        s = clean(s)
        deserialized = phpserialize.loads(s.encode('utf-8'), decode_strings=True)
        if isinstance(deserialized, dict):
            values = [str(v) for v in deserialized.values() if v]
            return values if values else None
        elif isinstance(deserialized, list):
            return [str(v) for v in deserialized if v]
        else:
            return [str(deserialized)] if deserialized else None
    except Exception as e:
        print(f"-- ERROR deserializing: {e}", file=sys.stderr)
        return None

def deserialize_days(s):
    """Convert PHP day numbers (1-7) to day names"""
    result = deserialize_php(s)
    if not result:
        return None
    day_map = {'1':'mon', '2':'tue', '3':'wed', '4':'thu', '5':'fri', '6':'sat', '7':'sun'}
    return [day_map.get(d, d) for d in result if d in day_map]

def generate_update(deal):
    """Generate UPDATE statement for a single deal"""
    deal_id = deal['id']
    
    # Deserialize each field
    exceptions = deserialize_php(deal.get('exceptions', ''))
    active_days = deserialize_days(deal.get('active_days', ''))
    items = deserialize_php(deal.get('items', ''))
    
    # Convert to JSONB strings
    def to_jsonb(obj):
        if obj is None:
            return 'NULL'
        return f"'{json.dumps(obj)}'::jsonb"
    
    return f"""UPDATE staging.v1_deals SET exceptions_json = {to_jsonb(exceptions)}, active_days_json = {to_jsonb(active_days)}, items_json = {to_jsonb(items)} WHERE id = {deal_id};"""

def main():
    """Process all deals from JSON input"""
    print("-- BLOB Deserialization: All 194 V1 Deals", file=sys.stderr)
    print("-- Processing deals from stdin...", file=sys.stderr)
    
    # Read JSON array from stdin
    deals = json.load(sys.stdin)
    
    print(f"-- Loaded {len(deals)} deals", file=sys.stderr)
    print("", file=sys.stderr)
    
    print("-- Marketing & Promotions: BLOB Deserialization for V1 Deals")
    print("-- Generated: 2025-10-08")
    print("-- Total deals: " + str(len(deals)))
    print("-- Fields: exceptions_json, active_days_json, items_json")
    print("")
    
    success = 0
    errors = 0
    batch_size = 30
    
    for i in range(0, len(deals), batch_size):
        batch = deals[i:i+batch_size]
        batch_num = (i // batch_size) + 1
        
        print(f"-- Batch {batch_num}: Deals {batch[0]['id']} to {batch[-1]['id']} ({len(batch)} deals)")
        
        for deal in batch:
            try:
                sql = generate_update(deal)
                print(sql)
                success += 1
            except Exception as e:
                print(f"-- ERROR processing deal {deal.get('id', 'unknown')}: {e}")
                errors += 1
        
        print("")  # Blank line between batches
        
        if (i + batch_size) % 90 == 0:  # Progress every 3 batches
            print(f"-- Progress: {success}/{len(deals)} deals processed", file=sys.stderr)
    
    # Summary
    print("", file=sys.stderr)
    print(f"✅ Successfully generated: {success}/{len(deals)} UPDATE statements", file=sys.stderr)
    if errors > 0:
        print(f"❌ Errors: {errors}", file=sys.stderr)
    
    success_rate = (success / len(deals) * 100) if len(deals) > 0 else 0
    print(f"📊 Success rate: {success_rate:.1f}%", file=sys.stderr)
    
    if success_rate < 100:
        print("⚠️ Some statements failed to generate!", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()

