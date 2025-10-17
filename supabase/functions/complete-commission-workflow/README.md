# Complete Commission Workflow Edge Function

## Overview

This is the **main orchestrator** for the commission report generation workflow. It coordinates all steps:

1. ✅ Get next statement number
2. ✅ Generate and save all reports
3. ✅ Generate PDF files (MANDATORY)
4. ✅ Update statement number (MANDATORY)
5. ✅ Send reports to vendor (MANDATORY)

## Endpoint

```
POST /functions/v1/complete-commission-workflow
```

## Request Body

```json
{
  "vendor_id": "uuid-vendor-1",
  "period_start": "2025-01-01",
  "period_end": "2025-01-31",
  "restaurants": [
    {
      "uuid": "uuid-rest-1",
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
}
```

## Response

```json
{
  "success": true,
  "statement_number": 22,
  "reports_count": 30,
  "pdf_files_generated": 30,
  "email_sent": true,
  "vendor_email": "vendor@example.com",
  "total_commission": 15000.50,
  "total_orders": 250000.00,
  "workflow_log": [
    "Step 1: Getting next statement number...",
    "✅ Next statement number: 22",
    "Step 2: Generating commission reports...",
    "✅ Saved 30 reports",
    "Step 3: Generating PDF files...",
    "✅ Generated 30 PDF files",
    "Step 4: Sending reports to vendor...",
    "✅ Reports sent to vendor@example.com",
    "✅ Statement number updated to 22"
  ],
  "duration_seconds": "12.45",
  "message": "Commission report workflow completed successfully in 12.45 seconds"
}
```

## Usage Example

```bash
curl -X POST "https://your-project.supabase.co/functions/v1/complete-commission-workflow" \
  -H "Authorization: Bearer YOUR_SUPABASE_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "vendor_id": "7edc3781-1234-5678-9abc-def012345678",
    "period_start": "2025-01-01",
    "period_end": "2025-01-31",
    "restaurants": [...]
  }'
```

## Error Handling

The workflow will fail if any step fails. Check the `workflow_log` in the response to see which step failed.

## Performance

Expected completion time:
- 10 restaurants: ~5-10 seconds
- 30 restaurants: ~10-15 seconds
- 50+ restaurants: ~15-30 seconds

