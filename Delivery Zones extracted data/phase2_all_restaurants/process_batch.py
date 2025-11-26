#!/usr/bin/env python3
"""
Process a batch of restaurants for BLOB deserialization
This creates separate JSON files per batch for easier processing
"""

import json
import sys

if len(sys.argv) < 3:
    print("Usage: python process_batch.py <start_index> <end_index>")
    print("Example: python process_batch.py 0 30")
    sys.exit(1)

start_idx = int(sys.argv[1])
end_idx = int(sys.argv[2])

print(f"Processing batch: restaurants {start_idx+1} to {end_idx}")
print("="*60)

# Load filtered BLOB data (excludes 5 MVP restaurants from Phase 1)
with open('phase2_only_blob_delivery_schedule.json', 'r', encoding='utf-8') as f:
    all_schedules = json.load(f)

with open('phase2_only_blob_deliveryArea.json', 'r', encoding='utf-8') as f:
    all_areas = json.load(f)

with open('phase2_only_blob_fee.json', 'r', encoding='utf-8') as f:
    all_fees = json.load(f)

# Extract batch
batch_schedules = all_schedules[start_idx:end_idx]
batch_areas = all_areas[start_idx:end_idx]
batch_fees = all_fees[start_idx:end_idx]

# Save batch files
batch_name = f"batch_{start_idx+1}_{end_idx}"

with open(f'{batch_name}_blob_delivery_schedule.json', 'w', encoding='utf-8') as f:
    json.dump(batch_schedules, f, indent=2)

with open(f'{batch_name}_blob_deliveryArea.json', 'w', encoding='utf-8') as f:
    json.dump(batch_areas, f, indent=2)

with open(f'{batch_name}_blob_fee.json', 'w', encoding='utf-8') as f:
    json.dump(batch_fees, f, indent=2)

print(f"\n[OK] Created batch files:")
print(f"  - {batch_name}_blob_delivery_schedule.json ({len(batch_schedules)} restaurants)")
print(f"  - {batch_name}_blob_deliveryArea.json ({len(batch_areas)} restaurants)")
print(f"  - {batch_name}_blob_fee.json ({len(batch_fees)} restaurants)")
print(f"\nBatch ready for deserialization!")

