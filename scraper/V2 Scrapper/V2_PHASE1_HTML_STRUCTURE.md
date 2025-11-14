# V2 Phase 1: HTML Structure Guide

**Critical Reference for Phase 1 Implementation**

---

## Phase 1 Workflow

### Step 1: Navigate to Restaurant List
**URL**: `https://aggregator-admin.menu.ca/index.php/restaurants/show/active`

**Table Element**: `<table class="table table-condensed table-striped table-responsive table-bordered" id="restaurantList"></table>`

### Step 2: Find Restaurant Row
Each restaurant is in a `<tr>` element within the table.

**Example** (Chicco Shawarma Cantley):
```html
<tr>
    <td class="text-left">
        <a href="https://aggregator-admin.menu.ca/index.php/restaurants/edit/1658/info" class="btn btn-default btn-xs">
            <i class="glyphicon glyphicon-edit"></i> Edit
        </a>
    </td>
    <td>Chicco Shawarma Cantley</td>
    <td>435 Montée de la Source</td>
    <td><a href="tel:(819) 607-0712">(819) 607-0712</a></td>
</tr>
```

**Key Data**:
- **Edit Link**: Extract `href` attribute → Contains V2 restaurant ID (e.g., `1658`)
- **Restaurant Name**: Second `<td>` element
- **Address**: Third `<td>` element
- **Phone**: Fourth `<td>` element

### Step 3: Navigate to Restaurant Menu
Click the "Edit" button, then navigate to Menu section.

**Menu Navigation**:
1. Click: `<a href="https://aggregator-admin.menu.ca/index.php/restaurants/edit/1658/menu" class="dropdown-toggle" data-toggle="dropdown">Menu<span class="caret"></span></a>`
2. Then click: `<a href="https://aggregator-admin.menu.ca/index.php/restaurants/edit/1658/menu/restaurant">Restaurant</a>`

**Menu URL Pattern**: `https://aggregator-admin.menu.ca/index.php/restaurants/edit/{RESTAURANT_ID}/menu/restaurant`

### Step 4: Check for English vs French Menu
**Check for this div**: `<div class="col-sm-12" id="sortable"></div>`

- **If exists**: English menu (proceed with current page)
- **If NOT exists**: French menu available

**For French menus**:
- Click: `<a href="https://aggregator-admin.menu.ca/index.php/restaurants/edit/1658/menu/2/restaurant" class="btn btn-default">French</a>`
- New URL pattern: `https://aggregator-admin.menu.ca/index.php/restaurants/edit/{RESTAURANT_ID}/menu/2/restaurant`

---

## Extracting Courses and Dishes

### Course Container Structure
Each course is in a `<div>` with class `jarviswidget jarviswidget-color-darken course-listing jarviswidget-sortable`

**Course Element**:
```html
<div class="jarviswidget jarviswidget-color-darken course-listing jarviswidget-sortable" 
     id="c_1122" 
     data-id="1122" 
     data-course="Shawarmas" 
     role="widget">
    <header role="heading">
        <h2>
            <a href="#" class="rename" data-course-id="1122" title="click to rename this course" style="color: #fff">
                Shawarmas
            </a>
        </h2>
    </header>
    <div id="course_1122" class="widget-body" role="content">
        <!-- Course description form -->
        <form action="..." method="post" class="form_update_course">
            <input type="hidden" name="course_id" value="1122">
            <textarea name="desc" id="course_desc_1122" cols="1" rows="3" class="form-control"></textarea>
        </form>
        
        <!-- Dishes table -->
        <table class="table table-bordered table-striped table-condensed show-dishes" id="table_1122">
            <!-- Dishes here -->
        </table>
    </div>
</div>
```

**Course Data to Extract**:
- **Course ID**: `data-id` attribute (e.g., `1122`)
- **Course Name**: `data-course` attribute OR text in `<h2><a class="rename">` (e.g., "Shawarmas")
- **Course Description**: Value in `<textarea name="desc">` (can be empty)
- **Display Order**: Implicit from order in DOM (0-indexed)

---

### Dish Table Structure
Within each course, dishes are in a table with `<tbody>` containing dish rows.

**Dish Row Example**:
```html
<tr class="sort" data-id="9001" data-dish="Shawarma 6&quot; TRIO" data-display_order="1">
    <td class="visible-xs">
        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/9001/1658/2" 
           data-dish="9001" 
           class="btn btn-primary edit_dish" 
           title="edit dish" 
           data-toggle="modal" 
           data-target="#mod_edit_dish" 
           data-backdrop="static" 
           data-keyboard="true" 
           data-dishname="Shawarma 6&quot; TRIO">
            edit
        </a>
        <a data-msg="Change status of this dish?" 
           href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" 
           data-dish="9001" 
           class="btn btn-danger remove_dish" 
           title="disable dish">
            disable
        </a>
    </td>
    <td><input type="text" name="name[9001]" value="Shawarma 6&quot; TRIO" class="form-control"></td>
    <td><input type="text" name="desc[9001]" value="Avec patate, un riz ou une salade (petit format) et un liqueur." class="form-control"></td>
    <td><input type="text" name="size[9001]" value="Poulet,Boeuf,Mixte" class="form-control size"></td>
    <td><input type="text" name="price[9001]" value="12.98,12.98,13.69" class="form-control price"></td>
    <td class="text-center dish-actions hidden-xs">
        <input type="hidden" name="ids[9001]" value="9001">
        <a href="#" class="btn btn-default cleanImage" data-dish="9001">
            <i class="fa fa-file-image-o"></i> image
        </a>
        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/9001/1658/2" 
           data-dish="9001" 
           class="btn btn-primary edit_dish" 
           title="edit dish" 
           data-toggle="modal" 
           data-target="#mod_edit_dish" 
           data-backdrop="static" 
           data-keyboard="true" 
           data-dishname="Shawarma 6&quot; TRIO">
            edit
        </a>
        <a data-msg="Change status of this dish?" 
           href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" 
           data-dish="9001" 
           class="btn btn-danger remove_dish" 
           title="disable dish">
            disable
        </a>
    </td>
</tr>
```

**Dish Data to Extract**:

1. **V2 Dish ID**: `data-id` attribute on `<tr>` (e.g., `9001`)
2. **Dish Name**: `value` attribute of `<input name="name[{DISH_ID}]">` (e.g., "Shawarma 6\" TRIO")
3. **Dish Description**: `value` attribute of `<input name="desc[{DISH_ID}]">` (e.g., "Avec patate, un riz ou une salade (petit format) et un liqueur.")
4. **Size Variants**: `value` attribute of `<input name="size[{DISH_ID}]" class="form-control size">` (e.g., "Poulet,Boeuf,Mixte")
   - **Format**: Comma-separated list
   - **If empty**: Use "standard" as size variant
5. **Prices**: `value` attribute of `<input name="price[{DISH_ID}]" class="form-control price">` (e.g., "12.98,12.98,13.69")
   - **Format**: Comma-separated list (matches size variants 1:1)
   - **If only one price**: Use "standard" as size variant
6. **Display Order**: `data-display_order` attribute OR implicit from order in `<tbody>` (0-indexed)
7. **Edit Link**: Extract from `<a class="btn btn-primary edit_dish">` → Used in Phase 2

---

## Size Variants & Prices Relationship

**IMPORTANT**: Sizes and prices are parallel arrays (comma-separated strings)

### Example 1: Multiple Sizes
```html
<input name="size[9001]" value="Poulet,Boeuf,Mixte">
<input name="price[9001]" value="12.98,12.98,13.69">
```

**Parse as**:
```python
sizes = ["Poulet", "Boeuf", "Mixte"]
prices = [12.98, 12.98, 13.69]

# Create 3 dish_prices records:
# 1. size_variant="Poulet", price=12.98, display_order=0
# 2. size_variant="Boeuf", price=12.98, display_order=1
# 3. size_variant="Mixte", price=13.69, display_order=2
```

### Example 2: No Size Variants
```html
<input name="size[9006]" value="">
<input name="price[9006]" value="16.95">
```

**Parse as**:
```python
sizes = ["standard"]  # Default when empty
prices = [16.95]

# Create 1 dish_prices record:
# 1. size_variant="standard", price=16.95, display_order=0
```

---

## Parsing Strategy (BeautifulSoup)

### Find All Courses
```python
courses_divs = soup.find_all('div', class_='course-listing', attrs={'data-id': True})

for course_div in courses_divs:
    course_id = course_div.get('data-id')
    course_name = course_div.get('data-course')
    
    # Get description
    desc_textarea = course_div.find('textarea', attrs={'name': 'desc'})
    course_description = desc_textarea.text.strip() if desc_textarea else ''
    
    # Find dishes table
    dishes_table = course_div.find('table', class_='show-dishes')
    if not dishes_table:
        continue
```

### Find All Dishes in Course
```python
    dish_rows = dishes_table.find('tbody').find_all('tr', class_='sort')
    
    for idx, dish_row in enumerate(dish_rows):
        # Dish ID
        v2_dish_id = dish_row.get('data-id')
        
        # Dish Name
        name_input = dish_row.find('input', attrs={'name': f'name[{v2_dish_id}]'})
        dish_name = name_input.get('value', '') if name_input else ''
        
        # Dish Description
        desc_input = dish_row.find('input', attrs={'name': f'desc[{v2_dish_id}]'})
        dish_description = desc_input.get('value', '') if desc_input else ''
        
        # Size Variants (comma-separated)
        size_input = dish_row.find('input', class_='size')
        sizes_str = size_input.get('value', '') if size_input else ''
        size_variants = [s.strip() for s in sizes_str.split(',') if s.strip()] if sizes_str else ['standard']
        
        # Prices (comma-separated)
        price_input = dish_row.find('input', class_='price')
        prices_str = price_input.get('value', '') if price_input else ''
        prices = [float(p.strip()) for p in prices_str.split(',') if p.strip()] if prices_str else [0.0]
        
        # Display Order
        display_order = int(dish_row.get('data-display_order', idx))
```

---

## Database Insertion for Phase 1

### Insert Course
```python
course_id = db.insert_course(
    restaurant_id=restaurant_db_id,  # From menuca_v3.restaurants
    name=course_name,                 # "Shawarmas"
    description=course_description,   # Can be empty ""
    display_order=course_idx          # 0, 1, 2, ...
)
```

### Insert Dish
```python
dish_id = db.insert_dish(
    restaurant_id=restaurant_db_id,   # From menuca_v3.restaurants
    course_id=course_id,               # From previous insert
    name=dish_name,                    # "Shawarma 6\" TRIO"
    description=dish_description,      # "Avec patate, un riz..."
    display_order=display_order,       # From data-display_order
    legacy_menu_entry_id=v2_dish_id    # "9001" (V2 dish ID)
)
```

### Insert Dish Prices (Phase 1 can optionally do this)
```python
for idx, (size, price) in enumerate(zip(size_variants, prices)):
    db.insert_dish_price(
        dish_id=dish_id,               # From previous insert
        size_variant=size,              # "Poulet", "Boeuf", "Mixte", or "standard"
        price=price,                    # 12.98, 12.98, 13.69
        display_order=idx               # 0, 1, 2, ...
    )
```

**Note**: You can insert dish prices in Phase 1 or Phase 2. If done in Phase 1, Phase 2 only needs to scrape modifiers.

---

## URL Patterns Summary

### Restaurant List
- **URL**: `https://aggregator-admin.menu.ca/index.php/restaurants/show/active`
- **Pattern**: Fixed

### Restaurant Edit (Info)
- **URL**: `https://aggregator-admin.menu.ca/index.php/restaurants/edit/{V2_RESTAURANT_ID}/info`
- **Example**: `https://aggregator-admin.menu.ca/index.php/restaurants/edit/1658/info`

### Restaurant Menu (English)
- **URL**: `https://aggregator-admin.menu.ca/index.php/restaurants/edit/{V2_RESTAURANT_ID}/menu/restaurant`
- **Example**: `https://aggregator-admin.menu.ca/index.php/restaurants/edit/1658/menu/restaurant`

### Restaurant Menu (French)
- **URL**: `https://aggregator-admin.menu.ca/index.php/restaurants/edit/{V2_RESTAURANT_ID}/menu/2/restaurant`
- **Example**: `https://aggregator-admin.menu.ca/index.php/restaurants/edit/1658/menu/2/restaurant`

### Edit Dish Modal (Phase 2)
- **URL**: `https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/{V2_DISH_ID}/{V2_RESTAURANT_ID}/2`
- **Example**: `https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/9001/1658/2`

---

## Important Notes

### 1. HTML Encoding
Dish names may contain HTML entities:
- `&quot;` → `"`
- `&amp;` → `&`
- `&#039;` → `'`

**BeautifulSoup automatically handles this**, but be aware when debugging.

### 2. Empty Values
- **Empty Description**: Use `""` (empty string)
- **Empty Size**: Use `["standard"]` 
- **Empty Price**: Use `[0.0]` (or skip the dish)

### 3. Display Order
- **Preferred**: Use `data-display_order` attribute if available
- **Fallback**: Use enumerate index (0, 1, 2, ...)

### 4. V2 Dish ID Storage
Store the V2 dish ID (`data-id` from `<tr>`) in `menuca_v3.dishes.source_id` column.
This is crucial for Phase 2 to re-identify dishes and scrape their modifiers.

### 5. French vs English Detection
The presence of `<div class="col-sm-12" id="sortable">` indicates an English menu.
If this div doesn't exist, look for a "French" button and navigate to the French menu URL.

---

## Complete Phase 1 Example

**Given**: Chicco Shawarma Cantley (V2 ID: 1658, DB ID: 100)

**Step-by-Step**:
1. Navigate to `https://aggregator-admin.menu.ca/index.php/restaurants/edit/1658/menu/restaurant`
2. Check for `id="sortable"` → Not found, so click "French" button
3. Navigate to `https://aggregator-admin.menu.ca/index.php/restaurants/edit/1658/menu/2/restaurant`
4. Parse courses:
   - Course 1: "Shawarmas" (V2 Course ID: 1122)
5. Parse dishes in "Shawarmas":
   - Dish 1: "Shawarma 6\"" (V2 ID: 9000), sizes: ["Poulet","Boeuf","Mixte"], prices: [7.99, 7.99, 8.70]
   - Dish 2: "Shawarma 6\" TRIO" (V2 ID: 9001), sizes: ["Poulet","Boeuf","Mixte"], prices: [12.98, 12.98, 13.69]
   - ...etc
6. Insert into database:
   ```python
   course_id = db.insert_course(100, "Shawarmas", "", 0)
   dish_id_1 = db.insert_dish(100, course_id, "Shawarma 6\"", "", 0, "9000")
   db.insert_dish_price(dish_id_1, "Poulet", 7.99, 0)
   db.insert_dish_price(dish_id_1, "Boeuf", 7.99, 1)
   db.insert_dish_price(dish_id_1, "Mixte", 8.70, 2)
   # ...repeat for other dishes
   ```

---

**This document provides all the HTML structure details needed to implement Phase 1 successfully!**

