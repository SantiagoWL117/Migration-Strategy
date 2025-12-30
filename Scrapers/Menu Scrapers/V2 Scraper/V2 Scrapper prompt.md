# This scraper will have three phases:
## Phase 1: Scrape all modifier groups 
Go over the v2 restaurants in the menuca_v3.restaurants table, verify if it they have modifier groups and if it does store all the modifier groups, modifiers, and modifier_prices for each restaurant.

## Phase 2: Scrape all Combo Groups 
Go over the v2 restaurants in the menuca_v3.restaurants table, verify if it has combo groups and if it does store all the combo groups, combo group sections, combo modifier groups, combo modifiers and combo modifier prices for each restaurant

## Phase 3:
Go over each dish for each restaurant and verify if it is a normal dish or a combo dish. 
- For normal dishes: link the dish to the right modifier group ID so we can map the right modifiers to it.
- For combo dishes: link the dish to the right combo group ID so we can map the right modifiers to it.

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

# V3 Modifier group schema

┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                              MODIFIER GROUPS SCHEMA (V3)                                     │
└─────────────────────────────────────────────────────────────────────────────────────────────┘

        RESTAURANT LEVEL                              DISH LEVEL
      (Shared within restaurant)                   (Dish-specific)
    ════════════════════════════                ════════════════════════════

┌───────────────────────────┐                  ┌─────────────────────────────────┐
│     modifier_groups       │                  │         dishes                  │
│  (Shared at restaurant)   │                  ├─────────────────────────────────┤
├───────────────────────────┤                  │ id                              │
│ id            PK          │                  │ name                            │
│ restaurant_id FK          │                  │ has_customization               │
│ name          (internal)  │                  └────────────────┬────────────────┘
│ category      (type code) │                                   │
└───────────┬───────────────┘                                   │
            │                                                   │
            │ 1:N                                               │
            ▼                                                   ▼
┌───────────────────────────┐                  ┌─────────────────────────────────┐
│       modifiers           │                  │     dish_modifier_groups        │
│  (Shared options)         │                  │  (Link: dish ↔ modifier_group)  │
├───────────────────────────┤                  ├─────────────────────────────────┤
│ id            PK          │                  │ id              PK              │
│ modifier_group_id FK      │                  │ dish_id         FK              │
│ name                      │                  │ modifier_group_id FK            │
│ display_order             │                  └────────────────┬────────────────┘
│ is_active                 │                                   │
└───────────┬───────────────┘                                   │ 1:1
            │                                                   ▼
            │ 1:N                              ┌─────────────────────────────────┐
            ▼                                  │   modifier_group_details        │
┌───────────────────────────┐                  │  (Per-dish display settings)    │
│    modifier_prices        │                  ├─────────────────────────────────┤
│  (Size-based pricing)     │                  │ id              PK              │
├───────────────────────────┤                  │ dish_modifier_group_id FK       │
│ id            PK          │                  │ name            (display name)  │
│ modifier_id   FK          │                  │ min_selections                  │
│ size_variant              │                  │ max_selections                  │
│ price                     │                  │ free_items                      │
│ display_order             │                  │ display_order                   │
└───────────────────────────┘                  └─────────────────────────────────┘

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


The first step is to separate the english from the french restaurants. 
Visit this URL https://aggregator-admin.menu.ca/index.php/restaurants/edit/[legacy_v2_id]/menu/restaurant
Use the legacy_v2_id of each restaurant to visit this page.

If the page has this layout, categorize the restaurant as French:
<div class="row">
            <div class="col-sm-12">
                <div id="course_upload" class="jarviswidget jarviswidget-color-darken course-upload jarviswidget-sortable" role="widget">
                    <header role="heading"><div class="jarviswidget-ctrls" role="menu">    <a href="javascript:void(0);" class="button-icon jarviswidget-toggle-btn" rel="tooltip" title="" data-placement="bottom" data-original-title="Collapse"><i class="fa fa-minus "></i></a>  </div>
                        <h2>
                            Upload pdf courses
                        </h2>
                    <span class="jarviswidget-loader"><i class="fa fa-refresh fa-spin"></i></span></header>
                    <div class="widget-body" id="course_upload_body" role="content">
                        <div class="row">
                            <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/upload_pdf_menu" method="post" id="form_upload">
                                <input type="hidden" name="restaurant_id" value="1664">
                                <div class="col-sm-4">
                                    <label for="file_en">English menu</label>
                                    <input type="file" name="file[en]" class="btn btn-default" id="file_en">
                                </div>
                                <div class="col-sm-4">
                                    <label for="file_fr">French menu</label>
                                    <input type="file" name="file[fr]" class="btn btn-default" id="file_fr">
                                </div>
                                <div class="col-sm-4">
                                    <button type="submit" class="btn btn-primary" style="margin-top: 3rem">Upload menus
                                    </button>
                                </div>
                            </form>
                        </div>
                                            </div>
                </div>
            </div>
        </div>

If the page has this layout, categorize it as English:
<div class="row">
                <div class="col-sm-12" id="sortable">
                                            <div class="jarviswidget jarviswidget-color-darken course-listing jarviswidget-sortable" id="c_1292" data-id="1292" data-course="Daily Specials" role="widget">
                            <header role="heading"><div class="jarviswidget-ctrls" role="menu">    <a href="javascript:void(0);" class="button-icon jarviswidget-toggle-btn" rel="tooltip" title="" data-placement="bottom" data-original-title="Collapse"><i class="fa fa-minus "></i></a>  </div>
                                <h2>
                                    <a href="#" class="rename" data-course-id="1292" title="click to rename this course" style="color: #fff">
                                        Daily Specials
                                    </a>
                                </h2>
                            <span class="jarviswidget-loader"><i class="fa fa-refresh fa-spin"></i></span></header>
                            <div id="course_1292" class="widget-body" role="content">
                                                                <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_course_description" method="post" class="form_update_course">
                                    <input type="hidden" name="course_id" value="1292">
                                    <div class="form-group">
                                        <label for="course_desc_1292">course description</label>
                                        <div class="input-group input-group-sm">
                                            <textarea name="desc" id="course_desc_1292" cols="1" rows="3" class="form-control"></textarea>
                                            <span class="input-group-btn">
										<button class="btn btn-primary">Update course description</button>
									</span>
                                        </div>
                                    </div>
                                </form>                                
                                                                <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_dishes" method="post" class="form_update_course">
                                    <div class="table-responsive">
                                        <input type="hidden" name="course" value="1292">
                                        <table class="table table-bordered table-striped table-condensed show-dishes" id="table_1292">
                                            <thead>
                                            <tr>
                                                <td colspan="3" class="text-right">
                                                                                                    </td>
                                                <td colspan="2" class="text-right">
                                                    <span class="form-control-static">course available for - if none chosen, course will not show: </span>&nbsp;
                                                                                                            <label class="checkbox-inline">
                                                            <input type="checkbox" name="available_for[1]" value="1" data-name="1" data-course="1292" checked="">
                                                            Takeout
                                                        </label>
                                                                                                            <label class="checkbox-inline">
                                                            <input type="checkbox" name="available_for[2]" value="2" data-name="2" data-course="1292" checked="">
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
                                                                <a href="#mod_add_dish" class="add-dish-modal" data-course="1292" data-toggle="modal">
                                                                    regular dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showCreateCombo/1292/1637" data-target="#mod_create_combo" data-toggle="modal" data-backdrop="static" data-keyboard="true" data-course="1292">
                                                                    combo dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showImportDish/1292/1637" data-target="#mod_import_dish" class="add-dish-modal" data-course="1292" data-toggle="modal" data-backdrop="static" data-keyboard="true">
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
                                                                <a href="#mod_add_dish" class="add-dish-modal" data-course="1292" data-toggle="modal">
                                                                    regular dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showCreateCombo/1292/1637" data-target="#mod_create_combo" data-toggle="modal" data-backdrop="static" data-keyboard="true" data-course="1292">
                                                                    combo dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showImportDish/1292/1637" data-target="#mod_import_dish" class="add-dish-modal" data-course="1292" data-toggle="modal" data-backdrop="static" data-keyboard="true">
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
                                                    <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/manage_dishes/1292" data-backdrop="static" data-keyboard="true" data-toggle="modal" data-target="#mod_manage_dishes" class="sort_dishes btn btn-default" data-course="1292">dish order</a>
                                                    <button type="submit" class="btn btn-primary ">
                                                        Update
                                                    </button>
                                                </td>
                                                <td colspan="2">
                                                    <div class="input-group">
												<span class="input-group-btn">
													<a href="#" data-update-type="value" class="btn btn-default update-prices">value</a>
												</span>
                                                        <input type="number" name="update_prices_by" id="update_prices_by_1292" class="form-control update_prices_by" value="0" placeholder="update prices by" min="0" step="0.1">
                                                        <span class="input-group-btn">
													<a href="#" data-update-type="percent" class="btn btn-default update-prices">percent</a>
												</span>
                                                    </div>
                                                </td>
                                                <td colspan="2"></td>
                                                <td class="text-right hidden-xs">
                                                    <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/manage_dishes/1292" data-backdrop="static" data-keyboard="true" data-toggle="modal" data-target="#mod_manage_dishes" class="sort_dishes btn btn-default" data-course="1292">dish order</a>
                                                    <button type="submit" class="btn btn-primary ">
                                                        Update
                                                    </button>
                                                </td>
                                            </tr>
                                            </tfoot>
                                            <tbody>
                                                                                                                                                <tr class="sort" data-id="10170" style="" data-dish="MONDAY SPECIAL - Large Pepperoni Pizza" data-display_order="0">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/10170/1637/1" data-dish="10170" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="MONDAY SPECIAL - Large Pepperoni Pizza">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10170" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[10170]" value="MONDAY SPECIAL - Large Pepperoni Pizza" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[10170]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[10170]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[10170]" value="18.69" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[10170]" value="10170">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/10170/1637/1" data-dish="10170" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="MONDAY SPECIAL - Large Pepperoni Pizza">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10170" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="10171" style="" data-dish="TUESDAY SPECIAL - Medium Hawaiian Pizza" data-display_order="1">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/10171/1637/1" data-dish="10171" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="TUESDAY SPECIAL - Medium Hawaiian Pizza">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10171" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[10171]" value="TUESDAY SPECIAL - Medium Hawaiian Pizza" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[10171]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[10171]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[10171]" value="19.79" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[10171]" value="10171">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/10171/1637/1" data-dish="10171" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="TUESDAY SPECIAL - Medium Hawaiian Pizza">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10171" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="10172" style="" data-dish="WEDNESDAY SPECIAL - Medium Combination Pizza" data-display_order="2">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/10172/1637/1" data-dish="10172" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="WEDNESDAY SPECIAL - Medium Combination Pizza">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10172" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[10172]" value="WEDNESDAY SPECIAL - Medium Combination Pizza" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[10172]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[10172]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[10172]" value="18.69" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[10172]" value="10172">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/10172/1637/1" data-dish="10172" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="WEDNESDAY SPECIAL - Medium Combination Pizza">
                                                                    edit
                                                                </a>                                                           
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10172" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="10173" style="" data-dish="THURSDAY SPECIAL - Medium La Belle Pizza" data-display_order="3">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/10173/1637/1" data-dish="10173" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="THURSDAY SPECIAL - Medium La Belle Pizza">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10173" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[10173]" value="THURSDAY SPECIAL - Medium La Belle Pizza" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[10173]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[10173]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[10173]" value="19.79" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[10173]" value="10173">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/10173/1637/1" data-dish="10173" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="THURSDAY SPECIAL - Medium La Belle Pizza">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10173" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="10174" style="" data-dish="FRIDAY SPECIAL - Medium Vegetarian Pizza" data-display_order="4">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/10174/1637/1" data-dish="10174" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="FRIDAY SPECIAL - Medium Vegetarian Pizza">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10174" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[10174]" value="FRIDAY SPECIAL - Medium Vegetarian Pizza" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[10174]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[10174]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[10174]" value="19.79" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[10174]" value="10174">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/10174/1637/1" data-dish="10174" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="FRIDAY SPECIAL - Medium Vegetarian Pizza">
                                                                    edit
                                                                </a>                                                           
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10174" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="10175" style="" data-dish="SATURDAY SPECIAL - Medium Meat Lovers Pizza" data-display_order="5">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/10175/1637/1" data-dish="10175" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="SATURDAY SPECIAL - Medium Meat Lovers Pizza">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10175" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[10175]" value="SATURDAY SPECIAL - Medium Meat Lovers Pizza" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[10175]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[10175]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[10175]" value="19.79" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[10175]" value="10175">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/10175/1637/1" data-dish="10175" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="SATURDAY SPECIAL - Medium Meat Lovers Pizza">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10175" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="10176" style="" data-dish="SUNDAY SPECIAL - Medium Mexican Pizza" data-display_order="6">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/10176/1637/1" data-dish="10176" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="SUNDAY SPECIAL - Medium Mexican Pizza">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10176" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[10176]" value="SUNDAY SPECIAL - Medium Mexican Pizza" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[10176]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[10176]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[10176]" value="19.79" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[10176]" value="10176">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/10176/1637/1" data-dish="10176" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="SUNDAY SPECIAL - Medium Mexican Pizza">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10176" class="btn btn-danger remove_dish" title="disable dish">
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
                                            <div class="jarviswidget jarviswidget-color-darken course-listing jarviswidget-sortable" id="c_961" data-id="961" data-course="Pizza and Wings Deal" role="widget">
                            <header role="heading"><div class="jarviswidget-ctrls" role="menu">    <a href="javascript:void(0);" class="button-icon jarviswidget-toggle-btn" rel="tooltip" title="" data-placement="bottom" data-original-title="Collapse"><i class="fa fa-minus "></i></a>  </div>
                                <h2>
                                    <a href="#" class="rename" data-course-id="961" title="click to rename this course" style="color: #fff">
                                        Pizza and Wings Deal
                                    </a>
                                </h2>
                            <span class="jarviswidget-loader"><i class="fa fa-refresh fa-spin"></i></span></header>
                            <div id="course_961" class="widget-body" role="content">
                                                                <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_course_description" method="post" class="form_update_course">
                                    <input type="hidden" name="course_id" value="961">
                                    <div class="form-group">
                                        <label for="course_desc_961">course description</label>
                                        <div class="input-group input-group-sm">
                                            <textarea name="desc" id="course_desc_961" cols="1" rows="3" class="form-control"></textarea>
                                            <span class="input-group-btn">
										<button class="btn btn-primary">Update course description</button>
									</span>
                                        </div>
                                    </div>
                                </form>                                
                                                                <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_dishes" method="post" class="form_update_course">
                                    <div class="table-responsive">
                                        <input type="hidden" name="course" value="961">
                                        <table class="table table-bordered table-striped table-condensed show-dishes" id="table_961">
                                            <thead>
                                            <tr>
                                                <td colspan="3" class="text-right">
                                                                                                    </td>
                                                <td colspan="2" class="text-right">
                                                    <span class="form-control-static">course available for - if none chosen, course will not show: </span>&nbsp;
                                                                                                            <label class="checkbox-inline">
                                                            <input type="checkbox" name="available_for[1]" value="1" data-name="1" data-course="961" checked="">
                                                            Takeout
                                                        </label>
                                                                                                            <label class="checkbox-inline">
                                                            <input type="checkbox" name="available_for[2]" value="2" data-name="2" data-course="961" checked="">
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
                                                                <a href="#mod_add_dish" class="add-dish-modal" data-course="961" data-toggle="modal">
                                                                    regular dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showCreateCombo/961/1637" data-target="#mod_create_combo" data-toggle="modal" data-backdrop="static" data-keyboard="true" data-course="961">
                                                                    combo dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showImportDish/961/1637" data-target="#mod_import_dish" class="add-dish-modal" data-course="961" data-toggle="modal" data-backdrop="static" data-keyboard="true">
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
                                                                <a href="#mod_add_dish" class="add-dish-modal" data-course="961" data-toggle="modal">
                                                                    regular dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showCreateCombo/961/1637" data-target="#mod_create_combo" data-toggle="modal" data-backdrop="static" data-keyboard="true" data-course="961">
                                                                    combo dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showImportDish/961/1637" data-target="#mod_import_dish" class="add-dish-modal" data-course="961" data-toggle="modal" data-backdrop="static" data-keyboard="true">
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
                                                    <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/manage_dishes/961" data-backdrop="static" data-keyboard="true" data-toggle="modal" data-target="#mod_manage_dishes" class="sort_dishes btn btn-default" data-course="961">dish order</a>
                                                    <button type="submit" class="btn btn-primary ">
                                                        Update
                                                    </button>
                                                </td>
                                                <td colspan="2">
                                                    <div class="input-group">
												<span class="input-group-btn">
													<a href="#" data-update-type="value" class="btn btn-default update-prices">value</a>
												</span>
                                                        <input type="number" name="update_prices_by" id="update_prices_by_961" class="form-control update_prices_by" value="0" placeholder="update prices by" min="0" step="0.1">
                                                        <span class="input-group-btn">
													<a href="#" data-update-type="percent" class="btn btn-default update-prices">percent</a>
												</span>
                                                    </div>
                                                </td>
                                                <td colspan="2"></td>
                                                <td class="text-right hidden-xs">
                                                    <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/manage_dishes/961" data-backdrop="static" data-keyboard="true" data-toggle="modal" data-target="#mod_manage_dishes" class="sort_dishes btn btn-default" data-course="961">dish order</a>
                                                    <button type="submit" class="btn btn-primary ">
                                                        Update
                                                    </button>
                                                </td>
                                            </tr>
                                            </tfoot>
                                            <tbody>
                                                                                                                                                <tr class="sort" data-id="7809" style="" data-dish="2 Large Pizzas and Wings" data-display_order="0">
                                                        <td class="visible-xs">
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7809" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7809]" value="2 Large Pizzas and Wings" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7809]" value="2 large pizzas with 3 toppings, 40 wings, 6 drinks." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7809]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7809]" value="90.19" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7809]" value="7809">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_combo/7809/1637/1" data-dish="7809" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_create_combo" data-backdrop="static" data-keyboard="true" data-dishname="2 Large Pizzas and Wings">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7809" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7808" style="" data-dish="2 Medium Pizzas and Wings" data-display_order="0">
                                                        <td class="visible-xs">
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7808" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7808]" value="2 Medium Pizzas and Wings" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7808]" value="2 medium pizzas with 3 toppings, 30 wings, 4 drinks." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7808]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7808]" value="71.49" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7808]" value="7808">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_combo/7808/1637/1" data-dish="7808" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_create_combo" data-backdrop="static" data-keyboard="true" data-dishname="2 Medium Pizzas and Wings">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7808" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7807" style="" data-dish="2 Small Pizzas and Wings" data-display_order="0">
                                                        <td class="visible-xs">
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7807" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7807]" value="2 Small Pizzas and Wings" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7807]" value="2 small pizzas with 3 toppings, 20 wings, 4 drinks." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7807]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7807]" value="53.89" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7807]" value="7807">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_combo/7807/1637/1" data-dish="7807" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_create_combo" data-backdrop="static" data-keyboard="true" data-dishname="2 Small Pizzas and Wings">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7807" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7806" style="background-color: #a90329" data-dish="2 Small Pizzas 3 Toppings" data-display_order="0">
                                                        <td class="visible-xs">
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7806" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7806]" value="2 Small Pizzas 3 Toppings" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7806]" value="2 small pizzas with 3 toppings, 20 wings, 2 drinks." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7806]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7806]" value="51.70" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7806]" value="7806">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_combo/7806/1637/1" data-dish="7806" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_create_combo" data-backdrop="static" data-keyboard="true" data-dishname="2 Small Pizzas 3 Toppings">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7806" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7805" style="" data-dish="Large Pizza and Wings" data-display_order="0">
                                                        <td class="visible-xs">
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7805" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7805]" value="Large Pizza and Wings" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7805]" value="Large pizza 3 toppings, 20 wings, 3 dips, 4 drinks." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7805]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7805]" value="48.39" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7805]" value="7805">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_combo/7805/1637/1" data-dish="7805" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_create_combo" data-backdrop="static" data-keyboard="true" data-dishname="Large Pizza and Wings">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7805" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7804" style="" data-dish="Medium Pizza and Wings" data-display_order="0">
                                                        <td class="visible-xs">
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7804" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7804]" value="Medium Pizza and Wings" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7804]" value="Medium pizza 3 toppings, 15 wings, 2 dips, 3 drinks." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7804]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7804]" value="36.29" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7804]" value="7804">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_combo/7804/1637/1" data-dish="7804" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_create_combo" data-backdrop="static" data-keyboard="true" data-dishname="Medium Pizza and Wings">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7804" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7803" style="background-color: #a90329" data-dish="Medium Pizza 3 Toppings" data-display_order="0">
                                                        <td class="visible-xs">
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7803" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7803]" value="Medium Pizza 3 Toppings" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7803]" value="Medium pizza 3 toppings, 15 wings, 2 dips, 2 drinks." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7803]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7803]" value="34.10" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7803]" value="7803">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_combo/7803/1637/1" data-dish="7803" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_create_combo" data-backdrop="static" data-keyboard="true" data-dishname="Medium Pizza 3 Toppings">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7803" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7802" style="" data-dish="Small Pizza and Wings" data-display_order="0">
                                                        <td class="visible-xs">
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7802" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7802]" value="Small Pizza and Wings" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7802]" value="Small pizza 3 toppings, 12 wings, 1 dip, 2 drink." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7802]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7802]" value="29.69" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7802]" value="7802">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_combo/7802/1637/1" data-dish="7802" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_create_combo" data-backdrop="static" data-keyboard="true" data-dishname="Small Pizza and Wings">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7802" class="btn btn-danger remove_dish" title="disable dish">
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
                                            <div class="jarviswidget jarviswidget-color-darken course-listing jarviswidget-sortable" id="c_962" data-id="962" data-course="Specials" role="widget">
                            <header role="heading"><div class="jarviswidget-ctrls" role="menu">    <a href="javascript:void(0);" class="button-icon jarviswidget-toggle-btn" rel="tooltip" title="" data-placement="bottom" data-original-title="Collapse"><i class="fa fa-minus "></i></a>  </div>
                                <h2>
                                    <a href="#" class="rename" data-course-id="962" title="click to rename this course" style="color: #fff">
                                        Specials
                                    </a>
                                </h2>
                            <span class="jarviswidget-loader"><i class="fa fa-refresh fa-spin"></i></span></header>

                            <div id="course_962" class="widget-body" role="content">
                                                                <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_course_description" method="post" class="form_update_course">
                                    <input type="hidden" name="course_id" value="962">
                                    <div class="form-group">
                                        <label for="course_desc_962">course description</label>
                                        <div class="input-group input-group-sm">
                                            <textarea name="desc" id="course_desc_962" cols="1" rows="3" class="form-control"></textarea>
                                            <span class="input-group-btn">
										<button class="btn btn-primary">Update course description</button>
									</span>
                                        </div>
                                    </div>
                                </form>
                                
                                                                <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_dishes" method="post" class="form_update_course">
                                    <div class="table-responsive">
                                        <input type="hidden" name="course" value="962">
                                        <table class="table table-bordered table-striped table-condensed show-dishes" id="table_962">
                                            <thead>
                                            <tr>
                                                <td colspan="3" class="text-right">

                                                                                                    </td>
                                                <td colspan="2" class="text-right">
                                                    <span class="form-control-static">course available for - if none chosen, course will not show: </span>&nbsp;
                                                                                                            <label class="checkbox-inline">
                                                            <input type="checkbox" name="available_for[1]" value="1" data-name="1" data-course="962" checked="">
                                                            Takeout
                                                        </label>
                                                                                                            <label class="checkbox-inline">
                                                            <input type="checkbox" name="available_for[2]" value="2" data-name="2" data-course="962" checked="">
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
                                                                <a href="#mod_add_dish" class="add-dish-modal" data-course="962" data-toggle="modal">
                                                                    regular dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showCreateCombo/962/1637" data-target="#mod_create_combo" data-toggle="modal" data-backdrop="static" data-keyboard="true" data-course="962">
                                                                    combo dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showImportDish/962/1637" data-target="#mod_import_dish" class="add-dish-modal" data-course="962" data-toggle="modal" data-backdrop="static" data-keyboard="true">
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
                                                                <a href="#mod_add_dish" class="add-dish-modal" data-course="962" data-toggle="modal">
                                                                    regular dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showCreateCombo/962/1637" data-target="#mod_create_combo" data-toggle="modal" data-backdrop="static" data-keyboard="true" data-course="962">
                                                                    combo dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showImportDish/962/1637" data-target="#mod_import_dish" class="add-dish-modal" data-course="962" data-toggle="modal" data-backdrop="static" data-keyboard="true">
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
                                                    <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/manage_dishes/962" data-backdrop="static" data-keyboard="true" data-toggle="modal" data-target="#mod_manage_dishes" class="sort_dishes btn btn-default" data-course="962">dish order</a>
                                                    <button type="submit" class="btn btn-primary ">
                                                        Update
                                                    </button>
                                                </td>
                                                <td colspan="2">
                                                    <div class="input-group">
												<span class="input-group-btn">
													<a href="#" data-update-type="value" class="btn btn-default update-prices">value</a>
												</span>
                                                        <input type="number" name="update_prices_by" id="update_prices_by_962" class="form-control update_prices_by" value="0" placeholder="update prices by" min="0" step="0.1">
                                                        <span class="input-group-btn">
													<a href="#" data-update-type="percent" class="btn btn-default update-prices">percent</a>
												</span>
                                                    </div>
                                                </td>
                                                <td colspan="2"></td>
                                                <td class="text-right hidden-xs">
                                                    <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/manage_dishes/962" data-backdrop="static" data-keyboard="true" data-toggle="modal" data-target="#mod_manage_dishes" class="sort_dishes btn btn-default" data-course="962">dish order</a>
                                                    <button type="submit" class="btn btn-primary ">
                                                        Update
                                                    </button>
                                                </td>
                                            </tr>
                                            </tfoot>
                                            <tbody>
                                                                                                                                                <tr class="sort" data-id="7816" style="background-color: #a90329" data-dish="2 Wraps with Drink" data-display_order="1">
                                                        <td class="visible-xs">
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7816" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7816]" value="2 Wraps with Drink" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7816]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7816]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7816]" value="25.30" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7816]" value="7816">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_combo/7816/1637/1" data-dish="7816" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_create_combo" data-backdrop="static" data-keyboard="true" data-dishname="2 Wraps with Drink">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7816" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7815" style="background-color: #a90329" data-dish="2 Wraps with Drink" data-display_order="2">
                                                        <td class="visible-xs">
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7815" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7815]" value="2 Wraps with Drink" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7815]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7815]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7815]" value="25.30" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7815]" value="7815">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_combo/7815/1637/1" data-dish="7815" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_create_combo" data-backdrop="static" data-keyboard="true" data-dishname="2 Wraps with Drink">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7815" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7814" style="background-color: #a90329" data-dish="2 Subs with Drink" data-display_order="3">
                                                        <td class="visible-xs">
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7814" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7814]" value="2 Subs with Drink" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7814]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7814]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7814]" value="25.30" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7814]" value="7814">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_combo/7814/1637/1" data-dish="7814" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_create_combo" data-backdrop="static" data-keyboard="true" data-dishname="2 Subs with Drink">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7814" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7813" style="background-color: #a90329" data-dish="2 Subs with Drink" data-display_order="4">
                                                        <td class="visible-xs">
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7813" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7813]" value="2 Subs with Drink" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7813]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7813]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7813]" value="25.30" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7813]" value="7813">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_combo/7813/1637/1" data-dish="7813" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_create_combo" data-backdrop="static" data-keyboard="true" data-dishname="2 Subs with Drink">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7813" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7812" style="background-color: #a90329" data-dish="2 Subs with Drink" data-display_order="5">
                                                        <td class="visible-xs">
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7812" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7812]" value="2 Subs with Drink" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7812]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7812]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7812]" value="25.30" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7812]" value="7812">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_combo/7812/1637/1" data-dish="7812" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_create_combo" data-backdrop="static" data-keyboard="true" data-dishname="2 Subs with Drink">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7812" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7811" style="background-color: #a90329" data-dish="2 Subs with Drink" data-display_order="6">
                                                        <td class="visible-xs">
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7811" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7811]" value="2 Subs with Drink" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7811]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7811]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7811]" value="25.30" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7811]" value="7811">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_combo/7811/1637/1" data-dish="7811" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_create_combo" data-backdrop="static" data-keyboard="true" data-dishname="2 Subs with Drink">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7811" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7810" style="" data-dish="Perfect Party Deal" data-display_order="7">
                                                        <td class="visible-xs">
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7810" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7810]" value="Perfect Party Deal" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7810]" value="2 large pizzas with 4 toppings each, 50 wings, large PopCurds, 6 dips, 4 drinks." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7810]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7810]" value="109.99" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7810]" value="7810">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_combo/7810/1637/1" data-dish="7810" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_create_combo" data-backdrop="static" data-keyboard="true" data-dishname="Perfect Party Deal">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7810" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7817" style="background-color: #a90329" data-dish="2 Large Poutine with 1 Drink" data-display_order="8">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7817/1637/1" data-dish="7817" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="2 Large Poutine with 1 Drink">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7817" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7817]" value="2 Large Poutine with 1 Drink" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7817]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7817]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7817]" value="25.30" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7817]" value="7817">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7817/1637/1" data-dish="7817" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="2 Large Poutine with 1 Drink">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7817" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                        </tbody>
                                        </table>
                                    </div>
                                </form>
                                                            </div>
                        </div>
                                            <div class="jarviswidget jarviswidget-color-darken course-listing jarviswidget-sortable" id="c_960" data-id="960" data-course="2 For 1 Pizza Deal" role="widget">
                            <header role="heading"><div class="jarviswidget-ctrls" role="menu">    <a href="javascript:void(0);" class="button-icon jarviswidget-toggle-btn" rel="tooltip" title="" data-placement="bottom" data-original-title="Collapse"><i class="fa fa-minus "></i></a>  </div>
                                <h2>
                                    <a href="#" class="rename" data-course-id="960" title="click to rename this course" style="color: #fff">
                                        2 For 1 Pizza Deal
                                    </a>
                                </h2>
                            <span class="jarviswidget-loader"><i class="fa fa-refresh fa-spin"></i></span></header>

                            <div id="course_960" class="widget-body" role="content">
                                                                <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_course_description" method="post" class="form_update_course">
                                    <input type="hidden" name="course_id" value="960">
                                    <div class="form-group">
                                        <label for="course_desc_960">course description</label>
                                        <div class="input-group input-group-sm">
                                            <textarea name="desc" id="course_desc_960" cols="1" rows="3" class="form-control">Comes with 2 dipping sauces and 2 drinks.</textarea>
                                            <span class="input-group-btn">
										<button class="btn btn-primary">Update course description</button>
									</span>
                                        </div>
                                    </div>
                                </form>
                                
                                                                <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_dishes" method="post" class="form_update_course">
                                    <div class="table-responsive">
                                        <input type="hidden" name="course" value="960">
                                        <table class="table table-bordered table-striped table-condensed show-dishes" id="table_960">
                                            <thead>
                                            <tr>
                                                <td colspan="3" class="text-right">

                                                                                                    </td>
                                                <td colspan="2" class="text-right">
                                                    <span class="form-control-static">course available for - if none chosen, course will not show: </span>&nbsp;
                                                                                                            <label class="checkbox-inline">
                                                            <input type="checkbox" name="available_for[1]" value="1" data-name="1" data-course="960" checked="">
                                                            Takeout
                                                        </label>
                                                                                                            <label class="checkbox-inline">
                                                            <input type="checkbox" name="available_for[2]" value="2" data-name="2" data-course="960" checked="">
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
                                                                <a href="#mod_add_dish" class="add-dish-modal" data-course="960" data-toggle="modal">
                                                                    regular dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showCreateCombo/960/1637" data-target="#mod_create_combo" data-toggle="modal" data-backdrop="static" data-keyboard="true" data-course="960">
                                                                    combo dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showImportDish/960/1637" data-target="#mod_import_dish" class="add-dish-modal" data-course="960" data-toggle="modal" data-backdrop="static" data-keyboard="true">
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
                                                                <a href="#mod_add_dish" class="add-dish-modal" data-course="960" data-toggle="modal">
                                                                    regular dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showCreateCombo/960/1637" data-target="#mod_create_combo" data-toggle="modal" data-backdrop="static" data-keyboard="true" data-course="960">
                                                                    combo dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showImportDish/960/1637" data-target="#mod_import_dish" class="add-dish-modal" data-course="960" data-toggle="modal" data-backdrop="static" data-keyboard="true">
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
                                                    <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/manage_dishes/960" data-backdrop="static" data-keyboard="true" data-toggle="modal" data-target="#mod_manage_dishes" class="sort_dishes btn btn-default" data-course="960">dish order</a>
                                                    <button type="submit" class="btn btn-primary ">
                                                        Update
                                                    </button>
                                                </td>
                                                <td colspan="2">
                                                    <div class="input-group">
												<span class="input-group-btn">
													<a href="#" data-update-type="value" class="btn btn-default update-prices">value</a>
												</span>
                                                        <input type="number" name="update_prices_by" id="update_prices_by_960" class="form-control update_prices_by" value="0" placeholder="update prices by" min="0" step="0.1">
                                                        <span class="input-group-btn">
													<a href="#" data-update-type="percent" class="btn btn-default update-prices">percent</a>
												</span>
                                                    </div>
                                                </td>
                                                <td colspan="2"></td>
                                                <td class="text-right hidden-xs">
                                                    <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/manage_dishes/960" data-backdrop="static" data-keyboard="true" data-toggle="modal" data-target="#mod_manage_dishes" class="sort_dishes btn btn-default" data-course="960">dish order</a>
                                                    <button type="submit" class="btn btn-primary ">
                                                        Update
                                                    </button>
                                                </td>
                                            </tr>
                                            </tfoot>
                                            <tbody>
                                                                                                                                                <tr class="sort" data-id="7799" style="" data-dish="1 Topping Pizzas" data-display_order="1">
                                                        <td class="visible-xs">
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7799" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7799]" value="1 Topping Pizzas" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7799]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7799]" value="2 x Small,2 x Medium,2 x Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7799]" value="26.40,34.10,40.70" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7799]" value="7799">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_combo/7799/1637/1" data-dish="7799" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_create_combo" data-backdrop="static" data-keyboard="true" data-dishname="1 Topping Pizzas">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7799" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7800" style="" data-dish="2 Toppings Pizzas" data-display_order="2">
                                                        <td class="visible-xs">
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7800" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7800]" value="2 Toppings Pizzas" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7800]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7800]" value="2 x Small,2 x Medium,2 x Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7800]" value="29.70,37.40,45.10" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7800]" value="7800">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_combo/7800/1637/1" data-dish="7800" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_create_combo" data-backdrop="static" data-keyboard="true" data-dishname="2 Toppings Pizzas">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7800" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7801" style="" data-dish="3 Toppings Pizzas" data-display_order="3">
                                                        <td class="visible-xs">
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7801" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7801]" value="3 Toppings Pizzas" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7801]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7801]" value="2 x Small,2 x Medium,2 x Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7801]" value="31.90,41.80,49.50" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7801]" value="7801">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_combo/7801/1637/1" data-dish="7801" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_create_combo" data-backdrop="static" data-keyboard="true" data-dishname="3 Toppings Pizzas">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7801" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7798" style="background-color: #a90329" data-dish="test" data-display_order="4">
                                                        <td class="visible-xs">
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7798" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7798]" value="test" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7798]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7798]" value="2 x Small,2 x Medium,2 x Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7798]" value="17.38,26.13,31.96" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7798]" value="7798">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_combo/7798/1637/1" data-dish="7798" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_create_combo" data-backdrop="static" data-keyboard="true" data-dishname="test">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7798" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7797" style="background-color: #a90329" data-dish="3 Toppings Pizzas" data-display_order="5">
                                                        <td class="visible-xs">
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7797" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7797]" value="3 Toppings Pizzas" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7797]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7797]" value="2 x Small,2 x Medium,2 x Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7797]" value="27.50,38.50,45.10" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7797]" value="7797">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_combo/7797/1637/1" data-dish="7797" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_create_combo" data-backdrop="static" data-keyboard="true" data-dishname="3 Toppings Pizzas">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7797" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7796" style="background-color: #a90329" data-dish="2 Toppings Pizzas" data-display_order="6">
                                                        <td class="visible-xs">
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7796" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7796]" value="2 Toppings Pizzas" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7796]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7796]" value="2 x Small,2 x Medium,2 x Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7796]" value="26.40,34.10,40.70" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7796]" value="7796">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_combo/7796/1637/1" data-dish="7796" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_create_combo" data-backdrop="static" data-keyboard="true" data-dishname="2 Toppings Pizzas">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7796" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7795" style="background-color: #a90329" data-dish="2 Toppings Pizzas" data-display_order="7">
                                                        <td class="visible-xs">
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7795" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7795]" value="2 Toppings Pizzas" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7795]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7795]" value="2 x Small,2 x Medium,2 x Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7795]" value="26.40,34.10,40.70" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7795]" value="7795">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_combo/7795/1637/1" data-dish="7795" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_create_combo" data-backdrop="static" data-keyboard="true" data-dishname="2 Toppings Pizzas">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7795" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7794" style="background-color: #a90329" data-dish="2 Toppings Pizzas" data-display_order="8">
                                                        <td class="visible-xs">
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7794" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7794]" value="2 Toppings Pizzas" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7794]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7794]" value="2 x Small,2 x Medium,2 x Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7794]" value="26.40,34.10,40.70" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7794]" value="7794">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_combo/7794/1637/1" data-dish="7794" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_create_combo" data-backdrop="static" data-keyboard="true" data-dishname="2 Toppings Pizzas">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7794" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7793" style="background-color: #a90329" data-dish="1 Topping Pizzas" data-display_order="9">
                                                        <td class="visible-xs">
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7793" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7793]" value="1 Topping Pizzas" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7793]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7793]" value="2 x Small,2 x Medium,2 x Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7793]" value="24.20,30.80,37.40" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7793]" value="7793">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_combo/7793/1637/1" data-dish="7793" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_create_combo" data-backdrop="static" data-keyboard="true" data-dishname="1 Topping Pizzas">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7793" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7792" style="background-color: #a90329" data-dish="1 Topping" data-display_order="10">
                                                        <td class="visible-xs">
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7792" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7792]" value="1 Topping" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7792]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7792]" value="Small,Medium,Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7792]" value="24.20,30.80,37.40" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7792]" value="7792">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_combo/7792/1637/1" data-dish="7792" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_create_combo" data-backdrop="static" data-keyboard="true" data-dishname="1 Topping">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7792" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                        </tbody>
                                        </table>
                                    </div>
                                </form>
                                                            </div>
                        </div>
                                            <div class="jarviswidget jarviswidget-color-darken course-listing jarviswidget-sortable" id="c_957" data-id="957" data-course="Pizza" role="widget">
                            <header role="heading"><div class="jarviswidget-ctrls" role="menu">    <a href="javascript:void(0);" class="button-icon jarviswidget-toggle-btn" rel="tooltip" title="" data-placement="bottom" data-original-title="Collapse"><i class="fa fa-minus "></i></a>  </div>
                                <h2>
                                    <a href="#" class="rename" data-course-id="957" title="click to rename this course" style="color: #fff">
                                        Pizza
                                    </a>
                                </h2>
                            <span class="jarviswidget-loader"><i class="fa fa-refresh fa-spin"></i></span></header>

                            <div id="course_957" class="widget-body" role="content">
                                                                <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_course_description" method="post" class="form_update_course">
                                    <input type="hidden" name="course_id" value="957">
                                    <div class="form-group">
                                        <label for="course_desc_957">course description</label>
                                        <div class="input-group input-group-sm">
                                            <textarea name="desc" id="course_desc_957" cols="1" rows="3" class="form-control"></textarea>
                                            <span class="input-group-btn">
										<button class="btn btn-primary">Update course description</button>
									</span>
                                        </div>
                                    </div>
                                </form>
                                
                                                                <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_dishes" method="post" class="form_update_course">
                                    <div class="table-responsive">
                                        <input type="hidden" name="course" value="957">
                                        <table class="table table-bordered table-striped table-condensed show-dishes" id="table_957">
                                            <thead>
                                            <tr>
                                                <td colspan="3" class="text-right">

                                                                                                    </td>
                                                <td colspan="2" class="text-right">
                                                    <span class="form-control-static">course available for - if none chosen, course will not show: </span>&nbsp;
                                                                                                            <label class="checkbox-inline">
                                                            <input type="checkbox" name="available_for[1]" value="1" data-name="1" data-course="957" checked="">
                                                            Takeout
                                                        </label>
                                                                                                            <label class="checkbox-inline">
                                                            <input type="checkbox" name="available_for[2]" value="2" data-name="2" data-course="957" checked="">
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
                                                                <a href="#mod_add_dish" class="add-dish-modal" data-course="957" data-toggle="modal">
                                                                    regular dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showCreateCombo/957/1637" data-target="#mod_create_combo" data-toggle="modal" data-backdrop="static" data-keyboard="true" data-course="957">
                                                                    combo dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showImportDish/957/1637" data-target="#mod_import_dish" class="add-dish-modal" data-course="957" data-toggle="modal" data-backdrop="static" data-keyboard="true">
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
                                                                <a href="#mod_add_dish" class="add-dish-modal" data-course="957" data-toggle="modal">
                                                                    regular dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showCreateCombo/957/1637" data-target="#mod_create_combo" data-toggle="modal" data-backdrop="static" data-keyboard="true" data-course="957">
                                                                    combo dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showImportDish/957/1637" data-target="#mod_import_dish" class="add-dish-modal" data-course="957" data-toggle="modal" data-backdrop="static" data-keyboard="true">
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
                                                    <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/manage_dishes/957" data-backdrop="static" data-keyboard="true" data-toggle="modal" data-target="#mod_manage_dishes" class="sort_dishes btn btn-default" data-course="957">dish order</a>
                                                    <button type="submit" class="btn btn-primary ">
                                                        Update
                                                    </button>
                                                </td>
                                                <td colspan="2">
                                                    <div class="input-group">
												<span class="input-group-btn">
													<a href="#" data-update-type="value" class="btn btn-default update-prices">value</a>
												</span>
                                                        <input type="number" name="update_prices_by" id="update_prices_by_957" class="form-control update_prices_by" value="0" placeholder="update prices by" min="0" step="0.1">
                                                        <span class="input-group-btn">
													<a href="#" data-update-type="percent" class="btn btn-default update-prices">percent</a>
												</span>
                                                    </div>
                                                </td>
                                                <td colspan="2"></td>
                                                <td class="text-right hidden-xs">
                                                    <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/manage_dishes/957" data-backdrop="static" data-keyboard="true" data-toggle="modal" data-target="#mod_manage_dishes" class="sort_dishes btn btn-default" data-course="957">dish order</a>
                                                    <button type="submit" class="btn btn-primary ">
                                                        Update
                                                    </button>
                                                </td>
                                            </tr>
                                            </tfoot>
                                            <tbody>
                                                                                                                                                <tr class="sort" data-id="7748" style="" data-dish="Cheese Pizza" data-display_order="1">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7748/1637/1" data-dish="7748" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Cheese Pizza">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7748" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7748]" value="Cheese Pizza" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7748]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7748]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7748]" value="13.19,16.49,18.69,20.89" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7748]" value="7748">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7748/1637/1" data-dish="7748" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Cheese Pizza">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7748" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7749" style="" data-dish="Pepperoni Pizza" data-display_order="2">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7749/1637/1" data-dish="7749" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Pepperoni Pizza">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7749" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7749]" value="Pepperoni Pizza" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7749]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7749]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7749]" value="14.29,20.89,23.09,26.39" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7749]" value="7749">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7749/1637/1" data-dish="7749" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Pepperoni Pizza">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7749" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7766" style="" data-dish="Mexican Pizza" data-display_order="3">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7766/1637/1" data-dish="7766" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Mexican Pizza">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7766" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7766]" value="Mexican Pizza" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7766]" value="Ground beef, black olives, hot peppers, onions." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7766]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7766]" value="16.49,27.49,31.89,36.29" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7766]" value="7766">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7766/1637/1" data-dish="7766" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Mexican Pizza">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7766" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7767" style="" data-dish="Donair Pizza" data-display_order="4">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7767/1637/1" data-dish="7767" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Donair Pizza">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7767" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7767]" value="Donair Pizza" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7767]" value="Mushrooms, green peppers, onions, donair" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7767]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7767]" value="16.49,27.49,31.89,36.29" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7767]" value="7767">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7767/1637/1" data-dish="7767" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Donair Pizza">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7767" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7750" style="" data-dish="Combination Pizza" data-display_order="5">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7750/1637/1" data-dish="7750" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Combination Pizza">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7750" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7750]" value="Combination Pizza" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7750]" value="Pepperoni, mushrooms, green peppers." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7750]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7750]" value="16.49,26.39,30.79,34.09" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7750]" value="7750">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7750/1637/1" data-dish="7750" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Combination Pizza">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7750" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7751" style="" data-dish="Combination with Olives" data-display_order="6">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7751/1637/1" data-dish="7751" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Combination with Olives">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7751" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7751]" value="Combination with Olives" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7751]" value="Pepperoni, mushrooms, green peppers, olives." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7751]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7751]" value="16.49,27.49,31.89,36.29" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7751]" value="7751">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7751/1637/1" data-dish="7751" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Combination with Olives">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7751" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7752" style="" data-dish="Canadian Pizza" data-display_order="7">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7752/1637/1" data-dish="7752" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Canadian Pizza">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7752" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7752]" value="Canadian Pizza" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7752]" value="Pepperoni, mushrooms, bacon, double cheese." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7752]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7752]" value="17.59,27.49,31.89,36.29" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7752]" value="7752">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7752/1637/1" data-dish="7752" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Canadian Pizza">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7752" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7753" style="" data-dish="Meat Lovers Pizza" data-display_order="8">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7753/1637/1" data-dish="7753" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Meat Lovers Pizza">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7753" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7753]" value="Meat Lovers Pizza" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7753]" value="Pepperoni, salami, Italian sausage, bacon." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7753]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7753]" value="17.59,27.49,31.89,36.29" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7753]" value="7753">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7753/1637/1" data-dish="7753" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Meat Lovers Pizza">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7753" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7754" style="" data-dish="Pizza Lovers Pizza" data-display_order="9">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7754/1637/1" data-dish="7754" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Pizza Lovers Pizza">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7754" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7754]" value="Pizza Lovers Pizza" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7754]" value="Pepperoni, green peppers, onions, hot peppers, bacon." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7754]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7754]" value="17.59,27.49,31.89,36.29" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7754]" value="7754">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7754/1637/1" data-dish="7754" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Pizza Lovers Pizza">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7754" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7755" style="" data-dish="Hawaiian Pizza" data-display_order="10">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7755/1637/1" data-dish="7755" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Hawaiian Pizza">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7755" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7755]" value="Hawaiian Pizza" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7755]" value="Ham, pineapple." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7755]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7755]" value="16.49,26.39,30.79,34.09" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7755]" value="7755">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7755/1637/1" data-dish="7755" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Hawaiian Pizza">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7755" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7758" style="" data-dish="La Belle Pizza" data-display_order="11">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7758/1637/1" data-dish="7758" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="La Belle Pizza">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7758" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7758]" value="La Belle Pizza" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7758]" value="Pepperoni, bacon, green olives." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7758]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7758]" value="17.59,27.49,31.89,36.29" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7758]" value="7758">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7758/1637/1" data-dish="7758" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="La Belle Pizza">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7758" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7760" style="" data-dish="Kirkwood Extreme Pizza" data-display_order="12">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7760/1637/1" data-dish="7760" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Kirkwood Extreme Pizza">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7760" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7760]" value="Kirkwood Extreme Pizza" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7760]" value="Pepperoni, mushrooms, green peppers, onions, bacon, Italian sausage, ground beef." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7760]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7760]" value="18.69,28.59,34.09,38.49" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7760]" value="7760">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7760/1637/1" data-dish="7760" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Kirkwood Extreme Pizza">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7760" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7761" style="" data-dish="House Special Pizza" data-display_order="13">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7761/1637/1" data-dish="7761" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="House Special Pizza">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7761" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7761]" value="House Special Pizza" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7761]" value="Pepperoni, mushrooms, green peppers, onions, green olives, bacon." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7761]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7761]" value="17.59,27.49,31.89,36.29" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7761]" value="7761">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7761/1637/1" data-dish="7761" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="House Special Pizza">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7761" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7762" style="" data-dish="House Favourite Pizza" data-display_order="14">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7762/1637/1" data-dish="7762" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="House Favourite Pizza">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7762" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7762]" value="House Favourite Pizza" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7762]" value="Pepperoni, mushrooms, green peppers, onions, tomatoes." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7762]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7762]" value="17.59,27.49,31.89,36.29" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7762]" value="7762">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7762/1637/1" data-dish="7762" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="House Favourite Pizza">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7762" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7763" style="" data-dish="Steak Pizza" data-display_order="15">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7763/1637/1" data-dish="7763" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Steak Pizza">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7763" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7763]" value="Steak Pizza" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7763]" value="Mushrooms, green peppers, onions, steak." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7763]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7763]" value="17.59,27.49,31.89,36.29" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7763]" value="7763">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7763/1637/1" data-dish="7763" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Steak Pizza">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7763" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7764" style="" data-dish="BBQ Chicken Pizza" data-display_order="16">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7764/1637/1" data-dish="7764" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="BBQ Chicken Pizza">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7764" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7764]" value="BBQ Chicken Pizza" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7764]" value="Green peppers, onions, chicken &amp; BBQ sauce drizzle." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7764]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7764]" value="17.59,27.49,31.89,36.29" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7764]" value="7764">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7764/1637/1" data-dish="7764" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="BBQ Chicken Pizza">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7764" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7768" style="" data-dish="Shawarma Pizza" data-display_order="17">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7768/1637/1" data-dish="7768" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Shawarma Pizza">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7768" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7768]" value="Shawarma Pizza" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7768]" value="Garlic sauce, chicken, onions, tomatoes." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7768]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7768]" value="17.59,27.49,31.89,36.29" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7768]" value="7768">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7768/1637/1" data-dish="7768" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Shawarma Pizza">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7768" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7769" style="" data-dish="Ottawa Pizza" data-display_order="18">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7769/1637/1" data-dish="7769" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Ottawa Pizza">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7769" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7769]" value="Ottawa Pizza" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7769]" value="Pepperoni, bacon, Pancetta, all meats diced and placed on top of the pizza." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7769]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7769]" value="17.59,27.49,31.89,36.29" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7769]" value="7769">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7769/1637/1" data-dish="7769" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Ottawa Pizza">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7769" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7772" style="" data-dish="Greek Pizza" data-display_order="19">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7772/1637/1" data-dish="7772" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Greek Pizza">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7772" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7772]" value="Greek Pizza" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7772]" value="Feta cheese, green peppers, onions, black olives, hot peppers, tomatoes." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7772]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7772]" value="17.59,27.49,32.99,37.39" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7772]" value="7772">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7772/1637/1" data-dish="7772" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Greek Pizza">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7772" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7773" style="" data-dish="Mediterranean Pizza" data-display_order="20">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7773/1637/1" data-dish="7773" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Mediterranean Pizza">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7773" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7773]" value="Mediterranean Pizza" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7773]" value="Feta cheese, green peppers, onions, black olives, tomatoes." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7773]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7773]" value="17.59,27.49,32.99,37.39" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7773]" value="7773">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7773/1637/1" data-dish="7773" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Mediterranean Pizza">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7773" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7774" style="" data-dish="Vegetarian Pizza" data-display_order="21">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7774/1637/1" data-dish="7774" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Vegetarian Pizza">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7774" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7774]" value="Vegetarian Pizza" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7774]" value="Mushrooms, green peppers, olives, onions, tomatoes." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7774]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7774]" value="17.59,27.49,32.99,37.39" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7774]" value="7774">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7774/1637/1" data-dish="7774" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Vegetarian Pizza">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7774" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7756" style="background-color: #a90329" data-dish="Hawaiian Plus N/A" data-display_order="22">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7756/1637/1" data-dish="7756" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Hawaiian Plus N/A">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7756" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7756]" value="Hawaiian Plus N/A" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7756]" value="Ham, pineapple, bacon, green olives." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7756]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7756]" value="15.39,24.19,29.69,32.99" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7756]" value="7756">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7756/1637/1" data-dish="7756" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Hawaiian Plus N/A">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7756" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7757" style="background-color: #a90329" data-dish="Pineapple Express N/A" data-display_order="23">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7757/1637/1" data-dish="7757" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Pineapple Express N/A">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7757" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7757]" value="Pineapple Express N/A" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7757]" value="Jalapeno peppers, Italian sausage, pineapple." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7757]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7757]" value="15.39,24.19,29.69,32.99" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7757]" value="7757">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7757/1637/1" data-dish="7757" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Pineapple Express N/A">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7757" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7759" style="background-color: #a90329" data-dish="Meatsa Pizza N/A" data-display_order="24">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7759/1637/1" data-dish="7759" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Meatsa Pizza N/A">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7759" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7759]" value="Meatsa Pizza N/A" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7759]" value="Pepperoni, ham, Italian sausage, bacon." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7759]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7759]" value="15.39,24.19,29.69,32.99" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7759]" value="7759">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7759/1637/1" data-dish="7759" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Meatsa Pizza N/A">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7759" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7765" style="background-color: #a90329" data-dish="BBQ Chicken &amp; Bacon Pizza N/A" data-display_order="25">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7765/1637/1" data-dish="7765" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="BBQ Chicken &amp; Bacon Pizza N/A">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7765" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7765]" value="BBQ Chicken &amp; Bacon Pizza N/A" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7765]" value="Green peppers, onions, chicken, bacon &amp; BBQ sauce drizzle." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7765]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7765]" value="15.39,24.19,29.69,32.99" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7765]" value="7765">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7765/1637/1" data-dish="7765" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="BBQ Chicken &amp; Bacon Pizza N/A">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7765" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7770" style="background-color: #a90329" data-dish="Italian Pizza N/A" data-display_order="26">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7770/1637/1" data-dish="7770" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Italian Pizza N/A">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7770" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7770]" value="Italian Pizza N/A" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7770]" value="Pepperoni, Italian sausage, Pancetta." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7770]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7770]" value="15.39,24.19,29.69,32.99" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7770]" value="7770">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7770/1637/1" data-dish="7770" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Italian Pizza N/A">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7770" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7771" style="background-color: #a90329" data-dish="Sweet &amp; Spicy Pizza N/A" data-display_order="27">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7771/1637/1" data-dish="7771" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Sweet &amp; Spicy Pizza N/A">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7771" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7771]" value="Sweet &amp; Spicy Pizza N/A" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7771]" value="Pancetta, pineapple, hot peppers, crushed chillies." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7771]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7771]" value="15.39,24.19,29.69,32.99" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7771]" value="7771">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7771/1637/1" data-dish="7771" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Sweet &amp; Spicy Pizza N/A">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7771" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7775" style="background-color: #a90329" data-dish="Veggie Extreme Pizza N/A" data-display_order="28">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7775/1637/1" data-dish="7775" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Veggie Extreme Pizza N/A">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7775" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7775]" value="Veggie Extreme Pizza N/A" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7775]" value="Mushrooms, broccoli, onions, tomatoes, sliced zucchini, spinach." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7775]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7775]" value="16.49,26.39,31.89,36.29" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7775]" value="7775">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7775/1637/1" data-dish="7775" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Veggie Extreme Pizza N/A">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7775" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                        </tbody>
                                        </table>
                                    </div>
                                </form>
                                                            </div>
                        </div>
                                            <div class="jarviswidget jarviswidget-color-darken course-listing jarviswidget-sortable" id="c_952" data-id="952" data-course="Appetizers" role="widget">
                            <header role="heading"><div class="jarviswidget-ctrls" role="menu">    <a href="javascript:void(0);" class="button-icon jarviswidget-toggle-btn" rel="tooltip" title="" data-placement="bottom" data-original-title="Collapse"><i class="fa fa-minus "></i></a>  </div>
                                <h2>
                                    <a href="#" class="rename" data-course-id="952" title="click to rename this course" style="color: #fff">
                                        Appetizers
                                    </a>
                                </h2>
                            <span class="jarviswidget-loader"><i class="fa fa-refresh fa-spin"></i></span></header>

                            <div id="course_952" class="widget-body" role="content">
                                                                <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_course_description" method="post" class="form_update_course">
                                    <input type="hidden" name="course_id" value="952">
                                    <div class="form-group">
                                        <label for="course_desc_952">course description</label>
                                        <div class="input-group input-group-sm">
                                            <textarea name="desc" id="course_desc_952" cols="1" rows="3" class="form-control"></textarea>
                                            <span class="input-group-btn">
										<button class="btn btn-primary">Update course description</button>
									</span>
                                        </div>
                                    </div>
                                </form>
                                
                                                                <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_dishes" method="post" class="form_update_course">
                                    <div class="table-responsive">
                                        <input type="hidden" name="course" value="952">
                                        <table class="table table-bordered table-striped table-condensed show-dishes" id="table_952">
                                            <thead>
                                            <tr>
                                                <td colspan="3" class="text-right">

                                                                                                    </td>
                                                <td colspan="2" class="text-right">
                                                    <span class="form-control-static">course available for - if none chosen, course will not show: </span>&nbsp;
                                                                                                            <label class="checkbox-inline">
                                                            <input type="checkbox" name="available_for[1]" value="1" data-name="1" data-course="952" checked="">
                                                            Takeout
                                                        </label>
                                                                                                            <label class="checkbox-inline">
                                                            <input type="checkbox" name="available_for[2]" value="2" data-name="2" data-course="952" checked="">
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
                                                                <a href="#mod_add_dish" class="add-dish-modal" data-course="952" data-toggle="modal">
                                                                    regular dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showCreateCombo/952/1637" data-target="#mod_create_combo" data-toggle="modal" data-backdrop="static" data-keyboard="true" data-course="952">
                                                                    combo dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showImportDish/952/1637" data-target="#mod_import_dish" class="add-dish-modal" data-course="952" data-toggle="modal" data-backdrop="static" data-keyboard="true">
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
                                                                <a href="#mod_add_dish" class="add-dish-modal" data-course="952" data-toggle="modal">
                                                                    regular dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showCreateCombo/952/1637" data-target="#mod_create_combo" data-toggle="modal" data-backdrop="static" data-keyboard="true" data-course="952">
                                                                    combo dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showImportDish/952/1637" data-target="#mod_import_dish" class="add-dish-modal" data-course="952" data-toggle="modal" data-backdrop="static" data-keyboard="true">
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
                                                    <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/manage_dishes/952" data-backdrop="static" data-keyboard="true" data-toggle="modal" data-target="#mod_manage_dishes" class="sort_dishes btn btn-default" data-course="952">dish order</a>
                                                    <button type="submit" class="btn btn-primary ">
                                                        Update
                                                    </button>
                                                </td>
                                                <td colspan="2">
                                                    <div class="input-group">
												<span class="input-group-btn">
													<a href="#" data-update-type="value" class="btn btn-default update-prices">value</a>
												</span>
                                                        <input type="number" name="update_prices_by" id="update_prices_by_952" class="form-control update_prices_by" value="0" placeholder="update prices by" min="0" step="0.1">
                                                        <span class="input-group-btn">
													<a href="#" data-update-type="percent" class="btn btn-default update-prices">percent</a>
												</span>
                                                    </div>
                                                </td>
                                                <td colspan="2"></td>
                                                <td class="text-right hidden-xs">
                                                    <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/manage_dishes/952" data-backdrop="static" data-keyboard="true" data-toggle="modal" data-target="#mod_manage_dishes" class="sort_dishes btn btn-default" data-course="952">dish order</a>
                                                    <button type="submit" class="btn btn-primary ">
                                                        Update
                                                    </button>
                                                </td>
                                            </tr>
                                            </tfoot>
                                            <tbody>
                                                                                                                                                <tr class="sort" data-id="7693" style="" data-dish="PopCurds" data-display_order="0">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7693/1637/1" data-dish="7693" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="PopCurds">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7693" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7693]" value="PopCurds" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7693]" value="Deep Fries breaded St.Alberts cheese curds." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7693]" value="Small,Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7693]" value="13.19,23.09" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7693]" value="7693">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7693/1637/1" data-dish="7693" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="PopCurds">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7693" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7694" style="" data-dish="Jalapeno Slammers (6 pcs)" data-display_order="1">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7694/1637/1" data-dish="7694" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Jalapeno Slammers (6 pcs)">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7694" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7694]" value="Jalapeno Slammers (6 pcs)" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7694]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7694]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7694]" value="12.09" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7694]" value="7694">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7694/1637/1" data-dish="7694" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Jalapeno Slammers (6 pcs)">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7694" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7695" style="" data-dish="Mozzarella Cheese Sticks (8 pcs)" data-display_order="2">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7695/1637/1" data-dish="7695" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Mozzarella Cheese Sticks (8 pcs)">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7695" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7695]" value="Mozzarella Cheese Sticks (8 pcs)" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7695]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7695]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7695]" value="12.09" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7695]" value="7695">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7695/1637/1" data-dish="7695" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Mozzarella Cheese Sticks (8 pcs)">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7695" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7696" style="" data-dish="Zucchini Sticks" data-display_order="3">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7696/1637/1" data-dish="7696" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Zucchini Sticks">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7696" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7696]" value="Zucchini Sticks" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7696]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7696]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7696]" value="13.19" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7696]" value="7696">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7696/1637/1" data-dish="7696" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Zucchini Sticks">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7696" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7697" style="" data-dish="Breaded Dill Pickles" data-display_order="4">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7697/1637/1" data-dish="7697" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Breaded Dill Pickles">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7697" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7697]" value="Breaded Dill Pickles" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7697]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7697]" value="5 pcs,10 pcs" class="form-control size"></td>
                                                        <td><input type="text" name="price[7697]" value="8.79,13.19" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7697]" value="7697">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7697/1637/1" data-dish="7697" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Breaded Dill Pickles">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7697" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7698" style="" data-dish="Garlic Bread" data-display_order="5">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7698/1637/1" data-dish="7698" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Garlic Bread">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7698" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7698]" value="Garlic Bread" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7698]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7698]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7698]" value="8.79" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7698]" value="7698">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7698/1637/1" data-dish="7698" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Garlic Bread">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7698" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7699" style="" data-dish="Garlic Cheese Bread" data-display_order="6">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7699/1637/1" data-dish="7699" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Garlic Cheese Bread">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7699" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7699]" value="Garlic Cheese Bread" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7699]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7699]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7699]" value="10.99" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7699]" value="7699">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7699/1637/1" data-dish="7699" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Garlic Cheese Bread">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7699" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7700" style="" data-dish="Garlic Cheese Bread with Bacon" data-display_order="7">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7700/1637/1" data-dish="7700" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Garlic Cheese Bread with Bacon">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7700" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7700]" value="Garlic Cheese Bread with Bacon" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7700]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7700]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7700]" value="12.09" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7700]" value="7700">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7700/1637/1" data-dish="7700" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Garlic Cheese Bread with Bacon">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7700" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7701" style="" data-dish="Nachos" data-display_order="8">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7701/1637/1" data-dish="7701" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Nachos">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7701" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7701]" value="Nachos" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7701]" value="Green peppers, onions, olives, tomatoes." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7701]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7701]" value="17.59" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7701]" value="7701">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7701/1637/1" data-dish="7701" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Nachos">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7701" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7702" style="" data-dish="Chicken Nachos" data-display_order="9">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7702/1637/1" data-dish="7702" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Chicken Nachos">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7702" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7702]" value="Chicken Nachos" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7702]" value="Olives, onions, green peppers." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7702]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7702]" value="19.79" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7702]" value="7702">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7702/1637/1" data-dish="7702" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Chicken Nachos">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7702" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7703" style="" data-dish="Beef Nachos" data-display_order="10">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7703/1637/1" data-dish="7703" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Beef Nachos">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7703" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7703]" value="Beef Nachos" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7703]" value="Olives, onions, green peppers." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7703]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7703]" value="19.79" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7703]" value="7703">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7703/1637/1" data-dish="7703" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Beef Nachos">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7703" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7704" style="background-color: #a90329" data-dish="Crazy Bread N/A" data-display_order="11">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7704/1637/1" data-dish="7704" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Crazy Bread N/A">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7704" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7704]" value="Crazy Bread N/A" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7704]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7704]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7704]" value="9.89" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7704]" value="7704">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7704/1637/1" data-dish="7704" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Crazy Bread N/A">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7704" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7705" style="" data-dish="French Fries with Gravy" data-display_order="12">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7705/1637/1" data-dish="7705" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="French Fries with Gravy">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7705" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7705]" value="French Fries with Gravy" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7705]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7705]" value="Small,Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7705]" value="7.69,9.89" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7705]" value="7705">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7705/1637/1" data-dish="7705" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="French Fries with Gravy">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7705" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7706" style="" data-dish="Tater Tots Potatoes" data-display_order="13">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7706/1637/1" data-dish="7706" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Tater Tots Potatoes">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7706" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7706]" value="Tater Tots Potatoes" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7706]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7706]" value="Small,Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7706]" value="7.69,12.09" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7706]" value="7706">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7706/1637/1" data-dish="7706" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Tater Tots Potatoes">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7706" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7707" style="" data-dish="Spicy Tater Tots Potatoes" data-display_order="14">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7707/1637/1" data-dish="7707" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Spicy Tater Tots Potatoes">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7707" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7707]" value="Spicy Tater Tots Potatoes" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7707]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7707]" value="Small,Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7707]" value="9.89,12.09" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7707]" value="7707">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7707/1637/1" data-dish="7707" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Spicy Tater Tots Potatoes">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7707" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7708" style="" data-dish="Onion Rings" data-display_order="15">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7708/1637/1" data-dish="7708" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Onion Rings">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7708" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7708]" value="Onion Rings" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7708]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7708]" value="Small,Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7708]" value="8.79,10.99" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7708]" value="7708">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7708/1637/1" data-dish="7708" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Onion Rings">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7708" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7709" style="background-color: #a90329" data-dish="Potatoes Wedges N/A" data-display_order="16">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7709/1637/1" data-dish="7709" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Potatoes Wedges N/A">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7709" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7709]" value="Potatoes Wedges N/A" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7709]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7709]" value="Small,Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7709]" value="7.69,9.89" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7709]" value="7709">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7709/1637/1" data-dish="7709" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Potatoes Wedges N/A">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7709" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                        </tbody>
                                        </table>
                                    </div>
                                </form>
                                                            </div>
                        </div>
                                            <div class="jarviswidget jarviswidget-color-darken course-listing jarviswidget-sortable" id="c_956" data-id="956" data-course="Wings Deals" role="widget">
                            <header role="heading"><div class="jarviswidget-ctrls" role="menu">    <a href="javascript:void(0);" class="button-icon jarviswidget-toggle-btn" rel="tooltip" title="" data-placement="bottom" data-original-title="Collapse"><i class="fa fa-minus "></i></a>  </div>
                                <h2>
                                    <a href="#" class="rename" data-course-id="956" title="click to rename this course" style="color: #fff">
                                        Wings Deals
                                    </a>
                                </h2>
                            <span class="jarviswidget-loader"><i class="fa fa-refresh fa-spin"></i></span></header>

                            <div id="course_956" class="widget-body" role="content">
                                                                <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_course_description" method="post" class="form_update_course">
                                    <input type="hidden" name="course_id" value="956">
                                    <div class="form-group">
                                        <label for="course_desc_956">course description</label>
                                        <div class="input-group input-group-sm">
                                            <textarea name="desc" id="course_desc_956" cols="1" rows="3" class="form-control"></textarea>
                                            <span class="input-group-btn">
										<button class="btn btn-primary">Update course description</button>
									</span>
                                        </div>
                                    </div>
                                </form>
                                
                                                                <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_dishes" method="post" class="form_update_course">
                                    <div class="table-responsive">
                                        <input type="hidden" name="course" value="956">
                                        <table class="table table-bordered table-striped table-condensed show-dishes" id="table_956">
                                            <thead>
                                            <tr>
                                                <td colspan="3" class="text-right">

                                                                                                    </td>
                                                <td colspan="2" class="text-right">
                                                    <span class="form-control-static">course available for - if none chosen, course will not show: </span>&nbsp;
                                                                                                            <label class="checkbox-inline">
                                                            <input type="checkbox" name="available_for[1]" value="1" data-name="1" data-course="956" checked="">
                                                            Takeout
                                                        </label>
                                                                                                            <label class="checkbox-inline">
                                                            <input type="checkbox" name="available_for[2]" value="2" data-name="2" data-course="956" checked="">
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
                                                                <a href="#mod_add_dish" class="add-dish-modal" data-course="956" data-toggle="modal">
                                                                    regular dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showCreateCombo/956/1637" data-target="#mod_create_combo" data-toggle="modal" data-backdrop="static" data-keyboard="true" data-course="956">
                                                                    combo dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showImportDish/956/1637" data-target="#mod_import_dish" class="add-dish-modal" data-course="956" data-toggle="modal" data-backdrop="static" data-keyboard="true">
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
                                                                <a href="#mod_add_dish" class="add-dish-modal" data-course="956" data-toggle="modal">
                                                                    regular dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showCreateCombo/956/1637" data-target="#mod_create_combo" data-toggle="modal" data-backdrop="static" data-keyboard="true" data-course="956">
                                                                    combo dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showImportDish/956/1637" data-target="#mod_import_dish" class="add-dish-modal" data-course="956" data-toggle="modal" data-backdrop="static" data-keyboard="true">
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
                                                    <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/manage_dishes/956" data-backdrop="static" data-keyboard="true" data-toggle="modal" data-target="#mod_manage_dishes" class="sort_dishes btn btn-default" data-course="956">dish order</a>
                                                    <button type="submit" class="btn btn-primary ">
                                                        Update
                                                    </button>
                                                </td>
                                                <td colspan="2">
                                                    <div class="input-group">
												<span class="input-group-btn">
													<a href="#" data-update-type="value" class="btn btn-default update-prices">value</a>
												</span>
                                                        <input type="number" name="update_prices_by" id="update_prices_by_956" class="form-control update_prices_by" value="0" placeholder="update prices by" min="0" step="0.1">
                                                        <span class="input-group-btn">
													<a href="#" data-update-type="percent" class="btn btn-default update-prices">percent</a>
												</span>
                                                    </div>
                                                </td>
                                                <td colspan="2"></td>
                                                <td class="text-right hidden-xs">
                                                    <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/manage_dishes/956" data-backdrop="static" data-keyboard="true" data-toggle="modal" data-target="#mod_manage_dishes" class="sort_dishes btn btn-default" data-course="956">dish order</a>
                                                    <button type="submit" class="btn btn-primary ">
                                                        Update
                                                    </button>
                                                </td>
                                            </tr>
                                            </tfoot>
                                            <tbody>
                                                                                                                                                <tr class="sort" data-id="7685" style="" data-dish="12 Wings" data-display_order="0">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7685/1637/1" data-dish="7685" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="12 Wings">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7685" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7685]" value="12 Wings" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7685]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7685]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7685]" value="15.40" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7685]" value="7685">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7685/1637/1" data-dish="7685" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="12 Wings">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7685" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7686" style="" data-dish="24 Wings" data-display_order="1">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7686/1637/1" data-dish="7686" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="24 Wings">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7686" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7686]" value="24 Wings" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7686]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7686]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7686]" value="29.70" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7686]" value="7686">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7686/1637/1" data-dish="7686" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="24 Wings">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7686" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7687" style="" data-dish="36 Wings" data-display_order="2">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7687/1637/1" data-dish="7687" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="36 Wings">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7687" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7687]" value="36 Wings" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7687]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7687]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7687]" value="44.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7687]" value="7687">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7687/1637/1" data-dish="7687" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="36 Wings">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7687" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7688" style="" data-dish="48 Wings" data-display_order="3">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7688/1637/1" data-dish="7688" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="48 Wings">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7688" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7688]" value="48 Wings" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7688]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7688]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7688]" value="58.30" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7688]" value="7688">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7688/1637/1" data-dish="7688" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="48 Wings">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7688" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7689" style="" data-dish="72 Wings" data-display_order="4">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7689/1637/1" data-dish="7689" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="72 Wings">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7689" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7689]" value="72 Wings" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7689]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7689]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7689]" value="86.90" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7689]" value="7689">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7689/1637/1" data-dish="7689" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="72 Wings">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7689" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="10154" style="" data-dish="Wings Platter" data-display_order="5">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/10154/1637/1" data-dish="10154" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Wings Platter">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10154" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[10154]" value="Wings Platter" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[10154]" value="10 wings, fries, gravy." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[10154]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[10154]" value="16.49" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[10154]" value="10154">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/10154/1637/1" data-dish="10154" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Wings Platter">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10154" class="btn btn-danger remove_dish" title="disable dish">
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
                                            <div class="jarviswidget jarviswidget-color-darken course-listing jarviswidget-sortable" id="c_955" data-id="955" data-course="Southern Fried Chicken" role="widget">
                            <header role="heading"><div class="jarviswidget-ctrls" role="menu">    <a href="javascript:void(0);" class="button-icon jarviswidget-toggle-btn" rel="tooltip" title="" data-placement="bottom" data-original-title="Collapse"><i class="fa fa-minus "></i></a>  </div>
                                <h2>
                                    <a href="#" class="rename" data-course-id="955" title="click to rename this course" style="color: #fff">
                                        Southern Fried Chicken
                                    </a>
                                </h2>
                            <span class="jarviswidget-loader"><i class="fa fa-refresh fa-spin"></i></span></header>

                            <div id="course_955" class="widget-body" role="content">
                                                                <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_course_description" method="post" class="form_update_course">
                                    <input type="hidden" name="course_id" value="955">
                                    <div class="form-group">
                                        <label for="course_desc_955">course description</label>
                                        <div class="input-group input-group-sm">
                                            <textarea name="desc" id="course_desc_955" cols="1" rows="3" class="form-control"></textarea>
                                            <span class="input-group-btn">
										<button class="btn btn-primary">Update course description</button>
									</span>
                                        </div>
                                    </div>
                                </form>
                                
                                                                <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_dishes" method="post" class="form_update_course">
                                    <div class="table-responsive">
                                        <input type="hidden" name="course" value="955">
                                        <table class="table table-bordered table-striped table-condensed show-dishes" id="table_955">
                                            <thead>
                                            <tr>
                                                <td colspan="3" class="text-right">

                                                                                                    </td>
                                                <td colspan="2" class="text-right">
                                                    <span class="form-control-static">course available for - if none chosen, course will not show: </span>&nbsp;
                                                                                                            <label class="checkbox-inline">
                                                            <input type="checkbox" name="available_for[1]" value="1" data-name="1" data-course="955" checked="">
                                                            Takeout
                                                        </label>
                                                                                                            <label class="checkbox-inline">
                                                            <input type="checkbox" name="available_for[2]" value="2" data-name="2" data-course="955" checked="">
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
                                                                <a href="#mod_add_dish" class="add-dish-modal" data-course="955" data-toggle="modal">
                                                                    regular dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showCreateCombo/955/1637" data-target="#mod_create_combo" data-toggle="modal" data-backdrop="static" data-keyboard="true" data-course="955">
                                                                    combo dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showImportDish/955/1637" data-target="#mod_import_dish" class="add-dish-modal" data-course="955" data-toggle="modal" data-backdrop="static" data-keyboard="true">
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
                                                                <a href="#mod_add_dish" class="add-dish-modal" data-course="955" data-toggle="modal">
                                                                    regular dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showCreateCombo/955/1637" data-target="#mod_create_combo" data-toggle="modal" data-backdrop="static" data-keyboard="true" data-course="955">
                                                                    combo dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showImportDish/955/1637" data-target="#mod_import_dish" class="add-dish-modal" data-course="955" data-toggle="modal" data-backdrop="static" data-keyboard="true">
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
                                                    <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/manage_dishes/955" data-backdrop="static" data-keyboard="true" data-toggle="modal" data-target="#mod_manage_dishes" class="sort_dishes btn btn-default" data-course="955">dish order</a>
                                                    <button type="submit" class="btn btn-primary ">
                                                        Update
                                                    </button>
                                                </td>
                                                <td colspan="2">
                                                    <div class="input-group">
												<span class="input-group-btn">
													<a href="#" data-update-type="value" class="btn btn-default update-prices">value</a>
												</span>
                                                        <input type="number" name="update_prices_by" id="update_prices_by_955" class="form-control update_prices_by" value="0" placeholder="update prices by" min="0" step="0.1">
                                                        <span class="input-group-btn">
													<a href="#" data-update-type="percent" class="btn btn-default update-prices">percent</a>
												</span>
                                                    </div>
                                                </td>
                                                <td colspan="2"></td>
                                                <td class="text-right hidden-xs">
                                                    <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/manage_dishes/955" data-backdrop="static" data-keyboard="true" data-toggle="modal" data-target="#mod_manage_dishes" class="sort_dishes btn btn-default" data-course="955">dish order</a>
                                                    <button type="submit" class="btn btn-primary ">
                                                        Update
                                                    </button>
                                                </td>
                                            </tr>
                                            </tfoot>
                                            <tbody>
                                                                                                                                                <tr class="sort" data-id="7710" style="" data-dish="3 Pcs Meal" data-display_order="0">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7710/1637/1" data-dish="7710" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="3 Pcs Meal">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7710" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7710]" value="3 Pcs Meal" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7710]" value="Served with fries, BBQ sauce, gravy." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7710]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7710]" value="19.79" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7710]" value="7710">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7710/1637/1" data-dish="7710" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="3 Pcs Meal">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7710" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7711" style="" data-dish="6 Pcs Meal" data-display_order="1">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7711/1637/1" data-dish="7711" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="6 Pcs Meal">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7711" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7711]" value="6 Pcs Meal" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7711]" value="Served with fries, BBQ sauce, gravy." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7711]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7711]" value="25.29" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7711]" value="7711">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7711/1637/1" data-dish="7711" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="6 Pcs Meal">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7711" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7712" style="background-color: #a90329" data-dish="9 Pcs Meal N/A" data-display_order="2">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7712/1637/1" data-dish="7712" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="9 Pcs Meal N/A">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7712" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7712]" value="9 Pcs Meal N/A" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7712]" value="Served with fries, 2 coleslaw, 2 BBQ sauce, 2 gravy." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7712]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7712]" value="27.49" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7712]" value="7712">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7712/1637/1" data-dish="7712" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="9 Pcs Meal N/A">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7712" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7713" style="background-color: #a90329" data-dish="12 Pcs Meal N/A" data-display_order="3">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7713/1637/1" data-dish="7713" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="12 Pcs Meal N/A">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7713" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7713]" value="12 Pcs Meal N/A" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7713]" value="Served with fries, 3 coleslaw, 3 BBQ sauce, 3 gravy." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7713]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7713]" value="31.89" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7713]" value="7713">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7713/1637/1" data-dish="7713" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="12 Pcs Meal N/A">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7713" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7714" style="" data-dish="3 Pcs ALONE" data-display_order="4">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7714/1637/1" data-dish="7714" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="3 Pcs ALONE">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7714" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7714]" value="3 Pcs ALONE" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7714]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7714]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7714]" value="13.19" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7714]" value="7714">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7714/1637/1" data-dish="7714" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="3 Pcs ALONE">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7714" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="10155" style="" data-dish="6 Pcs ALONE" data-display_order="5">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/10155/1637/1" data-dish="10155" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="6 Pcs ALONE">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10155" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[10155]" value="6 Pcs ALONE" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[10155]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[10155]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[10155]" value="23.09" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[10155]" value="10155">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/10155/1637/1" data-dish="10155" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="6 Pcs ALONE">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10155" class="btn btn-danger remove_dish" title="disable dish">
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
                                            <div class="jarviswidget jarviswidget-color-darken course-listing jarviswidget-sortable" id="c_951" data-id="951" data-course="Wraps" role="widget">
                            <header role="heading"><div class="jarviswidget-ctrls" role="menu">    <a href="javascript:void(0);" class="button-icon jarviswidget-toggle-btn" rel="tooltip" title="" data-placement="bottom" data-original-title="Collapse"><i class="fa fa-minus "></i></a>  </div>
                                <h2>
                                    <a href="#" class="rename" data-course-id="951" title="click to rename this course" style="color: #fff">
                                        Wraps
                                    </a>
                                </h2>
                            <span class="jarviswidget-loader"><i class="fa fa-refresh fa-spin"></i></span></header>

                            <div id="course_951" class="widget-body" role="content">
                                                                <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_course_description" method="post" class="form_update_course">
                                    <input type="hidden" name="course_id" value="951">
                                    <div class="form-group">
                                        <label for="course_desc_951">course description</label>
                                        <div class="input-group input-group-sm">
                                            <textarea name="desc" id="course_desc_951" cols="1" rows="3" class="form-control">All dishes served with lettuce, tomatoes, pickles and choice of garlic, sweet &amp; sour, or hot sauce.&lt;br&gt;All platters include fries &amp; gravy.</textarea>
                                            <span class="input-group-btn">
										<button class="btn btn-primary">Update course description</button>
									</span>
                                        </div>
                                    </div>
                                </form>
                                
                                                                <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_dishes" method="post" class="form_update_course">
                                    <div class="table-responsive">
                                        <input type="hidden" name="course" value="951">
                                        <table class="table table-bordered table-striped table-condensed show-dishes" id="table_951">
                                            <thead>
                                            <tr>
                                                <td colspan="3" class="text-right">

                                                                                                    </td>
                                                <td colspan="2" class="text-right">
                                                    <span class="form-control-static">course available for - if none chosen, course will not show: </span>&nbsp;
                                                                                                            <label class="checkbox-inline">
                                                            <input type="checkbox" name="available_for[1]" value="1" data-name="1" data-course="951" checked="">
                                                            Takeout
                                                        </label>
                                                                                                            <label class="checkbox-inline">
                                                            <input type="checkbox" name="available_for[2]" value="2" data-name="2" data-course="951" checked="">
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
                                                                <a href="#mod_add_dish" class="add-dish-modal" data-course="951" data-toggle="modal">
                                                                    regular dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showCreateCombo/951/1637" data-target="#mod_create_combo" data-toggle="modal" data-backdrop="static" data-keyboard="true" data-course="951">
                                                                    combo dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showImportDish/951/1637" data-target="#mod_import_dish" class="add-dish-modal" data-course="951" data-toggle="modal" data-backdrop="static" data-keyboard="true">
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
                                                                <a href="#mod_add_dish" class="add-dish-modal" data-course="951" data-toggle="modal">
                                                                    regular dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showCreateCombo/951/1637" data-target="#mod_create_combo" data-toggle="modal" data-backdrop="static" data-keyboard="true" data-course="951">
                                                                    combo dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showImportDish/951/1637" data-target="#mod_import_dish" class="add-dish-modal" data-course="951" data-toggle="modal" data-backdrop="static" data-keyboard="true">
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
                                                    <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/manage_dishes/951" data-backdrop="static" data-keyboard="true" data-toggle="modal" data-target="#mod_manage_dishes" class="sort_dishes btn btn-default" data-course="951">dish order</a>
                                                    <button type="submit" class="btn btn-primary ">
                                                        Update
                                                    </button>
                                                </td>
                                                <td colspan="2">
                                                    <div class="input-group">
												<span class="input-group-btn">
													<a href="#" data-update-type="value" class="btn btn-default update-prices">value</a>
												</span>
                                                        <input type="number" name="update_prices_by" id="update_prices_by_951" class="form-control update_prices_by" value="0" placeholder="update prices by" min="0" step="0.1">
                                                        <span class="input-group-btn">
													<a href="#" data-update-type="percent" class="btn btn-default update-prices">percent</a>
												</span>
                                                    </div>
                                                </td>
                                                <td colspan="2"></td>
                                                <td class="text-right hidden-xs">
                                                    <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/manage_dishes/951" data-backdrop="static" data-keyboard="true" data-toggle="modal" data-target="#mod_manage_dishes" class="sort_dishes btn btn-default" data-course="951">dish order</a>
                                                    <button type="submit" class="btn btn-primary ">
                                                        Update
                                                    </button>
                                                </td>
                                            </tr>
                                            </tfoot>
                                            <tbody>
                                                                                                                                                <tr class="sort" data-id="7666" style="" data-dish="Steak Wrap" data-display_order="1">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7666/1637/1" data-dish="7666" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Steak Wrap">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7666" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7666]" value="Steak Wrap" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7666]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7666]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7666]" value="15.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7666]" value="7666">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7666/1637/1" data-dish="7666" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Steak Wrap">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7666" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7667" style="" data-dish="Steak Platter" data-display_order="2">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7667/1637/1" data-dish="7667" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Steak Platter">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7667" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7667]" value="Steak Platter" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7667]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7667]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7667]" value="18.50" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7667]" value="7667">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7667/1637/1" data-dish="7667" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Steak Platter">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7667" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7663" style="" data-dish="Beef Donair Wrap" data-display_order="3">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7663/1637/1" data-dish="7663" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Beef Donair Wrap">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7663" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7663]" value="Beef Donair Wrap" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7663]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7663]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7663]" value="13.85" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7663]" value="7663">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7663/1637/1" data-dish="7663" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Beef Donair Wrap">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7663" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7673" style="" data-dish="Beef Donair Platter" data-display_order="4">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7673/1637/1" data-dish="7673" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Beef Donair Platter">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7673" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7673]" value="Beef Donair Platter" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7673]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7673]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7673]" value="17.30" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7673]" value="7673">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7673/1637/1" data-dish="7673" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Beef Donair Platter">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7673" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7664" style="" data-dish="Chicken Shawarma" data-display_order="5">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7664/1637/1" data-dish="7664" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Chicken Shawarma">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7664" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7664]" value="Chicken Shawarma" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7664]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7664]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7664]" value="15.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7664]" value="7664">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7664/1637/1" data-dish="7664" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Chicken Shawarma">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7664" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7665" style="" data-dish="Chicken Shawarma Platter" data-display_order="6">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7665/1637/1" data-dish="7665" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Chicken Shawarma Platter">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7665" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7665]" value="Chicken Shawarma Platter" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7665]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7665]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7665]" value="18.50" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7665]" value="7665">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7665/1637/1" data-dish="7665" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Chicken Shawarma Platter">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7665" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7668" style="background-color: #a90329" data-dish="BBQ Breaded Chicken N/A" data-display_order="7">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7668/1637/1" data-dish="7668" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="BBQ Breaded Chicken N/A">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7668" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7668]" value="BBQ Breaded Chicken N/A" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7668]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7668]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7668]" value="15.02" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7668]" value="7668">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7668/1637/1" data-dish="7668" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="BBQ Breaded Chicken N/A">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7668" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7669" style="background-color: #a90329" data-dish="BBQ Breaded Chicken Platte N/Ar" data-display_order="8">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7669/1637/1" data-dish="7669" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="BBQ Breaded Chicken Platte N/Ar">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7669" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7669]" value="BBQ Breaded Chicken Platte N/Ar" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7669]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7669]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7669]" value="17.32" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7669]" value="7669">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7669/1637/1" data-dish="7669" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="BBQ Breaded Chicken Platte N/Ar">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7669" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7670" style="background-color: #a90329" data-dish="Spicy Breaded Chicken N/A" data-display_order="9">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7670/1637/1" data-dish="7670" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Spicy Breaded Chicken N/A">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7670" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7670]" value="Spicy Breaded Chicken N/A" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7670]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7670]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7670]" value="15.02" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7670]" value="7670">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7670/1637/1" data-dish="7670" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Spicy Breaded Chicken N/A">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7670" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7671" style="background-color: #a90329" data-dish="Spicy Breaded Chicken Platter N/A" data-display_order="10">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7671/1637/1" data-dish="7671" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Spicy Breaded Chicken Platter N/A">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7671" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7671]" value="Spicy Breaded Chicken Platter N/A" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7671]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7671]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7671]" value="18.48" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7671]" value="7671">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7671/1637/1" data-dish="7671" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Spicy Breaded Chicken Platter N/A">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7671" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7672" style="background-color: #a90329" data-dish="Fish &amp; Chips (3 pcs) N/A" data-display_order="11">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7672/1637/1" data-dish="7672" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Fish &amp; Chips (3 pcs) N/A">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7672" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7672]" value="Fish &amp; Chips (3 pcs) N/A" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7672]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7672]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7672]" value="17.32" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7672]" value="7672">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7672/1637/1" data-dish="7672" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Fish &amp; Chips (3 pcs) N/A">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7672" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                        </tbody>
                                        </table>
                                    </div>
                                </form>
                                                            </div>
                        </div>
                                            <div class="jarviswidget jarviswidget-color-darken course-listing jarviswidget-sortable" id="c_950" data-id="950" data-course="Platters, Burgers &amp; Sandwiches" role="widget">
                            <header role="heading"><div class="jarviswidget-ctrls" role="menu">    <a href="javascript:void(0);" class="button-icon jarviswidget-toggle-btn" rel="tooltip" title="" data-placement="bottom" data-original-title="Collapse"><i class="fa fa-minus "></i></a>  </div>
                                <h2>
                                    <a href="#" class="rename" data-course-id="950" title="click to rename this course" style="color: #fff">
                                        Platters, Burgers &amp; Sandwiches
                                    </a>
                                </h2>
                            <span class="jarviswidget-loader"><i class="fa fa-refresh fa-spin"></i></span></header>

                            <div id="course_950" class="widget-body" role="content">
                                                                <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_course_description" method="post" class="form_update_course">
                                    <input type="hidden" name="course_id" value="950">
                                    <div class="form-group">
                                        <label for="course_desc_950">course description</label>
                                        <div class="input-group input-group-sm">
                                            <textarea name="desc" id="course_desc_950" cols="1" rows="3" class="form-control">All platters include fries &amp; gravy.</textarea>
                                            <span class="input-group-btn">
										<button class="btn btn-primary">Update course description</button>
									</span>
                                        </div>
                                    </div>
                                </form>
                                
                                                                <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_dishes" method="post" class="form_update_course">
                                    <div class="table-responsive">
                                        <input type="hidden" name="course" value="950">
                                        <table class="table table-bordered table-striped table-condensed show-dishes" id="table_950">
                                            <thead>
                                            <tr>
                                                <td colspan="3" class="text-right">

                                                                                                    </td>
                                                <td colspan="2" class="text-right">
                                                    <span class="form-control-static">course available for - if none chosen, course will not show: </span>&nbsp;
                                                                                                            <label class="checkbox-inline">
                                                            <input type="checkbox" name="available_for[1]" value="1" data-name="1" data-course="950" checked="">
                                                            Takeout
                                                        </label>
                                                                                                            <label class="checkbox-inline">
                                                            <input type="checkbox" name="available_for[2]" value="2" data-name="2" data-course="950" checked="">
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
                                                                <a href="#mod_add_dish" class="add-dish-modal" data-course="950" data-toggle="modal">
                                                                    regular dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showCreateCombo/950/1637" data-target="#mod_create_combo" data-toggle="modal" data-backdrop="static" data-keyboard="true" data-course="950">
                                                                    combo dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showImportDish/950/1637" data-target="#mod_import_dish" class="add-dish-modal" data-course="950" data-toggle="modal" data-backdrop="static" data-keyboard="true">
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
                                                                <a href="#mod_add_dish" class="add-dish-modal" data-course="950" data-toggle="modal">
                                                                    regular dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showCreateCombo/950/1637" data-target="#mod_create_combo" data-toggle="modal" data-backdrop="static" data-keyboard="true" data-course="950">
                                                                    combo dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showImportDish/950/1637" data-target="#mod_import_dish" class="add-dish-modal" data-course="950" data-toggle="modal" data-backdrop="static" data-keyboard="true">
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
                                                    <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/manage_dishes/950" data-backdrop="static" data-keyboard="true" data-toggle="modal" data-target="#mod_manage_dishes" class="sort_dishes btn btn-default" data-course="950">dish order</a>
                                                    <button type="submit" class="btn btn-primary ">
                                                        Update
                                                    </button>
                                                </td>
                                                <td colspan="2">
                                                    <div class="input-group">
												<span class="input-group-btn">
													<a href="#" data-update-type="value" class="btn btn-default update-prices">value</a>
												</span>
                                                        <input type="number" name="update_prices_by" id="update_prices_by_950" class="form-control update_prices_by" value="0" placeholder="update prices by" min="0" step="0.1">
                                                        <span class="input-group-btn">
													<a href="#" data-update-type="percent" class="btn btn-default update-prices">percent</a>
												</span>
                                                    </div>
                                                </td>
                                                <td colspan="2"></td>
                                                <td class="text-right hidden-xs">
                                                    <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/manage_dishes/950" data-backdrop="static" data-keyboard="true" data-toggle="modal" data-target="#mod_manage_dishes" class="sort_dishes btn btn-default" data-course="950">dish order</a>
                                                    <button type="submit" class="btn btn-primary ">
                                                        Update
                                                    </button>
                                                </td>
                                            </tr>
                                            </tfoot>
                                            <tbody>
                                                                                                                                                <tr class="sort" data-id="7675" style="" data-dish="Hamburger (home made)" data-display_order="1">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7675/1637/1" data-dish="7675" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Hamburger (home made)">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7675" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7675]" value="Hamburger (home made)" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7675]" value="Lettuce, tomatoes, pickles &amp; mayo." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7675]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7675]" value="17.30" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7675]" value="7675">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7675/1637/1" data-dish="7675" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Hamburger (home made)">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7675" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="10156" style="" data-dish="Double Burger" data-display_order="2">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/10156/1637/1" data-dish="10156" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Double Burger">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10156" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[10156]" value="Double Burger" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[10156]" value="Lettuce, tomatoes, pickles, mayo." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[10156]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[10156]" value="23.10" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[10156]" value="10156">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/10156/1637/1" data-dish="10156" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Double Burger">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10156" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7676" style="" data-dish="Cheeseburger" data-display_order="3">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7676/1637/1" data-dish="7676" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Cheeseburger">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7676" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7676]" value="Cheeseburger" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7676]" value="Lettuce, tomatoes, pickles &amp; mayo." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7676]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7676]" value="18.50" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7676]" value="7676">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7676/1637/1" data-dish="7676" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Cheeseburger">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7676" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="10157" style="" data-dish="Double Cheeseburger" data-display_order="4">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/10157/1637/1" data-dish="10157" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Double Cheeseburger">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10157" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[10157]" value="Double Cheeseburger" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[10157]" value="Lettuce, tomatoes, pickles, cheese, mayo." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[10157]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[10157]" value="24.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[10157]" value="10157">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/10157/1637/1" data-dish="10157" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Double Cheeseburger">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10157" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7678" style="" data-dish="Crunchie Burger" data-display_order="5">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7678/1637/1" data-dish="7678" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Crunchie Burger">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7678" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7678]" value="Crunchie Burger" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7678]" value="Lettuce, tomatoes, pickles with onion rings, cheese &amp; BBQ sauce." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7678]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7678]" value="18.50" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7678]" value="7678">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7678/1637/1" data-dish="7678" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Crunchie Burger">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7678" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7679" style="" data-dish="The Finisher" data-display_order="6">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7679/1637/1" data-dish="7679" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="The Finisher">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7679" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7679]" value="The Finisher" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7679]" value="Lettuce, tomatoes, pickles, mayo, cheese, sauted mushrooms &amp; onions." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7679]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7679]" value="18.50" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7679]" value="7679">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7679/1637/1" data-dish="7679" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="The Finisher">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7679" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7680" style="" data-dish="Chicken Burger" data-display_order="7">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7680/1637/1" data-dish="7680" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Chicken Burger">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7680" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7680]" value="Chicken Burger" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7680]" value="Lettuce, tomatoes, pickles &amp; mayo." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7680]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7680]" value="17.30" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7680]" value="7680">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7680/1637/1" data-dish="7680" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Chicken Burger">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7680" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7677" style="" data-dish="Bacon Cheeseburger" data-display_order="8">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7677/1637/1" data-dish="7677" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Bacon Cheeseburger">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7677" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7677]" value="Bacon Cheeseburger" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7677]" value="Lettuce, tomatoes, pickles &amp; mayo." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7677]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7677]" value="18.50" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7677]" value="7677">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7677/1637/1" data-dish="7677" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Bacon Cheeseburger">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7677" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7674" style="" data-dish="Bacon Supreme Burger" data-display_order="9">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7674/1637/1" data-dish="7674" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Bacon Supreme Burger">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7674" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7674]" value="Bacon Supreme Burger" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7674]" value="Lettuce, tomatoes, pickles, mayo, triple bacon &amp; cheese." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7674]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7674]" value="20.80" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7674]" value="7674">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7674/1637/1" data-dish="7674" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Bacon Supreme Burger">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7674" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="10158" style="" data-dish="Vegi Burger Platter" data-display_order="10">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/10158/1637/1" data-dish="10158" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Vegi Burger Platter">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10158" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[10158]" value="Vegi Burger Platter" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[10158]" value="Served with fries and gravy." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[10158]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[10158]" value="18.50" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[10158]" value="10158">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/10158/1637/1" data-dish="10158" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Vegi Burger Platter">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10158" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7681" style="" data-dish="Chicken Fingers (5 pcs)" data-display_order="11">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7681/1637/1" data-dish="7681" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Chicken Fingers (5 pcs)">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7681" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7681]" value="Chicken Fingers (5 pcs)" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7681]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7681]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7681]" value="18.50" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7681]" value="7681">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7681/1637/1" data-dish="7681" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Chicken Fingers (5 pcs)">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7681" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7682" style="" data-dish="Chicken Club Sandwich" data-display_order="12">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7682/1637/1" data-dish="7682" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Chicken Club Sandwich">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7682" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7682]" value="Chicken Club Sandwich" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7682]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7682]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7682]" value="18.50" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7682]" value="7682">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7682/1637/1" data-dish="7682" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Chicken Club Sandwich">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7682" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7683" style="" data-dish="Turkey Club Sandwich" data-display_order="13">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7683/1637/1" data-dish="7683" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Turkey Club Sandwich">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7683" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7683]" value="Turkey Club Sandwich" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7683]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7683]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7683]" value="17.30" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7683]" value="7683">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7683/1637/1" data-dish="7683" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Turkey Club Sandwich">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7683" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="10159" style="" data-dish="Fish and Chips" data-display_order="14">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/10159/1637/1" data-dish="10159" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Fish and Chips">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10159" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[10159]" value="Fish and Chips" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[10159]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[10159]" value="3 pcs,5 pcs" class="form-control size"></td>
                                                        <td><input type="text" name="price[10159]" value="19.65,30.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[10159]" value="10159">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/10159/1637/1" data-dish="10159" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Fish and Chips">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10159" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7684" style="" data-dish="Combo Platter" data-display_order="15">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7684/1637/1" data-dish="7684" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Combo Platter">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7684" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7684]" value="Combo Platter" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7684]" value="Popcurds, chicken fingers, zucchini, onion rings, fries." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7684]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7684]" value="18.50" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7684]" value="7684">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7684/1637/1" data-dish="7684" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Combo Platter">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7684" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="10160" style="" data-dish="Shrimp in a Basket" data-display_order="16">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/10160/1637/1" data-dish="10160" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Shrimp in a Basket">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10160" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[10160]" value="Shrimp in a Basket" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[10160]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[10160]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[10160]" value="17.30" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[10160]" value="10160">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/10160/1637/1" data-dish="10160" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Shrimp in a Basket">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10160" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="10161" style="" data-dish="Popcorn Chicken Platter" data-display_order="17">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/10161/1637/1" data-dish="10161" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Popcorn Chicken Platter">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10161" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[10161]" value="Popcorn Chicken Platter" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[10161]" value="Served with fries and gravy." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[10161]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[10161]" value="17.30" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[10161]" value="10161">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/10161/1637/1" data-dish="10161" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Popcorn Chicken Platter">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10161" class="btn btn-danger remove_dish" title="disable dish">
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
                                            <div class="jarviswidget jarviswidget-color-darken course-listing jarviswidget-sortable" id="c_948" data-id="948" data-course="Subs" role="widget">
                            <header role="heading"><div class="jarviswidget-ctrls" role="menu">    <a href="javascript:void(0);" class="button-icon jarviswidget-toggle-btn" rel="tooltip" title="" data-placement="bottom" data-original-title="Collapse"><i class="fa fa-minus "></i></a>  </div>
                                <h2>
                                    <a href="#" class="rename" data-course-id="948" title="click to rename this course" style="color: #fff">
                                        Subs
                                    </a>
                                </h2>
                            <span class="jarviswidget-loader"><i class="fa fa-refresh fa-spin"></i></span></header>

                            <div id="course_948" class="widget-body" role="content">
                                                                <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_course_description" method="post" class="form_update_course">
                                    <input type="hidden" name="course_id" value="948">
                                    <div class="form-group">
                                        <label for="course_desc_948">course description</label>
                                        <div class="input-group input-group-sm">
                                            <textarea name="desc" id="course_desc_948" cols="1" rows="3" class="form-control">All subs are served with lettuce, tomatoes, pickles, cheese.</textarea>
                                            <span class="input-group-btn">
										<button class="btn btn-primary">Update course description</button>
									</span>
                                        </div>
                                    </div>
                                </form>
                                
                                                                <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_dishes" method="post" class="form_update_course">
                                    <div class="table-responsive">
                                        <input type="hidden" name="course" value="948">
                                        <table class="table table-bordered table-striped table-condensed show-dishes" id="table_948">
                                            <thead>
                                            <tr>
                                                <td colspan="3" class="text-right">

                                                                                                    </td>
                                                <td colspan="2" class="text-right">
                                                    <span class="form-control-static">course available for - if none chosen, course will not show: </span>&nbsp;
                                                                                                            <label class="checkbox-inline">
                                                            <input type="checkbox" name="available_for[1]" value="1" data-name="1" data-course="948" checked="">
                                                            Takeout
                                                        </label>
                                                                                                            <label class="checkbox-inline">
                                                            <input type="checkbox" name="available_for[2]" value="2" data-name="2" data-course="948" checked="">
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
                                                                <a href="#mod_add_dish" class="add-dish-modal" data-course="948" data-toggle="modal">
                                                                    regular dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showCreateCombo/948/1637" data-target="#mod_create_combo" data-toggle="modal" data-backdrop="static" data-keyboard="true" data-course="948">
                                                                    combo dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showImportDish/948/1637" data-target="#mod_import_dish" class="add-dish-modal" data-course="948" data-toggle="modal" data-backdrop="static" data-keyboard="true">
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
                                                                <a href="#mod_add_dish" class="add-dish-modal" data-course="948" data-toggle="modal">
                                                                    regular dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showCreateCombo/948/1637" data-target="#mod_create_combo" data-toggle="modal" data-backdrop="static" data-keyboard="true" data-course="948">
                                                                    combo dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showImportDish/948/1637" data-target="#mod_import_dish" class="add-dish-modal" data-course="948" data-toggle="modal" data-backdrop="static" data-keyboard="true">
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
                                                    <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/manage_dishes/948" data-backdrop="static" data-keyboard="true" data-toggle="modal" data-target="#mod_manage_dishes" class="sort_dishes btn btn-default" data-course="948">dish order</a>
                                                    <button type="submit" class="btn btn-primary ">
                                                        Update
                                                    </button>
                                                </td>
                                                <td colspan="2">
                                                    <div class="input-group">
												<span class="input-group-btn">
													<a href="#" data-update-type="value" class="btn btn-default update-prices">value</a>
												</span>
                                                        <input type="number" name="update_prices_by" id="update_prices_by_948" class="form-control update_prices_by" value="0" placeholder="update prices by" min="0" step="0.1">
                                                        <span class="input-group-btn">
													<a href="#" data-update-type="percent" class="btn btn-default update-prices">percent</a>
												</span>
                                                    </div>
                                                </td>
                                                <td colspan="2"></td>
                                                <td class="text-right hidden-xs">
                                                    <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/manage_dishes/948" data-backdrop="static" data-keyboard="true" data-toggle="modal" data-target="#mod_manage_dishes" class="sort_dishes btn btn-default" data-course="948">dish order</a>
                                                    <button type="submit" class="btn btn-primary ">
                                                        Update
                                                    </button>
                                                </td>
                                            </tr>
                                            </tfoot>
                                            <tbody>
                                                                                                                                                <tr class="sort" data-id="7721" style="background-color: #a90329" data-dish="Breaded Chicken Sub" data-display_order="0">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7721/1637/1" data-dish="7721" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Breaded Chicken Sub">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7721" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7721]" value="Breaded Chicken Sub" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7721]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7721]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7721]" value="13.19" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7721]" value="7721">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7721/1637/1" data-dish="7721" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Breaded Chicken Sub">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7721" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7722" style="" data-dish="Spicy Breaded Chicken Sub" data-display_order="1">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7722/1637/1" data-dish="7722" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Spicy Breaded Chicken Sub">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7722" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7722]" value="Spicy Breaded Chicken Sub" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7722]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7722]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7722]" value="14.29" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7722]" value="7722">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7722/1637/1" data-dish="7722" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Spicy Breaded Chicken Sub">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7722" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7723" style="" data-dish="Steak Sub" data-display_order="2">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7723/1637/1" data-dish="7723" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Steak Sub">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7723" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7723]" value="Steak Sub" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7723]" value="Mushrooms, onions, green peppers." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7723]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7723]" value="16.49" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7723]" value="7723">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7723/1637/1" data-dish="7723" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Steak Sub">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7723" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7724" style="" data-dish="Pizza Sub" data-display_order="3">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7724/1637/1" data-dish="7724" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Pizza Sub">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7724" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7724]" value="Pizza Sub" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7724]" value="Served with pizza sauce, mozzarella, green peppers, mushrooms, pepperoni, cheese." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7724]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7724]" value="14.29" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7724]" value="7724">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7724/1637/1" data-dish="7724" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Pizza Sub">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7724" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7725" style="" data-dish="Meatball Sub" data-display_order="4">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7725/1637/1" data-dish="7725" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Meatball Sub">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7725" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7725]" value="Meatball Sub" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7725]" value="Meat sauce &amp; cheese." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7725]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7725]" value="14.29" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7725]" value="7725">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7725/1637/1" data-dish="7725" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Meatball Sub">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7725" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7726" style="" data-dish="Pepperoni Sub" data-display_order="5">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7726/1637/1" data-dish="7726" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Pepperoni Sub">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7726" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7726]" value="Pepperoni Sub" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7726]" value="Pepperoni, lettuce, tomatoes, cheese." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7726]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7726]" value="13.19" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7726]" value="7726">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7726/1637/1" data-dish="7726" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Pepperoni Sub">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7726" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7727" style="" data-dish="BLT Sub" data-display_order="6">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7727/1637/1" data-dish="7727" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="BLT Sub">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7727" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7727]" value="BLT Sub" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7727]" value="Bacon, lettuce, tomatoes, cheese." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7727]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7727]" value="13.19" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7727]" value="7727">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7727/1637/1" data-dish="7727" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="BLT Sub">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7727" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7728" style="" data-dish="Vegetarian Sub" data-display_order="7">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7728/1637/1" data-dish="7728" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Vegetarian Sub">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7728" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7728]" value="Vegetarian Sub" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7728]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7728]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7728]" value="14.29" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7728]" value="7728">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7728/1637/1" data-dish="7728" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Vegetarian Sub">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7728" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7729" style="" data-dish="All Meat Sub" data-display_order="8">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7729/1637/1" data-dish="7729" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="All Meat Sub">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7729" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7729]" value="All Meat Sub" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7729]" value="Pepperoni, bacon, ham, turkey, salami." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7729]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7729]" value="16.49" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7729]" value="7729">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7729/1637/1" data-dish="7729" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="All Meat Sub">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7729" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7730" style="" data-dish="Chicken Breast Sub" data-display_order="9">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7730/1637/1" data-dish="7730" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Chicken Breast Sub">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7730" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7730]" value="Chicken Breast Sub" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7730]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7730]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7730]" value="14.29" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7730]" value="7730">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7730/1637/1" data-dish="7730" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Chicken Breast Sub">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7730" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7731" style="" data-dish="Chicken Club Sub" data-display_order="10">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7731/1637/1" data-dish="7731" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Chicken Club Sub">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7731" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7731]" value="Chicken Club Sub" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7731]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7731]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7731]" value="14.29" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7731]" value="7731">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7731/1637/1" data-dish="7731" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Chicken Club Sub">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7731" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7732" style="" data-dish="Turkey Club Sub" data-display_order="11">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7732/1637/1" data-dish="7732" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Turkey Club Sub">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7732" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7732]" value="Turkey Club Sub" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7732]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7732]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7732]" value="14.29" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7732]" value="7732">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7732/1637/1" data-dish="7732" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Turkey Club Sub">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7732" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7733" style="" data-dish="Assorted Sub" data-display_order="12">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7733/1637/1" data-dish="7733" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Assorted Sub">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7733" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7733]" value="Assorted Sub" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7733]" value="Turkey, ham, salami. Served cold." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7733]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7733]" value="15.39" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7733]" value="7733">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7733/1637/1" data-dish="7733" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Assorted Sub">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7733" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7734" style="" data-dish="Donair Sub" data-display_order="13">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7734/1637/1" data-dish="7734" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Donair Sub">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7734" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7734]" value="Donair Sub" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7734]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7734]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7734]" value="13.19" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7734]" value="7734">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7734/1637/1" data-dish="7734" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Donair Sub">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7734" class="btn btn-danger remove_dish" title="disable dish">
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
                                            <div class="jarviswidget jarviswidget-color-darken course-listing jarviswidget-sortable" id="c_953" data-id="953" data-course="Poutine" role="widget">
                            <header role="heading"><div class="jarviswidget-ctrls" role="menu">    <a href="javascript:void(0);" class="button-icon jarviswidget-toggle-btn" rel="tooltip" title="" data-placement="bottom" data-original-title="Collapse"><i class="fa fa-minus "></i></a>  </div>
                                <h2>
                                    <a href="#" class="rename" data-course-id="953" title="click to rename this course" style="color: #fff">
                                        Poutine
                                    </a>
                                </h2>
                            <span class="jarviswidget-loader"><i class="fa fa-refresh fa-spin"></i></span></header>

                            <div id="course_953" class="widget-body" role="content">
                                                                <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_course_description" method="post" class="form_update_course">
                                    <input type="hidden" name="course_id" value="953">
                                    <div class="form-group">
                                        <label for="course_desc_953">course description</label>
                                        <div class="input-group input-group-sm">
                                            <textarea name="desc" id="course_desc_953" cols="1" rows="3" class="form-control"></textarea>
                                            <span class="input-group-btn">
										<button class="btn btn-primary">Update course description</button>
									</span>
                                        </div>
                                    </div>
                                </form>
                                
                                                                <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_dishes" method="post" class="form_update_course">
                                    <div class="table-responsive">
                                        <input type="hidden" name="course" value="953">
                                        <table class="table table-bordered table-striped table-condensed show-dishes" id="table_953">
                                            <thead>
                                            <tr>
                                                <td colspan="3" class="text-right">

                                                                                                    </td>
                                                <td colspan="2" class="text-right">
                                                    <span class="form-control-static">course available for - if none chosen, course will not show: </span>&nbsp;
                                                                                                            <label class="checkbox-inline">
                                                            <input type="checkbox" name="available_for[1]" value="1" data-name="1" data-course="953" checked="">
                                                            Takeout
                                                        </label>
                                                                                                            <label class="checkbox-inline">
                                                            <input type="checkbox" name="available_for[2]" value="2" data-name="2" data-course="953" checked="">
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
                                                                <a href="#mod_add_dish" class="add-dish-modal" data-course="953" data-toggle="modal">
                                                                    regular dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showCreateCombo/953/1637" data-target="#mod_create_combo" data-toggle="modal" data-backdrop="static" data-keyboard="true" data-course="953">
                                                                    combo dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showImportDish/953/1637" data-target="#mod_import_dish" class="add-dish-modal" data-course="953" data-toggle="modal" data-backdrop="static" data-keyboard="true">
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
                                                                <a href="#mod_add_dish" class="add-dish-modal" data-course="953" data-toggle="modal">
                                                                    regular dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showCreateCombo/953/1637" data-target="#mod_create_combo" data-toggle="modal" data-backdrop="static" data-keyboard="true" data-course="953">
                                                                    combo dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showImportDish/953/1637" data-target="#mod_import_dish" class="add-dish-modal" data-course="953" data-toggle="modal" data-backdrop="static" data-keyboard="true">
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
                                                    <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/manage_dishes/953" data-backdrop="static" data-keyboard="true" data-toggle="modal" data-target="#mod_manage_dishes" class="sort_dishes btn btn-default" data-course="953">dish order</a>
                                                    <button type="submit" class="btn btn-primary ">
                                                        Update
                                                    </button>
                                                </td>
                                                <td colspan="2">
                                                    <div class="input-group">
												<span class="input-group-btn">
													<a href="#" data-update-type="value" class="btn btn-default update-prices">value</a>
												</span>
                                                        <input type="number" name="update_prices_by" id="update_prices_by_953" class="form-control update_prices_by" value="0" placeholder="update prices by" min="0" step="0.1">
                                                        <span class="input-group-btn">
													<a href="#" data-update-type="percent" class="btn btn-default update-prices">percent</a>
												</span>
                                                    </div>
                                                </td>
                                                <td colspan="2"></td>
                                                <td class="text-right hidden-xs">
                                                    <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/manage_dishes/953" data-backdrop="static" data-keyboard="true" data-toggle="modal" data-target="#mod_manage_dishes" class="sort_dishes btn btn-default" data-course="953">dish order</a>
                                                    <button type="submit" class="btn btn-primary ">
                                                        Update
                                                    </button>
                                                </td>
                                            </tr>
                                            </tfoot>
                                            <tbody>
                                                                                                                                                <tr class="sort" data-id="7735" style="" data-dish="Oven Baked Poutine" data-display_order="1">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7735/1637/1" data-dish="7735" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Oven Baked Poutine">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7735" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7735]" value="Oven Baked Poutine" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7735]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7735]" value="Small,Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7735]" value="9.89,12.09" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7735]" value="7735">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7735/1637/1" data-dish="7735" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Oven Baked Poutine">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7735" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7736" style="" data-dish="Tater Tots Poutine" data-display_order="2">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7736/1637/1" data-dish="7736" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Tater Tots Poutine">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7736" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7736]" value="Tater Tots Poutine" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7736]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7736]" value="Small,Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7736]" value="10.99,13.19" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7736]" value="7736">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7736/1637/1" data-dish="7736" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Tater Tots Poutine">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7736" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7740" style="" data-dish="Popcurds Poutine" data-display_order="3">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7740/1637/1" data-dish="7740" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Popcurds Poutine">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7740" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7740]" value="Popcurds Poutine" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7740]" value="Regular poutine with breaded cheese curds." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7740]" value="Small,Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7740]" value="10.99,13.19" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7740]" value="7740">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7740/1637/1" data-dish="7740" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Popcurds Poutine">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7740" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7737" style="" data-dish="Spicy Popcurds Poutine" data-display_order="4">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7737/1637/1" data-dish="7737" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Spicy Popcurds Poutine">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7737" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7737]" value="Spicy Popcurds Poutine" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7737]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7737]" value="Small,Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7737]" value="10.99,13.19" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7737]" value="7737">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7737/1637/1" data-dish="7737" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Spicy Popcurds Poutine">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7737" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7744" style="" data-dish="Italian Poutine" data-display_order="5">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7744/1637/1" data-dish="7744" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Italian Poutine">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7744" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7744]" value="Italian Poutine" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7744]" value="Served with meat sauce." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7744]" value="Small,Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7744]" value="12.09,14.29" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7744]" value="7744">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7744/1637/1" data-dish="7744" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Italian Poutine">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7744" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7745" style="" data-dish="Steak Poutine" data-display_order="6">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7745/1637/1" data-dish="7745" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Steak Poutine">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7745" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7745]" value="Steak Poutine" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7745]" value="Served with mushrooms, onion, steak." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7745]" value="Small,Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7745]" value="13.19,15.39" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7745]" value="7745">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7745/1637/1" data-dish="7745" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Steak Poutine">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7745" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7747" style="" data-dish="Canadian Poutine" data-display_order="7">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7747/1637/1" data-dish="7747" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Canadian Poutine">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7747" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7747]" value="Canadian Poutine" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7747]" value="Pepperoni, bacon, mushrooms." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7747]" value="Small,Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7747]" value="12.09,14.29" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7747]" value="7747">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7747/1637/1" data-dish="7747" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Canadian Poutine">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7747" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7738" style="background-color: #a90329" data-dish="Potatoes Wedge Poutine N/A" data-display_order="8">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7738/1637/1" data-dish="7738" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Potatoes Wedge Poutine N/A">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7738" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7738]" value="Potatoes Wedge Poutine N/A" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7738]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7738]" value="Small,Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7738]" value="8.79,10.99" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7738]" value="7738">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7738/1637/1" data-dish="7738" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Potatoes Wedge Poutine N/A">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7738" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7739" style="background-color: #a90329" data-dish="Spicy Potatoes Wedge Poutine N/A" data-display_order="9">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7739/1637/1" data-dish="7739" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Spicy Potatoes Wedge Poutine N/A">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7739" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7739]" value="Spicy Potatoes Wedge Poutine N/A" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7739]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7739]" value="Small,Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7739]" value="8.79,10.99" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7739]" value="7739">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7739/1637/1" data-dish="7739" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Spicy Potatoes Wedge Poutine N/A">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7739" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7741" style="background-color: #a90329" data-dish="Bacon Poutine N/A" data-display_order="10">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7741/1637/1" data-dish="7741" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Bacon Poutine N/A">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7741" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7741]" value="Bacon Poutine N/A" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7741]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7741]" value="Small,Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7741]" value="8.79,10.99" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7741]" value="7741">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7741/1637/1" data-dish="7741" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Bacon Poutine N/A">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7741" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7742" style="background-color: #a90329" data-dish="Double Bacon Poutine N/A" data-display_order="11">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7742/1637/1" data-dish="7742" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Double Bacon Poutine N/A">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7742" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7742]" value="Double Bacon Poutine N/A" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7742]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7742]" value="Small,Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7742]" value="9.89,12.09" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7742]" value="7742">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7742/1637/1" data-dish="7742" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Double Bacon Poutine N/A">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7742" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7743" style="background-color: #a90329" data-dish="Ground Beef Poutine N/A" data-display_order="12">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7743/1637/1" data-dish="7743" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Ground Beef Poutine N/A">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7743" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7743]" value="Ground Beef Poutine N/A" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7743]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7743]" value="Small,Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7743]" value="8.79,10.99" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7743]" value="7743">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7743/1637/1" data-dish="7743" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Ground Beef Poutine N/A">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7743" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7746" style="background-color: #a90329" data-dish="Half &amp; Half Poutine N/A" data-display_order="13">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7746/1637/1" data-dish="7746" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Half &amp; Half Poutine N/A">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7746" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7746]" value="Half &amp; Half Poutine N/A" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7746]" value="Half onions rings, half fries." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7746]" value="Small,Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[7746]" value="8.79,10.99" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7746]" value="7746">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7746/1637/1" data-dish="7746" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Half &amp; Half Poutine N/A">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7746" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                        </tbody>
                                        </table>
                                    </div>
                                </form>
                                                            </div>
                        </div>
                                            <div class="jarviswidget jarviswidget-color-darken course-listing jarviswidget-sortable" id="c_954" data-id="954" data-course="Salads" role="widget">
                            <header role="heading"><div class="jarviswidget-ctrls" role="menu">    <a href="javascript:void(0);" class="button-icon jarviswidget-toggle-btn" rel="tooltip" title="" data-placement="bottom" data-original-title="Collapse"><i class="fa fa-minus "></i></a>  </div>
                                <h2>
                                    <a href="#" class="rename" data-course-id="954" title="click to rename this course" style="color: #fff">
                                        Salads
                                    </a>
                                </h2>
                            <span class="jarviswidget-loader"><i class="fa fa-refresh fa-spin"></i></span></header>

                            <div id="course_954" class="widget-body" role="content">
                                                                <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_course_description" method="post" class="form_update_course">
                                    <input type="hidden" name="course_id" value="954">
                                    <div class="form-group">
                                        <label for="course_desc_954">course description</label>
                                        <div class="input-group input-group-sm">
                                            <textarea name="desc" id="course_desc_954" cols="1" rows="3" class="form-control"></textarea>
                                            <span class="input-group-btn">
										<button class="btn btn-primary">Update course description</button>
									</span>
                                        </div>
                                    </div>
                                </form>
                                
                                                                <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_dishes" method="post" class="form_update_course">
                                    <div class="table-responsive">
                                        <input type="hidden" name="course" value="954">
                                        <table class="table table-bordered table-striped table-condensed show-dishes" id="table_954">
                                            <thead>
                                            <tr>
                                                <td colspan="3" class="text-right">

                                                                                                    </td>
                                                <td colspan="2" class="text-right">
                                                    <span class="form-control-static">course available for - if none chosen, course will not show: </span>&nbsp;
                                                                                                            <label class="checkbox-inline">
                                                            <input type="checkbox" name="available_for[1]" value="1" data-name="1" data-course="954" checked="">
                                                            Takeout
                                                        </label>
                                                                                                            <label class="checkbox-inline">
                                                            <input type="checkbox" name="available_for[2]" value="2" data-name="2" data-course="954" checked="">
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
                                                                <a href="#mod_add_dish" class="add-dish-modal" data-course="954" data-toggle="modal">
                                                                    regular dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showCreateCombo/954/1637" data-target="#mod_create_combo" data-toggle="modal" data-backdrop="static" data-keyboard="true" data-course="954">
                                                                    combo dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showImportDish/954/1637" data-target="#mod_import_dish" class="add-dish-modal" data-course="954" data-toggle="modal" data-backdrop="static" data-keyboard="true">
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
                                                                <a href="#mod_add_dish" class="add-dish-modal" data-course="954" data-toggle="modal">
                                                                    regular dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showCreateCombo/954/1637" data-target="#mod_create_combo" data-toggle="modal" data-backdrop="static" data-keyboard="true" data-course="954">
                                                                    combo dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showImportDish/954/1637" data-target="#mod_import_dish" class="add-dish-modal" data-course="954" data-toggle="modal" data-backdrop="static" data-keyboard="true">
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
                                                    <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/manage_dishes/954" data-backdrop="static" data-keyboard="true" data-toggle="modal" data-target="#mod_manage_dishes" class="sort_dishes btn btn-default" data-course="954">dish order</a>
                                                    <button type="submit" class="btn btn-primary ">
                                                        Update
                                                    </button>
                                                </td>
                                                <td colspan="2">
                                                    <div class="input-group">
												<span class="input-group-btn">
													<a href="#" data-update-type="value" class="btn btn-default update-prices">value</a>
												</span>
                                                        <input type="number" name="update_prices_by" id="update_prices_by_954" class="form-control update_prices_by" value="0" placeholder="update prices by" min="0" step="0.1">
                                                        <span class="input-group-btn">
													<a href="#" data-update-type="percent" class="btn btn-default update-prices">percent</a>
												</span>
                                                    </div>
                                                </td>
                                                <td colspan="2"></td>
                                                <td class="text-right hidden-xs">
                                                    <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/manage_dishes/954" data-backdrop="static" data-keyboard="true" data-toggle="modal" data-target="#mod_manage_dishes" class="sort_dishes btn btn-default" data-course="954">dish order</a>
                                                    <button type="submit" class="btn btn-primary ">
                                                        Update
                                                    </button>
                                                </td>
                                            </tr>
                                            </tfoot>
                                            <tbody>
                                                                                                                                                <tr class="sort" data-id="7715" style="" data-dish="Garden Salad" data-display_order="0">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7715/1637/1" data-dish="7715" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Garden Salad">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7715" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7715]" value="Garden Salad" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7715]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7715]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7715]" value="12.09" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7715]" value="7715">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7715/1637/1" data-dish="7715" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Garden Salad">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7715" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7716" style="" data-dish="Caesar Salad" data-display_order="1">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7716/1637/1" data-dish="7716" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Caesar Salad">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7716" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7716]" value="Caesar Salad" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7716]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7716]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7716]" value="12.09" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7716]" value="7716">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7716/1637/1" data-dish="7716" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Caesar Salad">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7716" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7717" style="" data-dish="Chicken Caesar Salad" data-display_order="2">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7717/1637/1" data-dish="7717" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Chicken Caesar Salad">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7717" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7717]" value="Chicken Caesar Salad" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7717]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7717]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7717]" value="13.19" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7717]" value="7717">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7717/1637/1" data-dish="7717" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Chicken Caesar Salad">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7717" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7718" style="" data-dish="Greek Salad" data-display_order="3">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7718/1637/1" data-dish="7718" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Greek Salad">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7718" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7718]" value="Greek Salad" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7718]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7718]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7718]" value="13.19" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7718]" value="7718">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7718/1637/1" data-dish="7718" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Greek Salad">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7718" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7719" style="" data-dish="Kirkwood Salad" data-display_order="4">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7719/1637/1" data-dish="7719" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Kirkwood Salad">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7719" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7719]" value="Kirkwood Salad" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7719]" value="Green olives, green onions, croutons, creamy garlic, cheese." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7719]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7719]" value="13.19" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7719]" value="7719">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7719/1637/1" data-dish="7719" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Kirkwood Salad">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7719" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7720" style="" data-dish="Garden Salad Supreme" data-display_order="5">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7720/1637/1" data-dish="7720" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Garden Salad Supreme">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7720" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7720]" value="Garden Salad Supreme" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7720]" value="Ham, cheese with greens." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7720]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7720]" value="13.19" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7720]" value="7720">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7720/1637/1" data-dish="7720" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Garden Salad Supreme">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7720" class="btn btn-danger remove_dish" title="disable dish">
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
                                            <div class="jarviswidget jarviswidget-color-darken course-listing jarviswidget-sortable" id="c_959" data-id="959" data-course="Drinks" role="widget">
                            <header role="heading"><div class="jarviswidget-ctrls" role="menu">    <a href="javascript:void(0);" class="button-icon jarviswidget-toggle-btn" rel="tooltip" title="" data-placement="bottom" data-original-title="Collapse"><i class="fa fa-minus "></i></a>  </div>
                                <h2>
                                    <a href="#" class="rename" data-course-id="959" title="click to rename this course" style="color: #fff">
                                        Drinks
                                    </a>
                                </h2>
                            <span class="jarviswidget-loader"><i class="fa fa-refresh fa-spin"></i></span></header>

                            <div id="course_959" class="widget-body" role="content">
                                                                <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_course_description" method="post" class="form_update_course">
                                    <input type="hidden" name="course_id" value="959">
                                    <div class="form-group">
                                        <label for="course_desc_959">course description</label>
                                        <div class="input-group input-group-sm">
                                            <textarea name="desc" id="course_desc_959" cols="1" rows="3" class="form-control"></textarea>
                                            <span class="input-group-btn">
										<button class="btn btn-primary">Update course description</button>
									</span>
                                        </div>
                                    </div>
                                </form>
                                
                                                                <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_dishes" method="post" class="form_update_course">
                                    <div class="table-responsive">
                                        <input type="hidden" name="course" value="959">
                                        <table class="table table-bordered table-striped table-condensed show-dishes" id="table_959">
                                            <thead>
                                            <tr>
                                                <td colspan="3" class="text-right">

                                                                                                    </td>
                                                <td colspan="2" class="text-right">
                                                    <span class="form-control-static">course available for - if none chosen, course will not show: </span>&nbsp;
                                                                                                            <label class="checkbox-inline">
                                                            <input type="checkbox" name="available_for[1]" value="1" data-name="1" data-course="959" checked="">
                                                            Takeout
                                                        </label>
                                                                                                            <label class="checkbox-inline">
                                                            <input type="checkbox" name="available_for[2]" value="2" data-name="2" data-course="959" checked="">
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
                                                                <a href="#mod_add_dish" class="add-dish-modal" data-course="959" data-toggle="modal">
                                                                    regular dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showCreateCombo/959/1637" data-target="#mod_create_combo" data-toggle="modal" data-backdrop="static" data-keyboard="true" data-course="959">
                                                                    combo dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showImportDish/959/1637" data-target="#mod_import_dish" class="add-dish-modal" data-course="959" data-toggle="modal" data-backdrop="static" data-keyboard="true">
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
                                                                <a href="#mod_add_dish" class="add-dish-modal" data-course="959" data-toggle="modal">
                                                                    regular dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showCreateCombo/959/1637" data-target="#mod_create_combo" data-toggle="modal" data-backdrop="static" data-keyboard="true" data-course="959">
                                                                    combo dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showImportDish/959/1637" data-target="#mod_import_dish" class="add-dish-modal" data-course="959" data-toggle="modal" data-backdrop="static" data-keyboard="true">
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
                                                    <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/manage_dishes/959" data-backdrop="static" data-keyboard="true" data-toggle="modal" data-target="#mod_manage_dishes" class="sort_dishes btn btn-default" data-course="959">dish order</a>
                                                    <button type="submit" class="btn btn-primary ">
                                                        Update
                                                    </button>
                                                </td>
                                                <td colspan="2">
                                                    <div class="input-group">
												<span class="input-group-btn">
													<a href="#" data-update-type="value" class="btn btn-default update-prices">value</a>
												</span>
                                                        <input type="number" name="update_prices_by" id="update_prices_by_959" class="form-control update_prices_by" value="0" placeholder="update prices by" min="0" step="0.1">
                                                        <span class="input-group-btn">
													<a href="#" data-update-type="percent" class="btn btn-default update-prices">percent</a>
												</span>
                                                    </div>
                                                </td>
                                                <td colspan="2"></td>
                                                <td class="text-right hidden-xs">
                                                    <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/manage_dishes/959" data-backdrop="static" data-keyboard="true" data-toggle="modal" data-target="#mod_manage_dishes" class="sort_dishes btn btn-default" data-course="959">dish order</a>
                                                    <button type="submit" class="btn btn-primary ">
                                                        Update
                                                    </button>
                                                </td>
                                            </tr>
                                            </tfoot>
                                            <tbody>
                                                                                                                                                <tr class="sort" data-id="7782" style="" data-dish="Pepsi" data-display_order="1">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7782/1637/1" data-dish="7782" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Pepsi">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7782" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7782]" value="Pepsi" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7782]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7782]" value="Can" class="form-control size"></td>
                                                        <td><input type="text" name="price[7782]" value="1.93" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7782]" value="7782">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7782/1637/1" data-dish="7782" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Pepsi">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7782" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7783" style="" data-dish="Diet Pepsi" data-display_order="2">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7783/1637/1" data-dish="7783" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Diet Pepsi">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7783" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7783]" value="Diet Pepsi" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7783]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7783]" value="Can" class="form-control size"></td>
                                                        <td><input type="text" name="price[7783]" value="1.93" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7783]" value="7783">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7783/1637/1" data-dish="7783" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Diet Pepsi">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7783" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7784" style="" data-dish="Pepsi Zero" data-display_order="3">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7784/1637/1" data-dish="7784" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Pepsi Zero">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7784" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7784]" value="Pepsi Zero" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7784]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7784]" value="Can" class="form-control size"></td>
                                                        <td><input type="text" name="price[7784]" value="1.93" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7784]" value="7784">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7784/1637/1" data-dish="7784" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Pepsi Zero">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7784" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7785" style="" data-dish="Root Beer" data-display_order="4">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7785/1637/1" data-dish="7785" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Root Beer">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7785" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7785]" value="Root Beer" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7785]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7785]" value="Can" class="form-control size"></td>
                                                        <td><input type="text" name="price[7785]" value="1.93" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7785]" value="7785">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7785/1637/1" data-dish="7785" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Root Beer">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7785" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7786" style="" data-dish="7Up" data-display_order="5">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7786/1637/1" data-dish="7786" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="7Up">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7786" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7786]" value="7Up" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7786]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7786]" value="Can" class="form-control size"></td>
                                                        <td><input type="text" name="price[7786]" value="1.93" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7786]" value="7786">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7786/1637/1" data-dish="7786" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="7Up">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7786" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7787" style="" data-dish="Ginger Ale" data-display_order="6">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7787/1637/1" data-dish="7787" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Ginger Ale">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7787" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7787]" value="Ginger Ale" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7787]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7787]" value="Can" class="form-control size"></td>
                                                        <td><input type="text" name="price[7787]" value="1.93" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7787]" value="7787">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7787/1637/1" data-dish="7787" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Ginger Ale">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7787" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7789" style="" data-dish="Brisk" data-display_order="7">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7789/1637/1" data-dish="7789" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Brisk">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7789" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7789]" value="Brisk" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7789]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7789]" value="Can" class="form-control size"></td>
                                                        <td><input type="text" name="price[7789]" value="1.93" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7789]" value="7789">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7789/1637/1" data-dish="7789" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Brisk">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7789" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7788" style="" data-dish="Orange Crush" data-display_order="8">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7788/1637/1" data-dish="7788" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Orange Crush">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7788" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7788]" value="Orange Crush" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7788]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7788]" value="Can" class="form-control size"></td>
                                                        <td><input type="text" name="price[7788]" value="1.93" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7788]" value="7788">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7788/1637/1" data-dish="7788" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Orange Crush">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7788" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7790" style="" data-dish="Grape Crush" data-display_order="9">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7790/1637/1" data-dish="7790" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Grape Crush">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7790" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7790]" value="Grape Crush" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7790]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7790]" value="Can" class="form-control size"></td>
                                                        <td><input type="text" name="price[7790]" value="1.93" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7790]" value="7790">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7790/1637/1" data-dish="7790" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Grape Crush">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7790" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7791" style="" data-dish="Cream Soda" data-display_order="10">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7791/1637/1" data-dish="7791" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Cream Soda">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7791" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7791]" value="Cream Soda" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7791]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7791]" value="Can" class="form-control size"></td>
                                                        <td><input type="text" name="price[7791]" value="1.93" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7791]" value="7791">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7791/1637/1" data-dish="7791" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Cream Soda">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7791" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="10162" style="" data-dish="Dr.Pepper" data-display_order="11">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/10162/1637/1" data-dish="10162" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Dr.Pepper">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10162" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[10162]" value="Dr.Pepper" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[10162]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[10162]" value="Can" class="form-control size"></td>
                                                        <td><input type="text" name="price[10162]" value="1.93" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[10162]" value="10162">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/10162/1637/1" data-dish="10162" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Dr.Pepper">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10162" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="10163" style="" data-dish="Coke" data-display_order="12">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/10163/1637/1" data-dish="10163" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Coke">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10163" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[10163]" value="Coke" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[10163]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[10163]" value="Can" class="form-control size"></td>
                                                        <td><input type="text" name="price[10163]" value="1.93" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[10163]" value="10163">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/10163/1637/1" data-dish="10163" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Coke">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10163" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="10164" style="" data-dish="Diet Coke" data-display_order="13">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/10164/1637/1" data-dish="10164" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Diet Coke">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10164" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[10164]" value="Diet Coke" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[10164]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[10164]" value="Can" class="form-control size"></td>
                                                        <td><input type="text" name="price[10164]" value="1.93" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[10164]" value="10164">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/10164/1637/1" data-dish="10164" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Diet Coke">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10164" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="10165" style="" data-dish="Coke Zero" data-display_order="14">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/10165/1637/1" data-dish="10165" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Coke Zero">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10165" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[10165]" value="Coke Zero" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[10165]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[10165]" value="Can" class="form-control size"></td>
                                                        <td><input type="text" name="price[10165]" value="1.93" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[10165]" value="10165">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/10165/1637/1" data-dish="10165" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Coke Zero">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10165" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="10166" style="" data-dish="Sprite" data-display_order="15">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/10166/1637/1" data-dish="10166" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Sprite">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10166" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[10166]" value="Sprite" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[10166]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[10166]" value="Can" class="form-control size"></td>
                                                        <td><input type="text" name="price[10166]" value="1.93" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[10166]" value="10166">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/10166/1637/1" data-dish="10166" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Sprite">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10166" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="10167" style="" data-dish="Iced Tea" data-display_order="16">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/10167/1637/1" data-dish="10167" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Iced Tea">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10167" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[10167]" value="Iced Tea" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[10167]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[10167]" value="Can" class="form-control size"></td>
                                                        <td><input type="text" name="price[10167]" value="1.93" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[10167]" value="10167">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/10167/1637/1" data-dish="10167" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Iced Tea">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10167" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="10168" style="" data-dish="Fanta" data-display_order="17">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/10168/1637/1" data-dish="10168" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Fanta">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10168" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[10168]" value="Fanta" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[10168]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[10168]" value="Can" class="form-control size"></td>
                                                        <td><input type="text" name="price[10168]" value="1.93" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[10168]" value="10168">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/10168/1637/1" data-dish="10168" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Fanta">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10168" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="10177" style="" data-dish="OASIS Juice" data-display_order="18">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/10177/1637/1" data-dish="10177" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="OASIS Juice">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10177" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[10177]" value="OASIS Juice" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[10177]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[10177]" value="Apple,Mango,Orange,Grapefruit,Grape" class="form-control size"></td>
                                                        <td><input type="text" name="price[10177]" value="2.20,2.20,2.20,2.20,2.20" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[10177]" value="10177">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/10177/1637/1" data-dish="10177" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="OASIS Juice">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10177" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="10169" style="" data-dish="Water" data-display_order="19">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/10169/1637/1" data-dish="10169" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Water">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10169" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[10169]" value="Water" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[10169]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[10169]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[10169]" value="1.93" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[10169]" value="10169">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/10169/1637/1" data-dish="10169" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="Water">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10169" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="10180" style="background-color: #a90329" data-dish="TEST" data-display_order="20">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/10180/1637/1" data-dish="10180" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="TEST">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10180" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[10180]" value="TEST" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[10180]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[10180]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[10180]" value="1.10" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[10180]" value="10180">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/10180/1637/1" data-dish="10180" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="TEST">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="10180" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                        </tbody>
                                        </table>
                                    </div>
                                </form>
                                                            </div>
                        </div>
                    
                </div>
            </div>

## Phase 1: Scrape all modifier groups 
Access this url https://aggregator-admin.menu.ca/index.php/restaurants/edit/[legacy_v2_id]/menu/1/ingredient_groups using the legacy_V2_id of each of the restaurants to be scraped.

All modifier groups are divided in 6 categories: Dressings, Sauces, Dips, Drinks, Side Dishes, Cooking Methods, Deserts.
One category can contain one or more modifier groups

For example, for the Capital Bites restaurant, the Crusts Crusts category contains a modifier group called Crust type:
<div class="jarviswidget jarviswidget-color-darken jarviswidget-sortable" role="widget">
    <header role="heading">
        <div class="jarviswidget-ctrls" role="menu">
            <a href="javascript:void(0);" class="button-icon jarviswidget-toggle-btn" rel="tooltip" title="" data-placement="bottom" data-original-title="Collapse"><i class="fa fa-minus"></i></a>
        </div>
        <h2>Crusts</h2>
        <span class="jarviswidget-loader" style="display: none;"><i class="fa fa-refresh fa-spin"></i></span>
    </header>
    <div class="widget-body" style="" role="content">
        <header class="text-right" style="margin-bottom: 5px;">
            <a href="https://aggregator-admin.menu.ca/index.php/restaurants/edit/1670/menu/1/add_ingredient_group/crust" class="btn btn-default ">
                <i class="fa fa-plus"></i> add a new group
            </a>
        </header>
        <section class="row">
            <div class="col-sm-4" style="margin-bottom:5px;">
                <a href="https://aggregator-admin.menu.ca/index.php/restaurants/edit/1670/menu/1/edit_ingredient_groups/crust/570" class="btn btn-default  btn-block text-left">Crust Type</a>
            </div>
        </section>
    </div>
</div>

Now to access the modifiers of each modifier group you must click the anchor element: <a href="https://aggregator-admin.menu.ca/index.php/restaurants/edit/1670/menu/1/edit_ingredient_groups/crust/570" class="btn btn-default  btn-block text-left">Crust Type</a>. This will open an edit group element with this structure:
<div class="col-sm-12 col-md-5">
                    <div class="jarviswidget jarviswidget-color-darken jarviswidget-sortable" role="widget">
                        <header role="heading"><div class="jarviswidget-ctrls" role="menu">    <a href="javascript:void(0);" class="button-icon jarviswidget-toggle-btn" rel="tooltip" title="" data-placement="bottom" data-original-title="Collapse"><i class="fa fa-minus"></i></a>  </div>
                            <h2>edit group</h2>
                        <span class="jarviswidget-loader" style="display: none;"><i class="fa fa-refresh fa-spin"></i></span></header>
                        <div class="widget-body" role="content" style="display: block;">
                                                            <div class="well">
                                    <h3 style="margin: 0">Dishes using this group</h3>
                                                                            <p class="form-control-static">\\Pizza \ Plain Pizza</p>
                                                                            <p class="form-control-static">\\Pizza \ One Topping Pizza</p>
                                                                            <p class="form-control-static">\\Pizza \ Two Toppings Pizza</p>
                                                                            <p class="form-control-static">\\Pizza \ Combination Pizza</p>
                                                                            <p class="form-control-static">\\Pizza \ Combination with Olives</p>
                                                                            <p class="form-control-static">\\Pizza \ Canadian Pizza</p>
                                                                            <p class="form-control-static">\\Pizza \ Hawaiian Pizza</p>
                                                                            <p class="form-control-static">\\Pizza \ Hawaiian with Bacon</p>
                                                                            <p class="form-control-static">\\Pizza \ Vegetarian Pizza</p>
                                                                            <p class="form-control-static">\\Pizza \ Capital Special Pizza</p>
                                                                            <p class="form-control-static">\\Pizza \ Steak Pizza</p>
                                                                            <p class="form-control-static">\\Pizza \ Shawarma Pizza</p>
                                                                            <p class="form-control-static">\\Pizza \ Greek Pizza</p>
                                                                            <p class="form-control-static">\\Pizza \ Meat Lovers Pizza</p>
                                                                            <p class="form-control-static">\\Pizza \ House Special Pizza</p>
                                                                    </div>
                                                        <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_group_content" method="post" class="form_update_group">
                                <input type="hidden" name="group_id" value="570">
                                <input type="hidden" name="group_type" value="crust">
                                <input type="hidden" name="language_id" value="1">
                                <div class="form-group">
                                    <label for="group_name">group name</label>
                                    <input type="text" name="group_name" id="group_name" class="form-control" value="Crust Type">
                                </div>
                                <p class="text-right"><a href="#" class="check_all">check all</a></p>
                                <div class="ingredients">
                                                                            <div class="row form-group">
                                            <div class="col-sm-10">
                                                <div class="input-group">
											<span class="input-group-addon text-left" style="min-width: 175px; overflow-y: auto">
												<label class="label_selected_ingredient">
													<input type="checkbox" name="ingredient[hash][]" value="495c4fd6" class="selected_ingredient_checkbox" checked="">
													Thick Crust
												</label>
											</span>
                                                    <input data-price="true" type="text" name="ingredient[price][]" value="0.00" class="form-control" placeholder="enter price">
                                                </div>
                                            </div>
                                            <div class="col-sm-2">
                                                <p class="form-control-static">
                                                    <a href="#" class="fill-prices" data-type="crust">
                                                        <i class="fa fa-plus"></i> Fill prices
                                                    </a>
                                                </p>
                                            </div>
                                        </div>
                                                                            <div class="row form-group">
                                            <div class="col-sm-10">
                                                <div class="input-group">
											<span class="input-group-addon text-left" style="min-width: 175px; overflow-y: auto">
												<label class="label_selected_ingredient">
													<input type="checkbox" name="ingredient[hash][]" value="8df400d8" class="selected_ingredient_checkbox" checked="">
													Thin Crust
												</label>
											</span>
                                                    <input data-price="true" type="text" name="ingredient[price][]" value="0.00" class="form-control" placeholder="enter price">
                                                </div>
                                            </div>
                                            <div class="col-sm-2">
                                                <p class="form-control-static">
                                                    <a href="#" class="fill-prices" data-type="crust">
                                                        <i class="fa fa-plus"></i> Fill prices
                                                    </a>
                                                </p>
                                            </div>
                                        </div>                                   
                                                                            <div class="row form-group">
                                            <div class="col-sm-10">
                                                <div class="input-group">
											<span class="input-group-addon text-left" style="min-width: 175px; overflow-y: auto">
												<label class="label_selected_ingredient">
													<input type="checkbox" name="ingredient[hash][]" value="dcff197b" class="selected_ingredient_checkbox">
													Beef Pepperoni
												</label>
											</span>
                                                    <input data-price="true" disabled="" type="text" name="ingredient[price][]" value="" class="form-control" placeholder="enter price">
                                                </div>
                                            </div>
                                            <div class="col-sm-2">
                                                <p class="form-control-static">
                                                    <a href="#" class="fill-prices" data-type="crust">
                                                        <i class="fa fa-plus"></i> Fill prices
                                                    </a>
                                                </p>
                                            </div>
                                        </div>
                                                                            <div class="row form-group">
                                            <div class="col-sm-10">
                                                <div class="input-group">
											<span class="input-group-addon text-left" style="min-width: 175px; overflow-y: auto">
												<label class="label_selected_ingredient">
													<input type="checkbox" name="ingredient[hash][]" value="9827af6a" class="selected_ingredient_checkbox">
													Beef
												</label>
											</span>
                                                    <input data-price="true" disabled="" type="text" name="ingredient[price][]" value="" class="form-control" placeholder="enter price">
                                                </div>
                                            </div>
                                            <div class="col-sm-2">
                                                <p class="form-control-static">
                                                    <a href="#" class="fill-prices" data-type="crust">
                                                        <i class="fa fa-plus"></i> Fill prices
                                                    </a>
                                                </p>
                                            </div>
                                        </div>
                                                                            <div class="row form-group">
                                            <div class="col-sm-10">
                                                <div class="input-group">
											<span class="input-group-addon text-left" style="min-width: 175px; overflow-y: auto">
												<label class="label_selected_ingredient">
													<input type="checkbox" name="ingredient[hash][]" value="1e268d32" class="selected_ingredient_checkbox">
													Sausage
												</label>
											</span>
                                                    <input data-price="true" disabled="" type="text" name="ingredient[price][]" value="" class="form-control" placeholder="enter price">
                                                </div>
                                            </div>
                                            <div class="col-sm-2">
                                                <p class="form-control-static">
                                                    <a href="#" class="fill-prices" data-type="crust">
                                                        <i class="fa fa-plus"></i> Fill prices
                                                    </a>
                                                </p>
                                            </div>
                                        </div>
                                                                            <div class="row form-group">
                                            <div class="col-sm-10">
                                                <div class="input-group">
											<span class="input-group-addon text-left" style="min-width: 175px; overflow-y: auto">
												<label class="label_selected_ingredient">
													<input type="checkbox" name="ingredient[hash][]" value="d2f6e64d" class="selected_ingredient_checkbox">
													Beef Salami
												</label>
											</span>
                                                    <input data-price="true" disabled="" type="text" name="ingredient[price][]" value="" class="form-control" placeholder="enter price">
                                                </div>
                                            </div>
                                            <div class="col-sm-2">
                                                <p class="form-control-static">
                                                    <a href="#" class="fill-prices" data-type="crust">
                                                        <i class="fa fa-plus"></i> Fill prices
                                                    </a>
                                                </p>
                                            </div>
                                        </div>
                                                                            <div class="row form-group">
                                            <div class="col-sm-10">
                                                <div class="input-group">
											<span class="input-group-addon text-left" style="min-width: 175px; overflow-y: auto">
												<label class="label_selected_ingredient">
													<input type="checkbox" name="ingredient[hash][]" value="9b538045" class="selected_ingredient_checkbox">
													Beef Bacon
												</label>
											</span>
                                                    <input data-price="true" disabled="" type="text" name="ingredient[price][]" value="" class="form-control" placeholder="enter price">
                                                </div>
                                            </div>
                                            <div class="col-sm-2">
                                                <p class="form-control-static">
                                                    <a href="#" class="fill-prices" data-type="crust">
                                                        <i class="fa fa-plus"></i> Fill prices
                                                    </a>
                                                </p>
                                            </div>
                                        </div>
                                                                            <div class="row form-group">
                                            <div class="col-sm-10">
                                                <div class="input-group">
											<span class="input-group-addon text-left" style="min-width: 175px; overflow-y: auto">
												<label class="label_selected_ingredient">
													<input type="checkbox" name="ingredient[hash][]" value="df9abe22" class="selected_ingredient_checkbox">
													Chicken
												</label>
											</span>
                                                    <input data-price="true" disabled="" type="text" name="ingredient[price][]" value="" class="form-control" placeholder="enter price">
                                                </div>
                                            </div>
                                            <div class="col-sm-2">
                                                <p class="form-control-static">
                                                    <a href="#" class="fill-prices" data-type="crust">
                                                        <i class="fa fa-plus"></i> Fill prices
                                                    </a>
                                                </p>
                                            </div>
                                        </div>
                                                                            <div class="row form-group">
                                            <div class="col-sm-10">
                                                <div class="input-group">
											<span class="input-group-addon text-left" style="min-width: 175px; overflow-y: auto">
												<label class="label_selected_ingredient">
													<input type="checkbox" name="ingredient[hash][]" value="6fe9bbc3" class="selected_ingredient_checkbox">
													Steak
												</label>
											</span>
                                                    <input data-price="true" disabled="" type="text" name="ingredient[price][]" value="" class="form-control" placeholder="enter price">
                                                </div>
                                            </div>
                                            <div class="col-sm-2">
                                                <p class="form-control-static">
                                                    <a href="#" class="fill-prices" data-type="crust">
                                                        <i class="fa fa-plus"></i> Fill prices
                                                    </a>
                                                </p>
                                            </div>
                                        </div>
                                                                            <div class="row form-group">
                                            <div class="col-sm-10">
                                                <div class="input-group">
											<span class="input-group-addon text-left" style="min-width: 175px; overflow-y: auto">
												<label class="label_selected_ingredient">
													<input type="checkbox" name="ingredient[hash][]" value="85406295" class="selected_ingredient_checkbox">
													Donair
												</label>
											</span>
                                                    <input data-price="true" disabled="" type="text" name="ingredient[price][]" value="" class="form-control" placeholder="enter price">
                                                </div>
                                            </div>
                                            <div class="col-sm-2">
                                                <p class="form-control-static">
                                                    <a href="#" class="fill-prices" data-type="crust">
                                                        <i class="fa fa-plus"></i> Fill prices
                                                    </a>
                                                </p>
                                            </div>
                                        </div>
                                                                            <div class="row form-group">
                                            <div class="col-sm-10">
                                                <div class="input-group">
											<span class="input-group-addon text-left" style="min-width: 175px; overflow-y: auto">
												<label class="label_selected_ingredient">
													<input type="checkbox" name="ingredient[hash][]" value="9dcd3252" class="selected_ingredient_checkbox">
													Ground Beef
												</label>
											</span>
                                                    <input data-price="true" disabled="" type="text" name="ingredient[price][]" value="" class="form-control" placeholder="enter price">
                                                </div>
                                            </div>
                                            <div class="col-sm-2">
                                                <p class="form-control-static">
                                                    <a href="#" class="fill-prices" data-type="crust">
                                                        <i class="fa fa-plus"></i> Fill prices
                                                    </a>
                                                </p>
                                            </div>
                                        </div>
                                                                            <div class="row form-group">
                                            <div class="col-sm-10">
                                                <div class="input-group">
											<span class="input-group-addon text-left" style="min-width: 175px; overflow-y: auto">
												<label class="label_selected_ingredient">
													<input type="checkbox" name="ingredient[hash][]" value="6217b8cc" class="selected_ingredient_checkbox">
													Anchovies
												</label>
											</span>
                                                    <input data-price="true" disabled="" type="text" name="ingredient[price][]" value="" class="form-control" placeholder="enter price">
                                                </div>
                                            </div>
                                            <div class="col-sm-2">
                                                <p class="form-control-static">
                                                    <a href="#" class="fill-prices" data-type="crust">
                                                        <i class="fa fa-plus"></i> Fill prices
                                                    </a>
                                                </p>
                                            </div>
                                        </div>
                                                                            <div class="row form-group">
                                            <div class="col-sm-10">
                                                <div class="input-group">
											<span class="input-group-addon text-left" style="min-width: 175px; overflow-y: auto">
												<label class="label_selected_ingredient">
													<input type="checkbox" name="ingredient[hash][]" value="edb91cd1" class="selected_ingredient_checkbox">
													Mushrooms
												</label>
											</span>
                                                    <input data-price="true" disabled="" type="text" name="ingredient[price][]" value="" class="form-control" placeholder="enter price">
                                                </div>
                                            </div>
                                            <div class="col-sm-2">
                                                <p class="form-control-static">
                                                    <a href="#" class="fill-prices" data-type="crust">
                                                        <i class="fa fa-plus"></i> Fill prices
                                                    </a>
                                                </p>
                                            </div>
                                        </div>
                                                                            <div class="row form-group">
                                            <div class="col-sm-10">
                                                <div class="input-group">
											<span class="input-group-addon text-left" style="min-width: 175px; overflow-y: auto">
												<label class="label_selected_ingredient">
													<input type="checkbox" name="ingredient[hash][]" value="4208d827" class="selected_ingredient_checkbox">
													Onions
												</label>
											</span>
                                                    <input data-price="true" disabled="" type="text" name="ingredient[price][]" value="" class="form-control" placeholder="enter price">
                                                </div>
                                            </div>
                                            <div class="col-sm-2">
                                                <p class="form-control-static">
                                                    <a href="#" class="fill-prices" data-type="crust">
                                                        <i class="fa fa-plus"></i> Fill prices
                                                    </a>
                                                </p>
                                            </div>
                                        </div>
                                                                            <div class="row form-group">
                                            <div class="col-sm-10">
                                                <div class="input-group">
											<span class="input-group-addon text-left" style="min-width: 175px; overflow-y: auto">
												<label class="label_selected_ingredient">
													<input type="checkbox" name="ingredient[hash][]" value="6da25ef7" class="selected_ingredient_checkbox">
													Tomatoes
												</label>
											</span>
                                                    <input data-price="true" disabled="" type="text" name="ingredient[price][]" value="" class="form-control" placeholder="enter price">
                                                </div>
                                            </div>
                                            <div class="col-sm-2">
                                                <p class="form-control-static">
                                                    <a href="#" class="fill-prices" data-type="crust">
                                                        <i class="fa fa-plus"></i> Fill prices
                                                    </a>
                                                </p>
                                            </div>
                                        </div>
                                                                            <div class="row form-group">
                                            <div class="col-sm-10">
                                                <div class="input-group">
											<span class="input-group-addon text-left" style="min-width: 175px; overflow-y: auto">
												<label class="label_selected_ingredient">
													<input type="checkbox" name="ingredient[hash][]" value="a92c4b67" class="selected_ingredient_checkbox">
													Green Peppers
												</label>
											</span>
                                                    <input data-price="true" disabled="" type="text" name="ingredient[price][]" value="" class="form-control" placeholder="enter price">
                                                </div>
                                            </div>
                                            <div class="col-sm-2">
                                                <p class="form-control-static">
                                                    <a href="#" class="fill-prices" data-type="crust">
                                                        <i class="fa fa-plus"></i> Fill prices
                                                    </a>
                                                </p>
                                            </div>
                                        </div>
                                                                            <div class="row form-group">
                                            <div class="col-sm-10">
                                                <div class="input-group">
											<span class="input-group-addon text-left" style="min-width: 175px; overflow-y: auto">
												<label class="label_selected_ingredient">
													<input type="checkbox" name="ingredient[hash][]" value="093e33cc" class="selected_ingredient_checkbox">
													Green Olives
												</label>
											</span>
                                                    <input data-price="true" disabled="" type="text" name="ingredient[price][]" value="" class="form-control" placeholder="enter price">
                                                </div>
                                            </div>
                                            <div class="col-sm-2">
                                                <p class="form-control-static">
                                                    <a href="#" class="fill-prices" data-type="crust">
                                                        <i class="fa fa-plus"></i> Fill prices
                                                    </a>
                                                </p>
                                            </div>
                                        </div>
                                                                            <div class="row form-group">
                                            <div class="col-sm-10">
                                                <div class="input-group">
											<span class="input-group-addon text-left" style="min-width: 175px; overflow-y: auto">
												<label class="label_selected_ingredient">
													<input type="checkbox" name="ingredient[hash][]" value="affe9808" class="selected_ingredient_checkbox">
													Black Olives
												</label>
											</span>
                                                    <input data-price="true" disabled="" type="text" name="ingredient[price][]" value="" class="form-control" placeholder="enter price">
                                                </div>
                                            </div>
                                            <div class="col-sm-2">
                                                <p class="form-control-static">
                                                    <a href="#" class="fill-prices" data-type="crust">
                                                        <i class="fa fa-plus"></i> Fill prices
                                                    </a>
                                                </p>
                                            </div>
                                        </div>
                                                                            <div class="row form-group">
                                            <div class="col-sm-10">
                                                <div class="input-group">
											<span class="input-group-addon text-left" style="min-width: 175px; overflow-y: auto">
												<label class="label_selected_ingredient">
													<input type="checkbox" name="ingredient[hash][]" value="313705fa" class="selected_ingredient_checkbox">
													Hot Peppers
												</label>
											</span>
                                                    <input data-price="true" disabled="" type="text" name="ingredient[price][]" value="" class="form-control" placeholder="enter price">
                                                </div>
                                            </div>
                                            <div class="col-sm-2">
                                                <p class="form-control-static">
                                                    <a href="#" class="fill-prices" data-type="crust">
                                                        <i class="fa fa-plus"></i> Fill prices
                                                    </a>
                                                </p>
                                            </div>
                                        </div>
                                                                            <div class="row form-group">
                                            <div class="col-sm-10">
                                                <div class="input-group">
											<span class="input-group-addon text-left" style="min-width: 175px; overflow-y: auto">
												<label class="label_selected_ingredient">
													<input type="checkbox" name="ingredient[hash][]" value="738c670d" class="selected_ingredient_checkbox">
													Feta
												</label>
											</span>
                                                    <input data-price="true" disabled="" type="text" name="ingredient[price][]" value="" class="form-control" placeholder="enter price">
                                                </div>
                                            </div>
                                            <div class="col-sm-2">
                                                <p class="form-control-static">
                                                    <a href="#" class="fill-prices" data-type="crust">
                                                        <i class="fa fa-plus"></i> Fill prices
                                                    </a>
                                                </p>
                                            </div>
                                        </div>
                                                                    </div>
                                <p class="text-right">                                    
                                    <button type="submit" class="btn btn-primary ">
                                        <i class="fa fa-save"></i> Update group
                                    </button>
                                </p>
                            </form>
                        </div>
                    </div>
                </div>




Some restaurants have modifier groups and others not.
- A restaurant with no modifier group will show this html markup:
<div class="row">
            <div class="col-sm-12 col-md-12">
                                    <div class="jarviswidget jarviswidget-color-darken jarviswidget-sortable" role="widget">
                        <header role="heading"><div class="jarviswidget-ctrls" role="menu">    <a href="javascript:void(0);" class="button-icon jarviswidget-toggle-btn" rel="tooltip" title="" data-placement="bottom" data-original-title="Collapse"><i class="fa fa-minus"></i></a>  </div>
                            <h2>Crusts</h2>
                        <span class="jarviswidget-loader" style="display: none;"><i class="fa fa-refresh fa-spin"></i></span></header>
                        <div class="widget-body" style="" role="content">
                            <header class="text-right" style="margin-bottom: 5px;">
                                <a href="https://aggregator-admin.menu.ca/index.php/restaurants/edit/1678/menu/1/add_ingredient_group/crust" class="btn btn-default ">
                                    <i class="fa fa-plus"></i> add a new group
                                </a>
                            </header>
                            <section class="row">
                                                            </section>
                        </div>
                    </div>
                                    <div class="jarviswidget jarviswidget-color-darken jarviswidget-sortable" role="widget">
                        <header role="heading"><div class="jarviswidget-ctrls" role="menu">    <a href="javascript:void(0);" class="button-icon jarviswidget-toggle-btn" rel="tooltip" title="" data-placement="bottom" data-original-title="Collapse"><i class="fa fa-minus"></i></a>  </div>
                            <h2>Custom ingredients</h2>
                        <span class="jarviswidget-loader" style="display: none;"><i class="fa fa-refresh fa-spin"></i></span></header>
                        <div class="widget-body" style="" role="content">
                            <header class="text-right" style="margin-bottom: 5px;">
                                <a href="https://aggregator-admin.menu.ca/index.php/restaurants/edit/1678/menu/1/add_ingredient_group/custom_ingredient" class="btn btn-default ">
                                    <i class="fa fa-plus"></i> add a new group
                                </a>
                            </header>
                            <section class="row">
                                                            </section>
                        </div>
                    </div>
                                    <div class="jarviswidget jarviswidget-color-darken jarviswidget-sortable" role="widget">
                        <header role="heading"><div class="jarviswidget-ctrls" role="menu">    <a href="javascript:void(0);" class="button-icon jarviswidget-toggle-btn" rel="tooltip" title="" data-placement="bottom" data-original-title="Collapse"><i class="fa fa-minus"></i></a>  </div>
                            <h2>Premium toppings</h2>
                        <span class="jarviswidget-loader" style="display: none;"><i class="fa fa-refresh fa-spin"></i></span></header>
                        <div class="widget-body" style="" role="content">
                            <header class="text-right" style="margin-bottom: 5px;">
                                <a href="https://aggregator-admin.menu.ca/index.php/restaurants/edit/1678/menu/1/add_ingredient_group/premium_toppings" class="btn btn-default ">
                                    <i class="fa fa-plus"></i> add a new group
                                </a>
                            </header>
                            <section class="row">
                                                            </section>
                        </div>
                    </div>
                                    <div class="jarviswidget jarviswidget-color-darken jarviswidget-sortable" role="widget">
                        <header role="heading"><div class="jarviswidget-ctrls" role="menu">    <a href="javascript:void(0);" class="button-icon jarviswidget-toggle-btn" rel="tooltip" title="" data-placement="bottom" data-original-title="Collapse"><i class="fa fa-minus"></i></a>  </div>
                            <h2>Extras</h2>
                        <span class="jarviswidget-loader" style="display: none;"><i class="fa fa-refresh fa-spin"></i></span></header>
                        <div class="widget-body" style="" role="content">
                            <header class="text-right" style="margin-bottom: 5px;">
                                <a href="https://aggregator-admin.menu.ca/index.php/restaurants/edit/1678/menu/1/add_ingredient_group/extra" class="btn btn-default ">
                                    <i class="fa fa-plus"></i> add a new group
                                </a>
                            </header>
                            <section class="row">
                                                            </section>
                        </div>
                    </div>
                                    <div class="jarviswidget jarviswidget-color-darken jarviswidget-sortable" role="widget">
                        <header role="heading"><div class="jarviswidget-ctrls" role="menu">    <a href="javascript:void(0);" class="button-icon jarviswidget-toggle-btn" rel="tooltip" title="" data-placement="bottom" data-original-title="Collapse"><i class="fa fa-minus"></i></a>  </div>
                            <h2>Dressings</h2>
                        <span class="jarviswidget-loader" style="display: none;"><i class="fa fa-refresh fa-spin"></i></span></header>
                        <div class="widget-body" style="" role="content">
                            <header class="text-right" style="margin-bottom: 5px;">
                                <a href="https://aggregator-admin.menu.ca/index.php/restaurants/edit/1678/menu/1/add_ingredient_group/dressing" class="btn btn-default ">
                                    <i class="fa fa-plus"></i> add a new group
                                </a>
                            </header>
                            <section class="row">
                                                            </section>
                        </div>
                    </div>
                                    <div class="jarviswidget jarviswidget-color-darken jarviswidget-sortable" role="widget">
                        <header role="heading"><div class="jarviswidget-ctrls" role="menu">    <a href="javascript:void(0);" class="button-icon jarviswidget-toggle-btn" rel="tooltip" title="" data-placement="bottom" data-original-title="Collapse"><i class="fa fa-minus"></i></a>  </div>
                            <h2>Sauces</h2>
                        <span class="jarviswidget-loader" style="display: none;"><i class="fa fa-refresh fa-spin"></i></span></header>
                        <div class="widget-body" style="" role="content">
                            <header class="text-right" style="margin-bottom: 5px;">
                                <a href="https://aggregator-admin.menu.ca/index.php/restaurants/edit/1678/menu/1/add_ingredient_group/sauce" class="btn btn-default ">
                                    <i class="fa fa-plus"></i> add a new group
                                </a>
                            </header>
                            <section class="row">
                                                            </section>
                        </div>
                    </div>
                                    <div class="jarviswidget jarviswidget-color-darken jarviswidget-sortable" role="widget">
                        <header role="heading"><div class="jarviswidget-ctrls" role="menu">    <a href="javascript:void(0);" class="button-icon jarviswidget-toggle-btn" rel="tooltip" title="" data-placement="bottom" data-original-title="Collapse"><i class="fa fa-minus"></i></a>  </div>
                            <h2>Dips</h2>
                        <span class="jarviswidget-loader" style="display: none;"><i class="fa fa-refresh fa-spin"></i></span></header>
                        <div class="widget-body" style="" role="content">
                            <header class="text-right" style="margin-bottom: 5px;">
                                <a href="https://aggregator-admin.menu.ca/index.php/restaurants/edit/1678/menu/1/add_ingredient_group/dip" class="btn btn-default ">
                                    <i class="fa fa-plus"></i> add a new group
                                </a>
                            </header>
                            <section class="row">
                                                            </section>
                        </div>
                    </div>
                                    <div class="jarviswidget jarviswidget-color-darken jarviswidget-sortable" role="widget">
                        <header role="heading"><div class="jarviswidget-ctrls" role="menu">    <a href="javascript:void(0);" class="button-icon jarviswidget-toggle-btn" rel="tooltip" title="" data-placement="bottom" data-original-title="Collapse"><i class="fa fa-minus"></i></a>  </div>
                            <h2>Drinks</h2>
                        <span class="jarviswidget-loader" style="display: none;"><i class="fa fa-refresh fa-spin"></i></span></header>
                        <div class="widget-body" style="" role="content">
                            <header class="text-right" style="margin-bottom: 5px;">
                                <a href="https://aggregator-admin.menu.ca/index.php/restaurants/edit/1678/menu/1/add_ingredient_group/drink" class="btn btn-default ">
                                    <i class="fa fa-plus"></i> add a new group
                                </a>
                            </header>
                            <section class="row">
                                                            </section>
                        </div>
                    </div>
                                    <div class="jarviswidget jarviswidget-color-darken jarviswidget-sortable" role="widget">
                        <header role="heading"><div class="jarviswidget-ctrls" role="menu">    <a href="javascript:void(0);" class="button-icon jarviswidget-toggle-btn" rel="tooltip" title="" data-placement="bottom" data-original-title="Collapse"><i class="fa fa-minus"></i></a>  </div>
                            <h2>Side dishes</h2>
                        <span class="jarviswidget-loader" style="display: none;"><i class="fa fa-refresh fa-spin"></i></span></header>
                        <div class="widget-body" style="" role="content">
                            <header class="text-right" style="margin-bottom: 5px;">
                                <a href="https://aggregator-admin.menu.ca/index.php/restaurants/edit/1678/menu/1/add_ingredient_group/side_dish" class="btn btn-default ">
                                    <i class="fa fa-plus"></i> add a new group
                                </a>
                            </header>
                            <section class="row">
                                                            </section>
                        </div>
                    </div>
                                    <div class="jarviswidget jarviswidget-color-darken jarviswidget-sortable" role="widget">
                        <header role="heading"><div class="jarviswidget-ctrls" role="menu">    <a href="javascript:void(0);" class="button-icon jarviswidget-toggle-btn" rel="tooltip" title="" data-placement="bottom" data-original-title="Collapse"><i class="fa fa-minus"></i></a>  </div>
                            <h2>Cooking method</h2>
                        <span class="jarviswidget-loader" style="display: none;"><i class="fa fa-refresh fa-spin"></i></span></header>
                        <div class="widget-body" style="" role="content">
                            <header class="text-right" style="margin-bottom: 5px;">
                                <a href="https://aggregator-admin.menu.ca/index.php/restaurants/edit/1678/menu/1/add_ingredient_group/cook_method" class="btn btn-default ">
                                    <i class="fa fa-plus"></i> add a new group
                                </a>
                            </header>
                            <section class="row">
                                                            </section>
                        </div>
                    </div>
                                    <div class="jarviswidget jarviswidget-color-darken jarviswidget-sortable" role="widget">
                        <header role="heading"><div class="jarviswidget-ctrls" role="menu">    <a href="javascript:void(0);" class="button-icon jarviswidget-toggle-btn" rel="tooltip" title="" data-placement="bottom" data-original-title="Collapse"><i class="fa fa-minus"></i></a>  </div>
                            <h2>Deserts</h2>
                        <span class="jarviswidget-loader" style="display: none;"><i class="fa fa-refresh fa-spin"></i></span></header>
                        <div class="widget-body" style="" role="content">
                            <header class="text-right" style="margin-bottom: 5px;">
                                <a href="https://aggregator-admin.menu.ca/index.php/restaurants/edit/1678/menu/1/add_ingredient_group/desert" class="btn btn-default ">
                                    <i class="fa fa-plus"></i> add a new group
                                </a>
                            </header>
                            <section class="row">
                                                            </section>
                        </div>
                    </div>
                            </div>  
</div>

If you enocunter this layout, it means the restaurant does not have modifier groups and you can continue with the next one.

- A re











_________________________________________________________________________________________________


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