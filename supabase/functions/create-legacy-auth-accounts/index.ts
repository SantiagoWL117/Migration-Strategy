import { createClient } from 'jsr:@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

interface LegacyUser {
  id: number;
  email: string;
  first_name: string;
  last_name: string;
  login_count: number;
  has_email_verified: boolean;
}

interface CreateResult {
  email: string;
  success: boolean;
  auth_user_id?: string;
  error?: string;
}

Deno.serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // Verify this is an admin request (require service role key in header)
    const authHeader = req.headers.get('Authorization');
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');

    if (!authHeader || !authHeader.includes(serviceRoleKey!)) {
      return new Response(
        JSON.stringify({ error: 'Unauthorized - Service role required' }),
        {
          status: 401,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    // Get request parameters
    const { dry_run = false, limit = null } = await req.json().catch(() => ({}));

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

    // Get all active legacy users (2025 activity)
    let query = supabaseAdmin
      .from('users')
      .select('id, email, first_name, last_name, login_count, has_email_verified')
      .is('auth_user_id', null)
      .is('deleted_at', null)
      .gte('last_login_at', '2025-01-01')
      .order('last_login_at', { ascending: false });

    if (limit) {
      query = query.limit(limit);
    }

    const { data: legacyUsers, error: queryError } = await query;

    if (queryError) {
      console.error('Error fetching legacy users:', queryError);
      return new Response(
        JSON.stringify({ error: 'Failed to fetch legacy users', details: queryError.message }),
        { 
          status: 500, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      );
    }

    if (!legacyUsers || legacyUsers.length === 0) {
      return new Response(
        JSON.stringify({ 
          success: true, 
          message: 'No legacy users found',
          total: 0,
          created: 0,
          failed: 0
        }),
        { 
          status: 200, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      );
    }

    console.log(`Found ${legacyUsers.length} legacy users to process`);

    if (dry_run) {
      return new Response(
        JSON.stringify({ 
          dry_run: true,
          message: `Would create auth accounts for ${legacyUsers.length} users`,
          total: legacyUsers.length,
          sample_users: legacyUsers.slice(0, 5).map(u => ({
            email: u.email,
            name: `${u.first_name} ${u.last_name}`,
            login_count: u.login_count
          }))
        }),
        { 
          status: 200, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      );
    }

    // Create auth accounts for each legacy user
    const results: CreateResult[] = [];
    let successCount = 0;
    let failCount = 0;

    for (const user of legacyUsers) {
      try {
        // Create auth.users record with admin API
        const { data: authUser, error: createError } = await supabaseAdmin.auth.admin.createUser({
          email: user.email,
          email_confirm: false, // Will confirm via password reset
          user_metadata: {
            first_name: user.first_name,
            last_name: user.last_name,
            legacy_migration: true,
            legacy_user_id: user.id,
            migration_created_at: new Date().toISOString()
          }
        });

        if (createError) {
          // Check if user already exists
          if (createError.message.includes('already registered') || createError.message.includes('already exists')) {
            console.log(`⚠️  User already exists: ${user.email}`);
            results.push({
              email: user.email,
              success: false,
              error: 'Already exists in auth.users'
            });
            failCount++;
          } else {
            console.error(`❌ Failed to create auth for ${user.email}:`, createError.message);
            results.push({
              email: user.email,
              success: false,
              error: createError.message
            });
            failCount++;
          }
        } else {
          console.log(`✅ Created auth account for ${user.email} (${user.first_name} ${user.last_name})`);
          results.push({
            email: user.email,
            success: true,
            auth_user_id: authUser.user?.id
          });
          successCount++;
        }

        // Rate limiting - wait 100ms between requests
        await new Promise(resolve => setTimeout(resolve, 100));

      } catch (err) {
        console.error(`❌ Exception creating auth for ${user.email}:`, err);
        results.push({
          email: user.email,
          success: false,
          error: err instanceof Error ? err.message : 'Unknown error'
        });
        failCount++;
      }
    }

    // Return summary
    return new Response(
      JSON.stringify({
        success: true,
        message: `Auth account creation complete`,
        total: legacyUsers.length,
        created: successCount,
        failed: failCount,
        success_rate: `${((successCount / legacyUsers.length) * 100).toFixed(2)}%`,
        results: results.slice(0, 20), // Return first 20 detailed results
        failed_users: results.filter(r => !r.success).slice(0, 10) // First 10 failures
      }),
      { 
        status: 200, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    );

  } catch (error) {
    console.error('Fatal error:', error);
    return new Response(
      JSON.stringify({ 
        error: 'Internal server error', 
        details: error instanceof Error ? error.message : 'Unknown error'
      }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    );
  }
});

