# TICKET: Phase 0 - Complex Modifier Validation

**Ticket ID:** PHASE_0_05_MODIFIER_VALIDATION  
**Priority:** 🟡 HIGH  
**Estimated Time:** 4-5 hours  
**Dependencies:** None  
**Assignee:** Builder Agent  
**Database:** Apply to production (cursor-build inherits)

/*--*/-

## Requirement

Create validation system for complex dish modifiers including required choices, multi-select limits, nested modifiers, and conditional pricing. Current plan oversimplifies modifiers - real restaurants have complex rules.

/*--*/-

## Problem Statement

**Current Plan:** Basic modifiers (add/remove ingredients)

**Real-World Complexity:**
- **Required choices:** "Pick a size" (must select one)
- **Multi-select limits:** "Pick up to 3 toppings"
- **Nested modifiers:** "If burrito, then pick a rice"
- **Conditional pricing:** "Extra guac +$2.00"
- **Default selections:** "Comes with cheese (can remove)"

**Solution:** Robust modifier validation system with flexible rules

/*--*/-

## Acceptance Criteria

### Database Schema
- [ ] Add `modifier_groups` table (groups like "Size", "Toppings")
- [ ] Add `is_required` field (must select from this group)
- [ ] Add `min_selections` and `max_selections` (limits)
- [ ] Add `display_order` (sequence on menu)
- [ ] Link modifiers to groups
- [ ] Support nested/conditional groups

### SQL Functions
- [ ] Create `validate_dish_modifiers(p_dish_id, p_selected_modifiers)` function
- [ ] Function checks all required groups have selections
- [ ] Function enforces min/max selection limits
- [ ] Function calculates total price including modifier charges
- [ ] Function returns validation errors or success

### Validation Rules
- [ ] Required groups must have at least 1 selection
- [ ] Cannot exceed max_selections in any group
- [ ] Must meet min_selections in any group
- [ ] Invalid modifier IDs rejected
- [ ] Pricing calculated correctly

/*--*/-

## Technical Details

### New Table: modifier_groups


```plaintext
CREATE TABLE menuca_v3.modifier_groups (
  id BIGSERIAL PRIMARY KEY,
  dish_id BIGINT NOT NULL REFERENCES menuca_v3.dishes(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,  /*--*/ "Size", "Toppings", "Add-ons"
  is_required BOOLEAN DEFAULT FALSE NOT NULL,
  min_selections INTEGER DEFAULT 0 NOT NULL CHECK (min_selections >= 0),
  max_selections INTEGER DEFAULT 1 NOT NULL CHECK (max_selections >= min_selections),
  display_order INTEGER DEFAULT 0 NOT NULL,
  parent_modifier_id BIGINT REFERENCES menuca_v3.dish_modifiers(id),  /*--*/ For nested
  instructions TEXT,  /*--*/ "Choose your protein"
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  
  CONSTRAINT valid_selection_range CHECK (min_selections <= max_selections)
);

CREATE INDEX idx_modifier_groups_dish 
  ON menuca_v3.modifier_groups(dish_id);
  
CREATE INDEX idx_modifier_groups_parent 
  ON menuca_v3.modifier_groups(parent_modifier_id)
  WHERE parent_modifier_id IS NOT NULL;

COMMENT ON TABLE menuca_v3.modifier_groups IS 
  'Groups modifiers into logical categories with selection rules (min/max, required).';
  
COMMENT ON COLUMN menuca_v3.modifier_groups.is_required IS 
  'If TRUE, customer must select at least min_selections modifiers from this group.';
  
COMMENT ON COLUMN menuca_v3.modifier_groups.min_selections IS 
  'Minimum number of modifiers required from this group.';
  
COMMENT ON COLUMN menuca_v3.modifier_groups.max_selections IS 
  'Maximum number of modifiers allowed from this group.';
  
COMMENT ON COLUMN menuca_v3.modifier_groups.parent_modifier_id IS 
  'If set, this group only appears if parent modifier is selected (nested modifiers).';
```

/*--*/-

### Update dish_modifiers Table


```plaintext
/*--*/ Add group relationship
ALTER TABLE menuca_v3.dish_modifiers
  ADD COLUMN modifier_group_id BIGINT REFERENCES menuca_v3.modifier_groups(id) ON DELETE CASCADE,
  ADD COLUMN is_default BOOLEAN DEFAULT FALSE NOT NULL,
  ADD COLUMN display_order INTEGER DEFAULT 0 NOT NULL;

CREATE INDEX idx_dish_modifiers_group 
  ON menuca_v3.dish_modifiers(modifier_group_id);

COMMENT ON COLUMN menuca_v3.dish_modifiers.modifier_group_id IS 
  'Which group this modifier belongs to (e.g., "Size" group).';
  
COMMENT ON COLUMN menuca_v3.dish_modifiers.is_default IS 
  'If TRUE, this modifier is pre-selected by default.';
```

/*--*/-

### SQL Function: validate_dish_modifiers()


```plaintext
CREATE OR REPLACE FUNCTION menuca_v3.validate_dish_modifiers(
  p_dish_id BIGINT,
  p_selected_modifiers JSONB  /*--*/ Array of {modifier_id, quantity}
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_group RECORD;
  v_selections_in_group INTEGER;
  v_errors JSONB := '[]'::JSONB;
  v_total_price NUMERIC(10,2) := 0;
  v_dish_base_price NUMERIC(10,2);
  v_modifier RECORD;
  v_selected_ids BIGINT[];
BEGIN
  /*--*/ Get dish base price
  SELECT price INTO v_dish_base_price
  FROM menuca_v3.dishes
  WHERE id = p_dish_id;
  
  IF NOT FOUND THEN
    RETURN jsonb_build_object(
      'valid', false,
      'errors', jsonb_build_array('Dish not found')
    );
  END IF;
  
  v_total_price := v_dish_base_price;
  
  /*--*/ Extract selected modifier IDs
  SELECT ARRAY_AGG((value->>'modifier_id')::BIGINT)
  INTO v_selected_ids
  FROM jsonb_array_elements(p_selected_modifiers);
  
  v_selected_ids := COALESCE(v_selected_ids, ARRAY[]::BIGINT[]);
  
  /*--*/ Validate each modifier group
  FOR v_group IN 
    SELECT 
      id,
      name,
      is_required,
      min_selections,
      max_selections
    FROM menuca_v3.modifier_groups
    WHERE dish_id = p_dish_id
    ORDER BY display_order
  LOOP
    /*--*/ Count selections in this group
    SELECT COUNT(*)
    INTO v_selections_in_group
    FROM menuca_v3.dish_modifiers dm
    WHERE dm.modifier_group_id = v_group.id
      AND dm.id = ANY(v_selected_ids);
    
    /*--*/ Check required group
    IF v_group.is_required AND v_selections_in_group = 0 THEN
      v_errors := v_errors || jsonb_build_object(
        'group_id', v_group.id,
        'group_name', v_group.name,
        'error', 'Required: You must select from this group',
        'min_required', v_group.min_selections
      );
    END IF;
    
    /*--*/ Check min selections
    IF v_selections_in_group > 0 AND v_selections_in_group < v_group.min_selections THEN
      v_errors := v_errors || jsonb_build_object(
        'group_id', v_group.id,
        'group_name', v_group.name,
        'error', format('You must select at least %s', v_group.min_selections),
        'selected', v_selections_in_group,
        'min_required', v_group.min_selections
      );
    END IF;
    
    /*--*/ Check max selections
    IF v_selections_in_group > v_group.max_selections THEN
      v_errors := v_errors || jsonb_build_object(
        'group_id', v_group.id,
        'group_name', v_group.name,
        'error', format('You can only select up to %s', v_group.max_selections),
        'selected', v_selections_in_group,
        'max_allowed', v_group.max_selections
      );
    END IF;
  END LOOP;
  
  /*--*/ Calculate total price (add modifier prices)
  FOR v_modifier IN
    SELECT 
      dm.id,
      dm.name,
      dm.price,
      (SELECT (value->>'quantity')::INTEGER 
       FROM jsonb_array_elements(p_selected_modifiers) 
       WHERE (value->>'modifier_id')::BIGINT = dm.id
       LIMIT 1) as quantity
    FROM menuca_v3.dish_modifiers dm
    WHERE dm.id = ANY(v_selected_ids)
  LOOP
    IF v_modifier.price IS NOT NULL AND v_modifier.price > 0 THEN
      v_total_price := v_total_price + (v_modifier.price * COALESCE(v_modifier.quantity, 1));
    END IF;
  END LOOP;
  
  /*--*/ Return result
  RETURN jsonb_build_object(
    'valid', (jsonb_array_length(v_errors) = 0),
    'errors', v_errors,
    'base_price', v_dish_base_price,
    'modifiers_price', v_total_price - v_dish_base_price,
    'total_price', v_total_price
  );
END;
$$;

COMMENT ON FUNCTION menuca_v3.validate_dish_modifiers IS 
  'Validates selected modifiers against dish rules (required, min/max). Returns validation errors and calculates total price.';
```

/*--*/-

## Example Data Setup

### Example 1: Pizza with Size (Required) and Toppings (Optional)


```plaintext
/*--*/ Create modifier groups for a pizza
INSERT INTO menuca_v3.modifier_groups (dish_id, name, is_required, min_selections, max_selections, display_order)
VALUES 
  (1, 'Size', TRUE, 1, 1, 1),  /*--*/ Must pick exactly 1 size
  (1, 'Extra Toppings', FALSE, 0, 5, 2);  /*--*/ Can pick up to 5 toppings

/*--*/ Create size modifiers
INSERT INTO menuca_v3.dish_modifiers (modifier_group_id, name, price)
SELECT id, 'Small (10")', 0.00 FROM menuca_v3.modifier_groups WHERE name = 'Size' AND dish_id = 1
UNION ALL
SELECT id, 'Medium (12")', 3.00 FROM menuca_v3.modifier_groups WHERE name = 'Size' AND dish_id = 1
UNION ALL
SELECT id, 'Large (14")', 6.00 FROM menuca_v3.modifier_groups WHERE name = 'Size' AND dish_id = 1;

/*--*/ Create topping modifiers
INSERT INTO menuca_v3.dish_modifiers (modifier_group_id, name, price)
SELECT id, 'Extra Cheese', 2.00 FROM menuca_v3.modifier_groups WHERE name = 'Extra Toppings' AND dish_id = 1
UNION ALL
SELECT id, 'Pepperoni', 2.00 FROM menuca_v3.modifier_groups WHERE name = 'Extra Toppings' AND dish_id = 1
UNION ALL
SELECT id, 'Mushrooms', 1.50 FROM menuca_v3.modifier_groups WHERE name = 'Extra Toppings' AND dish_id = 1;
```

### Example 2: Burrito with Nested Modifiers


```plaintext
/*--*/ Burrito: Pick protein, then pick rice
INSERT INTO menuca_v3.modifier_groups (dish_id, name, is_required, min_selections, max_selections)
VALUES 
  (2, 'Protein', TRUE, 1, 1),  /*--*/ Must pick protein
  (2, 'Add-ons', FALSE, 0, 3);  /*--*/ Optional add-ons

/*--*/ Protein modifiers
INSERT INTO menuca_v3.dish_modifiers (modifier_group_id, name, price)
SELECT id, 'Chicken', 0.00 FROM menuca_v3.modifier_groups WHERE name = 'Protein' AND dish_id = 2
RETURNING id;  /*--*/ Save chicken modifier_id

/*--*/ Nested group: Only appears if "Chicken" selected
INSERT INTO menuca_v3.modifier_groups (dish_id, name, is_required, parent_modifier_id, min_selections, max_selections)
VALUES (
  2, 
  'Rice Type', 
  TRUE, 
  <chicken_modifier_id>,  /*--*/ Only show if chicken selected
  1, 
  1
);
```

/*--*/-

## Usage Examples

### Frontend: Validate Before Adding to Cart


```ts
// User customizing pizza
const selectedModifiers = [
  { modifier_id: 101, quantity: 1 },  // Medium size
  { modifier_id: 201, quantity: 1 },  // Extra cheese
  { modifier_id: 202, quantity: 1 }   // Pepperoni
];

// Validate
const { data: validation } = await supabase.rpc('validate_dish_modifiers', {
  p_dish_id: dishId,
  p_selected_modifiers: selectedModifiers
});

if (!validation.valid) {
  // Show errors
  validation.errors.forEach(error => {
    toast.error(`${error.group_name}: ${error.error}`);
  });
} else {
  // Add to cart with calculated price
  addToCart({
    dish_id: dishId,
    modifiers: selectedModifiers,
    price: validation.total_price  // Use validated price!
  });
}
```

### Frontend: Display Modifier Groups


```ts
// Fetch modifier groups for a dish
const { data: groups } = await supabase
  .from('modifier_groups')
  .select(`
    *,
    modifiers:dish_modifiers(*)
  `)
  .eq('dish_id', dishId)
  .order('display_order');

// Render
{groups.map(group => (
  <div key={group.id}>
    <h3>
      {group.name}
      {group.is_required && <span className="text-red-500">*</span>}
    </h3>
    <p className="text-sm">
      {group.min_selections === group.max_selections
        ? `Choose ${group.max_selections}`
        : `Choose ${group.min_selections}-${group.max_selections}`
      }
    </p>
    
    {group.modifiers.map(modifier => (
      <label key={modifier.id}>
        <input 
          type={group.max_selections === 1 ? 'radio' : 'checkbox'}
          name={`group-${group.id}`}
          value={modifier.id}
        />
        {modifier.name}
        {modifier.price > 0 && ` +$${modifier.price.toFixed(2)}`}
      </label>
    ))}
  </div>
))}
```

/*--*/-

## Verification Queries


```plaintext
/*--*/ Verify tables created
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'menuca_v3'
  AND table_name IN ('modifier_groups');

/*--*/ Verify columns added
SELECT column_name FROM information_schema.columns
WHERE table_schema = 'menuca_v3'
  AND table_name = 'dish_modifiers'
  AND column_name IN ('modifier_group_id', 'is_default', 'display_order');

/*--*/ Verify function exists
SELECT routine_name FROM information_schema.routines
WHERE routine_schema = 'menuca_v3'
  AND routine_name = 'validate_dish_modifiers';

/*--*/ Test validation (replace with real IDs after setup)
SELECT menuca_v3.validate_dish_modifiers(
  1,  /*--*/ dish_id
  '[{"modifier_id": 101, "quantity": 1}]'::JSONB
);
```

/*--*/-

## Testing Requirements

### Test Case 1: Missing Required Group

```plaintext
/*--*/ Setup: Pizza with required size
/*--*/ Test: Don't select any size
SELECT menuca_v3.validate_dish_modifiers(1, '[]'::JSONB);

/*--*/ Expected: valid = false, error about required "Size" group
```

### Test Case 2: Too Many Selections

```plaintext
/*--*/ Setup: Toppings group allows max 3
/*--*/ Test: Select 4 toppings
SELECT menuca_v3.validate_dish_modifiers(
  1,
  '[
    {"modifier_id": 201, "quantity": 1},
    {"modifier_id": 202, "quantity": 1},
    {"modifier_id": 203, "quantity": 1},
    {"modifier_id": 204, "quantity": 1}
  ]'::JSONB
);

/*--*/ Expected: valid = false, error about max 3 toppings
```

### Test Case 3: Valid Selection with Price Calculation

```plaintext
/*--*/ Setup: Pizza base $15, Medium size +$3, 2 toppings +$2 each
/*--*/ Test: Select medium + 2 toppings
SELECT menuca_v3.validate_dish_modifiers(
  1,
  '[
    {"modifier_id": 102, "quantity": 1},
    {"modifier_id": 201, "quantity": 1},
    {"modifier_id": 202, "quantity": 1}
  ]'::JSONB
);

/*--*/ Expected: valid = true, total_price = $22 ($15 + $3 + $2 + $2)
```

/*--*/-

## Expected Outcome

After implementation:
- ✅ Complex modifier rules supported
- ✅ Required groups enforced
- ✅ Min/max selection limits validated
- ✅ Nested/conditional modifiers possible
- ✅ Price calculation includes modifiers
- ✅ Foundation ready for Phase 2 (Menu Display)

/*--*/-

## Rollback Plan


```plaintext
BEGIN;

/*--*/ Drop function
DROP FUNCTION IF EXISTS menuca_v3.validate_dish_modifiers(BIGINT, JSONB);

/*--*/ Remove columns from dish_modifiers
ALTER TABLE menuca_v3.dish_modifiers
  DROP COLUMN IF EXISTS modifier_group_id,
  DROP COLUMN IF EXISTS is_default,
  DROP COLUMN IF EXISTS display_order;

/*--*/ Drop table
DROP TABLE IF EXISTS menuca_v3.modifier_groups;

COMMIT;
```

/*--*/-

## References

- **Gap Analysis:** `/FRONTEND_BUILD_START_HERE.md` (Gap #3: Complex Modifier Handling)
- **Menu Schema:** `/Database/Schemas/menuca_v3.sql`

/*--*/-

**Status:** ⏳ READY FOR ASSIGNMENT  
**Created:** 2025-10-22 by Orchestrator Agent  
**Next Step:** Assign after Ticket 04 completion



