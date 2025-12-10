# This scraper will have two phases:

## Phase 1: Scrape all Combo Groups 
Go over the all the 5 phase 2 restaurants and verify if it has combo groups and if it does store all the combo groups, combo group sections, combo modifier groups, combo modifiers and combo modifier prices for each restaurant

## Phase 2:
Go over each menu data for each of the 5 restaurants in the legacy V1 CRM, scrape their courses, dishes, mnodifier groups, modifiers, prices. Link all combo dishes it to the right combo group ID so we can map the right modifiers to it. 


# Mapping for the scraping process:
We will use the legacy V1 CRM to scrape the data. Each restaurant in the phase 1 has a legacy_v1_id. This should be our primary criteria to determine which restaurant should be scraped in the v1 scraper.


## The restaurants to be scraped:
	V3 ID	V1 ID	Restaurant	Reason for Phase 2
	265	411	Milano - 2 Pembroke	19.3% price coverage
	607	830	Aroy Thai	30.8% price coverage + 0 modifiers
	924	1013	All Out Burger Bank St.	Completely empty
	948	1038	All Out Burger Gladstone	Completely empty
	949	1071	All Out Burger Montreal Rd	Completely empty
	636 863		Joes Family Pizzeria 

# V3 Menu Schema (menuca_v3)

## Core Menu Tables

### courses (Categories)
Menu categories/sections (e.g., "Appetizers", "Main Course", "Specials")

| Column | Type | Description |
|--------|------|-------------|
| id | BIGSERIAL | Primary Key |
| uuid | UUID | External identifier |
| restaurant_id | BIGINT | FK → restaurants.id |
| name | VARCHAR(255) NOT NULL | Category name |
| description | TEXT | Category description |
| display_order | INTEGER | Sort order (default: 0) |
| is_active | BOOLEAN | Active status (default: TRUE) |
| image_url | VARCHAR(500) | Category image |
| parent_course_id | BIGINT | FK → courses.id (for subcategories) |
| source_system | VARCHAR(10) | v1 or v2 |
| source_id | BIGINT | Original system ID |
| legacy_v1_id | INTEGER | V1 migration reference |
| legacy_v2_id | INTEGER | V2 migration reference |
| created_at | TIMESTAMPTZ | Creation timestamp |
| updated_at | TIMESTAMPTZ | Last update timestamp |
| deleted_at | TIMESTAMPTZ | Soft delete timestamp |

---

### dishes (Menu Items)
Individual menu items/products

| Column | Type | Description |
|--------|------|-------------|
| id | BIGSERIAL | Primary Key |
| uuid | UUID | External identifier |
| restaurant_id | BIGINT | FK → restaurants.id |
| course_id | BIGINT | FK → courses.id |
| name | VARCHAR(255) NOT NULL | Dish name |
| description | TEXT | Dish description |
| ingredients | TEXT | Ingredient list |
| sku | VARCHAR(50) | Stock keeping unit |
| display_order | INTEGER | Sort order (default: 0) |
| image_url | VARCHAR(500) | Dish image |
| is_combo | BOOLEAN | Is combo meal (default: FALSE) |
| has_customization | BOOLEAN | Has modifiers (default: FALSE) |
| quantity | VARCHAR(255) | Quantity description |
| is_upsell | BOOLEAN | Upsell item (default: FALSE) |
| is_active | BOOLEAN | Active status (default: TRUE) |
| hide_option_enabled | BOOLEAN | Has day-based hiding (default: FALSE) |
| source_system | VARCHAR(10) | v1 or v2 |
| source_id | BIGINT | Original system ID |
| legacy_v1_id | INTEGER | V1 migration reference |
| legacy_v2_id | INTEGER | V2 migration reference |
| notes | TEXT | Internal notes |
| allergen_info | JSONB | Allergen data |
| nutritional_info | JSONB | Nutrition data |
| search_vector | TSVECTOR | Full-text search (generated) |
| unavailable_until_at | TIMESTAMPTZ | Temporary unavailability |
| created_at | TIMESTAMPTZ | Creation timestamp |
| updated_at | TIMESTAMPTZ | Last update timestamp |
| deleted_at | TIMESTAMPTZ | Soft delete timestamp |

---

### dish_prices
Base dish pricing with size variants

| Column | Type | Description |
|--------|------|-------------|
| id | BIGSERIAL | Primary Key |
| dish_id | BIGINT | FK → dishes.id |
| size_code | VARCHAR(50) | Size identifier (e.g., "SM", "MD", "LG") |
| size_label | VARCHAR(100) | Size display name (e.g., "Small", "Medium") |
| price | NUMERIC(10,2) NOT NULL | Price amount |
| is_default | BOOLEAN | Default size (default: FALSE) |
| display_order | INTEGER | Sort order (default: 0) |
| created_at | TIMESTAMPTZ | Creation timestamp |
| updated_at | TIMESTAMPTZ | Last update timestamp |

---

### modifier_groups
Groups of related modifiers (e.g., "Size", "Toppings", "Drinks")

| Column | Type | Description |
|--------|------|-------------|
| id | BIGSERIAL | Primary Key |
| dish_id | BIGINT | FK → dishes.id |
| name | VARCHAR(100) NOT NULL | Group name |
| is_required | BOOLEAN | Selection required (default: FALSE) |
| min_selections | INTEGER | Minimum selections (default: 0) |
| max_selections | INTEGER | Maximum selections (default: 1) |
| free_items | SMALLINT | Free items count (default: 0) |
| display_order | INTEGER | Sort order (default: 0) |
| parent_modifier_id | BIGINT | FK → modifier_groups.id (for nested groups) |
| instructions | TEXT | User instructions |
| course_template_id | INTEGER | FK to template |
| is_custom | BOOLEAN | Custom or template (default: TRUE) |
| created_at | TIMESTAMPTZ | Creation timestamp |
| updated_at | TIMESTAMPTZ | Last update timestamp |
| deleted_at | TIMESTAMPTZ | Soft delete timestamp |

---

### dish_modifiers
Individual modifier options within a group

| Column | Type | Description |
|--------|------|-------------|
| id | BIGSERIAL | Primary Key |
| uuid | UUID | External identifier |
| restaurant_id | BIGINT | FK → restaurants.id |
| dish_id | BIGINT | FK → dishes.id |
| modifier_group_id | BIGINT | FK → modifier_groups.id |
| name | VARCHAR(100) | Modifier name |
| modifier_type | VARCHAR(50) | Type classification |
| display_order | INTEGER | Sort order |
| is_default | BOOLEAN | Pre-selected (default: FALSE) |
| is_included | BOOLEAN | Included in base price (default: FALSE) |
| source_system | VARCHAR(10) | v1 or v2 |
| source_id | BIGINT | Original system ID |
| created_at | TIMESTAMPTZ | Creation timestamp |
| updated_at | TIMESTAMPTZ | Last update timestamp |
| deleted_at | TIMESTAMPTZ | Soft delete timestamp |

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

| Column | Type | Description |
|--------|------|-------------|
| id | BIGSERIAL | Primary Key |
| uuid | UUID | External identifier |
| dish_modifier_id | BIGINT | FK → dish_modifiers.id |
| dish_id | BIGINT | FK → dishes.id |
| restaurant_id | BIGINT | FK → restaurants.id |
| size_variant | VARCHAR(50) | Size (Small/Medium/Large/X-Large) |
| price | NUMERIC(10,2) NOT NULL | Price amount (default: 0.00) |
| display_order | INTEGER | Sort order (default: 1) |
| is_active | BOOLEAN | Active status (default: TRUE) |
| source_system | VARCHAR(20) | v1 or v2 |
| created_at | TIMESTAMPTZ | Creation timestamp |
| updated_at | TIMESTAMPTZ | Last update timestamp |
| deleted_at | TIMESTAMPTZ | Soft delete timestamp |

---

## Combo Tables

### 1. combo_groups
Root table for combo configurations. **Only table with restaurant_id**.

| Column | Type | Description |
|--------|------|-------------|
| id | BIGSERIAL | Primary Key |
| restaurant_id | BIGINT | FK → restaurants.id |
| name | TEXT NOT NULL | Combo group name |
| number_of_items | INT | Number of items in combo |
| display_header | VARCHAR(255) | Header text for display |
| source_id | INT | V1 combo group ID |
| created_at | TIMESTAMPTZ | Creation timestamp |
| updated_at | TIMESTAMPTZ | Last update timestamp |
| deleted_at | TIMESTAMPTZ | Soft delete timestamp |

### 2. dish_combo_groups
Junction table for N:M relationship between dishes and combo groups.

| Column | Type | Description |
|--------|------|-------------|
| id | BIGSERIAL | Primary Key |
| dish_id | BIGINT | FK → dishes.id |
| combo_group_id | BIGINT | FK → combo_groups.id |
| is_active | BOOLEAN | Active status (default: TRUE) |
| UNIQUE | | (dish_id, combo_group_id) |

### 3. combo_group_sections
Section types: bread, custom_ingredients, dressing, sauce, side_dish, extras, cooking_method

| Column | Type | Description |
|--------|------|-------------|
| id | BIGSERIAL | Primary Key |
| combo_group_id | BIGINT | FK → combo_groups.id |
| section_type | TEXT NOT NULL | br_id, ci_id, dr_id, sa_id, sd_id, e_id, cm_id |
| use_header | VARCHAR(255) NOT NULL | Section header text |
| display_order | SMALLINT NOT NULL | Sort order |
| free_items | SMALLINT NOT NULL | Free items count (default: 0) |
| min_selection | SMALLINT NOT NULL | Minimum selections (default: 0) |
| max_selection | SMALLINT NOT NULL | Maximum selections (default: 1) |
| is_active | BOOLEAN NOT NULL | Active status (default: FALSE) |

### 4. combo_modifier_groups
Groups like "Crust Type", "Toppings", etc.

| Column | Type | Description |
|--------|------|-------------|
| id | BIGSERIAL | Primary Key |
| combo_group_section_id | BIGINT | FK → combo_group_sections.id |
| name | TEXT NOT NULL | Group name |
| type_code | TEXT | RADIO or CHECKBOX |
| is_selected | BOOLEAN | Was this checked in V1? (default: FALSE) |
| source_id | INT | V1 modifier group ID |

### 5. combo_modifiers
Individual modifier items (Regular Crust, Thick Crust, etc.)

| Column | Type | Description |
|--------|------|-------------|
| id | BIGSERIAL | Primary Key |
| combo_modifier_group_id | BIGINT | FK → combo_modifier_groups.id |
| name | TEXT NOT NULL | Modifier name |
| display_order | SMALLINT | Sort order (default: 0) |

### 6. combo_modifier_prices
Prices per size variant.

| Column | Type | Description |
|--------|------|-------------|
| id | BIGSERIAL | Primary Key |
| combo_modifier_id | BIGINT | FK → combo_modifiers.id |
| size_variant | TEXT | Small, Medium, Large, X-Large, Standard |
| price | NUMERIC(10,2) NOT NULL | Price amount |

### 7. dishes.hide_option_enabled (Column Added to Existing Table)
Boolean flag on the `dishes` table to mark dishes that have hide-on-days functionality enabled.

| Column | Type | Description |
|--------|------|-------------|
| hide_option_enabled | BOOLEAN NOT NULL | TRUE if dish uses day-based hiding (default: FALSE) |

### 8. dish_availability
Stores which days a dish is hidden (for "Hide Dish On" functionality).

| Column | Type | Description |
|--------|------|-------------|
| id | BIGSERIAL | Primary Key |
| dish_id | BIGINT | FK → dishes.id (ON DELETE CASCADE) |
| day_of_week | SMALLINT NOT NULL | 0=Sunday, 1=Monday...6=Saturday |
| is_hidden | BOOLEAN NOT NULL | Whether dish is hidden (default: TRUE) |
| created_at | TIMESTAMPTZ | Creation timestamp |
| UNIQUE | | (dish_id, day_of_week) |

**How They Work Together:**
1. `dishes.hide_option_enabled = TRUE` → dish has day-based hiding enabled
2. `dish_availability` rows → specify WHICH days the dish is hidden

**Day of Week Mapping:**

| Value | Day |
|-------|-----|
| 0 | Sunday |
| 1 | Monday |
| 2 | Tuesday |
| 3 | Wednesday |
| 4 | Thursday |
| 5 | Friday |
| 6 | Saturday |

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
|----------|-------------|
| mon | 1 |
| tue | 2 |
| wed | 3 |
| thu | 4 |
| fri | 5 |
| sat | 6 |
| sun | 0 |

## FK Chain to Get Restaurant

```
combo_modifier_prices.combo_modifier_id
    → combo_modifiers.combo_modifier_group_id
        → combo_modifier_groups.combo_group_section_id
            → combo_group_sections.combo_group_id
                → combo_groups.restaurant_id ✅
```

## Section Type Mapping

| V1 HTML ID | section_type | Description |
|------------|--------------|-------------|
| br_id | bread | Bread, crust, wraps options |
| ci_id | custom_ingredients | Toppings, ingredients customization |
| dr_id | dressing | Salad dressings, dipping options |
| sa_id | sauce | Pizza sauce, pasta sauce options |
| sd_id | side_dish | Side dish selections |
| e_id | extras | Extra add-ons |
| cm_id | cooking_method | Cooking preferences |

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

# Instructions with examples for Joes Family Pizzeria v3 ID: 636 V1 id 863:

## Phase 1

1. In the landing page you will find the v1 restaurants under an <ul id="active"> element. Each V1 restaurant is stored in an <li> element:

Each <li> element has an <a> element containing a link to the details page of each restaurant. This <a> element also contians the unique v1 id that identifies each restaurant. For instance the restaurant Joes Family Pizzeria v3 ID: 636 the a element contains its v1 id (863) in the href parameter <a href="/?p=restaurants&amp;display=editRestaurant&amp;restaurant=863">Edit</a>. You should use this element to both identify the v1 restaurants that must be scraped and access its details page where the data that needs to be scrapped is located.

2. Once you get to the details page of each restaurant you need to click this <a> element to navigate to the menu details:
<a class="active" href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=863&amp;load=menu&amp;showLang=en">Menu</a> this will take you to https://menuadmin.menu.ca/?p=restaurants&display=editRestaurant&restaurant=863&load=menu&showLang=en

3. In the menu details page search for the Combo Groups <a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=863&amp;load=comboGroups&amp;showLang=en">Combo Groups</a>. It is located inside a <div> with a style margin-left:501px;

4. Once you get to the combo groups you must check if the HTML contains any <p> element with a style of margin-top:1px;height:20px;line-height:1.5;background-color: #ccc;padding-left:20px;border:1px solid #aaa. If it doesn't continue with the next restaurant

5. If the page does contain a <p> element with a style of "margin-top:1px;height:20px;line-height:1.5;background-color: #ccc;padding-left:20px;border:1px solid #aaa" that means the current restaurant has Combos with modifiers that need to be scraped. I want you to click on the details of each combo group: 

<p style="margin-top:1px;height:20px;line-height:1.5;background-color: #ccc;padding-left:20px;border:1px solid #aaa">
	<a href="#" onclick="editGroupJS('6654');return false;">1 Topping Pizza</a>
</p>

You can extract the COMBO_GROUPS.source_id value from this link. For example, for the 1 Topping Pizza the source_id is 6654.

6. Once you are on the details of each modifier group (https://menuadmin.menu.ca/?p=restaurants&display=editRestaurant&restaurant=863&load=comboGroups&showLang=en) you must:

### Scrape the COMBO_GROUPS data:
- name: <input type="text" name="name" id="name" value="1 Topping Pizza" style="height:20px; line-height:20px;margin:2px; border:1px solid #aaa;width:420px">
- number_of_items: 
<p>
	<label for="itemcount">Number of items:</label>
	<input id="itemcount" type="text" name="itemcount" value="1" size="3">
</p>

- display_header: 
<p>
	<label for="displayHeader">Display Header</label>
	<input type="text" name="displayHeader" id="displayHeader" value="">
</p>



### COMBO_GROUP_SECTIONS, COMBO_MODIFIER_GROUPS, COMBO_MODIFIERS AND COMBO_MODIFIER_PRICES are stored inside a <div> element with id="options".

Scrape the COMBO_GROUP_SECTIONS data:
Each combo group section (Bread, Custom Ingredients, Dressing, Sauce, Side Dishes, Extras, Cooking Method) is stored these elements

For the Bread section:
<p><input checked="" type="checkbox" id="hasBread" name="hasBread" value="Y" onclick="if(this.checked){ $('breadNo').show(); $('br_id').appear(); } else {$('br_id').fade();$('breadNo').hide()}"> <label for="hasBread">Has Bread</label></p>
<p id="breadNo" style="padding-left: 20px;">
	<label for="breadHeader">Use header</label><input type="text" name="breadHeader" id="breadHeader" value=""><br>
	<label for="displayOrderBread">Display Order</label><input type="text" name="displayOrderBread" id="displayOrderBread" value="" size="3">
</p>

For the Custom Ingredients section:
<p><input checked="" type="checkbox" id="hasCustomisation" name="hasCustomisation" value="Y" onclick="if(this.checked){ $('ci_id').appear();$('ciNo').show(); } else {$('ci_id').fade();$('ciNo').hide();}"> <label for="hasCustomisation">Has Custom Ingredients</label></p>
<p id="ciNo" style="padding-left: 20px;">
	<label for="ciHeader">Use header</label><input type="text" name="ciHeader" id="ciHeader" value="First 3 Toppings Free"><br>
	<label for="minci" style="display: inline">Min custom items: </label><input type="text" name="minci" id="minci" size="3" value="3"><br>
	<label for="maxci" style="display: inline">Max custom items: </label><input type="text" name="maxci" id="maxci" size="3" value="0"><br>
	<label for="freeCI" style="display: inline">Free items: </label><input type="text" name="freeci" id="freeCI" size="3" value="3"><br>
	<label for="displayOrderCI">Display Order</label><input type="text" name="displayOrderCI" id="displayOrderCI" value="2" size="3">
</p>

For the Dressing section 
<p><input checked="" type="checkbox" id="hasCustomisation" name="hasCustomisation" value="Y" onclick="if(this.checked){ $('ci_id').appear();$('ciNo').show(); } else {$('ci_id').fade();$('ciNo').hide();}"> <label for="hasCustomisation">Has Custom Ingredients</label></p>
<p id="ciNo" style="padding-left: 20px;">
	<label for="ciHeader">Use header</label><input type="text" name="ciHeader" id="ciHeader" value="First 3 Toppings Free"><br>
	<label for="minci" style="display: inline">Min custom items: </label><input type="text" name="minci" id="minci" size="3" value="3"><br>
	<label for="maxci" style="display: inline">Max custom items: </label><input type="text" name="maxci" id="maxci" size="3" value="0"><br>
	<label for="freeCI" style="display: inline">Free items: </label><input type="text" name="freeci" id="freeCI" size="3" value="3"><br>
	<label for="displayOrderCI">Display Order</label><input type="text" name="displayOrderCI" id="displayOrderCI" value="2" size="3">
</p>

For the Sauce section:
<p><input type="checkbox" id="hasSauce" name="hasSauce" value="Y" onclick="if(this.checked){ $('sa_id').appear(); $('sauceNo').show(); } else {$('sa_id').fade();$('sauceNo').hide()}"> <label for="hasSauce">Has Sauce</label></p>
<p id="sauceNo" style="display: none;padding-left:20px">
	<label for="sauceHeader">Use header</label><input type="text" name="sauceHeader" id="sauceHeader" value=""><br>
	<label for="minSauce" style="display: inline">Min sauces: </label><input type="text" name="minsauce" id="minSauce" size="3" value="0"><br>
	<label for="maxSauce" style="display: inline">Max sauces: </label><input type="text" name="maxsauce" id="maxSauce" size="3" value="0"><br>
	<label for="freeSauce" style="display: inline">Free items: </label><input type="text" name="freeSauce" id="freeSauce" size="3" value="0"><br>
	<label for="displayOrderSauce">Display Order</label><input type="text" name="displayOrderSauce" id="displayOrderSauce" value="" size="3">
</p>

For the side dishes:
<p><input checked="" type="checkbox" id="hasSideDish" name="hasSideDish" onclick="if(this.checked){ $('sdNo').show(); $('sd_id').appear(); } else {$('sdNo').hide();$('sd_id').fade()}" value="Y"> <label for="hasSideDish">Has Side Dishes</label></p>
<p id="sdNo" style="display: none;padding-left:20px">
	<label for="sdHeader">Use header</label><input type="text" name="sdHeader" id="sdHeader" value=""><br>
	<label for="minSD" style="display: inline">Min side dishes: </label><input type="text" name="minsd" id="minSD" size="3" value="0"><br>
	<label for="maxSD" style="display: inline">Max side dishes: </label><input type="text" name="maxsd" id="maxSD" size="3" value="0"><br>
	<label for="freeSD" style="display: inline">Free items: </label><input type="text" name="freeSD" id="freeSD" size="3" value="0"><br>
	<label for="displayOrderSD">Display Order</label><input type="text" name="displayOrderSD" id="displayOrderSD" value="" size="3">
</p>

For the Extras
<p><input checked="" type="checkbox" id="hasExtras" name="hasExtras" value="Y" onclick="if(this.checked){ $('extraNo').show();$('e_id').appear() } else { $('e_id').fade(); $('extraNo').hide() }"> <label for="hasExtras">Has Extras</label></p>
<p id="extraNo" style="display: none;padding-left:20px">
	<label for="extraHeader">Use header</label><input type="text" name="extraHeader" id="extraHeader" value=""><br>
	<label for="minExtra" style="display: inline">Min extras: </label><input type="text" name="minextras" id="minExtra" size="3" value="0"><br>
	<label for="maxExtra" style="display: inline">Max extras: </label><input type="text" name="maxextras" id="maxExtra" size="3" value="0"><br>
	<label for="freeExtra" style="display: inline">Free items: </label><input type="text" name="freeExtra" id="freeExtra" size="3" value="0"><br>
	<label for="displayOrderExtras">Display Order</label><input type="text" name="displayOrderExtras" id="displayOrderExtras" value="" size="3">
</p>

For the Cooking method 
<p><input checked="" type="checkbox" id="hasCM" name="hasCM" value="Y" onclick="if(this.checked){ $('cmNo').show();$('cm_id').appear() } else { $('cm_id').fade(); $('cmNo').hide() }"> <label for="hasCM">Has Cooking Method</label></p>
<p id="cmNo" style="display: none;padding-left:20px">
	<label for="cmHeader">Use header</label><input type="text" name="cmHeader" id="cmHeader" value=""><br>
	<label for="minCm" style="display: inline">Min CM: </label><input type="text" name="minCm" id="minCm" size="3" value="0"><br>
	<label for="maxCm" style="display: inline">Max CM: </label><input type="text" name="maxCm" id="maxCm" size="3" value="0"><br>
	<label for="freeCm" style="display: inline">Free items: </label><input type="text" name="freeCm" id="freeCm" size="3" value="0"><br>
	<label for="displayOrderCm">Display Order</label><input type="text" name="displayOrderCm" id="displayOrderCm" value="" size="3">
</p>

Notice that from the examples that I just gave you only Source is checked:

<p><input type="checkbox" id="hasSauce" name="hasSauce" value="Y" onclick="if(this.checked){ $('sa_id').appear(); $('sauceNo').show(); } else {$('sa_id').fade();$('sauceNo').hide()}"> <label for="hasSauce">Has Sauce</label></p>

I want you to only scrape the sections that are checked (checked="") for the current combo group.

### Combo Modfier groups:
Each combo group section appears above its respective combo modifier groups

<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px">Custom Ingredients</p>
<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px">Side Dish</p>
<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px">Extras</p>
<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px">Bread</p>
<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px">Dressing</p>
<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px">Sauce</p>
<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px">Cooking Method</p>

Each section has one or more combo modifier groups. For example, for the 1 Medium 3 toppings Combo group, the Custom Ingredients section is active. This section has these modifier groups:


<div id="ci_id" style="border-width: 0px 1px 1px; border-style: solid; border-color: rgb(170, 170, 170); margin-bottom: 2px; padding: 1px;">
					<ul id="ulci" style="list-style-type:none;overflow: hidden">
								<li>
									<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
										<input class="ci" onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()});if(this.checked){ $('list_ci_8173').show();}" type="radio" name="ci_radio" value="8173" id="radio_ci_8173">
										<label for="radio_ci_8173">Pizza Toppings</label>
									</p>
									<ul style="list-style-type: none; overflow: hidden;display:none" class="ci" id="list_ci_8173">
																																	<li style="width:30%; float: left;padding-left:2px">
													Green Peppers													<input type="text" size="5" name="ci[8173][37052]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Onions													<input type="text" size="5" name="ci[8173][37053]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Mushrooms													<input type="text" size="5" name="ci[8173][37054]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Green Olives													<input type="text" size="5" name="ci[8173][37055]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Black Olives													<input type="text" size="5" name="ci[8173][37056]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Dill Pickle													<input type="text" size="5" name="ci[8173][37057]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Tomatoes													<input type="text" size="5" name="ci[8173][37058]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Pineapple													<input type="text" size="5" name="ci[8173][37059]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Hot Peppers													<input type="text" size="5" name="ci[8173][37060]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Jalapeno													<input type="text" size="5" name="ci[8173][37061]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Pepperoni													<input type="text" size="5" name="ci[8173][37062]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Italian Sausage													<input type="text" size="5" name="ci[8173][37063]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Bacon													<input type="text" size="5" name="ci[8173][37064]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Ham													<input type="text" size="5" name="ci[8173][37065]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Meatballs													<input type="text" size="5" name="ci[8173][37066]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Chicken													<input type="text" size="5" name="ci[8173][37067]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Ground Beef													<input type="text" size="5" name="ci[8173][37068]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Donair Meat													<input type="text" size="5" name="ci[8173][37069]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Cheddar													<input type="text" size="5" name="ci[8173][37071]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Feta Cheese													<input type="text" size="5" name="ci[8173][37072]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Sour Cream													<input type="text" size="5" name="ci[8173][44095]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Nacho Cheese Sauce													<input type="text" size="5" name="ci[8173][44096]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Hot Honey													<input type="text" size="5" name="ci[8173][56143]" value="2.99,3.49,3.99,4.99">
												</li>
																														</ul>
								</li>
								<li>
									<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
										<input class="ci" checked="" onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()});if(this.checked){ $('list_ci_8174').show();}" type="radio" name="ci_radio" value="8174" id="radio_ci_8174">
										<label for="radio_ci_8174">Pizza Toppings without Premium</label>
									</p>
									<ul style="list-style-type: none; overflow: hidden;display:" class="ci" id="list_ci_8174">
																																														<li style="width:30%; float: left;padding-left:2px">
														Green Peppers														<input type="text" size="5" name="ci[8174][37052]" value="2.99,3.49,3.99,4.99">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Onions														<input type="text" size="5" name="ci[8174][37053]" value="2.99,3.49,3.99,4.99">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Mushrooms														<input type="text" size="5" name="ci[8174][37054]" value="2.99,3.49,3.99,4.99">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Green Olives														<input type="text" size="5" name="ci[8174][37055]" value="2.99,3.49,3.99,4.99">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Black Olives														<input type="text" size="5" name="ci[8174][37056]" value="2.99,3.49,3.99,4.99">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Dill Pickle														<input type="text" size="5" name="ci[8174][37057]" value="2.99,3.49,3.99,4.99">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Tomatoes														<input type="text" size="5" name="ci[8174][37058]" value="2.99,3.49,3.99,4.99">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Pineapple														<input type="text" size="5" name="ci[8174][37059]" value="2.99,3.49,3.99,4.99">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Hot Peppers														<input type="text" size="5" name="ci[8174][37060]" value="2.99,3.49,3.99,4.99">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Jalapeno														<input type="text" size="5" name="ci[8174][37061]" value="2.99,3.49,3.99,4.99">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Pepperoni														<input type="text" size="5" name="ci[8174][37062]" value="2.99,3.49,3.99,4.99">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Italian Sausage														<input type="text" size="5" name="ci[8174][37063]" value="2.99,3.49,3.99,4.99">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Bacon														<input type="text" size="5" name="ci[8174][37064]" value="2.99,3.49,3.99,4.99">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Ham														<input type="text" size="5" name="ci[8174][37065]" value="2.99,3.49,3.99,4.99">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Meatballs														<input type="text" size="5" name="ci[8174][37066]" value="2.99,3.49,3.99,4.99">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Chicken														<input type="text" size="5" name="ci[8174][37067]" value="2.99,3.49,3.99,4.99">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Ground Beef														<input type="text" size="5" name="ci[8174][37068]" value="2.99,3.49,3.99,4.99">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Donair Meat														<input type="text" size="5" name="ci[8174][37069]" value="2.99,3.49,3.99,4.99">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Cheddar														<input type="text" size="5" name="ci[8174][37071]" value="2.99,3.49,3.99,4.99">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Feta Cheese														<input type="text" size="5" name="ci[8174][37072]" value="2.99,3.49,3.99,4.99">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Sour Cream														<input type="text" size="5" name="ci[8174][44095]" value="2.99,3.49,3.99,4.99">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Nacho Cheese Sauce														<input type="text" size="5" name="ci[8174][44096]" value="2.99,3.49,3.99,4.99">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Hot Honey														<input type="text" size="5" name="ci[8174][56143]" value="2.99,3.49,3.99,4.99">
													</li>
																																										</ul>
								</li>
								<li>
									<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
										<input class="ci" onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()});if(this.checked){ $('list_ci_8175').show();}" type="radio" name="ci_radio" value="8175" id="radio_ci_8175">
										<label for="radio_ci_8175">Premium Toppings</label>
									</p>
									<ul style="list-style-type: none; overflow: hidden;display:none" class="ci" id="list_ci_8175">
																																	<li style="width:30%; float: left;padding-left:2px">
													Extra Cheese													<input type="text" size="5" name="ci[8175][37070]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Double Cheese													<input type="text" size="5" name="ci[8175][37169]" value="5.98,7.58,11.98,14.98">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Extra Vegan Cheese													<input type="text" size="5" name="ci[8175][49543]" value="3.98,4.78,6.98,8.48">
												</li>
																														</ul>
								</li>
								<li>
									<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
										<input class="ci" onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()});if(this.checked){ $('list_ci_8177').show();}" type="radio" name="ci_radio" value="8177" id="radio_ci_8177">
										<label for="radio_ci_8177">Toppings for POUTINES</label>
									</p>
									<ul style="list-style-type: none; overflow: hidden;display:none" class="ci" id="list_ci_8177">
																																	<li style="width:30%; float: left;padding-left:2px">
													Bacon													<input type="text" size="5" name="ci[8177][37274]" value="1.00,2.00,3.00,4.00">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Extra Cheese													<input type="text" size="5" name="ci[8177][37276]" value="1.00,2.00,3.00,4.00">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Chicken													<input type="text" size="5" name="ci[8177][37277]" value="1.00,2.00,3.00,4.00">
												</li>
																														</ul>
								</li>
								<li>
									<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
										<input class="ci" onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()});if(this.checked){ $('list_ci_9362').show();}" type="radio" name="ci_radio" value="9362" id="radio_ci_9362">
										<label for="radio_ci_9362">Keto Desserts</label>
									</p>
									<ul style="list-style-type: none; overflow: hidden;display:none" class="ci" id="list_ci_9362">
																																	<li style="width:30%; float: left;padding-left:2px">
													Pecan Puffs													<input type="text" size="5" name="ci[9362][42473]" value="0.00">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Lemon Poppy Leaf													<input type="text" size="5" name="ci[9362][42474]" value="0.00">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Tiramisu Cup Cakes													<input type="text" size="5" name="ci[9362][42475]" value="0.00">
												</li>
																														</ul>
								</li>
								<li>
									<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
										<input class="ci" onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()});if(this.checked){ $('list_ci_9424').show();}" type="radio" name="ci_radio" value="9424" id="radio_ci_9424">
										<label for="radio_ci_9424">All Pizza Tails</label>
									</p>
									<ul style="list-style-type: none; overflow: hidden;display:none" class="ci" id="list_ci_9424">
																																	<li style="width:30%; float: left;padding-left:2px">
													Pot of Gold Pizza Tail													<input type="text" size="5" name="ci[9424][42713]" value="0.00">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Surprise Pizza Tail													<input type="text" size="5" name="ci[9424][42714]" value="0.00">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Smores Marshmallow Fluff Tail													<input type="text" size="5" name="ci[9424][42716]" value="0.00">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Nutella Pizza Tail													<input type="text" size="5" name="ci[9424][42717]" value="0.00">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Peanutbutter Cup Flutter Nutter Tail													<input type="text" size="5" name="ci[9424][42718]" value="0.00">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Cookies &amp; Cream Pizza Tail													<input type="text" size="5" name="ci[9424][42722]" value="0.00">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Kinder Surprise Pizza Tail													<input type="text" size="5" name="ci[9424][45379]" value="0.00">
												</li>
																														</ul>
								</li>
								<li>
									<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
										<input class="ci" onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()});if(this.checked){ $('list_ci_9691').show();}" type="radio" name="ci_radio" value="9691" id="radio_ci_9691">
										<label for="radio_ci_9691">Meats &amp; CHeese for Nacho Fries</label>
									</p>
									<ul style="list-style-type: none; overflow: hidden;display:none" class="ci" id="list_ci_9691">
																																	<li style="width:30%; float: left;padding-left:2px">
													Pepperoni													<input type="text" size="5" name="ci[9691][37062]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Italian Sausage													<input type="text" size="5" name="ci[9691][37063]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Bacon													<input type="text" size="5" name="ci[9691][37064]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Ham													<input type="text" size="5" name="ci[9691][37065]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Meatballs													<input type="text" size="5" name="ci[9691][37066]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Chicken													<input type="text" size="5" name="ci[9691][37067]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Ground Beef													<input type="text" size="5" name="ci[9691][37068]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Donair Meat													<input type="text" size="5" name="ci[9691][37069]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Cheddar													<input type="text" size="5" name="ci[9691][44099]" value="2.00">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Mozzarella													<input type="text" size="5" name="ci[9691][44100]" value="2.00">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Curd													<input type="text" size="5" name="ci[9691][44101]" value="2.00">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Asiago													<input type="text" size="5" name="ci[9691][44102]" value="2.00">
												</li>
																														</ul>
								</li>
								<li>
									<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
										<input class="ci" onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()});if(this.checked){ $('list_ci_9692').show();}" type="radio" name="ci_radio" value="9692" id="radio_ci_9692">
										<label for="radio_ci_9692">Vegetables for Nacho Fries</label>
									</p>
									<ul style="list-style-type: none; overflow: hidden;display:none" class="ci" id="list_ci_9692">
																																	<li style="width:30%; float: left;padding-left:2px">
													Green Peppers													<input type="text" size="5" name="ci[9692][37052]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Onions													<input type="text" size="5" name="ci[9692][37053]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Mushrooms													<input type="text" size="5" name="ci[9692][37054]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Green Olives													<input type="text" size="5" name="ci[9692][37055]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Black Olives													<input type="text" size="5" name="ci[9692][37056]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Dill Pickle													<input type="text" size="5" name="ci[9692][37057]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Tomatoes													<input type="text" size="5" name="ci[9692][37058]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Pineapple													<input type="text" size="5" name="ci[9692][37059]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Hot Peppers													<input type="text" size="5" name="ci[9692][37060]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Jalapeno													<input type="text" size="5" name="ci[9692][37061]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Jalapeno Crisps													<input type="text" size="5" name="ci[9692][44105]" value="0.00">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Onion Crisps													<input type="text" size="5" name="ci[9692][44106]" value="0.00">
												</li>
																														</ul>
								</li>
								<li>
									<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
										<input class="ci" onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()});if(this.checked){ $('list_ci_9869').show();}" type="radio" name="ci_radio" value="9869" id="radio_ci_9869">
										<label for="radio_ci_9869">Add Bacon 3.99</label>
									</p>
									<ul style="list-style-type: none; overflow: hidden;display:none" class="ci" id="list_ci_9869">
																																	<li style="width:30%; float: left;padding-left:2px">
													Add Bacon													<input type="text" size="5" name="ci[9869][44931]" value="3.99">
												</li>
																														</ul>
								</li>
								<li>
									<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
										<input class="ci" onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()});if(this.checked){ $('list_ci_9965').show();}" type="radio" name="ci_radio" value="9965" id="radio_ci_9965">
										<label for="radio_ci_9965">Easter Pizza Tail Selection</label>
									</p>
									<ul style="list-style-type: none; overflow: hidden;display:none" class="ci" id="list_ci_9965">
																																	<li style="width:30%; float: left;padding-left:2px">
													Hershey's Pizza Tail													<input type="text" size="5" name="ci[9965][45377]" value="0.00">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Reese's Pizza Tail													<input type="text" size="5" name="ci[9965][45378]" value="0.00">
												</li>
																														</ul>
								</li>
								<li>
									<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
										<input class="ci" onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()});if(this.checked){ $('list_ci_10089').show();}" type="radio" name="ci_radio" value="10089" id="radio_ci_10089">
										<label for="radio_ci_10089">Chicken 3$</label>
									</p>
									<ul style="list-style-type: none; overflow: hidden;display:none" class="ci" id="list_ci_10089">
																																	<li style="width:30%; float: left;padding-left:2px">
													Chicken													<input type="text" size="5" name="ci[10089][46044]" value="3.00">
												</li>
																														</ul>
								</li>
								<li>
									<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
										<input class="ci" onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()});if(this.checked){ $('list_ci_10240').show();}" type="radio" name="ci_radio" value="10240" id="radio_ci_10240">
										<label for="radio_ci_10240">Cookie dough</label>
									</p>
									<ul style="list-style-type: none; overflow: hidden;display:none" class="ci" id="list_ci_10240">
																																	<li style="width:30%; float: left;padding-left:2px">
													Naked													<input type="text" size="5" name="ci[10240][46844]" value="0.00">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Fluffernutter													<input type="text" size="5" name="ci[10240][46845]" value="0.00">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Cookies &amp; Cream													<input type="text" size="5" name="ci[10240][46846]" value="0.00">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Hazelnut with Chocolate &amp; Caramel													<input type="text" size="5" name="ci[10240][46847]" value="0.00">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Smore's													<input type="text" size="5" name="ci[10240][46848]" value="0.00">
												</li>
																														</ul>
								</li>
								<li>
									<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
										<input class="ci" onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()});if(this.checked){ $('list_ci_10241').show();}" type="radio" name="ci_radio" value="10241" id="radio_ci_10241">
										<label for="radio_ci_10241">Pizza TAILS</label>
									</p>
									<ul style="list-style-type: none; overflow: hidden;display:none" class="ci" id="list_ci_10241">
																																	<li style="width:30%; float: left;padding-left:2px">
													Pot of Gold Pizza Tail													<input type="text" size="5" name="ci[10241][42713]" value="0.00">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Smores Marshmallow Fluff Tail													<input type="text" size="5" name="ci[10241][42716]" value="0.00">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Nutella Pizza Tail													<input type="text" size="5" name="ci[10241][42717]" value="0.00">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Chef's Choice Pizza Tail													<input type="text" size="5" name="ci[10241][45519]" value="0.00">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Reese's Pieces Parfait Tail													<input type="text" size="5" name="ci[10241][50694]" value="0.00">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Chocolate Bar Lovers Tail													<input type="text" size="5" name="ci[10241][50695]" value="0.00">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Cookies &amp; Cream Tail													<input type="text" size="5" name="ci[10241][50721]" value="0.00">
												</li>
																														</ul>
								</li>
								<li>
									<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
										<input class="ci" onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()});if(this.checked){ $('list_ci_10534').show();}" type="radio" name="ci_radio" value="10534" id="radio_ci_10534">
										<label for="radio_ci_10534">NEW POUTINE FORMAT Step 1- Fries Selection</label>
									</p>
									<ul style="list-style-type: none; overflow: hidden;display:none" class="ci" id="list_ci_10534">
																																	<li style="width:30%; float: left;padding-left:2px">
													Classic crispy coated													<input type="text" size="5" name="ci[10534][48360]" value="0.00">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Home cut spiral													<input type="text" size="5" name="ci[10534][48361]" value="0.00">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Wedges													<input type="text" size="5" name="ci[10534][48362]" value="0.00">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Tots													<input type="text" size="5" name="ci[10534][48363]" value="0.00">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Onion Rings													<input type="text" size="5" name="ci[10534][48364]" value="0.00">
												</li>
																														</ul>
								</li>
								<li>
									<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
										<input class="ci" onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()});if(this.checked){ $('list_ci_10537').show();}" type="radio" name="ci_radio" value="10537" id="radio_ci_10537">
										<label for="radio_ci_10537">NEW POUTINE FORMAT Step 4- More Toppings Selection</label>
									</p>
									<ul style="list-style-type: none; overflow: hidden;display:none" class="ci" id="list_ci_10537">
																																	<li style="width:30%; float: left;padding-left:2px">
													Green Peppers													<input type="text" size="5" name="ci[10537][37052]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Onions													<input type="text" size="5" name="ci[10537][37053]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Mushrooms													<input type="text" size="5" name="ci[10537][37054]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Green Olives													<input type="text" size="5" name="ci[10537][37055]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Black Olives													<input type="text" size="5" name="ci[10537][37056]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Dill Pickle													<input type="text" size="5" name="ci[10537][37057]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Tomatoes													<input type="text" size="5" name="ci[10537][37058]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Pineapple													<input type="text" size="5" name="ci[10537][37059]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Hot Peppers													<input type="text" size="5" name="ci[10537][37060]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Jalapeno													<input type="text" size="5" name="ci[10537][37061]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Pepperoni													<input type="text" size="5" name="ci[10537][37062]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Italian Sausage													<input type="text" size="5" name="ci[10537][37063]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Bacon													<input type="text" size="5" name="ci[10537][37064]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Ham													<input type="text" size="5" name="ci[10537][37065]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Meatballs													<input type="text" size="5" name="ci[10537][37066]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Ground Beef													<input type="text" size="5" name="ci[10537][37068]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Donair Meat													<input type="text" size="5" name="ci[10537][37069]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Extra Cheese													<input type="text" size="5" name="ci[10537][37070]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Cheddar													<input type="text" size="5" name="ci[10537][37071]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Feta Cheese													<input type="text" size="5" name="ci[10537][37072]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Bacon													<input type="text" size="5" name="ci[10537][37274]" value="1.00,2.00,3.00,4.00">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Extra Cheese													<input type="text" size="5" name="ci[10537][37276]" value="1.00,2.00,3.00,4.00">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Sour Cream													<input type="text" size="5" name="ci[10537][44095]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Nacho Cheese Sauce													<input type="text" size="5" name="ci[10537][44096]" value="2.99,3.49,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Extra Gravy (4oz)													<input type="text" size="5" name="ci[10537][48365]" value="1.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Creamy Garlic													<input type="text" size="5" name="ci[10537][48382]" value="1.49">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Ranch sauce													<input type="text" size="5" name="ci[10537][48383]" value="1.49">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Cheddar Chipotle													<input type="text" size="5" name="ci[10537][48384]" value="1.49">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Marinara sauce													<input type="text" size="5" name="ci[10537][48385]" value="1.49">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Donair sauce													<input type="text" size="5" name="ci[10537][48386]" value="1.49">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													BBQ sauce													<input type="text" size="5" name="ci[10537][48387]" value="1.49">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Hot sauce													<input type="text" size="5" name="ci[10537][48388]" value="1.49">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Mild sauce													<input type="text" size="5" name="ci[10537][48389]" value="1.49">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Medium sauce													<input type="text" size="5" name="ci[10537][48390]" value="1.49">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Honey Garlic													<input type="text" size="5" name="ci[10537][48391]" value="1.49">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Honey Mustard sauce													<input type="text" size="5" name="ci[10537][48392]" value="1.49">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Sweet Chili Thai sauce													<input type="text" size="5" name="ci[10537][48393]" value="1.49">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Caesar sauce													<input type="text" size="5" name="ci[10537][48394]" value="1.49">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Plum sauce													<input type="text" size="5" name="ci[10537][48395]" value="1.49">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Maple Bacon BBQ Sauce													<input type="text" size="5" name="ci[10537][48396]" value="1.49">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Nacho Cheese Sauce													<input type="text" size="5" name="ci[10537][48397]" value="1.49">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Extra Vegan Cheese													<input type="text" size="5" name="ci[10537][49544]" value="1.99,2.99,3.99,4.99">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Onion Crisps													<input type="text" size="5" name="ci[10537][51957]" value="0.00">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Jalapeño Crisps													<input type="text" size="5" name="ci[10537][51958]" value="0.00">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Batter Bits													<input type="text" size="5" name="ci[10537][51959]" value="0.00">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Grilled Chicken													<input type="text" size="5" name="ci[10537][52453]" value="2.00,3.00,4.00,5.00">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Popcorn Chicken													<input type="text" size="5" name="ci[10537][52454]" value="2.00,3.00,4.00,5.00">
												</li>
																														</ul>
								</li>
								<li>
									<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
										<input class="ci" onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()});if(this.checked){ $('list_ci_11005').show();}" type="radio" name="ci_radio" value="11005" id="radio_ci_11005">
										<label for="radio_ci_11005">Medium Cheese Pizza for FRIDAY SPECIAL FISH &amp; CHIPS</label>
									</p>
									<ul style="list-style-type: none; overflow: hidden;display:none" class="ci" id="list_ci_11005">
																																	<li style="width:30%; float: left;padding-left:2px">
													Medium Cheese Pizza													<input type="text" size="5" name="ci[11005][50848]" value="9.95">
												</li>
																														</ul>
								</li>
								<li>
									<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
										<input class="ci" onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()});if(this.checked){ $('list_ci_11505').show();}" type="radio" name="ci_radio" value="11505" id="radio_ci_11505">
										<label for="radio_ci_11505">Wing (each 0.69) ( 5 or 10 or 20)</label>
									</p>
									<ul style="list-style-type: none; overflow: hidden;display:none" class="ci" id="list_ci_11505">
																																	<li style="width:30%; float: left;padding-left:2px">
													1 Wing (each)													<input type="text" size="5" name="ci[11505][53413]" value="0.69">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													5 Wings													<input type="text" size="5" name="ci[11505][53414]" value="3.45">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													10 Wings													<input type="text" size="5" name="ci[11505][53415]" value="6.90">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													20 Wings													<input type="text" size="5" name="ci[11505][53416]" value="13.80">
												</li>
																														</ul>
								</li>
																		</ul>
				</div>




Notice that for this example only the Pizza Toppings without Premium was checked:
<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
	<input class="ci" checked="" onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()});if(this.checked){ $('list_ci_8174').show();}" type="radio" name="ci_radio" value="8174" id="radio_ci_8174">
	<label for="radio_ci_8174">Pizza Toppings without Premium</label>
</p>
		 
I want you to only scrape the modifier groups that were checked (checked=""). Each combo modifier group have one or more combo modifers each with one or more prices depending on the size:

<ul style="list-style-type: none; overflow: hidden;display:" class="ci" id="list_ci_8174">
																																														<li style="width:30%; float: left;padding-left:2px">
														Green Peppers														<input type="text" size="5" name="ci[8174][37052]" value="2.99,3.49,3.99,4.99">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Onions														<input type="text" size="5" name="ci[8174][37053]" value="2.99,3.49,3.99,4.99">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Mushrooms														<input type="text" size="5" name="ci[8174][37054]" value="2.99,3.49,3.99,4.99">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Green Olives														<input type="text" size="5" name="ci[8174][37055]" value="2.99,3.49,3.99,4.99">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Black Olives														<input type="text" size="5" name="ci[8174][37056]" value="2.99,3.49,3.99,4.99">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Dill Pickle														<input type="text" size="5" name="ci[8174][37057]" value="2.99,3.49,3.99,4.99">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Tomatoes														<input type="text" size="5" name="ci[8174][37058]" value="2.99,3.49,3.99,4.99">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Pineapple														<input type="text" size="5" name="ci[8174][37059]" value="2.99,3.49,3.99,4.99">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Hot Peppers														<input type="text" size="5" name="ci[8174][37060]" value="2.99,3.49,3.99,4.99">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Jalapeno														<input type="text" size="5" name="ci[8174][37061]" value="2.99,3.49,3.99,4.99">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Pepperoni														<input type="text" size="5" name="ci[8174][37062]" value="2.99,3.49,3.99,4.99">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Italian Sausage														<input type="text" size="5" name="ci[8174][37063]" value="2.99,3.49,3.99,4.99">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Bacon														<input type="text" size="5" name="ci[8174][37064]" value="2.99,3.49,3.99,4.99">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Ham														<input type="text" size="5" name="ci[8174][37065]" value="2.99,3.49,3.99,4.99">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Meatballs														<input type="text" size="5" name="ci[8174][37066]" value="2.99,3.49,3.99,4.99">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Chicken														<input type="text" size="5" name="ci[8174][37067]" value="2.99,3.49,3.99,4.99">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Ground Beef														<input type="text" size="5" name="ci[8174][37068]" value="2.99,3.49,3.99,4.99">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Donair Meat														<input type="text" size="5" name="ci[8174][37069]" value="2.99,3.49,3.99,4.99">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Cheddar														<input type="text" size="5" name="ci[8174][37071]" value="2.99,3.49,3.99,4.99">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Feta Cheese														<input type="text" size="5" name="ci[8174][37072]" value="2.99,3.49,3.99,4.99">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Sour Cream														<input type="text" size="5" name="ci[8174][44095]" value="2.99,3.49,3.99,4.99">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Nacho Cheese Sauce														<input type="text" size="5" name="ci[8174][44096]" value="2.99,3.49,3.99,4.99">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Hot Honey														<input type="text" size="5" name="ci[8174][56143]" value="2.99,3.49,3.99,4.99">
													</li>
																																										</ul>




## Phase 2:
Once you all the combo modifier Groups have been scrapped you should:

1. Go back to the landing page: https://menuadmin.menu.ca/?p=restaurants

2. In the landing page you will find the v1 restaurants under an <ul id="active"> element. Each V1 restaurant is stored in an <li> element:

Each <li> element has an <a> element containing a link to the details page of each restaurant. This <a> element also contians the unique v1 id that identifies each restaurant. For instance the restaurant Joes Family Pizzeria v3 ID: 636 the a element contains its v1 id (863) in the href parameter <a href="/?p=restaurants&amp;display=editRestaurant&amp;restaurant=863">Edit</a>. You should use this element to both identify the v1 restaurants that must be scraped and access its details page where the data that needs to be scrapped is located.

3. Once you get to the details page of each restaurant you need to click this <a> element to navigate to the menu details:
<a class="active" href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=863&amp;load=menu&amp;showLang=en">Menu</a> this will take you to https://menuadmin.menu.ca/?p=restaurants&display=editRestaurant&restaurant=863&load=menu&showLang=en

4. In the menu details page I want you to look for this div: <div style="width:500px; float: left;">. It contains all the courses and dishes for each restaurant. Each course and its respective dishes are stored in a <ul> element:
<ul style="list-style-type: none" id="course_2">
	<li style="position: relative;"><h3>Daily Deals Category</h3></li>
	<li style="margin-left: 10px; position: relative; z-index: 0; top: 0px; left: 0px;" id="li_122796">
		<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
			<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=863&amp;load=editCombo&amp;showLang=en&amp;combo=122796">Friday &amp; Saturday Pizza Special HIDE</a> - One large 5 toppings pizza.											
	</li>
	<li style="margin-left: 10px; position: relative; z-index: 0; top: 0px; left: 0px;" id="li_122797">
		<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
		<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=863&amp;load=editDish&amp;showLang=en&amp;menuEntry=122797">Nacho Tuesdays HIDE</a> - Get a regular size Nacho for a special price. Limit of 2 per order.											
	</li>
	<li style="margin-left: 10px; position: relative; z-index: 0; top: 0px; left: 0px;" id="li_122798">
		<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
		<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=863&amp;load=editDish&amp;showLang=en&amp;menuEntry=122798">WILD Wednesdays HIDE</a> - Medium cheese pizzas. Limit of 2 per order.											
	</li>
	<li style="margin-left: 10px; position: relative; z-index: 0; top: 0px; left: 0px;" id="li_123372">
		<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
		<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=863&amp;load=editCombo&amp;showLang=en&amp;combo=123372">Joes Perfect Party Pack with Large Pizza and 5 Random Chocolate Bars HIDE</a> - Great for kids' parties (kids of ANY age). Get a large 1 topping pizza, 5 assorted chocolate bars, 5 drinks (Regular drinks). Feeds 5 people (2 slices, 1 drink &amp; 1 chocolate bar). For each party pack, you can add 1 half priced family fry!											
	</li>
</ul>

Now each course can have two different type of dishes: combo dishes and normal dishes.

##  Combo Dishes: 
They can be identified by the href attribute of <a> element of each dish. All combo dishes have a combo= at the end of the href:
<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=863&amp;load=editCombo&amp;showLang=en&amp;combo=122796">Friday &amp; Saturday Pizza Special HIDE</a> 
<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=863&amp;load=editCombo&amp;showLang=en&amp;combo=123372">Joes Perfect Party Pack with Large Pizza and 5 Random Chocolate Bars HIDE</a>


Click in the <a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=863&amp;load=editCombo&amp;showLang=en&amp;combo=122796">Friday &amp; Saturday Pizza Special HIDE</a> to enter the dish details:

In the dish details (https://menuadmin.menu.ca/?p=restaurants&display=editRestaurant&restaurant=863&load=editCombo&showLang=en&combo=122796)
Name: 
<li>
	<label style="display: block" for="name">Name</label>
	<input type="text" class="long" name="name" id="name" value="Friday &amp; Saturday Pizza Special HIDE">
</li>

Description: 
<li>
	<label style="display: block" for="ingredients">Description</label>
	<textarea rows="3" cols="35" name="ingredients" id="ingredients">One large 5 toppings pizza.</textarea>
</li>

Price: 
<li>
	<label style="display:block" for="price">Price - <sub>separate multiple prices by comma</sub></label>
	<input type="text" name="price" id="price" class="long" value="24.99">
</li>


DISH_COMBO_GROUPS:
All the Combo Groups are stored under the <ul style="list-style-type: none" id="sortMeCombo"> element:

<ul style="list-style-type: none" id="sortMeCombo"><li id="li_6654" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="6654" id="radio_6654">
                        <label for="radio_6654">1 Topping Pizza</label>
                    </p></li><li id="li_6655" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="6655" id="radio_6655">
                        <label for="radio_6655">Premium Toppings</label>
                    </p></li><li id="li_6656" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="6656" id="radio_6656">
                        <label for="radio_6656">Dips</label>
                    </p></li><li id="li_6657" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="6657" id="radio_6657">
                        <label for="radio_6657">Upgrade any Pizza to Pan Pizza</label>
                    </p></li><li id="li_6684" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="6684" id="radio_6684">
                        <label for="radio_6684">2 Large 3 Toppings Pizza</label>
                    </p></li><li id="li_6685" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="6685" id="radio_6685">
                        <label for="radio_6685">Premium Toppings Large----1st pizza</label>
                    </p></li><li id="li_6686" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="6686" id="radio_6686">
                        <label for="radio_6686">Premium Toppings Large -----2nd pizza</label>
                    </p></li><li id="li_6691" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="6691" id="radio_6691">
                        <label for="radio_6691">2 Toppings Pizza</label>
                    </p></li><li id="li_6978" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="6978" id="radio_6978">
                        <label for="radio_6978">1-2-3 Special - Crust and 2 meats selection -Step 1</label>
                    </p></li><li id="li_6979" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="6979" id="radio_6979">
                        <label for="radio_6979">1-2-3 Special - 3 Vegetables- Step 2</label>
                    </p></li><li id="li_6980" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="6980" id="radio_6980">
                        <label for="radio_6980">1-2-3 Special- Add more toppings - Step 3</label>
                    </p></li><li id="li_6982" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="6982" id="radio_6982">
                        <label for="radio_6982">1 medium pizza 2 toppings</label>
                    </p></li><li id="li_6983" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="6983" id="radio_6983">
                        <label for="radio_6983">Premium Toppings Medium</label>
                    </p></li><li id="li_6984" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="6984" id="radio_6984">
                        <label for="radio_6984">1 large pizza with 2 toppings</label>
                    </p></li><li id="li_6985" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="6985" id="radio_6985">
                        <label for="radio_6985">Premium Toppings Large</label>
                    </p></li><li id="li_6986" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="6986" id="radio_6986">
                        <label for="radio_6986">Poutine Selection for Medium or Large Pizza &amp; Poutine Deal</label>
                    </p></li><li id="li_6990" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="6990" id="radio_6990">
                        <label for="radio_6990">1 Large Pizza 3 Toppings</label>
                    </p></li><li id="li_6991" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="6991" id="radio_6991">
                        <label for="radio_6991">1 Appetizer</label>
                    </p></li><li id="li_6992" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="6992" id="radio_6992">
                        <label for="radio_6992">Mom's night off Side Dish</label>
                    </p></li><li id="li_6993" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="6993" id="radio_6993">
                        <label for="radio_6993">1st Dip Free</label>
                    </p></li><li id="li_6994" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="6994" id="radio_6994">
                        <label for="radio_6994">2 Dips Free</label>
                    </p></li><li id="li_7254" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="7254" id="radio_7254">
                        <label for="radio_7254">Poutine for Subs &amp; Wraps</label>
                    </p></li><li id="li_7255" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="7255" id="radio_7255">
                        <label for="radio_7255">Extra Cheese &amp; Meat for Subs</label>
                    </p></li><li id="li_7256" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="7256" id="radio_7256">
                        <label for="radio_7256">Extras and Options for Chicken and Bacon Wrap</label>
                    </p></li><li id="li_7257" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="7257" id="radio_7257">
                        <label for="radio_7257">Extras &amp; Options for Joes Donair Wrap</label>
                    </p></li><li id="li_7287" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="7287" id="radio_7287">
                        <label for="radio_7287">2 Pizzas 3 Toppings</label>
                    </p></li><li id="li_7288" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="7288" id="radio_7288">
                        <label for="radio_7288">Premium Toppings SMLXL---1st pizza</label>
                    </p></li><li id="li_7289" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="7289" id="radio_7289">
                        <label for="radio_7289">Premium Toppings SMLXL----2nd Pizza</label>
                    </p></li><li id="li_7420" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="7420" id="radio_7420">
                        <label for="radio_7420">Three Toppings Pizza</label>
                    </p></li><li id="li_7520" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="7520" id="radio_7520">
                        <label for="radio_7520">Team Deal - 5 XL Pepperoni Pizza</label>
                    </p></li><li id="li_7521" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="7521" id="radio_7521">
                        <label for="radio_7521">Team Specials - 5 XL Cheese Pizzas</label>
                    </p></li><li id="li_7522" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="7522" id="radio_7522">
                        <label for="radio_7522">Team Specials - 5 XL Pizzas with 3 Toppings</label>
                    </p></li><li id="li_7523" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="7523" id="radio_7523">
                        <label for="radio_7523">Premium Toppings X-Large---1st pizza</label>
                    </p></li><li id="li_7524" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="7524" id="radio_7524">
                        <label for="radio_7524">Premium Toppings X-Large---2nd pizza</label>
                    </p></li><li id="li_7525" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="7525" id="radio_7525">
                        <label for="radio_7525">Premium Toppings X-Large----3rd pizza</label>
                    </p></li><li id="li_7526" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="7526" id="radio_7526">
                        <label for="radio_7526">Premium Toppings X-Large----4th pizza</label>
                    </p></li><li id="li_7527" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="7527" id="radio_7527">
                        <label for="radio_7527">Premium Toppings X-Large---5th pizza</label>
                    </p></li><li id="li_7561" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="7561" id="radio_7561">
                        <label for="radio_7561">1 Medium Pizza 5 Toppings</label>
                    </p></li><li id="li_7562" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="7562" id="radio_7562">
                        <label for="radio_7562">1 Large Pizza 5 Toppings</label>
                    </p></li><li id="li_7563" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="7563" id="radio_7563">
                        <label for="radio_7563">Pizza Tail (dessert)</label>
                    </p></li><li id="li_7564" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="7564" id="radio_7564">
                        <label for="radio_7564">1 Medium Pizza 3 Toppings</label>
                    </p></li><li id="li_7806" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="7806" id="radio_7806">
                        <label for="radio_7806">1 Medium Pizza</label>
                    </p></li><li id="li_7807" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="7807" id="radio_7807">
                        <label for="radio_7807">Large Salad Selection</label>
                    </p></li><li id="li_7808" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="7808" id="radio_7808">
                        <label for="radio_7808">Wings Sauces</label>
                    </p></li><li id="li_7809" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="7809" id="radio_7809">
                        <label for="radio_7809">Keto Dessert</label>
                    </p></li><li id="li_7810" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="7810" id="radio_7810">
                        <label for="radio_7810">Extras for Nacho</label>
                    </p></li><li id="li_8070" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="8070" id="radio_8070">
                        <label for="radio_8070">NACHO FRIES Step 1 ---Dirty or Regular</label>
                    </p></li><li id="li_8071" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="8071" id="radio_8071">
                        <label for="radio_8071">NACHO FRIES Step 2-----Meat &amp; Cheese (2 items free)</label>
                    </p></li><li id="li_8072" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="8072" id="radio_8072">
                        <label for="radio_8072">NACHO FRIES Step 3------Unlimited Vegetables</label>
                    </p></li><li id="li_8073" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="8073" id="radio_8073">
                        <label for="radio_8073">NACHO FRIES Step 4-----Sauces</label>
                    </p></li><li id="li_8186" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="8186" id="radio_8186">
                        <label for="radio_8186">1 Pizza Kit</label>
                    </p></li><li id="li_8597" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="8597" id="radio_8597">
                        <label for="radio_8597">POUTINES NEW FORMAT- Step 1 and 2 and 3</label>
                    </p></li><li id="li_8598" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="8598" id="radio_8598">
                        <label for="radio_8598">POUTINES NEW FORMAT- Step 4+5 and 6</label>
                    </p></li><li id="li_8599" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="8599" id="radio_8599">
                        <label for="radio_8599">NACHO FRIES Step 0 ---Fries Selection</label>
                    </p></li><li id="li_8635" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="8635" id="radio_8635">
                        <label for="radio_8635">POUTINES NEW FORMAT- Step 4+5 and 6  SMALL</label>
                    </p></li><li id="li_8636" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="8636" id="radio_8636">
                        <label for="radio_8636">POUTINES NEW FORMAT- Step 4+5 and 6 MEDIUM</label>
                    </p></li><li id="li_8637" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="8637" id="radio_8637">
                        <label for="radio_8637">POUTINES NEW FORMAT- Step 4+5 and 6 LARGE</label>
                    </p></li><li id="li_8638" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="8638" id="radio_8638">
                        <label for="radio_8638">POUTINES NEW FORMAT- Step 4+5 and 6 X-LARGE</label>
                    </p></li><li id="li_8643" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="8643" id="radio_8643">
                        <label for="radio_8643">1 Small pizza 3 Toppings</label>
                    </p></li><li id="li_8644" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="8644" id="radio_8644">
                        <label for="radio_8644">Premium Toppings Small</label>
                    </p></li><li id="li_8729" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="8729" id="radio_8729">
                        <label for="radio_8729">Fish &amp; Chips Fries Selection</label>
                    </p></li><li id="li_8730" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="8730" id="radio_8730">
                        <label for="radio_8730">Add Gravy &amp; Small Salad</label>
                    </p></li><li id="li_8861" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="8861" id="radio_8861">
                        <label for="radio_8861">Medium Cheese Pizza FRIDAY SPECIAL FISH &amp; CHIPS</label>
                    </p></li><li id="li_9188" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="9188" id="radio_9188">
                        <label for="radio_9188">XL Cheese Pizza</label>
                    </p></li><li id="li_9189" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="9189" id="radio_9189">
                        <label for="radio_9189">XL Pizza 1 topping</label>
                    </p></li><li id="li_9190" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="9190" id="radio_9190">
                        <label for="radio_9190">XL Pizza 2 toppings</label>
                    </p></li><li id="li_9191" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="9191" id="radio_9191">
                        <label for="radio_9191">XL Pizza 3 toppings</label>
                    </p></li><li id="li_9192" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="9192" id="radio_9192">
                        <label for="radio_9192">All Appetizers (No Price)</label>
                    </p></li><li id="li_9193" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="9193" id="radio_9193">
                        <label for="radio_9193">1 XLarge Pizza 2 Toppings</label>
                    </p></li><li id="li_9216" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="9216" id="radio_9216">
                        <label for="radio_9216">Sauce On or On Side</label>
                    </p></li><li id="li_9261" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="9261" id="radio_9261">
                        <label for="radio_9261">Large Pizza 1 Topping</label>
                    </p></li><li id="li_9262" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="9262" id="radio_9262">
                        <label for="radio_9262">Half Priced Family FRIES</label>
                    </p></li><li id="li_9305" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="9305" id="radio_9305">
                        <label for="radio_9305">Wings Customization</label>
                    </p></li><li id="li_9361" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="9361" id="radio_9361">
                        <label for="radio_9361">Monday To Thursday Pizza Course</label>
                    </p></li><li id="li_9362" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="9362" id="radio_9362">
                        <label for="radio_9362">Wings for Monday to Thursday</label>
                    </p></li><li id="li_62720" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="62720" id="radio_62720">
                        <label for="radio_62720">Premium Poutine  - Choice of Fries</label>
                    </p></li><li id="li_62721" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="62721" id="radio_62721">
                        <label for="radio_62721">Premium Poutinesc - Cheese Selection</label>
                    </p></li><li id="li_62722" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="62722" id="radio_62722">
                        <label for="radio_62722">Ranch - Blue Cheese- Roasted Garlic Everything Sauce</label>
                    </p></li><li id="li_62723" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="62723" id="radio_62723">
                        <label for="radio_62723">Tossed Popcorn Chicken Sauces</label>
                    </p></li><li id="li_9187" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="9187" id="radio_9187" checked="">
                        <label for="radio_9187">Large Pizza 5 Toppings</label>
                    </p></li></ul>



Notice that only 1 combo groups were assigned to this dish:
<li id="li_9187" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
	<input type="checkbox" name="group[]" value="9187" id="radio_9187" checked="">
	<label for="radio_9187">Large Pizza 5 Toppings</label>
</p></li>

I want you to only use the combo groups of that were checked (<input checked="">) to assign each combo group to each dish.

1. Some combos a drink modifier: <p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px">Drinks</p> if you see this element you need to:
a. Scrape the modifier group: 
<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
	<input checked="" onclick="$$('#uld ul[class=\'d\']').each(function(u){$(u.id).hide()}); if(this.checked){ $('list_d_2052').show();}" type="radio" name="d_radio" value="2052" id="radio_d_2052">
	<label for="radio_d_2052">Drinks can</label>
</p>

and store it in the menuca_v3.modifier_groups and assign it to this dish_id

2. Scrape the modifiers and their prices and assign it to this dish:
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

Finally, each dish has a Hide Dish option. 

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

If any if the <input> elements are checked, set the value of hide_option_enabled to true, scrape the data and store it in the respective table menuca_v3.dish_availability 

## Normal dishes
