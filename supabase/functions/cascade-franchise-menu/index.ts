import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from 'jsr:@supabase/supabase-js@2';

// Types
interface CascadeMenuRequest {
  parent_restaurant_id: number;
  child_restaurant_ids?: number[];
  dish_id?: number;
  include_pricing?: boolean;
}

// CORS
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

// Utilities
function jsonResponse(data: any, status: number = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { 'Content-Type': 'application/json', ...corsHeaders },
  });
}

function badRequest(error: string): Response {
  return jsonResponse({ success: false, error }, 400);
}

function successResponse(data: any, message?: string): Response {
  return jsonResponse({ success: true, data, message }, 200);
}

function internalError(error: string): Response {
  return jsonResponse({ success: false, error }, 500);
}

async function logAdminAction(supabase: any, userId: string, action: string, resourceType: string, resourceId: number, metadata: any) {
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

Deno.serve(async (req) => {
  // CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  if (req.method !== 'POST') {
    return badRequest('Method not allowed');
  }

  try {
    // Auth
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return jsonResponse({ success: false, error: 'Missing authorization header' }, 401);
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const supabase = createClient(supabaseUrl, supabaseKey);

    // Get user
    const userClient = createClient(supabaseUrl, Deno.env.get('SUPABASE_ANON_KEY')!, {
      global: { headers: { Authorization: authHeader } },
    });
    const { data: { user } } = await userClient.auth.getUser();
    
    if (!user) {
      return jsonResponse({ success: false, error: 'Invalid or expired token' }, 401);
    }

    // Parse body
    const body: CascadeMenuRequest = await req.json();

    if (!body.parent_restaurant_id) {
      return badRequest('Missing required field: parent_restaurant_id');
    }

    // Single dish cascade
    if (body.dish_id) {
      const { data, error } = await supabase.rpc('cascade_dish_to_children', {
        p_parent_restaurant_id: body.parent_restaurant_id,
        p_dish_id: body.dish_id,
        p_child_restaurant_ids: body.child_restaurant_ids || null,
        p_include_pricing: body.include_pricing || false,
      });

      if (error) {
        console.error('SQL error:', error);
        throw error;
      }

      if (!data || data.length === 0) {
        return badRequest('Failed to cascade dish');
      }

      const result = data[0];

      logAdminAction(supabase, user.id, 'franchise.cascade_dish', 'dishes', body.dish_id, {
        parent_restaurant_id: body.parent_restaurant_id,
        children_updated: result.children_updated,
      }).catch(console.error);

      return successResponse(
        {
          parent_restaurant_id: body.parent_restaurant_id,
          dish_id: body.dish_id,
          dish_name: result.dish_name,
          children_updated: result.children_updated,
        },
        `Dish cascaded to ${result.children_updated} franchise locations`
      );
    }

    // Pricing cascade
    if (body.include_pricing) {
      const { data, error } = await supabase.rpc('cascade_pricing_to_children', {
        p_parent_restaurant_id: body.parent_restaurant_id,
        p_child_restaurant_ids: body.child_restaurant_ids || null,
      });

      if (error) {
        console.error('SQL error:', error);
        throw error;
      }

      if (!data || data.length === 0) {
        return badRequest('Failed to cascade pricing');
      }

      const result = data[0];

      logAdminAction(supabase, user.id, 'franchise.cascade_pricing', 'restaurants', body.parent_restaurant_id, {
        children_updated: result.children_updated,
      }).catch(console.error);

      return successResponse(
        {
          parent_restaurant_id: body.parent_restaurant_id,
          children_updated: result.children_updated,
          dishes_updated: result.dishes_updated,
        },
        `Pricing cascaded to ${result.children_updated} franchise locations`
      );
    }

    // Full menu sync
    const { data, error } = await supabase.rpc('sync_menu_from_parent', {
      p_parent_restaurant_id: body.parent_restaurant_id,
      p_child_restaurant_ids: body.child_restaurant_ids || null,
    });

    if (error) {
      console.error('SQL error:', error);
      throw error;
    }

    if (!data || data.length === 0) {
      return badRequest('Failed to sync menu');
    }

    const result = data[0];

    logAdminAction(supabase, user.id, 'franchise.sync_menu', 'restaurants', body.parent_restaurant_id, {
      children_updated: result.children_updated,
      dishes_synced: result.dishes_synced,
    }).catch(console.error);

    return successResponse(
      {
        parent_restaurant_id: body.parent_restaurant_id,
        children_updated: result.children_updated,
        dishes_synced: result.dishes_synced,
      },
      `Menu synced to ${result.children_updated} franchise locations`
    );

  } catch (error: any) {
    console.error('Error:', error);
    return internalError('Failed to cascade menu');
  }
});
