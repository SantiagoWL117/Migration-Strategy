import re

content = open('Database/Legacy Schemas/v1_restaurants_dump.sql', 'r', encoding='utf-8', errors='ignore').read()

# Find restaurant 968
m = re.search(r'\(968,', content)
chunk = content[m.start():m.start()+15000]  # Get more data

print("Testing different regex patterns:\n")

# Test 1
pattern1 = r'_binary \'s:(\d+):\\\\"(.+?)\\\\"'  # Using single quotes to avoid escaping issues
match1 = re.search(pattern1, chunk, re.DOTALL)
print(f"Pattern 1: {pattern1}")
print(f"  Match: {match1 is not None}")
if match1:
    print(f"  Length: {match1.group(1)}")
    print(f"  JSON start: {match1.group(2)[:100]}")

# Test 2 - simpler
pattern2 = r'_binary \'s:(\d+):'
match2 = re.search(pattern2, chunk)
print(f"\nPattern 2: {pattern2}")
print(f"  Match: {match2 is not None}")
if match2:
    print(f"  Length found: {match2.group(1)}")
    # Get everything after this until the closing quote
    start = match2.end()
    # Find the pattern that ends the BLOB: \\"')
    end_pattern = r'\\\\"\'[),;]'
    end_match = re.search(end_pattern, chunk[start:])
    print(f"  End pattern match: {end_match is not None}")
    if end_match:
        json_escaped = chunk[start:start+end_match.start()]
        print(f"  JSON length in chunk: {len(json_escaped)}")
        print(f"  JSON start: {json_escaped[:100]}")
        print(f"  JSON end: {json_escaped[-100:]}")
    else:
        # Show what we have at the end of the chunk
        print(f"  Chunk end (last 200 chars): {repr(chunk[-200:])}")

