// Supabase client utilities

import { createClient, SupabaseClient } from '@supabase/supabase-js';

/**
 * Create Supabase client with service role key (bypasses RLS)
 */
export function createAdminClient(): SupabaseClient {
  const supabaseUrl = process.env.SUPABASE_URL;
  const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

  if (!supabaseUrl || !supabaseKey) {
    throw new Error('Missing Supabase environment variables');
  }

  return createClient(supabaseUrl, supabaseKey, {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  });
}

/**
 * Create Supabase client with user token (respects RLS)
 */
export function createUserClient(token: string): SupabaseClient {
  const supabaseUrl = process.env.SUPABASE_URL;
  const supabaseKey = process.env.SUPABASE_ANON_KEY;

  if (!supabaseUrl || !supabaseKey) {
    throw new Error('Missing Supabase environment variables');
  }

  return createClient(supabaseUrl, supabaseKey, {
    global: {
      headers: {
        Authorization: `Bearer ${token}`,
      },
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
      created_at: new Date().toISOString(),
    });
  } catch (error) {
    console.error('Failed to log admin action:', error);
    // Don't throw - audit log failure shouldn't break the operation
  }
}

/**
 * Invalidate cache for a resource
 * TODO: Implement actual cache invalidation (Redis, CDN, etc.)
 */
export async function invalidateCache(keys: string | string[]): Promise<void> {
  const keyArray = Array.isArray(keys) ? keys : [keys];
  
  try {
    // TODO: Implement cache invalidation
    // Example: await redis.del(...keyArray);
    // Example: await cdn.purge(...keyArray);
    
    console.log('Cache invalidated:', keyArray);
  } catch (error) {
    console.error('Failed to invalidate cache:', error);
    // Don't throw - cache invalidation failure shouldn't break the operation
  }
}

/**
 * Send notification (Slack, email, etc.)
 * TODO: Implement actual notification system
 */
export async function sendNotification(
  type: 'slack' | 'email' | 'webhook',
  message: string,
  metadata?: Record<string, any>
): Promise<void> {
  try {
    // TODO: Implement notification system
    // Example for Slack:
    // if (type === 'slack') {
    //   await fetch(process.env.SLACK_WEBHOOK_URL!, {
    //     method: 'POST',
    //     body: JSON.stringify({ text: message, ...metadata }),
    //   });
    // }
    
    console.log(`Notification (${type}):`, message, metadata);
  } catch (error) {
    console.error('Failed to send notification:', error);
    // Don't throw - notification failure shouldn't break the operation
  }
}


