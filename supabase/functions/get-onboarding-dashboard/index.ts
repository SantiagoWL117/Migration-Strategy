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

    // Verify authentication (admin only)
    const {
      data: { user },
      error: authError,
    } = await supabaseClient.auth.getUser();

    if (authError || !user) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Unauthorized. Admin authentication required.'
        }),
        {
          status: 401,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    // Get overview using SQL function
    const { data: summaryData, error: summaryError } = await supabaseClient
      .schema('menuca_v3')
      .rpc('get_onboarding_summary');

    if (summaryError) {
      console.error('Summary fetch error:', summaryError);
      return new Response(
        JSON.stringify({
          success: false,
          error: summaryError.message
        }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    // Get at-risk restaurants from view
    const { data: atRiskData, error: atRiskError } = await supabaseClient
      .schema('menuca_v3')
      .from('v_incomplete_onboarding_restaurants')
      .select('*')
      .gte('days_in_onboarding', 7)
      .order('days_in_onboarding', { ascending: false })
      .limit(20);

    if (atRiskError) {
      console.error('At-risk fetch error:', atRiskError);
    }

    // Get recently completed restaurants
    const { data: recentlyCompleted, error: completedError } = await supabaseClient
      .schema('menuca_v3')
      .from('restaurant_onboarding')
      .select('restaurant_id, onboarding_completed_at, restaurants(name)')
      .eq('onboarding_completed', true)
      .not('onboarding_completed_at', 'is', null)
      .order('onboarding_completed_at', { ascending: false })
      .limit(10);

    if (completedError) {
      console.error('Recently completed fetch error:', completedError);
    }

    // Get step statistics from view
    const { data: stepStats, error: stepStatsError } = await supabaseClient
      .schema('menuca_v3')
      .from('v_onboarding_progress_stats')
      .select('*')
      .order('step_order');

    if (stepStatsError) {
      console.error('Step stats fetch error:', stepStatsError);
    }

    // Calculate priority scores for at-risk restaurants
    const atRiskWithPriority = (atRiskData || []).map((restaurant: any) => {
      const priorityScore =
        (restaurant.completion_percentage * 0.4) +
        (restaurant.days_in_onboarding * 2) +
        (restaurant.steps_remaining * -5);

      return {
        id: restaurant.id,
        name: restaurant.name,
        completion: restaurant.completion_percentage,
        days_stuck: restaurant.days_in_onboarding,
        steps_remaining: restaurant.steps_remaining,
        current_step: restaurant.current_step,
        priority_score: Math.round(priorityScore)
      };
    }).sort((a, b) => b.priority_score - a.priority_score);

    // Format recently completed
    const formattedRecentlyCompleted = (recentlyCompleted || []).map((item: any) => ({
      restaurant_id: item.restaurant_id,
      restaurant_name: item.restaurants?.name,
      completed_at: item.onboarding_completed_at
    }));

    return new Response(
      JSON.stringify({
        success: true,
        overview: {
          total_restaurants: summaryData[0]?.total_restaurants || 0,
          completed: summaryData[0]?.completed_onboarding || 0,
          in_progress: summaryData[0]?.incomplete_onboarding || 0,
          avg_completion: summaryData[0]?.avg_completion_percentage || 0
        },
        at_risk: atRiskWithPriority,
        recently_completed: formattedRecentlyCompleted,
        step_stats: stepStats || []
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
