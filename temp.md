# Combo Groups & Combo Modifiers Schema Structure

---

## V2 Legacy Combo Structure Analysis

### CSV Record for Combo ID 259: "1 Large Pizza 1 Topping"

| Field | Value |
|-------|-------|
| `id` | 249 (record ID) |
| `group_id` | 259 (combo group ID) |
| `dish_title` | 1 |

---

### Parsed JSON Fields

#### 1. `min` - Minimum Selections Required

| Modifier Type | Min Value | Meaning |
|---------------|-----------|---------|
| crust | **1** | Must choose 1 crust |
| custom_ingredient | **1** | Must choose 1 topping |
| premium_toppings | 0 | No premium toppings required |
| dip, drink, extra, sauce, desert, dressing, side_dish, cook_method | "" | Not applicable |

#### 2. `max` - Maximum Selections Allowed

| Modifier Type | Max Value | Meaning |
|---------------|-----------|---------|
| crust | **1** | Can only choose 1 crust |
| custom_ingredient | **0** | 0 = unlimited or default |
| premium_toppings | 0 | No premium toppings allowed |
| dip, drink, extra, sauce, desert, dressing, side_dish, cook_method | "" | Not applicable |

#### 3. `free` - Number of Free Items

| Modifier Type | Free Value | Meaning |
|---------------|------------|---------|
| crust | 0 | Crust not free (included in base) |
| custom_ingredient | **1** | **1 topping is FREE** ✓ |
| premium_toppings | 0 | No free premium toppings |
| dip, drink, extra, sauce, desert, dressing, side_dish, cook_method | "" | Not applicable |

#### 4. `use_only_this_item_types_in_combo` - Item Type Codes

| Modifier Type | Type Code | Meaning |
|---------------|-----------|---------|
| crust | 1 | Use crust type 1 |
| custom_ingredient | 2 | Use ingredient type 2 |
| premium_toppings | 3 | Use premium type 3 |

#### 5. `use_price` - V2 Modifier Group IDs

This maps modifier types to their **V2 modifier_group IDs**:

| Modifier Type | V2 Modifier Group ID(s) | Notes |
|---------------|-------------------------|-------|
| dip | 573 | |
| crust | 570 | |
| drink | 583 | |
| extra | 569 | |
| sauce | 568, 572 | Two sauce groups |
| custom_ingredient | 571 | Value "3" (possibly size/variant) |

#### 6. `dishes_to_choose_from`

**NULL** - No specific dish selections defined (pizza is the main dish)

---

### Cross-Reference: Modifier Data from Dump Files

The modifier data you're looking for is spread across **3 tables**:

#### Source Files:
| File | Table | Contains |
|------|-------|----------|
| `modifier_groups_dump.sql` | `menu_v3_modifier_groups` | Group definitions (ID 570, 571) |
| `modifiers_name_dump.sql` | `menu_v3_modifier_names` | Modifier names + hash |
| `modifiers_dump.sql` | `menu_v3_modifiers` | Prices linked via hash |

---

### ✅ CRUST MODIFIERS (group_id: 570)

| modifier_id | hash | name | price |
|-------------|------|------|-------|
| 3334 | `495c4fd6` | **Thick Crust** | **0.00** |
| 3335 | `8df400d8` | **Thin Crust** | **0.00** |

---

### ✅ PIZZA TOPPINGS (group_id: 571)

| modifier_id | hash | name | price (S,M,L) |
|-------------|------|------|---------------|
| 3336 | `767af924` | **Extra Sauce** | **0.00, 0.00, 0.00** |
| 3337 | `2d8f5f5a` | **Beef Pepperoni** | **1.00, 2.00, 3.00** |
| 3338 | `5ccc1782` | **Beef** | **1.00, 2.00, 3.00** |
| 3339 | `e809d8ea` | **Sausage** | **1.00, 2.00, 3.00** |
| 3340 | `4d59c0a2` | **Beef Salami** | **1.00, 2.00, 3.00** |
| 3341 | `b58f98f7` | **Beef Bacon** | **1.00, 2.00, 3.00** |
| 3342 | `1e5f6738` | **Chicken** | **1.00, 2.00, 3.00** |
| 3343 | `5087c07e` | **Steak** | **1.00, 2.00, 3.00** |
| 3344 | `c0c079a8` | **Donair** | **1.00, 2.00, 3.00** |
| 3345 | `15d1e8e7` | **Ground Beef** | **1.00, 2.00, 3.00** |
| 3346 | `05c7fb49` | **Anchovies** | **1.00, 2.00, 3.00** |
| 3347 | `2de45218` | **Mushrooms** | **1.00, 2.00, 3.00** |
| 3348 | `7ca02acb` | **Onions** | **1.00, 2.00, 3.00** |
| 3349 | `525766fd` | **Tomatoes** | **1.00, 2.00, 3.00** |
| 3350 | `7c50eac7` | **Green Peppers** | **1.00, 2.00, 3.00** |
| 3351 | `83f61f93` | **Green Olives** | **1.00, 2.00, 3.00** |
| 3352 | `b4d0530b` | **Black Olives** | **1.00, 2.00, 3.00** |
| 3353 | `bc6527cc` | **Hot Peppers** | **1.00, 2.00, 3.00** |
| 3354 | `c68b217e` | **Feta** | **1.00, 2.00, 3.00** |

---

### How V2 Links This Data

```
┌──────────────────────────────┐
│   user_structure.csv         │
│   (Combo Configuration)      │
├──────────────────────────────┤
│   use_price:                 │
│     crust: {570: ""}         │ ──► modifier_group_id = 570
│     custom_ingredient:       │
│       {571: "3"}             │ ──► modifier_group_id = 571
└──────────────────────────────┘
              │
              ▼
┌──────────────────────────────┐
│  menu_v3_modifier_groups     │
├──────────────────────────────┤
│  570 → Crust Type            │
│  571 → Pizza Toppings        │
└──────────────────────────────┘
              │
              ▼
┌──────────────────────────────┐     ┌──────────────────────────────┐
│  menu_v3_modifiers           │     │  menu_v3_modifier_names      │
├──────────────────────────────┤     ├──────────────────────────────┤
│  id: 3334                    │     │  hash: 495c4fd6              │
│  group_id: 570               │ ◄──►│  name: Thick Crust           │
│  item_hash: 495c4fd6         │     │  restaurant_v2_id: 1670      │
│  price: 0.00                 │     └──────────────────────────────┘
└──────────────────────────────┘
```

---

### Visual Interpretation

```
┌─────────────────────────────────────────────────────────────┐
│          COMBO: "1 Large Pizza 1 Topping" (ID: 259)         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  📦 CRUST SELECTION (modifier_group: 570)                   │
│     ├── min: 1, max: 1, free: 0                             │
│     └── Must choose exactly 1 crust                         │
│                                                             │
│  🍕 TOPPINGS (modifier_group: 571)                          │
│     ├── min: 1, max: unlimited, free: 1                     │
│     └── 1 FREE topping included, extras cost $              │
│                                                             │
│  ⭐ PREMIUM TOPPINGS (type: 3)                              │
│     ├── min: 0, max: 0, free: 0                             │
│     └── Not included in this combo                          │
│                                                             │
│  🥤 OPTIONAL ADD-ONS (Available but not required):          │
│     ├── Dip (573)                                           │
│     ├── Drink (583)                                         │
│     ├── Extra (569)                                         │
│     └── Sauce (568, 572)                                    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Entity Relationship Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         combo_groups                            │
├─────────────────────────────────────────────────────────────────┤
│ PK  id                      bigint                              │
│ FK  restaurant_id           bigint        → restaurants         │
│     name                    text                                │
│     special_number_of_items integer                             │
│     special_display_header  varchar(255)                        │
│     has_special_section     boolean                             │
│     source_id               integer                             │
│     created_at              timestamptz                         │
│     updated_at              timestamptz                         │
│     deleted_at              timestamptz                         │
└───────────────────────────────┬─────────────────────────────────┘
                                │
            ┌───────────────────┼───────────────────┐
            │ 1:N               │ 1:N               │ 1:N
            ▼                   ▼                   ▼
┌───────────────────────┐ ┌─────────────────────────────────┐ ┌─────────────────────────────────────┐
│  dish_combo_groups    │ │ combo_group_dish_selections     │ │      combo_group_sections           │
├───────────────────────┤ ├─────────────────────────────────┤ ├─────────────────────────────────────┤
│ PK id          bigint │ │ PK id               integer     │ │ PK id                bigint         │
│ FK dish_id     bigint │ │ FK combo_group_id   integer     │ │ FK combo_group_id    bigint         │
│ FK combo_group bigint │ │ FK dish_id          integer     │ │    section_type      text           │
│    is_active   bool   │ │ FK course_id        integer     │ │    use_header        varchar(255)   │
└───────────┬───────────┘ │    size             smallint    │ │    display_order     smallint       │
            │             │    dish_display_name text       │ │    free_items        smallint       │
            │             │    created_at       timestamp   │ │    min_selection     smallint       │
            ▼             │    deleted_at       timestamp   │ │    max_selection     smallint       │
┌───────────────────────┐ └────────────┬────────────────────┘ │    is_active         boolean        │
│       dishes          │              │                      └──────────────┬──────────────────────┘
│  (is_combo = true)    │              ▼                                     │
└───────────────────────┘ ┌─────────────────────────────────┐                │ 1:N
                          │           dishes                │                ▼
                          │    (selectable in combo)        │ ┌─────────────────────────────────────┐
                          └─────────────────────────────────┘ │      combo_modifier_groups          │
                                                              ├─────────────────────────────────────┤
                                                              │ PK id                     bigint    │
                                                              │ FK combo_group_section_id bigint    │
                                                              │    name                   text      │
                                                              │    type_code              text      │
                                                              │    is_selected            boolean   │
                                                              │    source_id              integer   │
                                                              └──────────────┬──────────────────────┘
                                                                             │
                                                                             │ 1:N
                                                                             ▼
                                                              ┌─────────────────────────────────────┐
                                                              │         combo_modifiers             │
                                                              ├─────────────────────────────────────┤
                                                              │ PK id                     bigint    │
                                                              │ FK combo_modifier_group_id bigint   │
                                                              │    name                   text      │
                                                              │    display_order          smallint  │
                                                              └──────────────┬──────────────────────┘
                                                                             │
                                                                             │ 1:N
                                                                             ▼
                                                              ┌─────────────────────────────────────┐
                                                              │      combo_modifier_prices          │
                                                              ├─────────────────────────────────────┤
                                                              │ PK id                bigint         │
                                                              │ FK combo_modifier_id bigint         │
                                                              │    size_variant      text           │
                                                              │    price             numeric(10,2)  │
                                                              └─────────────────────────────────────┘
```

### Relationship Summary

```
restaurants (1) ──────────────────────────────────────────► (N) combo_groups
combo_groups (1) ─────────────────────────────────────────► (N) dish_combo_groups ──► dishes
combo_groups (1) ─────────────────────────────────────────► (N) combo_group_dish_selections ──► dishes, courses
combo_groups (1) ─────────────────────────────────────────► (N) combo_group_sections
combo_group_sections (1) ─────────────────────────────────► (N) combo_modifier_groups
combo_modifier_groups (1) ────────────────────────────────► (N) combo_modifiers
combo_modifiers (1) ──────────────────────────────────────► (N) combo_modifier_prices
```

---

## 1. `combo_groups` - Main Combo Definition

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NOT NULL | auto | Primary key |
| `restaurant_id` | bigint | NOT NULL | - | FK → restaurants |
| `name` | text | NOT NULL | - | Combo group name |
| `special_number_of_items` | integer | NULL | - | Number of items in special |
| `special_display_header` | varchar(255) | NULL | - | Header text for display |
| `has_special_section` | boolean | NULL | false | Whether has special section |
| `source_id` | integer | NULL | - | Legacy source ID |
| `created_at` | timestamptz | NULL | now() | Creation timestamp |
| `updated_at` | timestamptz | NULL | now() | Last update timestamp |
| `deleted_at` | timestamptz | NULL | - | Soft delete timestamp |

**Referenced by:**
- `dish_combo_groups` → Links dishes to this combo
- `combo_group_dish_selections` → Dishes selectable in this combo
- `combo_group_sections` → Sections within this combo

---

## 2. `dish_combo_groups` - Links Dishes to Combo Groups

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NOT NULL | auto | Primary key |
| `dish_id` | bigint | NOT NULL | - | FK → dishes (the combo dish) |
| `combo_group_id` | bigint | NOT NULL | - | FK → combo_groups |
| `is_active` | boolean | NULL | true | Whether link is active |

**Purpose:** Connects a dish (marked as `is_combo=true`) to its combo group configuration.

---

## 3. `combo_group_dish_selections` - Selectable Dishes in Combo

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | integer | NOT NULL | auto | Primary key |
| `combo_group_id` | integer | NOT NULL | - | FK → combo_groups |
| `dish_id` | integer | NOT NULL | - | FK → dishes (selectable dish) |
| `course_id` | integer | NULL | - | FK → courses (optional filter) |
| `size` | smallint | NULL | - | Size restriction |
| `dish_display_name` | text | NULL | - | Override display name |
| `created_at` | timestamp | NULL | now() | Creation timestamp |
| `deleted_at` | timestamp | NULL | - | Soft delete timestamp |

**Purpose:** Defines which dishes can be selected within a combo group.

---

## 4. `combo_group_sections` - Sections within Combo Groups

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NOT NULL | auto | Primary key |
| `combo_group_id` | bigint | NOT NULL | - | FK → combo_groups |
| `section_type` | text | NOT NULL | - | Type of section |
| `use_header` | varchar(255) | NOT NULL | - | Section header text |
| `display_order` | smallint | NOT NULL | - | Order in display |
| `free_items` | smallint | NOT NULL | 0 | Number of free items |
| `min_selection` | smallint | NOT NULL | 0 | Minimum selections required |
| `max_selection` | smallint | NOT NULL | 1 | Maximum selections allowed |
| `is_active` | boolean | NOT NULL | false | Whether section is active |

**Purpose:** Defines sections within a combo (e.g., "Choose your side", "Choose your drink").

---

## 5. `combo_modifier_groups` - Modifier Groups in Sections

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NOT NULL | auto | Primary key |
| `combo_group_section_id` | bigint | NOT NULL | - | FK → combo_group_sections |
| `name` | text | NOT NULL | - | Modifier group name |
| `type_code` | text | NULL | - | Type identifier |
| `is_selected` | boolean | NULL | false | Default selection state |
| `source_id` | integer | NULL | - | Legacy source ID |

**Purpose:** Groups of modifiers within a combo section (e.g., "Size", "Add-ons").

---

## 6. `combo_modifiers` - Individual Modifiers

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NOT NULL | auto | Primary key |
| `combo_modifier_group_id` | bigint | NOT NULL | - | FK → combo_modifier_groups |
| `name` | text | NOT NULL | - | Modifier name |
| `display_order` | smallint | NULL | 0 | Order in display |

**Purpose:** Individual modifier options (e.g., "Large", "Extra Cheese").

---

## 7. `combo_modifier_prices` - Prices for Combo Modifiers

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NOT NULL | auto | Primary key |
| `combo_modifier_id` | bigint | NOT NULL | - | FK → combo_modifiers |
| `size_variant` | text | NULL | - | Size variant (if applicable) |
| `price` | numeric(10,2) | NOT NULL | - | Price for this modifier |

**Purpose:** Pricing for combo modifiers, optionally by size variant.

---

## Data Flow Example

```
COMBO DISH: "Family Combo" (dish.is_combo = true)
    │
    └── dish_combo_groups
            │
            └── combo_groups: "Family Combo Configuration"
                    │
                    ├── combo_group_dish_selections:
                    │       - Pizza (any from Pizzas course)
                    │       - Pasta (any from Pasta course)
                    │
                    └── combo_group_sections:
                            │
                            ├── Section 1: "Choose your drink" (min:1, max:2)
                            │       └── combo_modifier_groups: "Drinks"
                            │               └── combo_modifiers:
                            │                       - Coke ($0.00)
                            │                       - Sprite ($0.00)
                            │                       - Juice ($1.50)
                            │
                            └── Section 2: "Choose your side" (min:1, max:1)
                                    └── combo_modifier_groups: "Sides"
                                            └── combo_modifiers:
                                                    - Fries ($0.00)
                                                    - Salad ($2.00)
                                                    - Onion Rings ($1.50)
```

