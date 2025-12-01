// supabase/functions/delete-delivery-zone/index.ts
import { createClient } from 'jsr:@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

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
        JSON.stringify({ success: false, error: 'Unauthorized' }),
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

    // Parse query parameters or body
    let zone_id: number | null = null;

    if (req.method === 'DELETE') {
      const url = new URL(req.url);
      const zoneIdParam = url.searchParams.get('zone_id');
      zone_id = zoneIdParam ? parseInt(zoneIdParam) : null;
    } else if (req.method === 'POST') {
      const body = await req.json();
      zone_id = body.zone_id;
    }

    if (!zone_id) {
      return new Response(
        JSON.stringify({ success: false, error: 'zone_id is required' }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    // Get the zone details before deletion for the response
    const { data: zoneDetails, error: fetchError } = await supabaseClient
      .from('restaurant_delivery_areas')
      .select('id, area_name, restaurant_id')
      .eq('id', zone_id)
      .is('deleted_at', null)
      .single();

    if (fetchError || !zoneDetails) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Zone not found or already deleted',
        }),
        {
          status: 404,
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

    // Call SQL function for soft delete
    const { data, error } = await supabaseClient.rpc('soft_delete_delivery_zone', {
      p_zone_id: zone_id,
      p_deleted_by: adminUser?.id ?? null,
    });

    if (error) {
      return new Response(
        JSON.stringify({ success: false, error: error.message }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    // Check the result - the function returns a boolean
    const deleted = data === true || (Array.isArray(data) && data[0] === true);

    if (!deleted) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Failed to delete zone',
        }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    return new Response(
      JSON.stringify({
        success: true,
        data: {
          zone_id: zoneDetails.id,
          zone_name: zoneDetails.area_name,
          restaurant_id: zoneDetails.restaurant_id,
          deleted_at: new Date().toISOString(),
        },
        message: `Zone '${zoneDetails.area_name}' has been soft deleted`,
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
