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

function successResponse(data: any, totalCount: number) {
  return jsonResponse({ success: true, data, total_count: totalCount }, 200);
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
    const latitude = url.searchParams.get('latitude');
    const longitude = url.searchParams.get('longitude');
    const radiusKm = url.searchParams.get('radius_km') || '25';
    const limit = url.searchParams.get('limit') || '50';

    const supabaseUrl = Deno.env.get('SUPABASE_URL');
    const supabaseKey = Deno.env.get('SUPABASE_ANON_KEY');
    const supabase = createClient(supabaseUrl!, supabaseKey!);

    // If location provided, use spatial query
    if (latitude && longitude) {
      const lat = parseFloat(latitude);
      const lng = parseFloat(longitude);
      const radius = parseFloat(radiusKm);
      const maxResults = parseInt(limit);

      if (isNaN(lat) || isNaN(lng) || isNaN(radius) || isNaN(maxResults)) {
        return badRequest('Invalid query parameters. latitude, longitude, radius_km, and limit must be numbers.');
      }

      if (radius < 1 || radius > 100) {
        return badRequest('radius_km must be between 1 and 100');
      }

      if (maxResults < 1 || maxResults > 100) {
        return badRequest('limit must be between 1 and 100');
      }

      // Query operational restaurants with location
      const { data: restaurants, error } = await supabase
        .from('restaurants')
        .select(`
          id,
          name,
          status,
          online_ordering_enabled,
          restaurant_locations!inner(
            id,
            address_line1,
            city,
            province,
            postal_code,
            latitude,
            longitude
          )
        `)
        .eq('status', 'active')
        .is('deleted_at', null)
        .eq('online_ordering_enabled', true)
        .limit(maxResults);

      if (error) {
        console.error('Query error:', error);
        throw error;
      }

      // Calculate distances and filter by radius
      const restaurantsWithDistance = restaurants
        ?.map((r: any) => {
          const location = r.restaurant_locations[0];
          if (!location?.latitude || !location?.longitude) return null;

          // Haversine distance calculation
          const R = 6371; // Earth's radius in km
          const dLat = (location.latitude - lat) * Math.PI / 180;
          const dLon = (location.longitude - lng) * Math.PI / 180;
          const a = 
            Math.sin(dLat / 2) * Math.sin(dLat / 2) +
            Math.cos(lat * Math.PI / 180) * Math.cos(location.latitude * Math.PI / 180) *
            Math.sin(dLon / 2) * Math.sin(dLon / 2);
          const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
          const distance = R * c;

          return {
            id: r.id,
            name: r.name,
            status: r.status,
            can_accept_orders: true, // Already filtered
            distance_km: Math.round(distance * 10) / 10,
            address: {
              line1: location.address_line1,
              city: location.city,
              province: location.province,
              postal_code: location.postal_code
            },
            location: {
              latitude: location.latitude,
              longitude: location.longitude
            }
          };
        })
        .filter((r: any) => r !== null && r.distance_km <= radius)
        .sort((a: any, b: any) => a.distance_km - b.distance_km) || [];

      return successResponse(restaurantsWithDistance, restaurantsWithDistance.length);

    } else {
      // No location provided, return all operational restaurants
      const maxResults = parseInt(limit);

      if (isNaN(maxResults) || maxResults < 1 || maxResults > 100) {
        return badRequest('limit must be between 1 and 100');
      }

      const { data: restaurants, error, count } = await supabase
        .from('restaurants')
        .select('id, name, status, online_ordering_enabled', { count: 'exact' })
        .eq('status', 'active')
        .is('deleted_at', null)
        .eq('online_ordering_enabled', true)
        .limit(maxResults);

      if (error) {
        console.error('Query error:', error);
        throw error;
      }

      const formattedRestaurants = restaurants?.map(r => ({
        id: r.id,
        name: r.name,
        status: r.status,
        can_accept_orders: true
      })) || [];

      return successResponse(formattedRestaurants, count || 0);
    }

  } catch (error) {
    console.error('Error:', error);
    return internalError('Failed to get operational restaurants');
  }
});

