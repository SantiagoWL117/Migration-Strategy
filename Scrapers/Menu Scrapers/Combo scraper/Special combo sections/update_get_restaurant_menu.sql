-- Update get_restaurant_menu function to use renamed columns
-- NOTE: Special section fields (has_special_section, dish_selections) will be added once data is scraped

CREATE OR REPLACE FUNCTION menuca_v3.get_restaurant_menu(p_restaurant_id bigint, p_language_code text DEFAULT 'en'::text, p_combo_default_only boolean DEFAULT false)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE
AS $function$
DECLARE
  v_result jsonb;
BEGIN
  -- Check restaurant exists and is active
  IF NOT EXISTS (
    SELECT 1 FROM menuca_v3.restaurants
    WHERE id = p_restaurant_id AND status = 'active' AND deleted_at IS NULL
  ) THEN
    RAISE EXCEPTION 'Restaurant not found or inactive';
  END IF;

  -- Build complete menu structure with modifiers AND combo data
  SELECT jsonb_build_object(
    'restaurant_id', p_restaurant_id,
    'combo_default_only', p_combo_default_only,
    'courses', COALESCE(
      jsonb_agg(
        jsonb_build_object(
          'id', c.id,
          'name', c.name,
          'description', c.description,
          'display_order', c.display_order,
          'dishes', COALESCE((
            SELECT jsonb_agg(
              jsonb_build_object(
                'id', d.id,
                'name', d.name,
                'description', d.description,
                'display_order', d.display_order,
                'is_combo', d.is_combo,
                'has_customization', d.has_customization,
                'image_url', d.image_url,
                'prices', (
                  SELECT jsonb_agg(
                    jsonb_build_object(
                      'id', dp.id,
                      'size_variant', dp.size_variant,
                      'price', dp.price,
                      'display_order', dp.display_order
                    ) ORDER BY dp.display_order
                  )
                  FROM menuca_v3.dish_prices dp
                  WHERE dp.dish_id = d.id
                    AND dp.is_active = true
                    AND dp.deleted_at IS NULL
                ),
                -- Regular modifier groups (existing)
                'modifier_groups', COALESCE((
                  SELECT jsonb_agg(
                    jsonb_build_object(
                      'id', mg.id,
                      'name', mg.name,
                      'is_required', mg.is_required,
                      'min_selections', mg.min_selections,
                      'max_selections', mg.max_selections,
                      'display_order', mg.display_order,
                      'free_items', mg.free_items,
                      'modifiers', (
                        SELECT jsonb_agg(
                          jsonb_build_object(
                            'id', dm.id,
                            'name', dm.name,
                            'modifier_type', dm.modifier_type,
                            'is_default', dm.is_default,
                            'is_included', dm.is_included,
                            'display_order', dm.display_order,
                            'prices', COALESCE((
                              SELECT jsonb_agg(
                                jsonb_build_object(
                                  'id', dmp.id,
                                  'size_variant', dmp.size_variant,
                                  'price', dmp.price,
                                  'display_order', dmp.display_order
                                ) ORDER BY dmp.display_order
                              )
                              FROM menuca_v3.dish_modifier_prices dmp
                              WHERE dmp.dish_modifier_id = dm.id
                                AND dmp.is_active = true
                                AND dmp.deleted_at IS NULL
                            ), '[]'::jsonb)
                          ) ORDER BY dm.display_order
                        )
                        FROM menuca_v3.dish_modifiers dm
                        WHERE dm.modifier_group_id = mg.id
                          AND dm.deleted_at IS NULL
                      )
                    ) ORDER BY mg.display_order
                  )
                  FROM menuca_v3.modifier_groups mg
                  WHERE mg.dish_id = d.id
                    AND mg.deleted_at IS NULL
                ), '[]'::jsonb),
                -- Combo groups for this dish
                'combo_groups', COALESCE((
                  SELECT jsonb_agg(
                    jsonb_build_object(
                      'id', cg.id,
                      'name', cg.name,
                      'number_of_items', cg.special_number_of_items,
                      'display_header', cg.special_display_header,
                      'sections', COALESCE((
                        SELECT jsonb_agg(
                          jsonb_build_object(
                            'id', cgs.id,
                            'section_type', cgs.section_type,
                            'use_header', cgs.use_header,
                            'display_order', cgs.display_order,
                            'free_items', cgs.free_items,
                            'min_selection', cgs.min_selection,
                            'max_selection', cgs.max_selection,
                            'is_active', cgs.is_active,
                            'modifier_groups', COALESCE((
                              SELECT jsonb_agg(
                                jsonb_build_object(
                                  'id', cmg.id,
                                  'name', cmg.name,
                                  'type_code', cmg.type_code,
                                  'is_selected', cmg.is_selected,
                                  'modifiers', COALESCE((
                                    SELECT jsonb_agg(
                                      jsonb_build_object(
                                        'id', cm.id,
                                        'name', cm.name,
                                        'display_order', cm.display_order,
                                        'prices', COALESCE((
                                          SELECT jsonb_agg(
                                            jsonb_build_object(
                                              'id', cmp.id,
                                              'size_variant', cmp.size_variant,
                                              'price', cmp.price
                                            ) ORDER BY cmp.size_variant
                                          )
                                          FROM menuca_v3.combo_modifier_prices cmp
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
                              WHERE cmg.combo_group_section_id = cgs.id
                                -- Filter by is_selected if p_combo_default_only is true
                                AND (NOT p_combo_default_only OR cmg.is_selected = true)
                            ), '[]'::jsonb)
                          ) ORDER BY cgs.display_order
                        )
                        FROM menuca_v3.combo_group_sections cgs
                        WHERE cgs.combo_group_id = cg.id
                          AND cgs.is_active = true
                      ), '[]'::jsonb)
                    ) ORDER BY cg.id
                  )
                  FROM menuca_v3.dish_combo_groups dcg
                  JOIN menuca_v3.combo_groups cg ON dcg.combo_group_id = cg.id
                  WHERE dcg.dish_id = d.id
                    AND dcg.is_active = true
                    AND cg.deleted_at IS NULL
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

