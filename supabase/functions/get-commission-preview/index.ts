import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from 'jsr:@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

interface PreviewRequest {
  vendor_id: string;
  period_start: string;  // ISO date
  period_end: string;    // ISO date
}

interface RestaurantWithTotals {
  uuid: string;
  name: string;
  address: string;
  order_total: number;
  commission_template: string;
  last_commission_rate_used: number;
  last_commission_type_used: string;
}

Deno.serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // Parse request
    const url = new URL(req.url);
    const vendorId = url.searchParams.get('vendor_id');
    const periodStart = url.searchParams.get('period_start');
    const periodEnd = url.searchParams.get('period_end');

    if (!vendorId || !periodStart || !periodEnd) {
      return new Response(
        JSON.stringify({ 
          error: 'Missing required parameters: vendor_id, period_start, period_end' 
        }),
        { 
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    // Initialize Supabase client
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: { Authorization: req.headers.get('Authorization')! },
        },
      }
    );

    // Step 1: Fetch vendor details
    const { data: vendor, error: vendorError } = await supabaseClient
      .from('vendors')
      .select('id, business_name, email, contact_first_name, contact_last_name')
      .eq('id', vendorId)
      .eq('is_active', true)
      .single();

    if (vendorError || !vendor) {
      return new Response(
        JSON.stringify({ 
          error: 'Vendor not found or inactive',
          details: vendorError?.message 
        }),
        { 
          status: 404,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    // Step 2: Fetch vendor-restaurant assignments with last used rates
    const { data: assignments, error: assignmentsError } = await supabaseClient
      .from('v_active_vendor_restaurants')
      .select('*')
      .eq('vendor_id', vendorId);

    if (assignmentsError) {
      throw new Error(`Failed to fetch assignments: ${assignmentsError.message}`);
    }

    // Step 3: Calculate order totals for each restaurant
    const restaurantsWithTotals: RestaurantWithTotals[] = await Promise.all(
      (assignments || []).map(async (assignment: any) => {
        // Get completed orders for this restaurant in the period
        const { data: orders, error: ordersError } = await supabaseClient
          .from('orders')
          .select('total')
          .eq('restaurant_uuid', assignment.restaurant_uuid)
          .eq('status', 'completed')
          .gte('created_at', periodStart)
          .lte('created_at', periodEnd);

        if (ordersError) {
          console.error(`Error fetching orders for ${assignment.restaurant_uuid}:`, ordersError);
        }

        const orderTotal = orders?.reduce((sum: number, order: any) => sum + parseFloat(order.total || 0), 0) || 0;

        // Get restaurant address
        const { data: restaurant, error: restaurantError } = await supabaseClient
          .from('restaurants')
          .select('address, city, province, postal_code')
          .eq('uuid', assignment.restaurant_uuid)
          .single();

        if (restaurantError) {
          console.error(`Error fetching restaurant ${assignment.restaurant_uuid}:`, restaurantError);
        }

        const fullAddress = [
          restaurant?.address,
          restaurant?.city,
          restaurant?.province,
          restaurant?.postal_code
        ].filter(Boolean).join(', ');

        return {
          uuid: assignment.restaurant_uuid,
          name: assignment.restaurant_name,
          address: fullAddress || 'Address not available',
          order_total: orderTotal,
          commission_template: assignment.commission_template,
          last_commission_rate_used: assignment.last_commission_rate_used || 10.0,
          last_commission_type_used: assignment.last_commission_type_used || 'percentage'
        };
      })
    );

    // Step 4: Get next statement number
    const { data: statementTracker, error: statementError } = await supabaseClient
      .from('vendor_statement_numbers')
      .select('current_statement_number')
      .eq('vendor_id', vendorId)
      .single();

    if (statementError) {
      throw new Error(`Failed to fetch statement number: ${statementError.message}`);
    }

    const nextStatementNumber = (statementTracker?.current_statement_number || 0) + 1;

    // Step 5: Return preview data
    const response = {
      vendor: {
        id: vendor.id,
        business_name: vendor.business_name,
        email: vendor.email,
        contact_name: `${vendor.contact_first_name || ''} ${vendor.contact_last_name || ''}`.trim()
      },
      period: {
        start: periodStart,
        end: periodEnd
      },
      next_statement_number: nextStatementNumber,
      restaurants: restaurantsWithTotals,
      summary: {
        total_restaurants: restaurantsWithTotals.length,
        total_orders: restaurantsWithTotals.reduce((sum, r) => sum + r.order_total, 0)
      }
    };

    return new Response(
      JSON.stringify(response),
      { 
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    );

  } catch (error) {
    console.error('Error in get-commission-preview:', error);
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

