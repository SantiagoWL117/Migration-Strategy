import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from 'jsr:@supabase/supabase-js@2';

// Types
interface ConvertRequest {
  restaurant_id?: number;
  parent_restaurant_id: number;
  child_restaurant_ids?: number[];
  updated_by?: number;
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
    const body: ConvertRequest = await req.json();

    if (!body.parent_restaurant_id) {
      return badRequest('Missing required field: parent_restaurant_id');
    }

    // Single conversion
    if (body.restaurant_id) {
      const { data, error } = await supabase.rpc('convert_to_franchise', {
        p_restaurant_id: body.restaurant_id,
        p_parent_restaurant_id: body.parent_restaurant_id,
        p_updated_by: body.updated_by || null,
      });

      if (error) {
        console.error('SQL error:', error);
        if (error.message.includes('not found')) {
          return badRequest('Restaurant or parent not found');
        }
        throw error;
      }

      if (!data || data.length === 0) {
        return badRequest('Failed to convert restaurant');
      }

      const result = data[0];

      logAdminAction(supabase, user.id, 'franchise.convert', 'restaurants', body.restaurant_id, {
        parent_restaurant_id: body.parent_restaurant_id,
      }).catch(console.error);

      return successResponse(
        {
          restaurant_id: result.restaurant_id,
          restaurant_name: result.restaurant_name,
          parent_restaurant_id: result.parent_restaurant_id,
          parent_brand_name: result.parent_brand_name,
        },
        'Restaurant converted to franchise successfully'
      );
    }

    // Batch conversion
    if (body.child_restaurant_ids && Array.isArray(body.child_restaurant_ids)) {
      if (body.child_restaurant_ids.length === 0) {
        return badRequest('child_restaurant_ids must be a non-empty array');
      }

      const { data, error } = await supabase.rpc('batch_link_franchise_children', {
        p_parent_restaurant_id: body.parent_restaurant_id,
        p_child_restaurant_ids: body.child_restaurant_ids,
        p_updated_by: body.updated_by || null,
      });

      if (error) {
        console.error('SQL error:', error);
        throw error;
      }

      if (!data || data.length === 0) {
        return badRequest('Failed to link restaurants');
      }

      const result = data[0];

      logAdminAction(supabase, user.id, 'franchise.batch_link', 'restaurants', body.parent_restaurant_id, {
        child_count: result.linked_count,
      }).catch(console.error);

      return successResponse(
        {
          parent_restaurant_id: result.parent_restaurant_id,
          parent_brand_name: result.parent_brand_name,
          linked_count: result.linked_count,
          child_restaurants: result.child_restaurants || [],
        },
        `Successfully linked ${result.linked_count} restaurants to franchise`
      );
    }

    return badRequest('Must provide either restaurant_id or child_restaurant_ids');

  } catch (error: any) {
    console.error('Error:', error);
    return internalError('Failed to convert restaurant');
  }
});
