import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from 'jsr:@supabase/supabase-js@2';

// CORS headers
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

// Utilities
function jsonResponse(data: any, status: number = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      'Content-Type': 'application/json',
      ...corsHeaders,
    },
  });
}

function badRequest(error: string, details?: any) {
  return jsonResponse({ success: false, error, ...(details && { details }) }, 400);
}

function successResponse(data: any, message: string) {
  return jsonResponse({ success: true, data, message }, 200);
}

function internalError(error: string) {
  return jsonResponse({ success: false, error }, 500);
}

async function logAdminAction(supabase: any, userId: string, action: string, resourceType: string, resourceId: number, metadata: object) {
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
  }
}

Deno.serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  if (req.method !== 'PATCH') {
    return badRequest('Method not allowed. Use PATCH.');
  }

  try {
    // Authentication
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return jsonResponse({ success: false, error: 'Missing authorization header' }, 401);
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL');
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
    const supabase = createClient(supabaseUrl!, supabaseKey!);

    // Get user (for audit trail)
    const userClient = createClient(supabaseUrl!, Deno.env.get('SUPABASE_ANON_KEY')!, {
      global: { headers: { Authorization: authHeader } },
    });
    const { data: { user } } = await userClient.auth.getUser();
    if (!user) {
      return jsonResponse({ success: false, error: 'Invalid or expired token' }, 401);
    }

    // Parse request body
    const body = await req.json();

    // Input validation
    if (!body.restaurant_id || !body.new_status) {
      return badRequest('Missing required fields: restaurant_id, new_status');
    }

    if (!body.reason || body.reason.trim() === '') {
      return badRequest('Reason is required for status changes');
    }

    const validStatuses = ['active', 'pending', 'suspended', 'inactive', 'closed'];
    if (!validStatuses.includes(body.new_status)) {
      return badRequest(`Invalid new_status. Must be one of: ${validStatuses.join(', ')}`);
    }

    // Get current restaurant info
    const { data: restaurant, error: fetchError } = await supabase
      .from('restaurants')
      .select('id, name, status')
      .eq('id', body.restaurant_id)
      .is('deleted_at', null)
      .single();

    if (fetchError || !restaurant) {
      return badRequest('Restaurant not found', { restaurant_id: body.restaurant_id });
    }

    // Check if status is actually changing
    if (restaurant.status === body.new_status) {
      return badRequest(`Restaurant is already ${body.new_status}`);
    }

    // Validate status transition
    const invalidTransitions = [
      { from: 'active', to: 'pending', reason: 'Cannot revert active restaurant to pending' },
    ];

    const invalidTransition = invalidTransitions.find(
      t => t.from === restaurant.status && t.to === body.new_status
    );

    if (invalidTransition) {
      return badRequest(`Invalid status transition: ${invalidTransition.reason}`);
    }

    // Update status (trigger will automatically create audit record)
    const { error: updateError } = await supabase
      .from('restaurants')
      .update({
        status: body.new_status,
        updated_by: user.id,
        updated_at: new Date().toISOString()
      })
      .eq('id', body.restaurant_id);

    if (updateError) {
      console.error('Status update error:', updateError);
      throw updateError;
    }

    // Add reason to the most recent audit record
    const { error: reasonError } = await supabase
      .from('restaurant_status_history')
      .update({ reason: body.reason.trim() })
      .eq('restaurant_id', body.restaurant_id)
      .order('changed_at', { ascending: false })
      .limit(1);

    if (reasonError) {
      console.error('Failed to add reason to audit record:', reasonError);
      // Non-critical error, continue
    }

    // Log admin action
    logAdminAction(
      supabase,
      user.id,
      'restaurant.status_change',
      'restaurants',
      body.restaurant_id,
      {
        old_status: restaurant.status,
        new_status: body.new_status,
        reason: body.reason,
        restaurant_name: restaurant.name
      }
    ).catch(console.error);

    return successResponse(
      {
        restaurant_id: body.restaurant_id,
        restaurant_name: restaurant.name,
        old_status: restaurant.status,
        new_status: body.new_status,
        reason: body.reason,
        changed_at: new Date().toISOString()
      },
      `Status changed from ${restaurant.status} to ${body.new_status}`
    );

  } catch (error) {
    console.error('Error:', error);
    return internalError('Failed to update restaurant status');
  }
});

