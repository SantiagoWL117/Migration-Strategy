-- Cleanup admin_roles: Keep only Super Admin and create Restaurant Admin
-- Date: January 14, 2026

BEGIN;

-- Delete unused roles (Manager, Support, Restaurant Manager, Staff)
DELETE FROM menuca_v3.admin_roles WHERE id IN (2, 3, 5, 6);

-- Create Restaurant Admin role (id=2)
INSERT INTO menuca_v3.admin_roles (id, name, description, permissions, is_system_role)
VALUES (
  2,
  'Restaurant Admin',
  'Full menu management for assigned restaurants',
  '{"page_access": ["menu", "dishes", "modifiers", "combos", "courses", "prices", "orders", "deals"], "restaurant_access": ["assigned"], "crud_permissions": {"dishes": ["create", "read", "update", "delete"], "dish_prices": ["create", "read", "update", "delete"], "modifier_groups": ["create", "read", "update", "delete"], "modifiers": ["create", "read", "update", "delete"], "modifier_prices": ["create", "read", "update", "delete"], "combo_groups": ["create", "read", "update", "delete"], "combo_group_sections": ["create", "read", "update", "delete"], "courses": ["create", "read", "update", "delete"], "orders": ["read", "update"]}}'::jsonb,
  true
);

COMMIT;
