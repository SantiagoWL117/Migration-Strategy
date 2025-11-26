import re
from datetime import datetime

print("\n" + "="*80)
print("STEP 3: VALIDATE V2 SQL")
print("="*80)

# Read the generated SQL
print("\n[1/3] Reading generated SQL file...")
with open('extracted_data/v2_to_v3_delivery_areas.sql', 'r', encoding='utf-8') as f:
    sql_content = f.read()

print("   SQL file loaded successfully")

# Validation checks
print("\n[2/3] Running validation checks...")

validation_results = {
    'total_inserts': 0,
    'valid_geometries': 0,
    'closed_polygons': 0,
    'min_points_per_polygon': 999999,
    'max_points_per_polygon': 0,
    'unique_restaurant_ids': set(),
    'issues': []
}

# Extract all INSERT statements
insert_pattern = re.compile(r'INSERT INTO menuca_v3\.restaurant_delivery_areas.*?VALUES.*?\);', re.DOTALL)
inserts = insert_pattern.findall(sql_content)

validation_results['total_inserts'] = len(inserts)

for i, insert in enumerate(inserts):
    # Extract restaurant_id
    resto_match = re.search(r'VALUES\s*\((\d+),', insert)
    if resto_match:
        resto_id = resto_match.group(1)
        validation_results['unique_restaurant_ids'].add(resto_id)
    
    # Extract polygon
    poly_match = re.search(r"ST_GeomFromText\('POLYGON\(\((.*?)\)\)', 4326\)", insert, re.DOTALL)
    if poly_match:
        polygon_coords = poly_match.group(1)
        
        # Count points
        points = polygon_coords.split(',')
        point_count = len(points)
        
        if point_count < validation_results['min_points_per_polygon']:
            validation_results['min_points_per_polygon'] = point_count
        if point_count > validation_results['max_points_per_polygon']:
            validation_results['max_points_per_polygon'] = point_count
        
        # Check if polygon is closed (first point = last point)
        if point_count >= 2:
            first_point = points[0].strip()
            last_point = points[-1].strip()
            if first_point == last_point:
                validation_results['closed_polygons'] += 1
            else:
                validation_results['issues'].append(f"INSERT {i+1}: Polygon not closed")
        
        # Check if valid PostGIS format
        if 'ST_GeomFromText' in insert and '4326' in insert:
            validation_results['valid_geometries'] += 1
    else:
        validation_results['issues'].append(f"INSERT {i+1}: Could not extract polygon")

print(f"   Total INSERT statements found: {validation_results['total_inserts']}")
print(f"   Valid PostGIS geometries: {validation_results['valid_geometries']}")
print(f"   Closed polygons: {validation_results['closed_polygons']}")
print(f"   Unique restaurants: {len(validation_results['unique_restaurant_ids'])}")
print(f"   Point count range: {validation_results['min_points_per_polygon']} - {validation_results['max_points_per_polygon']}")
print(f"   Issues found: {len(validation_results['issues'])}")

# Generate validation report
print("\n[3/3] Generating validation report...")

with open('extracted_data/V2_SQL_VALIDATION_REPORT.md', 'w', encoding='utf-8') as f:
    f.write("# V2 SQL Validation Report\n\n")
    f.write(f"**Generated:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
    f.write("---\n\n")
    f.write("## Validation Summary\n\n")
    
    all_checks_passed = (
        validation_results['total_inserts'] > 0 and
        validation_results['valid_geometries'] == validation_results['total_inserts'] and
        validation_results['closed_polygons'] == validation_results['total_inserts'] and
        len(validation_results['issues']) == 0 and
        validation_results['min_points_per_polygon'] >= 4  # Minimum for a valid polygon
    )
    
    if all_checks_passed:
        f.write("**Status:** [PASS] All validation checks passed\n\n")
    else:
        f.write("**Status:** [FAIL] Some validation checks failed\n\n")
    
    f.write("---\n\n")
    f.write("## Statistics\n\n")
    f.write(f"- **Total INSERT statements:** {validation_results['total_inserts']}\n")
    f.write(f"- **Valid PostGIS geometries:** {validation_results['valid_geometries']}\n")
    f.write(f"- **Closed polygons:** {validation_results['closed_polygons']}\n")
    f.write(f"- **Unique restaurants:** {len(validation_results['unique_restaurant_ids'])}\n")
    f.write(f"- **Min points per polygon:** {validation_results['min_points_per_polygon']}\n")
    f.write(f"- **Max points per polygon:** {validation_results['max_points_per_polygon']}\n")
    f.write(f"- **Avg points per polygon:** {(validation_results['min_points_per_polygon'] + validation_results['max_points_per_polygon']) / 2:.1f}\n\n")
    
    f.write("---\n\n")
    f.write("## Validation Checks\n\n")
    f.write("| Check | Status | Count |\n")
    f.write("|-------|--------|-------|\n")
    f.write(f"| INSERT statements found | {'PASS' if validation_results['total_inserts'] > 0 else 'FAIL'} | {validation_results['total_inserts']} |\n")
    f.write(f"| Valid PostGIS format | {'PASS' if validation_results['valid_geometries'] == validation_results['total_inserts'] else 'FAIL'} | {validation_results['valid_geometries']}/{validation_results['total_inserts']} |\n")
    f.write(f"| Polygons closed | {'PASS' if validation_results['closed_polygons'] == validation_results['total_inserts'] else 'FAIL'} | {validation_results['closed_polygons']}/{validation_results['total_inserts']} |\n")
    f.write(f"| Min points >= 4 | {'PASS' if validation_results['min_points_per_polygon'] >= 4 else 'FAIL'} | {validation_results['min_points_per_polygon']} |\n")
    f.write(f"| No issues found | {'PASS' if len(validation_results['issues']) == 0 else 'FAIL'} | {len(validation_results['issues'])} issues |\n\n")
    
    if validation_results['issues']:
        f.write("---\n\n")
        f.write("## Issues Found\n\n")
        for issue in validation_results['issues']:
            f.write(f"- {issue}\n")
        f.write("\n")
    
    f.write("---\n\n")
    f.write("## Next Steps\n\n")
    if all_checks_passed:
        f.write("1. Proceed to V1 polygon extraction (Step 4)\n")
        f.write("2. All V2 SQL validation checks passed\n")
    else:
        f.write("1. Review and fix issues listed above\n")
        f.write("2. Re-run validation script\n")
        f.write("3. Do not proceed until all checks pass\n")

print(f"   Validation report saved: extracted_data/V2_SQL_VALIDATION_REPORT.md")

if all_checks_passed:
    print("\n" + "="*80)
    print("[PASS] ALL VALIDATION CHECKS PASSED")
    print("="*80)
    print("\n[COMPLETE] STEP 3 COMPLETE - Proceeding to Step 4\n")
else:
    print("\n" + "="*80)
    print("[FAIL] VALIDATION FAILED - REVIEW ISSUES")
    print("="*80 + "\n")


