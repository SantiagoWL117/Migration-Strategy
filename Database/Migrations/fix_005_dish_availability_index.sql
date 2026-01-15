-- FIX #5: Create partial index on dish_availability for hidden dishes
-- 
-- Problem: The function queries dish_availability with:
--   WHERE da.dish_id = d.id AND da.is_hidden = true
-- But no index existed on is_hidden
--
-- Solution: Create a partial index on (dish_id) WHERE is_hidden = true
-- This is more efficient than a full index because it only indexes the rows we query

CREATE INDEX IF NOT EXISTS idx_dish_availability_hidden 
ON menuca_v3.dish_availability (dish_id) 
WHERE is_hidden = true;

-- Stats at time of creation:
-- Total dish_availability records: 1,232
-- Records with is_hidden = true: 1,232 (100%)
