#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Fix mojibake encoding issues in CSV files."""

import os

# Common mojibake patterns (UTF-8 misread as Windows-1252)
replacements = {
    'ΓÇ¥': '"',      # inch mark / right double quote
    'ΓÇ£': '"',      # left double quote
    "ΓÇÖ": "'",      # right single quote / apostrophe
    "ΓÇÿ": "'",      # left single quote
    'ΓÇô': '–',      # en dash
    'ΓÇö': '—',      # em dash
    '├á': 'à',
    '├â': 'ã',
    '├ó': 'â',
    '├⌐': 'é',
    '├¿': 'è',
    '├¬': 'ê',
    '├ë': 'É',
    '├»': 'ï',
    '├«': 'î',
    '├┤': 'ô',
    '├╢': 'ö',
    '├╣': 'ù',
    '├╗': 'û',
    '├╝': 'ü',
    '├º': 'ç',
    '├▒': 'ñ',
    '├æ': 'Ñ',
    '├¡': 'í',
    '├¢': 'ò',
}

# Files to process
files_to_fix = [
    'dishes partition/gap_generic_dishes.csv',
    'dishes partition/gap_french_in_name_en.csv',
    'dishes partition/gap_size_variants.csv',
    'dishes partition/gap_combo_deals.csv',
    'dishes partition/gap_numbered_items.csv',
]

total_fixed = 0

for filepath in files_to_fix:
    if not os.path.exists(filepath):
        print(f"Skipping {filepath} - not found")
        continue
    
    # Read the file (handle BOM)
    with open(filepath, 'r', encoding='utf-8-sig') as f:
        content = f.read()
    
    # Apply replacements
    fixed = content
    fixes_applied = 0
    for old, new in replacements.items():
        count = fixed.count(old)
        if count > 0:
            fixed = fixed.replace(old, new)
            fixes_applied += count
    
    # Write back
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(fixed)
    
    total_fixed += fixes_applied
    print(f"Fixed {filepath}: {fixes_applied} replacements")

print(f"\nTotal fixes applied: {total_fixed}")
