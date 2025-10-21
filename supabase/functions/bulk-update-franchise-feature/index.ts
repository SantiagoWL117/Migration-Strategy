import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from 'jsr:@supabase/supabase-js@2';

// CORS
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type'
};

// Utilities
function jsonResponse(data: any, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      'Content-Type': 'application/json',
      ...corsHeaders
    }
  });
}

function badRequest(error: string) {
  return jsonResponse({
    success: false,
    error
  }, 400);
}

function successResponse(data: any, message: string) {
  return jsonResponse({
    success: true,
    data,
    message
  }, 200);
}

function internalError(error: string) {
  return jsonResponse({
    success: false,
    error
  }, 500);
}

async function logAdminAction(
  supabase: any,
  userId: string,
  action: string,
  resourceType: string,
  resourceId: number,
  metadata: any
) {
  try {
    await supabase.from('admin_action_logs').insert({
      user_id: userId,
      action,
      resource_type: resourceType,
      resource_id: resourceId,
      metadata
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
      return jsonResponse({
        success: false,
        error: 'Missing authorization header'
      }, 401);
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const supabase = createClient(supabaseUrl, supabaseKey);

    // Get user (for audit trail)
    const userClient = createClient(
      supabaseUrl,
      Deno.env.get('SUPABASE_ANON_KEY')!,
      {
        global: {
          headers: { Authorization: authHeader }
        }
      }
    );

    const { data: { user } } = await userClient.auth.getUser();
    if (!user) {
      return jsonResponse({
        success: false,
        error: 'Invalid or expired token'
      }, 401);
    }

    // Parse body
    const body = await req.json();

    // Validation
    if (!body.parent_restaurant_id || !body.feature_key || body.is_enabled === undefined) {
      return badRequest('Missing required fields: parent_restaurant_id, feature_key, is_enabled');
    }

    // Validate feature_key format
    const validFeatureKeys = [
      'online_ordering',
      'delivery',
      'pickup',
      'loyalty_program',
      'reservations',
      'gift_cards',
      'catering',
      'table_booking'
    ];

    if (!validFeatureKeys.includes(body.feature_key)) {
      return badRequest(`Invalid feature_key. Must be one of: ${validFeatureKeys.join(', ')}`);
    }

    // Validate parent_restaurant_id is a franchise parent
    const { data: parentCheck } = await supabase
      .from('restaurants')
      .select('id, franchise_brand_name, is_franchise_parent')
      .eq('id', body.parent_restaurant_id)
      .eq('is_franchise_parent', true)
      .is('deleted_at', null)
      .single();

    if (!parentCheck) {
      return badRequest('Invalid parent_restaurant_id or not a franchise parent');
    }

    // Call SQL function
    const { data, error } = await supabase.rpc('bulk_update_franchise_feature', {
      p_parent_id: body.parent_restaurant_id,
      p_feature_key: body.feature_key,
      p_is_enabled: body.is_enabled,
      p_updated_by: body.updated_by || null
    });

    if (error) {
      console.error('SQL error:', error);
      throw error;
    }

    const updatedCount = data || 0;

    // Audit log (async)
    logAdminAction(
      supabase,
      user.id,
      'franchise.bulk_update_feature',
      'restaurants',
      body.parent_restaurant_id,
      {
        feature_key: body.feature_key,
        is_enabled: body.is_enabled,
        updated_count: updatedCount,
        brand_name: parentCheck.franchise_brand_name
      }
    ).catch(console.error);

    return successResponse({
      parent_restaurant_id: body.parent_restaurant_id,
      brand_name: parentCheck.franchise_brand_name,
      feature_key: body.feature_key,
      is_enabled: body.is_enabled,
      updated_count: updatedCount
    }, `Successfully updated ${body.feature_key} for ${updatedCount} franchise location(s)`);

  } catch (error) {
    console.error('Error:', error);
    return internalError('Failed to update franchise feature');
  }
});


