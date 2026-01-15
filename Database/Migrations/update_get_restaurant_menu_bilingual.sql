-- Update get_restaurant_menu to use bilingual columns
-- Phase 6 of Bilingual Menu Support Implementation

CREATE OR REPLACE FUNCTION menuca_v3.get_restaurant_menu(
    p_restaurant_id bigint, 
    p_language_code text DEFAULT 'en'::text, 
    p_combo_default_only boolean DEFAULT false
)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
AS $function$
DECLARE
  v_result jsonb;
  v_use_french boolean;
BEGIN
  -- Determine language
  v_use_french := (p_language_code = 'fr');
  
  -- Check restaurant exists and is active
  IF NOT EXISTS (
    SELECT 1 FROM menuca_v3.restaurants
    WHERE id = p_restaurant_id AND status = 'active' AND deleted_at IS NULL
  ) THEN
    RAISE EXCEPTION 'Restaurant not found or inactive';
  END IF;

  -- Build complete menu structure with bilingual support
  SELECT jsonb_build_object(
    'restaurant_id', p_restaurant_id,
    'language', p_language_code,
    'combo_default_only', p_combo_default_only,
    'courses', COALESCE(
      jsonb_agg(
        jsonb_build_object(
          'id', c.id,
          'name', CASE WHEN v_use_french THEN COALESCE(c.name_fr, c.name_en) ELSE COALESCE(c.name_en, c.name_fr) END,
          'description', CASE WHEN v_use_french THEN COALESCE(c.description_fr, c.description_en) ELSE COALESCE(c.description_en, c.description_fr) END,
          'display_order', c.display_order,
          'dishes', COALESCE((
            SELECT jsonb_agg(
              jsonb_build_object(
                'id', d.id,
                'name', CASE WHEN v_use_french THEN COALESCE(d.name_fr, d.name_en) ELSE COALESCE(d.name_en, d.name_fr) END,
                'description', CASE WHEN v_use_french THEN COALESCE(d.description_fr, d.description_en) ELSE COALESCE(d.description_en, d.description_fr) END,
                'display_order', d.display_order,
                'is_combo', d.is_combo,
                'has_customization', d.has_customization,
                'image_url', d.image_url,
                'hidden_days', (
                  SELECT jsonb_agg(da.day_of_week ORDER BY da.day_of_week)
                  FROM menuca_v3.dish_availability da
                  WHERE da.dish_id = d.id AND da.is_hidden = true
                ),
                'prices', (
                  SELECT jsonb_agg(
                    jsonb_build_object(
                      'id', dp.id,
                      'size_variant', dp.size_variant,
                      'dish_size_variant_id', dp.dish_size_variant_id,
                      'modifier_size_variant_id', dsv.modifier_size_variant_id,
                      'price', dp.price,
                      'display_order', dp.display_order
                    ) ORDER BY dp.display_order
                  )
                  FROM menuca_v3.dish_prices dp
                  LEFT JOIN menuca_v3.dish_size_variants dsv ON dsv.id = dp.dish_size_variant_id
                  WHERE dp.dish_id = d.id AND dp.is_active = true AND dp.deleted_at IS NULL
                ),
                'modifier_groups', COALESCE((
                  SELECT jsonb_agg(
                    jsonb_build_object(
                      'id', mg.id,
                      'name', CASE WHEN v_use_french 
                        THEN COALESCE(mgd.name_fr, mgd.name_en, mg.name_fr, mg.name_en) 
                        ELSE COALESCE(mgd.name_en, mgd.name_fr, mg.name_en, mg.name_fr) 
                      END,
                      'category', mg.category,
                      'min_selections', COALESCE(mgd.min_selections, 0),
                      'max_selections', COALESCE(mgd.max_selections, 1),
                      'free_items', COALESCE(mgd.free_items, 0),
                      'display_order', COALESCE(mgd.display_order, 0),
                      'modifiers', COALESCE((
                        SELECT jsonb_agg(
                          jsonb_build_object(
                            'id', m.id,
                            'name', CASE WHEN v_use_french THEN COALESCE(m.name_fr, m.name_en) ELSE COALESCE(m.name_en, m.name_fr) END,
                            'display_order', m.display_order,
                            'is_active', m.is_active,
                            'prices', COALESCE((
                              SELECT jsonb_agg(
                                jsonb_build_object(
                                  'id', mp.id,
                                  'size_variant', mp.size_variant,
                                  'modifier_size_variant_id', mp.modifier_size_variant_id,
                                  'price', mp.price,
                                  'display_order', mp.display_order
                                ) ORDER BY mp.display_order
                              )
                              FROM menuca_v3.modifier_prices mp
                              WHERE mp.modifier_id = m.id AND mp.deleted_at IS NULL
                            ), '[]'::jsonb)
                          ) ORDER BY m.display_order
                        )
                        FROM menuca_v3.modifiers m
                        WHERE m.modifier_group_id = mg.id AND m.deleted_at IS NULL
                      ), '[]'::jsonb)
                    ) ORDER BY COALESCE(mgd.display_order, 0)
                  )
                  FROM menuca_v3.dish_modifier_groups dmg
                  JOIN menuca_v3.modifier_groups mg ON mg.id = dmg.modifier_group_id AND mg.deleted_at IS NULL
                  LEFT JOIN menuca_v3.modifier_group_details mgd ON mgd.dish_modifier_group_id = dmg.id AND mgd.deleted_at IS NULL
                  WHERE dmg.dish_id = d.id AND dmg.deleted_at IS NULL
                ), '[]'::jsonb),
                'combo_groups', COALESCE((
                  SELECT jsonb_agg(
                    jsonb_build_object(
                      'id', cg.id,
                      'name', CASE WHEN v_use_french THEN COALESCE(cg.name_fr, cg.name_en) ELSE COALESCE(cg.name_en, cg.name_fr) END,
                      'number_of_items', cg.special_number_of_items,
                      'display_header', CASE WHEN v_use_french THEN COALESCE(cg.special_display_header_fr, cg.special_display_header_en) ELSE COALESCE(cg.special_display_header_en, cg.special_display_header_fr) END,
                      'sections', COALESCE((
                        SELECT jsonb_agg(
                          jsonb_build_object(
                            'id', cgs.id,
                            'section_type', cgs.section_type,
                            'use_header', CASE WHEN v_use_french THEN COALESCE(cgs.use_header_fr, cgs.use_header_en) ELSE COALESCE(cgs.use_header_en, cgs.use_header_fr) END,
                            'display_order', cgs.display_order,
                            'free_items', cgs.free_items,
                            'min_selection', cgs.min_selection,
                            'max_selection', cgs.max_selection,
                            'is_active', cgs.is_active,
                            'modifier_groups', COALESCE((
                              SELECT jsonb_agg(
                                jsonb_build_object(
                                  'id', cmg.id,
                                  'name', CASE WHEN v_use_french THEN COALESCE(cmg.name_fr, cmg.name_en) ELSE COALESCE(cmg.name_en, cmg.name_fr) END,
                                  'type_code', cmg.type_code,
                                  'is_selected', cmg.is_selected,
                                  'modifiers', COALESCE((
                                    SELECT jsonb_agg(
                                      jsonb_build_object(
                                        'id', cm.id,
                                        'name', CASE WHEN v_use_french THEN COALESCE(cm.name_fr, cm.name_en) ELSE COALESCE(cm.name_en, cm.name_fr) END,
                                        'display_order', cm.display_order,
                                        'prices', COALESCE((
                                          SELECT jsonb_agg(
                                            jsonb_build_object(
                                              'id', cmp.id,
                                              'size_variant', cmp.size_variant,
                                              'modifier_size_variant_id', cmp.modifier_size_variant_id,
                                              'price', cmp.price
                                            ) ORDER BY msv.display_order NULLS FIRST
                                          )
                                          FROM menuca_v3.combo_modifier_prices cmp
                                          LEFT JOIN menuca_v3.modifier_size_variants msv ON msv.id = cmp.modifier_size_variant_id
                                          WHERE cmp.combo_modifier_id = cm.id
                                        ), '[]'::jsonb)
                                      ) ORDER BY cm.display_order
                                    )
                                    FROM menuca_v3.combo_modifiers cm
                                    WHERE cm.combo_modifier_group_id = cmg.id
                                  ), '[]'::jsonb)
                                ) ORDER BY cmg.id
                              )
                              FROM menuca_v3.combo_modifier_groups cmg
                              WHERE cmg.combo_group_section_id = cgs.id AND cmg.is_selected = true
                            ), '[]'::jsonb)
                          ) ORDER BY cgs.display_order
                        )
                        FROM menuca_v3.combo_group_sections cgs
                        WHERE cgs.combo_group_id = cg.id AND cgs.is_active = true
                      ), '[]'::jsonb)
                    ) ORDER BY cg.id
                  )
                  FROM menuca_v3.dish_combo_groups dcg
                  JOIN menuca_v3.combo_groups cg ON dcg.combo_group_id = cg.id
                  WHERE dcg.dish_id = d.id AND dcg.is_active = true AND cg.deleted_at IS NULL
                ), '[]'::jsonb)
              ) ORDER BY d.display_order
            )
            FROM menuca_v3.dishes d
            WHERE d.course_id = c.id
              AND d.restaurant_id = p_restaurant_id
              AND d.is_active = true
              AND d.deleted_at IS NULL
          ), '[]'::jsonb)
        ) ORDER BY c.display_order
      ),
      '[]'::jsonb
    )
  ) INTO v_result
  FROM menuca_v3.courses c
  WHERE c.restaurant_id = p_restaurant_id
    AND c.is_active = true
    AND c.deleted_at IS NULL;

  RETURN v_result;
END;
$function$;

-- Verify function was updated
SELECT 'get_restaurant_menu updated with bilingual support' as status;



