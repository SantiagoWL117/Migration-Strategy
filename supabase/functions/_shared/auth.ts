// Authentication and Authorization utilities for Supabase Edge Functions

import { createClient } from 'jsr:@supabase/supabase-js@2';
import type { SupabaseUser } from './types.ts';
import { unauthorized, forbidden } from './response.ts';

/**
 * Get authenticated user from request
 */
export async function getAuthenticatedUser(req: Request): Promise<SupabaseUser> {
  const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
  const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY')!;
  
  const authHeader = req.headers.get('Authorization');
  if (!authHeader) {
    throw unauthorized('Missing authorization header');
  }

  const supabase = createClient(supabaseUrl, supabaseAnonKey, {
    global: {
      headers: { Authorization: authHeader },
    },
  });

  const { data: { user }, error } = await supabase.auth.getUser();

  if (error || !user) {
    throw unauthorized('Invalid or expired token');
  }

  return {
    id: user.id,
    email: user.email,
    role: user.user_metadata?.role || 'user',
    permissions: user.user_metadata?.permissions || [],
  };
}

/**
 * Check if user has specific permission
 */
export function hasPermission(user: SupabaseUser, permission: string): boolean {
  // Super admin has all permissions
  if (user.role === 'super_admin') {
    return true;
  }

  // Check specific permissions
  if (user.permissions && user.permissions.includes(permission)) {
    return true;
  }

  // Role-based permissions
  const rolePermissions: Record<string, string[]> = {
    admin: [
      'restaurant.create',
      'restaurant.update',
      'franchise.create',
      'franchise.update',
      'franchise.menu_cascade',
    ],
    restaurant_owner: [
      'restaurant.read',
      'restaurant.update_own',
    ],
  };

  const perms = rolePermissions[user.role || ''] || [];
  return perms.includes(permission);
}

/**
 * Require specific permission
 * Throws error if user doesn't have permission
 */
export async function requirePermission(
  req: Request,
  permission: string
): Promise<SupabaseUser> {
  const user = await getAuthenticatedUser(req);

  if (!hasPermission(user, permission)) {
    throw forbidden(`Permission denied: ${permission}`);
  }

  return user;
}










