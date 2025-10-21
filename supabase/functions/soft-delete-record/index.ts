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

Deno.serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  if (req.method !== 'POST') {
    return badRequest('Method not allowed');
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
    if (!body.table_name || !body.record_id) {
      return badRequest('Missing required fields: table_name, record_id');
    }

    const validTables = [
      'restaurant_locations',
      'restaurant_contacts',
      'restaurant_domains',
      'restaurant_schedules',
      'restaurant_service_configs'
    ];

    if (!validTables.includes(body.table_name)) {
      return badRequest(`Invalid table_name. Must be one of: ${validTables.join(', ')}`);
    }

    // Call SQL function
    const { data, error } = await supabase.rpc('soft_delete_record', {
      p_table_name: body.table_name,
      p_record_id: body.record_id,
      p_deleted_by: user.id
    });

    if (error) {
      console.error('SQL error:', error);
      throw error;
    }

    const result = data[0];
    if (!result.success) {
      return badRequest(result.message);
    }

    // Calculate recovery window (30 days)
    const deletedAt = new Date(result.deleted_at);
    const recoverableUntil = new Date(deletedAt);
    recoverableUntil.setDate(recoverableUntil.getDate() + 30);

    // Audit logging (async)
    logAdminAction(
      supabase,
      user.id,
      'soft_delete_record',
      body.table_name,
      body.record_id,
      { 
        reason: body.reason || 'No reason provided',
        recoverable_until: recoverableUntil.toISOString()
      }
    ).catch(console.error);

    return successResponse(
      {
        table_name: body.table_name,
        record_id: body.record_id,
        deleted_at: result.deleted_at,
        recoverable_until: recoverableUntil.toISOString()
      },
      result.message
    );

  } catch (error) {
    console.error('Error:', error);
    return internalError('Failed to soft delete record.');
  }
});


