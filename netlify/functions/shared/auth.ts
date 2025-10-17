// Authentication and Authorization utilities

import type { SupabaseUser } from './types';

/**
 * Extract and verify Bearer token from Authorization header
 */
export function extractToken(req: Request): string | null {
  const authHeader = req.headers.get('Authorization');
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return null;
  }
  return authHeader.substring(7);
}

/**
 * Verify JWT token and extract user information
 * Note: In production, this would verify the token with Supabase
 */
export async function verifyToken(token: string): Promise<SupabaseUser | null> {
  try {
    // TODO: Implement actual JWT verification with Supabase
    // For now, this is a placeholder
    // In production, use: supabase.auth.getUser(token)
    
    // Example implementation:
    // const { data: { user }, error } = await supabase.auth.getUser(token);
    // if (error || !user) return null;
    
    // Placeholder return (replace with actual implementation)
    return {
      id: 'user-id',
      role: 'admin',
      email: 'admin@menu.ca',
      permissions: ['restaurant.create', 'restaurant.update', 'cuisine.create'],
    };
  } catch (error) {
    console.error('Token verification error:', error);
    return null;
  }
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
      'restaurant.read',
      'restaurant.create',
      'restaurant.update',
      'cuisine.read',
      'cuisine.create',
      'tag.read',
      'tag.create',
    ],
    restaurant_owner: [
      'restaurant.read',
      'restaurant.update_own',
      'cuisine.read',
      'tag.read',
    ],
    user: [
      'restaurant.read',
    ],
  };

  const perms = rolePermissions[user.role] || [];
  return perms.includes(permission);
}

/**
 * Check if user can modify specific restaurant
 */
export async function canModifyRestaurant(
  user: SupabaseUser,
  restaurantId: number
): Promise<boolean> {
  // Super admin and regular admin can modify any restaurant
  if (user.role === 'super_admin' || user.role === 'admin') {
    return true;
  }

  // Restaurant owners can only modify their own restaurants
  if (user.role === 'restaurant_owner') {
    // TODO: Query database to check if user owns this restaurant
    // const { data } = await supabase
    //   .from('restaurant_admin_users')
    //   .select('restaurant_id')
    //   .eq('admin_user_id', user.id)
    //   .eq('restaurant_id', restaurantId)
    //   .single();
    // return !!data;
    
    return false; // Placeholder
  }

  return false;
}

/**
 * Require authentication
 * Throws error if user is not authenticated
 */
export async function requireAuth(req: Request): Promise<SupabaseUser> {
  const token = extractToken(req);
  if (!token) {
    throw new Error('Authentication required');
  }

  const user = await verifyToken(token);
  if (!user) {
    throw new Error('Invalid or expired token');
  }

  return user;
}

/**
 * Require specific permission
 * Throws error if user doesn't have permission
 */
export async function requirePermission(
  req: Request,
  permission: string
): Promise<SupabaseUser> {
  const user = await requireAuth(req);

  if (!hasPermission(user, permission)) {
    throw new Error(`Permission denied: ${permission}`);
  }

  return user;
}


