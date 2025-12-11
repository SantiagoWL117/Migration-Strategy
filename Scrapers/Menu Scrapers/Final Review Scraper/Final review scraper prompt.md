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

## Phase 1

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

if you identify a dish with this href value, skip it and continue with the next dish.

Normal dishes can be identified by the href attribute of the <a> element of each dish. All normal dishes have a menuEntry= at the end of the href:
<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=89&amp;load=editDish&amp;showLang=en&amp;menuEntry=3898">Plain</a>

### Normal dishes

Click in the <a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=89&amp;load=editDish&amp;showLang=en&amp;menuEntry=3898">Plain</a>
 to enter the dish details:

In the dish details https://menuadmin.menu.ca/?p=restaurants&display=editRestaurant&restaurant=89&load=editDish&showLang=en&menuEntry=3898



### dishes table:

dish.sku:

<li>
                <label style="display: block" for="sku">SKU</label>
                <input type="text" name="sku" id="sku" value="" class="long">
            </li>

dish_prices.price:

<li>
		<label style="display:block" for="price">Price - <sub>separate multiple prices by comma</sub></label>
		<input type="text" name="price" id="price" class="long" value="9.95">
	    </li>

dish_prices.size_variant:

<li>
		<label style="display:block" for="quantity">Quantity - <sub>separate multiple quantities by comma, leave blank for 1</sub></label>
		<input type="text" name="quantity" id="quantity" class="long" value="">
	    </li>

### modifier_groups table:

All modifier groups, modifiers and modifier prices are stored in this div element:

<div style="margin-left:300px" id="groups">

Each modifier group belong to a given section: bread, custom ingredients, dressing, sauce, side dish, extras, cooking method. This section is important because it guides you to scrape the title, min_selections, max_selections, free_items, display_order.

For example, for the dish Nacho Tuesdays HIDE. The Custom Ingredients section has these modifier groups:

<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px">Custom Ingredients</p>

<div class="ingredientGroups" id="ci_id" style="border-width: 0px 1px 1px; border-style: solid; border-color: rgb(170, 170, 170); margin-bottom: 2px; padding: 1px;">
    	    <ul id="ulci" style="list-style-type:none;overflow: hidden">
	    		<li>
	    		    <p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
	    			<input onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()}); if(this.checked){ $('list_ci_8173').show();}" type="radio" name="ci_radio" value="8173" id="radio_ci_8173">
	    			<label for="radio_ci_8173">Pizza Toppings</label>
	    		    </p>
	    		    <ul class="ci" style="list-style-type: none; overflow: hidden;display:none" id="list_ci_8173">
				    					<li style="width:30%; float: left;padding-left:2px">
					    Green Peppers					    					    <input type="text" size="5" name="ci[8173][37052]" value="2.99,3.49,3.99,4.99">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Onions					    					    <input type="text" size="5" name="ci[8173][37053]" value="2.99,3.49,3.99,4.99">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Mushrooms					    					    <input type="text" size="5" name="ci[8173][37054]" value="2.99,3.49,3.99,4.99">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Green Olives					    					    <input type="text" size="5" name="ci[8173][37055]" value="2.99,3.49,3.99,4.99">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Black Olives					    					    <input type="text" size="5" name="ci[8173][37056]" value="2.99,3.49,3.99,4.99">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Dill Pickle					    					    <input type="text" size="5" name="ci[8173][37057]" value="2.99,3.49,3.99,4.99">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Tomatoes					    					    <input type="text" size="5" name="ci[8173][37058]" value="2.99,3.49,3.99,4.99">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Pineapple					    					    <input type="text" size="5" name="ci[8173][37059]" value="2.99,3.49,3.99,4.99">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Hot Peppers					    					    <input type="text" size="5" name="ci[8173][37060]" value="2.99,3.49,3.99,4.99">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Jalapeno					    					    <input type="text" size="5" name="ci[8173][37061]" value="2.99,3.49,3.99,4.99">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Pepperoni					    					    <input type="text" size="5" name="ci[8173][37062]" value="2.99,3.49,3.99,4.99">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Italian Sausage					    					    <input type="text" size="5" name="ci[8173][37063]" value="2.99,3.49,3.99,4.99">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Bacon					    					    <input type="text" size="5" name="ci[8173][37064]" value="2.99,3.49,3.99,4.99">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Ham					    					    <input type="text" size="5" name="ci[8173][37065]" value="2.99,3.49,3.99,4.99">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Meatballs					    					    <input type="text" size="5" name="ci[8173][37066]" value="2.99,3.49,3.99,4.99">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Chicken					    					    <input type="text" size="5" name="ci[8173][37067]" value="2.99,3.49,3.99,4.99">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Ground Beef					    					    <input type="text" size="5" name="ci[8173][37068]" value="2.99,3.49,3.99,4.99">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Donair Meat					    					    <input type="text" size="5" name="ci[8173][37069]" value="2.99,3.49,3.99,4.99">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Cheddar					    					    <input type="text" size="5" name="ci[8173][37071]" value="2.99,3.49,3.99,4.99">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Feta Cheese					    					    <input type="text" size="5" name="ci[8173][37072]" value="2.99,3.49,3.99,4.99">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Sour Cream					    					    <input type="text" size="5" name="ci[8173][44095]" value="2.99,3.49,3.99,4.99">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Nacho Cheese Sauce					    					    <input type="text" size="5" name="ci[8173][44096]" value="2.99,3.49,3.99,4.99">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Hot Honey					    					    <input type="text" size="5" name="ci[8173][56143]" value="2.99,3.49,3.99,4.99">
				</li>
				    	    		    </ul>
	    		</li>
	    		<li>
	    		    <p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
	    			<input checked="" onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()}); if(this.checked){ $('list_ci_8174').show();}" type="radio" name="ci_radio" value="8174" id="radio_ci_8174">
	    			<label for="radio_ci_8174">Pizza Toppings without Premium</label>
	    		    </p>
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
	    		</li>
	    		<li>
	    		    <p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
	    			<input onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()}); if(this.checked){ $('list_ci_8175').show();}" type="radio" name="ci_radio" value="8175" id="radio_ci_8175">
	    			<label for="radio_ci_8175">Premium Toppings</label>
	    		    </p>
	    		    <ul class="ci" style="list-style-type: none; overflow: hidden;display:none" id="list_ci_8175">
				    					<li style="width:30%; float: left;padding-left:2px">
					    Extra Cheese					    					    <input type="text" size="5" name="ci[8175][37070]" value="2.99,3.49,3.99,4.99">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Double Cheese					    					    <input type="text" size="5" name="ci[8175][37169]" value="5.98,7.58,11.98,14.98">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Extra Vegan Cheese					    					    <input type="text" size="5" name="ci[8175][49543]" value="3.98,4.78,6.98,8.48">
					</li>
				    	    		    </ul>
	    		</li>
	    		<li>
	    		    <p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
	    			<input onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()}); if(this.checked){ $('list_ci_8177').show();}" type="radio" name="ci_radio" value="8177" id="radio_ci_8177">
	    			<label for="radio_ci_8177">Toppings for POUTINES</label>
	    		    </p>
	    		    <ul class="ci" style="list-style-type: none; overflow: hidden;display:none" id="list_ci_8177">
				    					<li style="width:30%; float: left;padding-left:2px">
					    Bacon					    					    <input type="text" size="5" name="ci[8177][37274]" value="1.00,2.00,3.00,4.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Extra Cheese					    					    <input type="text" size="5" name="ci[8177][37276]" value="1.00,2.00,3.00,4.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Chicken					    					    <input type="text" size="5" name="ci[8177][37277]" value="1.00,2.00,3.00,4.00">
					</li>
				    	    		    </ul>
	    		</li>
	    		<li>
	    		    <p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
	    			<input onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()}); if(this.checked){ $('list_ci_9362').show();}" type="radio" name="ci_radio" value="9362" id="radio_ci_9362">
	    			<label for="radio_ci_9362">Keto Desserts</label>
	    		    </p>
	    		    <ul class="ci" style="list-style-type: none; overflow: hidden;display:none" id="list_ci_9362">
				    					<li style="width:30%; float: left;padding-left:2px">
					    Pecan Puffs					    					    <input type="text" size="5" name="ci[9362][42473]" value="0.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Lemon Poppy Leaf					    					    <input type="text" size="5" name="ci[9362][42474]" value="0.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Tiramisu Cup Cakes					    					    <input type="text" size="5" name="ci[9362][42475]" value="0.00">
					</li>
				    	    		    </ul>
	    		</li>
	    		<li>
	    		    <p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
	    			<input onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()}); if(this.checked){ $('list_ci_9424').show();}" type="radio" name="ci_radio" value="9424" id="radio_ci_9424">
	    			<label for="radio_ci_9424">All Pizza Tails</label>
	    		    </p>
	    		    <ul class="ci" style="list-style-type: none; overflow: hidden;display:none" id="list_ci_9424">
				    					<li style="width:30%; float: left;padding-left:2px">
					    Pot of Gold Pizza Tail					    					    <input type="text" size="5" name="ci[9424][42713]" value="0.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Surprise Pizza Tail					    					    <input type="text" size="5" name="ci[9424][42714]" value="0.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Smores Marshmallow Fluff Tail					    					    <input type="text" size="5" name="ci[9424][42716]" value="0.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Nutella Pizza Tail					    					    <input type="text" size="5" name="ci[9424][42717]" value="0.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Peanutbutter Cup Flutter Nutter Tail					    					    <input type="text" size="5" name="ci[9424][42718]" value="0.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Cookies &amp; Cream Pizza Tail					    					    <input type="text" size="5" name="ci[9424][42722]" value="0.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Kinder Surprise Pizza Tail					    					    <input type="text" size="5" name="ci[9424][45379]" value="0.00">
					</li>
				    	    		    </ul>
	    		</li>
	    		<li>
	    		    <p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
	    			<input onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()}); if(this.checked){ $('list_ci_9691').show();}" type="radio" name="ci_radio" value="9691" id="radio_ci_9691">
	    			<label for="radio_ci_9691">Meats &amp; CHeese for Nacho Fries</label>
	    		    </p>
	    		    <ul class="ci" style="list-style-type: none; overflow: hidden;display:none" id="list_ci_9691">
				    					<li style="width:30%; float: left;padding-left:2px">
					    Pepperoni					    					    <input type="text" size="5" name="ci[9691][37062]" value="2.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Italian Sausage					    					    <input type="text" size="5" name="ci[9691][37063]" value="2.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Bacon					    					    <input type="text" size="5" name="ci[9691][37064]" value="2.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Ham					    					    <input type="text" size="5" name="ci[9691][37065]" value="2.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Meatballs					    					    <input type="text" size="5" name="ci[9691][37066]" value="2.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Chicken					    					    <input type="text" size="5" name="ci[9691][37067]" value="2.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Ground Beef					    					    <input type="text" size="5" name="ci[9691][37068]" value="2.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Donair Meat					    					    <input type="text" size="5" name="ci[9691][37069]" value="2.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Cheddar					    					    <input type="text" size="5" name="ci[9691][44099]" value="2.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Mozzarella					    					    <input type="text" size="5" name="ci[9691][44100]" value="2.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Curd					    					    <input type="text" size="5" name="ci[9691][44101]" value="2.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Asiago					    					    <input type="text" size="5" name="ci[9691][44102]" value="2.00">
					</li>
				    	    		    </ul>
	    		</li>
	    		<li>
	    		    <p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
	    			<input onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()}); if(this.checked){ $('list_ci_9692').show();}" type="radio" name="ci_radio" value="9692" id="radio_ci_9692">
	    			<label for="radio_ci_9692">Vegetables for Nacho Fries</label>
	    		    </p>
	    		    <ul class="ci" style="list-style-type: none; overflow: hidden;display:none" id="list_ci_9692">
				    					<li style="width:30%; float: left;padding-left:2px">
					    Green Peppers					    					    <input type="text" size="5" name="ci[9692][37052]" value="0.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Onions					    					    <input type="text" size="5" name="ci[9692][37053]" value="0.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Mushrooms					    					    <input type="text" size="5" name="ci[9692][37054]" value="0.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Green Olives					    					    <input type="text" size="5" name="ci[9692][37055]" value="0.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Black Olives					    					    <input type="text" size="5" name="ci[9692][37056]" value="0.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Dill Pickle					    					    <input type="text" size="5" name="ci[9692][37057]" value="0.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Tomatoes					    					    <input type="text" size="5" name="ci[9692][37058]" value="0.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Pineapple					    					    <input type="text" size="5" name="ci[9692][37059]" value="0.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Hot Peppers					    					    <input type="text" size="5" name="ci[9692][37060]" value="0.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Jalapeno					    					    <input type="text" size="5" name="ci[9692][37061]" value="0.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Jalapeno Crisps					    					    <input type="text" size="5" name="ci[9692][44105]" value="0.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Onion Crisps					    					    <input type="text" size="5" name="ci[9692][44106]" value="0.00">
					</li>
				    	    		    </ul>
	    		</li>
	    		<li>
	    		    <p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
	    			<input onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()}); if(this.checked){ $('list_ci_9869').show();}" type="radio" name="ci_radio" value="9869" id="radio_ci_9869">
	    			<label for="radio_ci_9869">Add Bacon 3.99</label>
	    		    </p>
	    		    <ul class="ci" style="list-style-type: none; overflow: hidden;display:none" id="list_ci_9869">
				    					<li style="width:30%; float: left;padding-left:2px">
					    Add Bacon					    					    <input type="text" size="5" name="ci[9869][44931]" value="3.99">
					</li>
				    	    		    </ul>
	    		</li>
	    		<li>
	    		    <p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
	    			<input onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()}); if(this.checked){ $('list_ci_9965').show();}" type="radio" name="ci_radio" value="9965" id="radio_ci_9965">
	    			<label for="radio_ci_9965">Easter Pizza Tail Selection</label>
	    		    </p>
	    		    <ul class="ci" style="list-style-type: none; overflow: hidden;display:none" id="list_ci_9965">
				    					<li style="width:30%; float: left;padding-left:2px">
					    Hershey's Pizza Tail					    					    <input type="text" size="5" name="ci[9965][45377]" value="0.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Reese's Pizza Tail					    					    <input type="text" size="5" name="ci[9965][45378]" value="0.00">
					</li>
				    	    		    </ul>
	    		</li>
	    		<li>
	    		    <p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
	    			<input onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()}); if(this.checked){ $('list_ci_10089').show();}" type="radio" name="ci_radio" value="10089" id="radio_ci_10089">
	    			<label for="radio_ci_10089">Chicken 3$</label>
	    		    </p>
	    		    <ul class="ci" style="list-style-type: none; overflow: hidden;display:none" id="list_ci_10089">
				    					<li style="width:30%; float: left;padding-left:2px">
					    Chicken					    					    <input type="text" size="5" name="ci[10089][46044]" value="3.00">
					</li>
				    	    		    </ul>
	    		</li>
	    		<li>
	    		    <p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
	    			<input onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()}); if(this.checked){ $('list_ci_10240').show();}" type="radio" name="ci_radio" value="10240" id="radio_ci_10240">
	    			<label for="radio_ci_10240">Cookie dough</label>
	    		    </p>
	    		    <ul class="ci" style="list-style-type: none; overflow: hidden;display:none" id="list_ci_10240">
				    					<li style="width:30%; float: left;padding-left:2px">
					    Naked					    					    <input type="text" size="5" name="ci[10240][46844]" value="0.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Fluffernutter					    					    <input type="text" size="5" name="ci[10240][46845]" value="0.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Cookies &amp; Cream					    					    <input type="text" size="5" name="ci[10240][46846]" value="0.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Hazelnut with Chocolate &amp; Caramel					    					    <input type="text" size="5" name="ci[10240][46847]" value="0.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Smore's					    					    <input type="text" size="5" name="ci[10240][46848]" value="0.00">
					</li>
				    	    		    </ul>
	    		</li>
	    		<li>
	    		    <p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
	    			<input onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()}); if(this.checked){ $('list_ci_10241').show();}" type="radio" name="ci_radio" value="10241" id="radio_ci_10241">
	    			<label for="radio_ci_10241">Pizza TAILS</label>
	    		    </p>
	    		    <ul class="ci" style="list-style-type: none; overflow: hidden;display:none" id="list_ci_10241">
				    					<li style="width:30%; float: left;padding-left:2px">
					    Pot of Gold Pizza Tail					    					    <input type="text" size="5" name="ci[10241][42713]" value="0.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Smores Marshmallow Fluff Tail					    					    <input type="text" size="5" name="ci[10241][42716]" value="0.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Nutella Pizza Tail					    					    <input type="text" size="5" name="ci[10241][42717]" value="0.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Chef's Choice Pizza Tail					    					    <input type="text" size="5" name="ci[10241][45519]" value="0.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Reese's Pieces Parfait Tail					    					    <input type="text" size="5" name="ci[10241][50694]" value="0.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Chocolate Bar Lovers Tail					    					    <input type="text" size="5" name="ci[10241][50695]" value="0.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Cookies &amp; Cream Tail					    					    <input type="text" size="5" name="ci[10241][50721]" value="0.00">
					</li>
				    	    		    </ul>
	    		</li>
	    		<li>
	    		    <p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
	    			<input onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()}); if(this.checked){ $('list_ci_10534').show();}" type="radio" name="ci_radio" value="10534" id="radio_ci_10534">
	    			<label for="radio_ci_10534">NEW POUTINE FORMAT Step 1- Fries Selection</label>
	    		    </p>
	    		    <ul class="ci" style="list-style-type: none; overflow: hidden;display:none" id="list_ci_10534">
				    					<li style="width:30%; float: left;padding-left:2px">
					    Classic crispy coated					    					    <input type="text" size="5" name="ci[10534][48360]" value="0.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Home cut spiral					    					    <input type="text" size="5" name="ci[10534][48361]" value="0.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Wedges					    					    <input type="text" size="5" name="ci[10534][48362]" value="0.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Tots					    					    <input type="text" size="5" name="ci[10534][48363]" value="0.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Onion Rings					    					    <input type="text" size="5" name="ci[10534][48364]" value="0.00">
					</li>
				    	    		    </ul>
	    		</li>
	    		<li>
	    		    <p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
	    			<input onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()}); if(this.checked){ $('list_ci_10537').show();}" type="radio" name="ci_radio" value="10537" id="radio_ci_10537">
	    			<label for="radio_ci_10537">NEW POUTINE FORMAT Step 4- More Toppings Selection</label>
	    		    </p>
	    		    <ul class="ci" style="list-style-type: none; overflow: hidden;display:none" id="list_ci_10537">
				    					<li style="width:30%; float: left;padding-left:2px">
					    Green Peppers					    					    <input type="text" size="5" name="ci[10537][37052]" value="1.00,2.00,3.00,4.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Onions					    					    <input type="text" size="5" name="ci[10537][37053]" value="1.00,2.00,3.00,4.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Mushrooms					    					    <input type="text" size="5" name="ci[10537][37054]" value="1.00,2.00,3.00,4.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Green Olives					    					    <input type="text" size="5" name="ci[10537][37055]" value="1.00,2.00,3.00,4.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Black Olives					    					    <input type="text" size="5" name="ci[10537][37056]" value="1.00,2.00,3.00,4.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Dill Pickle					    					    <input type="text" size="5" name="ci[10537][37057]" value="1.00,2.00,3.00,4.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Tomatoes					    					    <input type="text" size="5" name="ci[10537][37058]" value="1.00,2.00,3.00,4.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Pineapple					    					    <input type="text" size="5" name="ci[10537][37059]" value="1.00,2.00,3.00,4.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Hot Peppers					    					    <input type="text" size="5" name="ci[10537][37060]" value="1.00,2.00,3.00,4.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Jalapeno					    					    <input type="text" size="5" name="ci[10537][37061]" value="1.00,2.00,3.00,4.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Pepperoni					    					    <input type="text" size="5" name="ci[10537][37062]" value="1.00,2.00,3.00,4.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Italian Sausage					    					    <input type="text" size="5" name="ci[10537][37063]" value="1.00,2.00,3.00,4.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Bacon					    					    <input type="text" size="5" name="ci[10537][37064]" value="1.00,2.00,3.00,4.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Ham					    					    <input type="text" size="5" name="ci[10537][37065]" value="1.00,2.00,3.00,4.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Meatballs					    					    <input type="text" size="5" name="ci[10537][37066]" value="1.00,2.00,3.00,4.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Ground Beef					    					    <input type="text" size="5" name="ci[10537][37068]" value="1.00,2.00,3.00,4.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Donair Meat					    					    <input type="text" size="5" name="ci[10537][37069]" value="1.00,2.00,3.00,4.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Extra Cheese					    					    <input type="text" size="5" name="ci[10537][37070]" value="1.00,2.00,3.00,4.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Cheddar					    					    <input type="text" size="5" name="ci[10537][37071]" value="1.00,2.00,3.00,4.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Feta Cheese					    					    <input type="text" size="5" name="ci[10537][37072]" value="1.00,2.00,3.00,4.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Bacon					    					    <input type="text" size="5" name="ci[10537][37274]" value="1.00,2.00,3.00,4.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Extra Cheese					    					    <input type="text" size="5" name="ci[10537][37276]" value="1.00,2.00,3.00,4.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Sour Cream					    					    <input type="text" size="5" name="ci[10537][44095]" value="1.49">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Nacho Cheese Sauce					    					    <input type="text" size="5" name="ci[10537][44096]" value="1.49">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Extra Gravy (4oz)					    					    <input type="text" size="5" name="ci[10537][48365]" value="1.99">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Creamy Garlic					    					    <input type="text" size="5" name="ci[10537][48382]" value="1.49">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Ranch sauce					    					    <input type="text" size="5" name="ci[10537][48383]" value="1.49">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Cheddar Chipotle					    					    <input type="text" size="5" name="ci[10537][48384]" value="1.49">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Marinara sauce					    					    <input type="text" size="5" name="ci[10537][48385]" value="1.49">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Donair sauce					    					    <input type="text" size="5" name="ci[10537][48386]" value="1.49">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    BBQ sauce					    					    <input type="text" size="5" name="ci[10537][48387]" value="1.49">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Hot sauce					    					    <input type="text" size="5" name="ci[10537][48388]" value="1.49">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Mild sauce					    					    <input type="text" size="5" name="ci[10537][48389]" value="1.49">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Medium sauce					    					    <input type="text" size="5" name="ci[10537][48390]" value="1.49">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Honey Garlic					    					    <input type="text" size="5" name="ci[10537][48391]" value="1.49">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Honey Mustard sauce					    					    <input type="text" size="5" name="ci[10537][48392]" value="1.49">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Sweet Chili Thai sauce					    					    <input type="text" size="5" name="ci[10537][48393]" value="1.49">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Caesar sauce					    					    <input type="text" size="5" name="ci[10537][48394]" value="1.49">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Plum sauce					    					    <input type="text" size="5" name="ci[10537][48395]" value="1.49">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Maple Bacon BBQ Sauce					    					    <input type="text" size="5" name="ci[10537][48396]" value="1.49">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Nacho Cheese Sauce					    					    <input type="text" size="5" name="ci[10537][48397]" value="1.49">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Extra Vegan Cheese					    					    <input type="text" size="5" name="ci[10537][49544]" value="1.99,2.99,3.99,4.99">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Onion Crisps					    					    <input type="text" size="5" name="ci[10537][51957]" value="0.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Jalapeño Crisps					    					    <input type="text" size="5" name="ci[10537][51958]" value="0.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Batter Bits					    					    <input type="text" size="5" name="ci[10537][51959]" value="0.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Grilled Chicken					    					    <input type="text" size="5" name="ci[10537][52453]" value="2.00,3.00,4.00,5.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Popcorn Chicken					    					    <input type="text" size="5" name="ci[10537][52454]" value="2.00,3.00,4.00,5.00">
					</li>
				    	    		    </ul>
	    		</li>
	    		<li>
	    		    <p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
	    			<input onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()}); if(this.checked){ $('list_ci_11005').show();}" type="radio" name="ci_radio" value="11005" id="radio_ci_11005">
	    			<label for="radio_ci_11005">Medium Cheese Pizza for FRIDAY SPECIAL FISH &amp; CHIPS</label>
	    		    </p>
	    		    <ul class="ci" style="list-style-type: none; overflow: hidden;display:none" id="list_ci_11005">
				    					<li style="width:30%; float: left;padding-left:2px">
					    Medium Cheese Pizza					    					    <input type="text" size="5" name="ci[11005][50848]" value="9.95">
					</li>
				    	    		    </ul>
	    		</li>
	    		<li>
	    		    <p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
	    			<input onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()}); if(this.checked){ $('list_ci_11505').show();}" type="radio" name="ci_radio" value="11505" id="radio_ci_11505">
	    			<label for="radio_ci_11505">Wing (each 0.69) ( 5 or 10 or 20)</label>
	    		    </p>
	    		    <ul class="ci" style="list-style-type: none; overflow: hidden;display:none" id="list_ci_11505">
				    					<li style="width:30%; float: left;padding-left:2px">
					    1 Wing (each)					    					    <input type="text" size="5" name="ci[11505][53413]" value="0.69">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    5 Wings					    					    <input type="text" size="5" name="ci[11505][53414]" value="3.45">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    10 Wings					    					    <input type="text" size="5" name="ci[11505][53415]" value="6.90">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    20 Wings					    					    <input type="text" size="5" name="ci[11505][53416]" value="13.80">
					</li>
				    	    		    </ul>
	    		</li>
					        	   </ul>
</div>

notice that only the Pizza Toppings without Premium was checked:

<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
	    			<input checked="" onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()}); if(this.checked){ $('list_ci_8174').show();}" type="radio" name="ci_radio" value="8174" id="radio_ci_8174">
	    			<label for="radio_ci_8174">Pizza Toppings without Premium</label>
</p>

I want you to scrape only the modifier groups that were checked (checked="").

After scraping the modifier groups, you will need to scrape the dish modifiers of each modifier group.

### dish_modifiers and dish_modifier_prices tables:

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

### Modifier Groups Details:

After scraping the dish modifiers of each modifier group I want you to check this html section:

<li>
		<p><input type="checkbox" id="hasBread" name="hasBread" value="Y" onclick="if(this.checked){ $('breadNo').show();$('br_id').appear() } else { $('br_id').fade(); $('breadNo').hide() }"> <label for="hasBread">Has Bread</label></p>
		<p id="breadNo" style="display: none;padding-left:20px">
			<label for="breadHeader">Use this title</label><input type="text" name="breadHeader" id="breadHeader" value="Bread Selection"><br>
		    <label for="displayOrderBread">Display Order</label><input type="text" name="displayOrderBread" id="displayOrderBread" value="1" size="3">
		</p>
		<p><input type="checkbox" id="hasCustomisation" name="hasCustomisation" checked="" value="Y" onclick="if(this.checked){ $('ciNo').show();$('ci_id').appear() } else { $('ci_id').fade(); $('ciNo').hide() }"> <label for="hasCustomisation">Has Custom Ingredients</label></p>
		<p id="ciNo" style="padding-left: 20px;">
			<label for="ciHeader">Use this title</label><input type="text" name="ciHeader" id="ciHeader" value="First 4 Toppings Free"><br>
		    <label for="minci" style="display: inline">Min custom items: </label><input type="text" name="minci" id="minci" size="3" value="1"><br>
		    <label for="maxci" style="display: inline">Max custom items: </label><input type="text" name="maxci" id="maxci" size="3" value="0"><br>
		    <label for="freeCI" style="display: inline">Free items: </label><input type="text" name="freeci" id="freeCI" size="3" value="4"><br>
		    <label for="displayOrderCI">Display Order</label><input type="text" name="displayOrderCI" id="displayOrderCI" value="2" size="3">
		</p>
		<p><input type="checkbox" id="hasDressing" name="hasDressing" value="Y" onclick="if(this.checked){ $('dressingNo').show();$('dr_id').appear() } else { $('dr_id').fade(); $('dressingNo').hide() }"> <label for="hasDressing">Has Dressing</label></p>
		<p id="dressingNo" style="display: none;padding-left:20px">
			<label for="dressingHeader">Use this title</label><input type="text" name="dressingHeader" id="dressingHeader" value="Dressing"><br>
		    <label for="minDressing" style="display: inline">Min dressings: </label><input type="text" name="mindressing" id="minDressing" size="3" value="1"><br>
		    <label for="maxDressing" style="display: inline">Max dressings: </label><input type="text" name="maxdressing" id="maxDressing" size="3" value="1"><br>
		    <label for="freeDressing" style="display: inline">Free items: </label><input type="text" name="freeDressing" id="freeDressing" size="3" value="0"><br>
		    <label for="displayOrderDressing">Display Order</label><input type="text" name="displayOrderDressing" id="displayOrderDressing" value="3" size="3">
		</p>
		<p><input type="checkbox" id="hasSauce" name="hasSauce" value="Y" onclick="if(this.checked){ $('sauceNo').show();$('sa_id').appear() } else { $('sa_id').fade(); $('sauceNo').hide() }"> <label for="hasSauce">Has Sauce</label></p>
		<p id="sauceNo" style="display: none;padding-left:20px">
			<label for="sauceHeader">Use this title</label><input type="text" name="sauceHeader" id="sauceHeader" value="Sauces"><br>
		    <label for="minSauce" style="display: inline">Min sauces: </label><input type="text" name="minsauce" id="minSauce" size="3" value="1"><br>
		    <label for="maxSauce" style="display: inline">Max sauces: </label><input type="text" name="maxsauce" id="maxSauce" size="3" value="1"><br>
		    <label for="freeSauce" style="display: inline">Free items: </label><input type="text" name="freeSauce" id="freeSauce" size="3" value="0"><br>
		    <label for="displayOrderSauce">Display Order</label><input type="text" name="displayOrderSauce" id="displayOrderSauce" value="4" size="3">
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
			<label for="drinksHeader">Use this title</label><input type="text" name="drinksHeader" id="drinksHeader" value="Drinks"><br>
		    <label for="minDrink" style="display: inline">Min drinks: </label><input type="text" name="mindrink" id="minDrink" size="3" value="1"><br>
		    <label for="maxDrink" style="display: inline">Max drinks: </label><input type="text" name="maxdrink" id="maxDrink" size="3" value="1"><br>
		    <label for="freeDrink" style="display: inline">Free items: </label><input type="text" name="freeDrink" id="freeDrink" size="3" value="0"><br>
		    <label for="displayOrderDrink">Display Order</label><input type="text" name="displayOrderDrink" id="displayOrderDrink" value="6" size="3">
		</p>
		<p><input type="checkbox" id="hasExtras" name="hasExtras" checked="" value="Y" onclick="if(this.checked){ $('extraNo').show();$('e_id').appear() } else { $('e_id').fade(); $('extraNo').hide() }"> <label for="hasExtras">Has Extras</label></p>
		<p id="extraNo" style="padding-left: 20px;">
			<label for="extraHeader">Use this title</label><input type="text" name="extraHeader" id="extraHeader" value="Extras"><br>
		    <label for="minExtra" style="display: inline">Min extras: </label><input type="text" name="minextras" id="minExtra" size="3" value="0"><br>
		    <label for="maxExtra" style="display: inline">Max extras: </label><input type="text" name="maxextras" id="maxExtra" size="3" value="0"><br>
		    <label for="freeExtra" style="display: inline">Free items: </label><input type="text" name="freeExtra" id="freeExtra" size="3" value="0"><br>
		    <label for="displayOrderExtras">Display Order</label><input type="text" name="displayOrderExtras" id="displayOrderExtras" value="7" size="3">
		</p>
		<p><input type="checkbox" id="hasCookMethod" name="hasCookMethod" value="Y" onclick="if(this.checked){ $('cmNo').show();$('cm_id').appear(); } else { $('cm_id').fade(); $('cmNo').hide() }"> <label for="hasCookMethod">Has Cooking Method</label></p>
		<p id="cmNo" style="display: none;padding-left:20px">
			<label for="cmHeader">Use this title</label><input type="text" name="cmHeader" id="cmHeader" value="Cooking Method"><br>
		    <label for="displayOrderCM">Display Order</label><input type="text" name="displayOrderCM" id="displayOrderCM" value="8" size="3">
		</p>
		<p>
		    <input type="checkbox" id="showPizzaIcons" value="Y" name="showPizzaIcons"> <label for="showPizzaIcons">Show Pizza Icons</label>
		</p>
		<p>
		    <input type="checkbox" id="showInMenu" value="Y" name="showInMenu"> <label for="showInMenu">Show dish in menu</label>
		</p>
                <p>
                    <input type="checkbox" id="checkoutItems" value="Y" name="checkoutItems" checked=""> <label for="checkoutItems">Checkout Items</label>
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
			<label for="ciHeader">Use this title</label><input type="text" name="ciHeader" id="ciHeader" value="First 4 Toppings Free"><br>
		    <label for="minci" style="display: inline">Min custom items: </label><input type="text" name="minci" id="minci" size="3" value="1"><br>
		    <label for="maxci" style="display: inline">Max custom items: </label><input type="text" name="maxci" id="maxci" size="3" value="0"><br>
		    <label for="freeCI" style="display: inline">Free items: </label><input type="text" name="freeci" id="freeCI" size="3" value="4"><br>
		    <label for="displayOrderCI">Display Order</label><input type="text" name="displayOrderCI" id="displayOrderCI" value="2" size="3">
</p>

modifier_groups.name:
Replace the name of scraped modifier group with the value of the label for="ciHeader">Use this title</label><input type="text" name="ciHeader" id="ciHeader" value="First 4 Toppings Free"><br>

min_selections:
<label for="minci" style="display: inline">Min custom items: </label><input type="text" name="minci" id="minci" size="3" value="1">

max_selections:
<label for="maxci" style="display: inline">Max custom items: </label>
<input type="text" name="maxci" id="maxci" size="3" value="0">

free_items:
<label for="freeCI" style="display: inline">Free items: </label>
<input type="text" name="freeci" id="freeCI" size="3" value="4">

display_order:
<label for="displayOrderCI">Display Order</label>
<input type="text" name="displayOrderCI" id="displayOrderCI" value="2" size="3">

### dish_availability

Finally, verify if the current dish should be hidden on certain days. By scraping this html section:

<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:10px">Hide dish on</p>

<div class="ingredientGroups" style="border-width:0 1px 1px 1px; border-style: solid;border-color: #aaa;margin-bottom:2px;padding:2px">
                            <input type="checkbox" name="hideOnDays[]" value="mon" id="d_mon" style="vertical-align: center" checked=""> <label for="d_mon" style="vertical-align: center">Monday</label>
                            <input type="checkbox" name="hideOnDays[]" value="tue" id="d_tue" style="vertical-align: center"> <label for="d_tue" style="vertical-align: center">Tuesday</label>
                            <input type="checkbox" name="hideOnDays[]" value="wed" id="d_wed" style="vertical-align: center" checked=""> <label for="d_wed" style="vertical-align: center">Wednersday</label>
                            <input type="checkbox" name="hideOnDays[]" value="thu" id="d_thu" style="vertical-align: center" checked=""> <label for="d_thu" style="vertical-align: center">Thursday</label>
                            <input type="checkbox" name="hideOnDays[]" value="fri" id="d_fri" style="vertical-align: center" checked=""> <label for="d_fri" style="vertical-align: center">Friday</label>
                            <input type="checkbox" name="hideOnDays[]" value="sat" id="d_sat" style="vertical-align: center" checked=""> <label for="d_sat" style="vertical-align: center">Saturday</label>
                            <input type="checkbox" name="hideOnDays[]" value="sun" id="d_sun" style="vertical-align: center" checked=""> <label for="d_sun" style="vertical-align: center">Sunday</label>            
</div>


