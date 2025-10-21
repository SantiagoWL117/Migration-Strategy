// supabase/functions/update-delivery-zone/index.ts
import { createClient } from 'jsr:@supabase/supabase-js@2';

Deno.serve(async (req) => {
  // CORS handling
  if (req.method === 'OPTIONS') {
    return new Response('ok', { 
      headers: { 
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type'
      } 
    });
  }

  try {
    // Authentication check
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return new Response(JSON.stringify({ error: 'Missing authorization header' }), {
        status: 401,
        headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' }
      });
    }

    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: authHeader } } }
    );

    const { data: { user }, error: userError } = await supabaseClient.auth.getUser();
    if (userError || !user) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401,
        headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' }
      });
    }

    // Parse request body
    const body = await req.json();
    const {
      zone_id,
      zone_name,
      delivery_fee_cents,
      minimum_order_cents,
      estimated_delivery_minutes,
      radius_meters,
      is_active
    } = body;

    // Validation
    if (!zone_id) {
      return new Response(JSON.stringify({ error: 'zone_id is required' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' }
      });
    }

    if (radius_meters !== undefined && (radius_meters < 500 || radius_meters > 50000)) {
      return new Response(JSON.stringify({ 
        error: 'radius_meters must be between 500 and 50000' 
      }), {
        status: 400,
        headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' }
      });
    }

    if (delivery_fee_cents !== undefined && delivery_fee_cents < 0) {
      return new Response(JSON.stringify({ error: 'delivery_fee_cents must be >= 0' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' }
      });
    }

    // Call SQL function
    const { data, error } = await supabaseClient.rpc('update_delivery_zone', {
      p_zone_id: zone_id,
      p_zone_name: zone_name,
      p_delivery_fee_cents: delivery_fee_cents,
      p_minimum_order_cents: minimum_order_cents,
      p_estimated_delivery_minutes: estimated_delivery_minutes,
      p_new_radius_meters: radius_meters,
      p_is_active: is_active,
      p_updated_by: user.id
    });

    if (error) {
      console.error('SQL Error:', error);
      return new Response(JSON.stringify({ error: error.message }), {
        status: 400,
        headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' }
      });
    }

    const result = data[0];

    return new Response(JSON.stringify({
      success: true,
      data: {
        zone_id: result.zone_id,
        zone_name: result.zone_name,
        area_sq_km: result.area_sq_km,
        delivery_fee_cents: result.delivery_fee_cents,
        minimum_order_cents: result.minimum_order_cents,
        estimated_delivery_minutes: result.estimated_minutes,
        radius_meters: result.radius_meters,
        is_active: result.is_active,
        geometry_updated: result.geometry_updated,
        updated_at: result.updated_at
      },
      message: result.geometry_updated 
        ? `Zone updated with new geometry (${result.area_sq_km} sq km)`
        : 'Zone updated successfully'
    }), {
      status: 200,
      headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' }
    });

  } catch (error) {
    console.error('Error:', error);
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' }
    });
  }
});

