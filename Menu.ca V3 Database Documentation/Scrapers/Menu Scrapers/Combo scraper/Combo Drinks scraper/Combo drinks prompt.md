Summary of Skip Conditions
#	Skip Condition	Log Level
1	div#d_id not found	Silent (debug)
2	div#d_id has style="display: none"	Silent (debug)
3	input#hasDrinks checkbox not found	Silent (debug)
4	input#hasDrinks checkbox not checked	Silent (debug)
5	No radio button (d_radio) is checked	Silent (debug)
6	V3 dish not found by combo_id	⚠️ WARNING
7	Modifier group not found (exact + fallback)	⚠️ WARNING




# V3 Menu Schema (menuca_v3)

# Core Menu Tables


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

# Instructions with example for Mano City Pizza (V3: 118, V1: 238)

1. In the landing page you will find the v1 restaurants under an <ul id="active"> element. Each V1 restaurant is stored in an <li> element:

Each <li> element has an <a> element containing a link to the details page of each restaurant. This <a> element also contians the unique v1 id that identifies each restaurant. For instance the restaurant Mano City Pizza the a element contains its v1 id (383) in the href parameter <a href="/?p=restaurants&amp;display=editRestaurant&amp;restaurant=238">Edit</a>. You should use this element to both identify the v1 restaurants that must be scraped and access its details page where the data that needs to be scrapped is located.

2. Once you get to the details page of each restaurant you need to click this <a> element to navigate to the menu details:
<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=238&amp;load=menu&amp;showLang=en">Menu</a> this will take you tohttps://menuadmin.menu.ca/?p=restaurants&display=editRestaurant&restaurant=238&load=menu&showLang=en

3. In the Menu details page you will find different courses, each with its own dishes. All courses and dishes per course are located within a div with this signature:
<div style="width:500px; float: left;"> 

Now, we are only looking to scrape the combo dishes. So only scrape dishes that have this attribute in their href element: combo=

For example, the Mano City Pizza Restaurant  has a course called Everyday Specials. Some of the dishes under this course contain an <a> element with an href attribute ending with combo=. This means that all the dishes under this course that that end with combo= in the href attribute should be scraped:

<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=238&amp;load=editCombo&amp;showLang=en&amp;combo=96394">Pizza &amp; Wings</a>to enter the dish details:

5. In the dish details (https://menuadmin.menu.ca/?p=restaurants&display=editRestaurant&restaurant=238&load=editCombo&showLang=en&combo=96394) check for this element: 

<li>
    <p><input type="checkbox" id="hasDrinks" name="hasDrinks" checked="" onclick="if(this.checked){ $('d_id').appear();$('drinksNo').show(); } else { $('d_id').fade();$('drinksNo').hide() }" value="Y"> <label for="hasDrinks">Has Drinks</label></p>
    <p id="drinksNo" style="padding-left: 20px;">
        <label for="drinksHeader">Use this title</label><input type="text" name="drinksHeader" id="drinksHeader" value="Choose 2 Cans"><br>
        <label for="minDrink" style="display: inline">Min drinks: </label><input type="text" name="mindrink" id="minDrink" size="3" value="2"><br>
        <label for="maxDrink" style="display: inline">Max drinks: </label><input type="text" name="maxdrink" id="maxDrink" size="3" value="2"><br>
        <label for="freeDrink" style="display: inline">Free items: </label><input type="text" name="freeDrink" id="freeDrink" size="3" value="0"><br>
    </p>
</li>

if the input#hasDrinks checkbox is not found or input#hasDrinks checkbox not checked skip this dish and continue with the next.

The data that we need to scrape (modifier_groups.name, .modifier_groups, modifier_groups.min_selections,modifier_groups.max_selections,modifier_groups.free_items,modifier_groups.display_order) is located within this html section

modifier_groups.name: <label for="drinksHeader">Use this title</label><input type="text" name="drinksHeader" id="drinksHeader" value="Choose 2 Cans">

modifier_groups.min_selection:<label for="minDrink" style="display: inline">Min drinks: </label><input type="text" name="mindrink" id="minDrink" size="3" value="2"><br>

modifier_groups.max_selection:  <label for="maxDrink" style="display: inline">Max drinks: </label><input type="text" name="maxdrink" id="maxDrink" size="3" value="2"><br>

modifier_groups.free items: <label for="freeDrink" style="display: inline">Free items: </label><input type="text" name="freeDrink" id="freeDrink" size="3" value="0"><br>
___________________________________________________________________________________________________
<div id="d_id" style="">
                <p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px">Drinks</p>
                <div style="border-width:0 1px 1px 1px; border-style: solid;border-color: #aaa;margin-bottom:2px;padding:1px">
                    <ul id="uld" style="list-style-type:none;overflow: hidden">
                                <li>
                                    <p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                                        <input checked="" onclick="$$('#uld ul[class=\'d\']').each(function(u){$(u.id).hide()}); if(this.checked){ $('list_d_2052').show();}" type="radio" name="d_radio" value="2052" id="radio_d_2052">
                                        <label for="radio_d_2052">Drinks can</label>
                                    </p>
                                    <ul class="d" style="list-style-type: none; overflow: hidden;display:" id="list_d_2052">
                                                                                              <li style="width:30%; float: left;padding-left:2px">
                                                    Pepsi                                                    <input type="text" size="5" name="d[2052][9349]" value="0.00">
                                                </li>
                                                                                            <li style="width:30%; float: left;padding-left:2px">
                                                    Coke                                                    <input type="text" size="5" name="d[2052][9350]" value="0.00">
                                                </li>
                                                                                            <li style="width:30%; float: left;padding-left:2px">
                                                    Diet Pepsi                                                    <input type="text" size="5" name="d[2052][9351]" value="0.00">
                                                </li>
                                                                                            <li style="width:30%; float: left;padding-left:2px">
                                                    Diet Coke                                                    <input type="text" size="5" name="d[2052][9352]" value="0.00">
                                                </li>
                                                                                            <li style="width:30%; float: left;padding-left:2px">
                                                    Ginger Ale                                                    <input type="text" size="5" name="d[2052][9353]" value="0.00">
                                                </li>
                                                                                            <li style="width:30%; float: left;padding-left:2px">
                                                    Sprite                                                    <input type="text" size="5" name="d[2052][9354]" value="0.00">
                                                </li>
                                                                                            <li style="width:30%; float: left;padding-left:2px">
                                                                                                        <input type="text" size="5" name="d[2052][9355]" value="0.00">
                                                </li>
                                                                                            <li style="width:30%; float: left;padding-left:2px">
                                                                                                        <input type="text" size="5" name="d[2052][9356]" value="0.00">
                                                </li>
                                                                                            <li style="width:30%; float: left;padding-left:2px">
                                                    Iced Tea                                                    <input type="text" size="5" name="d[2052][9358]" value="0.00">
                                                </li>
                                                                                                                        </ul>
                                </li>
                                                                        </ul>
                </div>
            </div>

If the dish details page does not have this element skip it and continue with the next one. 

If it does I want you to query menuca_v3.modifier_groups and find a modifier group with this name: <label for="radio_d_2052">Drinks can</label>

6. Once you found the correct modifier group for the current dish, look for this element:

<li>
    <p><input type="checkbox" id="hasDrinks" name="hasDrinks" checked="" onclick="if(this.checked){ $('d_id').appear();$('drinksNo').show(); } else { $('d_id').fade();$('drinksNo').hide() }" value="Y"> <label for="hasDrinks">Has Drinks</label></p>
    <p id="drinksNo" style="padding-left: 20px;">
        <label for="drinksHeader">Use this title</label><input type="text" name="drinksHeader" id="drinksHeader" value="Drinks"><br>
        <label for="minDrink" style="display: inline">Min drinks: </label><input type="text" name="mindrink" id="minDrink" size="3" value="2"><br>
        <label for="maxDrink" style="display: inline">Max drinks: </label><input type="text" name="maxdrink" id="maxDrink" size="3" value="2"><br>
        <label for="freeDrink" style="display: inline">Free items: </label><input type="text" name="freeDrink" id="freeDrink" size="3" value="0"><br>
    </p>
</li>

 The data that we need to scrape (modifier_groups.name, .modifier_groups, modifier_groups.min_selections,modifier_groups.max_selections,modifier_groups.free_items,modifier_groups.display_order) is located within this html section

modifier_groups.name: <label for="drinksHeader">Use this title</label><input type="text" name="drinksHeader" id="drinksHeader" value="Drinks"><br>

modifier_groups.min_selection:<label for="minDrink" style="display: inline">Min drinks: </label><input type="text" name="mindrink" id="minDrink" size="3" value="2"><br>

modifier_groups.max_selection:  <label for="maxDrink" style="display: inline">Max drinks: </label><input type="text" name="maxdrink" id="maxDrink" size="3" value="2"><br>

modifier_groups.free items: <label for="freeDrink" style="display: inline">Free items: </label><input type="text" name="freeDrink" id="freeDrink" size="3" value="0"><br>