#!/usr/bin/env python3
"""
Process all 194 V1 deals - deserialize BLOBs and generate SQL UPDATE statements
This will output SQL that can be executed via Supabase MCP
"""

import json
import sys
from deserialize_v1_deals_blobs import (
    deserialize_active_days,
    parse_active_dates
)
import phpserialize

# All 194 deals data (will be read from stdin or embedded)
def clean_php_string(php_str):
    """Clean PHP serialized string by unescaping quotes"""
    if not php_str:
        return php_str
    return php_str.replace('\\\"', '"').replace('\\"', '"')

def deserialize_field(field_str, field_type='array'):
    """Generic deserialize for PHP serialized fields"""
    if not field_str or field_str == '' or field_str == 'a:0:{}':
        return None
    
    try:
        field_str = clean_php_string(field_str)
        deserialized = phpserialize.loads(field_str.encode('utf-8'), decode_strings=True)
        
        if isinstance(deserialized, dict):
            values = [str(v) for v in deserialized.values() if v]
            return values if values else None
        elif isinstance(deserialized, list):
            return [str(v) for v in deserialized if v]
        else:
            return [str(deserialized)] if deserialized else None
    except Exception as e:
        print(f"  ⚠️ Deserialization error: {e}", file=sys.stderr)
        return None

def process_deal(deal):
    """Process a single deal and return UPDATE SQL"""
    deal_id = deal['id']
    
    # Deserialize each field
    exceptions_json = deserialize_field(deal.get('exceptions', ''))
    active_days_json = deserialize_active_days(deal.get('active_days', ''))
    items_json = deserialize_field(deal.get('items', ''))
    active_dates_json = parse_active_dates(deal.get('active_dates', ''))
    
    # Generate UPDATE SQL
    def to_json_str(obj):
        if obj is None:
            return 'NULL'
        return f"'{json.dumps(obj)}'::jsonb"
    
    sql = f"""UPDATE staging.v1_deals SET
  exceptions_json = {to_json_str(exceptions_json)},
  active_days_json = {to_json_str(active_days_json)},
  items_json = {to_json_str(items_json)},
  active_dates_json = {to_json_str(active_dates_json)}
WHERE id = {deal_id};"""
    
    return sql

def main():
    """Read deals from stdin and generate UPDATE statements"""
    
    print("-- Marketing & Promotions: V1 Deals BLOB Deserialization", file=sys.stderr)
    print("-- Processing all 194 deals from staging.v1_deals...", file=sys.stderr)
    print("", file=sys.stderr)
    
    # Read JSON array from stdin
    data = json.load(sys.stdin)
    deals = data if isinstance(data, list) else []
    
    print(f"-- Total deals to process: {len(deals)}", file=sys.stderr)
    print("", file=sys.stderr)
    
    success_count = 0
    error_count = 0
    
    print("-- Generated UPDATE statements for staging.v1_deals")
    print("-- Batch processing: 20 updates per batch for MCP execution")
    print("")
    
    batch = []
    batch_num = 1
    
    for idx, deal in enumerate(deals):
        try:
            sql = process_deal(deal)
            batch.append(sql)
            success_count += 1
            
            # Output batch every 20 statements
            if len(batch) >= 20:
                print(f"-- Batch {batch_num} (20 updates)")
                print('\n'.join(batch))
                print("")
                batch = []
                batch_num += 1
                
                if success_count % 50 == 0:
                    print(f"-- Progress: {success_count}/{len(deals)} deals processed", file=sys.stderr)
        
        except Exception as e:
            print(f"-- ❌ Error processing deal ID {deal.get('id', 'unknown')}: {e}", file=sys.stderr)
            error_count += 1
    
    # Output remaining batch
    if batch:
        print(f"-- Batch {batch_num} ({len(batch)} updates)")
        print('\n'.join(batch))
        print("")
    
    # Summary
    print("", file=sys.stderr)
    print(f"✅ Successfully processed: {success_count}/{len(deals)} deals", file=sys.stderr)
    if error_count > 0:
        print(f"❌ Errors: {error_count}", file=sys.stderr)
    
    success_rate = (success_count / len(deals) * 100) if len(deals) > 0 else 0
    print(f"📊 Success rate: {success_rate:.1f}%", file=sys.stderr)

if __name__ == "__main__":
    main()

