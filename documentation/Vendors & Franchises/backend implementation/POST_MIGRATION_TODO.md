# Post-Migration TODO: Backend Implementation

**Document Version:** 1.0  
**Last Updated:** October 15, 2025  
**Status:** Pending Migration Completion

---

## 🎯 Overview

After all migration phases are complete, the following backend logic must be implemented in Supabase for commission report generation.

---

## ✅ Prerequisites (Must Be Complete First)

- [x] Phase 1: Data Analysis - ✅ Complete
- [x] Phase 2: CSV Extraction - ✅ Complete
- [x] Phase 3: Edge Function Implementation - ✅ Complete
- [x] Phase 4: Staging Schema Creation - ✅ Complete
- [x] Phase 5: V3 Schema Creation - ✅ Complete
- [x] Phase 6: Data Migration - ✅ Complete
- [ ] Phase 7: Validation & Verification - **In Progress**
- [ ] Phase 8: Testing - **Pending**
- [ ] Phase 9: Production Deployment - **Pending**

---

## 📋 Backend Implementation Tasks

### **Task 1: API Endpoints**

Implement the following REST API endpoints in Supabase:

| Endpoint | Method | Purpose | Priority |
|----------|--------|---------|----------|
| `/api/vendors/:vendorId/commission-report-preview` | GET | Fetch preview data with last used rates | **HIGH** |
| `/api/vendors/:vendorId/commission-reports/generate` | POST | Save all reports to database | **HIGH** |
| `/api/vendors/:vendorId/commission-reports/:statementNumber/generate-pdfs` | POST | Generate PDF files (MANDATORY) | **CRITICAL** |
| `/api/vendors/:vendorId/statement-numbers/increment` | POST | Update statement number (MANDATORY) | **CRITICAL** |
| `/api/vendors/:vendorId/commission-reports/:statementNumber/send` | POST | Email reports to vendor (MANDATORY) | **CRITICAL** |

**Reference:** See `BACKEND_IMPLEMENTATION_GUIDE.md` for complete specifications.

---

### **Task 2: PDF Generation (MANDATORY)**

#### Requirements:
- Generate professional PDF reports for each restaurant
- Include vendor details, restaurant details, commission breakdown
- Upload to Supabase Storage bucket `commission-reports`
- Update `vendor_commission_reports.pdf_file_url` with storage URL

#### Implementation Options:
1. **jsPDF** - Client-side PDF generation (lightweight)
2. **Puppeteer** - Server-side HTML to PDF (flexible)
3. **PDFKit** - Node.js PDF generation (full control)

#### PDF Template Structure:
```
┌─────────────────────────────────────────┐
│         COMMISSION REPORT               │
│         Statement #22                   │
├─────────────────────────────────────────┤
│ Period: Jan 1 - Jan 31, 2025           │
│                                         │
│ VENDOR:                                 │
│ Menu Ottawa                             │
│ vendor@example.com                      │
│                                         │
│ RESTAURANT:                             │
│ River Pizza                             │
│ 123 Main St, Ottawa, ON                │
│                                         │
│ COMMISSION BREAKDOWN:                   │
│ Order Total:        $10,000.00          │
│ Commission Rate:    10%                 │
│ Total Commission:   $1,000.00           │
│ Platform Fee:       $80.00              │
│ Vendor Commission:  $460.00             │
│                                         │
│ Generated: 2025-01-31                   │
└─────────────────────────────────────────┘
```

---

### **Task 3: Email Notification (MANDATORY)**

#### Requirements:
- Send HTML email to vendor after report generation
- Include summary (total restaurants, total commission)
- Include table with individual restaurant breakdown
- Attach or link to all PDF reports
- Update `vendor_commission_reports.report_status = 'sent'`
- Update `vendor_commission_reports.sent_at`

#### Email Service Options:
1. **Supabase Edge Function** - Built-in email sending
2. **Resend** - Modern email API (recommended)
3. **SendGrid** - Enterprise email service
4. **Amazon SES** - AWS email service

#### Email Template:
```html
Subject: Commission Report #22 - Menu Ottawa

Dear [Vendor Name],

Your commission report for January 2025 is now available.

SUMMARY:
- Total Restaurants: 11
- Total Orders: $125,450.00
- Total Commission: $5,234.50

Individual Reports:
┌────────────────────┬──────────────┬──────────────┬──────────┐
│ Restaurant         │ Order Total  │ Commission   │ PDF      │
├────────────────────┼──────────────┼──────────────┼──────────┤
│ River Pizza        │ $10,000.00   │ $460.00      │ Download │
│ Cosenza            │ $15,000.00   │ $690.00      │ Download │
│ ...                │ ...          │ ...          │ ...      │
└────────────────────┴──────────────┴──────────────┴──────────┘

Best regards,
Menu.ca Team
```

---

### **Task 4: Orchestration Controller**

Create a main controller that orchestrates the entire workflow:

```typescript
async function completeCommissionReportWorkflow(
  vendorId: string,
  periodStart: string,
  periodEnd: string,
  restaurants: RestaurantCommissionData[]
) {
  // 1. Save reports to database
  // 2. Generate PDF files (MANDATORY)
  // 3. Update statement number (MANDATORY)
  // 4. Send email to vendor (MANDATORY)
  // 5. Handle errors and rollback if necessary
}
```

**This controller ensures all mandatory steps are executed.**

---

### **Task 5: Error Handling & Rollback**

Implement proper error handling:

```typescript
try {
  // Step 1: Save reports
  const savedReports = await generateCommissionReports(...);
  
  try {
    // Step 2: Generate PDFs (MANDATORY)
    const pdfUrls = await generatePDFReports(...);
    
    try {
      // Step 3: Update statement number (MANDATORY)
      await incrementStatementNumber(...);
      
      try {
        // Step 4: Send email (MANDATORY)
        await sendCommissionReports(...);
        
      } catch (emailError) {
        // Email failed - log error but don't rollback
        // Reports are still valid, can resend later
        console.error('Email failed:', emailError);
      }
      
    } catch (statementError) {
      // Statement number update failed - critical
      // Should rollback PDFs and reports
      throw statementError;
    }
    
  } catch (pdfError) {
    // PDF generation failed - critical
    // Should rollback reports
    throw pdfError;
  }
  
} catch (saveError) {
  // Report save failed - nothing to rollback
  throw saveError;
}
```

---

## 📚 Documentation References

| Document | Purpose |
|----------|---------|
| `BACKEND_IMPLEMENTATION_GUIDE.md` | Complete implementation specifications |
| `COMMISSION_RATE_WORKFLOW.md` | Step-by-step workflow explanation |
| `COMMISSION_RATE_FINAL_IMPLEMENTATION.md` | Architecture overview |
| `supabase/functions/calculate-vendor-commission/README.md` | Edge Function API documentation |

---

## 🔧 Setup Requirements

### Supabase Configuration

1. **Storage Bucket**
   ```sql
   -- Create storage bucket for PDFs
   INSERT INTO storage.buckets (id, name, public)
   VALUES ('commission-reports', 'commission-reports', true);
   
   -- Set up RLS policies
   CREATE POLICY "Vendors can view own reports"
   ON storage.objects FOR SELECT
   USING (bucket_id = 'commission-reports' AND auth.uid() IN (
     SELECT auth_user_id FROM menuca_v3.vendors
   ));
   ```

2. **Email Service**
   - Configure email service credentials
   - Set up email templates
   - Test email delivery

3. **Environment Variables**
   ```env
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key
   SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
   EMAIL_SERVICE_API_KEY=your-email-api-key
   ```

---

## 🎯 Testing Checklist

### Unit Tests
- [ ] Test preview data endpoint with mock data
- [ ] Test report generation with sample calculations
- [ ] Test PDF generation with various report sizes
- [ ] Test statement number increment
- [ ] Test email sending

### Integration Tests
- [ ] Test complete workflow with 1 restaurant
- [ ] Test complete workflow with 11 restaurants (Menu Ottawa)
- [ ] Test complete workflow with 12 restaurants (Darrell Corcoran)
- [ ] Test error handling and rollback
- [ ] Test concurrent report generation

### Performance Tests
- [ ] Measure time to generate 30 reports
- [ ] Measure PDF generation time
- [ ] Measure email sending time
- [ ] Target: Complete workflow in < 2 minutes

---

## 📊 Success Metrics

The backend implementation is considered complete when:

1. ✅ All API endpoints are implemented and tested
2. ✅ PDF generation works for all report types
3. ✅ Statement numbers increment correctly
4. ✅ Emails are sent successfully with PDFs
5. ✅ Error handling and rollback work correctly
6. ✅ Performance meets target (<2 min for 30 restaurants)
7. ✅ All tests pass
8. ✅ Documentation is complete

---

## 🚀 Deployment Plan

### Stage 1: Development Environment
- Implement all endpoints
- Test with sample data
- Verify PDF generation
- Test email sending

### Stage 2: Staging Environment
- Deploy to staging
- Test with real V2 data
- Validate calculations match V2 results
- Perform load testing

### Stage 3: Production Deployment
- Deploy to production
- Generate first real reports
- Monitor logs and errors
- Gather vendor feedback

---

## 📞 Support & Maintenance

### Monitoring
- Set up logging for all workflow steps
- Monitor PDF generation success rate
- Monitor email delivery rate
- Track workflow completion time

### Error Alerts
- Alert on PDF generation failures
- Alert on email delivery failures
- Alert on statement number conflicts
- Alert on Edge Function errors

---

## 🎉 Summary

**After all migration phases are complete:**

1. Implement 5 API endpoints
2. Implement PDF generation (MANDATORY)
3. Implement statement number management (MANDATORY)
4. Implement email notification (MANDATORY)
5. Create orchestration controller
6. Add error handling and rollback
7. Write comprehensive tests
8. Deploy to production

**Reference:** See `BACKEND_IMPLEMENTATION_GUIDE.md` for complete implementation details.

**Status:** Ready for implementation after Phase 9 completion.

