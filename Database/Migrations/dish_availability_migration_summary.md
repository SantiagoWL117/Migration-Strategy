# Dish Availability Migration Summary

**Date**: January 8, 2026

## Objective

Migrated day-of-week visibility restrictions from V2 legacy database (`restaurants_dishes_customization.dish_info.show_on`) to V3 schema (`menuca_v3.dish_availability`).

## Source Data

- **V2 Table**: `restaurants_dishes_customization`
- **V2 Column**: `dish_info` (JSON) containing `show_on` object with day keys (`mon`, `tue`, `wed`, `thu`, `fri`, `sat`, `sun`)
- **Logic**: If a day key is missing from `show_on`, the dish is hidden on that day

### Example V2 `dish_info` Structure

```json
{
  "nuts": "y",
  "spicy": "y",
  "show_on": {
    "mon": "on",
    "sat": "on",
    "sun": "on",
    "thu": "on",
    "tue": "on",
    "wed": "on"
  },
  "calories": "2",
  "hot_level": "1",
  "vegetarian": "y",
  "gluten_free": "y"
}
```

In this example, `fri` is missing, so the dish is hidden on Friday.

## Target Schema

- **V3 Table**: `menuca_v3.dish_availability`
- **Columns**: 
  - `dish_id` (FK to `menuca_v3.dishes.id`)
  - `day_of_week` (smallint: 0=Sunday, 1=Monday, 2=Tuesday, 3=Wednesday, 4=Thursday, 5=Friday, 6=Saturday)
  - `is_hidden` (boolean)
- **Constraint**: Unique on `(dish_id, day_of_week)`

## Linking Method

```sql
menuca_v3.dishes.source_id = V2.restaurants_dishes_customization.dish_id
```

## Migration Statistics

| Metric | Value |
|--------|-------|
| V2 dishes with restrictions in dump | 118 |
| V2 dishes matched to V3 | 103 |
| Availability records inserted | 281 |
| Restaurants affected | 7 |

## Restaurants Migrated

| Restaurant | V3 ID | Dishes | Pattern | Days Hidden |
|------------|-------|--------|---------|-------------|
| Wandee Thai | 954 | 28 | Lunch menu - weekdays only | 0 (Sun), 6 (Sat) |
| Kirkwood Pizza | 950 | 9 | Daily specials - one day each | All except designated day |
| Little Gyros Greek Grill | 971 | 36 | Lunch Special + Deal of Day | Mixed patterns |
| La Nawab | 825 | 1 | Monday special | 0,2,3,4,5,6 |
| Capri Pizza | 977 | 1 | Saturday Kids Special | 0,1,2,3,4,5 |
| Imilio's Pizzeria | - | 27 | Lunch menu - weekdays only | 0 (Sun), 6 (Sat) |
| Milano | - | 1 | Saturday special | 0,1,2,3,4,5 |

## Files Created

- `Database/Migrations/dish_availability_migration.sql` - Executable migration script with ON CONFLICT handling

## V2 Restaurant Coverage

- **20 V2 restaurants** exist in V3 (identified by `legacy_v2_id IS NOT NULL`)
- **1,782 V2 dishes** in V3 total
- **1,554 dishes** linkable to V2 customization dump (source_id range 35-10666)
- **1 restaurant** (Pho Dau Bo - Kitchener) has newer dish IDs not in dump

## Day Mapping Reference

| V2 Key | V3 day_of_week | Day Name |
|--------|----------------|----------|
| `sun` | 0 | Sunday |
| `mon` | 1 | Monday |
| `tue` | 2 | Tuesday |
| `wed` | 3 | Wednesday |
| `thu` | 4 | Thursday |
| `fri` | 5 | Friday |
| `sat` | 6 | Saturday |

## Notes

- V2 dump dish_id range: 35-10666
- V3 source_id range: 7034-120577
- 16 V2 restricted dishes were not found in V3 (restaurants not migrated to V3)
- Migration uses `ON CONFLICT DO NOTHING` to prevent duplicate insertions
- **Updated 2026-01-08**: Added Imilio's Pizzeria (27 dishes) and Milano (1 dish) - now 100% coverage of V2 dishes in V3

