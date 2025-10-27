import { createClient } from 'jsr:@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

interface CheckLegacyRequest {
  email: string;
}

interface LegacyUser {
  id: number;
  email: string;
  first_name: string;
  last_name: string;
  has_email_verified: boolean;
  auth_user_id: string | null;
}

Deno.serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const { email }: CheckLegacyRequest = await req.json();

    if (!email) {
      return new Response(
        JSON.stringify({ error: 'Email is required' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      );
    }

    // Create Supabase client
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

    // Check if user exists in menuca_v3.users
    const { data: legacyUser, error: queryError } = await supabase
      .from('users')
      .select('id, email, first_name, last_name, has_email_verified, auth_user_id')
      .eq('email', email)
      .is('deleted_at', null)
      .single();

    if (queryError) {
      // User doesn't exist - not a legacy user
      return new Response(
        JSON.stringify({
          is_legacy: false,
          message: 'Not a legacy user'
        }),
        { 
          status: 200, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      );
    }

    const user = legacyUser as LegacyUser;

    // Check if already migrated
    if (user.auth_user_id) {
      return new Response(
        JSON.stringify({
          is_legacy: false,
          already_migrated: true,
          message: 'User already migrated'
        }),
        { 
          status: 200, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      );
    }

    // Legacy user found - needs migration
    return new Response(
      JSON.stringify({
        is_legacy: true,
        user: {
          id: user.id,
          email: user.email,
          first_name: user.first_name,
          last_name: user.last_name,
          has_email_verified: user.has_email_verified
        },
        message: 'Legacy user found - migration required'
      }),
      { 
        status: 200, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    );

  } catch (error) {
    console.error('Error checking legacy account:', error);
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

