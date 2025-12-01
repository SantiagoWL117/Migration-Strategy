// supabase/functions/update-delivery-zone/index.ts
import { createClient } from 'jsr:@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

interface Coordinate {
  lat: number;
  lng: number;
}

interface UpdateDeliveryZoneRequest {
  zone_id: number;
  zone_name?: string;
  polygon_coordinates?: Coordinate[];
  delivery_fee?: number;
  min_order_value?: number;
  estimated_delivery_minutes?: number;
  fee_type?: 'free' | 'flat' | 'conditional';
  is_active?: boolean;
}

Deno.serve(async (req) => {
  // CORS handling
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // Authentication check
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return new Response(
        JSON.stringify({ success: false, error: 'Missing authorization header' }),
        {
          status: 401,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: authHeader } } }
    );

    const {
      data: { user },
      error: userError,
    } = await supabaseClient.auth.getUser();
    if (userError || !user) {
      return new Response(
        JSON.stringify({ success: false, error: 'Unauthorized' }),
        {
          status: 401,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    // Parse request body
    const body: UpdateDeliveryZoneRequest = await req.json();

    // Validation
    if (!body.zone_id) {
      return new Response(
        JSON.stringify({ success: false, error: 'zone_id is required' }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    // Validate polygon if provided
    if (body.polygon_coordinates !== undefined) {
      if (!Array.isArray(body.polygon_coordinates) || body.polygon_coordinates.length < 3) {
        return new Response(
          JSON.stringify({
            success: false,
            error: 'Polygon must have at least 3 coordinate points',
          }),
          {
            status: 400,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          }
        );
      }

      for (const coord of body.polygon_coordinates) {
        if (typeof coord.lat !== 'number' || typeof coord.lng !== 'number') {
          return new Response(
            JSON.stringify({
              success: false,
              error: 'Each coordinate must have numeric lat and lng properties',
            }),
            {
              status: 400,
              headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            }
          );
        }
      }
    }

    // Validate fee_type if provided
    const validFeeTypes = ['free', 'flat', 'conditional'];
    if (body.fee_type && !validFeeTypes.includes(body.fee_type)) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'fee_type must be one of: free, flat, conditional',
        }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    if (body.delivery_fee !== undefined && body.delivery_fee < 0) {
      return new Response(
        JSON.stringify({ success: false, error: 'delivery_fee must be >= 0' }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    if (body.min_order_value !== undefined && body.min_order_value < 0) {
      return new Response(
        JSON.stringify({ success: false, error: 'min_order_value must be >= 0' }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    // Get admin user ID
    const { data: adminUser } = await supabaseClient
      .from('admin_users')
      .select('id')
      .eq('auth_user_id', user.id)
      .single();

    // Call SQL function
    const { data, error } = await supabaseClient.rpc('update_delivery_zone', {
      p_zone_id: body.zone_id,
      p_zone_name: body.zone_name ?? null,
      p_polygon_coordinates: body.polygon_coordinates ?? null,
      p_delivery_fee: body.delivery_fee ?? null,
      p_min_order_value: body.min_order_value ?? null,
      p_estimated_delivery_minutes: body.estimated_delivery_minutes ?? null,
      p_fee_type: body.fee_type ?? null,
      p_is_active: body.is_active ?? null,
      p_updated_by: adminUser?.id ?? null,
    });

    if (error) {
      console.error('SQL Error:', error);
      return new Response(
        JSON.stringify({ success: false, error: error.message }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    if (!data || data.length === 0) {
      return new Response(
        JSON.stringify({ success: false, error: 'Zone not found or update failed' }),
        {
          status: 404,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    const result = data[0];

    return new Response(
      JSON.stringify({
        success: true,
        data: {
          zone_id: result.zone_id,
          zone_name: result.zone_name,
          area_sq_km: result.area_sq_km,
          delivery_fee: result.delivery_fee,
          min_order_value: result.min_order_value,
          estimated_delivery_minutes: result.estimated_minutes,
          is_active: result.is_active,
          updated_at: result.updated_at,
        },
        message: `Zone "${result.zone_name}" updated successfully`,
      }),
      {
        status: 200,
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
