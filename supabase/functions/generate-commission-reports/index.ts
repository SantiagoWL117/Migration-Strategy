import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from 'jsr:@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

interface RestaurantCommissionData {
  uuid: string;
  commission_rate: number;
  commission_type: string;
  calculation_result: {
    template_name: string;
    use_total: number;
    for_vendor: number;
    for_menu_ottawa?: number;
    for_menuca: number;
    menuottawa_share: number;
    breakdown?: any;
  };
}

interface GenerateReportsRequest {
  vendor_id: string;
  period_start: string;
  period_end: string;
  statement_number: number;
  restaurants: RestaurantCommissionData[];
}

Deno.serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // Parse request body
    const requestBody: GenerateReportsRequest = await req.json();
    
    const { vendor_id, period_start, period_end, statement_number, restaurants } = requestBody;

    if (!vendor_id || !period_start || !period_end || !statement_number || !restaurants) {
      return new Response(
        JSON.stringify({ 
          error: 'Missing required fields: vendor_id, period_start, period_end, statement_number, restaurants' 
        }),
        { 
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    // Initialize Supabase client with service role for inserts
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
      {
        global: {
          headers: { Authorization: req.headers.get('Authorization')! },
        },
      }
    );

    // Prepare reports for insertion
    const reportsToInsert = restaurants.map(restaurant => ({
      vendor_id: vendor_id,
      restaurant_uuid: restaurant.uuid,
      statement_number: statement_number,
      report_period_start: period_start,
      report_period_end: period_end,
      calculation_template: restaurant.calculation_result.template_name || 'percent_commission',
      calculation_input: {
        template_name: restaurant.calculation_result.template_name || 'percent_commission',
        total: restaurant.calculation_result.use_total,
        restaurant_commission: restaurant.commission_rate,
        commission_type: restaurant.commission_type,
        menuottawa_share: 80.00
      },
      calculation_result: restaurant.calculation_result,
      total_order_amount: restaurant.calculation_result.use_total,
      vendor_commission_amount: restaurant.calculation_result.for_vendor,
      platform_fee_amount: 80.00,
      menu_ottawa_amount: restaurant.calculation_result.for_menu_ottawa || null,
      commission_rate_used: restaurant.commission_rate,
      commission_type_used: restaurant.commission_type,
      report_status: 'finalized',
      report_generated_at: new Date().toISOString()
    }));

    // Insert all reports
    const { data: savedReports, error: insertError } = await supabaseClient
      .from('vendor_commission_reports')
      .insert(reportsToInsert)
      .select();

    if (insertError) {
      throw new Error(`Failed to save reports: ${insertError.message}`);
    }

    // Trigger automatically updates last_commission_rate_used

    return new Response(
      JSON.stringify({
        success: true,
        reports_saved: savedReports?.length || 0,
        reports: savedReports,
        message: `Successfully saved ${savedReports?.length || 0} commission reports`
      }),
      { 
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    );

  } catch (error) {
    console.error('Error in generate-commission-reports:', error);
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

