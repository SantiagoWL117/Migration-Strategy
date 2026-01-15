-- Export remaining untranslated modifier groups
\copy (SELECT DISTINCT name_en FROM menuca_v3.modifier_groups WHERE name_fr IS NULL OR TRIM(name_fr) = '' ORDER BY name_en) TO 'C:/Users/santi/Menu.ca/Legacy Database/Migration Strategy/Database/Exports/remaining_modifier_groups.csv' WITH (FORMAT CSV, HEADER true, ENCODING 'UTF8');
