import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from 'jsr:@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

interface WorkflowRequest {
  vendor_id: string;
  period_start: string;
  period_end: string;
  restaurants: Array<{
    uuid: string;
    commission_rate: number;
    commission_type: string;
    calculation_result: any;
  }>;
}

/**
 * Complete Commission Report Workflow Orchestrator
 * 
 * This function orchestrates the entire commission report generation process:
 * 1. Get next statement number
 * 2. Generate and save all reports
 * 3. Generate PDF files (MANDATORY)
 * 4. Update statement number (MANDATORY)
 * 5. Send reports to vendor (MANDATORY)
 */
Deno.serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // Parse request body
    const requestBody: WorkflowRequest = await req.json();
    const { vendor_id, period_start, period_end, restaurants } = requestBody;

    if (!vendor_id || !period_start || !period_end || !restaurants || restaurants.length === 0) {
      return new Response(
        JSON.stringify({ 
          error: 'Missing required fields: vendor_id, period_start, period_end, restaurants' 
        }),
        { 
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';

    // Initialize Supabase client
    const supabaseClient = createClient(supabaseUrl, supabaseServiceKey);

    const workflowLog: string[] = [];
    const startTime = Date.now();

    // STEP 1: Get next statement number
    workflowLog.push('Step 1: Getting next statement number...');
    
    const { data: statementTracker, error: statementError } = await supabaseClient
      .from('vendor_statement_numbers')
      .select('current_statement_number')
      .eq('vendor_id', vendor_id)
      .single();

    if (statementError) {
      throw new Error(`Failed to fetch statement number: ${statementError.message}`);
    }

    const nextStatementNumber = (statementTracker?.current_statement_number || 0) + 1;
    workflowLog.push(`✅ Next statement number: ${nextStatementNumber}`);

    // STEP 2: Generate and save all reports
    workflowLog.push('Step 2: Generating commission reports...');
    
    const generateResponse = await fetch(`${supabaseUrl}/functions/v1/generate-commission-reports`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${supabaseServiceKey}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        vendor_id,
        period_start,
        period_end,
        statement_number: nextStatementNumber,
        restaurants
      })
    });

    if (!generateResponse.ok) {
      const errorData = await generateResponse.json();
      throw new Error(`Failed to generate reports: ${errorData.error || 'Unknown error'}`);
    }

    const generateResult = await generateResponse.json();
    workflowLog.push(`✅ Saved ${generateResult.reports_saved} reports`);

    // STEP 3: Generate PDF files (MANDATORY)
    workflowLog.push('Step 3: Generating PDF files...');
    
    const pdfResponse = await fetch(`${supabaseUrl}/functions/v1/generate-commission-pdfs`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${supabaseServiceKey}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        vendor_id,
        statement_number: nextStatementNumber
      })
    });

    if (!pdfResponse.ok) {
      const errorData = await pdfResponse.json();
      throw new Error(`Failed to generate PDFs: ${errorData.error || 'Unknown error'}`);
    }

    const pdfResult = await pdfResponse.json();
    workflowLog.push(`✅ Generated ${pdfResult.reports_generated} PDF files`);

    // STEP 4 & 5: Send reports to vendor (MANDATORY) - This also updates statement number
    workflowLog.push('Step 4: Sending reports to vendor...');
    
    const sendResponse = await fetch(`${supabaseUrl}/functions/v1/send-commission-reports`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${supabaseServiceKey}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        vendor_id,
        statement_number: nextStatementNumber
      })
    });

    if (!sendResponse.ok) {
      const errorData = await sendResponse.json();
      throw new Error(`Failed to send reports: ${errorData.error || 'Unknown error'}`);
    }

    const sendResult = await sendResponse.json();
    workflowLog.push(`✅ Reports sent to ${sendResult.vendor_email}`);
    workflowLog.push(`✅ Statement number updated to ${nextStatementNumber}`);

    const endTime = Date.now();
    const duration = ((endTime - startTime) / 1000).toFixed(2);

    return new Response(
      JSON.stringify({
        success: true,
        statement_number: nextStatementNumber,
        reports_count: generateResult.reports_saved,
        pdf_files_generated: pdfResult.reports_generated,
        email_sent: true,
        vendor_email: sendResult.vendor_email,
        total_commission: sendResult.total_commission,
        total_orders: sendResult.total_orders,
        workflow_log: workflowLog,
        duration_seconds: duration,
        message: `Commission report workflow completed successfully in ${duration} seconds`
      }),
      { 
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    );

  } catch (error) {
    console.error('Error in complete-commission-workflow:', error);
    return new Response(
      JSON.stringify({ 
        error: 'Workflow failed',
        details: error instanceof Error ? error.message : 'Unknown error',
        note: 'The workflow may have partially completed. Check database state.'
      }),
      { 
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    );
  }
});

