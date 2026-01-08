The purpose of this scraper is to link each of the v2 combo groups migrated in the past and link them with their respective dish.

## Phase 3:
Go over each dish for each restaurant and verify if it is a normal dish or a combo dish. If it is a noraml dish skip it, if it is a combo dish link it to the right combo group ID so we can map the right modifiers to it.

# Mapping for the scraping process:
We will use the legacy V2 CRM to scrape the data. Each v2 restaurant has a legacy_v2_id. This should be our primary criteria to determine which restaurant should be scraped.

# Restaurants to be scrapped:
|V3 ID |legacy_v2_id  | name
| ---- | ------------ | --------------------------------- |
| 981  | 1678         | Al-s Drive In                     |
| 973  | 1670         | Capital Bites                     |
| 977  | 1674         | Capri Pizza                       |
| 966  | 1663         | Chicco Pizza de l�Hopital         |
| 964  | 1661         | Chicco Pizza Maloney              |
| 963  | 1660         | Chicco Pizza Shawarma Anger       |
| 967  | 1664         | Chicco Pizza St-Louis             |
| 961  | 1658         | Chicco Shawarma Cantley           |
| 965  | 1662         | Chicco Shawarma Maloney           |
| 957  | 1654         | Cosenza                           |
| 960  | 1657         | Cuisine Bombay Indienne           |
| 950  | 1637         | Kirkwood Pizza                    |
| 825  | 1642         | La Nawab                          |
| 971  | 1668         | Little Gyros Greek Grill          |
| 974  | 1671         | Pachino Pizza                     |
| 147  | 1171         | Pho Dau Bo Restaurant - Kitchener |
| 976  | 1673         | Pizza Marie                       |
| 952  | 1639         | River Pizza                       |
| 133  | 1157         | Riverside Pizzeria                |
| 1020 | 1285         | Sushi Presse                      |
| 954  | 1641         | Wandee Thai                       |


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
## Login to the V2 CRM:
<form action="https://aggregator-admin.menu.ca/index.php/auth/index" id="loginForm" autocomplete="off" method="post" accept-charset="utf-8">
	<h2 class="text-center mb-4">Sign in to your account</h2>
	<p class="mb-1">Enter your <span class="font-weight-bold">email address</span> and <span class="font-weight-bold">password</span>.</p>
	<div class="form-group has-feedback">
		<input placeholder="email address" type="email" class="form-control form-control-lg" name="email">
	</div>
	<div class="form-group has-feedback">
		<input placeholder="password" type="password" name="password" class="form-control form-control-lg">
	</div>
	<div class="form-group">
		<button type="submit" class="btn btn-danger btn-block">Sign in</button>
	</div>
</form>

### Go to the menu details site of each restaurant

The URL for the menu details of each English restaurant is: 
https://aggregator-admin.menu.ca/index.php/restaurants/edit/[restaurant_legacy_v2_id]/menu/1/restaurant

The URL of the menu details of each French restaurant is:
https://aggregator-admin.m_enu.ca/index.php/restaurants/edit/[restaurant_legacy_v2_id]/menu/2/restaurant

Access this URL using the legacy_v2_id of each of the restaurants to be scraped. 
All the courses and their respective dishes are inside this html element: <div class="col-sm-12" id="sortable">

### Access each dish
Each course with its respective dishes are located in this kind of html markup:

<div class="jarviswidget jarviswidget-color-darken course-listing jarviswidget-sortable" id="c_1347" data-id="1347" data-course="Walk In" style="" role="widget">
                            <header role="heading"><div class="jarviswidget-ctrls" role="menu">    <a href="javascript:void(0);" class="button-icon jarviswidget-toggle-btn" rel="tooltip" title="" data-placement="bottom" data-original-title="Collapse"><i class="fa fa-minus "></i></a>  </div>
                                <h2>
                                    <a href="#" class="rename" data-course-id="1347" title="click to rename this course" style="color: #fff">
                                        Walk In
                                    </a>
                                </h2>
                            <span class="jarviswidget-loader"><i class="fa fa-refresh fa-spin"></i></span></header>
                            <div id="course_1347" class="widget-body" role="content">
                                                                <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_course_description" method="post" class="form_update_course">
                                    <input type="hidden" name="course_id" value="1347">
                                    <div class="form-group">
                                        <label for="course_desc_1347">course description</label>
                                        <div class="input-group input-group-sm">
                                            <textarea name="desc" id="course_desc_1347" cols="1" rows="3" class="form-control"></textarea>
                                            <span class="input-group-btn">
										<button class="btn btn-primary">Update course description</button>
									</span>
                                        </div>
                                    </div>
                                </form>                                
                                                                <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_dishes" method="post" class="form_update_course">
                                    <div class="table-responsive">
                                        <input type="hidden" name="course" value="1347">
                                        <table class="table table-bordered table-striped table-condensed show-dishes" id="table_1347">
                                            <thead>
                                            <tr>
                                                <td colspan="3" class="text-right">
                                                                                                    </td>
                                                <td colspan="2" class="text-right">
                                                    <span class="form-control-static">course available for - if none chosen, course will not show: </span>&nbsp;
                                                                                                            <label class="checkbox-inline">
                                                            <input type="checkbox" name="available_for[1]" value="1" data-name="1" data-course="1347" checked="">
                                                            Takeout
                                                        </label>
                                                                                                            <label class="checkbox-inline">
                                                            <input type="checkbox" name="available_for[2]" value="2" data-name="2" data-course="1347">
                                                            Delivery
                                                        </label>
                                                                                                        <button type="button" class="btn btn-default btn-xs available_for">
                                                        update
                                                    </button>
                                                </td>
                                            </tr>
                                            <tr>
                                                <th class="dish-actions visible-xs">
                                                    <div class="btn-group">
                                                        <button class="btn btn-default  dropdown-toggle" data-toggle="dropdown">
                                                            add dish <span class="caret"></span>
                                                        </button>
                                                        <ul class="dropdown-menu">
                                                            <li>
                                                                <a href="#mod_add_dish" class="add-dish-modal" data-course="1347" data-toggle="modal">
                                                                    regular dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showCreateCombo/1347/1670" data-target="#mod_create_combo" data-toggle="modal" data-backdrop="static" data-keyboard="true" data-course="1347">
                                                                    combo dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showImportDish/1347/1670" data-target="#mod_import_dish" class="add-dish-modal" data-course="1347" data-toggle="modal" data-backdrop="static" data-keyboard="true">
                                                                    import dishes
                                                                </a>
                                                            </li>
                                                        </ul>
                                                    </div>
                                                </th>
                                                <th class="dish-name">name</th>
                                                <th class="dish-desc">description</th>
                                                <th class="dish-size">size(s)</th>
                                                <th class="dish-price">price(s)</th>
                                                <th class="text-center dish-actions hidden-xs">
                                                    <div class="btn-group">
                                                        <button class="btn btn-default  dropdown-toggle" data-toggle="dropdown">
                                                            add dish <span class="caret"></span>
                                                        </button>
                                                        <ul class="dropdown-menu">
                                                            <li>
                                                                <a href="#mod_add_dish" class="add-dish-modal" data-course="1347" data-toggle="modal">
                                                                    regular dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showCreateCombo/1347/1670" data-target="#mod_create_combo" data-toggle="modal" data-backdrop="static" data-keyboard="true" data-course="1347">
                                                                    combo dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showImportDish/1347/1670" data-target="#mod_import_dish" class="add-dish-modal" data-course="1347" data-toggle="modal" data-backdrop="static" data-keyboard="true">
                                                                    import dishes
                                                                </a>
                                                            </li>
                                                        </ul>
                                                    </div>
                                                </th>
                                            </tr>
                                            </thead>
                                            <tfoot>
                                            <tr>
                                                <td class="visible-xs">
                                                    <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/manage_dishes/1347" data-backdrop="static" data-keyboard="true" data-toggle="modal" data-target="#mod_manage_dishes" class="sort_dishes btn btn-default" data-course="1347">dish order</a>
                                                    <button type="submit" class="btn btn-primary ">
                                                        Update
                                                    </button>
                                                </td>
                                                <td colspan="2">
                                                    <div class="input-group">
												<span class="input-group-btn">
													<a href="#" data-update-type="value" class="btn btn-default update-prices">value</a>
												</span>
                                                        <input type="number" name="update_prices_by" id="update_prices_by_1347" class="form-control update_prices_by" value="0" placeholder="update prices by" min="0" step="0.1">
                                                        <span class="input-group-btn">
													<a href="#" data-update-type="percent" class="btn btn-default update-prices">percent</a>
												</span>
                                                    </div>
                                                </td>
                                                <td colspan="2"></td>
                                                <td class="text-right hidden-xs">
                                                    <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/manage_dishes/1347" data-backdrop="static" data-keyboard="true" data-toggle="modal" data-target="#mod_manage_dishes" class="sort_dishes btn btn-default" data-course="1347">dish order</a>
                                                    <button type="submit" class="btn btn-primary ">
                                                        Update
                                                    </button>
                                                </td>
                                            </tr>
                                            </tfoot>
                                            <tbody>
                                                                                                                                                <tr class="sort" data-id="10666" style="" data-dish="Walk-In Special (Medium Pizza)" data-display_order="0">
                                                        <td class="visible-xs">
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10666" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[10666]" value="Walk-In Special (Medium Pizza)" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[10666]" value="1 medium pizza 1 topping." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[10666]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[10666]" value="15.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[10666]" value="10666">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_combo/10666/1670/1" data-dish="10666" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_create_combo" data-backdrop="static" data-keyboard="true" data-dishname="Walk-In Special (Medium Pizza)">
                                                                    edit
                                                                </a>                                                           
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10666" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                       </tbody>
                                        </table>
                                    </div>
                                </form>
                                                            </div>
                        </div>

Things to notice: 
- Name of the course: 
<h2>
    <a href="#" class="rename" data-course-id="1347" title="click to rename this course" style="color: #fff">
        Walk In
    </a>
</h2>

- Dish under each course:
<tr class="sort" data-id="10666" style="" data-dish="Walk-In Special (Medium Pizza)" data-display_order="0">
                                                        <td class="visible-xs">
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10666" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[10666]" value="Walk-In Special (Medium Pizza)" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[10666]" value="1 medium pizza 1 topping." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[10666]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[10666]" value="15.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[10666]" value="10666">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_combo/10666/1670/1" data-dish="10666" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_create_combo" data-backdrop="static" data-keyboard="true" data-dishname="Walk-In Special (Medium Pizza)">
                                                                    edit
                                                                </a>                                                          
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10666" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>


Click on the edit button element to launch the modal with the dish details: 
<a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_combo/10666/1670/1" data-dish="10666" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_create_combo" data-backdrop="static" data-keyboard="true" data-dishname="Walk-In Special (Medium Pizza)">
                                                                    edit
                                                                </a>

Two things are very important to notice from this element:
1. the href element has a edit_combo substring. This is the key element that will tell you if a dish is a combo dish or not. A normal dish would have this href: 
<a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/9903/1670/1" data-dish="9903" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Plain Pizza">edit</a>

If the href of the current dish has a edit_dish substring, skip it and continue with the next dish. If it has a edit_combo substring click on the edit button to open the dish details to scrape its assigned combo groups.

2. The href element contains the source_id of each dish. For example, for the Walk-In Special (Medium Pizza) (id 172885 ; source_id 10666)  this is its anchor element:
<a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_combo/10666/1670/1" data-dish="10666" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_create_combo" data-backdrop="static" data-keyboard="true" data-dishname="Walk-In Special (Medium Pizza)">
                                                                    edit
                                                                </a>

Use this source_id to map each v2 dish to its respective v3 record in the menuca_v3.dishes table

### Link the respective combo group to each dish

The details of each combo group is stored in a modal inside this element:
<div class="modal-body"></div>

The dish-specific details are in this element:
<form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_combo" method="post" id="comboForm">
				<input type="hidden" name="is_combo" value="y">			
									<input type="hidden" name="dish_id" value="10666">				
				<div id="combo_content">
					<div class="form-group">
						<label for="combo_name">name</label>
						<input type="text" name="name" id="combo_name" class="form-control" value="Walk-In Special (Medium Pizza)">
					</div>
					<div class="form-group">
						<label for="combo_desc">description</label>
						<textarea name="description" id="combo_desc" cols="30" rows="3" class="form-control">1 medium pizza 1 topping.</textarea>
					</div>
					<div class="form-group">
						<label for="combo_size">size</label>
						<input type="text" name="size" id="combo_size" class="form-control" value="">
					</div>
					<div class="form-group">
						<label for="combo_price">price</label>
						<input type="text" name="price" id="combo_price" class="form-control" value="15.00">
					</div>
					<div id="drop_here" class="text-center ui-widget-header ui-droppable">
						drag groups here to add to combo
					</div>
										<ul class="ul-dish">
													<li class="alert-info">
								<div style="overflow: hidden;">
									<div class="pull-left">
										<input type="hidden" name="dish_info[group][group_id][0]" value="261">
										<input type="hidden" name="dish_info[group][group_name][0]" value="1 Medium 1 Topping">
										<span>1 Medium 1 Topping</span>
									</div>
									<div style="padding: 2px 4px;" class="pull-right alert-danger">
										<a title="remove this dish from combo" href="#" style="color: #000; display: block" class="remove">
											<i class="fa fa-minus"></i>
										</a>
									</div>
								</div>
							</li>
													<li class="alert-info">
								<div style="overflow: hidden;">
									<div class="pull-left">
										<input type="hidden" name="dish_info[group][group_id][1]" value="227">
										<input type="hidden" name="dish_info[group][group_name][1]" value="Dips">
										<span>Dips</span>
									</div>
									<div style="padding: 2px 4px;" class="pull-right alert-danger">
										<a title="remove this dish from combo" href="#" style="color: #000; display: block" class="remove">
											<i class="fa fa-minus"></i>
										</a>
									</div>
								</div>
							</li>
											</ul>
					<div class="checkbox">
						<label>
							<input type="checkbox" name="dish_info[split_ingredients]" value="y">
							Split																					                            ingredients between pizzas
						</label>
					</div>
					<div class="checkbox">
						<label>
							<input type="checkbox" name="drink" value="y" class="drink_selection">
							this combo has drinks
						</label>
					</div>
					<div id="show_drink_groups" style="display: none">
						<div class="form-group div_options row">
																												<div class="col-sm-6">
								<label for="c_drink_title_free">use tile for free drinks</label>
								<input type="text" name="customization[drink][title][free]" id="c_drink_title_free" class="form-control" value="Drinks">
							</div>
							<div class="col-sm-6">
								<label for="c_drink_title_paid">use tile for paid drinks</label>
								<input type="text" name="customization[drink][title][paid]" id="c_drink_title_paid" class="form-control" value="Drinks">
							</div>
						</div>
						<div class="row form-group div_options">
							<div class="col-sm-4">
																<label for="c_drink_min">min items</label>
								<input type="number" class="form-control" name="customization[drink][min]" id="c_drink_min" min="0" value="1">
							</div>
							<div class="col-sm-4">
																<label for="c_drink_max">max items</label>
								<input type="number" class="form-control" name="customization[drink][max]" id="c_drink_max" min="0" value="1">
							</div>
							<div class="col-sm-4">
																<label for="c_drink_free">free items</label>
								<input type="number" class="form-control" name="customization[drink][free]" id="c_drink_free" min="0" value="0">
							</div>
						</div>
						<div>choose drinks group</div>
													<div class="radio">
																<label>
									<input type="radio" name="customization[drink][drink_group]" value="583">
									Drinks Can
								</label>
							</div>
											</div>
					<div>
						<div class="checkbox">
							<span style="display: block">dish available on</span>
																													<label class="checkbox-inline" title="monday">
																		<input type="checkbox" name="dish_info[show_on][mon]" checked="" data-smt="true">
									mon
								</label>
															<label class="checkbox-inline" title="tuesday">
																		<input type="checkbox" name="dish_info[show_on][tue]" checked="" data-smt="true">
									tue
								</label>
															<label class="checkbox-inline" title="wednesday">
																		<input type="checkbox" name="dish_info[show_on][wed]" checked="" data-smt="true">
									wed
								</label>
															<label class="checkbox-inline" title="thursday">
																		<input type="checkbox" name="dish_info[show_on][thu]" checked="" data-smt="true">
									thu
								</label>
															<label class="checkbox-inline" title="friday">
																		<input type="checkbox" name="dish_info[show_on][fri]" checked="" data-smt="true">
									fri
								</label>
															<label class="checkbox-inline" title="saturday">
																		<input type="checkbox" name="dish_info[show_on][sat]" checked="" data-smt="true">
									sat
								</label>
															<label class="checkbox-inline" title="sunday">
																		<input type="checkbox" name="dish_info[show_on][sun]" checked="" data-smt="true">
									sun
								</label>
													</div>
					</div>
					<button class="btn btn-primary btn-block" type="submit">
						<i class="fa fa-save"></i>
													Update dish
											</button>
				</div>
			</form>

The combo groups assigned to the given combo dish are located in this element:
<ul class="ul-dish">
    <li class="alert-info">
        <div style="overflow: hidden;">
            <div class="pull-left">
                <input type="hidden" name="dish_info[group][group_id][0]" value="261">
                <input type="hidden" name="dish_info[group][group_name][0]" value="1 Medium 1 Topping">
                <span>1 Medium 1 Topping</span>
            </div>
            <div style="padding: 2px 4px;" class="pull-right alert-danger">
                <a title="remove this dish from combo" href="#" style="color: #000; display: block" class="remove">
                    <i class="fa fa-minus"></i>
                </a>
            </div>
        </div>
    </li>
                            <li class="alert-info">
        <div style="overflow: hidden;">
            <div class="pull-left">
                <input type="hidden" name="dish_info[group][group_id][1]" value="227">
                <input type="hidden" name="dish_info[group][group_name][1]" value="Dips">
                <span>Dips</span>
            </div>
            <div style="padding: 2px 4px;" class="pull-right alert-danger">
                <a title="remove this dish from combo" href="#" style="color: #000; display: block" class="remove">
                    <i class="fa fa-minus"></i>
                </a>
            </div>
        </div>
    </li>
</ul>

Notice that each combo group has an input element with its respective source_id. For example for the 1 Medium 1 Topping (v3 id 2890; source id 261) we have this element containing its name and source_id (value="261")
<div class="pull-left">
                <input type="hidden" name="dish_info[group][group_id][0]" value="261">
                <input type="hidden" name="dish_info[group][group_name][0]" value="1 Medium 1 Topping">
                <span>1 Medium 1 Topping</span>
            </div>


Your job is to link this dish (Walk-In Special (Medium Pizza) v3 id 172885) to all its respective combo groups assigned to it: 1 Medium 1 Topping (v3 id 261) and Dips (v3 id 227). Use this table to link all the dishes to their respective combo groups:

dish_combo_groups
Junction table for N:M relationship between dishes and combo groups.

| Column | Type | Description |
|--------|------|-------------|
| id | BIGSERIAL | Primary Key |
| dish_id | BIGINT | FK → dishes.id |
| combo_group_id | BIGINT | FK → combo_groups.id |
| is_active | BOOLEAN | Active status (default: TRUE) |
| UNIQUE | | (dish_id, combo_group_id) |

Once you finish, close the modal (<button type="button" class="close" data-dismiss="modal" aria-label="Close">
		<span aria-hidden="true">×</span>
	</button>) and continue with the next dish
















