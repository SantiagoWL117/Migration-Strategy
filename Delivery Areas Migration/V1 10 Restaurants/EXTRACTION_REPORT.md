# V1 Delivery Areas Extraction Report

**Generated:** 2025-11-28 11:24:50

## Summary

| Metric                | Value |
| --------------------- | ----- |
| Restaurants Processed | 10    |
| Restaurants with Data | 10    |
| Total Delivery Zones  | 11    |
| Errors                | 0     |

## Extracted Data

| V1 ID | V3 ID | Restaurant              | Zones | Coordinates |
| ----- | ----- | ----------------------- | ----- | ----------- |
| 231   | 1012  | Papa Pizza Des Flandres | 1     | 8           |
| 238   | 118   | Mano City Pizza         | 1     | 13          |
| 346   | 1013  | Papa Pizza Maloney      | 1     | 11          |
| 694   | 941   | Ting's Kitchen          | 1     | 9           |
| 805   | 584   | Crispy's                | 1     | 18          |
| 865   | 638   | Digby's Restaurant      | 1     | 18          |
| 914   | 681   | Oka's Hull              | 2     | 29          |
| 1050  | 806   | Crispy's Bank Street    | 1     | 18          |
| 1064  | 820   | Vieux Hull Pizza        | 1     | 12          |
| 1066  | 822   | Papa Burger Maloney     | 1     | 11          |

## Zone Details

### Papa Pizza Des Flandres

- **Zone 1**: 8 points

### Mano City Pizza

- **Zone 1**: 13 points

### Papa Pizza Maloney

- **Zone 1**: 11 points

### Ting's Kitchen

- **Zone 1**: 9 points

### Crispy's

- **Zone 1**: 18 points

### Digby's Restaurant

- **Zone 1**: 18 points

### Oka's Hull

- **Zone 1**: 6 points
- **Zone 2**: 23 points

### Crispy's Bank Street

- **Zone 1**: 18 points

### Vieux Hull Pizza

- **Zone 1**: 12 points

### Papa Burger Maloney

- **Zone 1**: 11 points

## Files Generated

| File                        | Description                |
| --------------------------- | -------------------------- |
| `v1_id_mappings.json`       | V1 to V3 ID mappings       |
| `v1_blob_deliveryArea.json` | Raw extracted BLOB data    |
| `deserialized_areas.json`   | Parsed polygon coordinates |
| `v1_10_migration.sql`       | V3 INSERT statements       |

## Next Steps

1. Review the extracted data in `deserialized_areas.json`
2. Execute `v1_10_migration.sql` against menuca_v3 database
3. Verify polygons render correctly on map
