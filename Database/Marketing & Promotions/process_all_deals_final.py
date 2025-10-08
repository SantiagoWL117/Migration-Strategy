#!/usr/bin/env python3
"""
Final comprehensive processor for all 194 V1 deals
Takes deal IDs as input and generates SQL for batch execution
"""
import phpserialize, json, sys

def c(s): return s.replace('\\\"','"').replace('\\"','"') if s else s
def d(s):
    if not s or s=='' or s=='a:0:{}': return None
    try:
        r=phpserialize.loads(c(s).encode('utf-8'), decode_strings=True)
        if isinstance(r, dict): return [str(v) for v in r.values() if v] or None
        return [str(r)] if r else None
    except: return None

def days_convert(s):
    r=d(s)
    m={'1':'mon','2':'tue','3':'wed','4':'thu','5':'fri','6':'sat','7':'sun'}
    return [m.get(x,x) for x in r if x in m] if r else None

# Use direct SQL to regenerate all updates
print("-- Generating UPDATE statements for all 194 deals...")
print("-- Run this SQL to complete BLOB deserialization:")
print()
