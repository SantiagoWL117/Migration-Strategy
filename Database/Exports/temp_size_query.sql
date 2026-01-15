SELECT DISTINCT name_en
FROM menuca_v3.dishes
WHERE name_fr IS NULL
  AND name_en ~ '[0-9]+"'
ORDER BY name_en;

