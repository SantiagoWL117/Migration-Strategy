#!/bin/bash
# ============================================================================
# V2 Phase 1 Import Wrapper Script (DELETE then INSERT strategy)
# ============================================================================
# This script loads JSON files from phase1_output/ and imports them into
# menuca_v3 using psql. It DELETES existing menu data before importing.
#
# Usage:
#   chmod +x import_phase1_wrapper.sh
#   ./import_phase1_wrapper.sh
#
# Requirements:
#   - jq (JSON processor): brew install jq
#   - psql with connection to Supabase
# ============================================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DB_CONNECTION="postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres"
PHASE1_OUTPUT_DIR="../phase1_output"
LOG_FILE="import_phase1.log"

# Clear log file
> "$LOG_FILE"

echo -e "${BLUE}============================================================================${NC}"
echo -e "${BLUE}V2 Phase 1 Import - Courses, Dishes, and Prices${NC}"
echo -e "${BLUE}Strategy: DELETE existing data, then INSERT new data${NC}"
echo -e "${BLUE}============================================================================${NC}"
echo ""

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo -e "${RED}Error: jq is not installed${NC}"
    echo "Install it with: brew install jq"
    exit 1
fi

# Check if output directory exists
if [ ! -d "$PHASE1_OUTPUT_DIR" ]; then
    echo -e "${RED}Error: Output directory not found: $PHASE1_OUTPUT_DIR${NC}"
    exit 1
fi

# Count JSON files
JSON_FILES=("$PHASE1_OUTPUT_DIR"/restaurant_*_menu.json)
FILE_COUNT=${#JSON_FILES[@]}

if [ $FILE_COUNT -eq 0 ]; then
    echo -e "${RED}Error: No JSON files found in $PHASE1_OUTPUT_DIR${NC}"
    exit 1
fi

echo -e "${GREEN}Found $FILE_COUNT restaurant menu files${NC}"
echo ""

# Track statistics
TOTAL_COURSES=0
TOTAL_DISHES=0
TOTAL_PRICES=0
SUCCESSFUL=0
FAILED=0

# Process each JSON file
for ((i=0; i<${#JSON_FILES[@]}; i++)); do
    JSON_FILE="${JSON_FILES[$i]}"
    FILENAME=$(basename "$JSON_FILE")
    RESTAURANT_ID=$(echo "$FILENAME" | grep -o '[0-9]\+')
    
    echo -e "${BLUE}[$((i+1))/$FILE_COUNT]${NC} Processing: $FILENAME (Restaurant ID: $RESTAURANT_ID)"
    
    # Extract restaurant name from JSON
    RESTAURANT_NAME=$(jq -r '.db_restaurant_id' "$JSON_FILE" 2>/dev/null || echo "Unknown")
    COURSES_COUNT=$(jq '.courses | length' "$JSON_FILE" 2>/dev/null || echo "0")
    
    if [ "$COURSES_COUNT" -eq 0 ]; then
        echo -e "${YELLOW}  ⚠ Skipping: No courses found${NC}"
        continue
    fi
    
    # Import this restaurant's menu (DELETE then INSERT)
    echo "  → Deleting existing menu data for restaurant $RESTAURANT_ID..."
    echo "  → Importing courses, dishes, and prices..."
    
    if psql "$DB_CONNECTION" -v ON_ERROR_STOP=1 -q >> "$LOG_FILE" 2>&1 <<EOF
BEGIN;

-- ========================================
-- STEP 1: DELETE existing menu data for this restaurant
-- ========================================

-- Delete dish_prices first (FK to dishes)
DELETE FROM menuca_v3.dish_prices WHERE restaurant_id = $RESTAURANT_ID;

-- Delete dish_modifiers (FK to dishes)
DELETE FROM menuca_v3.dish_modifiers WHERE restaurant_id = $RESTAURANT_ID;

-- Delete modifier_groups (FK to dishes)
DELETE FROM menuca_v3.modifier_groups WHERE dish_id IN (
    SELECT id FROM menuca_v3.dishes WHERE restaurant_id = $RESTAURANT_ID
);

-- Delete dishes (FK to courses)
DELETE FROM menuca_v3.dishes WHERE restaurant_id = $RESTAURANT_ID;

-- Delete courses
DELETE FROM menuca_v3.courses WHERE restaurant_id = $RESTAURANT_ID;

-- ========================================
-- STEP 2: Insert Courses
-- ========================================
WITH json_data AS (
    SELECT '$(cat "$JSON_FILE" | jq -c .)'::jsonb AS data
),
course_data AS (
    SELECT
        (data->>'db_restaurant_id')::BIGINT AS restaurant_id,
        course->>'name' AS course_name,
        COALESCE(course->>'description', '') AS description,
        (course->>'display_order')::INTEGER AS display_order,
        course->>'v2_course_id' AS v2_course_id
    FROM json_data,
         jsonb_array_elements(data->'courses') AS course
)
INSERT INTO menuca_v3.courses (
    restaurant_id,
    name,
    description,
    display_order,
    created_at,
    updated_at
)
SELECT
    restaurant_id,
    course_name,
    description,
    display_order,
    NOW(),
    NOW()
FROM course_data;

-- ========================================
-- STEP 3: Insert Dishes
-- ========================================
WITH json_data AS (
    SELECT '$(cat "$JSON_FILE" | jq -c .)'::jsonb AS data
),
course_data AS (
    SELECT
        (data->>'db_restaurant_id')::BIGINT AS restaurant_id,
        course->>'name' AS course_name,
        (course->>'display_order')::INTEGER AS course_display_order,
        dish->>'name' AS dish_name,
        COALESCE(dish->>'description', '') AS dish_description,
        (dish->>'display_order')::INTEGER AS dish_display_order,
        dish->>'v2_dish_id' AS v2_dish_id,
        dish->'prices' AS prices_json
    FROM json_data,
         jsonb_array_elements(data->'courses') AS course,
         jsonb_array_elements(course->'dishes') AS dish
),
course_lookup AS (
    SELECT
        c.id AS course_id,
        c.restaurant_id,
        c.name AS course_name,
        c.display_order AS course_display_order
    FROM menuca_v3.courses c
    WHERE c.restaurant_id = $RESTAURANT_ID
)
INSERT INTO menuca_v3.dishes (
    restaurant_id,
    course_id,
    name,
    description,
    display_order,
    source_id,
    created_at,
    updated_at
)
SELECT
    cd.restaurant_id,
    cl.course_id,
    cd.dish_name,
    cd.dish_description,
    cd.dish_display_order,
    cd.v2_dish_id,
    NOW(),
    NOW()
FROM course_data cd
INNER JOIN course_lookup cl
    ON cd.restaurant_id = cl.restaurant_id
    AND cd.course_name = cl.course_name
    AND cd.course_display_order = cl.course_display_order;

-- ========================================
-- STEP 4: Insert Dish Prices
-- ========================================
WITH json_data AS (
    SELECT '$(cat "$JSON_FILE" | jq -c .)'::jsonb AS data
),
course_data AS (
    SELECT
        (data->>'db_restaurant_id')::BIGINT AS restaurant_id,
        course->>'name' AS course_name,
        (course->>'display_order')::INTEGER AS course_display_order,
        dish->>'name' AS dish_name,
        (dish->>'display_order')::INTEGER AS dish_display_order,
        dish->'prices' AS prices_json
    FROM json_data,
         jsonb_array_elements(data->'courses') AS course,
         jsonb_array_elements(course->'dishes') AS dish
),
course_lookup AS (
    SELECT c.id, c.restaurant_id, c.name, c.display_order
    FROM menuca_v3.courses c
    WHERE c.restaurant_id = $RESTAURANT_ID
),
dish_lookup AS (
    SELECT d.id, d.restaurant_id, d.course_id, d.name, d.display_order
    FROM menuca_v3.dishes d
    WHERE d.restaurant_id = $RESTAURANT_ID
),
price_data AS (
    SELECT
        dl.id AS dish_id,
        dl.restaurant_id,
        price->>'size_variant' AS size_variant,
        (price->>'price')::NUMERIC(10,2) AS price,
        (price->>'display_order')::INTEGER AS display_order
    FROM course_data cd
    INNER JOIN course_lookup cl
        ON cd.restaurant_id = cl.restaurant_id
        AND cd.course_name = cl.name
        AND cd.course_display_order = cl.display_order
    INNER JOIN dish_lookup dl
        ON cl.id = dl.course_id
        AND cd.dish_name = dl.name
        AND cd.dish_display_order = dl.display_order,
    jsonb_array_elements(cd.prices_json) AS price
)
INSERT INTO menuca_v3.dish_prices (
    dish_id,
    restaurant_id,
    size_variant,
    price,
    display_order,
    created_at,
    updated_at
)
SELECT
    dish_id,
    restaurant_id,
    size_variant,
    price,
    display_order,
    NOW(),
    NOW()
FROM price_data;

COMMIT;
EOF
    then
        echo -e "${GREEN}  ✓ Success${NC}"
        SUCCESSFUL=$((SUCCESSFUL + 1))
        TOTAL_COURSES=$((TOTAL_COURSES + COURSES_COUNT))
    else
        echo -e "${RED}  ✗ Failed - see $LOG_FILE for details${NC}"
        FAILED=$((FAILED + 1))
    fi
    
    echo ""
done

# Final summary
echo -e "${BLUE}============================================================================${NC}"
echo -e "${BLUE}Import Summary${NC}"
echo -e "${BLUE}============================================================================${NC}"
echo -e "Total restaurants processed: ${FILE_COUNT}"
echo -e "${GREEN}Successful: ${SUCCESSFUL}${NC}"
if [ $FAILED -gt 0 ]; then
    echo -e "${RED}Failed: ${FAILED}${NC}"
fi
echo -e "Estimated courses imported: ${TOTAL_COURSES}"
echo ""
echo -e "Log file: ${LOG_FILE}"
echo -e "${BLUE}============================================================================${NC}"
echo ""

# Query actual counts from database
echo -e "${YELLOW}Querying actual counts from database...${NC}"
psql "$DB_CONNECTION" -c "
SELECT
    (SELECT COUNT(*) FROM menuca_v3.courses) AS total_courses,
    (SELECT COUNT(*) FROM menuca_v3.dishes) AS total_dishes,
    (SELECT COUNT(*) FROM menuca_v3.dish_prices) AS total_prices;
"

echo ""
echo -e "${GREEN}Phase 1 import complete!${NC}"
