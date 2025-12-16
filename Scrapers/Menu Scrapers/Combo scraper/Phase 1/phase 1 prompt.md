
# This scraper will have two phases:

## Phase 1: Scrape all Combo Groups 
Go over the v1 restaurants in the menuca_v3.restaurants table, verify if it has combo groups and if it does store all the combo groups, combo group sections, combo modifier groups, combo modifiers and combo modifier prices for each restaurant

## Phase 2:
Go over each dish for each restaurant and verify if it is a combo dish. If it is, link it to the right combo group ID so we can map the right modifiers to it. If not continue with the next dish.



# Mapping for the scraping process:
We will use the legacy V1 CRM to scrape the data. Each restaurant in the phase 1 has a legacy_v1_id. This should be our primary criteria to determine which restaurant should be scraped in the v1 scraper.

# Notable exclusions from this process:
## All the 5 MVP Restaurants:
	- [Restaurant #1: Ginkgo Garden (ID: 105)]
	- [Restaurant #2: Orchid Sushi (ID: 245)]
	- [Restaurant #3: Lucky Star Chinese Food (ID: 8)]
	- [Restaurant #4: Champa Thai Cuisine (ID: 87)]
	- [Restaurant #5: Hung Mein (ID: 119)]
	- Econo Pizza v3 ID 1009
	- Joes Family Pizzeria V3 ID: 636
## The 5 phase 2 restaurants:
	V3 ID	V1 ID	Restaurant	Reason for Phase 2
	265	411	Milano - 2 Pembroke	19.3% price coverage
	607	830	Aroy Thai	30.8% price coverage + 0 modifiers
	924	1013	All Out Burger Bank St.	Completely empty
	948	1038	All Out Burger Gladstone	Completely empty
	949	1071	All Out Burger Montreal Rd	Completely empty

## Scraped restaurants with no combo dishes (71 Restaurants):

| V3 ID | Restaurant Name |
|-------|-----------------|
| 561 | Aahar The Taste of India |
| 630 | Asia Garden Ottawa |
| 72 | Cathay Restaurants |
| 87 | Champa Thai Cuisine |
| 943 | Charm Thai Cuisine |
| 641 | China Moon |
| 584 | Crispy's |
| 806 | Crispy's Bank Street |
| 816 | Dépanneur Généreux |
| 638 | Digby's Restaurant |
| 1009 | Econo Pizza |
| 511 | Egg Roll Factory |
| 211 | Erman Pizza |
| 730 | Friendly Restaurant and Pizzeria |
| 105 | Ginkgo Garden |
| 736 | Greber Pizza et Shawarma |
| 519 | HaNoi Pho |
| 160 | Hong Kong Chinese Food Takeout |
| 119 | Hung Mein |
| 479 | iCook Pho You |
| 180 | Indian Punjabi Clay Oven |
| 646 | JC Royal Thai Cuisine |
| 798 | Kabylie Pizza |
| 721 | La Maison Pho |
| 727 | La Maison du Burger |
| 825 | La Nawab V2 |
| 1010 | Lemongrass Thai Cuisine |
| 491 | Light of India |
| 267 | Lucky Fortune |
| 174 | Lucky King Take Out |
| 8 | Lucky Star Chinese Food |
| 614 | Marina Pizza des Flandres |
| 205 | Mont Liban Bakery & Shawarma |
| 644 | Mozza Pizza Hull |
| 1011 | Mozza Pizza Gatineau |
| 845 | Mykonos Greek Grill |
| 846 | Mykonos Greek Grill |
| 502 | New Hong Kong |
| 15 | New Mee Fung Restaurant |
| 234 | New Mukut Restaurant Indian Cuisine |
| 807 | Oh My Grill |
| 681 | Oka's Hull |
| 797 | Papa Burger |
| 822 | Papa Burger Maloney |
| 540 | Papa Grecque des Flandres |
| 616 | Papa Grecque Maloney |
| 810 | Papa Grecque Cantley |
| 437 | Papa Joe's Fried Chicken - Downtown |
| 70 | Papa Pizza - Hull |
| 602 | Papa Pizza Cantley |
| 795 | Papa Pizza Chem. de Masson |
| 1012 | Papa Pizza Des Flandres |
| 1013 | Papa Pizza Maloney |
| 1014 | Papa Pizza Val-Des-Monts |
| 712 | Patate Lou Lou |
| 199 | Pho Bo Ga King - Somerset |
| 139 | Pizza Bravo |
| 562 | Pizza des Hautes Plaines |
| 726 | Pizza Joanna |
| 696 | Pizza Maisonneuve |
| 716 | PizzaRama |
| 1016 | Roulas Grecque et Pizza |
| 376 | Sachi Sushi |
| 745 | Sala Thai |
| 269 | Shaan Tandoori |
| 836 | Souvlaki Souvlaki |
| 596 | Sushi Fleury |
| 1017 | Sushi Express Chambly |
| 847 | Sushiyana |
| 941 | Ting's Kitchen |
| 820 | Vieux Hull Pizza |
---

# V3 Combo Schema (menuca_v3)

## Tables Created

The following 6 tables store combo modifier data scraped from V1 CRM:

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

# Instructions:

## Phase 1

1. In the landing page you will find the v1 restaurants under an <ul id="active"> element. Each V1 restaurant is stored in an <li> element:

Each <li> element has an <a> element containing a link to the details page of each restaurant. This <a> element also contians the unique v1 id that identifies each restaurant. For instance the restaurant Centertown Donair & Pizza the a element contains its v1 id (383) in the href parameter <a href="/?p=restaurants&amp;display=editRestaurant&amp;restaurant=255">Edit</a>. You should use this element to both identify the v1 restaurants that must be scraped and access its details page where the data that needs to be scrapped is located.

2. Once you get to the details page of each restaurant you need to click this <a> element to navigate to the menu details:
<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=255&amp;load=menu&amp;showLang=en">Menu</a> this will take you tohttps://menuadmin.menu.ca/?p=restaurants&display=editRestaurant&restaurant=255&load=menu&showLang=en

3. In the menu details page search for the Combo Groups <a> element <a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=255&amp;load=comboGroups&amp;showLang=en">Combo Groups</a>. It is located inside a <div> with a style margin-left:501px;

4. Once you get to the combo groups you must check if the HTML contains any <p> element with a style of margin-top:1px;height:20px;line-height:1.5;background-color: #ccc;padding-left:20px;border:1px solid #aaa. If it doesn't continue with the next restaurant

5. If the page does contain a <p> element with a style of "margin-top:1px;height:20px;line-height:1.5;background-color: #ccc;padding-left:20px;border:1px solid #aaa" that means the current restaurant has Combos with modifiers that need to be scraped. I want you to click on the details of each combo group: 

<p style="margin-top:1px;height:20px;line-height:1.5;background-color: #ccc;padding-left:20px;border:1px solid #aaa">
        <a href="#" onclick="editGroupJS('1502');return false;">1 Medium 3 toppings</a>
    </p>

You can extract the COMBO_GROUPS.source_id value from this link. For example, for the 1 Medium 3 toppings the source_id is 1502.

6. Once you are on the details of each modifier group (https://menuadmin.menu.ca/?p=restaurants&display=editRestaurant&restaurant=255&load=comboGroups&showLang=en#) you must:

### Scrape the COMBO_GROUPS data:
- name: <input type="text" name="name" id="name" value="1 Medium 3 toppings" style="height:20px; line-height:20px;margin:2px; border:1px solid #aaa;width:420px">
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
<p><input type="checkbox" id="hasBread" name="hasBread" value="Y" onclick="if(this.checked){ $('breadNo').show(); $('br_id').appear(); } else {$('br_id').fade();$('breadNo').hide()}"> <label for="hasBread">Has Bread</label></p>
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
<p><input type="checkbox" id="hasSideDish" name="hasSideDish" onclick="if(this.checked){ $('sdNo').show(); $('sd_id').appear(); } else {$('sdNo').hide();$('sd_id').fade()}" value="Y"> <label for="hasSideDish">Has Side Dishes</label></p>
<p id="sdNo" style="display: none;padding-left:20px">
	<label for="sdHeader">Use header</label><input type="text" name="sdHeader" id="sdHeader" value=""><br>
	<label for="minSD" style="display: inline">Min side dishes: </label><input type="text" name="minsd" id="minSD" size="3" value="0"><br>
	<label for="maxSD" style="display: inline">Max side dishes: </label><input type="text" name="maxsd" id="maxSD" size="3" value="0"><br>
	<label for="freeSD" style="display: inline">Free items: </label><input type="text" name="freeSD" id="freeSD" size="3" value="0"><br>
	<label for="displayOrderSD">Display Order</label><input type="text" name="displayOrderSD" id="displayOrderSD" value="" size="3">
</p>

For the Extras
<p><input type="checkbox" id="hasExtras" name="hasExtras" value="Y" onclick="if(this.checked){ $('extraNo').show();$('e_id').appear() } else { $('e_id').fade(); $('extraNo').hide() }"> <label for="hasExtras">Has Extras</label></p>
<p id="extraNo" style="display: none;padding-left:20px">
	<label for="extraHeader">Use header</label><input type="text" name="extraHeader" id="extraHeader" value=""><br>
	<label for="minExtra" style="display: inline">Min extras: </label><input type="text" name="minextras" id="minExtra" size="3" value="0"><br>
	<label for="maxExtra" style="display: inline">Max extras: </label><input type="text" name="maxextras" id="maxExtra" size="3" value="0"><br>
	<label for="freeExtra" style="display: inline">Free items: </label><input type="text" name="freeExtra" id="freeExtra" size="3" value="0"><br>
	<label for="displayOrderExtras">Display Order</label><input type="text" name="displayOrderExtras" id="displayOrderExtras" value="" size="3">
</p>

For the Cooking method 
<p><input type="checkbox" id="hasCM" name="hasCM" value="Y" onclick="if(this.checked){ $('cmNo').show();$('cm_id').appear() } else { $('cm_id').fade(); $('cmNo').hide() }"> <label for="hasCM">Has Cooking Method</label></p>
<p id="cmNo" style="display: none;padding-left:20px">
	<label for="cmHeader">Use header</label><input type="text" name="cmHeader" id="cmHeader" value=""><br>
	<label for="minCm" style="display: inline">Min CM: </label><input type="text" name="minCm" id="minCm" size="3" value="0"><br>
	<label for="maxCm" style="display: inline">Max CM: </label><input type="text" name="maxCm" id="maxCm" size="3" value="0"><br>
	<label for="freeCm" style="display: inline">Free items: </label><input type="text" name="freeCm" id="freeCm" size="3" value="0"><br>
	<label for="displayOrderCm">Display Order</label><input type="text" name="displayOrderCm" id="displayOrderCm" value="" size="3">
</p>

Notice that from the examples that I just gave you only Custom Ingredients is checked:
<p><input checked="" type="checkbox" id="hasCustomisation" name="hasCustomisation" value="Y" onclick="if(this.checked){ $('ci_id').appear();$('ciNo').show(); } else {$('ci_id').fade();$('ciNo').hide();}"> <label for="hasCustomisation">Has Custom Ingredients</label></p>

I want you to only scrape only the sections that are checked (checked="") for the current combo group. In this example you are only required to scrape 

For the Custom Ingredients section:
<p><input checked="" type="checkbox" id="hasCustomisation" name="hasCustomisation" value="Y" onclick="if(this.checked){ $('ci_id').appear();$('ciNo').show(); } else {$('ci_id').fade();$('ciNo').hide();}"> <label for="hasCustomisation">Has Custom Ingredients</label></p>
<p id="ciNo" style="padding-left: 20px;">
	<label for="ciHeader">Use header</label><input type="text" name="ciHeader" id="ciHeader" value="First 3 Toppings Free"><br>
	<label for="minci" style="display: inline">Min custom items: </label><input type="text" name="minci" id="minci" size="3" value="3"><br>
	<label for="maxci" style="display: inline">Max custom items: </label><input type="text" name="maxci" id="maxci" size="3" value="0"><br>
	<label for="freeCI" style="display: inline">Free items: </label><input type="text" name="freeci" id="freeCI" size="3" value="3"><br>
	<label for="displayOrderCI">Display Order</label><input type="text" name="displayOrderCI" id="displayOrderCI" value="2" size="3">
</p>

use_header: <label for="ciHeader">Use header</label><input type="text" name="ciHeader" id="ciHeader" value="First 3 Toppings Free"><br>
display_order: <label for="displayOrderCI">Display Order</label><input type="text" name="displayOrderCI" id="displayOrderCI" value="2" size="3">
free_items: <label for="freeCI" style="display: inline">Free items: </label><input type="text" name="freeci" id="freeCI" size="3" value="3"><br>
min_selection: <label for="minci" style="display: inline">Min custom items: </label><input type="text" name="minci" id="minci" size="3" value="3"><br>
max_selection: <label for="maxci" style="display: inline">Max custom items: </label><input type="text" name="maxci" id="maxci" size="3" value="0"><br>

### Combo Modfier groups:
Each combo group section appears above its respective combo modifier groups

<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px">Custom Ingredients</p>
<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px">Side Dish</p>
<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px">Extras</p>
<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px">Bread</p>
<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px">Dressing</p>
<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px">Sauce</p>
<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px">Cooking Method</p>

Each section has one or more combo modifier groups. For example, for the 1 Medium 3 toppings Combo group, the Has Custom Ingredients section is active. This section has these modifier groups:

<ul id="ulci" style="list-style-type:none;overflow: hidden">
	<li>
									<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
										<input class="ci" onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()});if(this.checked){ $('list_ci_2040').show();}" type="radio" name="ci_radio" value="2040" id="radio_ci_2040">
										<label for="radio_ci_2040">Pizza Toppings</label>
									</p>
									<ul style="list-style-type: none; overflow: hidden;display:none" class="ci" id="list_ci_2040">
																																	<li style="width:30%; float: left;padding-left:2px">
													Pepperoni													<input type="text" size="5" name="ci[2040][9316]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Ham													<input type="text" size="5" name="ci[2040][9317]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Bacon													<input type="text" size="5" name="ci[2040][9318]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Italian Sausage													<input type="text" size="5" name="ci[2040][9319]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Chicken													<input type="text" size="5" name="ci[2040][9320]" value="1.50,2.75,3.75">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Ground Beef													<input type="text" size="5" name="ci[2040][9321]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Donair Meat													<input type="text" size="5" name="ci[2040][9322]" value="1.50,2.75,3.75">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Mushrooms													<input type="text" size="5" name="ci[2040][9323]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Onions													<input type="text" size="5" name="ci[2040][9324]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Tomatoes													<input type="text" size="5" name="ci[2040][9325]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Pineapple													<input type="text" size="5" name="ci[2040][9326]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Green Olives													<input type="text" size="5" name="ci[2040][9327]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Black Olives													<input type="text" size="5" name="ci[2040][9328]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Hot Banana Peppers													<input type="text" size="5" name="ci[2040][9329]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Green Peppers													<input type="text" size="5" name="ci[2040][9330]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Extra Cheese													<input type="text" size="5" name="ci[2040][9331]" value="1.50,2.75,3.75">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Feta													<input type="text" size="5" name="ci[2040][39072]" value="1.50,2.75,3.75">
												</li>
																														</ul>
								</li>
								<li>
									<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
										<input class="ci" checked="" onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()});if(this.checked){ $('list_ci_2041').show();}" type="radio" name="ci_radio" value="2041" id="radio_ci_2041">
										<label for="radio_ci_2041">Pizza Toppings without Premium</label>
									</p>
									<ul style="list-style-type: none; overflow: hidden;display:" class="ci" id="list_ci_2041">
																																														<li style="width:30%; float: left;padding-left:2px">
														Pepperoni														<input type="text" size="5" name="ci[2041][9316]" value="2.50">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Ham														<input type="text" size="5" name="ci[2041][9317]" value="2.50">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Bacon														<input type="text" size="5" name="ci[2041][9318]" value="2.50">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Italian Sausage														<input type="text" size="5" name="ci[2041][9319]" value="2.50">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Ground Beef														<input type="text" size="5" name="ci[2041][9321]" value="2.50">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Mushrooms														<input type="text" size="5" name="ci[2041][9323]" value="2.50">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Onions														<input type="text" size="5" name="ci[2041][9324]" value="2.50">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Tomatoes														<input type="text" size="5" name="ci[2041][9325]" value="2.50">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Pineapple														<input type="text" size="5" name="ci[2041][9326]" value="2.50">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Green Olives														<input type="text" size="5" name="ci[2041][9327]" value="2.50">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Black Olives														<input type="text" size="5" name="ci[2041][9328]" value="2.50">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Hot Banana Peppers														<input type="text" size="5" name="ci[2041][9329]" value="2.50">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Green Peppers														<input type="text" size="5" name="ci[2041][9330]" value="2.50">
													</li>
																																										</ul>
								</li>
								<li>
									<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
										<input class="ci" onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()});if(this.checked){ $('list_ci_2042').show();}" type="radio" name="ci_radio" value="2042" id="radio_ci_2042">
										<label for="radio_ci_2042">Premium Toppings</label>
									</p>
									<ul style="list-style-type: none; overflow: hidden;display:none" class="ci" id="list_ci_2042">
																																	<li style="width:30%; float: left;padding-left:2px">
													Chicken													<input type="text" size="5" name="ci[2042][9320]" value="1.50,2.75,3.75">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Donair Meat													<input type="text" size="5" name="ci[2042][9322]" value="1.50,2.75,3.75">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Extra Cheese													<input type="text" size="5" name="ci[2042][9331]" value="1.50,2.75,3.75">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Feta													<input type="text" size="5" name="ci[2042][39072]" value="1.50,2.75,3.75">
												</li>
																														</ul>
								</li>
								<li>
									<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
										<input class="ci" onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()});if(this.checked){ $('list_ci_2046').show();}" type="radio" name="ci_radio" value="2046" id="radio_ci_2046">
										<label for="radio_ci_2046">Burgers ing</label>
									</p>
									<ul style="list-style-type: none; overflow: hidden;display:none" class="ci" id="list_ci_2046">
																																	<li style="width:30%; float: left;padding-left:2px">
													Mustard													<input type="text" size="5" name="ci[2046][9342]" value="0.00">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Hot Peppers													<input type="text" size="5" name="ci[2046][9346]" value="0.00">
												</li>
																														</ul>
								</li>
								<li>
									<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
										<input class="ci" onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()});if(this.checked){ $('list_ci_2074').show();}" type="radio" name="ci_radio" value="2074" id="radio_ci_2074">
										<label for="radio_ci_2074">Pizza Toppings for Single Pizza</label>
									</p>
									<ul style="list-style-type: none; overflow: hidden;display:none" class="ci" id="list_ci_2074">
																																	<li style="width:30%; float: left;padding-left:2px">
													Pepperoni													<input type="text" size="5" name="ci[2074][9316]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Ham													<input type="text" size="5" name="ci[2074][9317]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Bacon													<input type="text" size="5" name="ci[2074][9318]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Italian Sausage													<input type="text" size="5" name="ci[2074][9319]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Chicken													<input type="text" size="5" name="ci[2074][9320]" value="1.50,2.75,3.75">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Ground Beef													<input type="text" size="5" name="ci[2074][9321]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Donair Meat													<input type="text" size="5" name="ci[2074][9322]" value="1.50,2.75,3.75">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Mushrooms													<input type="text" size="5" name="ci[2074][9323]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Onions													<input type="text" size="5" name="ci[2074][9324]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Tomatoes													<input type="text" size="5" name="ci[2074][9325]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Pineapple													<input type="text" size="5" name="ci[2074][9326]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Green Olives													<input type="text" size="5" name="ci[2074][9327]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Black Olives													<input type="text" size="5" name="ci[2074][9328]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Hot Banana Peppers													<input type="text" size="5" name="ci[2074][9329]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Green Peppers													<input type="text" size="5" name="ci[2074][9330]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Extra Cheese													<input type="text" size="5" name="ci[2074][9331]" value="1.50,2.75,3.75">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Feta													<input type="text" size="5" name="ci[2074][39072]" value="1.50,2.75,3.75">
												</li>
																														</ul>
								</li>
								<li>
									<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
										<input class="ci" onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()});if(this.checked){ $('list_ci_2075').show();}" type="radio" name="ci_radio" value="2075" id="radio_ci_2075">
										<label for="radio_ci_2075">Pizza Toppings without Premium for Single Pizza</label>
									</p>
									<ul style="list-style-type: none; overflow: hidden;display:none" class="ci" id="list_ci_2075">
																																	<li style="width:30%; float: left;padding-left:2px">
													Pepperoni													<input type="text" size="5" name="ci[2075][9316]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Ham													<input type="text" size="5" name="ci[2075][9317]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Bacon													<input type="text" size="5" name="ci[2075][9318]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Italian Sausage													<input type="text" size="5" name="ci[2075][9319]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Ground Beef													<input type="text" size="5" name="ci[2075][9321]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Mushrooms													<input type="text" size="5" name="ci[2075][9323]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Onions													<input type="text" size="5" name="ci[2075][9324]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Tomatoes													<input type="text" size="5" name="ci[2075][9325]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Pineapple													<input type="text" size="5" name="ci[2075][9326]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Green Olives													<input type="text" size="5" name="ci[2075][9327]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Black Olives													<input type="text" size="5" name="ci[2075][9328]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Hot Banana Peppers													<input type="text" size="5" name="ci[2075][9329]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Green Peppers													<input type="text" size="5" name="ci[2075][9330]" value="1.25,2.50,2.95">
												</li>
																														</ul>
								</li>
								<li>
									<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
										<input class="ci" onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()});if(this.checked){ $('list_ci_2076').show();}" type="radio" name="ci_radio" value="2076" id="radio_ci_2076">
										<label for="radio_ci_2076">Premium Toppings for Single Pizza</label>
									</p>
									<ul style="list-style-type: none; overflow: hidden;display:none" class="ci" id="list_ci_2076">
																																	<li style="width:30%; float: left;padding-left:2px">
													Chicken													<input type="text" size="5" name="ci[2076][9320]" value="1.50,2.75,3.75">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Donair Meat													<input type="text" size="5" name="ci[2076][9322]" value="1.50,2.75,3.75">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Extra Cheese													<input type="text" size="5" name="ci[2076][9331]" value="1.50,2.75,3.75">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Feta													<input type="text" size="5" name="ci[2076][39072]" value="1.50,2.75,3.75">
												</li>
																														</ul>
								</li>
																		</ul>

Notice that for this example only the Pizza Toppings without Premium was checked:
<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
	<input class="ci" checked="" onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()});if(this.checked){ $('list_ci_2041').show();}" type="radio" name="ci_radio" value="2041" id="radio_ci_2041">
	<label for="radio_ci_2041">Pizza Toppings without Premium</label>
</p>
		 
I want you to only scrape the modifier groups that were checked (checked=""). Each combo modifier group have one or more combo modifers each with one or more prices depending on the size:

<ul style="list-style-type: none; overflow: hidden;display:" class="ci" id="list_ci_2041">
																																														<li style="width:30%; float: left;padding-left:2px">
														Pepperoni														<input type="text" size="5" name="ci[2041][9316]" value="2.50">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Ham														<input type="text" size="5" name="ci[2041][9317]" value="2.50">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Bacon														<input type="text" size="5" name="ci[2041][9318]" value="2.50">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Italian Sausage														<input type="text" size="5" name="ci[2041][9319]" value="2.50">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Ground Beef														<input type="text" size="5" name="ci[2041][9321]" value="2.50">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Mushrooms														<input type="text" size="5" name="ci[2041][9323]" value="2.50">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Onions														<input type="text" size="5" name="ci[2041][9324]" value="2.50">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Tomatoes														<input type="text" size="5" name="ci[2041][9325]" value="2.50">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Pineapple														<input type="text" size="5" name="ci[2041][9326]" value="2.50">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Green Olives														<input type="text" size="5" name="ci[2041][9327]" value="2.50">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Black Olives														<input type="text" size="5" name="ci[2041][9328]" value="2.50">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Hot Banana Peppers														<input type="text" size="5" name="ci[2041][9329]" value="2.50">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Green Peppers														<input type="text" size="5" name="ci[2041][9330]" value="2.50">
													</li>
																																										</ul>


Here is the complete html markup for combo group 1 Medium 3 toppings:
<form id="editGroupForm" action="ajax/comboGroups.php?action=update" method="post">
	<input type="text" name="name" id="name" value="1 Medium 3 toppings" style="height:20px; line-height:20px;margin:2px; border:1px solid #aaa;width:420px">
	<input type="submit" value="Update" style="clear: both">
	<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=255&amp;load=comboGroups&amp;showLang=en&amp;action=delete&amp;group=1502" onclick="return confirm('Realy Delete?')">Delete</a>
	<a href="#" onclick="copyGroup(1502);return false;">Copy group</a>
	<input type="hidden" name="restaurant" value="255">
	<input type="hidden" name="lang" value="en">
	<input type="hidden" name="id" value="1502 ">

	<div style="width:550px; float: left">
		<ul style="list-style-type:none;" id="dishes">
												<li>
						<h4>Specials</h4>
						<ul style="list-style-type: none; margin-left: 10px;overflow: hidden">
							
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20051" id="items_20051"> <label style="display: inline" for="items_20051">Medium Pizza and Donairs</label></li>
								
							
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20040" id="items_20040"> <label style="display: inline" for="items_20040">Small Pizza and One Garlic Fingers</label></li>
								
							
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20041" id="items_20041"> <label style="display: inline" for="items_20041">Medium Pizza and One Garlic Fingers</label></li>
								
							
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20042" id="items_20042"> <label style="display: inline" for="items_20042">Large Pizza and One Garlic Fingers</label></li>
								
							
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="57648" id="items_57648"> <label style="display: inline" for="items_57648">2 Small Donairs and Garlic Fingers</label></li>
								
							
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="57645" id="items_57645"> <label style="display: inline" for="items_57645">2 Small Halifax Donairs</label></li>
								
							
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="57643" id="items_57643"> <label style="display: inline" for="items_57643">2 Small Donairs and Wings HIDE</label></li>
								
							
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20043" id="items_20043"> <label style="display: inline" for="items_20043">Large Pizza and Donair Special HIDE</label></li>
								
													</ul>
					</li>
									<li>
						<h4>Pizza</h4>
						<ul style="list-style-type: none; margin-left: 10px;overflow: hidden">
							
																																				<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20166.0" id="items_20166.0"> <label style="display: inline" for="items_20166.0">Plain  Small (9")</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20166.1" id="items_20166.1"> <label style="display: inline" for="items_20166.1">Plain  Medium (12")</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20166.2" id="items_20166.2"> <label style="display: inline" for="items_20166.2">Plain  Large (15")</label></li>
																	
							
																																				<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20167.0" id="items_20167.0"> <label style="display: inline" for="items_20167.0">1 Topping  Small (9")</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20167.1" id="items_20167.1"> <label style="display: inline" for="items_20167.1">1 Topping  Medium (12")</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20167.2" id="items_20167.2"> <label style="display: inline" for="items_20167.2">1 Topping  Large (15")</label></li>
																	
							
																																				<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20168.0" id="items_20168.0"> <label style="display: inline" for="items_20168.0">2 Toppings Small (9")</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20168.1" id="items_20168.1"> <label style="display: inline" for="items_20168.1">2 Toppings Medium (12")</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20168.2" id="items_20168.2"> <label style="display: inline" for="items_20168.2">2 Toppings Large (15")</label></li>
																	
							
																																				<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20169.0" id="items_20169.0"> <label style="display: inline" for="items_20169.0">Canadian  Small (9")</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20169.1" id="items_20169.1"> <label style="display: inline" for="items_20169.1">Canadian  Medium (12")</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20169.2" id="items_20169.2"> <label style="display: inline" for="items_20169.2">Canadian  Large (15")</label></li>
																	
							
																																				<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20170.0" id="items_20170.0"> <label style="display: inline" for="items_20170.0">Combination  Small (9")</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20170.1" id="items_20170.1"> <label style="display: inline" for="items_20170.1">Combination  Medium (12")</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20170.2" id="items_20170.2"> <label style="display: inline" for="items_20170.2">Combination  Large (15")</label></li>
																	
							
																																				<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20171.0" id="items_20171.0"> <label style="display: inline" for="items_20171.0">Hawaiian  Small (9")</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20171.1" id="items_20171.1"> <label style="display: inline" for="items_20171.1">Hawaiian  Medium (12")</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20171.2" id="items_20171.2"> <label style="display: inline" for="items_20171.2">Hawaiian  Large (15")</label></li>
																	
							
																																				<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20174.0" id="items_20174.0"> <label style="display: inline" for="items_20174.0">Vegetarian Small (9")</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20174.1" id="items_20174.1"> <label style="display: inline" for="items_20174.1">Vegetarian Medium (12")</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20174.2" id="items_20174.2"> <label style="display: inline" for="items_20174.2">Vegetarian Large (15")</label></li>
																	
							
																																				<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20176.0" id="items_20176.0"> <label style="display: inline" for="items_20176.0">Meat Lovers Pizza Small (9")</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20176.1" id="items_20176.1"> <label style="display: inline" for="items_20176.1">Meat Lovers Pizza Medium (12")</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20176.2" id="items_20176.2"> <label style="display: inline" for="items_20176.2">Meat Lovers Pizza Large (15")</label></li>
																	
							
																																				<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20180.0" id="items_20180.0"> <label style="display: inline" for="items_20180.0">Deluxe Small (9")</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20180.1" id="items_20180.1"> <label style="display: inline" for="items_20180.1">Deluxe Medium (12")</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20180.2" id="items_20180.2"> <label style="display: inline" for="items_20180.2">Deluxe Large (15")</label></li>
																	
							
																																				<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20173.0" id="items_20173.0"> <label style="display: inline" for="items_20173.0">Real Halifax Donair Pizza Small (9")</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20173.1" id="items_20173.1"> <label style="display: inline" for="items_20173.1">Real Halifax Donair Pizza Medium (12")</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20173.2" id="items_20173.2"> <label style="display: inline" for="items_20173.2">Real Halifax Donair Pizza Large (15")</label></li>
																	
							
																																				<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20172.0" id="items_20172.0"> <label style="display: inline" for="items_20172.0">Chicken Pizza HIDE Small (9")</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20172.1" id="items_20172.1"> <label style="display: inline" for="items_20172.1">Chicken Pizza HIDE Medium (12")</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20172.2" id="items_20172.2"> <label style="display: inline" for="items_20172.2">Chicken Pizza HIDE Large (15")</label></li>
																	
							
																																				<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20175.0" id="items_20175.0"> <label style="display: inline" for="items_20175.0">Chef’s Special Pizza HIDE Small (9")</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20175.1" id="items_20175.1"> <label style="display: inline" for="items_20175.1">Chef’s Special Pizza HIDE Medium (12")</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20175.2" id="items_20175.2"> <label style="display: inline" for="items_20175.2">Chef’s Special Pizza HIDE Large (15")</label></li>
																	
							
																																				<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20178.0" id="items_20178.0"> <label style="display: inline" for="items_20178.0">Greek Pizza HIDE Small (9")</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20178.1" id="items_20178.1"> <label style="display: inline" for="items_20178.1">Greek Pizza HIDE Medium (12")</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20178.2" id="items_20178.2"> <label style="display: inline" for="items_20178.2">Greek Pizza HIDE Large (15")</label></li>
																	
							
																																				<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20179.0" id="items_20179.0"> <label style="display: inline" for="items_20179.0">Mexican HIDE Small (9")</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20179.1" id="items_20179.1"> <label style="display: inline" for="items_20179.1">Mexican HIDE Medium (12")</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20179.2" id="items_20179.2"> <label style="display: inline" for="items_20179.2">Mexican HIDE Large (15")</label></li>
																	
							
																																				<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20177.0" id="items_20177.0"> <label style="display: inline" for="items_20177.0">Centertown Special HIDE Small (9")</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20177.1" id="items_20177.1"> <label style="display: inline" for="items_20177.1">Centertown Special HIDE Medium (12")</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20177.2" id="items_20177.2"> <label style="display: inline" for="items_20177.2">Centertown Special HIDE Large (15")</label></li>
																	
							
																																				<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20181.0" id="items_20181.0"> <label style="display: inline" for="items_20181.0">Indian Punjabi Pizza HIDE Small (9")</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20181.1" id="items_20181.1"> <label style="display: inline" for="items_20181.1">Indian Punjabi Pizza HIDE Medium (12")</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20181.2" id="items_20181.2"> <label style="display: inline" for="items_20181.2">Indian Punjabi Pizza HIDE Large (15")</label></li>
																	
													</ul>
					</li>
									<li>
						<h4>Twins Pizza Special</h4>
						<ul style="list-style-type: none; margin-left: 10px;overflow: hidden">
							
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="70189" id="items_70189"> <label style="display: inline" for="items_70189">2 Small Pizza Special</label></li>
								
							
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="70190" id="items_70190"> <label style="display: inline" for="items_70190">2 Medium Pizza Special</label></li>
								
							
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="70191" id="items_70191"> <label style="display: inline" for="items_70191">2 Large Pizza Special</label></li>
								
													</ul>
					</li>
									<li>
						<h4>Wings</h4>
						<ul style="list-style-type: none; margin-left: 10px;overflow: hidden">
							
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20003" id="items_20003"> <label style="display: inline" for="items_20003">10 Wings</label></li>
								
							
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20004" id="items_20004"> <label style="display: inline" for="items_20004">15 Wings</label></li>
								
							
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20006" id="items_20006"> <label style="display: inline" for="items_20006">25 Wings HIDE</label></li>
								
													</ul>
					</li>
									<li>
						<h4>Subs</h4>
						<ul style="list-style-type: none; margin-left: 10px;overflow: hidden">
							
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20009" id="items_20009"> <label style="display: inline" for="items_20009">Pepperoni Sub</label></li>
								
							
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20010" id="items_20010"> <label style="display: inline" for="items_20010">Pizza Sub</label></li>
								
													</ul>
					</li>
									<li>
						<h4>Halifax Donair</h4>
						<ul style="list-style-type: none; margin-left: 10px;overflow: hidden">
							
																																				<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="19997.0" id="items_19997.0"> <label style="display: inline" for="items_19997.0">Donair in a Pita Small</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="19997.1" id="items_19997.1"> <label style="display: inline" for="items_19997.1">Donair in a Pita Large</label></li>
																	
							
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="19998" id="items_19998"> <label style="display: inline" for="items_19998">Donair Sub</label></li>
								
							
																																				<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="19999.0" id="items_19999.0"> <label style="display: inline" for="items_19999.0">Donair Platter Small</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="19999.1" id="items_19999.1"> <label style="display: inline" for="items_19999.1">Donair Platter Large</label></li>
																	
							
																																				<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20000.0" id="items_20000.0"> <label style="display: inline" for="items_20000.0">Diane’s Donair Salad Small</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20000.1" id="items_20000.1"> <label style="display: inline" for="items_20000.1">Diane’s Donair Salad Large</label></li>
																	
							
																																				<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20001.0" id="items_20001.0"> <label style="display: inline" for="items_20001.0">Jessica’s Donair Poutine Small</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20001.1" id="items_20001.1"> <label style="display: inline" for="items_20001.1">Jessica’s Donair Poutine Large</label></li>
																	
							
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="57630" id="items_57630"> <label style="display: inline" for="items_57630">Donair Sauce</label></li>
								
							
																																				<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20002.0" id="items_20002.0"> <label style="display: inline" for="items_20002.0">Tasty Garlic Fingers Small</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20002.1" id="items_20002.1"> <label style="display: inline" for="items_20002.1">Tasty Garlic Fingers Medium</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20002.2" id="items_20002.2"> <label style="display: inline" for="items_20002.2">Tasty Garlic Fingers Large</label></li>
																	
													</ul>
					</li>
									<li>
						<h4>Salads</h4>
						<ul style="list-style-type: none; margin-left: 10px;overflow: hidden">
							
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="19981" id="items_19981"> <label style="display: inline" for="items_19981">Caesar Salad</label></li>
								
							
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="19982" id="items_19982"> <label style="display: inline" for="items_19982">Chef Salad</label></li>
								
							
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="19980" id="items_19980"> <label style="display: inline" for="items_19980">Greek Salad HIDE</label></li>
								
													</ul>
					</li>
									<li>
						<h4>Platters</h4>
						<ul style="list-style-type: none; margin-left: 10px;overflow: hidden">
							
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="19983" id="items_19983"> <label style="display: inline" for="items_19983">Hamburger HIDE</label></li>
								
							
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="19984" id="items_19984"> <label style="display: inline" for="items_19984">Hamburger Platter HIDE</label></li>
								
							
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="19986" id="items_19986"> <label style="display: inline" for="items_19986">Club Sandwich HIDE</label></li>
								
													</ul>
					</li>
									<li>
						<h4>Side Orders</h4>
						<ul style="list-style-type: none; margin-left: 10px;overflow: hidden">
							
																																				<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="19989.0" id="items_19989.0"> <label style="display: inline" for="items_19989.0">Poutine Small</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="19989.1" id="items_19989.1"> <label style="display: inline" for="items_19989.1">Poutine Large</label></li>
																	
							
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="19991" id="items_19991"> <label style="display: inline" for="items_19991">French Fries</label></li>
								
							
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="19993" id="items_19993"> <label style="display: inline" for="items_19993">Onion Rings</label></li>
								
							
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="19994" id="items_19994"> <label style="display: inline" for="items_19994">Cheese Sticks with Fries</label></li>
								
							
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="19995" id="items_19995"> <label style="display: inline" for="items_19995">Gravy</label></li>
								
							
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="19996" id="items_19996"> <label style="display: inline" for="items_19996">Deep Fried Zucchini Sticks</label></li>
								
							
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="19990" id="items_19990"> <label style="display: inline" for="items_19990">Garlic Bread</label></li>
								
							
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="70192" id="items_70192"> <label style="display: inline" for="items_70192">Garlic Bread with Cheese</label></li>
								
							
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="70193" id="items_70193"> <label style="display: inline" for="items_70193">Italian Garlic Bread</label></li>
								
							
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="19992" id="items_19992"> <label style="display: inline" for="items_19992">Egg Roll HIDE</label></li>
								
													</ul>
					</li>
									<li>
						<h4>Desserts</h4>
						<ul style="list-style-type: none; margin-left: 10px;overflow: hidden">
							
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20011" id="items_20011"> <label style="display: inline" for="items_20011">Cherry Cheesecake</label></li>
								
													</ul>
					</li>
									<li>
						<h4>Drinks</h4>
						<ul style="list-style-type: none; margin-left: 10px;overflow: hidden">
							
																																				<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20012.0" id="items_20012.0"> <label style="display: inline" for="items_20012.0">Pepsi Can</label></li>
																	
							
																																				<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20013.0" id="items_20013.0"> <label style="display: inline" for="items_20013.0">Coke Can</label></li>
																	
							
																																				<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20014.0" id="items_20014.0"> <label style="display: inline" for="items_20014.0">Diet Pepsi Can</label></li>
																	
							
																																				<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20015.0" id="items_20015.0"> <label style="display: inline" for="items_20015.0">Diet Coke Can</label></li>
																	
							
																																				<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20016.0" id="items_20016.0"> <label style="display: inline" for="items_20016.0">Ginger Ale Can</label></li>
																	
							
																																				<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20017.0" id="items_20017.0"> <label style="display: inline" for="items_20017.0">Sprite Can</label></li>
																	
							
																																				<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20018.0" id="items_20018.0"> <label style="display: inline" for="items_20018.0">Orange Crush HIDE Can</label></li>
																	
							
																																				<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20019.0" id="items_20019.0"> <label style="display: inline" for="items_20019.0">Root Beer HIDE Can</label></li>
																	
							
																																				<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20021.0" id="items_20021.0"> <label style="display: inline" for="items_20021.0">Iced Tea Can</label></li>
																	
							
																																				<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20023.0" id="items_20023.0"> <label style="display: inline" for="items_20023.0">Small Juice Apple</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20023.1" id="items_20023.1"> <label style="display: inline" for="items_20023.1">Small Juice Orange</label></li>
																	
							
																																				<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20024.0" id="items_20024.0"> <label style="display: inline" for="items_20024.0">Snapple Iced Tea</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20024.1" id="items_20024.1"> <label style="display: inline" for="items_20024.1">Snapple Lemonade</label></li>
																	
							
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="20025" id="items_20025"> <label style="display: inline" for="items_20025">Bottled Water</label></li>
								
													</ul>
					</li>
							
					</ul>
	</div>
	<div style="margin-left:550px" id="options">
		<p><input type="checkbox" id="hasBread" name="hasBread" value="Y" onclick="if(this.checked){ $('breadNo').show(); $('br_id').appear(); } else {$('br_id').fade();$('breadNo').hide()}"> <label for="hasBread">Has Bread</label></p>
		<p id="breadNo" style="padding-left: 20px; display: none;">
			<label for="breadHeader">Use header</label><input type="text" name="breadHeader" id="breadHeader" value=""><br>
			<label for="displayOrderBread">Display Order</label><input type="text" name="displayOrderBread" id="displayOrderBread" value="" size="3">
		</p>

		<p><input checked="" type="checkbox" id="hasCustomisation" name="hasCustomisation" value="Y" onclick="if(this.checked){ $('ci_id').appear();$('ciNo').show(); } else {$('ci_id').fade();$('ciNo').hide();}"> <label for="hasCustomisation">Has Custom Ingredients</label></p>
		<p id="ciNo" style="padding-left: 20px;">
			<label for="ciHeader">Use header</label><input type="text" name="ciHeader" id="ciHeader" value="First 3 Toppings Free"><br>
			<label for="minci" style="display: inline">Min custom items: </label><input type="text" name="minci" id="minci" size="3" value="3"><br>
			<label for="maxci" style="display: inline">Max custom items: </label><input type="text" name="maxci" id="maxci" size="3" value="0"><br>
			<label for="freeCI" style="display: inline">Free items: </label><input type="text" name="freeci" id="freeCI" size="3" value="3"><br>
			<label for="displayOrderCI">Display Order</label><input type="text" name="displayOrderCI" id="displayOrderCI" value="2" size="3">
		</p>

		<p><input type="checkbox" id="hasDressing" name="hasDressing" value="Y" onclick="if(this.checked){ $('dr_id').appear(); $('dressingNo').show(); } else { $('dr_id').fade(); $('dressingNo').hide()}"> <label for="hasDressing">Has Dressing</label></p>
		<p id="dressingNo" style="padding-left: 20px; display: none;">
			<label for="dressingHeader">Use header</label><input type="text" name="dressingHeader" id="dressingHeader" value=""><br>
			<label for="minDressing" style="display: inline">Min dressings: </label><input type="text" name="mindressing" id="minDressing" size="3" value="0"><br>
			<label for="maxDressing" style="display: inline">Max dressings: </label><input type="text" name="maxdressing" id="maxDressing" size="3" value="0"><br>
			<label for="freeDressing" style="display: inline">Free items: </label><input type="text" name="freeDressing" id="freeDressing" size="3" value="0"><br>
			<label for="displayOrderDressing">Display Order</label><input type="text" name="displayOrderDressing" id="displayOrderDressing" value="" size="3">
		</p>

		<p><input type="checkbox" id="hasSauce" name="hasSauce" value="Y" onclick="if(this.checked){ $('sa_id').appear(); $('sauceNo').show(); } else {$('sa_id').fade();$('sauceNo').hide()}"> <label for="hasSauce">Has Sauce</label></p>
		<p id="sauceNo" style="display: none;padding-left:20px">
			<label for="sauceHeader">Use header</label><input type="text" name="sauceHeader" id="sauceHeader" value=""><br>
			<label for="minSauce" style="display: inline">Min sauces: </label><input type="text" name="minsauce" id="minSauce" size="3" value="0"><br>
			<label for="maxSauce" style="display: inline">Max sauces: </label><input type="text" name="maxsauce" id="maxSauce" size="3" value="0"><br>
			<label for="freeSauce" style="display: inline">Free items: </label><input type="text" name="freeSauce" id="freeSauce" size="3" value="0"><br>
			<label for="displayOrderSauce">Display Order</label><input type="text" name="displayOrderSauce" id="displayOrderSauce" value="" size="3">
		</p>

		<p><input type="checkbox" id="hasSideDish" name="hasSideDish" onclick="if(this.checked){ $('sdNo').show(); $('sd_id').appear(); } else {$('sdNo').hide();$('sd_id').fade()}" value="Y"> <label for="hasSideDish">Has Side Dishes</label></p>
		<p id="sdNo" style="display: none;padding-left:20px">
			<label for="sdHeader">Use header</label><input type="text" name="sdHeader" id="sdHeader" value=""><br>
			<label for="minSD" style="display: inline">Min side dishes: </label><input type="text" name="minsd" id="minSD" size="3" value="0"><br>
			<label for="maxSD" style="display: inline">Max side dishes: </label><input type="text" name="maxsd" id="maxSD" size="3" value="0"><br>
			<label for="freeSD" style="display: inline">Free items: </label><input type="text" name="freeSD" id="freeSD" size="3" value="0"><br>
			<label for="displayOrderSD">Display Order</label><input type="text" name="displayOrderSD" id="displayOrderSD" value="" size="3">
		</p>

		<p><input type="checkbox" id="hasExtras" name="hasExtras" value="Y" onclick="if(this.checked){ $('extraNo').show();$('e_id').appear() } else { $('e_id').fade(); $('extraNo').hide() }"> <label for="hasExtras">Has Extras</label></p>
		<p id="extraNo" style="display: none;padding-left:20px">
			<label for="extraHeader">Use header</label><input type="text" name="extraHeader" id="extraHeader" value=""><br>
			<label for="minExtra" style="display: inline">Min extras: </label><input type="text" name="minextras" id="minExtra" size="3" value="0"><br>
			<label for="maxExtra" style="display: inline">Max extras: </label><input type="text" name="maxextras" id="maxExtra" size="3" value="0"><br>
			<label for="freeExtra" style="display: inline">Free items: </label><input type="text" name="freeExtra" id="freeExtra" size="3" value="0"><br>
			<label for="displayOrderExtras">Display Order</label><input type="text" name="displayOrderExtras" id="displayOrderExtras" value="" size="3">
		</p>
		<p><input type="checkbox" id="hasCM" name="hasCM" value="Y" onclick="if(this.checked){ $('cmNo').show();$('cm_id').appear() } else { $('cm_id').fade(); $('cmNo').hide() }"> <label for="hasCM">Has Cooking Method</label></p>
		<p id="cmNo" style="display: none;padding-left:20px">
			<label for="cmHeader">Use header</label><input type="text" name="cmHeader" id="cmHeader" value=""><br>
			<label for="minCm" style="display: inline">Min CM: </label><input type="text" name="minCm" id="minCm" size="3" value="0"><br>
			<label for="maxCm" style="display: inline">Max CM: </label><input type="text" name="maxCm" id="maxCm" size="3" value="0"><br>
			<label for="freeCm" style="display: inline">Free items: </label><input type="text" name="freeCm" id="freeCm" size="3" value="0"><br>
			<label for="displayOrderCm">Display Order</label><input type="text" name="displayOrderCm" id="displayOrderCm" value="" size="3">
		</p>
		<p>
			<label for="itemcount">Number of items:</label>
			<input id="itemcount" type="text" name="itemcount" value="1" size="3">
		</p>
		<p>
			<label for="showPizzaIcons">Show Pizza Icons</label>
			<input type="checkbox" name="showPizzaIcons" id="showPizzaIcons" value="Y" checked="">
		</p>

		<p>
			<label for="displayHeader">Display Header</label>
			<input type="text" name="displayHeader" id="displayHeader" value="">
		</p>
		<div>
			
				<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px">Custom Ingredients</p>
				<div id="ci_id" style="border-width: 0px 1px 1px; border-style: solid; border-color: rgb(170, 170, 170); margin-bottom: 2px; padding: 1px;">

					<ul id="ulci" style="list-style-type:none;overflow: hidden">
													
								
								<li>
									<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
										<input class="ci" onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()});if(this.checked){ $('list_ci_2040').show();}" type="radio" name="ci_radio" value="2040" id="radio_ci_2040">
										<label for="radio_ci_2040">Pizza Toppings</label>
									</p>
									<ul style="list-style-type: none; overflow: hidden;display:none" class="ci" id="list_ci_2040">
																																	<li style="width:30%; float: left;padding-left:2px">
													Pepperoni													<input type="text" size="5" name="ci[2040][9316]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Ham													<input type="text" size="5" name="ci[2040][9317]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Bacon													<input type="text" size="5" name="ci[2040][9318]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Italian Sausage													<input type="text" size="5" name="ci[2040][9319]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Chicken													<input type="text" size="5" name="ci[2040][9320]" value="1.50,2.75,3.75">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Ground Beef													<input type="text" size="5" name="ci[2040][9321]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Donair Meat													<input type="text" size="5" name="ci[2040][9322]" value="1.50,2.75,3.75">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Mushrooms													<input type="text" size="5" name="ci[2040][9323]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Onions													<input type="text" size="5" name="ci[2040][9324]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Tomatoes													<input type="text" size="5" name="ci[2040][9325]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Pineapple													<input type="text" size="5" name="ci[2040][9326]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Green Olives													<input type="text" size="5" name="ci[2040][9327]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Black Olives													<input type="text" size="5" name="ci[2040][9328]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Hot Banana Peppers													<input type="text" size="5" name="ci[2040][9329]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Green Peppers													<input type="text" size="5" name="ci[2040][9330]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Extra Cheese													<input type="text" size="5" name="ci[2040][9331]" value="1.50,2.75,3.75">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Feta													<input type="text" size="5" name="ci[2040][39072]" value="1.50,2.75,3.75">
												</li>
																														</ul>
								</li>
							
								
								<li>
									<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
										<input class="ci" checked="" onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()});if(this.checked){ $('list_ci_2041').show();}" type="radio" name="ci_radio" value="2041" id="radio_ci_2041">
										<label for="radio_ci_2041">Pizza Toppings without Premium</label>
									</p>
									<ul style="list-style-type: none; overflow: hidden;display:" class="ci" id="list_ci_2041">
																																														<li style="width:30%; float: left;padding-left:2px">
														Pepperoni														<input type="text" size="5" name="ci[2041][9316]" value="2.50">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Ham														<input type="text" size="5" name="ci[2041][9317]" value="2.50">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Bacon														<input type="text" size="5" name="ci[2041][9318]" value="2.50">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Italian Sausage														<input type="text" size="5" name="ci[2041][9319]" value="2.50">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Ground Beef														<input type="text" size="5" name="ci[2041][9321]" value="2.50">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Mushrooms														<input type="text" size="5" name="ci[2041][9323]" value="2.50">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Onions														<input type="text" size="5" name="ci[2041][9324]" value="2.50">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Tomatoes														<input type="text" size="5" name="ci[2041][9325]" value="2.50">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Pineapple														<input type="text" size="5" name="ci[2041][9326]" value="2.50">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Green Olives														<input type="text" size="5" name="ci[2041][9327]" value="2.50">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Black Olives														<input type="text" size="5" name="ci[2041][9328]" value="2.50">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Hot Banana Peppers														<input type="text" size="5" name="ci[2041][9329]" value="2.50">
													</li>
																																																<li style="width:30%; float: left;padding-left:2px">
														Green Peppers														<input type="text" size="5" name="ci[2041][9330]" value="2.50">
													</li>
																																										</ul>
								</li>
							
								
								<li>
									<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
										<input class="ci" onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()});if(this.checked){ $('list_ci_2042').show();}" type="radio" name="ci_radio" value="2042" id="radio_ci_2042">
										<label for="radio_ci_2042">Premium Toppings</label>
									</p>
									<ul style="list-style-type: none; overflow: hidden;display:none" class="ci" id="list_ci_2042">
																																	<li style="width:30%; float: left;padding-left:2px">
													Chicken													<input type="text" size="5" name="ci[2042][9320]" value="1.50,2.75,3.75">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Donair Meat													<input type="text" size="5" name="ci[2042][9322]" value="1.50,2.75,3.75">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Extra Cheese													<input type="text" size="5" name="ci[2042][9331]" value="1.50,2.75,3.75">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Feta													<input type="text" size="5" name="ci[2042][39072]" value="1.50,2.75,3.75">
												</li>
																														</ul>
								</li>
							
								
								<li>
									<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
										<input class="ci" onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()});if(this.checked){ $('list_ci_2046').show();}" type="radio" name="ci_radio" value="2046" id="radio_ci_2046">
										<label for="radio_ci_2046">Burgers ing</label>
									</p>
									<ul style="list-style-type: none; overflow: hidden;display:none" class="ci" id="list_ci_2046">
																																	<li style="width:30%; float: left;padding-left:2px">
													Mustard													<input type="text" size="5" name="ci[2046][9342]" value="0.00">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Hot Peppers													<input type="text" size="5" name="ci[2046][9346]" value="0.00">
												</li>
																														</ul>
								</li>
							
								
								<li>
									<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
										<input class="ci" onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()});if(this.checked){ $('list_ci_2074').show();}" type="radio" name="ci_radio" value="2074" id="radio_ci_2074">
										<label for="radio_ci_2074">Pizza Toppings for Single Pizza</label>
									</p>
									<ul style="list-style-type: none; overflow: hidden;display:none" class="ci" id="list_ci_2074">
																																	<li style="width:30%; float: left;padding-left:2px">
													Pepperoni													<input type="text" size="5" name="ci[2074][9316]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Ham													<input type="text" size="5" name="ci[2074][9317]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Bacon													<input type="text" size="5" name="ci[2074][9318]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Italian Sausage													<input type="text" size="5" name="ci[2074][9319]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Chicken													<input type="text" size="5" name="ci[2074][9320]" value="1.50,2.75,3.75">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Ground Beef													<input type="text" size="5" name="ci[2074][9321]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Donair Meat													<input type="text" size="5" name="ci[2074][9322]" value="1.50,2.75,3.75">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Mushrooms													<input type="text" size="5" name="ci[2074][9323]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Onions													<input type="text" size="5" name="ci[2074][9324]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Tomatoes													<input type="text" size="5" name="ci[2074][9325]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Pineapple													<input type="text" size="5" name="ci[2074][9326]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Green Olives													<input type="text" size="5" name="ci[2074][9327]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Black Olives													<input type="text" size="5" name="ci[2074][9328]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Hot Banana Peppers													<input type="text" size="5" name="ci[2074][9329]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Green Peppers													<input type="text" size="5" name="ci[2074][9330]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Extra Cheese													<input type="text" size="5" name="ci[2074][9331]" value="1.50,2.75,3.75">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Feta													<input type="text" size="5" name="ci[2074][39072]" value="1.50,2.75,3.75">
												</li>
																														</ul>
								</li>
							
								
								<li>
									<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
										<input class="ci" onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()});if(this.checked){ $('list_ci_2075').show();}" type="radio" name="ci_radio" value="2075" id="radio_ci_2075">
										<label for="radio_ci_2075">Pizza Toppings without Premium for Single Pizza</label>
									</p>
									<ul style="list-style-type: none; overflow: hidden;display:none" class="ci" id="list_ci_2075">
																																	<li style="width:30%; float: left;padding-left:2px">
													Pepperoni													<input type="text" size="5" name="ci[2075][9316]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Ham													<input type="text" size="5" name="ci[2075][9317]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Bacon													<input type="text" size="5" name="ci[2075][9318]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Italian Sausage													<input type="text" size="5" name="ci[2075][9319]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Ground Beef													<input type="text" size="5" name="ci[2075][9321]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Mushrooms													<input type="text" size="5" name="ci[2075][9323]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Onions													<input type="text" size="5" name="ci[2075][9324]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Tomatoes													<input type="text" size="5" name="ci[2075][9325]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Pineapple													<input type="text" size="5" name="ci[2075][9326]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Green Olives													<input type="text" size="5" name="ci[2075][9327]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Black Olives													<input type="text" size="5" name="ci[2075][9328]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Hot Banana Peppers													<input type="text" size="5" name="ci[2075][9329]" value="1.25,2.50,2.95">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Green Peppers													<input type="text" size="5" name="ci[2075][9330]" value="1.25,2.50,2.95">
												</li>
																														</ul>
								</li>
							
								
								<li>
									<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
										<input class="ci" onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()});if(this.checked){ $('list_ci_2076').show();}" type="radio" name="ci_radio" value="2076" id="radio_ci_2076">
										<label for="radio_ci_2076">Premium Toppings for Single Pizza</label>
									</p>
									<ul style="list-style-type: none; overflow: hidden;display:none" class="ci" id="list_ci_2076">
																																	<li style="width:30%; float: left;padding-left:2px">
													Chicken													<input type="text" size="5" name="ci[2076][9320]" value="1.50,2.75,3.75">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Donair Meat													<input type="text" size="5" name="ci[2076][9322]" value="1.50,2.75,3.75">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Extra Cheese													<input type="text" size="5" name="ci[2076][9331]" value="1.50,2.75,3.75">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Feta													<input type="text" size="5" name="ci[2076][39072]" value="1.50,2.75,3.75">
												</li>
																														</ul>
								</li>
																		</ul>

				</div>

			
				<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px">Side Dish</p>
				<div id="sd_id" style="border-width:0 1px 1px 1px; border-style: solid;border-color: #aaa;margin-bottom:2px;padding:1px;display: none">

					<ul id="ulsd" style="list-style-type:none;overflow: hidden">
													
								
								<li>
									<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
										<input class="sd" onclick="$$('#ulsd ul[class=\'sd\']').each(function(u){$(u.id).hide()});if(this.checked){ $('list_sd_11191').show();}" type="radio" name="sd_radio" value="11191" id="radio_sd_11191">
										<label for="radio_sd_11191">Donair Platter Upgrade</label>
									</p>
									<ul style="list-style-type: none; overflow: hidden;display:none" class="sd" id="list_sd_11191">
																																	<li style="width:30%; float: left;padding-left:2px">
													Onion Rings													<input type="text" size="5" name="sd[11191][51886]" value="1.00">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Poutine													<input type="text" size="5" name="sd[11191][51887]" value="2.50">
												</li>
																														</ul>
								</li>
																		</ul>

				</div>

			
				<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px">Extras</p>
				<div id="e_id" style="border-width:0 1px 1px 1px; border-style: solid;border-color: #aaa;margin-bottom:2px;padding:1px;display: none">

					<ul id="ule" style="list-style-type:none;overflow: hidden">
													
								
								<li>
									<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
										<input class="e" onclick="$$('#ule ul[class=\'e\']').each(function(u){$(u.id).hide()});if(this.checked){ $('list_e_2047').show();}" type="radio" name="e_radio" value="2047" id="radio_e_2047">
										<label for="radio_e_2047">Burgers Platters extra</label>
									</p>
									<ul style="list-style-type: none; overflow: hidden;display:none" class="e" id="list_e_2047">
																																	<li style="width:30%; float: left;padding-left:2px">
													Cheese													<input type="text" size="5" name="e[2047][9343]" value="0.75">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Bacon													<input type="text" size="5" name="e[2047][9344]" value="0.75">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Poutine													<input type="text" size="5" name="e[2047][9345]" value="2.50">
												</li>
																														</ul>
								</li>
							
								
								<li>
									<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
										<input class="e" onclick="$$('#ule ul[class=\'e\']').each(function(u){$(u.id).hide()});if(this.checked){ $('list_e_2048').show();}" type="radio" name="e_radio" value="2048" id="radio_e_2048">
										<label for="radio_e_2048">Platters upgrade</label>
									</p>
									<ul style="list-style-type: none; overflow: hidden;display:none" class="e" id="list_e_2048">
																																	<li style="width:30%; float: left;padding-left:2px">
													Poutine													<input type="text" size="5" name="e[2048][9345]" value="2.50">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Onion Rings													<input type="text" size="5" name="e[2048][39071]" value="1.00">
												</li>
																														</ul>
								</li>
							
								
								<li>
									<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
										<input class="e" onclick="$$('#ule ul[class=\'e\']').each(function(u){$(u.id).hide()});if(this.checked){ $('list_e_2049').show();}" type="radio" name="e_radio" value="2049" id="radio_e_2049">
										<label for="radio_e_2049">Burgers extra</label>
									</p>
									<ul style="list-style-type: none; overflow: hidden;display:none" class="e" id="list_e_2049">
																																	<li style="width:30%; float: left;padding-left:2px">
													Cheese													<input type="text" size="5" name="e[2049][9343]" value="0.75">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Bacon													<input type="text" size="5" name="e[2049][9344]" value="0.75">
												</li>
																														</ul>
								</li>
							
								
								<li>
									<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
										<input class="e" onclick="$$('#ule ul[class=\'e\']').each(function(u){$(u.id).hide()});if(this.checked){ $('list_e_2050').show();}" type="radio" name="e_radio" value="2050" id="radio_e_2050">
										<label for="radio_e_2050">Donair extra</label>
									</p>
									<ul style="list-style-type: none; overflow: hidden;display:none" class="e" id="list_e_2050">
																																	<li style="width:30%; float: left;padding-left:2px">
													Cheese													<input type="text" size="5" name="e[2050][9343]" value="0.75">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Meat													<input type="text" size="5" name="e[2050][9347]" value="1.25,2.50">
												</li>
																														</ul>
								</li>
							
								
								<li>
									<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
										<input class="e" onclick="$$('#ule ul[class=\'e\']').each(function(u){$(u.id).hide()});if(this.checked){ $('list_e_2054').show();}" type="radio" name="e_radio" value="2054" id="radio_e_2054">
										<label for="radio_e_2054">Make it large</label>
									</p>
									<ul style="list-style-type: none; overflow: hidden;display:none" class="e" id="list_e_2054">
																																	<li style="width:30%; float: left;padding-left:2px">
													Make it large													<input type="text" size="5" name="e[2054][9366]" value="3.00">
												</li>
																														</ul>
								</li>
							
								
								<li>
									<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
										<input class="e" onclick="$$('#ule ul[class=\'e\']').each(function(u){$(u.id).hide()});if(this.checked){ $('list_e_8630').show();}" type="radio" name="e_radio" value="8630" id="radio_e_8630">
										<label for="radio_e_8630">Meat for Salads</label>
									</p>
									<ul style="list-style-type: none; overflow: hidden;display:none" class="e" id="list_e_8630">
																																	<li style="width:30%; float: left;padding-left:2px">
													Donair Meat													<input type="text" size="5" name="e[8630][39069]" value="2.50">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Chicken													<input type="text" size="5" name="e[8630][39070]" value="2.50">
												</li>
																														</ul>
								</li>
																		</ul>

				</div>

			
				<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px">Bread</p>
				<div id="br_id" style="border-width: 0px 1px 1px; border-style: solid; border-color: rgb(170, 170, 170); margin-bottom: 2px; padding: 1px; display: none;">

					<ul id="ulbr" style="list-style-type:none;overflow: hidden">
											</ul>

				</div>

			
				<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px">Dressing</p>
				<div id="dr_id" style="border-width: 0px 1px 1px; border-style: solid; border-color: rgb(170, 170, 170); margin-bottom: 2px; padding: 1px; display: none;">

					<ul id="uldr" style="list-style-type:none;overflow: hidden">
													
								
								<li>
									<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
										<input class="dr" onclick="$$('#uldr ul[class=\'dr\']').each(function(u){$(u.id).hide()});if(this.checked){ $('list_dr_2045').show();}" type="radio" name="dr_radio" value="2045" id="radio_dr_2045">
										<label for="radio_dr_2045">Salads Dressings</label>
									</p>
									<ul style="list-style-type: none; overflow: hidden;display:none" class="dr" id="list_dr_2045">
																																	<li style="width:30%; float: left;padding-left:2px">
													Greek													<input type="text" size="5" name="dr[2045][9339]" value="0.00">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Italian													<input type="text" size="5" name="dr[2045][9340]" value="0.00">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Caesar													<input type="text" size="5" name="dr[2045][9341]" value="0.00">
												</li>
																														</ul>
								</li>
																		</ul>

				</div>

			
				<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px">Sauce</p>
				<div id="sa_id" style="border-width:0 1px 1px 1px; border-style: solid;border-color: #aaa;margin-bottom:2px;padding:1px;display: none">

					<ul id="ulsa" style="list-style-type:none;overflow: hidden">
													
								
								<li>
									<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
										<input class="sa" onclick="$$('#ulsa ul[class=\'sa\']').each(function(u){$(u.id).hide()});if(this.checked){ $('list_sa_2043').show();}" type="radio" name="sa_radio" value="2043" id="radio_sa_2043">
										<label for="radio_sa_2043">Dips</label>
									</p>
									<ul style="list-style-type: none; overflow: hidden;display:none" class="sa" id="list_sa_2043">
																																	<li style="width:30%; float: left;padding-left:2px">
													Creamy Garlic													<input type="text" size="5" name="sa[2043][9332]" value="1.00">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Honey Garlic													<input type="text" size="5" name="sa[2043][9333]" value="1.00">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Hot													<input type="text" size="5" name="sa[2043][9334]" value="1.00">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													B.B.Q													<input type="text" size="5" name="sa[2043][9335]" value="1.00">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Marinara													<input type="text" size="5" name="sa[2043][9336]" value="1.00">
												</li>
																														</ul>
								</li>
							
								
								<li>
									<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
										<input class="sa" onclick="$$('#ulsa ul[class=\'sa\']').each(function(u){$(u.id).hide()});if(this.checked){ $('list_sa_2051').show();}" type="radio" name="sa_radio" value="2051" id="radio_sa_2051">
										<label for="radio_sa_2051">Wings Sauces</label>
									</p>
									<ul style="list-style-type: none; overflow: hidden;display:none" class="sa" id="list_sa_2051">
																																	<li style="width:30%; float: left;padding-left:2px">
													Honey Garlic													<input type="text" size="5" name="sa[2051][9333]" value="1.00">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Hot													<input type="text" size="5" name="sa[2051][9334]" value="1.00">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													B.B.Q													<input type="text" size="5" name="sa[2051][9335]" value="1.00">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Medium													<input type="text" size="5" name="sa[2051][9348]" value="0.00">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Mild													<input type="text" size="5" name="sa[2051][51885]" value="0.00">
												</li>
																														</ul>
								</li>
							
								
								<li>
									<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
										<input class="sa" onclick="$$('#ulsa ul[class=\'sa\']').each(function(u){$(u.id).hide()});if(this.checked){ $('list_sa_4840').show();}" type="radio" name="sa_radio" value="4840" id="radio_sa_4840">
										<label for="radio_sa_4840">Sauces For Jesica Donair Poutine</label>
									</p>
									<ul style="list-style-type: none; overflow: hidden;display:none" class="sa" id="list_sa_4840">
																																	<li style="width:30%; float: left;padding-left:2px">
													Gravy													<input type="text" size="5" name="sa[4840][22694]" value="0.00">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Donair Sauce													<input type="text" size="5" name="sa[4840][22695]" value="0.00">
												</li>
																														</ul>
								</li>
																		</ul>

				</div>

			
				<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px">Cooking Method</p>
				<div id="cm_id" style="border-width:0 1px 1px 1px; border-style: solid;border-color: #aaa;margin-bottom:2px;padding:1px;display: none">

					<ul id="ulcm" style="list-style-type:none;overflow: hidden">
													
								
								<li>
									<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
										<input class="cm" onclick="$$('#ulcm ul[class=\'cm\']').each(function(u){$(u.id).hide()});if(this.checked){ $('list_cm_2044').show();}" type="radio" name="cm_radio" value="2044" id="radio_cm_2044">
										<label for="radio_cm_2044">Punjabi Pizza cooking method</label>
									</p>
									<ul style="list-style-type: none; overflow: hidden;display:none" class="cm" id="list_cm_2044">
																																	<li style="width:30%; float: left;padding-left:2px">
													Veggie													<input type="text" size="5" name="cm[2044][9337]" value="0.00">
												</li>
																							<li style="width:30%; float: left;padding-left:2px">
													Non-Veggie													<input type="text" size="5" name="cm[2044][9338]" value="0.00">
												</li>
																														</ul>
								</li>
																		</ul>

				</div>

					</div>

	</div>

</form>

## Phase 2:
Once you all the combo modifier Groups have been scrapped you should:

1. Go back to the landing page: https://menuadmin.menu.ca/?p=restaurants


2. In the landing page you will find the v1 restaurants under an <ul id="active"> element. Each V1 restaurant is stored in an <li> element:

Each <li> element has an <a> element containing a link to the details page of each restaurant. This <a> element also contians the unique v1 id that identifies each restaurant. For instance the restaurant Centertown Donair & Pizza the a element contains its v1 id (383) in the href parameter <a href="/?p=restaurants&amp;display=editRestaurant&amp;restaurant=255">Edit</a>. You should use this element to both identify the v1 restaurants that must be scraped and access its details page where the data that needs to be scrapped is located.

3. Once you get to the details page of each restaurant you need to click this <a> element to navigate to the menu details:
<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=255&amp;load=menu&amp;showLang=en">Menu</a> this will take you tohttps://menuadmin.menu.ca/?p=restaurants&display=editRestaurant&restaurant=255&load=menu&showLang=en

4. In the Menu details page you will find different courses, each with its own dishes. Now, we are only looking to scrape the combo dishes. So only extract courses that have dishes with this attribute in their href element: combo=

For example, the Centertown Donair & Pizza has a course called Specials with multiple combos. All of them containing an <a> element with an href attribute ending with combo=. This means that this particular couse should be scrapped allong with all the dishes that end with combo= in the href attribute of their respective <a> element

<ul style="list-style-type: none" id="course_0"><li style="position: relative;"><h3>Specials</h3></li><li style="margin-left: 10px; position: relative; z-index: 0; top: 0px; left: 0px;" id="li_20051">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=255&amp;load=editCombo&amp;showLang=en&amp;combo=20051">Medium Pizza and Donairs</a> - 1 medium pizza with 3 toppings, 2 small donairs, 2 pops.											</li><li style="margin-left: 10px; position: relative;" id="li_20040">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=255&amp;load=editCombo&amp;showLang=en&amp;combo=20040">Small Pizza and One Garlic Fingers</a> - 1 small pizza with 3 toppings and 1 garlic fingers.											</li><li style="margin-left: 10px; position: relative;" id="li_20041">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=255&amp;load=editCombo&amp;showLang=en&amp;combo=20041">Medium Pizza and One Garlic Fingers</a> - 1 medium pizza with 3 toppings and 1 garlic fingers.											</li><li style="margin-left: 10px; position: relative;" id="li_20042">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=255&amp;load=editCombo&amp;showLang=en&amp;combo=20042">Large Pizza and One Garlic Fingers</a> - 1 large pizza with 3 toppings and 1 garlic fingers.											</li><li style="margin-left: 10px; position: relative;" id="li_57648">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=255&amp;load=editCombo&amp;showLang=en&amp;combo=57648">2 Small Donairs and Garlic Fingers</a> - 2 small donairs, medium garlic fingers and 2 cans of pop.											</li><li style="margin-left: 10px; position: relative;" id="li_57645">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=255&amp;load=editCombo&amp;showLang=en&amp;combo=57645">2 Small Halifax Donairs</a> - 2 small donairs and 2 cans of pop.											</li><li style="margin-left: 10px; position: relative;" id="li_57643">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=255&amp;load=editCombo&amp;showLang=en&amp;combo=57643">2 Small Donairs and Wings HIDE</a> - 2 small donairs, 10 wings and 2 cans of pop.											</li><li style="margin-left: 10px; position: relative;" id="li_20043">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=255&amp;load=editCombo&amp;showLang=en&amp;combo=20043">Large Pizza and Donair Special HIDE</a> - 1 large pizza with 3 toppings, 1 small donair and 2 cans of pop.											</li></ul>

Click in the <a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=255&amp;load=editCombo&amp;showLang=en&amp;combo=20051">Medium Pizza and Donairs</a> to enter the dish details:

5. In the dish details (https://menuadmin.menu.ca/?p=restaurants&display=editRestaurant&restaurant=255&load=editCombo&showLang=en&combo=20051)
Name: 
<li>
	<label style="display: block" for="name">Name</label>
	<input type="text" class="long" name="name" id="name" value="Medium Pizza and Donairs">
</li>

Description: 
<li>
	<label style="display: block" for="ingredients">Description</label>
	<textarea rows="3" cols="35" name="ingredients" id="ingredients">1 medium pizza with 3 toppings, 2 small donairs, 2 pops.</textarea>
</li>

Price: 
<li>
	<label style="display:block" for="price">Price - <sub>separate multiple prices by comma</sub></label>
	<input type="text" name="price" id="price" class="long" value="38.50">
</li>


DISH_COMBO_GROUPS:
All the Combo Groups are stored under the <ul style="list-style-type: none" id="sortMeCombo"> element:

<ul style="list-style-type: none" id="sortMeCombo"><li id="li_1493" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="1493" id="radio_1493">
                        <label for="radio_1493">Pizza Toppings</label>
                    </p></li><li id="li_1495" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="1495" id="radio_1495">
                        <label for="radio_1495">Double Pizza 1 Topping</label>
                    </p></li><li id="li_1496" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="1496" id="radio_1496">
                        <label for="radio_1496">Premium Toppings ---1st Pizza</label>
                    </p></li><li id="li_1497" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="1497" id="radio_1497">
                        <label for="radio_1497">Premium Toppings---2nd pizza</label>
                    </p></li><li id="li_1498" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="1498" id="radio_1498">
                        <label for="radio_1498">Double Pizza 2 Toppings</label>
                    </p></li><li id="li_1499" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="1499" id="radio_1499">
                        <label for="radio_1499">Punjabi Pizza</label>
                    </p></li><li id="li_1500" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="1500" id="radio_1500">
                        <label for="radio_1500">1 Small 3 toppings</label>
                    </p></li><li id="li_1501" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="1501" id="radio_1501">
                        <label for="radio_1501">Premium Toppings Small</label>
                    </p></li><li id="li_1504" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="1504" id="radio_1504">
                        <label for="radio_1504">1 Large 3 toppings</label>
                    </p></li><li id="li_1505" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="1505" id="radio_1505">
                        <label for="radio_1505">Premium Toppings Large</label>
                    </p></li><li id="li_1506" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="1506" id="radio_1506">
                        <label for="radio_1506">Make it large</label>
                    </p></li><li id="li_1508" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="1508" id="radio_1508">
                        <label for="radio_1508">Premium Toppings Medium-----1st Pizza</label>
                    </p></li><li id="li_1509" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="1509" id="radio_1509">
                        <label for="radio_1509">Premium Toppings Medium-----2nd Pizza</label>
                    </p></li><li id="li_1510" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="1510" id="radio_1510">
                        <label for="radio_1510">Wings Sauces</label>
                    </p></li><li id="li_1526" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="1526" id="radio_1526">
                        <label for="radio_1526">1 Topping for Single Pizza</label>
                    </p></li><li id="li_1527" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="1527" id="radio_1527">
                        <label for="radio_1527">2 Toppings for Single Pizza</label>
                    </p></li><li id="li_1528" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="1528" id="radio_1528">
                        <label for="radio_1528">Premium Toppings for Single Pizza</label>
                    </p></li><li id="li_1507" style="position: relative; z-index: 0; top: 0px; left: 0px;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="1507" id="radio_1507">
                        <label for="radio_1507">2 medium pizzas 3 toppings special</label>
                    </p></li><li id="li_3562" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="3562" id="radio_3562">
                        <label for="radio_3562">Extras Small Donair</label>
                    </p></li><li id="li_3564" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="3564" id="radio_3564">
                        <label for="radio_3564">Twin Pizzas and garlic fingers</label>
                    </p></li><li id="li_5071" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="5071" id="radio_5071">
                        <label for="radio_5071">NEW 2 Small Pizza 3 Toppings</label>
                    </p></li><li id="li_5072" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="5072" id="radio_5072">
                        <label for="radio_5072">NEW 2 Medium 3 Toppings Pizza</label>
                    </p></li><li id="li_5073" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="5073" id="radio_5073">
                        <label for="radio_5073">NEW 2 Large 3 Toppings Pizza</label>
                    </p></li><li id="li_5074" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="5074" id="radio_5074">
                        <label for="radio_5074">Premium Toppings Small --1st Pizza</label>
                    </p></li><li id="li_5075" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="5075" id="radio_5075">
                        <label for="radio_5075">Premium Toppings Small ---2nd Pizza</label>
                    </p></li><li id="li_5076" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="5076" id="radio_5076">
                        <label for="radio_5076">Premium Toppings Medium---1st Pizza</label>
                    </p></li><li id="li_5077" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="5077" id="radio_5077">
                        <label for="radio_5077">Premium Toppings Medium ---2nd Pizza</label>
                    </p></li><li id="li_5078" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="5078" id="radio_5078">
                        <label for="radio_5078">Premium Toppings Large ---1st Pizza</label>
                    </p></li><li id="li_5079" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="5079" id="radio_5079">
                        <label for="radio_5079">Premium Toppings Large ---2nd Pizza</label>
                    </p></li><li id="li_1502" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="1502" id="radio_1502" checked="">
                        <label for="radio_1502">1 Medium 3 toppings</label>
                    </p></li><li id="li_1503" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="1503" id="radio_1503" checked="">
                        <label for="radio_1503">Premium Toppings Medium</label>
                    </p></li><li id="li_3563" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="3563" id="radio_3563" checked="">
                        <label for="radio_3563">2 Small Donairs</label>
                    </p></li><li id="li_1494" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
                        <input type="checkbox" name="group[]" value="1494" id="radio_1494" checked="">
                        <label for="radio_1494">Dips</label>
                    </p></li></ul>

Notice that only 4 combo groups were assigned to this dish:
- 1 Medium 3 Toppings: <li id="li_1502" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
	<input type="checkbox" name="group[]" value="1502" id="radio_1502" checked="">
	<label for="radio_1502">1 Medium 3 toppings</label>
</p></li>
- Premium Toppings Medium:
<li id="li_1503" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
	<input type="checkbox" name="group[]" value="1503" id="radio_1503" checked="">
	<label for="radio_1503">Premium Toppings Medium</label>
</p></li>
- Small Donairs: 
<li id="li_3563" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
	<input type="checkbox" name="group[]" value="3563" id="radio_3563" checked="">
	<label for="radio_3563">2 Small Donairs</label>
</p></li>
- Dips: 
<li id="li_1494" style="position: relative;"><p style="height:20px;line-height:20px;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
	<input type="checkbox" name="group[]" value="1494" id="radio_1494" checked="">
	<label for="radio_1494">Dips</label>
</p></li>

I want you to only use the combo groups of that were checked (<input checked="">) to assign each combo group to each dish.

6. Some combos a drink modifier:

 <p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px">Drinks</p> if you see this element you need to:
a. Scrape the modifier group: <p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
	<input checked="" onclick="$$('#uld ul[class=\'d\']').each(function(u){$(u.id).hide()}); if(this.checked){ $('list_d_2052').show();}" type="radio" name="d_radio" value="2052" id="radio_d_2052">
	<label for="radio_d_2052">Drinks can</label>
</p>
and store it in the menuca_v3.modifier_groups and assign it to this dish_id

b. Scrape the modifiers and their prices and assign it to this dish:
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