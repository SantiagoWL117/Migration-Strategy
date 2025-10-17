# Domain Verification Edge Function - Deployment Checklist

**Created:** 2025-10-16
**Task:** 5.1 SSL & DNS Verification
**Status:** ✅ Ready for Deployment

---

## 📋 Pre-Deployment Checklist

### 1. Files Created ✅

- [x] `netlify/functions/cron/verify-domains.ts` - Automated cron job
- [x] `netlify/functions/admin/domains/verify-single.ts` - On-demand verification
- [x] `netlify.toml` - Netlify configuration
- [x] `package.json` - Dependencies
- [x] `DOMAIN_VERIFICATION_EDGE_FUNCTION.md` - Implementation guide
- [x] `DOMAIN_VERIFICATION_DEPLOYMENT_CHECKLIST.md` - This file

### 2. Database Prerequisites ✅

- [x] SQL function `mark_domain_verified()` exists
- [x] SQL function `get_domain_verification_status()` exists
- [x] View `v_domains_needing_attention` exists
- [x] View `v_domain_verification_summary` exists
- [x] Columns added to `restaurant_domains`:
  - [x] `ssl_verified`
  - [x] `ssl_verified_at`
  - [x] `ssl_expires_at`
  - [x] `ssl_issuer`
  - [x] `dns_verified`
  - [x] `dns_verified_at`
  - [x] `dns_records` (JSONB)
  - [x] `last_checked_at`
  - [x] `verification_errors`

---

## 🚀 Deployment Steps

### Step 1: Install Dependencies

```bash
cd "C:\Users\santi\Menu.ca\Legacy Database\Migration Strategy"
npm install
```

**Expected output:**
```
added 2 packages
@supabase/supabase-js@^2.39.0
```

---

### Step 2: Configure Environment Variables

**In Netlify UI:**
1. Go to `Site Settings > Environment Variables`
2. Add the following variables:

```bash
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
CRON_SECRET=generate-random-secret-here
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/xxx (optional)
```

**Generate CRON_SECRET:**
```bash
# PowerShell
-join ((65..90) + (97..122) + (48..57) | Get-Random -Count 32 | % {[char]$_})

# Or use online generator: https://randomkeygen.com/
```

---

### Step 3: Deploy to Netlify

**Option A: Git Push (Recommended)**
```bash
git add netlify/ package.json netlify.toml
git commit -m "Add domain verification Edge Functions"
git push origin Santiago
```

**Option B: Manual Deploy**
```bash
netlify deploy --prod
```

---

### Step 4: Verify Deployment

**Check Functions Deployed:**
```bash
netlify functions:list
```

**Expected output:**
```
Functions:
- cron/verify-domains
- admin/domains/verify-single
```

**Check Function Logs:**
```bash
netlify functions:log verify-domains --live
```

---

### Step 5: Test Cron Job Manually

**Using curl:**
```bash
curl -X POST https://your-site.netlify.app/.netlify/functions/cron/verify-domains \
  -H "X-Cron-Secret: YOUR_CRON_SECRET_HERE"
```

**Expected response:**
```json
{
  "success": true,
  "message": "Domain verification completed",
  "summary": {
    "total_checked": 100,
    "ssl_verified": 0,
    "dns_verified": 0,
    "fully_verified": 0,
    "errors": 0
  }
}
```

---

### Step 6: Test Single Domain Verification

**Using curl:**
```bash
curl -X POST https://your-site.netlify.app/.netlify/functions/admin/domains/verify-single \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN" \
  -d '{"domain_id": 2120}'
```

**Expected response:**
```json
{
  "success": true,
  "message": "Domain verified successfully",
  "domain": "pizzashark.ca",
  "verification": {
    "ssl_verified": true,
    "ssl_expires_at": "2025-04-15T12:00:00Z",
    "ssl_issuer": "Let's Encrypt",
    "ssl_days_remaining": 180,
    "dns_verified": true,
    "dns_records": {
      "a_records": ["192.168.1.1"]
    }
  }
}
```

---

### Step 7: Enable Cron Schedule

**In Netlify UI:**
1. Go to `Functions > verify-domains`
2. Click "Settings"
3. Enable "Scheduled function"
4. Set cron expression: `0 2 * * *` (Daily at 2 AM UTC)
5. Save

**Or verify in `netlify.toml`:**
```toml
[[functions."cron/verify-domains"]]
  schedule = "0 2 * * *"
```

---

### Step 8: Monitor First Run

**Wait for first scheduled run (2 AM UTC) or trigger manually:**

**Check Supabase:**
```sql
-- Check verification summary
SELECT * FROM menuca_v3.v_domain_verification_summary;

-- Check recently verified domains
SELECT 
  domain,
  ssl_verified,
  dns_verified,
  last_checked_at
FROM menuca_v3.restaurant_domains
WHERE last_checked_at > NOW() - INTERVAL '1 hour'
ORDER BY last_checked_at DESC
LIMIT 20;
```

---

## 📊 Post-Deployment Monitoring

### Day 1: Initial Verification

**Check:**
- [ ] Cron job ran successfully
- [ ] ~100 domains verified
- [ ] No critical errors in logs
- [ ] Database updated correctly

**Query:**
```sql
SELECT 
  COUNT(*) as total_domains,
  COUNT(*) FILTER (WHERE last_checked_at > NOW() - INTERVAL '24 hours') as verified_today,
  COUNT(*) FILTER (WHERE ssl_verified) as ssl_verified_count,
  COUNT(*) FILTER (WHERE dns_verified) as dns_verified_count
FROM menuca_v3.restaurant_domains
WHERE deleted_at IS NULL AND is_enabled = true;
```

---

### Day 7: Full Cycle Complete

**Check:**
- [ ] All 711 domains verified (8-day cycle)
- [ ] SSL expiration alerts working
- [ ] No domains stuck in "Never checked" status

**Query:**
```sql
-- Verification progress
SELECT 
  CASE 
    WHEN last_checked_at IS NULL THEN 'Never checked'
    WHEN last_checked_at < NOW() - INTERVAL '7 days' THEN 'Stale (>7 days)'
    WHEN last_checked_at < NOW() - INTERVAL '2 days' THEN 'Recent (2-7 days)'
    ELSE 'Up to date (<2 days)'
  END as status,
  COUNT(*) as domain_count
FROM menuca_v3.restaurant_domains
WHERE deleted_at IS NULL AND is_enabled = true
GROUP BY status
ORDER BY domain_count DESC;
```

---

### Day 30: Production Metrics

**Check:**
- [ ] Verify success rate > 95%
- [ ] Average verification time < 3 seconds
- [ ] No SSL certificates expired unexpectedly
- [ ] Slack alerts received for expiring certs

**Query:**
```sql
-- Monthly verification stats
SELECT 
  DATE(last_checked_at) as check_date,
  COUNT(*) as domains_checked,
  COUNT(*) FILTER (WHERE ssl_verified) as ssl_success,
  COUNT(*) FILTER (WHERE dns_verified) as dns_success,
  COUNT(*) FILTER (WHERE verification_errors IS NOT NULL) as errors,
  ROUND(100.0 * COUNT(*) FILTER (WHERE ssl_verified) / COUNT(*), 2) as ssl_success_rate
FROM menuca_v3.restaurant_domains
WHERE last_checked_at > NOW() - INTERVAL '30 days'
  AND deleted_at IS NULL
GROUP BY DATE(last_checked_at)
ORDER BY check_date DESC;
```

---

## 🔧 Troubleshooting

### Issue 1: Cron Job Not Running

**Symptoms:**
- No domains verified
- `last_checked_at` still NULL

**Solutions:**
1. Check Netlify Functions logs
2. Verify cron schedule is enabled
3. Test manual trigger with `X-Cron-Secret`
4. Check environment variables are set

---

### Issue 2: SSL Verification Failing

**Symptoms:**
- `ssl_verified = false` for all domains
- `verification_errors` contains "Connection timeout"

**Solutions:**
1. Check firewall/network settings
2. Verify domains are publicly accessible
3. Increase timeout in code (currently 10s)
4. Test specific domain manually:
   ```bash
   openssl s_client -connect pizzashark.ca:443 -servername pizzashark.ca
   ```

---

### Issue 3: DNS Verification Failing

**Symptoms:**
- `dns_verified = false` for all domains
- `verification_errors` contains "No DNS records found"

**Solutions:**
1. Check DNS resolver settings
2. Verify domains are registered and active
3. Test specific domain manually:
   ```bash
   nslookup pizzashark.ca
   dig pizzashark.ca A
   dig pizzashark.ca CNAME
   ```

---

### Issue 4: Function Timeout

**Symptoms:**
- Function exceeds 30-second timeout
- Only partial domains verified

**Solutions:**
1. Reduce batch size (currently 100 domains)
2. Increase function timeout in `netlify.toml`:
   ```toml
   [functions."cron/verify-domains"]
     timeout = 60
   ```
3. Reduce rate limit delay (currently 500ms)

---

## 🎯 Success Criteria

### ✅ Deployment Successful If:

1. **Cron Job Runs Daily**
   - Scheduled at 2 AM UTC
   - Completes in < 60 seconds
   - Verifies 100 domains per run

2. **Verification Accuracy**
   - SSL verification success rate > 95%
   - DNS verification success rate > 95%
   - Error rate < 5%

3. **Database Updates**
   - `last_checked_at` updated for all domains
   - `ssl_verified` and `dns_verified` flags accurate
   - `ssl_expires_at` dates populated
   - `dns_records` JSONB contains valid data

4. **Alerts Working**
   - Slack notifications sent for certs expiring < 30 days
   - URGENT alerts sent for certs expiring < 7 days
   - No false positives

5. **Admin Interface**
   - Single domain verification works
   - Response time < 5 seconds
   - Accurate verification results

---

## 📈 Performance Benchmarks

### Expected Performance

| Metric | Target | Actual |
|--------|--------|--------|
| Cron job runtime | < 60s | TBD |
| Domains per run | 100 | TBD |
| SSL check time | 1-2s | TBD |
| DNS check time | 1-2s | TBD |
| Database update | < 500ms | TBD |
| Success rate | > 95% | TBD |
| Error rate | < 5% | TBD |

**Update this table after 7 days of production use.**

---

## 🔄 Maintenance Schedule

### Daily (Automated)
- Cron job runs at 2 AM UTC
- Verifies 100 domains
- Sends expiration alerts

### Weekly (Manual)
- Review `v_domains_needing_attention` view
- Check for domains stuck in error state
- Verify expiration alerts are accurate

### Monthly (Manual)
- Analyze verification success rate
- Review function performance metrics
- Update batch size if needed
- Check for SSL certificates expiring < 90 days

### Quarterly (Manual)
- Review and update alert thresholds
- Test disaster recovery procedure
- Update documentation with lessons learned

---

## 📞 Support Contacts

### Netlify Issues
- Platform Status: https://www.netlifystatus.com/
- Support: support@netlify.com
- Docs: https://docs.netlify.com/functions/

### Supabase Issues
- Platform Status: https://status.supabase.com/
- Support: support@supabase.io
- Docs: https://supabase.com/docs

### SSL Certificate Issues
- Let's Encrypt: https://letsencrypt.org/docs/
- SSL Labs Test: https://www.ssllabs.com/ssltest/

---

## ✅ Deployment Complete

Once all checklist items are verified, mark this deployment as **PRODUCTION READY**.

**Deployed By:** Santiago
**Deployment Date:** 2025-10-16
**Status:** ⏳ Pending Deployment

---

**Next Steps After Deployment:**
1. Monitor for 48 hours
2. Verify first week of verification cycles
3. Adjust batch size and rate limits if needed
4. Document any issues encountered
5. Mark Task 5.1 as COMPLETE ✅

