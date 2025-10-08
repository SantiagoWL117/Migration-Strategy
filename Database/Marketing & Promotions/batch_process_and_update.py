#!/usr/bin/env python3
"""
Process deals in batches - simpler approach using manual batch execution
This script generates SQL files that can be executed via MCP
"""
import json

# All 194 deal IDs (from SELECT id FROM staging.v1_deals ORDER BY id)
all_deal_ids = [
    19,22,24,25,26,27,29,31,33,34,35,36,38,39,40,43,46,47,48,49,50,51,53,54,55,56,60,65,69,70,
    72,73,76,77,79,82,83,87,88,89,90,91,92,93,94,95,97,98,100,101,102,103,105,106,107,108,110,
    111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,
    134,135,136,137,138,139,140,141,142,143,144,145,148,149,150,151,152,153,154,155,156,157,158,
    159,160,161,162,163,164,165,166,167,168,169,170,171,172,174,176,177,178,179,180,181,183,187,
    188,190,191,192,193,194,195,197,198,200,201,202,203,204,205,207,209,211,212,213,214,215,217,
    218,219,220,221,222,223,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240,
    241,242,243,244,245,246,247,248,249,250,251,252,253,254,255,256,257,258,261,262,263,264
]

print(f"Total deals: {len(all_deal_ids)}")

# Split into batches of 30
batch_size = 30
for i in range(0, len(all_deal_ids), batch_size):
    batch = all_deal_ids[i:i+batch_size]
    batch_num = (i // batch_size) + 1
    
    ids_str = ','.join(map(str, batch))
    
    print(f"\nBatch {batch_num}: {len(batch)} deals (IDs {batch[0]}-{batch[-1]})")
    print(f"SELECT json_agg(row_to_json(t))::text FROM (")
    print(f"  SELECT id, exceptions, active_days, items") 
    print(f"  FROM staging.v1_deals")
    print(f"  WHERE id IN ({ids_str})")
    print(f"  ORDER BY id")
    print(f") t;")

print(f"\n✅ Generated {(len(all_deal_ids) + batch_size - 1) // batch_size} batch queries")
print("\nNow fetch each batch via MCP and process with generate_all_194_updates.py")

