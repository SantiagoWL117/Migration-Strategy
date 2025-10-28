#!/bin/bash
# V2 Production Export Commands for 18 Specific Restaurants
# These restaurants are LIVE on menu.ca but missing dish data in V3

# Restaurant IDs that need data recovery:
# 1635 - All Out Burger Gladstone
# 1636 - All Out Burger Montreal Rd  
# 1637 - Kirkwood Pizza
# 1639 - River Pizza
# 1641 - Wandee Thai
# 1642 - La Nawab
# 1654 - Cosenza
# 1657 - Cuisine Bombay Indienne
# 1658 - Chicco Shawarma Cantley
# 1659 - Chicco Pizza & Shawarma Buckingham
# 1664 - Chicco Pizza St-Louis
# 1665 - Zait and Zaatar
# 1668 - Little Gyros Greek Grill
# 1673 - Pizza Marie
# 1674 - Capri Pizza
# 1676 - Routine Poutine
# 1677 - Chef Rad Halal Pizza & Burgers
# 1678 - Al-s Drive In

RESTAURANT_IDS="1635,1636,1637,1639,1641,1642,1654,1657,1658,1659,1664,1665,1668,1673,1674,1676,1677,1678"

echo "🚀 Exporting V2 Production Data for 18 Restaurants..."
echo "Restaurant IDs: $RESTAURANT_IDS"
echo ""

# ========================================
# OPTION 1: MySQL/MariaDB Export
# ========================================

echo "📦 MySQL Export Commands:"
echo ""

# Step 1: Get course IDs for these restaurants first
echo "# Step 1: Export courses for these restaurants"
mysqldump -h V2_PRODUCTION_HOST -u V2_USER -p menuca_v2 restaurants_courses \
  --where="restaurant_id IN ($RESTAURANT_IDS)" \
  --single-transaction \
  --no-create-info > /tmp/v2_18_restaurants_courses.sql

# Step 2: Get the course IDs from the export and use them for dishes
echo "# Step 2: Extract course IDs"
COURSE_IDS=\$(grep "INSERT INTO" /tmp/v2_18_restaurants_courses.sql | \
  grep -oP "\\([0-9]+," | sed 's/(//g' | sed 's/,//g' | paste -sd "," -)

echo "Course IDs found: \$COURSE_IDS"

# Step 3: Export dishes for those courses
echo "# Step 3: Export dishes"
mysqldump -h V2_PRODUCTION_HOST -u V2_USER -p menuca_v2 restaurants_dishes \
  --where="course_id IN (\$COURSE_IDS) AND enabled='y'" \
  --single-transaction \
  --no-create-info > /tmp/v2_18_restaurants_dishes.sql

# Step 4: Export ingredient groups (modifiers)
echo "# Step 4: Export ingredient groups (modifiers)"
mysqldump -h V2_PRODUCTION_HOST -u V2_USER -p menuca_v2 restaurants_ingredient_groups \
  --where="restaurant_id IN ($RESTAURANT_IDS)" \
  --single-transaction \
  --no-create-info > /tmp/v2_18_restaurants_ingredient_groups.sql

# Step 5: Get ingredient group IDs and export ingredients
echo "# Step 5: Extract ingredient group IDs"
IG_IDS=\$(grep "INSERT INTO" /tmp/v2_18_restaurants_ingredient_groups.sql | \
  grep -oP "\\([0-9]+," | sed 's/(//g' | sed 's/,//g' | paste -sd "," -)

echo "# Step 6: Export ingredients"
mysqldump -h V2_PRODUCTION_HOST -u V2_USER -p menuca_v2 restaurants_ingredients \
  --where="group_id IN (\$IG_IDS)" \
  --single-transaction \
  --no-create-info > /tmp/v2_18_restaurants_ingredients.sql

# Step 7: Export customizations (dish-specific modifiers)
echo "# Step 7: Get dish IDs and export customizations"
DISH_IDS=\$(grep "INSERT INTO" /tmp/v2_18_restaurants_dishes.sql | \
  grep -oP "\\([0-9]+," | sed 's/(//g' | sed 's/,//g' | paste -sd "," -)

mysqldump -h V2_PRODUCTION_HOST -u V2_USER -p menuca_v2 restaurants_dishes_customization \
  --where="dish_id IN (\$DISH_IDS)" \
  --single-transaction \
  --no-create-info > /tmp/v2_18_restaurants_customizations.sql

# Step 8: Export combo groups if they exist
echo "# Step 8: Export combo groups"
mysqldump -h V2_PRODUCTION_HOST -u V2_USER -p menuca_v2 restaurants_combo_groups \
  --where="restaurant_id IN ($RESTAURANT_IDS)" \
  --single-transaction \
  --no-create-info > /tmp/v2_18_restaurants_combo_groups.sql 2>/dev/null || echo "No combo groups"

echo ""
echo "✅ Export complete! Files created:"
ls -lh /tmp/v2_18_restaurants_*.sql

# ========================================
# OPTION 2: Direct CSV Export (Alternative)
# ========================================

echo ""
echo "📊 Alternative: CSV Export Commands"
echo ""

# Courses
mysql -h V2_PRODUCTION_HOST -u V2_USER -p menuca_v2 -e \
  "SELECT * FROM restaurants_courses WHERE restaurant_id IN ($RESTAURANT_IDS)" \
  > /tmp/v2_18_courses.csv

# Dishes (with course join to filter)
mysql -h V2_PRODUCTION_HOST -u V2_USER -p menuca_v2 -e \
  "SELECT rd.* FROM restaurants_dishes rd 
   JOIN restaurants_courses rc ON rc.id = rd.course_id 
   WHERE rc.restaurant_id IN ($RESTAURANT_IDS) AND rd.enabled='y'" \
  > /tmp/v2_18_dishes.csv

# Ingredient groups
mysql -h V2_PRODUCTION_HOST -u V2_USER -p menuca_v2 -e \
  "SELECT * FROM restaurants_ingredient_groups WHERE restaurant_id IN ($RESTAURANT_IDS)" \
  > /tmp/v2_18_ingredient_groups.csv

# Ingredients
mysql -h V2_PRODUCTION_HOST -u V2_USER -p menuca_v2 -e \
  "SELECT i.* FROM restaurants_ingredients i
   JOIN restaurants_ingredient_groups ig ON ig.id = i.group_id
   WHERE ig.restaurant_id IN ($RESTAURANT_IDS)" \
  > /tmp/v2_18_ingredients.csv

# Customizations
mysql -h V2_PRODUCTION_HOST -u V2_USER -p menuca_v2 -e \
  "SELECT c.* FROM restaurants_dishes_customization c
   JOIN restaurants_dishes rd ON rd.id = c.dish_id
   JOIN restaurants_courses rc ON rc.id = rd.course_id
   WHERE rc.restaurant_id IN ($RESTAURANT_IDS)" \
  > /tmp/v2_18_customizations.csv

echo ""
echo "✅ CSV exports complete!"
echo ""
echo "📋 NEXT STEPS:"
echo "1. Run this script with V2 production credentials"
echo "2. Upload resulting SQL/CSV files to migration server"
echo "3. Load into staging tables"
echo "4. Run V2→V3 migration for these 18 restaurants"
echo ""
echo "🎯 Expected Recovery:"
echo "   - 18 restaurants"
echo "   - Estimated 500-2000 dishes"
echo "   - Full modifier/customization data"
echo "   - 100% pricing coverage"

