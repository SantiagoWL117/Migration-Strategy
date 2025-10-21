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

Deno.serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  if (req.method !== 'GET') {
    return badRequest('Method not allowed. Use GET.');
  }

  try {
    // Parse query parameters
    const url = new URL(req.url);
    const restaurantId = url.searchParams.get('restaurant_id');

    if (!restaurantId || isNaN(parseInt(restaurantId))) {
      return badRequest('Valid restaurant_id query parameter is required');
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL');
    const supabaseKey = Deno.env.get('SUPABASE_ANON_KEY');
    const supabase = createClient(supabaseUrl!, supabaseKey!);

    // Call SQL function
    const { data, error } = await supabase.rpc('get_restaurant_availability', {
      p_restaurant_id: parseInt(restaurantId)
    });

    if (error) {
      console.error('Availability check error:', error);
      throw error;
    }

    // The function returns a table, get first row
    const availability = data && data.length > 0 ? data[0] : null;

    if (!availability) {
      return badRequest('Restaurant not found', { restaurant_id: restaurantId });
    }

    // Format response with user-friendly message
    let statusMessage = '';
    if (availability.can_accept_orders) {
      statusMessage = 'Open and accepting orders';
    } else if (availability.status !== 'active') {
      const statusLabels: Record<string, string> = {
        pending: 'Pending approval',
        suspended: 'Temporarily suspended',
        inactive: 'Inactive',
        closed: 'Permanently closed'
      };
      statusMessage = statusLabels[availability.status] || `Restaurant is ${availability.status}`;
    } else if (!availability.online_ordering_enabled) {
      statusMessage = availability.closure_reason 
        ? `Temporarily closed: ${availability.closure_reason}` 
        : 'Temporarily closed';
    }

    return successResponse({
      restaurant_id: parseInt(restaurantId),
      can_accept_orders: availability.can_accept_orders,
      status: availability.status,
      online_ordering_enabled: availability.online_ordering_enabled,
      status_message: statusMessage,
      closure_info: availability.closure_reason ? {
        reason: availability.closure_reason,
        closed_since: availability.closed_since,
        closure_duration_hours: availability.closure_duration_hours
      } : null
    });

  } catch (error) {
    console.error('Error:', error);
    return internalError('Failed to check restaurant availability');
  }
});

