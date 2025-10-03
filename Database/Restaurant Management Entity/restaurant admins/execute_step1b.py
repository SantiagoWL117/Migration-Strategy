#!/usr/bin/env python3
"""
Execute Step 1b SQL via terminal (for Supabase MCP execution)
Reads the generated SQL and prints it for manual execution
"""

sql_file = "Database/Restaurant Management Entity/restaurant admins/step1b_insert_statements.sql"

print("=" * 80)
print("  Step 1b: Execute SQL Statements")
print("=" * 80)
print()

with open(sql_file, 'r', encoding='utf-8') as f:
    sql_content = f.read()

# Count statements
insert_count = sql_content.count("INSERT INTO")
print(f"[INFO] File contains {insert_count} INSERT statements")
print()

# Split into manageable chunks (100 inserts per chunk)
lines = sql_content.split('\n')

# Find BEGIN, TRUNCATE, and COMMIT positions
begin_idx = next(i for i, line in enumerate(lines) if 'BEGIN;' in line)
truncate_idx = next(i for i, line in enumerate(lines) if 'TRUNCATE' in line)
commit_idx = next(i for i, line in enumerate(lines) if 'COMMIT;' in line)

# Create 5 batches
batch_size = 100

# Calculate insert ranges
insert_lines = [i for i, line in enumerate(lines) if line.startswith('INSERT INTO')]
total_inserts = len(insert_lines)

print(f"[INFO] Total INSERTs: {total_inserts}")
print(f"[INFO] Will execute in batches of {batch_size}")
print()

# Output each batch to separate file
for batch_num in range(0, (total_inserts // batch_size) + 1):
    start_idx = batch_num * batch_size
    end_idx = min((batch_num + 1) * batch_size, total_inserts)
    
    if start_idx >= total_inserts:
        break
    
    start_line = insert_lines[start_idx]
    if end_idx < total_inserts:
        end_line = insert_lines[end_idx]
    else:
        end_line = commit_idx
    
    # Build batch SQL
    if batch_num == 0:
        # First batch includes BEGIN and TRUNCATE
        batch_lines = lines[:truncate_idx+2] + lines[start_line:end_line]
    else:
        batch_lines = lines[start_line:end_line]
    
    # Last batch includes COMMIT
    if end_idx >= total_inserts:
        batch_lines.append("COMMIT;")
    
    batch_sql = '\n'.join(batch_lines)
    
    # Write to file
    batch_file = f"Database/Restaurant Management Entity/restaurant admins/step1b_batch_{batch_num+1}.sql"
    with open(batch_file, 'w', encoding='utf-8') as f:
        f.write(batch_sql)
    
    print(f"[OK] Created {batch_file} ({end_idx - start_idx} inserts)")

print()
print("=" * 80)
print("  Batch files created - ready for MCP execution")
print("=" * 80)

