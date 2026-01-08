Here is the prompt for Replit:

Every combo group section in the menuca_v3.combo_group_sections has a display_order column with the order of each section. Lines 116-162 of the function:

'sections', COALESCE((
  SELECT jsonb_agg(
    jsonb_build_object(
      'id', cgs.id,
      'section_type', cgs.section_type,
      'use_header', cgs.use_header,
      'display_order', cgs.display_order,   -- ← Direct from table column
      'free_items', cgs.free_items,
      'min_selection', cgs.min_selection,
      'max_selection', cgs.max_selection,
      ...
    ) ORDER BY cgs.display_order           -- ← Sections ordered by display_order
  )
  FROM menuca_v3.combo_group_sections cgs
  WHERE cgs.combo_group_id = cg.id
    AND cgs.is_active = true
), '[]'::jsonb)


For example for  these  sections are assigned to the dish dish Walk-In Special (Medium Pizza) id 172885  of the restaurant Capital Bites id 973


Combo Group	Section	Type	display_order	free_items	min	max
2957 - Dips	4004	dip	5	0	0	0
2980 - 1 Medium 1 Topping	4062	crust	1	0	1	1
2980 - 1 Medium 1 Topping	4063	custom_ingredients	2	1	1	0


The front end should take the display_order value to render each combo group section in the correct order

create table menuca_v3.combo_group_sections (
  id bigserial not null,
  combo_group_id bigint not null,
  section_type text not null,
  use_header character varying(255) not null,
  display_order smallint not null,
  free_items smallint not null default 0,
  min_selection smallint not null default 0,
  max_selection smallint not null default 1,
  is_active boolean not null default false,
  constraint combo_group_sections_pkey primary key (id),
  constraint combo_group_sections_combo_group_id_fkey foreign KEY (combo_group_id) references menuca_v3.combo_groups (id)
) TABLESPACE pg_default;

create index IF not exists idx_combo_sections_group on menuca_v3.combo_group_sections using btree (combo_group_id) TABLESPACE pg_default;