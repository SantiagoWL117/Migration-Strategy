#!/usr/bin/env python3
"""Clean up batch files by replacing \\n with actual newlines."""

from pathlib import Path

def clean_batch_files(batches_dir):
    """Replace literal \\n with actual newlines in all batch files."""
    batches_dir = Path(batches_dir)
    batch_files = sorted(batches_dir.glob("batch_*.sql"))
    
    print(f"Cleaning {len(batch_files)} batch files...")
    
    for batch_file in batch_files:
        with open(batch_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Replace literal \n with actual newlines
        cleaned = content.replace('\\n', '\n')
        
        with open(batch_file, 'w', encoding='utf-8') as f:
            f.write(cleaned)
        
        print(f"  ✓ {batch_file.name}")
    
    print(f"\n✅ All {len(batch_files)} files cleaned!")

if __name__ == "__main__":
    clean_batch_files("/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Devices & Infrastructure Entity/batches")

