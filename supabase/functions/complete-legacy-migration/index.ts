import { createClient } from 'jsr:@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

interface CompleteMigrationRequest {
  email: string;
  user_type: 'customer' | 'admin';
}

interface LinkResult {
  success: boolean;
  message: string;
  user_id: number;
}

Deno.serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const { email, user_type }: CompleteMigrationRequest = await req.json();

    if (!email || !user_type) {
      return new Response(
        JSON.stringify({ error: 'Email and user_type are required' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      );
    }

    // Validate user_type
    if (user_type !== 'customer' && user_type !== 'admin') {
      return new Response(
        JSON.stringify({ error: 'user_type must be "customer" or "admin"' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      );
    }

    // Get auth header
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: 'No authorization header' }),
        { 
          status: 401, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      );
    }

    // Create Supabase client with user's JWT
    const supabaseUser = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: { Authorization: authHeader }
        }
      }
    );

    // Get the authenticated user
    const { data: { user }, error: userError } = await supabaseUser.auth.getUser();

    if (userError || !user) {
      console.error('Auth error:', userError);
      return new Response(
        JSON.stringify({ error: 'Not authenticated' }),
        { 
          status: 401, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      );
    }

    // Create service role client for linking
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

    // Call the link_auth_user_id SQL function
    // Note: This returns TABLE(success, message, user_id), so we get an array
    const { data, error: rpcError } = await supabaseAdmin.rpc('link_auth_user_id', {
      p_email: email,
      p_auth_user_id: user.id,
      p_user_type: user_type
    });

    if (rpcError) {
      console.error('RPC error:', rpcError);
      return new Response(
        JSON.stringify({ 
          error: 'Failed to complete migration',
          details: rpcError.message 
        }),
        { 
          status: 500, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      );
    }

    // The function returns an array of rows (TABLE type)
    // Extract the first row
    const result: LinkResult | undefined = Array.isArray(data) && data.length > 0 
      ? data[0] 
      : undefined;

    if (!result) {
      return new Response(
        JSON.stringify({ 
          error: 'Migration failed - no result returned',
          details: 'SQL function did not return expected data'
        }),
        { 
          status: 500, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      );
    }

    if (!result.success) {
      return new Response(
        JSON.stringify({
          success: false,
          message: result.message || 'Migration failed'
        }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      );
    }

    // Success!
    return new Response(
      JSON.stringify({
        success: true,
        message: result.message,
        user_id: result.user_id,
        auth_user_id: user.id
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

