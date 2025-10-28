import { createClient } from 'jsr:@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

interface CreateAdminRequest {
  email: string;
  password: string;
  first_name: string;
  last_name: string;
  restaurant_ids?: number[];
  mfa_enabled?: boolean;
  send_welcome_email?: boolean;
}

interface CreateAdminResponse {
  success: boolean;
  admin_user_id?: number;
  auth_user_id?: string;
  email?: string;
  restaurants_assigned?: number;
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
    const body: CreateAdminRequest = await req.json();
    const {
      email,
      password,
      first_name,
      last_name,
      restaurant_ids = [],
      mfa_enabled = false,
      send_welcome_email = false
    } = body;

    // Validate required fields
    if (!email || !password || !first_name || !last_name) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Missing required fields',
          details: 'email, password, first_name, and last_name are required'
        }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Invalid email format'
        }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    // Validate password strength (min 8 chars)
    if (password.length < 8) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Password too weak',
          details: 'Password must be at least 8 characters'
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

    console.log(`Creating admin user: ${email}`);

    // STEP 1: Create auth.users record
    const { data: authUser, error: authError } = await supabaseAdmin.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
      user_metadata: {
        first_name,
        last_name,
        is_admin: true,
        created_via: 'admin-portal',
        created_at: new Date().toISOString()
      }
    });

    if (authError) {
      console.error('Failed to create auth user:', authError);
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Failed to create auth user',
          details: authError.message
        }),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    const authUserId = authUser.user!.id;
    console.log(`✅ Auth user created: ${authUserId}`);

    // STEP 2: Create admin_users record
    const { data: adminUser, error: adminError } = await supabaseAdmin
      .from('admin_users')
      .insert({
        auth_user_id: authUserId,
        email,
        first_name,
        last_name,
        mfa_enabled,
        status: 'active'
      })
      .select('id')
      .single();

    if (adminError) {
      console.error('Failed to create admin user:', adminError);

      // Rollback: Delete auth user
      await supabaseAdmin.auth.admin.deleteUser(authUserId);

      return new Response(
        JSON.stringify({
          success: false,
          error: 'Failed to create admin user record',
          details: adminError.message
        }),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    const adminUserId = adminUser.id;
    console.log(`✅ Admin user created: ${adminUserId}`);

    // STEP 3: Assign restaurants (if provided)
    let assignedCount = 0;
    if (restaurant_ids && restaurant_ids.length > 0) {
      // Validate restaurants exist
      const { data: restaurants, error: restaurantError } = await supabaseAdmin
        .from('restaurants')
        .select('id, name')
        .in('id', restaurant_ids)
        .is('deleted_at', null);

      if (restaurantError) {
        console.error('Failed to validate restaurants:', restaurantError);
      } else if (restaurants && restaurants.length !== restaurant_ids.length) {
        console.warn(`Some restaurants not found. Requested: ${restaurant_ids.length}, Found: ${restaurants.length}`);
      }

      // Insert assignments for valid restaurants
      const validRestaurantIds = restaurants?.map(r => r.id) || [];
      if (validRestaurantIds.length > 0) {
        const assignments = validRestaurantIds.map(restaurantId => ({
          admin_user_id: adminUserId,
          restaurant_id: restaurantId
        }));

        const { error: assignError } = await supabaseAdmin
          .from('admin_user_restaurants')
          .insert(assignments);

        if (assignError) {
          console.error('Failed to assign restaurants:', assignError);
        } else {
          assignedCount = validRestaurantIds.length;
          console.log(`✅ Assigned ${assignedCount} restaurants`);
        }
      }
    }

    // STEP 4: Send welcome email (optional - placeholder)
    if (send_welcome_email) {
      console.log(`📧 Would send welcome email to ${email}`);
      // TODO: Implement email sending
    }

    // Success response
    return new Response(
      JSON.stringify({
        success: true,
        admin_user_id: adminUserId,
        auth_user_id: authUserId,
        email,
        restaurants_assigned: assignedCount,
        message: `Admin user created successfully${assignedCount > 0 ? ` with ${assignedCount} restaurant(s)` : ''}`
      } as CreateAdminResponse),
      {
        status: 201,
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
      } as CreateAdminResponse),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    );
  }
});
