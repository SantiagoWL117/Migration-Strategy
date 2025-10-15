# Backend Implementation Guide: Commission Report Generation

**Document Version:** 1.0  
**Last Updated:** October 15, 2025  
**Status:** Ready for Implementation  
**Priority:** Required after migration completion

---

## 🎯 Purpose

This document provides the complete specification for implementing commission report generation in the Supabase backend. This will be implemented **after all migration phases are complete**.

---

## 📋 Prerequisites

Before implementing this backend logic, ensure:

- ✅ Phase 6 migration is complete (all vendor data in V3)
- ✅ Supabase Edge Function `calculate-vendor-commission` is deployed
- ✅ Database schema is finalized with all tables and triggers
- ✅ Authentication and authorization are configured

---

## 🔄 Complete Workflow Overview

```
┌──────────────────────────────────────────────────────────────┐
│                    COMMISSION REPORT WORKFLOW                │
├──────────────────────────────────────────────────────────────┤
│ 1. User initiates report generation (frontend)              │
│ 2. Backend fetches vendor-restaurant assignments            │
│ 3. Backend calculates order totals per restaurant           │
│ 4. Backend gets next statement number                       │
│ 5. Backend sends preview data to client                     │
│ 6. Client displays preview form with last used rates        │
│ 7. User reviews/adjusts rates and confirms                  │
│ 8. Client calls Edge Function for each restaurant           │
│ 9. Edge Function calculates commission amounts              │
│ 10. Client saves all reports to database                    │
│ 11. Database trigger updates last_commission_rate_used      │
│ 12. Backend generates PDF reports (MANDATORY)               │
│ 13. Backend updates statement number (MANDATORY)            │
│ 14. Backend sends reports to vendor (MANDATORY)             │
└──────────────────────────────────────────────────────────────┘
```

---

## 📡 Required Backend API Endpoints

### **1. Get Commission Report Preview**

Fetch all data needed to generate commission reports for a vendor.

#### **Endpoint**
```
GET /api/vendors/:vendorId/commission-report-preview
```

#### **Query Parameters**
```typescript
{
  period_start: string;  // ISO date: "2025-01-01"
  period_end: string;    // ISO date: "2025-01-31"
}
```

#### **Implementation**

```typescript
async function getCommissionReportPreview(
  vendorId: string,
  periodStart: string,
  periodEnd: string
) {
  // Step 1: Fetch vendor details
  const { data: vendor } = await supabase
    .from('vendors')
    .select('id, business_name, email, contact_first_name, contact_last_name')
    .eq('id', vendorId)
    .eq('is_active', true)
    .single();
  
  if (!vendor) {
    throw new Error('Vendor not found or inactive');
  }
  
  // Step 2: Fetch vendor-restaurant assignments with last used rates
  const { data: assignments } = await supabase
    .from('v_active_vendor_restaurants')
    .select('*')
    .eq('vendor_id', vendorId);
  
  // Step 3: Calculate order totals for each restaurant
  const restaurantsWithTotals = await Promise.all(
    assignments.map(async (assignment) => {
      // Get completed orders for this restaurant in the period
      const { data: orders } = await supabase
        .from('orders')
        .select('total')
        .eq('restaurant_uuid', assignment.restaurant_uuid)
        .eq('status', 'completed')
        .gte('created_at', periodStart)
        .lte('created_at', periodEnd);
      
      const orderTotal = orders?.reduce((sum, order) => sum + order.total, 0) || 0;
      
      // Get restaurant address
      const { data: restaurant } = await supabase
        .from('restaurants')
        .select('address, city, province, postal_code')
        .eq('uuid', assignment.restaurant_uuid)
        .single();
      
      const fullAddress = [
        restaurant?.address,
        restaurant?.city,
        restaurant?.province,
        restaurant?.postal_code
      ].filter(Boolean).join(', ');
      
      return {
        uuid: assignment.restaurant_uuid,
        name: assignment.restaurant_name,
        address: fullAddress,
        order_total: orderTotal,
        commission_template: assignment.commission_template,
        last_commission_rate_used: assignment.last_commission_rate_used || 10.0,
        last_commission_type_used: assignment.last_commission_type_used || 'percentage'
      };
    })
  );
  
  // Step 4: Get next statement number
  const { data: statementTracker } = await supabase
    .from('vendor_statement_numbers')
    .select('current_statement_number')
    .eq('vendor_id', vendorId)
    .single();
  
  const nextStatementNumber = (statementTracker?.current_statement_number || 0) + 1;
  
  // Step 5: Return preview data
  return {
    vendor: {
      id: vendor.id,
      business_name: vendor.business_name,
      email: vendor.email,
      contact_name: `${vendor.contact_first_name} ${vendor.contact_last_name}`
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
}
```

#### **Response Format**

```json
{
  "vendor": {
    "id": "uuid-vendor-1",
    "business_name": "Menu Ottawa",
    "email": "vendor@example.com",
    "contact_name": "John Smith"
  },
  "period": {
    "start": "2025-01-01",
    "end": "2025-01-31"
  },
  "next_statement_number": 22,
  "restaurants": [
    {
      "uuid": "uuid-rest-1",
      "name": "River Pizza",
      "address": "123 Main St, Ottawa, ON, K1A 0A1",
      "order_total": 10000.00,
      "commission_template": "percent_commission",
      "last_commission_rate_used": 10.0,
      "last_commission_type_used": "percentage"
    },
    {
      "uuid": "uuid-rest-2",
      "name": "Cosenza",
      "address": "456 Bank St, Ottawa, ON, K1B 1B1",
      "order_total": 15000.00,
      "commission_template": "percent_commission",
      "last_commission_rate_used": 12.0,
      "last_commission_type_used": "percentage"
    }
  ],
  "summary": {
    "total_restaurants": 2,
    "total_orders": 25000.00
  }
}
```

---

### **2. Generate Commission Reports**

Process and save all commission reports for a vendor.

#### **Endpoint**
```
POST /api/vendors/:vendorId/commission-reports/generate
```

#### **Request Body**

```typescript
{
  period_start: string;      // "2025-01-01"
  period_end: string;        // "2025-01-31"
  statement_number: number;  // 22
  restaurants: [
    {
      uuid: string;
      commission_rate: number;      // User-provided or last used
      commission_type: string;      // "percentage" or "fixed"
      calculation_result: object;   // Result from Edge Function
    }
  ]
}
```

#### **Implementation**

```typescript
async function generateCommissionReports(
  vendorId: string,
  requestBody: GenerateReportsRequest
) {
  const { period_start, period_end, statement_number, restaurants } = requestBody;
  
  // Start transaction
  const { data: savedReports, error } = await supabase
    .from('vendor_commission_reports')
    .insert(
      restaurants.map(restaurant => ({
        vendor_id: vendorId,
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
      }))
    )
    .select();
  
  if (error) {
    throw new Error(`Failed to save reports: ${error.message}`);
  }
  
  // Trigger automatically updates last_commission_rate_used
  
  return savedReports;
}
```

---

### **3. Generate PDF Reports (MANDATORY)**

Generate PDF files for all commission reports.

#### **Endpoint**
```
POST /api/vendors/:vendorId/commission-reports/:statementNumber/generate-pdfs
```

#### **Implementation**

```typescript
import { jsPDF } from 'jspdf';
// OR use your preferred PDF library (puppeteer, pdfkit, etc.)

async function generatePDFReports(
  vendorId: string,
  statementNumber: number
) {
  // Fetch all reports for this statement
  const { data: reports } = await supabase
    .from('vendor_commission_reports')
    .select(`
      *,
      vendor:vendors(*),
      restaurant:restaurants(*)
    `)
    .eq('vendor_id', vendorId)
    .eq('statement_number', statementNumber);
  
  const pdfUrls = [];
  
  for (const report of reports) {
    // Generate PDF content
    const pdfBuffer = await generatePDFContent({
      vendor: report.vendor,
      restaurant: report.restaurant,
      report: {
        statement_number: report.statement_number,
        period_start: report.report_period_start,
        period_end: report.report_period_end,
        order_total: report.total_order_amount,
        commission_rate: report.commission_rate_used,
        commission_type: report.commission_type_used,
        vendor_commission: report.vendor_commission_amount,
        platform_fee: report.platform_fee_amount,
        calculation_breakdown: report.calculation_result
      }
    });
    
    // Upload to Supabase Storage
    const fileName = `statements/${vendorId}/${statementNumber}/${report.restaurant_uuid}.pdf`;
    
    const { data: uploadResult, error: uploadError } = await supabase.storage
      .from('commission-reports')
      .upload(fileName, pdfBuffer, {
        contentType: 'application/pdf',
        upsert: true
      });
    
    if (uploadError) {
      throw new Error(`Failed to upload PDF: ${uploadError.message}`);
    }
    
    // Get public URL
    const { data: urlData } = supabase.storage
      .from('commission-reports')
      .getPublicUrl(fileName);
    
    // Update report with PDF URL
    await supabase
      .from('vendor_commission_reports')
      .update({ pdf_file_url: urlData.publicUrl })
      .eq('id', report.id);
    
    pdfUrls.push({
      report_id: report.id,
      restaurant_name: report.restaurant.name,
      pdf_url: urlData.publicUrl
    });
  }
  
  return pdfUrls;
}

// PDF content generation
async function generatePDFContent(data: PDFData): Promise<Buffer> {
  const doc = new jsPDF();
  
  // Header
  doc.setFontSize(20);
  doc.text('Commission Report', 105, 20, { align: 'center' });
  
  // Statement info
  doc.setFontSize(12);
  doc.text(`Statement #${data.report.statement_number}`, 20, 40);
  doc.text(`Period: ${data.report.period_start} to ${data.report.period_end}`, 20, 50);
  
  // Vendor info
  doc.text('Vendor:', 20, 70);
  doc.text(data.vendor.business_name, 20, 80);
  doc.text(data.vendor.email, 20, 90);
  
  // Restaurant info
  doc.text('Restaurant:', 120, 70);
  doc.text(data.restaurant.name, 120, 80);
  doc.text(data.restaurant.address, 120, 90);
  
  // Commission breakdown
  doc.text('Commission Breakdown:', 20, 120);
  doc.text(`Order Total: $${data.report.order_total.toFixed(2)}`, 20, 130);
  doc.text(`Commission Rate: ${data.report.commission_rate}${data.report.commission_type === 'percentage' ? '%' : ' (fixed)'}`, 20, 140);
  doc.text(`Platform Fee: $${data.report.platform_fee.toFixed(2)}`, 20, 150);
  doc.text(`Vendor Commission: $${data.report.vendor_commission.toFixed(2)}`, 20, 160);
  
  // Footer
  doc.setFontSize(10);
  doc.text(`Generated on ${new Date().toLocaleDateString()}`, 105, 280, { align: 'center' });
  
  return doc.output('arraybuffer');
}
```

---

### **4. Update Statement Number (MANDATORY)**

Increment the statement number after all reports are generated.

#### **Endpoint**
```
POST /api/vendors/:vendorId/statement-numbers/increment
```

#### **Implementation**

```typescript
async function incrementStatementNumber(
  vendorId: string,
  statementNumber: number
) {
  const { data, error } = await supabase
    .from('vendor_statement_numbers')
    .update({
      current_statement_number: statementNumber,
      last_statement_generated_at: new Date().toISOString()
    })
    .eq('vendor_id', vendorId);
  
  if (error) {
    throw new Error(`Failed to update statement number: ${error.message}`);
  }
  
  return {
    vendor_id: vendorId,
    current_statement_number: statementNumber,
    next_statement_number: statementNumber + 1
  };
}
```

---

### **5. Send Reports to Vendor (MANDATORY)**

Email the commission reports to the vendor.

#### **Endpoint**
```
POST /api/vendors/:vendorId/commission-reports/:statementNumber/send
```

#### **Implementation**

```typescript
async function sendCommissionReports(
  vendorId: string,
  statementNumber: number
) {
  // Fetch vendor details
  const { data: vendor } = await supabase
    .from('vendors')
    .select('business_name, email, contact_first_name')
    .eq('id', vendorId)
    .single();
  
  // Fetch all reports with PDFs
  const { data: reports } = await supabase
    .from('vendor_commission_reports')
    .select(`
      *,
      restaurant:restaurants(name)
    `)
    .eq('vendor_id', vendorId)
    .eq('statement_number', statementNumber);
  
  if (!reports || reports.length === 0) {
    throw new Error('No reports found');
  }
  
  // Calculate totals
  const totalCommission = reports.reduce(
    (sum, r) => sum + r.vendor_commission_amount,
    0
  );
  const totalOrders = reports.reduce(
    (sum, r) => sum + r.total_order_amount,
    0
  );
  
  // Prepare email
  const emailSubject = `Commission Report #${statementNumber} - ${vendor.business_name}`;
  
  const emailBody = `
    <html>
      <body>
        <h2>Commission Report #${statementNumber}</h2>
        
        <p>Dear ${vendor.contact_first_name},</p>
        
        <p>Your commission report for the period ${reports[0].report_period_start} to ${reports[0].report_period_end} is now available.</p>
        
        <h3>Summary</h3>
        <ul>
          <li>Total Restaurants: ${reports.length}</li>
          <li>Total Orders: $${totalOrders.toFixed(2)}</li>
          <li>Total Commission: $${totalCommission.toFixed(2)}</li>
        </ul>
        
        <h3>Individual Reports</h3>
        <table border="1" cellpadding="5" style="border-collapse: collapse;">
          <thead>
            <tr>
              <th>Restaurant</th>
              <th>Order Total</th>
              <th>Commission</th>
              <th>PDF Report</th>
            </tr>
          </thead>
          <tbody>
            ${reports.map(r => `
              <tr>
                <td>${r.restaurant.name}</td>
                <td>$${r.total_order_amount.toFixed(2)}</td>
                <td>$${r.vendor_commission_amount.toFixed(2)}</td>
                <td><a href="${r.pdf_file_url}">Download</a></td>
              </tr>
            `).join('')}
          </tbody>
        </table>
        
        <p>Best regards,<br/>Menu.ca Team</p>
      </body>
    </html>
  `;
  
  // Send email using Supabase Edge Function or external service
  const { data: emailResult, error: emailError } = await supabase.functions.invoke('send-email', {
    body: {
      to: vendor.email,
      subject: emailSubject,
      html: emailBody
    }
  });
  
  if (emailError) {
    throw new Error(`Failed to send email: ${emailError.message}`);
  }
  
  // Update all reports as sent
  await supabase
    .from('vendor_commission_reports')
    .update({
      report_status: 'sent',
      sent_at: new Date().toISOString()
    })
    .eq('vendor_id', vendorId)
    .eq('statement_number', statementNumber);
  
  return {
    success: true,
    vendor_email: vendor.email,
    reports_count: reports.length,
    total_commission: totalCommission
  };
}
```

---

## 🔄 Complete Backend Workflow

### **Main Controller Function**

This orchestrates the entire report generation process.

```typescript
async function completeCommissionReportWorkflow(
  vendorId: string,
  periodStart: string,
  periodEnd: string,
  restaurants: RestaurantCommissionData[]
) {
  try {
    // Step 1: Get next statement number
    const { data: statementTracker } = await supabase
      .from('vendor_statement_numbers')
      .select('current_statement_number')
      .eq('vendor_id', vendorId)
      .single();
    
    const nextStatementNumber = (statementTracker?.current_statement_number || 0) + 1;
    
    // Step 2: Generate and save all reports
    console.log('Generating commission reports...');
    const savedReports = await generateCommissionReports(vendorId, {
      period_start: periodStart,
      period_end: periodEnd,
      statement_number: nextStatementNumber,
      restaurants: restaurants
    });
    
    console.log(`✅ Saved ${savedReports.length} reports`);
    
    // Step 3: Generate PDF files (MANDATORY)
    console.log('Generating PDF files...');
    const pdfUrls = await generatePDFReports(vendorId, nextStatementNumber);
    console.log(`✅ Generated ${pdfUrls.length} PDF files`);
    
    // Step 4: Update statement number (MANDATORY)
    console.log('Updating statement number...');
    await incrementStatementNumber(vendorId, nextStatementNumber);
    console.log(`✅ Statement number updated to ${nextStatementNumber}`);
    
    // Step 5: Send reports to vendor (MANDATORY)
    console.log('Sending reports to vendor...');
    const emailResult = await sendCommissionReports(vendorId, nextStatementNumber);
    console.log(`✅ Reports sent to ${emailResult.vendor_email}`);
    
    return {
      success: true,
      statement_number: nextStatementNumber,
      reports_count: savedReports.length,
      pdf_urls: pdfUrls,
      email_sent: true,
      total_commission: savedReports.reduce((sum, r) => sum + r.vendor_commission_amount, 0)
    };
    
  } catch (error) {
    console.error('Error in commission report workflow:', error);
    throw error;
  }
}
```

---

## 📋 Implementation Checklist

### Phase 1: Setup ✅
- [ ] Verify all migration phases complete
- [ ] Confirm Edge Function deployed
- [ ] Set up Supabase Storage bucket `commission-reports`
- [ ] Configure email service (Resend, SendGrid, or Supabase Email)

### Phase 2: API Endpoints
- [ ] Implement `GET /api/vendors/:vendorId/commission-report-preview`
- [ ] Implement `POST /api/vendors/:vendorId/commission-reports/generate`
- [ ] Add authentication/authorization checks
- [ ] Add request validation

### Phase 3: PDF Generation (MANDATORY)
- [ ] Implement `POST /api/vendors/:vendorId/commission-reports/:statementNumber/generate-pdfs`
- [ ] Choose PDF library (jsPDF, puppeteer, pdfkit)
- [ ] Design PDF template
- [ ] Test PDF generation with sample data
- [ ] Set up Supabase Storage integration

### Phase 4: Statement Management (MANDATORY)
- [ ] Implement `POST /api/vendors/:vendorId/statement-numbers/increment`
- [ ] Add rollback logic if email fails

### Phase 5: Email Notification (MANDATORY)
- [ ] Implement `POST /api/vendors/:vendorId/commission-reports/:statementNumber/send`
- [ ] Create email template (HTML)
- [ ] Configure email service
- [ ] Test email sending with sample data
- [ ] Add email retry logic

### Phase 6: Orchestration
- [ ] Implement main workflow controller
- [ ] Add transaction handling
- [ ] Add error recovery
- [ ] Add logging/monitoring

### Phase 7: Testing
- [ ] Unit tests for each endpoint
- [ ] Integration tests for complete workflow
- [ ] Test with real V2 data
- [ ] Performance testing with multiple restaurants

### Phase 8: Documentation
- [ ] API documentation (OpenAPI/Swagger)
- [ ] Frontend integration guide
- [ ] Error handling guide
- [ ] Deployment guide

---

## 🔒 Security Considerations

### Authentication
```typescript
// Verify user has permission to generate reports for this vendor
async function checkVendorAccess(userId: string, vendorId: string) {
  const { data: vendor } = await supabase
    .from('vendors')
    .select('auth_user_id')
    .eq('id', vendorId)
    .single();
  
  if (vendor.auth_user_id !== userId) {
    throw new Error('Unauthorized access to vendor reports');
  }
}
```

### Rate Limiting
```typescript
// Prevent abuse - limit report generation to once per day per vendor
const rateLimitKey = `commission_reports:${vendorId}:${new Date().toDateString()}`;
// Implement rate limiting logic
```

---

## 🎯 Success Criteria

A successful implementation must:

1. ✅ Generate accurate commission calculations
2. ✅ Save all reports to database with correct data
3. ✅ Trigger automatically updates `last_commission_rate_used`
4. ✅ Generate PDF for every report (MANDATORY)
5. ✅ Update statement number correctly (MANDATORY)
6. ✅ Send email to vendor with all PDFs (MANDATORY)
7. ✅ Handle errors gracefully with rollback
8. ✅ Complete within reasonable time (<2 minutes for 30 restaurants)

---

## 📊 Monitoring & Logging

Implement logging for:

```typescript
// Log key events
await supabase.from('commission_report_logs').insert({
  vendor_id: vendorId,
  statement_number: statementNumber,
  action: 'reports_generated',
  reports_count: savedReports.length,
  total_commission: totalCommission,
  timestamp: new Date().toISOString()
});

await supabase.from('commission_report_logs').insert({
  vendor_id: vendorId,
  statement_number: statementNumber,
  action: 'pdfs_generated',
  pdf_count: pdfUrls.length,
  timestamp: new Date().toISOString()
});

await supabase.from('commission_report_logs').insert({
  vendor_id: vendorId,
  statement_number: statementNumber,
  action: 'email_sent',
  recipient: vendor.email,
  timestamp: new Date().toISOString()
});
```

---

## 🎉 Summary

This backend implementation will provide a complete, automated commission report generation system:

1. **Preview** - Shows last used rates, allows adjustments
2. **Calculate** - Uses Edge Function for accurate calculations
3. **Save** - Stores reports with audit trail
4. **Generate PDFs** - Creates professional reports (MANDATORY)
5. **Update State** - Increments statement number (MANDATORY)
6. **Notify** - Sends email to vendor (MANDATORY)

**Status:** Ready for implementation after migration completion.

