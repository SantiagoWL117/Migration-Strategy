// Supabase client utilities for Edge Functions

import { createClient, SupabaseClient } from 'jsr:@supabase/supabase-js@2';

/**
 * Create Supabase admin client (service role)
 */
export function createAdminClient(): SupabaseClient {
  const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
  const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

  return createClient(supabaseUrl, supabaseServiceKey, {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  });
}

/**
 * Log admin action to audit table
 */
export async function logAdminAction(
  supabase: SupabaseClient,
  userId: string,
  action: string,
  resourceType: string,
  resourceId: number | null,
  metadata?: Record<string, any>
): Promise<void> {
  try {
    await supabase.from('admin_action_logs').insert({
      user_id: userId,
      action,
      resource_type: resourceType,
      resource_id: resourceId,
      metadata,
    });
  } catch (error) {
    console.error('Failed to log admin action:', error);
    // Don't throw - audit log failure shouldn't break the operation
  }
}

/**
 * Invalidate cache for a resource (placeholder)
 */
export async function invalidateCache(keys: string | string[]): Promise<void> {
  const keyArray = Array.isArray(keys) ? keys : [keys];
  console.log('Cache invalidated:', keyArray);
  // TODO: Implement actual cache invalidation
}

/**
 * Send notification (placeholder)
 */
export async function sendNotification(
  type: 'slack' | 'email',
  message: string,
  metadata?: Record<string, any>
): Promise<void> {
  console.log(`Notification (${type}):`, message, metadata);
  // TODO: Implement notification system
}










