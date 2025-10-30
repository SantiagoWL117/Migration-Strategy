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
  role_id?: number;
  restaurant_ids?: number[];
  mfa_enabled?: boolean;
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
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get('Authorization');

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return new Response(
        JSON.stringify({ success: false, error: 'Missing authorization header' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // Create Supabase admin client
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
      { auth: { autoRefreshToken: false, persistSession: false } }
    );

    // Verify JWT and get calling user
    const token = authHeader.substring(7);
    const { data: { user }, error: userError } = await supabaseAdmin.auth.getUser(token);

    if (userError || !user) {
      return new Response(
        JSON.stringify({ success: false, error: 'Invalid token' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const callingUserId = user.id;
    console.log(`Calling user: ${callingUserId}`);

    // Check Super Admin role
    const { data: adminUser, error: adminCheckError } = await supabaseAdmin
      .schema('menuca_v3')
      .from('admin_users')
      .select('id, email, role_id, status')
      .eq('auth_user_id', callingUserId)
      .single();

    if (adminCheckError || !adminUser) {
      return new Response(
        JSON.stringify({ success: false, error: 'User is not an admin' }),
        { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    if (adminUser.status !== 'active') {
      return new Response(
        JSON.stringify({ success: false, error: 'Admin account not active' }),
        { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    if (adminUser.role_id !== 1) {
      return new Response(
        JSON.stringify({ success: false, error: 'Super Admin role required' }),
        { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    console.log(`✅ Super Admin validated: ${adminUser.email}`);

    // Parse request body
    const body: CreateAdminRequest = await req.json();
    const { email, password, first_name, last_name, role_id, restaurant_ids = [], mfa_enabled = false } = body;

    // Validate required fields
    if (!email || !password || !first_name || !last_name) {
      return new Response(
        JSON.stringify({ success: false, error: 'Missing required fields' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return new Response(
        JSON.stringify({ success: false, error: 'Invalid email format' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // Validate password strength
    if (password.length < 8) {
      return new Response(
        JSON.stringify({ success: false, error: 'Password must be at least 8 characters' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    console.log(`Creating admin user: ${email}`);

    // STEP 1: Create auth user
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
        JSON.stringify({ success: false, error: 'Failed to create auth user', details: authError.message }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const newAuthUserId = authUser.user!.id;
    console.log(`✅ Auth user created: ${newAuthUserId}`);

    // STEP 2: Create admin_users record
    const insertData: Record<string, unknown> = {
      auth_user_id: newAuthUserId,
      email,
      first_name,
      last_name,
      mfa_enabled,
      status: 'active'
    };

    if (role_id !== undefined) {
      insertData.role_id = role_id;
    }

    const { data: newAdminUser, error: adminError } = await supabaseAdmin
      .schema('menuca_v3')
      .from('admin_users')
      .insert(insertData)
      .select('id')
      .single();

    if (adminError) {
      console.error('Failed to create admin user:', adminError);
      await supabaseAdmin.auth.admin.deleteUser(newAuthUserId);
      return new Response(
        JSON.stringify({ success: false, error: 'Failed to create admin user record', details: adminError.message }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const adminUserId = newAdminUser.id;
    console.log(`✅ Admin user created: ${adminUserId}`);

    // STEP 3: Assign restaurants
    let assignedCount = 0;
    if (restaurant_ids && restaurant_ids.length > 0) {
      const { data: restaurants, error: restaurantError } = await supabaseAdmin
        .schema('menuca_v3')
        .from('restaurants')
        .select('id, name')
        .in('id', restaurant_ids)
        .is('deleted_at', null);

      if (!restaurantError && restaurants && restaurants.length > 0) {
        const validRestaurantIds = restaurants.map(r => r.id);
        const assignments = validRestaurantIds.map(restaurantId => ({
          admin_user_id: adminUserId,
          restaurant_id: restaurantId
        }));

        const { error: assignError } = await supabaseAdmin
          .schema('menuca_v3')
          .from('admin_user_restaurants')
          .insert(assignments);

        if (!assignError) {
          assignedCount = validRestaurantIds.length;
          console.log(`✅ Assigned ${assignedCount} restaurants`);
        }
      }
    }

    // Success response
    return new Response(
      JSON.stringify({
        success: true,
        admin_user_id: adminUserId,
        auth_user_id: newAuthUserId,
        email,
        restaurants_assigned: assignedCount,
        message: `Admin user created successfully${assignedCount > 0 ? ` with ${assignedCount} restaurant(s)` : ''}`
      } as CreateAdminResponse),
      { status: 201, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );

  } catch (error) {
    console.error('Fatal error:', error);
    return new Response(
      JSON.stringify({
        success: false,
        error: 'Internal server error',
        details: error instanceof Error ? error.message : 'Unknown error'
      } as CreateAdminResponse),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }
});
