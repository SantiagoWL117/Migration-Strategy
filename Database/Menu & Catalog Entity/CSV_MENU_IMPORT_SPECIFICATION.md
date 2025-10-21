# CSV Menu Import Wizard - Specification

**Status:** 🚧 NOT YET IMPLEMENTED  
**Priority:** Medium (Post-MVP)  
**Estimated Effort:** 6-8 hours

---

## Business Purpose

Enable restaurant owners to bulk import their menu from Excel/CSV files during onboarding, reducing menu entry time from **3-4 hours → 15 minutes**.

---

## CSV Format Specification

### Required Columns
| Column Name | Type | Example | Notes |
|-------------|------|---------|-------|
| `name` | VARCHAR(255) | "Margherita Pizza" | **Required** |
| `price` | NUMERIC(10,2) | 14.99 | **Required** - No $ symbol |
| `category` | VARCHAR(100) | "Pizza" | **Required** - Auto-creates if doesn't exist |

### Optional Columns
| Column Name | Type | Example | Notes |
|-------------|------|---------|-------|
| `description` | TEXT | "Fresh mozzarella..." | Recommended for SEO |
| `ingredients` | TEXT | "Tomatoes, basil, mozzarella" | Comma-separated |
| `image_url` | VARCHAR(500) | "https://..." | Must be valid URL |
| `is_enabled` | BOOLEAN | "true" or "1" | Defaults to `true` |
| `allergens` | TEXT | "Dairy, Gluten" | Comma-separated |
| `dietary_flags` | TEXT | "Vegetarian" | Comma-separated |

### Example CSV File
```csv
name,price,category,description,ingredients,image_url,is_enabled
Margherita Pizza,14.99,Pizza,Classic Italian pizza,Tomatoes; basil; mozzarella,https://example.com/margherita.jpg,true
Pepperoni Pizza,15.99,Pizza,Spicy pepperoni with cheese,Pepperoni; mozzarella; tomato sauce,https://example.com/pepperoni.jpg,true
Caesar Salad,8.99,Salads,Fresh romaine lettuce,Romaine; parmesan; croutons,,true
Garlic Bread,4.99,Appetizers,Toasted with garlic butter,Bread; garlic; butter,,false
```

**File Format Requirements:**
- UTF-8 encoding (for French accents: café, crêpe, etc.)
- Maximum file size: 5 MB
- Maximum rows: 1000 items
- Supported formats: `.csv`, `.xlsx` (Excel)

---

## Implementation Plan

### Phase 1: SQL Function

```sql
CREATE OR REPLACE FUNCTION menuca_v3.import_menu_from_csv(
    p_restaurant_id BIGINT,
    p_csv_data JSONB,  -- Array of row objects parsed by frontend
    p_created_by BIGINT DEFAULT NULL
)
RETURNS TABLE (
    items_imported INTEGER,
    items_failed INTEGER,
    categories_created INTEGER,
    errors JSONB,  -- Array of error objects
    completion_percentage INTEGER,
    current_step VARCHAR,
    success BOOLEAN
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_row JSONB;
    v_items_imported INTEGER := 0;
    v_items_failed INTEGER := 0;
    v_categories_created INTEGER := 0;
    v_errors JSONB := '[]'::JSONB;
    v_category_id BIGINT;
    v_dish_id BIGINT;
    v_row_number INTEGER := 0;
    v_restaurant_exists BOOLEAN;
BEGIN
    -- 1. Validate restaurant exists
    SELECT EXISTS(
        SELECT 1 FROM menuca_v3.restaurants 
        WHERE id = p_restaurant_id AND deleted_at IS NULL
    ) INTO v_restaurant_exists;
    
    IF NOT v_restaurant_exists THEN
        RETURN QUERY SELECT 0, 0, 0, 
            jsonb_build_array(jsonb_build_object(
                'row', 0, 
                'error', 'Restaurant not found'
            )),
            0, NULL::VARCHAR, false;
        RETURN;
    END IF;

    -- 2. Loop through each row
    FOR v_row IN SELECT * FROM jsonb_array_elements(p_csv_data)
    LOOP
        v_row_number := v_row_number + 1;
        
        BEGIN
            -- 3. Validate required fields
            IF NOT (v_row ? 'name' AND v_row ? 'price' AND v_row ? 'category') THEN
                v_errors := v_errors || jsonb_build_object(
                    'row', v_row_number,
                    'error', 'Missing required fields (name, price, category)'
                );
                v_items_failed := v_items_failed + 1;
                CONTINUE;
            END IF;

            -- 4. Validate price is numeric
            IF NOT (v_row->>'price' ~ '^[0-9]+\.?[0-9]*$') THEN
                v_errors := v_errors || jsonb_build_object(
                    'row', v_row_number,
                    'error', 'Invalid price format: ' || (v_row->>'price')
                );
                v_items_failed := v_items_failed + 1;
                CONTINUE;
            END IF;

            -- 5. Get or create category
            SELECT id INTO v_category_id
            FROM menuca_v3.dish_categories
            WHERE restaurant_id = p_restaurant_id 
              AND LOWER(name) = LOWER(v_row->>'category')
              AND deleted_at IS NULL
            LIMIT 1;

            IF v_category_id IS NULL THEN
                INSERT INTO menuca_v3.dish_categories (
                    restaurant_id,
                    name,
                    created_at
                )
                VALUES (
                    p_restaurant_id,
                    v_row->>'category',
                    NOW()
                )
                RETURNING id INTO v_category_id;
                
                v_categories_created := v_categories_created + 1;
            END IF;

            -- 6. Insert dish
            INSERT INTO menuca_v3.dishes (
                restaurant_id,
                category_id,
                name,
                description,
                ingredients,
                image_url,
                is_enabled,
                created_at
            )
            VALUES (
                p_restaurant_id,
                v_category_id,
                v_row->>'name',
                v_row->>'description',
                v_row->>'ingredients',
                v_row->>'image_url',
                COALESCE((v_row->>'is_enabled')::BOOLEAN, true),
                NOW()
            )
            RETURNING id INTO v_dish_id;

            -- 7. Insert price
            INSERT INTO menuca_v3.dish_prices (
                dish_id,
                price,
                is_active,
                created_at
            )
            VALUES (
                v_dish_id,
                (v_row->>'price')::NUMERIC(10,2),
                true,
                NOW()
            );

            v_items_imported := v_items_imported + 1;

        EXCEPTION WHEN OTHERS THEN
            v_errors := v_errors || jsonb_build_object(
                'row', v_row_number,
                'error', SQLERRM
            );
            v_items_failed := v_items_failed + 1;
        END;
    END LOOP;

    -- 8. Update onboarding tracking (if any items imported)
    IF v_items_imported > 0 THEN
        UPDATE menuca_v3.restaurant_onboarding
        SET 
            step_menu_completed = TRUE,
            step_menu_completed_at = NOW(),
            current_step = 'payment',
            updated_at = NOW()
        WHERE restaurant_id = p_restaurant_id
          AND step_menu_completed = FALSE;
    END IF;

    -- 9. Get updated completion percentage
    DECLARE
        v_completion_percentage INTEGER;
        v_current_step VARCHAR;
    BEGIN
        SELECT completion_percentage, current_step
        INTO v_completion_percentage, v_current_step
        FROM menuca_v3.restaurant_onboarding
        WHERE restaurant_id = p_restaurant_id;

        RETURN QUERY SELECT 
            v_items_imported,
            v_items_failed,
            v_categories_created,
            v_errors,
            v_completion_percentage,
            v_current_step,
            (v_items_imported > 0)::BOOLEAN;
    END;
END;
$$;
```

---

### Phase 2: Edge Function

```typescript
// supabase/functions/import-menu-csv/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: { Authorization: req.headers.get('Authorization')! },
        },
      }
    );

    const { data: { user } } = await supabaseClient.auth.getUser();
    if (!user) {
      return new Response(
        JSON.stringify({ error: 'Unauthorized' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const { restaurant_id, csv_data } = await req.json();

    // Validate input
    if (!restaurant_id || !csv_data || !Array.isArray(csv_data)) {
      return new Response(
        JSON.stringify({ 
          error: 'Invalid request. Required: restaurant_id (number), csv_data (array)' 
        }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // Validate array not empty and not too large
    if (csv_data.length === 0) {
      return new Response(
        JSON.stringify({ error: 'CSV data is empty' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    if (csv_data.length > 1000) {
      return new Response(
        JSON.stringify({ error: 'Maximum 1000 rows allowed per import' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // Call SQL function
    const { data, error } = await supabaseClient.rpc('import_menu_from_csv', {
      p_restaurant_id: restaurant_id,
      p_csv_data: csv_data,
      p_created_by: null
    });

    if (error) {
      return new Response(
        JSON.stringify({ error: error.message }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const result = data[0];

    return new Response(
      JSON.stringify({
        success: result.success,
        result: {
          items_imported: result.items_imported,
          items_failed: result.items_failed,
          categories_created: result.categories_created,
          errors: result.errors,
          completion_percentage: result.completion_percentage,
          current_step: result.current_step
        },
        message: `Successfully imported ${result.items_imported} menu items` +
                 (result.items_failed > 0 ? ` (${result.items_failed} failed)` : '') +
                 (result.categories_created > 0 ? ` and created ${result.categories_created} categories` : '')
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );

  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }
});
```

---

### Phase 3: Frontend Integration

```typescript
// Frontend component example
import Papa from 'papaparse';  // CSV parsing library

async function handleMenuUpload(file: File, restaurantId: number) {
  // 1. Parse CSV file
  Papa.parse(file, {
    header: true,
    encoding: 'UTF-8',
    complete: async (results) => {
      const csvData = results.data;
      
      // 2. Call Edge Function
      const { data, error } = await supabase.functions.invoke('import-menu-csv', {
        body: {
          restaurant_id: restaurantId,
          csv_data: csvData
        }
      });
      
      // 3. Show results to user
      if (data.success) {
        alert(`✅ Imported ${data.result.items_imported} items!`);
        
        // Show errors if any
        if (data.result.items_failed > 0) {
          console.log('Errors:', data.result.errors);
        }
      }
    },
    error: (error) => {
      alert('Failed to parse CSV: ' + error.message);
    }
  });
}
```

---

## Error Handling

### Common Errors & Solutions

| Error | Cause | Solution |
|-------|-------|----------|
| "Missing required fields" | CSV missing name/price/category | Add missing columns |
| "Invalid price format" | Price has $ or commas | Use plain number: 14.99 |
| "File too large" | CSV > 5 MB | Split into multiple files |
| "Invalid encoding" | Not UTF-8 | Save Excel as "CSV UTF-8" |
| "Too many rows" | > 1000 items | Import in batches |

---

## Testing Strategy

1. **Happy Path:** Valid CSV with 50 items → All imported
2. **Partial Errors:** CSV with 50 items, 5 invalid → 45 imported, 5 errors returned
3. **All Errors:** CSV with all invalid data → 0 imported, all errors returned
4. **Category Creation:** CSV with new categories → Categories auto-created
5. **French Characters:** CSV with "Café", "Crêpe" → Properly encoded
6. **Large File:** CSV with 1000 items → Performance < 5s

---

## Business Impact

**Time Savings:**
- Manual entry: 20-30 items × 5 min/item = **1.5-2.5 hours**
- CSV import: 20-30 items × 30 seconds = **10 minutes**
- **Savings: 80-90 minutes per restaurant**

**For 959 restaurants:**
- Total time saved: 959 × 90 min = **1,437 hours**
- At $25/hour support cost = **$35,925 saved**

---

## Recommendation

**Build Priority:** Post-MVP  
**Reason:** Current methods (manual + franchise copy) cover 90% of use cases. Build this after core onboarding is proven to work.

**Build Trigger:** When you see 3+ support tickets requesting bulk import.

