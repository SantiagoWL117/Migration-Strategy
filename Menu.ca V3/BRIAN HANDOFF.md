# Combo Group ID 7: "Dips" - Complete Data

> **Restaurant:** Centertown Donair & Pizza (V3 ID: 131, V1 ID: 255)  
> **Last Updated:** 2025-12-09

---

## 1. COMBO_GROUPS Record

| Field | Value |
|-------|-------|
| **id** | 7 |
| **restaurant_id** | 131 |
| **name** | Dips |
| **number_of_items** | 1 |
| **display_header** | *(empty)* |
| **source_id** | 1494 |
| **created_at** | 2025-12-08 20:53:25 |
| **updated_at** | 2025-12-09 17:12:52 |
| **deleted_at** | NULL |

---

## 2. COMBO_GROUP_SECTIONS Record

| Field | Value |
|-------|-------|
| **id** | 13 |
| **combo_group_id** | 7 |
| **section_type** | sauce |
| **use_header** | Dips |
| **display_order** | 4 |
| **free_items** | 0 |
| **min_selection** | 0 |
| **max_selection** | 0 |
| **is_active** | true |

---

## 3. COMBO_MODIFIER_GROUPS Records (3 groups)

| ID | Section ID | Name | Type Code | is_selected | Source ID |
|----|------------|------|-----------|-------------|-----------|
| 131 | 13 | Dips | SA | ✅ **true** | 2043 |
| 132 | 13 | Wings Sauces | SA | false | 2051 |
| 133 | 13 | Sauces For Jesica Donair Poutine | SA | false | 4840 |

---

## 4. COMBO_MODIFIERS Records (12 modifiers)

### Group 131: "Dips" (default selection)

| ID | Name | Display Order |
|----|------|---------------|
| 801 | Creamy Garlic | 0 |
| 802 | Honey Garlic | 1 |
| 804 | Hot | 2 |
| 805 | B.B.Q | 3 |
| 807 | Marinara | 4 |

### Group 132: "Wings Sauces"

| ID | Name | Display Order |
|----|------|---------------|
| 808 | Honey Garlic | 0 |
| 810 | Hot | 1 |
| 811 | B.B.Q | 2 |
| 812 | Medium | 3 |
| 814 | Mild | 4 |

### Group 133: "Sauces For Jesica Donair Poutine"

| ID | Name | Display Order |
|----|------|---------------|
| 815 | Gravy | 0 |
| 817 | Donair Sauce | 1 |

---

## 5. COMBO_MODIFIER_PRICES Records (12 prices)

| Price ID | Modifier ID | Modifier Name | Size Variant | Price | Modifier Group |
|----------|-------------|---------------|--------------|-------|----------------|
| 1779 | 801 | Creamy Garlic | Standard | $1.00 | Dips |
| 1781 | 802 | Honey Garlic | Standard | $1.00 | Dips |
| 1784 | 804 | Hot | Standard | $1.00 | Dips |
| 1787 | 805 | B.B.Q | Standard | $1.00 | Dips |
| 1789 | 807 | Marinara | Standard | $1.00 | Dips |
| 1793 | 808 | Honey Garlic | Standard | $1.00 | Wings Sauces |
| 1795 | 810 | Hot | Standard | $1.00 | Wings Sauces |
| 1798 | 811 | B.B.Q | Standard | $1.00 | Wings Sauces |
| 1800 | 812 | Medium | Standard | $0.00 | Wings Sauces |
| 1803 | 814 | Mild | Standard | $0.00 | Wings Sauces |
| 1806 | 815 | Gravy | Standard | $0.00 | Sauces For Jesica Donair Poutine |
| 1808 | 817 | Donair Sauce | Standard | $0.00 | Sauces For Jesica Donair Poutine |

---

## 6. DISH_COMBO_GROUPS Records (10 dishes linked)

| Link ID | Dish ID | Dish Name | Course | is_active |
|---------|---------|-----------|--------|-----------|
| 24 | 133654 | 1 Topping | Pizza | ✅ |
| 27 | 133655 | 2 Toppings | Pizza | ✅ |
| 31 | 133669 | 2 Small Pizza Special | Twins Pizza Special | ✅ |
| 35 | 133670 | 2 Medium Pizza Special | Twins Pizza Special | ✅ |
| 39 | 133671 | 2 Large Pizza Special | Twins Pizza Special | ✅ |
| 7 | 133646 | Small Pizza and One Garlic Fingers | Specials | ✅ |
| 10 | 133647 | Medium Pizza and One Garlic Fingers | Specials | ✅ |
| 13 | 133648 | Large Pizza and One Garlic Fingers | Specials | ✅ |
| 4 | 133645 | Medium Pizza and Donairs | Specials | ✅ |
| 21 | 133652 | Large Pizza and Donair Special HIDE | Specials | ✅ |

---

## 7. Visual Structure

```
┌───────────────────────────────────────────────────────────────────────────────┐
│  COMBO GROUP: "Dips" (ID: 7, source_id: 1494)                                 │
│  restaurant_id: 131, number_of_items: 1                                       │
│  Linked to 10 dishes                                                          │
└───────────────────────────────────────┬───────────────────────────────────────┘
                                        │
                                        │ 1:N
                                        ▼
┌───────────────────────────────────────────────────────────────────────────────┐
│  SECTION (ID: 13): sauce                                                      │
│           use_header: "Dips"                                                  │
│           display_order: 4, min: 0, max: 0, free_items: 0                     │
└───────────────────────────────────────┬───────────────────────────────────────┘
                                        │
                                        │ 1:N
        ┌───────────────────────────────┼───────────────────────────────┐
        ▼                               ▼                               ▼
┌────────────────────┐    ┌─────────────────────────┐    ┌─────────────────────────────┐
│ Dips (ID: 131)     │    │ Wings Sauces (ID: 132)  │    │ Sauces For Jesica           │
│ type_code: SA      │    │ type_code: SA           │    │ Donair Poutine (ID: 133)    │
│ is_selected: ✅ YES │    │ is_selected: ❌ NO      │    │ type_code: SA               │
└────────┬───────────┘    └─────────────┬───────────┘    │ is_selected: ❌ NO          │
         │                              │                └─────────────┬───────────────┘
         │ 1:N                          │ 1:N                          │ 1:N
         ▼                              ▼                              ▼
┌────────────────────┐    ┌─────────────────────────┐    ┌─────────────────────────────┐
│ MODIFIERS:         │    │ MODIFIERS:              │    │ MODIFIERS:                  │
│ • Creamy Garlic $1 │    │ • Honey Garlic $1       │    │ • Gravy         $0          │
│ • Honey Garlic  $1 │    │ • Hot          $1       │    │ • Donair Sauce  $0          │
│ • Hot           $1 │    │ • B.B.Q        $1       │    └─────────────────────────────┘
│ • B.B.Q         $1 │    │ • Medium       $0       │
│ • Marinara      $1 │    │ • Mild         $0       │
└────────────────────┘    └─────────────────────────┘
```

---

## 8. Summary Statistics

| Metric | Count |
|--------|-------|
| **Combo Group Sections** | 1 |
| **Combo Modifier Groups** | 3 |
| **Combo Modifiers** | 12 |
| **Combo Modifier Prices** | 12 |
| **Linked Dishes** | 10 |

---

## 9. Other Tables (Empty for this combo group)

| Table | Records |
|-------|---------|
| combo_group_translations | 0 |
| combo_group_modifier_pricing | 0 |
| combo_modifier_placements | 0 |

---

## 10. Query to Retrieve This Data

```sql
-- Get complete combo group structure for ID 7
SELECT 
    cg.id as combo_group_id,
    cg.name as combo_group_name,
    cg.restaurant_id,
    cg.number_of_items,
    cg.source_id,
    cgs.id as section_id,
    cgs.section_type,
    cgs.use_header,
    cgs.display_order,
    cgs.free_items,
    cgs.min_selection,
    cgs.max_selection,
    cgs.is_active,
    cmg.id as modifier_group_id,
    cmg.name as modifier_group_name,
    cmg.type_code,
    cmg.is_selected,
    cmg.source_id as cmg_source_id,
    cm.id as modifier_id,
    cm.name as modifier_name,
    cm.display_order as modifier_order,
    cmp.id as price_id,
    cmp.size_variant,
    cmp.price
FROM menuca_v3.combo_groups cg
JOIN menuca_v3.combo_group_sections cgs ON cgs.combo_group_id = cg.id
JOIN menuca_v3.combo_modifier_groups cmg ON cmg.combo_group_section_id = cgs.id
JOIN menuca_v3.combo_modifiers cm ON cm.combo_modifier_group_id = cmg.id
JOIN menuca_v3.combo_modifier_prices cmp ON cmp.combo_modifier_id = cm.id
WHERE cg.id = 7
ORDER BY cgs.display_order, cmg.id, cm.display_order;
```

