#!/bin/bash
# Execute all staging loads via Supabase MCP

echo 'Loading staging_v1_deals_load.sql...'
# supabase db execute --file staging_inserts_fixed/staging_v1_deals_load.sql

echo 'Loading staging_v1_coupons_load.sql...'
# supabase db execute --file staging_inserts_fixed/staging_v1_coupons_load.sql

echo 'Loading staging_v2_restaurants_deals_load.sql...'
# supabase db execute --file staging_inserts_fixed/staging_v2_restaurants_deals_load.sql

