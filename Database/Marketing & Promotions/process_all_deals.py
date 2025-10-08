#!/usr/bin/env python3
"""
Process all V1 deals - deserialize BLOBs and generate UPDATE statements
This script reads sample data and can be used as a template for full processing
"""

import json
from deserialize_v1_deals_blobs import (
    deserialize_exceptions,
    deserialize_active_days,
    deserialize_items,
    parse_active_dates
)

# Sample data from staging.v1_deals (first 10 rows)
sample_deals = [
    {"id":19,"exceptions":"","active_days":"a:7:{i:0;s:1:\"1\";i:1;s:1:\"2\";i:2;s:1:\"3\";i:3;s:1:\"4\";i:4;s:1:\"5\";i:5;s:1:\"6\";i:6;s:1:\"7\";}","items":"a:0:{}","active_dates":""},
    {"id":22,"exceptions":"a:1:{i:0;s:3:\"884\";}","active_days":"a:0:{}","items":"a:1:{i:0;s:4:\"5728\";}","active_dates":"10/17,10/19,10/25"},
    {"id":24,"exceptions":"","active_days":"a:0:{}","items":"a:1:{i:0;s:4:\"6031\";}","active_dates":"05/19,05/22"},
]

def clean_php_string(php_str):
    """Clean PHP serialized string by unescaping quotes"""
    if not php_str:
        return php_str
    # Replace escaped quotes
    return php_str.replace('\\\"', '"').replace('\\"', '"')

def process_deal(deal):
    """Process a single deal and return UPDATE SQL"""
    deal_id = deal['id']
    
    # Clean and deserialize each field
    exceptions_str = clean_php_string(deal.get('exceptions', ''))
    active_days_str = clean_php_string(deal.get('active_days', ''))
    items_str = clean_php_string(deal.get('items', ''))
    active_dates_str = deal.get('active_dates', '')
    
    # Deserialize
    exceptions_json = None
    if exceptions_str and exceptions_str != 'a:0:{}':
        # For TEXT fields, encode to UTF-8 bytes for phpserialize
        try:
            import phpserialize
            deserialized = phpserialize.loads(exceptions_str.encode('utf-8'), decode_strings=True)
            if isinstance(deserialized, dict):
                exceptions_json = [str(v) for v in deserialized.values() if v]
        except:
            pass
    
    active_days_json = deserialize_active_days(active_days_str) if active_days_str and active_days_str != 'a:0:{}' else None
    
    items_json = None
    if items_str and items_str != 'a:0:{}':
        try:
            import phpserialize
            deserialized = phpserialize.loads(items_str.encode('utf-8'), decode_strings=True)
            if isinstance(deserialized, dict):
                items_json = [str(v) for v in deserialized.values() if v]
        except:
            pass
    
    active_dates_json = parse_active_dates(active_dates_str) if active_dates_str else None
    
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
    
    return sql, {
        'id': deal_id,
        'exceptions': exceptions_json,
        'active_days': active_days_json,
        'items': items_json,
        'active_dates': active_dates_json
    }

def main():
    print("# Processing V1 Deals - BLOB Deserialization Test\n")
    
    for deal in sample_deals:
        sql, result = process_deal(deal)
        print(f"## Deal ID {deal['id']}:")
        print(f"   Exceptions: {result['exceptions']}")
        print(f"   Active Days: {result['active_days']}")
        print(f"   Items: {result['items']}")
        print(f"   Active Dates: {result['active_dates']}")
        print(f"\n{sql}\n")

if __name__ == "__main__":
    main()

