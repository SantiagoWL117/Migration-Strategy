#!/usr/bin/env python3
"""Process deals in batches and generate SQL for MCP execution"""
import json
import sys
import phpserialize

def clean(s):
    return s.replace('\\\"', '"').replace('\\"', '"') if s else s

def deser(s):
    if not s or s == '' or s == 'a:0:{}': return None
    try:
        d = phpserialize.loads(clean(s).encode('utf-8'), decode_strings=True)
        if isinstance(d, dict):
            v = [str(x) for x in d.values() if x]
            return v if v else None
        return [str(d)] if d else None
    except: return None

def days(s):
    r = deser(s)
    m = {'1':'mon','2':'tue','3':'wed','4':'thu','5':'fri','6':'sat','7':'sun'}
    return [m.get(d,d) for d in r if d in m] if r else None

deals = json.load(sys.stdin)
print(f"-- Processing {len(deals)} deals")
for d in deals:
    exc, dy, itm = deser(d.get('exceptions','')), days(d.get('active_days','')), deser(d.get('items',''))
    j = lambda o: 'NULL' if o is None else f"'{json.dumps(o)}'::jsonb"
    print(f"UPDATE staging.v1_deals SET exceptions_json={j(exc)}, active_days_json={j(dy)}, items_json={j(itm)} WHERE id={d['id']};")

