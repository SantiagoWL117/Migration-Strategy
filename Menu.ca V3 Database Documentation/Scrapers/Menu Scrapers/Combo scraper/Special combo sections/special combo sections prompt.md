
# Menuca_V3 Schema for Special Combo Sections

## Overview

Special combo sections are combo groups that reference **actual dishes** from the restaurant menu (not just modifier groups). These allow customers to select dishes like "2 Large Pizzas from Menu" where they pick from a pre-defined list of pizzas.

## Schema Changes Applied

### 1. `combo_groups` Table - Renamed Columns + New Flag

```sql
-- Renamed columns (to clarify their purpose for special sections)
special_number_of_items   INTEGER     -- How many items the user can select (e.g., 2 pizzas)
special_display_header    VARCHAR     -- Header text like "First Pizza;Second Pizza"

-- New column
has_special_section       BOOLEAN     -- TRUE if this combo has dish selections (DEFAULT FALSE)
```

### 2. `combo_group_dish_selections` Table - NEW

Stores the checked dishes that are selectable within a special combo group.

```sql
CREATE TABLE menuca_v3.combo_group_dish_selections (
    id                SERIAL PRIMARY KEY,
    combo_group_id    INTEGER NOT NULL REFERENCES menuca_v3.combo_groups(id),
    dish_id           INTEGER NOT NULL REFERENCES menuca_v3.dishes(id),  -- V3 dish ID
    size              SMALLINT,       -- 0=Small, 1=Medium, 2=Large, 3=X-Large, NULL=no size
    course_id         INTEGER REFERENCES menuca_v3.courses(id),  -- FK to courses table
    dish_display_name TEXT,           -- Optional: Only if different from dish.name
    created_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at        TIMESTAMP       -- Soft delete
);

-- Indexes
CREATE INDEX idx_combo_dish_selections_combo_group ON menuca_v3.combo_group_dish_selections(combo_group_id);
CREATE INDEX idx_combo_dish_selections_dish ON menuca_v3.combo_group_dish_selections(dish_id);
CREATE INDEX idx_combo_dish_selections_course ON menuca_v3.combo_group_dish_selections(course_id);
```

## Data Mapping from V1 HTML

### Size Mapping
The V1 `value` attribute encodes dish + size as `source_id.size_index`:

| Value Format | Meaning |
|--------------|---------|
| `105965` | Dish without size variants |
| `105965.0` | Small |
| `105965.1` | Medium |
| `105965.2` | Large |
| `105965.3` | Extra Large |

### Parsing Example

```html
<input checked="" type="checkbox" name="items[]" value="105965.2" id="items_105965.2">
<label for="items_105965.2">Combination Pizza Large</label>
```

Maps to:
- `dish_id` → V3 dish ID (lookup by source_id=105965 + restaurant_id)
- `size` → 2 (Large)
- `course_id` → FK to courses table (lookup by course name from parent `<h4>` + restaurant_id)
- `dish_display_name` → "Combination Pizza Large" (only if different from dish.name)

## Restaurants with Special Combo Sections

12 restaurants identified with 48 special combo groups:

| Restaurant | V3 ID | V1 ID | Special Combos | Total Items |
|------------|-------|-------|----------------|-------------|
| Mano City Pizza | 118 | 238 | 3 | 19 |
| Milano | 123 | 245 | 2 | 4 |
| Orchid Sushi | 245 | 387 | 1 | 8 |
| Milano | 350 | 513 | 2 | 7 |
| Aroy Thai | 607 | 830 | 4 | 116 |
| Milano | 680 | 913 | 21 | 349 |
| Amicci Pizza | 735 | 973 | 5 | 60 |
| Little Gyros Greek Grill | 756 | 998 | 2 | 10 |
| Nachos Loco Hull | 790 | 1033 | 3 | 36 |
| Dumpling Bowl | 792 | 1035 | 1 | 22 |
| Nachos Loco Gatineau | 801 | 1045 | 3 | 36 |
| All Out Burger | 833 | 1080 | 1 | 12 |

---

# Scraping Instructions



Instructions with v3 id 735	v1 id 973 Amicci Pizza

1. In the landing page you will find the v1 restaurants under an <ul id="active"> element. Each V1 restaurant is stored in an <li> element:

Each <li> element has an <a> element containing a link to the details page of each restaurant. This <a> element also contians the unique v1 id that identifies each restaurant. For instance the restaurant Amicci pizza the a element contains its v1 id (973) in the href parameter <a href="/?p=restaurants&amp;display=editRestaurant&amp;restaurant=973">Edit</a>. You should use this element to both identify the v1 restaurants that must be scraped and access its details page where the data that needs to be scrapped is located.

2. Once you get to the details page of each restaurant you need to click this <a> element to navigate to the menu details:
   <a class="active" href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=menu&amp;showLang=en">Menu</a> this will take you to https://menuadmin.menu.ca/?p=restaurants&display=editRestaurant&restaurant=863&load=menu&showLang=en

3. In the menu details page search for the Combo Groups <a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=comboGroups&amp;showLang=en">Combo Groups</a>. It is located inside a <div> with a style margin-left:501px;

4. Once you get to the combo groups you must check if the HTML contains any <p> element with a style of margin-top:1px;height:20px;line-height:1.5;background-color: #ccc;padding-left:20px;border:1px solid #aaa. If it doesn't continue with the next restaurant

5. If the page does contain a <p> element with a style of "margin-top:1px;height:20px;line-height:1.5;background-color: #ccc;padding-left:20px;border:1px solid #aaa" that means the current restaurant has Combos with modifiers that need to be reviewd. I want you to click on the details of each combo group:

<p style="margin-top:1px;height:20px;line-height:1.5;background-color: #ccc;padding-left:20px;border:1px solid #aaa">
        <a href="#" onclick="editGroupJS('8164');return false;">1 Large Pizza from Menu</a>
    </p>

6. Once you are on the details of each modifier group (https://menuadmin.menu.ca/?p=restaurants&display=editRestaurant&restaurant=973&load=comboGroups&showLang=en) you must search for this html markup:
<div style="width:550px; float: left">
		<ul style="list-style-type:none;" id="dishes">
												<li>
						<h4>Super Special</h4>
						<ul style="list-style-type: none; margin-left: 10px;overflow: hidden">		
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="106129" id="items_106129"> <label style="display: inline" for="items_106129">Large Pizza &amp; Wings</label></li>			
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="106130" id="items_106130"> <label style="display: inline" for="items_106130">Medium Pizza &amp; Wings</label></li>
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="106131" id="items_106131"> <label style="display: inline" for="items_106131">Small Pizza &amp; Wings</label></li>
													</ul>
					</li>
									<li>
						<h4>Pizzas</h4>
						<ul style="list-style-type: none; margin-left: 10px;overflow: hidden">
											<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105963.0" id="items_105963.0"> <label style="display: inline" for="items_105963.0">Cheese Pizza Small</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105963.1" id="items_105963.1"> <label style="display: inline" for="items_105963.1">Cheese Pizza Medium</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input checked="" type="checkbox" name="items[]" value="105963.2" id="items_105963.2"> <label style="display: inline" for="items_105963.2">Cheese Pizza Large</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105963.3" id="items_105963.3"> <label style="display: inline" for="items_105963.3">Cheese Pizza X-Large</label></li>
															<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105965.0" id="items_105965.0"> <label style="display: inline" for="items_105965.0">Combination Pizza Small</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105965.1" id="items_105965.1"> <label style="display: inline" for="items_105965.1">Combination Pizza Medium</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input checked="" type="checkbox" name="items[]" value="105965.2" id="items_105965.2"> <label style="display: inline" for="items_105965.2">Combination Pizza Large</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105965.3" id="items_105965.3"> <label style="display: inline" for="items_105965.3">Combination Pizza X-Large</label></li>
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105966.0" id="items_105966.0"> <label style="display: inline" for="items_105966.0">Vegetarian Pizza Small</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105966.1" id="items_105966.1"> <label style="display: inline" for="items_105966.1">Vegetarian Pizza Medium</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input checked="" type="checkbox" name="items[]" value="105966.2" id="items_105966.2"> <label style="display: inline" for="items_105966.2">Vegetarian Pizza Large</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105966.3" id="items_105966.3"> <label style="display: inline" for="items_105966.3">Vegetarian Pizza X-Large</label></li>
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105967.0" id="items_105967.0"> <label style="display: inline" for="items_105967.0">Hawaiian Pizza Small</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105967.1" id="items_105967.1"> <label style="display: inline" for="items_105967.1">Hawaiian Pizza Medium</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input checked="" type="checkbox" name="items[]" value="105967.2" id="items_105967.2"> <label style="display: inline" for="items_105967.2">Hawaiian Pizza Large</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105967.3" id="items_105967.3"> <label style="display: inline" for="items_105967.3">Hawaiian Pizza X-Large</label></li>
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105974.0" id="items_105974.0"> <label style="display: inline" for="items_105974.0">Taco Pizza Small</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105974.1" id="items_105974.1"> <label style="display: inline" for="items_105974.1">Taco Pizza Medium</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input checked="" type="checkbox" name="items[]" value="105974.2" id="items_105974.2"> <label style="display: inline" for="items_105974.2">Taco Pizza Large</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105974.3" id="items_105974.3"> <label style="display: inline" for="items_105974.3">Taco Pizza X-Large</label></li>
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="122858.0" id="items_122858.0"> <label style="display: inline" for="items_122858.0">Shawarma Pizza Small</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="122858.1" id="items_122858.1"> <label style="display: inline" for="items_122858.1">Shawarma Pizza Medium</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="122858.2" id="items_122858.2"> <label style="display: inline" for="items_122858.2">Shawarma Pizza Large</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="122858.3" id="items_122858.3"> <label style="display: inline" for="items_122858.3">Shawarma Pizza X-Large</label></li>
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105972.0" id="items_105972.0"> <label style="display: inline" for="items_105972.0">House Special Pizza Small</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105972.1" id="items_105972.1"> <label style="display: inline" for="items_105972.1">House Special Pizza Medium</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input checked="" type="checkbox" name="items[]" value="105972.2" id="items_105972.2"> <label style="display: inline" for="items_105972.2">House Special Pizza Large</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105972.3" id="items_105972.3"> <label style="display: inline" for="items_105972.3">House Special Pizza X-Large</label></li>
																<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105973.0" id="items_105973.0"> <label style="display: inline" for="items_105973.0">Meat Lovers Pizza Small</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105973.1" id="items_105973.1"> <label style="display: inline" for="items_105973.1">Meat Lovers Pizza Medium</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input checked="" type="checkbox" name="items[]" value="105973.2" id="items_105973.2"> <label style="display: inline" for="items_105973.2">Meat Lovers Pizza Large</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105973.3" id="items_105973.3"> <label style="display: inline" for="items_105973.3">Meat Lovers Pizza X-Large</label></li>
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105969.0" id="items_105969.0"> <label style="display: inline" for="items_105969.0">The Senators Pizza Small</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105969.1" id="items_105969.1"> <label style="display: inline" for="items_105969.1">The Senators Pizza Medium</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input checked="" type="checkbox" name="items[]" value="105969.2" id="items_105969.2"> <label style="display: inline" for="items_105969.2">The Senators Pizza Large</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105969.3" id="items_105969.3"> <label style="display: inline" for="items_105969.3">The Senators Pizza X-Large</label></li>
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105968.0" id="items_105968.0"> <label style="display: inline" for="items_105968.0">Canadian Pizza Small</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105968.1" id="items_105968.1"> <label style="display: inline" for="items_105968.1">Canadian Pizza Medium</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input checked="" type="checkbox" name="items[]" value="105968.2" id="items_105968.2"> <label style="display: inline" for="items_105968.2">Canadian Pizza Large</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105968.3" id="items_105968.3"> <label style="display: inline" for="items_105968.3">Canadian Pizza X-Large</label></li>
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105975.0" id="items_105975.0"> <label style="display: inline" for="items_105975.0">BBQ Chicken Pizza Small</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105975.1" id="items_105975.1"> <label style="display: inline" for="items_105975.1">BBQ Chicken Pizza Medium</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input checked="" type="checkbox" name="items[]" value="105975.2" id="items_105975.2"> <label style="display: inline" for="items_105975.2">BBQ Chicken Pizza Large</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105975.3" id="items_105975.3"> <label style="display: inline" for="items_105975.3">BBQ Chicken Pizza X-Large</label></li>
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105970.0" id="items_105970.0"> <label style="display: inline" for="items_105970.0">Greek Pizza Small</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105970.1" id="items_105970.1"> <label style="display: inline" for="items_105970.1">Greek Pizza Medium</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input checked="" type="checkbox" name="items[]" value="105970.2" id="items_105970.2"> <label style="display: inline" for="items_105970.2">Greek Pizza Large</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105970.3" id="items_105970.3"> <label style="display: inline" for="items_105970.3">Greek Pizza X-Large</label></li>
																<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105971.0" id="items_105971.0"> <label style="display: inline" for="items_105971.0">Garden Pizza Small</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105971.1" id="items_105971.1"> <label style="display: inline" for="items_105971.1">Garden Pizza Medium</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input checked="" type="checkbox" name="items[]" value="105971.2" id="items_105971.2"> <label style="display: inline" for="items_105971.2">Garden Pizza Large</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105971.3" id="items_105971.3"> <label style="display: inline" for="items_105971.3">Garden Pizza X-Large</label></li>
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105964.0" id="items_105964.0"> <label style="display: inline" for="items_105964.0">1 Topping Pizza HIDE Small</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105964.1" id="items_105964.1"> <label style="display: inline" for="items_105964.1">1 Topping Pizza HIDE Medium</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105964.2" id="items_105964.2"> <label style="display: inline" for="items_105964.2">1 Topping Pizza HIDE Large</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105964.3" id="items_105964.3"> <label style="display: inline" for="items_105964.3">1 Topping Pizza HIDE X-Large</label></li>						
													</ul>
					</li>
									<li>
						<h4>Twins Special</h4>
						<ul style="list-style-type: none; margin-left: 10px;overflow: hidden">		
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="106127" id="items_106127"> <label style="display: inline" for="items_106127">2 Large Pizzas</label></li>				
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="106128" id="items_106128"> <label style="display: inline" for="items_106128">2 Medium Pizzas</label></li>	
													</ul>
					</li>
									<li>
						<h4>Wings</h4>
						<ul style="list-style-type: none; margin-left: 10px;overflow: hidden">				
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105887" id="items_105887"> <label style="display: inline" for="items_105887">10 Jumbo Chicken Wings</label></li>				
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105888" id="items_105888"> <label style="display: inline" for="items_105888">15 Jumbo Chicken Wings</label></li>						
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105889" id="items_105889"> <label style="display: inline" for="items_105889">20 Jumbo Chicken Wings</label></li>				
													</ul>
					</li>
									<li>
						<h4>Salads</h4>
						<ul style="list-style-type: none; margin-left: 10px;overflow: hidden">				
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105894" id="items_105894"> <label style="display: inline" for="items_105894">Michel Salad</label></li>				
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105892" id="items_105892"> <label style="display: inline" for="items_105892">Fattouch Salad</label></li>					
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105891" id="items_105891"> <label style="display: inline" for="items_105891">Greek Salad</label></li>				
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105895" id="items_105895"> <label style="display: inline" for="items_105895">Caesar Salad</label></li>					
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105890" id="items_105890"> <label style="display: inline" for="items_105890">Amicci Salad</label></li>				
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105893" id="items_105893"> <label style="display: inline" for="items_105893">Feta Salad HIDE</label></li>					
													</ul>
					</li>
									<li>
						<h4>Wraps</h4>
						<ul style="list-style-type: none; margin-left: 10px;overflow: hidden">					
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105900" id="items_105900"> <label style="display: inline" for="items_105900">Chicken Shawarma</label></li>						
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105901" id="items_105901"> <label style="display: inline" for="items_105901">Beef Donair</label></li>					
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105896" id="items_105896"> <label style="display: inline" for="items_105896">Chicken Souvlaki Wrap</label></li>					
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105897" id="items_105897"> <label style="display: inline" for="items_105897">Pork Souvlaki Wrap</label></li>				
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105898" id="items_105898"> <label style="display: inline" for="items_105898">Beef Kafta Wrap</label></li>
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105899" id="items_105899"> <label style="display: inline" for="items_105899">Filet Mignon Wrap</label></li>
															<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="106132.0" id="items_106132.0"> <label style="display: inline" for="items_106132.0">Trio Shawarma Chicken</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="106132.1" id="items_106132.1"> <label style="display: inline" for="items_106132.1">Trio Shawarma Beef</label></li>
																<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="106133.0" id="items_106133.0"> <label style="display: inline" for="items_106133.0">Trio Souvlaki Chicken</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="106133.1" id="items_106133.1"> <label style="display: inline" for="items_106133.1">Trio Souvlaki Pork</label></li>						
													</ul>
					</li>
									<li>
						<h4>Appetizers</h4>
						<ul style="list-style-type: none; margin-left: 10px;overflow: hidden">
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105906" id="items_105906"> <label style="display: inline" for="items_105906">Rice</label></li>	
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105903" id="items_105903"> <label style="display: inline" for="items_105903">Dolmades (7)</label></li>			
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105907" id="items_105907"> <label style="display: inline" for="items_105907">Hummus</label></li>															
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105904" id="items_105904"> <label style="display: inline" for="items_105904">Tzatziki</label></li>						
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105905" id="items_105905"> <label style="display: inline" for="items_105905">Greek Potatoes</label></li>
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105902" id="items_105902"> <label style="display: inline" for="items_105902">Fried Calmars</label></li>
													</ul>
					</li>
									<li>
						<h4>Greek Platters</h4>
						<ul style="list-style-type: none; margin-left: 10px;overflow: hidden">
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105908" id="items_105908"> <label style="display: inline" for="items_105908">Chicken Shawarma Plate</label></li>
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105910" id="items_105910"> <label style="display: inline" for="items_105910">Chicken Skewer Plate</label></li>
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105911" id="items_105911"> <label style="display: inline" for="items_105911">Pork Skewer Plate</label></li>
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105909" id="items_105909"> <label style="display: inline" for="items_105909">Marinated Chicken Breast Plate</label></li>
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105912" id="items_105912"> <label style="display: inline" for="items_105912">Kafta Beef Skewer Plate</label></li>
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105914" id="items_105914"> <label style="display: inline" for="items_105914">Filet Mignon Plate</label></li>
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105913" id="items_105913"> <label style="display: inline" for="items_105913">Butterfly Shrimp Plate (8)</label></li>
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105915" id="items_105915"> <label style="display: inline" for="items_105915">Chicken Shrimp Combo (4)</label></li>
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105916" id="items_105916"> <label style="display: inline" for="items_105916">Filet mignon and Shrimps Skewers Combo (4)</label></li>
													</ul>
					</li>
									<li>
						<h4>Italian Dishes</h4>
						<ul style="list-style-type: none; margin-left: 10px;overflow: hidden">							
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105922" id="items_105922"> <label style="display: inline" for="items_105922">Meat Ravioli</label></li>															
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105917" id="items_105917"> <label style="display: inline" for="items_105917">Spaghetti Bolognese</label></li>															
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105919" id="items_105919"> <label style="display: inline" for="items_105919">Meatball Spaghetti</label></li>							
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105920" id="items_105920"> <label style="display: inline" for="items_105920">Meat Lasagna</label></li>							
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105923" id="items_105923"> <label style="display: inline" for="items_105923">Meat Canneloni</label></li>
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105924" id="items_105924"> <label style="display: inline" for="items_105924">Spinach Canneloni</label></li>
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105925" id="items_105925"> <label style="display: inline" for="items_105925">Chicken Parmesan</label></li>
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105918" id="items_105918"> <label style="display: inline" for="items_105918">Neopolitain Spaghetti HIDE</label></li>
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105921" id="items_105921"> <label style="display: inline" for="items_105921">Neopolitain Lasagna HIDE</label></li>
													</ul>
					</li>
									<li>
						<h4>Canadian Dishes</h4>
						<ul style="list-style-type: none; margin-left: 10px;overflow: hidden">
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105926" id="items_105926"> <label style="display: inline" for="items_105926">Club Sandwich</label></li>
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105931" id="items_105931"> <label style="display: inline" for="items_105931">Chicken Burger Platter</label></li>
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105930" id="items_105930"> <label style="display: inline" for="items_105930">Hamburger Platter</label></li>
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105928" id="items_105928"> <label style="display: inline" for="items_105928">Hamburger Steak</label></li>
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105932" id="items_105932"> <label style="display: inline" for="items_105932">Hot Chicken Sandwich</label></li>
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105929" id="items_105929"> <label style="display: inline" for="items_105929">Chicken Fingers</label></li>
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105947" id="items_105947"> <label style="display: inline" for="items_105947">Fish N Chips</label></li>
																																				<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105933.0" id="items_105933.0"> <label style="display: inline" for="items_105933.0">Fries Small</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105933.1" id="items_105933.1"> <label style="display: inline" for="items_105933.1">Fries Large</label></li>
																																				<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105934.0" id="items_105934.0"> <label style="display: inline" for="items_105934.0">Onion Rings Small</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105934.1" id="items_105934.1"> <label style="display: inline" for="items_105934.1">Onion Rings Large</label></li>
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105940" id="items_105940"> <label style="display: inline" for="items_105940">Nachos</label></li>
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105942" id="items_105942"> <label style="display: inline" for="items_105942">Garlic Bread HIDE</label></li>
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105943" id="items_105943"> <label style="display: inline" for="items_105943">Garlic Cheese Bread</label></li>
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105944" id="items_105944"> <label style="display: inline" for="items_105944">Cheese Sticks</label></li>
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105945" id="items_105945"> <label style="display: inline" for="items_105945">Deep Fried Pickles</label></li>
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105941" id="items_105941"> <label style="display: inline" for="items_105941">Fried Zucchini</label></li>
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105946" id="items_105946"> <label style="display: inline" for="items_105946">Amicci Platter</label></li>
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105927" id="items_105927"> <label style="display: inline" for="items_105927">Club Poutine HIDE</label></li>
													</ul>
					</li>
									<li>
						<h4>Poutine</h4>
						<ul style="list-style-type: none; margin-left: 10px;overflow: hidden">
																																				<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105935.0" id="items_105935.0"> <label style="display: inline" for="items_105935.0">Regular Poutine Small</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105935.1" id="items_105935.1"> <label style="display: inline" for="items_105935.1">Regular Poutine Large</label></li>
																																				<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105936.0" id="items_105936.0"> <label style="display: inline" for="items_105936.0">Italian Poutine Small</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105936.1" id="items_105936.1"> <label style="display: inline" for="items_105936.1">Italian Poutine Large</label></li>
																																				<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105937.0" id="items_105937.0"> <label style="display: inline" for="items_105937.0">Chicken Shawarma Poutine Small</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105937.1" id="items_105937.1"> <label style="display: inline" for="items_105937.1">Chicken Shawarma Poutine Large</label></li>
																																				<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105938.0" id="items_105938.0"> <label style="display: inline" for="items_105938.0">Bacon Poutine Small</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105938.1" id="items_105938.1"> <label style="display: inline" for="items_105938.1">Bacon Poutine Large</label></li>
																																				<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105939.0" id="items_105939.0"> <label style="display: inline" for="items_105939.0">Senator’s Poutine Small</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105939.1" id="items_105939.1"> <label style="display: inline" for="items_105939.1">Senator’s Poutine Large</label></li>
													</ul>
					</li>
									<li>
						<h4>Subs</h4>
						<ul style="list-style-type: none; margin-left: 10px;overflow: hidden">
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105951" id="items_105951"> <label style="display: inline" for="items_105951">Steak Philly Sub</label></li>
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105949" id="items_105949"> <label style="display: inline" for="items_105949">Steak Pepperoni Sub</label></li>
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105950" id="items_105950"> <label style="display: inline" for="items_105950">Steak Bacon Sub</label></li>
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105952" id="items_105952"> <label style="display: inline" for="items_105952">Meatballs Sub</label></li>
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105953" id="items_105953"> <label style="display: inline" for="items_105953">Club Sub</label></li>
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105948" id="items_105948"> <label style="display: inline" for="items_105948">Steak Sub HIDE</label></li>
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105954" id="items_105954"> <label style="display: inline" for="items_105954">Pepperoni Sub HIDE</label></li>
													</ul>
					</li>
									<li>
						<h4>Desserts</h4>
						<ul style="list-style-type: none; margin-left: 10px;overflow: hidden">
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105955" id="items_105955"> <label style="display: inline" for="items_105955">Cheesecake</label></li>
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105956" id="items_105956"> <label style="display: inline" for="items_105956">Baklava (1)</label></li>
																																				<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="113284.0" id="items_113284.0"> <label style="display: inline" for="items_113284.0">Truffles (4) HIDE Salted pistachio and dark chocolate</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="113284.1" id="items_113284.1"> <label style="display: inline" for="items_113284.1">Truffles (4) HIDE Red Velvet</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="113284.2" id="items_113284.2"> <label style="display: inline" for="items_113284.2">Truffles (4) HIDE Oreo Chocolate</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="113284.3" id="items_113284.3"> <label style="display: inline" for="items_113284.3">Truffles (4) HIDE Oreo Chocolate and Vanilla</label></li>
													</ul>
					</li>
									<li>
						<h4>Drinks</h4>
						<ul style="list-style-type: none; margin-left: 10px;overflow: hidden">	
																																				<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105957.0" id="items_105957.0"> <label style="display: inline" for="items_105957.0">Pepsi Can</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105957.1" id="items_105957.1"> <label style="display: inline" for="items_105957.1">Pepsi 2L</label></li>
																																				<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105958.0" id="items_105958.0"> <label style="display: inline" for="items_105958.0">Coke Can</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105958.1" id="items_105958.1"> <label style="display: inline" for="items_105958.1">Coke 2L</label></li>
																																				<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105959.0" id="items_105959.0"> <label style="display: inline" for="items_105959.0">7Up Can</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105959.1" id="items_105959.1"> <label style="display: inline" for="items_105959.1">7Up 2L</label></li>
																																				<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105960.0" id="items_105960.0"> <label style="display: inline" for="items_105960.0">Sprite Can</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105960.1" id="items_105960.1"> <label style="display: inline" for="items_105960.1">Sprite 2L</label></li>						
																																				<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105961.0" id="items_105961.0"> <label style="display: inline" for="items_105961.0">Ginger Ale Can</label></li>
																			<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105961.1" id="items_105961.1"> <label style="display: inline" for="items_105961.1">Ginger Ale 2L</label></li>
																	<li style="width:32%; float: left;margin-right:2px;"><input type="checkbox" name="items[]" value="105962" id="items_105962"> <label style="display: inline" for="items_105962">Bottled Water</label></li>
													</ul>
					</li>
					</ul>
	</div>



and verify if any if the checkboxes are checked:
<li style="width:32%; float: left;margin-right:2px;"><input checked="" type="checkbox" name="items[]" value="105963.2" id="items_105963.2"> <label style="display: inline" for="items_105963.2">Cheese Pizza Large</label></li>


If any of the checkboxes are checked then the current combo group is a special combo group that need to be re-scraped. 

7. Set the value of combo_groups.has_special_section of the current combo_group to true

8. `combo_group_dish_selections` Table:
size and dish_display_name can be get from this html element:
<li style="width:32%; float: left;margin-right:2px;"><input checked="" type="checkbox" name="items[]" value="105965.2" id="items_105965.2"> <label style="display: inline" for="items_105965.2">Combination Pizza Large</label></li>

store the dish_display_name value only if it is different from dish.name for the same dish id

## Special Section Data Model

This combo group has a special section that references **actual dishes** from the restaurant menu. Each dish can be referenced with an optional size variant.

### Value Format Parsing

```
value="105965.2" → source_id=105965, size=2 (Large)
value="105962"   → source_id=105962, size=NULL (no size variant)
```

**Size mapping:**
- `0` = Small
- `1` = Medium  
- `2` = Large
- `3` = Extra Large
- `NULL` = No size variant (single-price dish)

### Example HTML

```html
<input checked="" type="checkbox" name="items[]" value="105965.2" id="items_105965.2">
<label for="items_105965.2">Combination Pizza Large</label>
```

### Database Insert Logic

1. Parse `value` to extract `source_id` and `size`
2. Look up V3 `dish_id` using: `source_id` + `restaurant_id`
3. Look up V3 `course_id` using: course name from parent `<h4>` + `restaurant_id`
4. Insert into `combo_group_dish_selections`:
   - `combo_group_id` → Current combo group
   - `dish_id` → V3 dish ID (FK)
   - `size` → Size index (0-3) or NULL
   - `course_id` → V3 course ID (FK)
   - `dish_display_name` → Only if label text differs from dish.name

### Special Section Characteristics

| Field | Source | Maps To |
|-------|--------|---------|
| Display Header | `<input name="display_header">` | `combo_groups.special_display_header` |
| Number of Items | `<input name="number_of_items">` | `combo_groups.special_number_of_items` |
| Has Special Section | Any checked checkbox in `#dishes` | `combo_groups.has_special_section = TRUE` |
| Dish Selections | Checked checkboxes with `name="items[]"` | `combo_group_dish_selections` rows |

**Note:** The special section should always be displayed BEFORE the normal combo_group_sections in the UI.
