import { createClient } from 'jsr:@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

interface AssignRestaurantsRequest {
  admin_user_id: number;
  restaurant_ids: number[];
  action: 'add' | 'remove' | 'replace';
}

interface AssignRestaurantsResponse {
  success: boolean;
  action?: string;
  admin_user_id?: number;
  admin_email?: string;
  assignments_before?: number;
  assignments_after?: number;
  affected_count?: number;
  error?: string;
  details?: string;
}

Deno.serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // Verify this is a service role request
    const authHeader = req.headers.get('Authorization');
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');

    if (!authHeader || !authHeader.includes(serviceRoleKey!)) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Unauthorized - Service role required',
          details: 'This endpoint can only be called with the service role key'
        }),
        {
          status: 401,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    // Parse request body
    const body: AssignRestaurantsRequest = await req.json();
    const { admin_user_id, restaurant_ids, action } = body;

    // Validate required fields
    if (!admin_user_id || !restaurant_ids || !action) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Missing required fields',
          details: 'admin_user_id, restaurant_ids, and action are required'
        }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    // Validate action
    if (!['add', 'remove', 'replace'].includes(action)) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Invalid action',
          details: 'action must be one of: add, remove, replace'
        }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    // Validate restaurant_ids is an array
    if (!Array.isArray(restaurant_ids) || restaurant_ids.length === 0) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Invalid restaurant_ids',
          details: 'restaurant_ids must be a non-empty array of numbers'
        }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    // Create Supabase admin client
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
      {
        auth: {
          autoRefreshToken: false,
          persistSession: false
        }
      }
    );

    console.log(`${action.toUpperCase()} restaurants for admin ${admin_user_id}`);

    // STEP 1: Validate admin exists and get current assignments count
    const { data: admin, error: adminError } = await supabaseAdmin
      .from('admin_users')
      .select('id, email, status')
      .eq('id', admin_user_id)
      .is('deleted_at', null)
      .single();

    if (adminError || !admin) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Admin user not found',
          details: `Admin user with id ${admin_user_id} does not exist or is deleted`
        }),
        {
          status: 404,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    if (admin.status !== 'active') {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Admin user is not active',
          details: `Admin user status is ${admin.status}`
        }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    // Get current assignments count
    const { count: assignmentsBefore } = await supabaseAdmin
      .from('admin_user_restaurants')
      .select('id', { count: 'exact', head: true })
      .eq('admin_user_id', admin_user_id);

    console.log(`Admin ${admin.email} has ${assignmentsBefore || 0} assignments`);

    // STEP 2: Validate restaurants exist
    const { data: restaurants, error: restaurantsError } = await supabaseAdmin
      .from('restaurants')
      .select('id, name, slug')
      .in('id', restaurant_ids)
      .is('deleted_at', null);

    if (restaurantsError) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Failed to validate restaurants',
          details: restaurantsError.message
        }),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    if (!restaurants || restaurants.length === 0) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'No valid restaurants found',
          details: `None of the provided restaurant IDs exist or all are deleted`
        }),
        {
          status: 404,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    if (restaurants.length !== restaurant_ids.length) {
      console.warn(`Some restaurants not found. Requested: ${restaurant_ids.length}, Found: ${restaurants.length}`);
    }

    const validRestaurantIds = restaurants.map(r => r.id);
    let affectedCount = 0;

    // STEP 3: Perform action
    if (action === 'remove') {
      // Remove specified restaurant assignments
      const { error: deleteError, count } = await supabaseAdmin
        .from('admin_user_restaurants')
        .delete({ count: 'exact' })
        .eq('admin_user_id', admin_user_id)
        .in('restaurant_id', validRestaurantIds);

      if (deleteError) {
        return new Response(
          JSON.stringify({
            success: false,
            error: 'Failed to remove restaurant assignments',
            details: deleteError.message
          }),
          {
            status: 500,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' }
          }
        );
      }

      affectedCount = count || 0;
      console.log(`✅ Removed ${affectedCount} restaurant assignments`);

    } else if (action === 'replace') {
      // Remove ALL existing assignments first
      const { error: deleteError } = await supabaseAdmin
        .from('admin_user_restaurants')
        .delete()
        .eq('admin_user_id', admin_user_id);

      if (deleteError) {
        return new Response(
          JSON.stringify({
            success: false,
            error: 'Failed to clear existing assignments',
            details: deleteError.message
          }),
          {
            status: 500,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' }
          }
        );
      }

      // Add new assignments
      const assignments = validRestaurantIds.map(rid => ({
        admin_user_id,
        restaurant_id: rid
      }));

      const { error: insertError, count } = await supabaseAdmin
        .from('admin_user_restaurants')
        .insert(assignments, { count: 'exact' });

      if (insertError) {
        return new Response(
          JSON.stringify({
            success: false,
            error: 'Failed to create new assignments',
            details: insertError.message
          }),
          {
            status: 500,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' }
          }
        );
      }

      affectedCount = count || 0;
      console.log(`✅ Replaced all assignments with ${affectedCount} new ones`);

    } else if (action === 'add') {
      // Add new assignments (ignore duplicates)
      const assignments = validRestaurantIds.map(rid => ({
        admin_user_id,
        restaurant_id: rid
      }));

      const { error: insertError, count } = await supabaseAdmin
        .from('admin_user_restaurants')
        .insert(assignments, { count: 'exact' })
        .select('id');

      if (insertError) {
        // Check if error is due to duplicates
        if (insertError.code === '23505') {
          console.log('⚠️  Some assignments already exist (duplicates ignored)');
        } else {
          return new Response(
            JSON.stringify({
              success: false,
              error: 'Failed to add restaurant assignments',
              details: insertError.message
            }),
            {
              status: 500,
              headers: { ...corsHeaders, 'Content-Type': 'application/json' }
            }
          );
        }
      }

      affectedCount = count || 0;
      console.log(`✅ Added ${affectedCount} new restaurant assignments`);
    }

    // Get final assignments count
    const { count: assignmentsAfter } = await supabaseAdmin
      .from('admin_user_restaurants')
      .select('id', { count: 'exact', head: true })
      .eq('admin_user_id', admin_user_id);

    // Success response
    return new Response(
      JSON.stringify({
        success: true,
        action,
        admin_user_id,
        admin_email: admin.email,
        assignments_before: assignmentsBefore || 0,
        assignments_after: assignmentsAfter || 0,
        affected_count: affectedCount,
        message: `Successfully ${action}ed ${affectedCount} restaurant assignment(s) for ${admin.email}`
      } as AssignRestaurantsResponse),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    );

  } catch (error) {
    console.error('Fatal error:', error);
    return new Response(
      JSON.stringify({
        success: false,
        error: 'Internal server error',
        details: error instanceof Error ? error.message : 'Unknown error'
      } as AssignRestaurantsResponse),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    );
  }
});
