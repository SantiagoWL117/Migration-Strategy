import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from 'jsr:@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

interface SendReportsRequest {
  vendor_id: string;
  statement_number: number;
}

/**
 * Generate email HTML content
 */
function generateEmailHTML(data: {
  vendor: any;
  reports: any[];
  statementNumber: number;
  periodStart: string;
  periodEnd: string;
  totalCommission: number;
  totalOrders: number;
}): string {
  const { vendor, reports, statementNumber, periodStart, periodEnd, totalCommission, totalOrders } = data;

  return `
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <style>
    body {
      font-family: Arial, sans-serif;
      line-height: 1.6;
      color: #333;
      max-width: 800px;
      margin: 0 auto;
      padding: 20px;
      background-color: #f9fafb;
    }
    .container {
      background: white;
      border-radius: 8px;
      padding: 30px;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
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
    .summary {
      background: #eff6ff;
      padding: 20px;
      border-radius: 8px;
      margin: 20px 0;
    }
    .summary-item {
      display: flex;
      justify-content: space-between;
      padding: 8px 0;
      border-bottom: 1px solid #dbeafe;
    }
    .summary-item:last-child {
      border-bottom: none;
      font-size: 1.2em;
      font-weight: bold;
      color: #059669;
    }
    table {
      width: 100%;
      border-collapse: collapse;
      margin: 20px 0;
    }
    th {
      background: #1e40af;
      color: white;
      padding: 12px;
      text-align: left;
      font-weight: bold;
    }
    td {
      padding: 12px;
      border-bottom: 1px solid #e5e7eb;
    }
    tr:hover {
      background: #f9fafb;
    }
    .amount {
      font-weight: bold;
      color: #059669;
    }
    .button {
      display: inline-block;
      padding: 8px 16px;
      background: #2563eb;
      color: white;
      text-decoration: none;
      border-radius: 4px;
      font-size: 0.9em;
    }
    .button:hover {
      background: #1e40af;
    }
    .footer {
      margin-top: 40px;
      text-align: center;
      color: #6b7280;
      font-size: 0.9em;
      border-top: 2px solid #e5e7eb;
      padding-top: 20px;
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>Commission Report #${statementNumber}</h1>
      <p>Period: ${new Date(periodStart).toLocaleDateString()} - ${new Date(periodEnd).toLocaleDateString()}</p>
    </div>

    <p>Dear ${vendor.contact_first_name || 'Vendor'},</p>
    
    <p>Your commission report for the period <strong>${new Date(periodStart).toLocaleDateString()}</strong> to <strong>${new Date(periodEnd).toLocaleDateString()}</strong> is now available.</p>
    
    <div class="summary">
      <h2 style="margin-top: 0; color: #1e40af;">Summary</h2>
      <div class="summary-item">
        <span>Total Restaurants:</span>
        <span>${reports.length}</span>
      </div>
      <div class="summary-item">
        <span>Total Orders:</span>
        <span class="amount">$${totalOrders.toFixed(2)}</span>
      </div>
      <div class="summary-item">
        <span>Total Commission:</span>
        <span class="amount">$${totalCommission.toFixed(2)}</span>
      </div>
    </div>
    
    <h2 style="color: #1e40af;">Individual Reports</h2>
    <table>
      <thead>
        <tr>
          <th>Restaurant</th>
          <th>Order Total</th>
          <th>Commission</th>
          <th>Report</th>
        </tr>
      </thead>
      <tbody>
        ${reports.map(r => `
          <tr>
            <td>${r.restaurant?.name || 'N/A'}</td>
            <td class="amount">$${parseFloat(r.total_order_amount || 0).toFixed(2)}</td>
            <td class="amount">$${parseFloat(r.vendor_commission_amount || 0).toFixed(2)}</td>
            <td>
              ${r.pdf_file_url ? `<a href="${r.pdf_file_url}" class="button">View Report</a>` : 'Pending'}
            </td>
          </tr>
        `).join('')}
      </tbody>
    </table>
    
    <div class="footer">
      <p><strong>Need help?</strong> Contact us at support@menu.ca</p>
      <p>Best regards,<br/>Menu.ca Team</p>
      <p style="font-size: 0.8em; color: #9ca3af; margin-top: 20px;">
        This is an automated email. Please do not reply directly to this message.
      </p>
    </div>
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
    const requestBody: SendReportsRequest = await req.json();
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

    // Fetch vendor details
    const { data: vendor, error: vendorError } = await supabaseClient
      .from('vendors')
      .select('business_name, email, contact_first_name, contact_last_name')
      .eq('id', vendor_id)
      .single();

    if (vendorError || !vendor) {
      return new Response(
        JSON.stringify({ 
          error: 'Vendor not found',
          details: vendorError?.message
        }),
        { 
          status: 404,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    // Fetch all reports with restaurant data
    const { data: reports, error: reportsError } = await supabaseClient
      .from('vendor_commission_reports')
      .select(`
        *,
        restaurant:restaurants(name, address, city, province)
      `)
      .eq('vendor_id', vendor_id)
      .eq('statement_number', statement_number);

    if (reportsError || !reports || reports.length === 0) {
      return new Response(
        JSON.stringify({ 
          error: 'No reports found',
          details: reportsError?.message
        }),
        { 
          status: 404,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    // Calculate totals
    const totalCommission = reports.reduce(
      (sum, r) => sum + parseFloat(r.vendor_commission_amount || 0),
      0
    );
    const totalOrders = reports.reduce(
      (sum, r) => sum + parseFloat(r.total_order_amount || 0),
      0
    );

    // Prepare email content
    const emailSubject = `Commission Report #${statement_number} - ${vendor.business_name || 'Your Business'}`;
    const emailHTML = generateEmailHTML({
      vendor,
      reports,
      statementNumber: statement_number,
      periodStart: reports[0].report_period_start,
      periodEnd: reports[0].report_period_end,
      totalCommission,
      totalOrders
    });

    // TODO: Integrate with actual email service (Resend, SendGrid, etc.)
    // For now, we'll just log the email content and mark reports as sent
    console.log('Email would be sent to:', vendor.email);
    console.log('Subject:', emailSubject);
    console.log('HTML content generated:', emailHTML.substring(0, 200) + '...');

    // Note: In production, you would call an email service here:
    // const emailResult = await fetch('https://api.resend.com/emails', {
    //   method: 'POST',
    //   headers: {
    //     'Authorization': `Bearer ${Deno.env.get('RESEND_API_KEY')}`,
    //     'Content-Type': 'application/json'
    //   },
    //   body: JSON.stringify({
    //     from: 'reports@menu.ca',
    //     to: vendor.email,
    //     subject: emailSubject,
    //     html: emailHTML
    //   })
    // });

    // Update all reports as sent
    const { error: updateError } = await supabaseClient
      .from('vendor_commission_reports')
      .update({
        report_status: 'sent',
        sent_at: new Date().toISOString()
      })
      .eq('vendor_id', vendor_id)
      .eq('statement_number', statement_number);

    if (updateError) {
      throw new Error(`Failed to update report status: ${updateError.message}`);
    }

    // Update statement number
    const { error: statementUpdateError } = await supabaseClient
      .from('vendor_statement_numbers')
      .update({
        current_statement_number: statement_number,
        last_statement_generated_at: new Date().toISOString()
      })
      .eq('vendor_id', vendor_id);

    if (statementUpdateError) {
      console.error('Failed to update statement number:', statementUpdateError);
    }

    return new Response(
      JSON.stringify({
        success: true,
        vendor_email: vendor.email,
        reports_count: reports.length,
        total_commission: totalCommission,
        total_orders: totalOrders,
        statement_number: statement_number,
        message: `Commission reports marked as sent. Email would be sent to ${vendor.email}`,
        note: 'Email service integration pending. Connect Resend, SendGrid, or similar service.'
      }),
      { 
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    );

  } catch (error) {
    console.error('Error in send-commission-reports:', error);
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

