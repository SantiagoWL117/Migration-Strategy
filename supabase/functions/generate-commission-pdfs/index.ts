import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from 'jsr:@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

interface PDFRequest {
  vendor_id: string;
  statement_number: number;
}

/**
 * Generate a simple PDF report as HTML (can be converted to PDF by browser or puppeteer)
 * For production, consider using:
 * - jsPDF (client-side)
 * - puppeteer/playwright (server-side)
 * - wkhtmltopdf
 * - PDFKit
 */
function generatePDFHTML(data: any): string {
  const report = data.report;
  const vendor = data.vendor;
  const restaurant = data.restaurant;
  const calculationResult = report.calculation_result || {};

  return `
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Commission Report #${report.statement_number}</title>
  <style>
    @page { 
      size: A4;
      margin: 2cm;
    }
    body {
      font-family: Arial, sans-serif;
      line-height: 1.6;
      color: #333;
      max-width: 800px;
      margin: 0 auto;
      padding: 20px;
    }
    .header {
      text-align: center;
      border-bottom: 3px solid #2563eb;
      padding-bottom: 20px;
      margin-bottom: 30px;
    }
    .header h1 {
      color: #1e40af;
      margin: 0;
    }
    .statement-number {
      font-size: 1.2em;
      color: #666;
      margin-top: 10px;
    }
    .section {
      margin-bottom: 25px;
      padding: 15px;
      background: #f9fafb;
      border-radius: 8px;
    }
    .section h2 {
      color: #1e40af;
      margin-top: 0;
      border-bottom: 2px solid #e5e7eb;
      padding-bottom: 10px;
    }
    .info-row {
      display: flex;
      justify-content: space-between;
      padding: 8px 0;
      border-bottom: 1px solid #e5e7eb;
    }
    .info-row:last-child {
      border-bottom: none;
    }
    .label {
      font-weight: bold;
      color: #4b5563;
    }
    .value {
      color: #1f2937;
    }
    .amount {
      font-size: 1.1em;
      font-weight: bold;
      color: #059669;
    }
    .breakdown {
      background: white;
      padding: 15px;
      border-radius: 6px;
      margin-top: 10px;
    }
    .footer {
      margin-top: 40px;
      text-align: center;
      color: #6b7280;
      font-size: 0.9em;
      border-top: 2px solid #e5e7eb;
      padding-top: 20px;
    }
    @media print {
      body {
        padding: 0;
      }
      .section {
        page-break-inside: avoid;
      }
    }
  </style>
</head>
<body>
  <div class="header">
    <h1>Commission Report</h1>
    <div class="statement-number">Statement #${report.statement_number}</div>
    <div>Period: ${new Date(report.report_period_start).toLocaleDateString()} - ${new Date(report.report_period_end).toLocaleDateString()}</div>
  </div>

  <div class="section">
    <h2>Vendor Information</h2>
    <div class="info-row">
      <span class="label">Business Name:</span>
      <span class="value">${vendor.business_name || 'N/A'}</span>
    </div>
    <div class="info-row">
      <span class="label">Contact:</span>
      <span class="value">${vendor.contact_first_name || ''} ${vendor.contact_last_name || ''}</span>
    </div>
    <div class="info-row">
      <span class="label">Email:</span>
      <span class="value">${vendor.email || 'N/A'}</span>
    </div>
  </div>

  <div class="section">
    <h2>Restaurant Information</h2>
    <div class="info-row">
      <span class="label">Name:</span>
      <span class="value">${restaurant.name || 'N/A'}</span>
    </div>
    <div class="info-row">
      <span class="label">Address:</span>
      <span class="value">${[restaurant.address, restaurant.city, restaurant.province, restaurant.postal_code].filter(Boolean).join(', ') || 'N/A'}</span>
    </div>
  </div>

  <div class="section">
    <h2>Commission Breakdown</h2>
    <div class="info-row">
      <span class="label">Commission Template:</span>
      <span class="value">${report.calculation_template || 'N/A'}</span>
    </div>
    <div class="info-row">
      <span class="label">Order Total:</span>
      <span class="value amount">$${parseFloat(report.total_order_amount || 0).toFixed(2)}</span>
    </div>
    <div class="info-row">
      <span class="label">Commission Rate:</span>
      <span class="value">${report.commission_rate_used || 0}${report.commission_type_used === 'percentage' ? '%' : ' (fixed)'}</span>
    </div>
    <div class="info-row">
      <span class="label">Platform Fee (Menu.ca):</span>
      <span class="value">$${parseFloat(report.platform_fee_amount || 0).toFixed(2)}</span>
    </div>
    ${report.menu_ottawa_amount ? `
    <div class="info-row">
      <span class="label">Menu Ottawa Share:</span>
      <span class="value">$${parseFloat(report.menu_ottawa_amount).toFixed(2)}</span>
    </div>
    ` : ''}
    <div class="info-row">
      <span class="label" style="font-size: 1.2em;">Vendor Commission:</span>
      <span class="value amount" style="font-size: 1.3em; color: #059669;">$${parseFloat(report.vendor_commission_amount || 0).toFixed(2)}</span>
    </div>
  </div>

  ${calculationResult.breakdown ? `
  <div class="section">
    <h2>Detailed Calculation</h2>
    <div class="breakdown">
      <pre style="margin: 0; white-space: pre-wrap; font-size: 0.9em;">${JSON.stringify(calculationResult.breakdown, null, 2)}</pre>
    </div>
  </div>
  ` : ''}

  <div class="footer">
    <p>Generated on ${new Date().toLocaleDateString()} at ${new Date().toLocaleTimeString()}</p>
    <p>Menu.ca Commission Management System</p>
    <p style="font-size: 0.8em; color: #9ca3af;">This is an automated system-generated report.</p>
  </div>
</body>
</html>
  `.trim();
}

Deno.serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // Parse request body
    const requestBody: PDFRequest = await req.json();
    const { vendor_id, statement_number } = requestBody;

    if (!vendor_id || !statement_number) {
      return new Response(
        JSON.stringify({ 
          error: 'Missing required fields: vendor_id, statement_number' 
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
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    );

    // Fetch all reports for this statement
    const { data: reports, error: reportsError } = await supabaseClient
      .from('vendor_commission_reports')
      .select(`
        *,
        vendor:vendors(*),
        restaurant:restaurants(*)
      `)
      .eq('vendor_id', vendor_id)
      .eq('statement_number', statement_number);

    if (reportsError || !reports || reports.length === 0) {
      return new Response(
        JSON.stringify({ 
          error: 'No reports found for this vendor and statement number',
          details: reportsError?.message
        }),
        { 
          status: 404,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    const pdfResults = [];

    // Generate HTML for each report and store it
    for (const report of reports) {
      const htmlContent = generatePDFHTML({
        vendor: report.vendor,
        restaurant: report.restaurant,
        report: report
      });

      // Store HTML content in Supabase Storage
      const fileName = `statements/${vendor_id}/${statement_number}/${report.restaurant_uuid}.html`;
      
      const { data: uploadResult, error: uploadError } = await supabaseClient.storage
        .from('commission-reports')
        .upload(fileName, new Blob([htmlContent], { type: 'text/html' }), {
          contentType: 'text/html',
          upsert: true
        });

      if (uploadError) {
        console.error(`Failed to upload HTML for ${report.restaurant_uuid}:`, uploadError);
        continue;
      }

      // Get public URL
      const { data: urlData } = supabaseClient.storage
        .from('commission-reports')
        .getPublicUrl(fileName);

      // Update report with HTML URL (can be converted to PDF later)
      await supabaseClient
        .from('vendor_commission_reports')
        .update({ 
          pdf_file_url: urlData.publicUrl,
          report_status: 'pdf_generated'
        })
        .eq('id', report.id);

      pdfResults.push({
        report_id: report.id,
        restaurant_name: report.restaurant?.name || 'Unknown',
        restaurant_uuid: report.restaurant_uuid,
        html_url: urlData.publicUrl,
        note: 'HTML report generated. Can be converted to PDF using browser print or external service.'
      });
    }

    return new Response(
      JSON.stringify({
        success: true,
        reports_generated: pdfResults.length,
        files: pdfResults,
        message: `Successfully generated ${pdfResults.length} HTML reports (ready for PDF conversion)`
      }),
      { 
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    );

  } catch (error) {
    console.error('Error in generate-commission-pdfs:', error);
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

