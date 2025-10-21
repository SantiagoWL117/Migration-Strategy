// supabase/functions/delete-delivery-zone/index.ts
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
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
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

    // Parse query parameters
    const url = new URL(req.url);
    const zone_id = url.searchParams.get('zone_id');
    const reason = url.searchParams.get('reason') || 'Zone no longer needed';

    if (!zone_id) {
      return new Response(JSON.stringify({ error: 'zone_id is required' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' }
      });
    }

    // Call SQL function
    const { data, error } = await supabaseClient.rpc('soft_delete_delivery_zone', {
      p_zone_id: parseInt(zone_id),
      p_deleted_by: user.id,
      p_reason: reason
    });

    if (error) {
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
        restaurant_id: result.restaurant_id,
        deleted_at: result.deleted_at,
        recoverable_until: result.recoverable_until
      },
      message: `Zone '${result.zone_name}' deleted. Recoverable until ${result.recoverable_until}`
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

