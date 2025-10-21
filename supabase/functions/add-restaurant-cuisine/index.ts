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
  return jsonResponse({ success: true, data, message }, 201);
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
    if (!body.restaurant_id || !body.cuisine_name) {
      return badRequest('Missing required fields: restaurant_id, cuisine_name');
    }

    // Verify restaurant exists
    const { data: restaurant, error: restaurantError } = await supabase
      .from('restaurants')
      .select('id, name')
      .eq('id', body.restaurant_id)
      .is('deleted_at', null)
      .single();

    if (restaurantError || !restaurant) {
      return badRequest('Restaurant not found', { restaurant_id: body.restaurant_id });
    }

    // Call SQL function to add cuisine
    const { data: result, error: functionError } = await supabase
      .rpc('add_cuisine_to_restaurant', {
        p_restaurant_id: body.restaurant_id,
        p_cuisine_name: body.cuisine_name
      });

    if (functionError) {
      console.error('Function error:', functionError);
      return internalError('Failed to add cuisine');
    }

    const functionResult = result[0];

    if (!functionResult.success) {
      return badRequest(functionResult.message, { cuisine_name: body.cuisine_name });
    }

    // Get the cuisine details
    const { data: cuisine } = await supabase
      .from('cuisine_types')
      .select('id, name, slug')
      .eq('name', body.cuisine_name)
      .single();

    // Log admin action
    logAdminAction(
      supabase,
      user.id,
      'cuisine.add',
      'restaurant_cuisines',
      body.restaurant_id,
      {
        restaurant_id: body.restaurant_id,
        restaurant_name: restaurant.name,
        cuisine_name: body.cuisine_name,
        is_primary: functionResult.message.includes('primary')
      }
    ).catch(console.error);

    return successResponse(
      {
        restaurant_id: body.restaurant_id,
        restaurant_name: restaurant.name,
        cuisine: {
          id: cuisine?.id,
          name: cuisine?.name,
          slug: cuisine?.slug
        },
        is_primary: functionResult.message.includes('primary')
      },
      functionResult.message
    );

  } catch (error) {
    console.error('Error:', error);
    return internalError('Failed to add cuisine');
  }
});

