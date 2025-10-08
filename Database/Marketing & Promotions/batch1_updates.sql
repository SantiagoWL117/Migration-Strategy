-- Processing 2 deals
UPDATE staging.v1_deals SET exceptions_json=NULL, active_days_json='["mon", "tue", "wed", "thu", "fri", "sat", "sun"]'::jsonb, items_json=NULL WHERE id=19;
UPDATE staging.v1_deals SET exceptions_json='["884"]'::jsonb, active_days_json=NULL, items_json='["5728"]'::jsonb WHERE id=22;
