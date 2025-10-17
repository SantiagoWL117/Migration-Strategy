# Commission Reports Backend - Deployment Guide

**Version:** 1.0  
**Last Updated:** October 15, 2025  
**Status:** Ready for Deployment

---

## 📦 Edge Functions Created

| Function Name | Purpose | Status |
|--------------|---------|--------|
| `get-commission-preview` | Fetch preview data for report generation | ✅ Ready |
| `generate-commission-reports` | Save commission reports to database | ✅ Ready |
| `generate-commission-pdfs` | Generate PDF/HTML reports | ✅ Ready |
| `send-commission-reports` | Email reports to vendor | ⚠️ Needs email service |
| `complete-commission-workflow` | Main orchestrator | ✅ Ready |
| `calculate-vendor-commission` | Calculate commissions | ✅ Already deployed |

---

## 🚀 Deployment Steps

### Prerequisites

1. ✅ Supabase CLI installed
2. ✅ Deno installed (v1.37+)
3. ✅ Supabase project linked

### Step 1: Deploy All Functions

```bash
# Navigate to project root
cd "C:\Users\santi\Menu.ca\Legacy Database\Migration Strategy"

# Deploy get-commission-preview
supabase functions deploy get-commission-preview

# Deploy generate-commission-reports
supabase functions deploy generate-commission-reports

# Deploy generate-commission-pdfs
supabase functions deploy generate-commission-pdfs

# Deploy send-commission-reports
supabase functions deploy send-commission-reports

# Deploy complete-commission-workflow (main orchestrator)
supabase functions deploy complete-commission-workflow
```

### Step 2: Create Storage Bucket

The PDF generation function needs a storage bucket:

```bash
# Via Supabase Dashboard:
# 1. Go to Storage
# 2. Create new bucket: "commission-reports"
# 3. Set to public: YES (so vendors can download PDFs)
# 4. Set file size limit: 10MB

# Or via SQL:
```

```sql
-- Create storage bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('commission-reports', 'commission-reports', true);

-- Allow public read access
CREATE POLICY "Public Access"
ON storage.objects FOR SELECT
USING ( bucket_id = 'commission-reports' );

-- Allow service role to upload
CREATE POLICY "Service Role Upload"
ON storage.objects FOR INSERT
TO service_role
WITH CHECK ( bucket_id = 'commission-reports' );
```

### Step 3: Configure Email Service (Optional)

The `send-commission-reports` function currently logs emails but doesn't send them. To enable email sending:

**Option A: Resend (Recommended)**

```bash
# Set environment variable
supabase secrets set RESEND_API_KEY=your_resend_api_key_here
```

Then update `send-commission-reports/index.ts` to uncomment the Resend integration.

**Option B: SendGrid**

```bash
supabase secrets set SENDGRID_API_KEY=your_sendgrid_api_key_here
```

**Option C: Skip for now**

The function will mark reports as sent and log the email content without actually sending.

### Step 4: Verify Deployment

```bash
# List all deployed functions
supabase functions list

# Test the preview endpoint
curl -X GET "https://your-project.supabase.co/functions/v1/get-commission-preview?vendor_id=YOUR_VENDOR_ID&period_start=2025-01-01&period_end=2025-01-31" \
  -H "Authorization: Bearer YOUR_SERVICE_ROLE_KEY"
```

---

## 🧪 Testing

### Test 1: Get Preview Data

```bash
curl -X GET "https://your-project.supabase.co/functions/v1/get-commission-preview?vendor_id=7edc3781-xxxx&period_start=2024-01-01&period_end=2024-12-31" \
  -H "Authorization: Bearer YOUR_KEY"
```

Expected: JSON with vendor info, restaurants, and order totals.

### Test 2: Calculate Commission (Existing Function)

```bash
curl -X POST "https://your-project.supabase.co/functions/v1/calculate-vendor-commission" \
  -H "Authorization: Bearer YOUR_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "template_name": "percent_commission",
    "total": 10000,
    "restaurant_commission": 10,
    "commission_type": "percentage",
    "menuottawa_share": 80
  }'
```

Expected: Calculation breakdown.

### Test 3: Complete Workflow (Integration Test)

```bash
curl -X POST "https://your-project.supabase.co/functions/v1/complete-commission-workflow" \
  -H "Authorization: Bearer YOUR_SERVICE_ROLE_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "vendor_id": "YOUR_VENDOR_ID",
    "period_start": "2025-01-01",
    "period_end": "2025-01-31",
    "restaurants": [
      {
        "uuid": "RESTAURANT_UUID",
        "commission_rate": 10.0,
        "commission_type": "percentage",
        "calculation_result": {
          "template_name": "percent_commission",
          "use_total": 10000.00,
          "for_vendor": 4960.00,
          "for_menu_ottawa": 80.00,
          "for_menuca": 4960.00,
          "menuottawa_share": 80.00
        }
      }
    ]
  }'
```

Expected: Complete workflow execution with all steps.

---

## 📊 Monitoring

### Check Function Logs

```bash
# View logs for a specific function
supabase functions logs get-commission-preview

# Follow logs in real-time
supabase functions logs get-commission-preview --follow
```

### Database Monitoring

```sql
-- Check recent reports
SELECT 
    vendor_id,
    statement_number,
    COUNT(*) as report_count,
    SUM(vendor_commission_amount) as total_commission,
    report_status,
    report_generated_at
FROM menuca_v3.vendor_commission_reports
WHERE report_generated_at >= NOW() - INTERVAL '7 days'
GROUP BY vendor_id, statement_number, report_status, report_generated_at
ORDER BY report_generated_at DESC;

-- Check statement numbers
SELECT * FROM menuca_v3.vendor_statement_numbers;
```

---

## 🔧 Troubleshooting

### Issue: "Storage bucket not found"

**Solution:** Create the `commission-reports` bucket (see Step 2).

### Issue: "Failed to send email"

**Solution:** Configure email service (see Step 3) or verify it's working in log-only mode.

### Issue: "Permission denied"

**Solution:** Ensure you're using the service role key for backend operations.

### Issue: "Function timeout"

**Solution:** 
- Check if processing too many restaurants at once
- Consider breaking into smaller batches
- Increase function timeout in Supabase dashboard

---

## 🎯 Success Criteria

Deployment is successful when:

- ✅ All 5 new functions are deployed
- ✅ Storage bucket `commission-reports` exists
- ✅ Preview endpoint returns data
- ✅ Complete workflow executes without errors
- ✅ Reports are saved to database
- ✅ PDFs are generated and stored
- ✅ Statement numbers are updated
- ✅ Email notifications sent (or logged if service not configured)

---

## 📝 Next Steps After Deployment

1. **Frontend Integration**: Connect these Edge Functions to your frontend application
2. **Email Service**: Set up Resend or SendGrid for production email sending
3. **Monitoring**: Set up alerts for function failures
4. **Performance Testing**: Test with production data volumes
5. **Documentation**: Update API documentation with actual endpoints

---

## 🔗 Related Documentation

- [Backend Implementation Guide](../documentation/Vendors%20&%20Franchises/backend%20implementation/BACKEND_IMPLEMENTATION_GUIDE.md)
- [Vendor Business Logic Analysis](../documentation/Vendors%20&%20Franchises/vendor-business-logic-analysis.plan.md)
- [Deployment Checklist](../documentation/Vendors%20&%20Franchises/Deployment%20and%20operations/DEPLOYMENT_CHECKLIST.md)

