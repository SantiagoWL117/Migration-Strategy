# V1 Polygon Extraction Summary

**Generated:** 2025-11-25 17:19:21

---

## Summary

- **Target restaurants:** 3
- **Polygons extracted:** 3
- **Success rate:** 100.0%

---

## Restaurant Details

| V3 ID | V1 ID | Restaurant Name | Polygons | Status |
|-------|-------|-----------------|----------|--------|
| 7 | 89 | Imilio's Pizzeria | 1 | OK |
| 83 | 199 | Season's Pizza | 1 | OK |
| 147 | 280 | Pho Dau Bo Restaurant - Kitchener | 1 | OK |

---

## Source Data

V1 polygons extracted from deserialized JSON files:

- V1 ID 89: `phase2_all_restaurants/batch_1_30_deserialized_areas.json`
- V1 ID 199: `phase2_all_restaurants/batch_1_30_deserialized_areas.json`
- V1 ID 280: `phase2_all_restaurants/batch_31_60_deserialized_areas.json`

---

## Next Steps

1. Run validation script: `python extracted_data/validate_v1_sql.py`
2. Review validation report
3. Proceed to merge V2 and V1 SQL (Step 6)

