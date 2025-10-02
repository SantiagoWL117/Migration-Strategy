#!/usr/bin/env python3
"""
Fix SQL Escaping Issues in v1_ingredients Batch Files

Fixes the triple quote problem: \''' → ''
This allows PostgreSQL to parse the SQL correctly.

Usage:
    python3 fix_ingredients_escaping.py
"""

import os
import glob
import re
from pathlib import Path

# Configuration
BATCH_DIR = Path(__file__).parent / "split_pg"
BACKUP_DIR = Path(__file__).parent / "split_pg_backup"
PATTERN = "menuca_v1_ingredients_batch_*.sql"

def fix_escaping(content):
    """
    Fix SQL escaping issues for PostgreSQL
    
    Patterns fixed:
    1. \' → '' (MySQL backslash-escaped quote → PostgreSQL doubled quote)
    2. \''' → '' (Triple quote corruption)
    """
    # First, handle the triple quote corruption directly
    content = content.replace("\\'\\'\\'", "''")
    
    # Then handle standard backslash-escaped quotes
    # But be careful not to touch actual backslashes in other contexts
    # Match \' but not \\' (which is an escaped backslash followed by quote)
    content = re.sub(r"(?<!\\)\\'", "''", content)
    
    return content


def backup_files():
    """Create backup of batch files before modification"""
    print("\n📦 Creating backup of batch files...")
    BACKUP_DIR.mkdir(exist_ok=True)
    
    batch_files = sorted(glob.glob(str(BATCH_DIR / PATTERN)))
    
    for batch_file in batch_files:
        backup_path = BACKUP_DIR / Path(batch_file).name
        with open(batch_file, 'r', encoding='utf-8') as f:
            content = f.read()
        with open(backup_path, 'w', encoding='utf-8') as f:
            f.write(content)
    
    print(f"✅ Backed up {len(batch_files)} files to {BACKUP_DIR}")


def fix_batch_files():
    """Fix escaping in all v1_ingredients batch files"""
    batch_files = sorted(glob.glob(str(BATCH_DIR / PATTERN)))
    
    if not batch_files:
        print(f"❌ No files found matching: {PATTERN}")
        return 0
    
    print(f"\n🔧 Fixing escaping in {len(batch_files)} batch files...")
    print("=" * 70)
    
    fixed_count = 0
    total_changes = 0
    
    for i, batch_file in enumerate(batch_files, 1):
        filename = Path(batch_file).name
        
        # Read original
        with open(batch_file, 'r', encoding='utf-8') as f:
            original = f.read()
        
        # Apply fixes
        fixed = fix_escaping(original)
        
        # Count changes
        changes = len([m for m in re.finditer(r"\\'", original)])
        
        if fixed != original:
            # Write fixed version
            with open(batch_file, 'w', encoding='utf-8') as f:
                f.write(fixed)
            
            fixed_count += 1
            total_changes += changes
            print(f"  [{i:2d}/{len(batch_files)}] {filename:50s} - Fixed {changes:3d} escapes")
        else:
            print(f"  [{i:2d}/{len(batch_files)}] {filename:50s} - No changes needed")
    
    print("=" * 70)
    print(f"\n✅ Fixed {fixed_count} files with {total_changes} total escaping corrections")
    
    return fixed_count


def analyze_before_fix():
    """Analyze issues before fixing"""
    print("\n🔍 Analyzing escaping issues...")
    print("=" * 70)
    
    batch_files = sorted(glob.glob(str(BATCH_DIR / PATTERN)))
    
    issue_count = 0
    files_with_issues = []
    
    for batch_file in batch_files:
        with open(batch_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Count problematic patterns
        triple_quotes = len(re.findall(r"\\'\\'\\'", content))
        backslash_quotes = len(re.findall(r"(?<!\\)\\'", content))
        
        total = triple_quotes + backslash_quotes
        
        if total > 0:
            filename = Path(batch_file).name
            files_with_issues.append(filename)
            print(f"  {filename:50s} - {total:4d} issues")
            issue_count += total
    
    print("=" * 70)
    print(f"\nFound {issue_count} escaping issues across {len(files_with_issues)} files")
    
    return issue_count


def main():
    """Main execution"""
    print("\n" + "=" * 70)
    print("🔧 V1_INGREDIENTS ESCAPING FIX SCRIPT")
    print("=" * 70)
    print(f"Batch Directory: {BATCH_DIR}")
    print(f"Pattern: {PATTERN}")
    
    # Step 1: Analyze
    issue_count = analyze_before_fix()
    
    if issue_count == 0:
        print("\n✅ No escaping issues found! All files are clean.")
        return 0
    
    # Step 2: Auto-proceed
    print(f"\n⚠️  Fixing {issue_count} escaping issues...")
    print("=" * 70)
    
    # Step 3: Backup
    backup_files()
    
    # Step 4: Fix
    fixed_count = fix_batch_files()
    
    # Step 5: Summary
    print("\n" + "=" * 70)
    print("📊 SUMMARY")
    print("=" * 70)
    print(f"Files analyzed: {len(glob.glob(str(BATCH_DIR / PATTERN)))}")
    print(f"Files with issues: {fixed_count}")
    print(f"Issues fixed: {issue_count}")
    print(f"Backup location: {BACKUP_DIR}")
    
    print("\n🎯 NEXT STEPS:")
    print("1. Truncate staging.v1_ingredients")
    print("2. Re-run bulk_reload_v1_data.py (v1_ingredients only)")
    print("3. Verify row count: Should be 53,367 rows")
    
    return 0


if __name__ == "__main__":
    import sys
    sys.exit(main())

