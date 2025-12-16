
# Mapping for the scraping process:

We will use the legacy V1 CRM to scrape the data. Each restaurant in the phase 1 has a legacy_v1_id. This should be our primary criteria to determine which restaurant should be scraped in the v1 scraper.

## The restaurants to be scraped:

| V3 ID | V1 ID | Restaurant                          |
| ----- | ----- | ----------------------------------- |
| 7     | 89    | Imilio's Pizzeria                   |
| 8     | 90    | Lucky Star Chinese Food             |
| 12    | 94    | Mama Rosa                           |
| 13    | 95    | Papa Joe's Pizza - Downtown         |
| 15    | 101   | New Mee Fung Restaurant             |
| 22    | 117   | House of Lasagna                    |
| 28    | 124   | Eastview Pizza                      |
| 31    | 127   | Milano                              |
| 44    | 142   | Kiki Lebanese Pineview Pizza        |
| 45    | 143   | Bobbie's Pizza & Subs               |
| 47    | 145   | Mr Mozzarella - Nepean              |
| 48    | 146   | Merivale Pizza & Wings              |
| 55    | 161   | Milano                              |
| 57    | 164   | Milano                              |
| 59    | 172   | Milano                              |
| 62    | 175   | Vanier Pizza & Subs                 |
| 65    | 179   | Number One Chinese Take Out         |
| 69    | 183   | Aylmer BBQ                          |
| 70    | 184   | Papa Pizza - Hull                   |
| 72    | 187   | Cathay Restaurants                  |
| 75    | 190   | Milano                              |
| 77    | 192   | Lorenzo's Pizzeria - Vanier         |
| 83    | 199   | Season's Pizza                      |
| 84    | 200   | The Original Georgie's              |
| 87    | 203   | Champa Thai Cuisine                 |
| 88    | 204   | Milano                              |
| 89    | 205   | Milano                              |
| 90    | 206   | Milano                              |
| 91    | 207   | Milano                              |
| 92    | 208   | Milano                              |
| 93    | 209   | Milano                              |
| 95    | 211   | Milano                              |
| 97    | 213   | Milano                              |
| 105   | 224   | Ginkgo Garden                       |
| 106   | 225   | Restaurant Le Choix                 |
| 109   | 228   | Restaurant Chez Gerry               |
| 118   | 238   | Mano City Pizza                     |
| 119   | 239   | Hung Mein                           |
| 123   | 245   | Milano                              |
| 124   | 246   | Carlo's Pizza                       |
| 126   | 248   | Milano                              |
| 131   | 255   | Centertown Donair & Pizza           |
| 133   | 257   | Riverside Pizzeria                  |
| 139   | 264   | Pizza Bravo                         |
| 143   | 275   | Tony's Pizza                        |
| 147   | 280   | Pho Dau Bo Restaurant - Kitchener   |
| 160   | 294   | Hong Kong Chinese Food Takeout      |
| 174   | 312   | Lucky King Take Out                 |
| 180   | 318   | Indian Punjabi Clay Oven            |
| 190   | 328   | Milano                              |
| 196   | 334   | Colonnade Pizza                     |
| 199   | 337   | Pho Bo Ga King - Somerset           |
| 205   | 344   | Mont Liban Bakery & Shawarma        |
| 211   | 350   | Erman Pizza                         |
| 234   | 374   | New Mukut Restaurant Indian Cuisine |
| 241   | 383   | Beneci Pizza                        |
| 245   | 387   | Orchid Sushi                        |
| 267   | 413   | Lucky Fortune                       |
| 269   | 415   | Shaan Tandoori                      |
| 328   | 489   | JN Pizza                            |
| 349   | 512   | Milano                              |
| 350   | 513   | Milano                              |
| 367   | 532   | Xtreme Pizza                        |
| 376   | 542   | Sachi Sushi                         |
| 437   | 612   | Papa Joe's Fried Chicken - Downtown |
| 479   | 669   | iCook Pho You                       |
| 491   | 695   | Light of India                      |
| 497   | 701   | Rangoli                             |
| 502   | 707   | New Hong Kong                       |
| 507   | 712   | Pizza Lovers Hunt Club              |
| 511   | 716   | Egg Roll Factory                    |
| 515   | 721   | Napolis                             |
| 519   | 727   | HaNoi Pho                           |
| 521   | 729   | Palermo Pizzeria                    |
| 540   | 758   | Papa Grecque des Flandres           |
| 561   | 781   | Aahar The Taste of India            |
| 562   | 782   | Pizza des Hautes Plaines            |
| 565   | 785   | Milano                              |
| 569   | 789   | Milano                              |
| 584   | 805   | Crispy's                            |
| 586   | 807   | Milano                              |
| 593   | 815   | Milano                              |
| 595   | 817   | Supreme Pizzeria                    |
| 596   | 818   | Sushi Fleury                        |
| 601   | 824   | Milano                              |
| 602   | 825   | Papa Pizza Cantley                  |
| 614   | 838   | Marina Pizza des Flandres           |
| 616   | 840   | Papa Grecque Maloney                |
| 624   | 850   | Milano                              |
| 630   | 856   | Asia Garden Ottawa                  |
| 638   | 865   | Digby's Restaurant                  |
| 641   | 869   | China Moon                          |
| 644   | 872   | Mozza Pizza Hull                    |
| 646   | 874   | JC Royal Thai Cuisine               |
| 651   | 879   | Milano                              |
| 660   | 889   | Milano                              |
| 680   | 913   | Milano                              |
| 681   | 914   | Oka's Hull                          |
| 696   | 930   | Pizza Maisonneuve                   |
| 701   | 937   | Milano                              |
| 711   | 947   | Supreme Pizzeria                    |
| 712   | 948   | Patate Lou Lou                      |
| 714   | 951   | Ogilvie Pizza                       |
| 715   | 952   | La Poutinerie Ogilvie               |
| 716   | 953   | PizzaRama                           |
| 721   | 959   | La Maison Pho                       |
| 726   | 964   | Pizza Joanna                        |
| 727   | 965   | La Maison du Burger                 |
| 730   | 968   | Friendly Restaurant and Pizzeria    |
| 735   | 973   | Amicci Pizza                        |
| 736   | 974   | Greber Pizza et Shawarma            |
| 745   | 983   | Sala Thai                           |
| 749   | 987   | Milano                              |
| 751   | 989   | Milano                              |
| 756   | 998   | Little Gyros Greek Grill            |
| 783   | 1025  | Colonnade Pizza                     |
| 784   | 1027  | Colonnade Pizza                     |
| 785   | 1028  | Colonnade Pizza                     |
| 789   | 1032  | Poutinerie Québecurds Hull          |
| 790   | 1033  | Nachos Loco Hull                    |
| 792   | 1035  | Dumpling Bowl                       |
| 795   | 1039  | Papa Pizza Chem. de Masson          |
| 797   | 1041  | Papa Burger                         |
| 798   | 1042  | Kabylie Pizza                       |
| 801   | 1045  | Nachos Loco Gatineau                |
| 806   | 1050  | Crispy's Bank Street                |
| 807   | 1051  | Oh My Grill                         |
| 810   | 1054  | Papa Grecque Cantley                |
| 815   | 1059  | Golden Center Pizza                 |
| 816   | 1060  | Dépanneur Généreux                  |
| 818   | 1062  | Milano                              |
| 819   | 1063  | Milano                              |
| 820   | 1064  | Vieux Hull Pizza                    |
| 821   | 1065  | Milano                              |
| 822   | 1066  | Papa Burger Maloney                 |
| 824   | 1069  | Prima Pizza                         |
| 825   | 1070  | La Nawab V2                         |
| 829   | 1074  | Pizzalicious                        |
| 833   | 1080  | All Out Burger                      |
| 835   | 1082  | Milano                              |
| 836   | 1083  | Souvlaki Souvlaki                   |
| 837   | 1084  | Milano                              |
| 840   | 1087  | Milano                              |
| 841   | 1088  | All Out Burger                      |
| 842   | 1089  | Milano                              |
| 845   | 1092  | Mykonos Greek Grill                 |
| 846   | 1093  | Mykonos Greek Grill                 |
| 847   | 1094  | Sushiyana                           |
| 941   | 694   | Ting's Kitchen                      |
| 943   | 323   | Charm Thai Cuisine                  |
| 954   | 686   | Wandee Thai                         |
| 971   | 998   | Little Gyros Greek Grill            |
| 984   | 364   | La Famiglia on the Danforth         |
| 985   | 547   | Yorgo's - Nepean                    |
| 1009  | 1095  | Econo Pizza                         |
| 1010  | 219   | Lemongrass Thai Cuisine             |
| 1011  | 132   | Mozza Pizza Gatineau                |
| 1012  | 231   | Papa Pizza Des Flandres             |
| 1013  | 346   | Papa Pizza Maloney                  |
| 1014  | 703   | Papa Pizza Val-Des-Monts            |
| 1015  | 1046  | Poutinerie Québecurds Gatineau      |
| 1016  | 173   | Roulas Grecque et Pizza             |
| 1017  | 511   | Sushi Express Chambly               |

Restaurants that cannot be scraped (no V1 ID)
| V3 ID | V1 ID | Restaurant |
| ----- | ----- | ----------------------------------- |
| 981 | - | Al's Drive In |
| 973 | - | Capital Bites |
| 977 | - | Capri Pizza |
| 966 | - | Chicco Pizza de l'Hopital |
| 964 | - | Chicco Pizza Maloney |
| 963 | - | Chicco Pizza Shawarma Anger |
| 967 | - | Chicco Pizza St-Louis |
| 961 | - | Chicco Shawarma Cantley |
| 965 | - | Chicco Shawarma Maloney |
| 957 | - | Cosenza |
| 960 | - | Cuisine Bombay Indienne |
| 1021 | - | JJ's Shawarma |
| 950 | - | Kirkwood Pizza |
| 974 | - | Pachino Pizza |
| 976 | - | Pizza Marie |
| 952 | - | River Pizza |
| 1020 | - | Sushi Presse |

**Total: 180 restaurants** (excludes 6 Phase 2 restaurants: IDs 265, 607, 636, 924, 948, 949)

# V3 Menu Schema (menuca_v3)

## Core Menu Tables

### courses (Categories)

Menu categories/sections (e.g., "Appetizers", "Main Course", "Specials")

| Column           | Type                  | Description                         |
| ---------------- | --------------------- | ----------------------------------- |
| id               | BIGSERIAL             | Primary Key                         |
| uuid             | UUID                  | External identifier                 |
| restaurant_id    | BIGINT                | FK → restaurants.id                 |
| name             | VARCHAR(255) NOT NULL | Category name                       |
| description      | TEXT                  | Category description                |
| display_order    | INTEGER               | Sort order (default: 0)             |
| is_active        | BOOLEAN               | Active status (default: TRUE)       |
| image_url        | VARCHAR(500)          | Category image                      |
| parent_course_id | BIGINT                | FK → courses.id (for subcategories) |
| source_system    | VARCHAR(10)           | v1 or v2                            |
| source_id        | BIGINT                | Original system ID                  |
| legacy_v1_id     | INTEGER               | V1 migration reference              |
| legacy_v2_id     | INTEGER               | V2 migration reference              |
| created_at       | TIMESTAMPTZ           | Creation timestamp                  |
| updated_at       | TIMESTAMPTZ           | Last update timestamp               |
| deleted_at       | TIMESTAMPTZ           | Soft delete timestamp               |

---

### dishes (Menu Items)

Individual menu items/products

| Column               | Type                  | Description                           |
| -------------------- | --------------------- | ------------------------------------- |
| id                   | BIGSERIAL             | Primary Key                           |
| uuid                 | UUID                  | External identifier                   |
| restaurant_id        | BIGINT                | FK → restaurants.id                   |
| course_id            | BIGINT                | FK → courses.id                       |
| name                 | VARCHAR(255) NOT NULL | Dish name                             |
| description          | TEXT                  | Dish description                      |
| ingredients          | TEXT                  | Ingredient list                       |
| sku                  | VARCHAR(50)           | Stock keeping unit                    |
| display_order        | INTEGER               | Sort order (default: 0)               |
| image_url            | VARCHAR(500)          | Dish image                            |
| is_combo             | BOOLEAN               | Is combo meal (default: FALSE)        |
| has_customization    | BOOLEAN               | Has modifiers (default: FALSE)        |
| quantity             | VARCHAR(255)          | Quantity description                  |
| is_upsell            | BOOLEAN               | Upsell item (default: FALSE)          |
| is_active            | BOOLEAN               | Active status (default: TRUE)         |
| hide_option_enabled  | BOOLEAN               | Has day-based hiding (default: FALSE) |
| source_system        | VARCHAR(10)           | v1 or v2                              |
| source_id            | BIGINT                | Original system ID                    |
| legacy_v1_id         | INTEGER               | V1 migration reference                |
| legacy_v2_id         | INTEGER               | V2 migration reference                |
| notes                | TEXT                  | Internal notes                        |
| allergen_info        | JSONB                 | Allergen data                         |
| nutritional_info     | JSONB                 | Nutrition data                        |
| search_vector        | TSVECTOR              | Full-text search (generated)          |
| unavailable_until_at | TIMESTAMPTZ           | Temporary unavailability              |
| created_at           | TIMESTAMPTZ           | Creation timestamp                    |
| updated_at           | TIMESTAMPTZ           | Last update timestamp                 |
| deleted_at           | TIMESTAMPTZ           | Soft delete timestamp                 |

---

### dish_prices

Base dish pricing with size variants

| Column        | Type                   | Description                                 |
| ------------- | ---------------------- | ------------------------------------------- |
| id            | BIGSERIAL              | Primary Key                                 |
| dish_id       | BIGINT                 | FK → dishes.id                              |
| size_code     | VARCHAR(50)            | Size identifier (e.g., "SM", "MD", "LG")    |
| size_label    | VARCHAR(100)           | Size display name (e.g., "Small", "Medium") |
| price         | NUMERIC(10,2) NOT NULL | Price amount                                |
| is_default    | BOOLEAN                | Default size (default: FALSE)               |
| display_order | INTEGER                | Sort order (default: 0)                     |
| created_at    | TIMESTAMPTZ            | Creation timestamp                          |
| updated_at    | TIMESTAMPTZ            | Last update timestamp                       |

---

### modifier_groups

Groups of related modifiers (e.g., "Size", "Toppings", "Drinks")

| Column             | Type                  | Description                                 |
| ------------------ | --------------------- | ------------------------------------------- |
| id                 | BIGSERIAL             | Primary Key                                 |
| dish_id            | BIGINT                | FK → dishes.id                              |
| name               | VARCHAR(100) NOT NULL | Group name                                  |
| is_required        | BOOLEAN               | Selection required (default: FALSE)         |
| min_selections     | INTEGER               | Minimum selections (default: 0)             |
| max_selections     | INTEGER               | Maximum selections (default: 1)             |
| free_items         | SMALLINT              | Free items count (default: 0)               |
| display_order      | INTEGER               | Sort order (default: 0)                     |
| parent_modifier_id | BIGINT                | FK → modifier_groups.id (for nested groups) |
| instructions       | TEXT                  | User instructions                           |
| course_template_id | INTEGER               | FK to template                              |
| is_custom          | BOOLEAN               | Custom or template (default: TRUE)          |
| created_at         | TIMESTAMPTZ           | Creation timestamp                          |
| updated_at         | TIMESTAMPTZ           | Last update timestamp                       |
| deleted_at         | TIMESTAMPTZ           | Soft delete timestamp                       |

---

### dish_modifiers

Individual modifier options within a group

| Column            | Type         | Description                             |
| ----------------- | ------------ | --------------------------------------- |
| id                | BIGSERIAL    | Primary Key                             |
| uuid              | UUID         | External identifier                     |
| restaurant_id     | BIGINT       | FK → restaurants.id                     |
| dish_id           | BIGINT       | FK → dishes.id                          |
| modifier_group_id | BIGINT       | FK → modifier_groups.id                 |
| name              | VARCHAR(100) | Modifier name                           |
| modifier_type     | VARCHAR(50)  | Type classification                     |
| display_order     | INTEGER      | Sort order                              |
| is_default        | BOOLEAN      | Pre-selected (default: FALSE)           |
| is_included       | BOOLEAN      | Included in base price (default: FALSE) |
| source_system     | VARCHAR(10)  | v1 or v2                                |
| source_id         | BIGINT       | Original system ID                      |
| created_at        | TIMESTAMPTZ  | Creation timestamp                      |
| updated_at        | TIMESTAMPTZ  | Last update timestamp                   |
| deleted_at        | TIMESTAMPTZ  | Soft delete timestamp                   |

**Modifier Types:**

- `custom_ingredients` - Toppings, add-ons
- `extras` - Extra items
- `side_dishes` - Side options
- `drinks` - Beverage options
- `sauces` - Sauce choices
- `bread` - Bread/crust options
- `dressing` - Salad dressings
- `cooking_method` - Preparation style
- `other` - Miscellaneous

---

### dish_modifier_prices

Modifier pricing with size variants

| Column           | Type                   | Description                       |
| ---------------- | ---------------------- | --------------------------------- |
| id               | BIGSERIAL              | Primary Key                       |
| uuid             | UUID                   | External identifier               |
| dish_modifier_id | BIGINT                 | FK → dish_modifiers.id            |
| dish_id          | BIGINT                 | FK → dishes.id                    |
| restaurant_id    | BIGINT                 | FK → restaurants.id               |
| size_variant     | VARCHAR(50)            | Size (Small/Medium/Large/X-Large) |
| price            | NUMERIC(10,2) NOT NULL | Price amount (default: 0.00)      |
| display_order    | INTEGER                | Sort order (default: 1)           |
| is_active        | BOOLEAN                | Active status (default: TRUE)     |
| source_system    | VARCHAR(20)            | v1 or v2                          |
| created_at       | TIMESTAMPTZ            | Creation timestamp                |
| updated_at       | TIMESTAMPTZ            | Last update timestamp             |
| deleted_at       | TIMESTAMPTZ            | Soft delete timestamp             |

---

## Combo Tables

### 1. combo_groups

Root table for combo configurations. **Only table with restaurant_id**.

| Column          | Type          | Description              |
| --------------- | ------------- | ------------------------ |
| id              | BIGSERIAL     | Primary Key              |
| restaurant_id   | BIGINT        | FK → restaurants.id      |
| name            | TEXT NOT NULL | Combo group name         |
| number_of_items | INT           | Number of items in combo |
| display_header  | VARCHAR(255)  | Header text for display  |
| source_id       | INT           | V1 combo group ID        |
| created_at      | TIMESTAMPTZ   | Creation timestamp       |
| updated_at      | TIMESTAMPTZ   | Last update timestamp    |
| deleted_at      | TIMESTAMPTZ   | Soft delete timestamp    |

### 2. dish_combo_groups

Junction table for N:M relationship between dishes and combo groups.

| Column         | Type      | Description                   |
| -------------- | --------- | ----------------------------- |
| id             | BIGSERIAL | Primary Key                   |
| dish_id        | BIGINT    | FK → dishes.id                |
| combo_group_id | BIGINT    | FK → combo_groups.id          |
| is_active      | BOOLEAN   | Active status (default: TRUE) |
| UNIQUE         |           | (dish_id, combo_group_id)     |

### 3. combo_group_sections

Section types: bread, custom_ingredients, dressing, sauce, side_dish, extras, cooking_method

| Column         | Type                  | Description                                    |
| -------------- | --------------------- | ---------------------------------------------- |
| id             | BIGSERIAL             | Primary Key                                    |
| combo_group_id | BIGINT                | FK → combo_groups.id                           |
| section_type   | TEXT NOT NULL         | br_id, ci_id, dr_id, sa_id, sd_id, e_id, cm_id |
| use_header     | VARCHAR(255) NOT NULL | Section header text                            |
| display_order  | SMALLINT NOT NULL     | Sort order                                     |
| free_items     | SMALLINT NOT NULL     | Free items count (default: 0)                  |
| min_selection  | SMALLINT NOT NULL     | Minimum selections (default: 0)                |
| max_selection  | SMALLINT NOT NULL     | Maximum selections (default: 1)                |
| is_active      | BOOLEAN NOT NULL      | Active status (default: FALSE)                 |

### 4. combo_modifier_groups

Groups like "Crust Type", "Toppings", etc.

| Column                 | Type          | Description                              |
| ---------------------- | ------------- | ---------------------------------------- |
| id                     | BIGSERIAL     | Primary Key                              |
| combo_group_section_id | BIGINT        | FK → combo_group_sections.id             |
| name                   | TEXT NOT NULL | Group name                               |
| type_code              | TEXT          | RADIO or CHECKBOX                        |
| is_selected            | BOOLEAN       | Was this checked in V1? (default: FALSE) |
| source_id              | INT           | V1 modifier group ID                     |

### 5. combo_modifiers

Individual modifier items (Regular Crust, Thick Crust, etc.)

| Column                  | Type          | Description                   |
| ----------------------- | ------------- | ----------------------------- |
| id                      | BIGSERIAL     | Primary Key                   |
| combo_modifier_group_id | BIGINT        | FK → combo_modifier_groups.id |
| name                    | TEXT NOT NULL | Modifier name                 |
| display_order           | SMALLINT      | Sort order (default: 0)       |

### 6. combo_modifier_prices

Prices per size variant.

| Column            | Type                   | Description                             |
| ----------------- | ---------------------- | --------------------------------------- |
| id                | BIGSERIAL              | Primary Key                             |
| combo_modifier_id | BIGINT                 | FK → combo_modifiers.id                 |
| size_variant      | TEXT                   | Small, Medium, Large, X-Large, Standard |
| price             | NUMERIC(10,2) NOT NULL | Price amount                            |

### 7. dishes.hide_option_enabled (Column Added to Existing Table)

Boolean flag on the `dishes` table to mark dishes that have hide-on-days functionality enabled.

| Column              | Type             | Description                                         |
| ------------------- | ---------------- | --------------------------------------------------- |
| hide_option_enabled | BOOLEAN NOT NULL | TRUE if dish uses day-based hiding (default: FALSE) |

### 8. dish_availability

Stores which days a dish is hidden (for "Hide Dish On" functionality).

| Column      | Type              | Description                            |
| ----------- | ----------------- | -------------------------------------- |
| id          | BIGSERIAL         | Primary Key                            |
| dish_id     | BIGINT            | FK → dishes.id (ON DELETE CASCADE)     |
| day_of_week | SMALLINT NOT NULL | 0=Sunday, 1=Monday...6=Saturday        |
| is_hidden   | BOOLEAN NOT NULL  | Whether dish is hidden (default: TRUE) |
| created_at  | TIMESTAMPTZ       | Creation timestamp                     |
| UNIQUE      |                   | (dish_id, day_of_week)                 |

**How They Work Together:**

1. `dishes.hide_option_enabled = TRUE` → dish has day-based hiding enabled
2. `dish_availability` rows → specify WHICH days the dish is hidden

**Day of Week Mapping:**

| Value | Day       |
| ----- | --------- |
| 0     | Sunday    |
| 1     | Monday    |
| 2     | Tuesday   |
| 3     | Wednesday |
| 4     | Thursday  |
| 5     | Friday    |
| 6     | Saturday  |

**Usage Examples:**

```sql
-- Enable hide option for a dish and hide on Mondays
UPDATE menuca_v3.dishes SET hide_option_enabled = TRUE WHERE id = 12345;
INSERT INTO menuca_v3.dish_availability (dish_id, day_of_week, is_hidden)
VALUES (12345, 1, TRUE);

-- Hide dish on weekends
UPDATE menuca_v3.dishes SET hide_option_enabled = TRUE WHERE id = 12345;
INSERT INTO menuca_v3.dish_availability (dish_id, day_of_week, is_hidden)
VALUES (12345, 0, TRUE), (12345, 6, TRUE);

-- Get visible dishes for current day (checks both flags)
SELECT d.* FROM menuca_v3.dishes d
WHERE d.restaurant_id = 680 AND d.is_active = TRUE
  AND (
      d.hide_option_enabled = FALSE  -- No hiding configured
      OR NOT EXISTS (
          SELECT 1 FROM menuca_v3.dish_availability da
          WHERE da.dish_id = d.id
            AND da.day_of_week = EXTRACT(DOW FROM CURRENT_TIMESTAMP)
            AND da.is_hidden = TRUE
      )
  );
```

**V1 HTML ID Mapping for Scraper:**

| V1 Value | day_of_week |
| -------- | ----------- |
| mon      | 1           |
| tue      | 2           |
| wed      | 3           |
| thu      | 4           |
| fri      | 5           |
| sat      | 6           |
| sun      | 0           |

## FK Chain to Get Restaurant

```
combo_modifier_prices.combo_modifier_id
    → combo_modifiers.combo_modifier_group_id
        → combo_modifier_groups.combo_group_section_id
            → combo_group_sections.combo_group_id
                → combo_groups.restaurant_id ✅
```

## Section Type Mapping

| V1 HTML ID | section_type       | Description                         |
| ---------- | ------------------ | ----------------------------------- |
| br_id      | bread              | Bread, crust, wraps options         |
| ci_id      | custom_ingredients | Toppings, ingredients customization |
| dr_id      | dressing           | Salad dressings, dipping options    |
| sa_id      | sauce              | Pizza sauce, pasta sauce options    |
| sd_id      | side_dish          | Side dish selections                |
| e_id       | extras             | Extra add-ons                       |
| cm_id      | cooking_method     | Cooking preferences                 |

## Insert Order (Respecting FK Constraints)

```
1. combo_groups           → returns combo_group.id
2. dish_combo_groups      → uses dish_id + combo_group_id
3. combo_group_sections   → returns combo_group_section.id
4. combo_modifier_groups  → returns combo_modifier_group.id
5. combo_modifiers        → returns combo_modifier.id
6. combo_modifier_prices  → uses combo_modifier_id
```

## Delete Order (Rollback)

```
1. combo_modifier_prices
2. combo_modifiers
3. combo_modifier_groups
4. combo_group_sections
5. dish_combo_groups
6. combo_groups
```

---

# Instructions with examples for V3 ID 7     V1 ID 89    Imilio's Pizzeria


1. In the landing page you will find the v1 restaurants under an <ul id="active"> element. Each V1 restaurant is stored in an <li> element:

Each <li> element has an <a> element containing a link to the details page of each restaurant. This <a> element also contains the unique v1 id that identifies each restaurant. For instance the restaurant Imilio's Pizzeria the a element contains its v1 id (89) in the href parameter <a href="/?p=restaurants&amp;display=editRestaurant&amp;restaurant=89">Edit</a>. You should use this element to both identify the v1 restaurants that must be scraped and access its details page where the data that needs to be scrapped is located.

2. Once you get to the details page of each restaurant you need to click this <a> element to navigate to the menu details:
   <a class="active" href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=89&amp;load=menu&amp;showLang=en">Menu</a> this will take you to https://menuadmin.menu.ca/?p=restaurants&display=editRestaurant&restaurant=89


4. In the menu details page look for this div: <div style="width:500px; float: left;">. It contains all the courses and dishes for each restaurant.

Each course and its respective dishes are stored in a <ul> element:
<ul style="list-style-type: none" id="course_0">

Now, each course can have a combo dish or a normal dish. This scraper should only scrape normal dishes. 

You can identify a combo dish by the href attribute of the <a> element of each dish. All combo dishes have a combo= at the end of the href:
<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=89&amp;load=editCombo&amp;showLang=en&amp;combo=4004">Medium Pizza Deal</a>

If you identify a dish with this href value, skip it and continue with the next dish.

Normal dishes can be identified by the href attribute of the <a> element of each dish. All normal dishes have a menuEntry= at the end of the href:
<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=89&amp;load=editDish&amp;showLang=en&amp;menuEntry=3898">Plain</a>

### Normal dishes

Click in the <a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=89&amp;load=editDish&amp;showLang=en&amp;menuEntry=3898">Plain</a>
 to enter the dish details:

In the dish details https://menuadmin.menu.ca/?p=restaurants&display=editRestaurant&restaurant=89&load=editDish&showLang=en&menuEntry=3898


### modifier_groups table:

All modifier groups, modifiers and modifier prices are stored in this div element:

<div style="margin-left:300px" id="groups">

Each modifier group belong to a given section: bread, custom ingredients, dressing, sauce, side dish, extras, cooking method. This section is important because it guides you to scrape the modifier_groups data that needs to be extracted and stored by this scraper:  min_selections, max_selections, free_items, display_order.

For example, for the dish Plain. The Custom Ingredients section has these modifier groups:

<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px">Custom Ingredients</p>

<div class="ingredientGroups" id="ci_id" style="border-width: 0px 1px 1px; border-style: solid; border-color: rgb(170, 170, 170); margin-bottom: 2px; padding: 1px;">
<ul id="ulci" style="list-style-type:none;overflow: hidden">
	    		<li>
	    		    <p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
	    			<input checked="" onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()}); if(this.checked){ $('list_ci_198').show();}" type="radio" name="ci_radio" value="198" id="radio_ci_198">
	    			<label for="radio_ci_198">Pizza Toppings</label>
	    		    </p>
	    		    <ul class="ci" style="list-style-type: none; overflow: hidden;display:" id="list_ci_198">
				    					<li style="width:30%; float: left;padding-left:2px">
					    Ground Beef					    					    <input type="text" size="5" name="ci[198][1518]" value="1.65,3.25,4.05,5.05">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Hot Sausage					    					    <input type="text" size="5" name="ci[198][1519]" value="1.65,3.25,4.05,5.05">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Ham					    					    <input type="text" size="5" name="ci[198][1520]" value="1.65,3.25,4.05,5.05">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Salami					    					    <input type="text" size="5" name="ci[198][1521]" value="1.65,3.25,4.05,5.05">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Bacon Strips					    					    <input type="text" size="5" name="ci[198][1522]" value="1.95,3.55,4.25,5.75">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Pepperoni					    					    <input type="text" size="5" name="ci[198][1523]" value="1.65,3.25,4.05,5.05">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Donair Meat					    					    <input type="text" size="5" name="ci[198][1525]" value="1.65,3.25,4.05,5.05">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Meatballs					    					    <input type="text" size="5" name="ci[198][1526]" value="1.65,3.25,4.05,5.05">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Roast Beef					    					    <input type="text" size="5" name="ci[198][1527]" value="1.65,3.25,4.05,5.05">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Smoked Meat					    					    <input type="text" size="5" name="ci[198][1528]" value="1.65,3.25,4.05,5.05">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Anchovies					    					    <input type="text" size="5" name="ci[198][1529]" value="1.65,3.25,4.05,5.05">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Green Peppers					    					    <input type="text" size="5" name="ci[198][1530]" value="1.65,3.25,4.05,5.05">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Tomatoes					    					    <input type="text" size="5" name="ci[198][1531]" value="1.65,3.25,4.05,5.05">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Onions					    					    <input type="text" size="5" name="ci[198][1532]" value="1.65,3.25,4.05,5.05">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Hot Peppers					    					    <input type="text" size="5" name="ci[198][1533]" value="1.65,3.25,4.05,5.05">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Mushrooms					    					    <input type="text" size="5" name="ci[198][1534]" value="1.65,3.25,4.05,5.05">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Black Olives					    					    <input type="text" size="5" name="ci[198][1535]" value="1.65,3.25,4.05,5.05">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Green Olives					    					    <input type="text" size="5" name="ci[198][1536]" value="1.65,3.25,4.05,5.05">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Artichoke					    					    <input type="text" size="5" name="ci[198][1537]" value="1.65,3.25,4.05,5.05">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Jalapenos					    					    <input type="text" size="5" name="ci[198][1538]" value="1.65,3.25,4.05,5.05">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Pineapple					    					    <input type="text" size="5" name="ci[198][1539]" value="1.65,3.25,4.05,5.05">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Garlic					    					    <input type="text" size="5" name="ci[198][1540]" value="1.65,3.25,4.05,5.05">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Chicken Breast					    					    <input type="text" size="5" name="ci[198][1541]" value="1.95,3.55,4.25,5.75">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Fajita Beef					    					    <input type="text" size="5" name="ci[198][1542]" value="1.95,3.55,4.25,5.75">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Feta					    					    <input type="text" size="5" name="ci[198][1543]" value="2.25,4.25,5.25,7.25">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Mozzarella					    					    <input type="text" size="5" name="ci[198][1544]" value="2.25,4.25,5.25,7.25">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Brick Cheese					    					    <input type="text" size="5" name="ci[198][1545]" value="2.25,4.25,5.25,7.25">
					</li>
				    	    		    </ul>
	    		</li>
	    		<li>
	    		    <p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
	    			<input onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()}); if(this.checked){ $('list_ci_202').show();}" type="radio" name="ci_radio" value="202" id="radio_ci_202">
	    			<label for="radio_ci_202">Sub extras</label>
	    		    </p>
	    		    <ul class="ci" style="list-style-type: none; overflow: hidden;display:none" id="list_ci_202">
				    					<li style="width:30%; float: left;padding-left:2px">
					    Ground Beef					    					    <input type="text" size="5" name="ci[202][37333]" value="1.50,3.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Hot Sausage					    					    <input type="text" size="5" name="ci[202][37334]" value="1.50,3.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Ham					    					    <input type="text" size="5" name="ci[202][37335]" value="1.50,3.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Salami					    					    <input type="text" size="5" name="ci[202][37336]" value="1.50,3.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Bacon					    					    <input type="text" size="5" name="ci[202][37337]" value="1.50,3.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Pepperoni					    					    <input type="text" size="5" name="ci[202][37338]" value="1.50,3.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Donair Meat					    					    <input type="text" size="5" name="ci[202][37339]" value="1.50,3.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Meatballs					    					    <input type="text" size="5" name="ci[202][37340]" value="1.50,3.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Roast Beef					    					    <input type="text" size="5" name="ci[202][37341]" value="1.50,3.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Smoked Meat					    					    <input type="text" size="5" name="ci[202][37342]" value="1.50,3.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Anchovies					    					    <input type="text" size="5" name="ci[202][37343]" value="1.50,3.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Green Peppers					    					    <input type="text" size="5" name="ci[202][37344]" value="1.50,3.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Tomatoes					    					    <input type="text" size="5" name="ci[202][37345]" value="1.50,3.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Onions					    					    <input type="text" size="5" name="ci[202][37346]" value="1.50,3.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Hot Peppers					    					    <input type="text" size="5" name="ci[202][37347]" value="1.50,3.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Mushrooms					    					    <input type="text" size="5" name="ci[202][37348]" value="1.50,3.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Black Olives					    					    <input type="text" size="5" name="ci[202][37349]" value="1.50,3.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Green Olives					    					    <input type="text" size="5" name="ci[202][37350]" value="1.25,2.50">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Artichoke					    					    <input type="text" size="5" name="ci[202][37351]" value="1.50,3.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Jalapenos					    					    <input type="text" size="5" name="ci[202][37352]" value="1.50,3.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Pineapple					    					    <input type="text" size="5" name="ci[202][37353]" value="1.50,3.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Garlic					    					    <input type="text" size="5" name="ci[202][37354]" value="1.50,3.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Extra Cheese					    					    <input type="text" size="5" name="ci[202][41219]" value="1.75,3.50">
					</li>
				    	    		    </ul>
	    		</li>
	    		<li>
	    		    <p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
	    			<input onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()}); if(this.checked){ $('list_ci_206').show();}" type="radio" name="ci_radio" value="206" id="radio_ci_206">
	    			<label for="radio_ci_206">fajita meat</label>
	    		    </p>
	    		    <ul class="ci" style="list-style-type: none; overflow: hidden;display:none" id="list_ci_206">
				    					<li style="width:30%; float: left;padding-left:2px">
					    Chicken Fajitas					    					    <input type="text" size="5" name="ci[206][1559]" value="0.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Beef Fajitas					    					    <input type="text" size="5" name="ci[206][1560]" value="0.00">
					</li>
				    	    		    </ul>
	    		</li>
	    		<li>
	    		    <p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
	    			<input onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()}); if(this.checked){ $('list_ci_207').show();}" type="radio" name="ci_radio" value="207" id="radio_ci_207">
	    			<label for="radio_ci_207">beef or chicken</label>
	    		    </p>
	    		    <ul class="ci" style="list-style-type: none; overflow: hidden;display:none" id="list_ci_207">
				    					<li style="width:30%; float: left;padding-left:2px">
					    Beef					    					    <input type="text" size="5" name="ci[207][1561]" value="0.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Chicken					    					    <input type="text" size="5" name="ci[207][1562]" value="0.00">
					</li>
				    	    		    </ul>
	    		</li>
	    		<li>
	    		    <p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
	    			<input onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()}); if(this.checked){ $('list_ci_215').show();}" type="radio" name="ci_radio" value="215" id="radio_ci_215">
	    			<label for="radio_ci_215">Pizza toppings for specials</label>
	    		    </p>
	    		    <ul class="ci" style="list-style-type: none; overflow: hidden;display:none" id="list_ci_215">
				    					<li style="width:30%; float: left;padding-left:2px">
					    Ground Beef					    					    <input type="text" size="5" name="ci[215][1518]" value="1.00,2.00,2.95,3.95">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Hot Sausage					    					    <input type="text" size="5" name="ci[215][1519]" value="1.00,2.00,2.95,3.95">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Ham					    					    <input type="text" size="5" name="ci[215][1520]" value="1.00,2.00,2.95,3.95">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Salami					    					    <input type="text" size="5" name="ci[215][1521]" value="1.00,2.00,2.95,3.95">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Bacon Strips					    					    <input type="text" size="5" name="ci[215][1522]" value="1.00,2.00,2.95,3.95">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Pepperoni					    					    <input type="text" size="5" name="ci[215][1523]" value="1.00,2.00,2.95,3.95">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Donair Meat					    					    <input type="text" size="5" name="ci[215][1525]" value="1.00,2.00,2.95,3.95">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Meatballs					    					    <input type="text" size="5" name="ci[215][1526]" value="1.00,2.00,2.95,3.95">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Roast Beef					    					    <input type="text" size="5" name="ci[215][1527]" value="1.00,2.00,2.95,3.95">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Smoked Meat					    					    <input type="text" size="5" name="ci[215][1528]" value="1.00,2.00,2.95,3.95">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Anchovies					    					    <input type="text" size="5" name="ci[215][1529]" value="1.00,2.00,2.95,3.95">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Green Peppers					    					    <input type="text" size="5" name="ci[215][1530]" value="1.00,2.00,2.95,3.95">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Tomatoes					    					    <input type="text" size="5" name="ci[215][1531]" value="1.00,2.00,2.95,3.95">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Onions					    					    <input type="text" size="5" name="ci[215][1532]" value="1.00,2.00,2.95,3.95">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Hot Peppers					    					    <input type="text" size="5" name="ci[215][1533]" value="1.00,2.00,2.95,3.95">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Mushrooms					    					    <input type="text" size="5" name="ci[215][1534]" value="1.00,2.00,2.95,3.95">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Black Olives					    					    <input type="text" size="5" name="ci[215][1535]" value="1.00,2.00,2.95,3.95">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Green Olives					    					    <input type="text" size="5" name="ci[215][1536]" value="1.00,2.00,2.95,3.95">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Artichoke					    					    <input type="text" size="5" name="ci[215][1537]" value="1.00,2.00,2.95,3.95">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Jalapenos					    					    <input type="text" size="5" name="ci[215][1538]" value="1.00,2.00,2.95,3.95">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Pineapple					    					    <input type="text" size="5" name="ci[215][1539]" value="1.00,2.00,2.95,3.95">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Garlic					    					    <input type="text" size="5" name="ci[215][1540]" value="1.00,2.00,2.95,3.95">
					</li>
				    	    		    </ul>
	    		</li>
	    		<li>
	    		    <p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
	    			<input onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()}); if(this.checked){ $('list_ci_220').show();}" type="radio" name="ci_radio" value="220" id="radio_ci_220">
	    			<label for="radio_ci_220">hamburger toppings</label>
	    		    </p>
	    		    <ul class="ci" style="list-style-type: none; overflow: hidden;display:none" id="list_ci_220">
				    					<li style="width:30%; float: left;padding-left:2px">
					    Tomatoes					    					    <input type="text" size="5" name="ci[220][1531]" value="1.00,2.00,2.95,3.95">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Onions					    					    <input type="text" size="5" name="ci[220][1532]" value="1.00,2.00,2.95,3.95">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Lettuce					    					    <input type="text" size="5" name="ci[220][1595]" value="0.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Pickle					    					    <input type="text" size="5" name="ci[220][1596]" value="0.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Ketchup					    					    <input type="text" size="5" name="ci[220][1597]" value="0.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Mustard					    					    <input type="text" size="5" name="ci[220][1598]" value="0.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Plain					    					    <input type="text" size="5" name="ci[220][1599]" value="0.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    All dressed					    					    <input type="text" size="5" name="ci[220][1600]" value="0.00">
					</li>
				    	    		    </ul>
	    		</li>
	    		<li>
	    		    <p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
	    			<input onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()}); if(this.checked){ $('list_ci_8237').show();}" type="radio" name="ci_radio" value="8237" id="radio_ci_8237">
	    			<label for="radio_ci_8237">Pizza Toppings without Premium</label>
	    		    </p>
	    		    <ul class="ci" style="list-style-type: none; overflow: hidden;display:none" id="list_ci_8237">
				    					<li style="width:30%; float: left;padding-left:2px">
					    Ground Beef					    					    <input type="text" size="5" name="ci[8237][1518]" value="1.65,3.25,4.05,5.05">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Hot Sausage					    					    <input type="text" size="5" name="ci[8237][1519]" value="1.65,3.25,4.05,5.05">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Ham					    					    <input type="text" size="5" name="ci[8237][1520]" value="1.65,3.25,4.05,5.05">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Salami					    					    <input type="text" size="5" name="ci[8237][1521]" value="1.65,3.25,4.05,5.05">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Pepperoni					    					    <input type="text" size="5" name="ci[8237][1523]" value="1.65,3.25,4.05,5.05">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Donair Meat					    					    <input type="text" size="5" name="ci[8237][1525]" value="1.65,3.25,4.05,5.05">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Meatballs					    					    <input type="text" size="5" name="ci[8237][1526]" value="1.65,3.25,4.05,5.05">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Roast Beef					    					    <input type="text" size="5" name="ci[8237][1527]" value="1.65,3.25,4.05,5.05">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Smoked Meat					    					    <input type="text" size="5" name="ci[8237][1528]" value="1.65,3.25,4.05,5.05">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Anchovies					    					    <input type="text" size="5" name="ci[8237][1529]" value="1.65,3.25,4.05,5.05">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Green Peppers					    					    <input type="text" size="5" name="ci[8237][1530]" value="1.65,3.25,4.05,5.05">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Tomatoes					    					    <input type="text" size="5" name="ci[8237][1531]" value="1.65,3.25,4.05,5.05">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Onions					    					    <input type="text" size="5" name="ci[8237][1532]" value="1.65,3.25,4.05,5.05">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Hot Peppers					    					    <input type="text" size="5" name="ci[8237][1533]" value="1.65,3.25,4.05,5.05">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Mushrooms					    					    <input type="text" size="5" name="ci[8237][1534]" value="1.65,3.25,4.05,5.05">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Black Olives					    					    <input type="text" size="5" name="ci[8237][1535]" value="1.65,3.25,4.05,5.05">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Green Olives					    					    <input type="text" size="5" name="ci[8237][1536]" value="1.65,3.25,4.05,5.05">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Artichoke					    					    <input type="text" size="5" name="ci[8237][1537]" value="1.65,3.25,4.05,5.05">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Jalapenos					    					    <input type="text" size="5" name="ci[8237][1538]" value="1.65,3.25,4.05,5.05">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Pineapple					    					    <input type="text" size="5" name="ci[8237][1539]" value="1.65,3.25,4.05,5.05">
					</li>
				    	    		    </ul>
	    		</li>
	    		<li>
	    		    <p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
	    			<input onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()}); if(this.checked){ $('list_ci_8238').show();}" type="radio" name="ci_radio" value="8238" id="radio_ci_8238">
	    			<label for="radio_ci_8238">Premium Toppings</label>
	    		    </p>
	    		    <ul class="ci" style="list-style-type: none; overflow: hidden;display:none" id="list_ci_8238">
				    					<li style="width:30%; float: left;padding-left:2px">
					    Bacon Strips					    					    <input type="text" size="5" name="ci[8238][1522]" value="1.95,3.55,4.25,5.75">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Chicken Breast					    					    <input type="text" size="5" name="ci[8238][1541]" value="1.95,3.55,4.25,5.75">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Fajita Beef					    					    <input type="text" size="5" name="ci[8238][1542]" value="1.95,3.55,4.25,5.75">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Feta					    					    <input type="text" size="5" name="ci[8238][1543]" value="2.25,4.25,5.25,7.25">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Mozzarella					    					    <input type="text" size="5" name="ci[8238][1544]" value="2.25,4.25,5.25,7.25">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Brick Cheese					    					    <input type="text" size="5" name="ci[8238][1545]" value="2.25,4.25,5.25,7.25">
					</li>
				    	    		    </ul>
	    		</li>
					        	   </ul>


notice that only the Pizza Toppings without Premium was checked. We should only focus on the active (checked="") modifier groups:

<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
	    			<input checked="" onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()}); if(this.checked){ $('list_ci_198').show();}" type="radio" name="ci_radio" value="198" id="radio_ci_198">
	    			<label for="radio_ci_198">Pizza Toppings</label>
	    		    </p>


The modifiers of each modifier group and their prices are stored in this element:

<li>
	<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
		<input checked="" onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()}); if(this.checked){ $('list_ci_8174').show();}" type="radio" name="ci_radio" value="8174" id="radio_ci_8174">
		<label for="radio_ci_8174">Pizza Toppings without Premium</label>
	</p>
	<ul class="ci" style="list-style-type: none; overflow: hidden;display:" id="list_ci_8174">			    					
	</ul>
</li>

The modifiers of the Pizza Toppings without Premium modifier group are:

<ul class="ci" style="list-style-type: none; overflow: hidden;display:" id="list_ci_8174">
				    					<li style="width:30%; float: left;padding-left:2px">
					    Green Peppers					    					    <input type="text" size="5" name="ci[8174][37052]" value="2.99">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Onions					    					    <input type="text" size="5" name="ci[8174][37053]" value="2.99">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Mushrooms					    					    <input type="text" size="5" name="ci[8174][37054]" value="2.99">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Green Olives					    					    <input type="text" size="5" name="ci[8174][37055]" value="2.99">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Black Olives					    					    <input type="text" size="5" name="ci[8174][37056]" value="2.99">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Dill Pickle					    					    <input type="text" size="5" name="ci[8174][37057]" value="2.99">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Tomatoes					    					    <input type="text" size="5" name="ci[8174][37058]" value="2.99">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Pineapple					    					    <input type="text" size="5" name="ci[8174][37059]" value="2.99">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Hot Peppers					    					    <input type="text" size="5" name="ci[8174][37060]" value="2.99">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Jalapeno					    					    <input type="text" size="5" name="ci[8174][37061]" value="2.99">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Pepperoni					    					    <input type="text" size="5" name="ci[8174][37062]" value="2.99">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Italian Sausage					    					    <input type="text" size="5" name="ci[8174][37063]" value="2.99">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Bacon					    					    <input type="text" size="5" name="ci[8174][37064]" value="2.99">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Ham					    					    <input type="text" size="5" name="ci[8174][37065]" value="2.99">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Meatballs					    					    <input type="text" size="5" name="ci[8174][37066]" value="2.99">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Chicken					    					    <input type="text" size="5" name="ci[8174][37067]" value="2.99">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Ground Beef					    					    <input type="text" size="5" name="ci[8174][37068]" value="2.99">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Donair Meat					    					    <input type="text" size="5" name="ci[8174][37069]" value="2.99">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Cheddar					    					    <input type="text" size="5" name="ci[8174][37071]" value="2.99">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Feta Cheese					    					    <input type="text" size="5" name="ci[8174][37072]" value="2.99">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Sour Cream					    					    <input type="text" size="5" name="ci[8174][44095]" value="2.99">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Nacho Cheese Sauce					    					    <input type="text" size="5" name="ci[8174][44096]" value="2.99">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Hot Honey					    					    <input type="text" size="5" name="ci[8174][56143]" value="2.99,3.49,3.99,4.99">
					</li>
				    	    		    </ul>

if you find more than one price, it is because each price belongs to a different size variant.

Do this process for all the active modifier groups (<input checked="" onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()}); if(this.checked){ $('list_ci_8174').show();}" type="radio" name="ci_radio" value="8174" id="radio_ci_8174">) in each dish.

#### Modifier Groups Details:
The data that we need to scrape (min_selections, max_selections, free_items, display_order) is located within this html section:

<li>
		<p><input type="checkbox" id="hasBread" name="hasBread" checked="" value="Y" onclick="if(this.checked){ $('breadNo').show();$('br_id').appear() } else { $('br_id').fade(); $('breadNo').hide() }"> <label for="hasBread">Has Bread</label></p>
		<p id="breadNo" style="padding-left: 20px;">
			<label for="breadHeader">Use this title</label><input type="text" name="breadHeader" id="breadHeader" value="Bread Selection"><br>
		    <label for="displayOrderBread">Display Order</label><input type="text" name="displayOrderBread" id="displayOrderBread" value="1" size="3">
		</p>
		<p><input type="checkbox" id="hasCustomisation" name="hasCustomisation" checked="" value="Y" onclick="if(this.checked){ $('ciNo').show();$('ci_id').appear() } else { $('ci_id').fade(); $('ciNo').hide() }"> <label for="hasCustomisation">Has Custom Ingredients</label></p>
		<p id="ciNo" style="padding-left: 20px;">
			<label for="ciHeader">Use this title</label><input type="text" name="ciHeader" id="ciHeader" value="How about some extra toppings?"><br>
		    <label for="minci" style="display: inline">Min custom items: </label><input type="text" name="minci" id="minci" size="3" value="0"><br>
		    <label for="maxci" style="display: inline">Max custom items: </label><input type="text" name="maxci" id="maxci" size="3" value="0"><br>
		    <label for="freeCI" style="display: inline">Free items: </label><input type="text" name="freeci" id="freeCI" size="3" value="0"><br>
		    <label for="displayOrderCI">Display Order</label><input type="text" name="displayOrderCI" id="displayOrderCI" value="3" size="3">
		</p>
		<p><input type="checkbox" id="hasDressing" name="hasDressing" value="Y" onclick="if(this.checked){ $('dressingNo').show();$('dr_id').appear() } else { $('dr_id').fade(); $('dressingNo').hide() }"> <label for="hasDressing">Has Dressing</label></p>
		<p id="dressingNo" style="display: none;padding-left:20px">
			<label for="dressingHeader">Use this title</label><input type="text" name="dressingHeader" id="dressingHeader" value="Dressing"><br>
		    <label for="minDressing" style="display: inline">Min dressings: </label><input type="text" name="mindressing" id="minDressing" size="3" value="1"><br>
		    <label for="maxDressing" style="display: inline">Max dressings: </label><input type="text" name="maxdressing" id="maxDressing" size="3" value="1"><br>
		    <label for="freeDressing" style="display: inline">Free items: </label><input type="text" name="freeDressing" id="freeDressing" size="3" value="0"><br>
		    <label for="displayOrderDressing">Display Order</label><input type="text" name="displayOrderDressing" id="displayOrderDressing" value="3" size="3">
		</p>
		<p><input type="checkbox" id="hasSauce" name="hasSauce" checked="" value="Y" onclick="if(this.checked){ $('sauceNo').show();$('sa_id').appear() } else { $('sa_id').fade(); $('sauceNo').hide() }"> <label for="hasSauce">Has Sauce</label></p>
		<p id="sauceNo" style="padding-left: 20px;">
			<label for="sauceHeader">Use this title</label><input type="text" name="sauceHeader" id="sauceHeader" value="Sauces"><br>
		    <label for="minSauce" style="display: inline">Min sauces: </label><input type="text" name="minsauce" id="minSauce" size="3" value="1"><br>
		    <label for="maxSauce" style="display: inline">Max sauces: </label><input type="text" name="maxsauce" id="maxSauce" size="3" value="1"><br>
		    <label for="freeSauce" style="display: inline">Free items: </label><input type="text" name="freeSauce" id="freeSauce" size="3" value="0"><br>
		    <label for="displayOrderSauce">Display Order</label><input type="text" name="displayOrderSauce" id="displayOrderSauce" value="2" size="3">
		</p>
		<p><input type="checkbox" id="hasSideDish" name="hasSideDish" onclick="if(this.checked){ $('sdNo').show();$('sd_id').appear() } else { $('sd_id').fade(); $('sdNo').hide() }" value="Y"> <label for="hasSideDish">Has Side Dishes</label></p>
		<p id="sdNo" style="display: none;padding-left:20px">
			<label for="sideDishHeader">Use this title</label><input type="text" name="sideDishHeader" id="sideDishHeader" value="Side Dish"><br>
		    <label for="minSD" style="display: inline">Min side dishes: </label><input type="text" name="minsd" id="minSD" size="3" value="1"><br>
		    <label for="maxSD" style="display: inline">Max side dishes: </label><input type="text" name="maxsd" id="maxSD" size="3" value="1"><br>
		    <label for="freeSD" style="display: inline">Free items: </label><input type="text" name="freeSD" id="freeSD" size="3" value="0"><br>
		    <label for="displayOrderSD">Display Order</label><input type="text" name="displayOrderSD" id="displayOrderSD" value="5" size="3">
		</p>
		<p><input type="checkbox" id="hasDrinks" name="hasDrinks" onclick="if(this.checked){ $('d_id').appear();$('drinksNo').show(); } else { $('d_id').fade();$('drinksNo').hide() }" value="Y"> <label for="hasDrinks">Has Drinks</label></p>
		<p id="drinksNo" style="display: none;padding-left:20px">
			<label for="drinksHeader">Use this title</label><input type="text" name="drinksHeader" id="drinksHeader" value="Choose your free pop!"><br>
		    <label for="minDrink" style="display: inline">Min drinks: </label><input type="text" name="mindrink" id="minDrink" size="3" value="1,2,3,3"><br>
		    <label for="maxDrink" style="display: inline">Max drinks: </label><input type="text" name="maxdrink" id="maxDrink" size="3" value="1,2,3,3"><br>
		    <label for="freeDrink" style="display: inline">Free items: </label><input type="text" name="freeDrink" id="freeDrink" size="3" value="1,2,3,3"><br>
		    <label for="displayOrderDrink">Display Order</label><input type="text" name="displayOrderDrink" id="displayOrderDrink" value="6" size="3">
		</p>
		<p><input type="checkbox" id="hasExtras" name="hasExtras" value="Y" onclick="if(this.checked){ $('extraNo').show();$('e_id').appear() } else { $('e_id').fade(); $('extraNo').hide() }"> <label for="hasExtras">Has Extras</label></p>
		<p id="extraNo" style="display: none;padding-left:20px">
			<label for="extraHeader">Use this title</label><input type="text" name="extraHeader" id="extraHeader" value="Extras"><br>
		    <label for="minExtra" style="display: inline">Min extras: </label><input type="text" name="minextras" id="minExtra" size="3" value="1"><br>
		    <label for="maxExtra" style="display: inline">Max extras: </label><input type="text" name="maxextras" id="maxExtra" size="3" value="1"><br>
		    <label for="freeExtra" style="display: inline">Free items: </label><input type="text" name="freeExtra" id="freeExtra" size="3" value="0"><br>
		    <label for="displayOrderExtras">Display Order</label><input type="text" name="displayOrderExtras" id="displayOrderExtras" value="7" size="3">
		</p>
		<p><input type="checkbox" id="hasCookMethod" name="hasCookMethod" value="Y" onclick="if(this.checked){ $('cmNo').show();$('cm_id').appear(); } else { $('cm_id').fade(); $('cmNo').hide() }"> <label for="hasCookMethod">Has Cooking Method</label></p>
		<p id="cmNo" style="display: none;padding-left:20px">
			<label for="cmHeader">Use this title</label><input type="text" name="cmHeader" id="cmHeader" value="Cooking Method"><br>
		    <label for="displayOrderCM">Display Order</label><input type="text" name="displayOrderCM" id="displayOrderCM" value="8" size="3">
		</p>
		<p>
		    <input type="checkbox" id="showPizzaIcons" value="Y" name="showPizzaIcons" checked=""> <label for="showPizzaIcons">Show Pizza Icons</label>
		</p>
		<p>
		    <input type="checkbox" id="showInMenu" value="Y" name="showInMenu" checked=""> <label for="showInMenu">Show dish in menu</label>
		</p>
                <p>
                    <input type="checkbox" id="checkoutItems" value="Y" name="checkoutItems"> <label for="checkoutItems">Checkout Items</label>
                </p>
        <p>
        	<input type="checkbox" id="upsell" value="y" name="upsell"> <label for="upsell">Upsell</label>
        </p>
		<p>
		    <a href="#" id="attachCourse">Attach course name to dish name</a>
		</p>
 </li>

Use the id of each active modifier to map to its respective details section. For example, The Pizza Toppings modifier group is contained in a <div> element with an id=ci_id:

<div class="ingredientGroups" id="ci_id" style="border-width: 0px 1px 1px; border-style: solid; border-color: rgb(170, 170, 170); margin-bottom: 2px; padding: 1px;">

This same id can be found in this element:

<p><input type="checkbox" id="hasCustomisation" name="hasCustomisation" checked="" value="Y" onclick="if(this.checked){ $('ciNo').show();$('ci_id').appear() } else { $('ci_id').fade(); $('ciNo').hide() }"> <label for="hasCustomisation">Has Custom Ingredients</label></p>
<p id="ciNo" style="padding-left: 20px;">
			<label for="ciHeader">Use this title</label><input type="text" name="ciHeader" id="ciHeader" value="How about some extra toppings?"><br>
		    <label for="minci" style="display: inline">Min custom items: </label><input type="text" name="minci" id="minci" size="3" value="0"><br>
		    <label for="maxci" style="display: inline">Max custom items: </label><input type="text" name="maxci" id="maxci" size="3" value="0"><br>
		    <label for="freeCI" style="display: inline">Free items: </label><input type="text" name="freeci" id="freeCI" size="3" value="0"><br>
		    <label for="displayOrderCI">Display Order</label><input type="text" name="displayOrderCI" id="displayOrderCI" value="3" size="3">
</p>

modifier_groups.name:
<label for="ciHeader">Use this title</label><input type="text" name="ciHeader" id="ciHeader" value="How about some extra toppings?"><br>

min_selections:
<label for="minci" style="display: inline">Min custom items: </label><input type="text" name="minci" id="minci" size="3" value="0"><br>

max_selections:
 <label for="maxci" style="display: inline">Max custom items: </label><input type="text" name="maxci" id="maxci" size="3" value="0"><br>

free_items:
<label for="freeCI" style="display: inline">Free items: </label><input type="text" name="freeci" id="freeCI" size="3" value="0"><br>

display_order:
<label for="displayOrderCI">Display Order</label><input type="text" name="displayOrderCI" id="displayOrderCI" value="3" size="3">

### dish_availability

Finally, verify if the current dish should be hidden on certain days. By scraping this html section:

<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:10px">Hide dish on</p>

<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:10px">Hide dish on</p>

<div class="ingredientGroups" style="border-width:0 1px 1px 1px; border-style: solid;border-color: #aaa;margin-bottom:2px;padding:2px">
                            <input type="checkbox" name="hideOnDays[]" value="mon" id="d_mon" style="vertical-align: center"> <label for="d_mon" style="vertical-align: center">Monday</label>
                            <input type="checkbox" name="hideOnDays[]" value="tue" id="d_tue" style="vertical-align: center"> <label for="d_tue" style="vertical-align: center">Tuesday</label>
                            <input type="checkbox" name="hideOnDays[]" value="wed" id="d_wed" style="vertical-align: center"> <label for="d_wed" style="vertical-align: center">Wednersday</label>
                            <input type="checkbox" name="hideOnDays[]" value="thu" id="d_thu" style="vertical-align: center"> <label for="d_thu" style="vertical-align: center">Thursday</label>
                            <input type="checkbox" name="hideOnDays[]" value="fri" id="d_fri" style="vertical-align: center"> <label for="d_fri" style="vertical-align: center">Friday</label>
                            <input type="checkbox" name="hideOnDays[]" value="sat" id="d_sat" style="vertical-align: center"> <label for="d_sat" style="vertical-align: center">Saturday</label>
                            <input type="checkbox" name="hideOnDays[]" value="sun" id="d_sun" style="vertical-align: center"> <label for="d_sun" style="vertical-align: center">Sunday</label>
</div>

