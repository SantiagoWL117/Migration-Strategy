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
    if (!body.restaurant_id || !body.tag_name) {
      return badRequest('Missing required fields: restaurant_id, tag_name');
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

    // Call SQL function to add tag
    const { data: result, error: functionError } = await supabase
      .rpc('add_tag_to_restaurant', {
        p_restaurant_id: body.restaurant_id,
        p_tag_name: body.tag_name
      });

    if (functionError) {
      console.error('Function error:', functionError);
      return internalError('Failed to add tag');
    }

    const functionResult = result[0];

    if (!functionResult.success) {
      return badRequest(functionResult.message, { tag_name: body.tag_name });
    }

    // Get the tag details
    const { data: tag } = await supabase
      .from('restaurant_tags')
      .select('id, name, slug, category')
      .eq('name', body.tag_name)
      .single();

    // Log admin action
    logAdminAction(
      supabase,
      user.id,
      'tag.add',
      'restaurant_tag_assignments',
      body.restaurant_id,
      {
        restaurant_id: body.restaurant_id,
        restaurant_name: restaurant.name,
        tag_name: body.tag_name,
        tag_category: tag?.category
      }
    ).catch(console.error);

    return successResponse(
      {
        restaurant_id: body.restaurant_id,
        restaurant_name: restaurant.name,
        tag: {
          id: tag?.id,
          name: tag?.name,
          slug: tag?.slug,
          category: tag?.category
        }
      },
      functionResult.message
    );

  } catch (error) {
    console.error('Error:', error);
    return internalError('Failed to add tag');
  }
});

