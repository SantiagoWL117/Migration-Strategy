import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from 'jsr:@supabase/supabase-js@2';

// CORS headers
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

Deno.serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    // Parse URL to extract restaurant_id
    const url = new URL(req.url);
    const pathParts = url.pathname.split('/');

    // Expected: /get-restaurant-onboarding/{restaurant_id}/onboarding
    const restaurantIdIndex = pathParts.findIndex(part => part === 'get-restaurant-onboarding') + 1;

    if (!pathParts[restaurantIdIndex]) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Invalid URL format. Expected: /get-restaurant-onboarding/{restaurant_id}/onboarding'
        }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    const restaurantId = parseInt(pathParts[restaurantIdIndex]);

    if (isNaN(restaurantId)) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Invalid restaurant_id. Must be a number.'
        }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    // Create Supabase client (public access)
    const supabaseUrl = Deno.env.get('SUPABASE_URL');
    const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY');
    const supabaseClient = createClient(supabaseUrl!, supabaseAnonKey!);

    // Get onboarding steps using SQL function
    const { data: stepsData, error: stepsError } = await supabaseClient
      .schema('menuca_v3')
      .rpc('get_onboarding_status', {
        p_restaurant_id: restaurantId
      });

    if (stepsError) {
      console.error('Steps fetch error:', stepsError);
      return new Response(
        JSON.stringify({
          success: false,
          error: stepsError.message
        }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    // Get onboarding record with metadata
    const { data: onboardingData, error: onboardingError } = await supabaseClient
      .schema('menuca_v3')
      .from('restaurant_onboarding')
      .select('completion_percentage, onboarding_completed, onboarding_completed_at, onboarding_started_at, current_step')
      .eq('restaurant_id', restaurantId)
      .single();

    if (onboardingError) {
      console.error('Onboarding fetch error:', onboardingError);
      return new Response(
        JSON.stringify({
          success: false,
          error: onboardingError.message
        }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    // Calculate days in onboarding
    const startedAt = new Date(onboardingData.onboarding_started_at);
    const completedAt = onboardingData.onboarding_completed_at
      ? new Date(onboardingData.onboarding_completed_at)
      : new Date();
    const daysInOnboarding = Math.floor((completedAt.getTime() - startedAt.getTime()) / (1000 * 60 * 60 * 24));

    return new Response(
      JSON.stringify({
        success: true,
        restaurant_id: restaurantId,
        completion_percentage: onboardingData.completion_percentage,
        steps: stepsData.map((step: any) => ({
          step_name: step.step_name,
          is_completed: step.is_completed,
          completed_at: step.completed_at
        })),
        started_at: onboardingData.onboarding_started_at,
        completed_at: onboardingData.onboarding_completed_at,
        days_in_onboarding: daysInOnboarding,
        current_step: onboardingData.current_step,
        onboarding_completed: onboardingData.onboarding_completed
      }),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    );

  } catch (error) {
    console.error('Error:', error);
    return new Response(
      JSON.stringify({
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error occurred'
      }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    );
  }
});
