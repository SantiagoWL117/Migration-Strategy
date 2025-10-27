import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from 'jsr:@supabase/supabase-js@2';

// CORS headers
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

const VALID_STEPS = [
  'basic_info',
  'location',
  'contact',
  'schedule',
  'menu',
  'payment',
  'delivery',
  'testing'
] as const;

type OnboardingStep = typeof VALID_STEPS[number];

Deno.serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    // Parse URL to extract restaurant_id and step
    const url = new URL(req.url);
    const pathParts = url.pathname.split('/');

    // Expected: /update-onboarding-step/{restaurant_id}/onboarding/steps/{step}
    const restaurantIdIndex = pathParts.findIndex(part => part === 'update-onboarding-step') + 1;
    const stepIndex = pathParts.findIndex(part => part === 'steps') + 1;

    if (!pathParts[restaurantIdIndex] || !pathParts[stepIndex]) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Invalid URL format. Expected: /update-onboarding-step/{restaurant_id}/onboarding/steps/{step}'
        }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    const restaurantId = parseInt(pathParts[restaurantIdIndex]);
    const step = pathParts[stepIndex] as OnboardingStep;

    // Validate step name
    if (!VALID_STEPS.includes(step)) {
      return new Response(
        JSON.stringify({
          success: false,
          error: `Invalid step name. Valid steps: ${VALID_STEPS.join(', ')}`
        }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    // Parse request body
    const { completed } = await req.json();

    if (typeof completed !== 'boolean') {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Body must contain "completed" boolean field'
        }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    // Create Supabase client
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: { Authorization: req.headers.get('Authorization')! },
        },
      }
    );

    // Verify authentication
    const {
      data: { user },
      error: authError,
    } = await supabaseClient.auth.getUser();

    if (authError || !user) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Unauthorized. Authentication required.'
        }),
        {
          status: 401,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    // Update the onboarding step
    const columnName = `step_${step}_completed`;
    const timestampColumn = `step_${step}_completed_at`;

    const updateData: any = {
      [columnName]: completed,
      updated_at: new Date().toISOString()
    };

    // Set timestamp only when marking as completed
    if (completed) {
      updateData[timestampColumn] = new Date().toISOString();
    } else {
      updateData[timestampColumn] = null;
    }

    const { data: updateResult, error: updateError } = await supabaseClient
      .schema('menuca_v3')
      .from('restaurant_onboarding')
      .update(updateData)
      .eq('restaurant_id', restaurantId)
      .select('*, restaurants(name)')
      .single();

    if (updateError) {
      console.error('Update error:', updateError);
      return new Response(
        JSON.stringify({
          success: false,
          error: updateError.message
        }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    // Get updated completion status
    const { data: statusData, error: statusError } = await supabaseClient
      .schema('menuca_v3')
      .from('restaurant_onboarding')
      .select('completion_percentage, onboarding_completed, onboarding_completed_at, current_step')
      .eq('restaurant_id', restaurantId)
      .single();

    if (statusError) {
      console.error('Status fetch error:', statusError);
    }

    return new Response(
      JSON.stringify({
        success: true,
        restaurant_id: restaurantId,
        restaurant_name: updateResult.restaurants?.name,
        step_name: step,
        completed: completed,
        completed_at: completed ? updateData[timestampColumn] : null,
        completion_percentage: statusData?.completion_percentage || updateResult.completion_percentage,
        onboarding_completed: statusData?.onboarding_completed || updateResult.onboarding_completed,
        onboarding_completed_at: statusData?.onboarding_completed_at || updateResult.onboarding_completed_at,
        current_step: statusData?.current_step || updateResult.current_step
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
