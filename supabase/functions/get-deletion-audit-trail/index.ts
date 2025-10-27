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

function successResponse(data: any) {
  return jsonResponse({ success: true, data }, 200);
}

function internalError(error: string) {
  return jsonResponse({ success: false, error }, 500);
}

Deno.serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  if (req.method !== 'GET') {
    return badRequest('Method not allowed');
  }

  try {
    // Create Supabase client (public access - using service role for RPC)
    const supabaseUrl = Deno.env.get('SUPABASE_URL');
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
    const supabase = createClient(supabaseUrl!, supabaseKey!);

    // Parse query parameters
    const url = new URL(req.url);
    const tableName = url.searchParams.get('table') || 'ALL';
    const daysBack = parseInt(url.searchParams.get('days') || '30');

    // Validate table name
    const validTables = [
      'restaurant_locations',
      'restaurant_contacts',
      'restaurant_domains',
      'restaurant_schedules',
      'restaurant_service_configs',
      'ALL'
    ];

    if (!validTables.includes(tableName)) {
      return badRequest(`Invalid table name. Must be one of: ${validTables.join(', ')}`);
    }

    // Validate days_back
    if (isNaN(daysBack) || daysBack < 1 || daysBack > 365) {
      return badRequest('Invalid days parameter. Must be between 1 and 365.');
    }

    // Call SQL function in menuca_v3 schema
    const { data, error } = await supabase.rpc('get_deletion_audit_trail', {
      p_table_name: tableName,
      p_days_back: daysBack
    }).schema('menuca_v3');

    if (error) {
      console.error('SQL error:', error);
      throw error;
    }

    // Format response with recovery status
    const formatted = data.map((row: any) => ({
      table_name: row.table_name,
      record_id: row.record_id,
      deleted_at: row.deleted_at,
      deleted_by_id: row.deleted_by_id,
      days_since_deletion: row.days_since_deletion,
      recoverable: row.days_since_deletion <= 30  // 30-day recovery window
    }));

    return successResponse({
      total_deletions: formatted.length,
      recovery_window_days: 30,
      deletions: formatted
    });

  } catch (error) {
    console.error('Error:', error);
    return internalError('Failed to retrieve deletion audit trail.');
  }
});


