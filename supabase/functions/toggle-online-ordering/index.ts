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

  if (req.method !== 'POST') {
    return badRequest('Method not allowed. Use POST.');
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

    // Get user
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
    if (!body.restaurant_id || body.enabled === undefined) {
      return badRequest('Missing required fields: restaurant_id, enabled');
    }

    // Validate enabled is boolean
    if (typeof body.enabled !== 'boolean') {
      return badRequest('Field "enabled" must be a boolean');
    }

    // If disabling, require reason
    if (body.enabled === false && (!body.reason || body.reason.trim() === '')) {
      return badRequest('Reason is required when disabling online ordering');
    }

    // Get restaurant and verify ownership/authorization
    const { data: restaurant, error: fetchError } = await supabase
      .from('restaurants')
      .select('id, name, status, online_ordering_enabled')
      .eq('id', body.restaurant_id)
      .is('deleted_at', null)
      .single();

    if (fetchError || !restaurant) {
      return badRequest('Restaurant not found', { restaurant_id: body.restaurant_id });
    }

    // Call SQL function to toggle
    const { data: toggleResult, error: toggleError } = await supabase.rpc('toggle_online_ordering', {
      p_restaurant_id: body.restaurant_id,
      p_enabled: body.enabled,
      p_reason: body.reason || null,
      p_updated_by: user.id
    });

    if (toggleError) {
      console.error('Toggle error:', toggleError);
      // Check if it's a validation error from the function
      if (toggleError.message) {
        return badRequest(toggleError.message);
      }
      throw toggleError;
    }

    // The function returns a table, get first row
    const result = toggleResult && toggleResult.length > 0 ? toggleResult[0] : null;

    if (!result || !result.success) {
      return badRequest(result?.message || 'Failed to toggle online ordering');
    }

    // Log admin action
    logAdminAction(
      supabase,
      user.id,
      body.enabled ? 'restaurant.enable_ordering' : 'restaurant.disable_ordering',
      'restaurants',
      body.restaurant_id,
      {
        enabled: body.enabled,
        reason: body.reason || null,
        restaurant_name: restaurant.name
      }
    ).catch(console.error);

    return successResponse(
      {
        restaurant_id: body.restaurant_id,
        restaurant_name: restaurant.name,
        enabled: result.new_status,
        message: result.message,
        changed_at: new Date().toISOString()
      },
      result.message
    );

  } catch (error) {
    console.error('Error:', error);
    return internalError('Failed to toggle online ordering');
  }
});

