# Backend Implementation Guide: Commission Report Generation

**Status:** Ready for Implementation  
**Priority:** Required after migration completion

---

## 🎯 PURPOSE

Complete specification for implementing commission report generation in Supabase backend after all migration phases complete.

**Prerequisites:**
- ✅ Phase 6 migration complete
- ✅ Edge Function `calculate-vendor-commission` deployed
- ✅ Database schema finalized
- ✅ Auth/authz configured

---

## 🔄 WORKFLOW OVERVIEW

```
1. User initiates → 2. Fetch vendor-restaurant assignments
3. Calculate order totals → 4. Get next statement number
5. Preview to client → 6. User reviews/adjusts rates
7. Client calls Edge Function per restaurant → 8. Calculate commissions
9. Save reports → 10. Trigger updates last_commission_rate_used
11. Generate PDFs (MANDATORY) → 12. Update statement number (MANDATORY)
13. Send to vendor (MANDATORY)
```

---

## 💻 BACKEND API ENDPOINTS

### **Quick Reference**
- **Endpoints:** 5 (1 preview, 4 post-generation mandatory)
- **Mandatory Steps:** PDF generation, statement increment, email send
- **Libraries Needed:** jsPDF (or puppeteer), email service (Resend/SendGrid)

---

### **1. Get Commission Report Preview**

**Endpoint:** `GET /api/vendors/:vendorId/commission-report-preview?period_start=YYYY-MM-DD&period_end=YYYY-MM-DD`

**Purpose:** Fetch all data needed to generate commission reports for a vendor.

**Usage Pattern:**
```typescript
async function getCommissionReportPreview(vendorId: string, periodStart: string, periodEnd: string) {
  // 1. Fetch vendor details
  const { data: vendor } = await supabase
    .from('vendors')
    .select('id, business_name, email, contact_first_name, contact_last_name')
    .eq('id', vendorId)
    .eq('is_active', true)
    .single();
  
  // 2. Fetch vendor-restaurant assignments with last used rates
  const { data: assignments } = await supabase
    .from('v_active_vendor_restaurants')
    .select('*')
    .eq('vendor_id', vendorId);
  
  // 3. Calculate order totals per restaurant
  const restaurantsWithTotals = await Promise.all(
    assignments.map(async (assignment) => {
      const { data: orders } = await supabase
        .from('orders')
        .select('total')
        .eq('restaurant_uuid', assignment.restaurant_uuid)
        .eq('status', 'completed')
        .gte('created_at', periodStart)
        .lte('created_at', periodEnd);
      
      const orderTotal = orders?.reduce((sum, order) => sum + order.total, 0) || 0;
      
      return {
        uuid: assignment.restaurant_uuid,
        name: assignment.restaurant_name,
        order_total: orderTotal,
        last_commission_rate_used: assignment.last_commission_rate_used || 10.0,
        last_commission_type_used: assignment.last_commission_type_used || 'percentage'
      };
    })
  );
  
  // 4. Get next statement number
  const { data: statementTracker } = await supabase
    .from('vendor_statement_numbers')
    .select('current_statement_number')
    .eq('vendor_id', vendorId)
    .single();
  
  return {
    vendor: { id: vendor.id, business_name: vendor.business_name, email: vendor.email },
    period: { start: periodStart, end: periodEnd },
    next_statement_number: (statementTracker?.current_statement_number || 0) + 1,
    restaurants: restaurantsWithTotals
  };
}
```

**Response:**
```json
{
  "vendor": { "id": "uuid", "business_name": "Menu Ottawa", "email": "vendor@example.com" },
  "period": { "start": "2025-01-01", "end": "2025-01-31" },
  "next_statement_number": 22,
  "restaurants": [
    {
      "uuid": "uuid-rest-1",
      "name": "River Pizza",
      "order_total": 10000.00,
      "last_commission_rate_used": 10.0,
      "last_commission_type_used": "percentage"
    }
  ]
}
```

---

### **2. Generate Commission Reports**

**Endpoint:** `POST /api/vendors/:vendorId/commission-reports/generate`

**Purpose:** Save all commission reports to database.

**Request Body:**
```typescript
{
  period_start: "2025-01-01",
  period_end: "2025-01-31",
  statement_number: 22,
  restaurants: [
    {
      uuid: string,
      commission_rate: number,
      commission_type: "percentage" | "fixed",
      calculation_result: object  // From Edge Function
    }
  ]
}
```

**Usage Pattern:**
```typescript
async function generateCommissionReports(vendorId: string, requestBody: GenerateReportsRequest) {
  const { period_start, period_end, statement_number, restaurants } = requestBody;
  
  const { data: savedReports, error } = await supabase
    .from('vendor_commission_reports')
    .insert(
      restaurants.map(restaurant => ({
        vendor_id: vendorId,
        restaurant_uuid: restaurant.uuid,
        statement_number: statement_number,
        report_period_start: period_start,
        report_period_end: period_end,
        calculation_input: {
          template_name: restaurant.calculation_result.template_name,
          total: restaurant.calculation_result.use_total,
          restaurant_commission: restaurant.commission_rate,
          commission_type: restaurant.commission_type
        },
        calculation_result: restaurant.calculation_result,
        total_order_amount: restaurant.calculation_result.use_total,
        vendor_commission_amount: restaurant.calculation_result.for_vendor,
        commission_rate_used: restaurant.commission_rate,
        commission_type_used: restaurant.commission_type,
        report_status: 'finalized',
        report_generated_at: new Date().toISOString()
      }))
    )
    .select();
  
  if (error) throw new Error(`Failed to save reports: ${error.message}`);
  
  return savedReports; // Trigger auto-updates last_commission_rate_used
}
```

---

### **3. Generate PDF Reports (MANDATORY)**

**Endpoint:** `POST /api/vendors/:vendorId/commission-reports/:statementNumber/generate-pdfs`

**Purpose:** Generate PDF files for all reports and upload to Supabase Storage.

**Usage Pattern:**
```typescript
import { jsPDF } from 'jspdf';

async function generatePDFReports(vendorId: string, statementNumber: number) {
  const { data: reports } = await supabase
    .from('vendor_commission_reports')
    .select('*, vendor:vendors(*), restaurant:restaurants(*)')
    .eq('vendor_id', vendorId)
    .eq('statement_number', statementNumber);
  
  const pdfUrls = [];
  
  for (const report of reports) {
    // Generate PDF
    const pdfBuffer = await generatePDFContent({
      vendor: report.vendor,
      restaurant: report.restaurant,
      report: {
        statement_number: report.statement_number,
        period_start: report.report_period_start,
        period_end: report.report_period_end,
        order_total: report.total_order_amount,
        commission_rate: report.commission_rate_used,
        vendor_commission: report.vendor_commission_amount
      }
    });
    
    // Upload to Storage
    const fileName = `statements/${vendorId}/${statementNumber}/${report.restaurant_uuid}.pdf`;
    
    const { error: uploadError } = await supabase.storage
      .from('commission-reports')
      .upload(fileName, pdfBuffer, { contentType: 'application/pdf', upsert: true });
    
    if (uploadError) throw new Error(`Failed to upload PDF: ${uploadError.message}`);
    
    // Get public URL
    const { data: urlData } = supabase.storage
      .from('commission-reports')
      .getPublicUrl(fileName);
    
    // Update report with PDF URL
    await supabase
      .from('vendor_commission_reports')
      .update({ pdf_file_url: urlData.publicUrl })
      .eq('id', report.id);
    
    pdfUrls.push({ report_id: report.id, pdf_url: urlData.publicUrl });
  }
  
  return pdfUrls;
}

// PDF generation helper
async function generatePDFContent(data: PDFData): Promise<Buffer> {
  const doc = new jsPDF();
  
  doc.setFontSize(20);
  doc.text('Commission Report', 105, 20, { align: 'center' });
  
  doc.setFontSize(12);
  doc.text(`Statement #${data.report.statement_number}`, 20, 40);
  doc.text(`Period: ${data.report.period_start} to ${data.report.period_end}`, 20, 50);
  
  doc.text('Vendor:', 20, 70);
  doc.text(data.vendor.business_name, 20, 80);
  
  doc.text('Restaurant:', 120, 70);
  doc.text(data.restaurant.name, 120, 80);
  
  doc.text('Commission Breakdown:', 20, 120);
  doc.text(`Order Total: $${data.report.order_total.toFixed(2)}`, 20, 130);
  doc.text(`Vendor Commission: $${data.report.vendor_commission.toFixed(2)}`, 20, 140);
  
  doc.setFontSize(10);
  doc.text(`Generated on ${new Date().toLocaleDateString()}`, 105, 280, { align: 'center' });
  
  return doc.output('arraybuffer');
}
```

---

### **4. Update Statement Number (MANDATORY)**

**Endpoint:** `POST /api/vendors/:vendorId/statement-numbers/increment`

**Purpose:** Increment statement number after all reports generated.

**Usage Pattern:**
```typescript
async function incrementStatementNumber(vendorId: string, statementNumber: number) {
  const { error } = await supabase
    .from('vendor_statement_numbers')
    .update({
      current_statement_number: statementNumber,
      last_statement_generated_at: new Date().toISOString()
    })
    .eq('vendor_id', vendorId);
  
  if (error) throw new Error(`Failed to update statement number: ${error.message}`);
  
  return {
    vendor_id: vendorId,
    current_statement_number: statementNumber,
    next_statement_number: statementNumber + 1
  };
}
```

---

### **5. Send Reports to Vendor (MANDATORY)**

**Endpoint:** `POST /api/vendors/:vendorId/commission-reports/:statementNumber/send`

**Purpose:** Email commission reports to vendor with PDF links.

**Usage Pattern:**
```typescript
async function sendCommissionReports(vendorId: string, statementNumber: number) {
  // Fetch vendor + reports
  const { data: vendor } = await supabase
    .from('vendors')
    .select('business_name, email, contact_first_name')
    .eq('id', vendorId)
    .single();
  
  const { data: reports } = await supabase
    .from('vendor_commission_reports')
    .select('*, restaurant:restaurants(name)')
    .eq('vendor_id', vendorId)
    .eq('statement_number', statementNumber);
  
  const totalCommission = reports.reduce((sum, r) => sum + r.vendor_commission_amount, 0);
  
  // Prepare email
  const emailBody = `
    <h2>Commission Report #${statementNumber}</h2>
    <p>Dear ${vendor.contact_first_name},</p>
    <p>Your commission report is now available.</p>
    
    <h3>Summary</h3>
    <ul>
      <li>Total Restaurants: ${reports.length}</li>
      <li>Total Commission: $${totalCommission.toFixed(2)}</li>
    </ul>
    
    <table border="1">
      <thead>
        <tr><th>Restaurant</th><th>Commission</th><th>PDF</th></tr>
      </thead>
      <tbody>
        ${reports.map(r => `
          <tr>
            <td>${r.restaurant.name}</td>
            <td>$${r.vendor_commission_amount.toFixed(2)}</td>
            <td><a href="${r.pdf_file_url}">Download</a></td>
          </tr>
        `).join('')}
      </tbody>
    </table>
  `;
  
  // Send via Edge Function
  const { error: emailError } = await supabase.functions.invoke('send-email', {
    body: {
      to: vendor.email,
      subject: `Commission Report #${statementNumber} - ${vendor.business_name}`,
      html: emailBody
    }
  });
  
  if (emailError) throw new Error(`Failed to send email: ${emailError.message}`);
  
  // Mark as sent
  await supabase
    .from('vendor_commission_reports')
    .update({ report_status: 'sent', sent_at: new Date().toISOString() })
    .eq('vendor_id', vendorId)
    .eq('statement_number', statementNumber);
  
  return { success: true, vendor_email: vendor.email, total_commission: totalCommission };
}
```

---

## 🔄 COMPLETE WORKFLOW CONTROLLER

**Orchestrates entire process:**

```typescript
async function completeCommissionReportWorkflow(
  vendorId: string,
  periodStart: string,
  periodEnd: string,
  restaurants: RestaurantCommissionData[]
) {
  try {
    // 1. Get next statement number
    const { data: statementTracker } = await supabase
      .from('vendor_statement_numbers')
      .select('current_statement_number')
      .eq('vendor_id', vendorId)
      .single();
    
    const nextStatementNumber = (statementTracker?.current_statement_number || 0) + 1;
    
    // 2. Save reports
    console.log('Generating commission reports...');
    const savedReports = await generateCommissionReports(vendorId, {
      period_start: periodStart,
      period_end: periodEnd,
      statement_number: nextStatementNumber,
      restaurants
    });
    console.log(`✅ Saved ${savedReports.length} reports`);
    
    // 3. Generate PDFs (MANDATORY)
    console.log('Generating PDF files...');
    const pdfUrls = await generatePDFReports(vendorId, nextStatementNumber);
    console.log(`✅ Generated ${pdfUrls.length} PDFs`);
    
    // 4. Update statement number (MANDATORY)
    console.log('Updating statement number...');
    await incrementStatementNumber(vendorId, nextStatementNumber);
    console.log(`✅ Updated to ${nextStatementNumber}`);
    
    // 5. Send to vendor (MANDATORY)
    console.log('Sending reports to vendor...');
    const emailResult = await sendCommissionReports(vendorId, nextStatementNumber);
    console.log(`✅ Sent to ${emailResult.vendor_email}`);
    
    return {
      success: true,
      statement_number: nextStatementNumber,
      reports_count: savedReports.length,
      pdf_urls: pdfUrls,
      email_sent: true
    };
    
  } catch (error) {
    console.error('Error in commission report workflow:', error);
    throw error;
  }
}
```

---

## 🔒 SECURITY

**Authentication Check:**
```typescript
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

**Rate Limiting:**
- Limit report generation to once per day per vendor
- Prevent abuse with rate limiting middleware

---

## ✅ IMPLEMENTATION CHECKLIST

### **Setup**
- [ ] Verify migration phases complete
- [ ] Confirm Edge Function deployed
- [ ] Create Supabase Storage bucket `commission-reports`
- [ ] Configure email service (Resend/SendGrid)

### **API Endpoints**
- [ ] Implement preview endpoint
- [ ] Implement generate reports endpoint
- [ ] Add auth/validation checks

### **PDF Generation (MANDATORY)**
- [ ] Implement PDF generation endpoint
- [ ] Choose PDF library (jsPDF/puppeteer/pdfkit)
- [ ] Design PDF template
- [ ] Set up Storage integration

### **Statement Management (MANDATORY)**
- [ ] Implement statement increment endpoint
- [ ] Add rollback logic if email fails

### **Email Notification (MANDATORY)**
- [ ] Implement send endpoint
- [ ] Create HTML email template
- [ ] Configure email service
- [ ] Add retry logic

### **Orchestration**
- [ ] Implement main workflow controller
- [ ] Add transaction handling
- [ ] Add error recovery
- [ ] Add logging/monitoring

### **Testing**
- [ ] Unit tests for each endpoint
- [ ] Integration tests for complete workflow
- [ ] Test with real V2 data
- [ ] Performance testing

---

## 📊 SUCCESS CRITERIA

Implementation must:
1. ✅ Generate accurate calculations
2. ✅ Save all reports correctly
3. ✅ Trigger updates `last_commission_rate_used`
4. ✅ Generate PDF for every report (MANDATORY)
5. ✅ Update statement number (MANDATORY)
6. ✅ Send email with PDFs (MANDATORY)
7. ✅ Handle errors with rollback
8. ✅ Complete < 2 minutes for 30 restaurants

---

## 📈 MONITORING & LOGGING

**Log Key Events:**
```typescript
await supabase.from('commission_report_logs').insert({
  vendor_id: vendorId,
  statement_number: statementNumber,
  action: 'reports_generated' | 'pdfs_generated' | 'email_sent',
  timestamp: new Date().toISOString()
});
```

---

## 🎉 SUMMARY

**Complete automated system:**
1. **Preview** - Shows last used rates, allows adjustments
2. **Calculate** - Uses Edge Function for accuracy
3. **Save** - Stores reports with audit trail
4. **Generate PDFs** - Professional reports (MANDATORY)
5. **Update State** - Increments statement number (MANDATORY)
6. **Notify** - Emails vendor (MANDATORY)

**Status:** ✅ Ready for implementation after migration completion
