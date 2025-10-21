import { createClient } from 'jsr:@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

interface CreateDeliveryZoneRequest {
  restaurant_id: number;
  zone_name: string;
  center_latitude: number;
  center_longitude: number;
  radius_meters: number;
  delivery_fee_cents: number;
  minimum_order_cents: number;
  estimated_delivery_minutes: number;
}

Deno.serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // Initialize Supabase client
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: { Authorization: req.headers.get('Authorization')! },
        },
      }
    );

    // Verify authentication
    const {
      data: { user },
      error: authError,
    } = await supabaseClient.auth.getUser();

    if (authError || !user) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Unauthorized - Authentication required',
        }),
        {
          status: 401,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    // Parse request body
    const body: CreateDeliveryZoneRequest = await req.json();

    // Validate required fields
    if (!body.restaurant_id || !body.zone_name || !body.center_latitude || 
        !body.center_longitude || !body.radius_meters || 
        body.delivery_fee_cents === undefined || body.minimum_order_cents === undefined || 
        !body.estimated_delivery_minutes) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Missing required fields',
        }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    // Validate numeric fields
    if (body.radius_meters < 500 || body.radius_meters > 50000) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Radius must be between 500m and 50km',
        }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    if (body.delivery_fee_cents < 0 || body.minimum_order_cents < 0) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Fee and minimum order must be non-negative',
        }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    // Call SQL function to create delivery zone
    const { data: zoneData, error: sqlError } = await supabaseClient.rpc(
      'create_delivery_zone',
      {
        p_restaurant_id: body.restaurant_id,
        p_zone_name: body.zone_name,
        p_center_latitude: body.center_latitude,
        p_center_longitude: body.center_longitude,
        p_radius_meters: body.radius_meters,
        p_delivery_fee_cents: body.delivery_fee_cents,
        p_minimum_order_cents: body.minimum_order_cents,
        p_estimated_delivery_minutes: body.estimated_delivery_minutes,
        p_created_by: parseInt(user.id) || null,
      }
    );

    if (sqlError) {
      console.error('SQL Error:', sqlError);
      return new Response(
        JSON.stringify({
          success: false,
          error: sqlError.message,
        }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    if (!zoneData || zoneData.length === 0) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Failed to create delivery zone',
        }),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    const zone = zoneData[0];

    // Return success response
    return new Response(
      JSON.stringify({
        success: true,
        data: {
          zone_id: zone.zone_id,
          restaurant_id: body.restaurant_id,
          zone_name: zone.zone_name,
          area_sq_km: zone.area_sq_km,
          delivery_fee_cents: zone.delivery_fee_cents,
          minimum_order_cents: zone.minimum_order_cents,
          estimated_delivery_minutes: zone.estimated_minutes,
          radius_meters: body.radius_meters,
          center: {
            latitude: body.center_latitude,
            longitude: body.center_longitude,
          },
        },
        message: `Delivery zone "${zone.zone_name}" created successfully (${zone.area_sq_km} sq km)`,
      }),
      {
        status: 201,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    );
  } catch (error) {
    console.error('Error:', error);
    return new Response(
      JSON.stringify({
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error occurred',
      }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    );
  }
});

