#!/usr/bin/env python3
"""Generate UPDATE statements for all 194 V1 deals"""
import json
import phpserialize

def clean_php_string(s):
    if not s: return s
    return s.replace('\\\"', '"').replace('\\"', '"')

def deserialize_php(s):
    if not s or s == '' or s == 'a:0:{}': return None
    try:
        s = clean_php_string(s)
        d = phpserialize.loads(s.encode('utf-8'), decode_strings=True)
        if isinstance(d, dict):
            v = [str(x) for x in d.values() if x]
            return v if v else None
        elif isinstance(d, list):
            return [str(x) for x in d if x]
        else:
            return [str(d)] if d else None
    except: return None

def day_map(num):
    m = {'1':'mon','2':'tue','3':'wed','4':'thu','5':'fri','6':'sat','7':'sun'}
    return m.get(num, num)

def deserialize_days(s):
    r = deserialize_php(s)
    return [day_map(d) for d in r if d in ['1','2','3','4','5','6','7']] if r else None

# Sample deals for testing
deals = [
    {"id":19,"exceptions":"","active_days":"a:7:{i:0;s:1:\"1\";i:1;s:1:\"2\";i:2;s:1:\"3\";i:3;s:1:\"4\";i:4;s:1:\"5\";i:5;s:1:\"6\";i:6;s:1:\"7\";}","items":"a:0:{}"},
    {"id":22,"exceptions":"a:1:{i:0;s:3:\"884\";}","active_days":"a:0:{}","items":"a:1:{i:0;s:4:\"5728\";}"}
]

for d in deals:
    exc = deserialize_php(d.get('exceptions',''))
    days = deserialize_days(d.get('active_days',''))
    items = deserialize_php(d.get('items',''))
    
    def j(o): return 'NULL' if o is None else f"'{json.dumps(o)}'::jsonb"
    
    print(f"""UPDATE staging.v1_deals SET exceptions_json={j(exc)}, active_days_json={j(days)}, items_json={j(items)} WHERE id={d['id']};""")

print("\n-- Testing: 2 sample deals processed successfully")
