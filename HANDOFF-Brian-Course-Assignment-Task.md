# Task Handoff: Course Assignment Fix for Active Restaurants

**Date:** 2025-11-03
**From:** Santiago
**To:** Brian
**Task:** Systematic Course Assignment Fix for All Active Restaurants

---

## Task Overview

We are fixing **Issue #1: NULL Course Assignments** identified in the Capri Pizza Data Integrity Report. The goal is to systematically go through ALL restaurants listed in `Restaurants-active.md` and ensure every dish has a valid `course_id` assigned.

---

## The Problem

Many restaurants in the `menuca_v3` schema have dishes with `NULL` values for `course_id`, which breaks menu display functionality. Dishes cannot be properly organized into categories (Appetizers, Mains, Desserts, etc.) without course assignments.

---

## Critical Guidelines (MUST FOLLOW)

### 1. **Restaurant-by-Restaurant Review (NO SKIPPING)**
- Go through restaurants **IN ORDER** from `Restaurants-active.md`
- **NEVER skip a restaurant** without explicit authorization
- Review EVERY restaurant regardless of status (active, suspended, pending)
- Wait for authorization after each restaurant before proceeding to the next

### 2. **Status Verification Protocol**
All restaurants in `Restaurants-active.md` are **supposed to be active**. If you find:

- **Suspended Restaurant**:
  - 🛑 STOP immediately
  - Report the status mismatch
  - Wait for authorization to correct the status
  - Only proceed after status is corrected

- **Pending Restaurant**:
  - 🛑 STOP immediately
  - Report the status mismatch
  - Wait for authorization

- **Restaurant Not Found**:
  - 🛑 STOP immediately
  - Report that restaurant doesn't exist in database
  - Wait for authorization to investigate

### 3. **Course Assignment Process**

For each restaurant, assess:

**Step 1: Check Restaurant Status**
```sql
SELECT id, name, status FROM menuca_v3.restaurants WHERE name ILIKE '%[restaurant_name]%';
```
- If status != 'active', STOP and report

**Step 2: Check Courses**
```sql
SELECT COUNT(*) FROM menuca_v3.courses WHERE restaurant_id = [id];
```
- If course_count = 0, document as "No Courses Defined" and wait for authorization

**Step 3: Check Dishes**
```sql
SELECT
    COUNT(*) as total_dishes,
    COUNT(CASE WHEN course_id IS NULL THEN 1 END) as null_course_id_count,
    COUNT(CASE WHEN course_id IS NOT NULL THEN 1 END) as has_course_id_count
FROM menuca_v3.dishes
WHERE restaurant_id = [id] AND deleted_at IS NULL;
```
- If all dishes have course_id, document as "Already Assigned" and wait for authorization
- If dishes have NULL course_id and courses exist, proceed with mapping

**Step 4: Map Dishes to Courses**
- Get all dishes for the restaurant
- Analyze dish names to determine logical course assignments
- Create UPDATE statements to assign course_id
- Map based on dish names (e.g., "Pepsi" → Drinks, "Cheesecake" → Desserts)

**Step 5: Check Modifiers and Relationships**
```sql
-- Count total modifiers
SELECT 
    COUNT(DISTINCT dm.id) as total_modifiers,
    COUNT(DISTINCT dm.dish_id) as dishes_with_modifiers
FROM menuca_v3.dish_modifiers dm
WHERE dm.restaurant_id = [id] AND dm.deleted_at IS NULL;
```

```sql
-- Check modifier relationships - which dishes have modifiers
SELECT 
    d.id as dish_id,
    d.name as dish_name,
    c.name as course_name,
    COUNT(DISTINCT dm.id) as modifier_count,
    COUNT(DISTINCT dm.ingredient_group_id) as modifier_groups_count
FROM menuca_v3.dishes d
LEFT JOIN menuca_v3.courses c ON d.course_id = c.id
LEFT JOIN menuca_v3.dish_modifiers dm ON d.id = dm.dish_id AND dm.deleted_at IS NULL
WHERE d.restaurant_id = [id] AND d.deleted_at IS NULL
GROUP BY d.id, d.name, c.name
HAVING COUNT(DISTINCT dm.id) > 0
ORDER BY modifier_count DESC;
```

```sql
-- Check modifier group structure
SELECT 
    dm.dish_id,
    d.name as dish_name,
    dm.ingredient_group_id,
    ig.name as group_name,
    COUNT(DISTINCT dm.ingredient_id) as modifiers_in_group
FROM menuca_v3.dish_modifiers dm
LEFT JOIN menuca_v3.dishes d ON dm.dish_id = d.id
LEFT JOIN menuca_v3.ingredient_groups ig ON dm.ingredient_group_id = ig.id
WHERE dm.restaurant_id = [id] AND dm.deleted_at IS NULL AND d.deleted_at IS NULL
GROUP BY dm.dish_id, d.name, dm.ingredient_group_id, ig.name
ORDER BY dm.dish_id, dm.ingredient_group_id;
```

- Document modifier counts and relationships
- Verify modifiers are assigned to correct dishes
- Check if modifier groups are properly structured
- Compare with live menu if available to verify modifier assignments match

**Step 6: Verify Course Assignments**
```sql
-- Check remaining NULL values
SELECT COUNT(*) FROM menuca_v3.dishes
WHERE restaurant_id = [id] AND course_id IS NULL AND deleted_at IS NULL;
```
- Must be 0 remaining NULL values

**Step 7: Report & Pause**
- Document results in `Course-Fix-Progress.md`
- Report findings
- 🛑 STOP and wait for authorization before next restaurant

---

## Documentation Requirements

All findings must be documented in `Course-Fix-Progress.md` under appropriate sections:

### Section Categories:

1. **✅ Completed Restaurants**
   - Restaurant successfully processed
   - All dishes assigned to courses
   - 0 remaining NULL values

2. **⚠️ Skipped Restaurants - No Courses Defined**
   - Restaurants with 0 courses in database
   - Cannot proceed until courses are created
   - Document recommended course structure

3. **⚠️ Skipped Restaurants - Already Assigned**
   - All dishes already have course_id
   - No work needed

4. **❌ Restaurants Not Found in Database**
   - Listed in active list but don't exist in database
   - Needs investigation

5. **⏸️ Restaurants with Suspended/Pending Status**
   - Status mismatch found
   - Needs status correction before proceeding

6. **✅ Restaurants with Status Corrected**
   - Status was corrected from suspended/pending to active
   - Document the correction

---

## Example Mapping Logic

When assigning dishes to courses, use logical patterns:

### Pizza Restaurant:
- Appetizers: Breaded items, wings, garlic bread, etc.
- Pizza: All pizza items
- Pasta: Pasta dishes
- Salads: Salad items
- Desserts: Cakes, pies, sweet items
- Drinks: Beverages
- Specials/Combos: Combo meals, deals

### Burger Restaurant:
- Appetizers: Fries, onion rings, appetizer platters
- Burgers SOLO: Individual burgers
- Burger COMBOS: Burger combo meals
- Hot Dogs: Hot dog items
- Chicken: Wings, strips, tenders
- Salads: Salad items
- Drinks: Beverages
- Kids Menu: Kids meals

### Thai/Asian Restaurant:
- Appetizers: Spring rolls, satay, etc.
- Soups: Tom Yum, etc.
- Curries: All curry dishes
- Noodles: Pad Thai, Pad See Ew, etc.
- Rice Dishes: Fried rice, etc.
- Stir Fry: Stir-fried dishes
- Desserts: Sweet items
- Drinks: Beverages

---

## SQL Template for Updates

```sql
-- Update [Course Name] (course_id: [ID])
UPDATE menuca_v3.dishes
SET course_id = [COURSE_ID], updated_at = NOW()
WHERE restaurant_id = [RESTAURANT_ID]
AND name IN (
    'Dish Name 1',
    'Dish Name 2',
    'Dish Name 3'
)
AND deleted_at IS NULL;

-- OR use pattern matching
UPDATE menuca_v3.dishes
SET course_id = [COURSE_ID], updated_at = NOW()
WHERE restaurant_id = [RESTAURANT_ID]
AND (
    name ILIKE '%pattern%'
    OR name ILIKE '%another_pattern%'
)
AND deleted_at IS NULL;

-- Verify
SELECT
    c.name as course_name,
    COUNT(d.id) as dish_count
FROM menuca_v3.courses c
LEFT JOIN menuca_v3.dishes d ON c.id = d.course_id
    AND d.restaurant_id = [RESTAURANT_ID]
    AND d.deleted_at IS NULL
WHERE c.restaurant_id = [RESTAURANT_ID]
GROUP BY c.id, c.name
ORDER BY c.display_order;
```

---

## Progress Tracking

Track progress in `Course-Fix-Progress.md`:

**Summary Statistics Section:**
- Total Restaurants in List: 252
- Completed: [count]
- Skipped (No Courses): [count]
- Skipped (Already Assigned): [count]
- Status Corrected: [count]
- Not Found: [count]
- In Progress: 0
- Pending: [remaining]

---

## Current Progress (as of handoff)

### ✅ Completed (5 restaurants):
1. Capri Pizza (86 dishes)
2. Al's Drive In (36 dishes)
3. All Out Burger Gladstone (59 dishes)
4. All Out Burger Montreal Rd (59 dishes)
5. Routine Poutine (8 dishes)

**Total dishes fixed: 248**

### ⚠️ Skipped - No Courses (4 restaurants):
1. Aahar The Taste of India (108 dishes, 0 courses)
2. Amicci Pizza (196 dishes, 0 courses)
3. Aroy Thai (39 dishes, 0 courses) ← **CURRENT POSITION**
4. Asia Garden Ottawa (154 dishes, 0 courses)

### ⚠️ Skipped - Already Assigned (7 restaurants):
1. 2 for 1 Pizza (2 dishes)
2. All Out Burger (IDs: 771, 794, 826, 833, 841) - 5 locations
3. All Out Burger Bank St. (520 dishes)

### ❌ Not Found (1 restaurant):
1. Andiamo Pizzeria (102B McEwen Ave)

### ✅ Status Corrected (1 restaurant):
1. Argos Greek & Pizza (was suspended, now active, already assigned)

---

## Next Steps

**Current Position:** Aroy Thai (Restaurant ID: 607)
- Status: Active ✅
- Issue: No courses defined (0 courses, 39 dishes with NULL course_id)
- Action: Awaiting decision on how to handle restaurants with no courses

**Pending Decision:**
Should we:
1. Skip all restaurants with no courses for now?
2. Create courses first, then assign dishes?
3. Continue to next restaurant and come back later?

---

## Important Reminders

1. **NEVER skip without authorization**
2. **ALWAYS stop when finding status issues**
3. **ALWAYS document in Course-Fix-Progress.md**
4. **ALWAYS verify 0 remaining NULL values after updates**
5. **ALWAYS wait for authorization before next restaurant**

---

## Reference Files

- **Active Restaurant List**: `Restaurants-active.md`
- **Progress Tracking**: `Course-Fix-Progress.md`
- **Original Issue Report**: `Capri-Pizza-Data-Integrity-Report.md`
- **Database Connection**: Supabase project `menu-rebuild-vo` (nthpbtdjhhnwfxqsxbvy)

---

## Questions?

If unclear on any step:
1. STOP
2. Ask for clarification
3. DO NOT proceed without authorization

---

**End of Handoff Document**
