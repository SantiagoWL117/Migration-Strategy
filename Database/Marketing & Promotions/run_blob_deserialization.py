#!/usr/bin/env python3
"""
Marketing & Promotions - Run BLOB Deserialization
Reads staging.v1_deals, deserializes PHP BLOBs, updates JSONB columns

Based on successful Menu & Catalog migration (98.6% success rate, 144,377 BLOBs)
"""

import json
import sys
from deserialize_v1_deals_blobs import (
    deserialize_exceptions,
    deserialize_active_days,
    deserialize_items,
    parse_active_dates
)

# For this migration, we'll output SQL UPDATE statements
# These can be executed via Supabase MCP

def generate_update_sql(deal_id, exceptions_json, active_days_json, items_json, active_dates_json):
    """Generate SQL UPDATE statement for a single deal"""
    
    # Convert Python lists/dicts to JSON strings, handling None
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
    """
    This script reads from STDIN the deal records exported from staging.v1_deals
    and outputs SQL UPDATE statements to STDOUT
    
    Expected input format (tab-separated):
    id    exceptions    active_days    items    active_dates
    """
    
    print("-- Marketing & Promotions BLOB Deserialization", file=sys.stderr)
    print("-- Reading from staging.v1_deals...", file=sys.stderr)
    print("", file=sys.stderr)
    
    # SQL output header
    print("-- Generated UPDATE statements for staging.v1_deals")
    print("-- Deserializing BLOBs: exceptions, active_days, items, active_dates")
    print("")
    
    success_count = 0
    error_count = 0
    line_num = 0
    
    for line in sys.stdin:
        line_num += 1
        
        # Skip header line
        if line_num == 1 and line.startswith('id\t'):
            continue
        
        try:
            # Parse tab-separated input
            parts = line.strip().split('\t')
            if len(parts) < 5:
                print(f"-- ⚠️ Skipping line {line_num}: insufficient columns", file=sys.stderr)
                error_count += 1
                continue
            
            deal_id = int(parts[0])
            exceptions_blob = parts[1] if parts[1] and parts[1] != '\\N' else None
            active_days_text = parts[2] if parts[2] and parts[2] != '\\N' else None
            items_text = parts[3] if parts[3] and parts[3] != '\\N' else None
            active_dates_text = parts[4] if parts[4] and parts[4] != '\\N' else None
            
            # Deserialize each field
            exceptions_json = deserialize_exceptions(exceptions_blob) if exceptions_blob else None
            active_days_json = deserialize_active_days(active_days_text) if active_days_text else None
            items_json = deserialize_items(items_text) if items_text else None
            active_dates_json = parse_active_dates(active_dates_text) if active_dates_text else None
            
            # Generate UPDATE SQL
            sql = generate_update_sql(deal_id, exceptions_json, active_days_json, items_json, active_dates_json)
            print(sql)
            print("")
            
            success_count += 1
            
            if success_count % 50 == 0:
                print(f"-- Progress: {success_count} deals processed", file=sys.stderr)
        
        except Exception as e:
            print(f"-- ❌ Error processing line {line_num}: {e}", file=sys.stderr)
            error_count += 1
    
    # Summary
    print("", file=sys.stderr)
    print(f"✅ Successfully processed: {success_count} deals", file=sys.stderr)
    if error_count > 0:
        print(f"❌ Errors: {error_count}", file=sys.stderr)
    
    success_rate = (success_count / (success_count + error_count) * 100) if (success_count + error_count) > 0 else 0
    print(f"📊 Success rate: {success_rate:.1f}%", file=sys.stderr)
    
    if success_rate < 95:
        print(f"⚠️ Success rate below 95% - review errors!", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    if sys.stdin.isatty():
        print("⚠️ This script reads from STDIN", file=sys.stderr)
        print("", file=sys.stderr)
        print("Usage:", file=sys.stderr)
        print("  1. Export data from database:", file=sys.stderr)
        print("     psql -c \"COPY (SELECT id, encode(exceptions, 'hex'), active_days, items, active_dates FROM staging.v1_deals ORDER BY id) TO STDOUT\" > deals.tsv", file=sys.stderr)
        print("  2. Run this script:", file=sys.stderr)
        print("     python3 run_blob_deserialization.py < deals.tsv > updates.sql", file=sys.stderr)
        print("  3. Execute updates via Supabase MCP or psql", file=sys.stderr)
        print("", file=sys.stderr)
        print("Or pipe directly:", file=sys.stderr)
        print("  psql -c \"COPY (...) TO STDOUT\" | python3 run_blob_deserialization.py > updates.sql", file=sys.stderr)
        sys.exit(1)
    
    main()

