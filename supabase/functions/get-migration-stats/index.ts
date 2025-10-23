import { createClient } from 'jsr:@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

interface MigrationStats {
  total_customers: number;
  total_admins: number;
  migrated_customers: number;
  migrated_admins: number;
  pending_customers: number;
  pending_admins: number;
  auth_accounts_created: number;
  migration_success_rate: string;
}

Deno.serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // Verify authorization (admin/service role only)
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: 'Authorization required' }),
        { 
          status: 401, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      );
    }

    // Create Supabase service role client
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
      {
        auth: {
          autoRefreshToken: false,
          persistSession: false
        }
      }
    );

    // Call the SQL function to get migration stats
    const { data, error } = await supabase.rpc('get_legacy_migration_stats');

    if (error) {
      console.error('Error fetching migration stats:', error);
      return new Response(
        JSON.stringify({ 
          error: 'Failed to fetch migration stats',
          details: error.message 
        }),
        { 
          status: 500, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      );
    }

    // The function returns TABLE type, so extract first row
    const stats: MigrationStats | undefined = Array.isArray(data) && data.length > 0
      ? data[0]
      : undefined;

    if (!stats) {
      return new Response(
        JSON.stringify({ 
          error: 'No stats available',
          details: 'SQL function returned no data'
        }),
        { 
          status: 500, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      );
    }

    // Return stats
    return new Response(
      JSON.stringify({
        success: true,
        stats: {
          customers: {
            total: stats.total_customers,
            migrated: stats.migrated_customers,
            pending: stats.pending_customers,
            migration_rate: stats.pending_customers > 0 
              ? `${((stats.migrated_customers / stats.total_customers) * 100).toFixed(2)}%`
              : '100%'
          },
          admins: {
            total: stats.total_admins,
            migrated: stats.migrated_admins,
            pending: stats.pending_admins,
            migration_rate: stats.pending_admins > 0
              ? `${((stats.migrated_admins / stats.total_admins) * 100).toFixed(2)}%`
              : '100%'
          },
          overall: {
            total_users: stats.total_customers + stats.total_admins,
            total_migrated: stats.migrated_customers + stats.migrated_admins,
            total_pending: stats.pending_customers + stats.pending_admins,
            auth_accounts_created: stats.auth_accounts_created,
            overall_success_rate: stats.migration_success_rate
          }
        },
        generated_at: new Date().toISOString()
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

