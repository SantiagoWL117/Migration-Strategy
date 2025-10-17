/**
 * Domain Verification Edge Function (Cron Job)
 * 
 * Purpose: Automatically verify SSL certificates and DNS records for all restaurant domains
 * Frequency: Runs daily via cron or on-demand
 * 
 * Features:
 * - SSL certificate verification (expiration, issuer)
 * - DNS record validation (A, CNAME records)
 * - Batch processing with rate limiting
 * - Detailed error logging
 * - Slack/email alerts for expiring certificates
 * 
 * Usage:
 * - Cron: Scheduled via Netlify (daily at 2 AM)
 * - Manual: POST /api/cron/verify-domains with auth token
 */

import { createClient } from '@supabase/supabase-js';
import * as https from 'https';
import * as dns from 'dns';
import { promisify } from 'util';

// DNS lookup promises
const resolveCname = promisify(dns.resolveCname);
const resolve4 = promisify(dns.resolve4);

interface DomainVerificationResult {
  domain_id: number;
  domain: string;
  ssl_verified: boolean;
  ssl_expires_at: string | null;
  ssl_issuer: string | null;
  dns_verified: boolean;
  dns_records: {
    a_records?: string[];
    cname_records?: string[];
    verified_at: string;
  };
  verification_errors: string | null;
}

interface SSLCertificateInfo {
  valid: boolean;
  issuer: string;
  expiresAt: Date;
  daysRemaining: number;
  error?: string;
}

interface DNSVerificationResult {
  verified: boolean;
  records: {
    a_records?: string[];
    cname_records?: string[];
  };
  error?: string;
}

/**
 * Main handler function
 */
export default async (req: Request): Promise<Response> => {
  // CORS headers for OPTIONS
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      status: 204,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      },
    });
  }

  try {
    // 1. Authentication (Cron secret or admin token)
    const authHeader = req.headers.get('Authorization');
    const cronSecret = process.env.CRON_SECRET;
    
    if (!authHeader && (!cronSecret || req.headers.get('X-Cron-Secret') !== cronSecret)) {
      return jsonResponse({ error: 'Unauthorized' }, 401);
    }

    // 2. Initialize Supabase client
    const supabase = createClient(
      process.env.SUPABASE_URL!,
      process.env.SUPABASE_SERVICE_KEY!
    );

    // 3. Get domains that need verification
    const { data: domains, error: fetchError } = await supabase
      .from('restaurant_domains')
      .select('id, domain, restaurant_id, is_enabled')
      .is('deleted_at', null)
      .eq('is_enabled', true)
      .or('last_checked_at.is.null,last_checked_at.lt.' + getYesterdayISO())
      .limit(100); // Process 100 domains per run

    if (fetchError) {
      console.error('Failed to fetch domains:', fetchError);
      throw new Error('Failed to fetch domains');
    }

    if (!domains || domains.length === 0) {
      return jsonResponse({
        success: true,
        message: 'No domains need verification',
        domains_checked: 0,
      });
    }

    console.log(`Verifying ${domains.length} domains...`);

    // 4. Verify each domain (with rate limiting)
    const results: DomainVerificationResult[] = [];
    const errors: string[] = [];

    for (const domain of domains) {
      try {
        const result = await verifyDomain(domain.id, domain.domain);
        results.push(result);

        // 5. Update database with verification result
        const { error: updateError } = await supabase.rpc('mark_domain_verified', {
          p_domain_id: result.domain_id,
          p_ssl_verified: result.ssl_verified,
          p_dns_verified: result.dns_verified,
          p_ssl_expires_at: result.ssl_expires_at,
          p_ssl_issuer: result.ssl_issuer,
          p_dns_records: result.dns_records,
          p_verification_errors: result.verification_errors,
        });

        if (updateError) {
          console.error(`Failed to update domain ${domain.id}:`, updateError);
          errors.push(`Failed to update domain ${domain.domain}: ${updateError.message}`);
        }

        // 6. Alert if SSL expires soon
        if (result.ssl_verified && result.ssl_expires_at) {
          const expiresAt = new Date(result.ssl_expires_at);
          const daysRemaining = Math.floor((expiresAt.getTime() - Date.now()) / (1000 * 60 * 60 * 24));
          
          if (daysRemaining <= 30) {
            await sendExpirationAlert(domain.domain, daysRemaining);
          }
        }

        // Rate limiting: wait 500ms between requests
        await sleep(500);

      } catch (error: any) {
        console.error(`Error verifying domain ${domain.domain}:`, error);
        errors.push(`${domain.domain}: ${error.message}`);
      }
    }

    // 7. Summary statistics
    const summary = {
      total_checked: results.length,
      ssl_verified: results.filter(r => r.ssl_verified).length,
      dns_verified: results.filter(r => r.dns_verified).length,
      fully_verified: results.filter(r => r.ssl_verified && r.dns_verified).length,
      errors: errors.length,
    };

    console.log('Verification complete:', summary);

    // 8. Response
    return jsonResponse({
      success: true,
      message: 'Domain verification completed',
      summary,
      errors: errors.length > 0 ? errors : undefined,
    });

  } catch (error: any) {
    console.error('Domain verification failed:', error);
    return jsonResponse({
      error: 'Domain verification failed',
      message: error.message,
    }, 500);
  }
};

/**
 * Verify a single domain (SSL + DNS)
 */
async function verifyDomain(domainId: number, domain: string): Promise<DomainVerificationResult> {
  console.log(`Verifying domain: ${domain}`);

  // Verify SSL certificate
  const sslResult = await verifySSL(domain);
  
  // Verify DNS records
  const dnsResult = await verifyDNS(domain);

  return {
    domain_id: domainId,
    domain,
    ssl_verified: sslResult.valid,
    ssl_expires_at: sslResult.valid ? sslResult.expiresAt.toISOString() : null,
    ssl_issuer: sslResult.valid ? sslResult.issuer : null,
    dns_verified: dnsResult.verified,
    dns_records: {
      ...dnsResult.records,
      verified_at: new Date().toISOString(),
    },
    verification_errors: [sslResult.error, dnsResult.error].filter(Boolean).join('; ') || null,
  };
}

/**
 * Verify SSL certificate for a domain
 */
async function verifySSL(domain: string): Promise<SSLCertificateInfo> {
  return new Promise((resolve) => {
    const options = {
      host: domain,
      port: 443,
      method: 'GET',
      rejectUnauthorized: false, // We want to check the cert even if invalid
      timeout: 10000, // 10 second timeout
    };

    const req = https.request(options, (res) => {
      const cert = (res.socket as any).getPeerCertificate();

      if (!cert || !cert.valid_to) {
        resolve({
          valid: false,
          issuer: 'Unknown',
          expiresAt: new Date(),
          daysRemaining: 0,
          error: 'No certificate found',
        });
        return;
      }

      const expiresAt = new Date(cert.valid_to);
      const now = new Date();
      const daysRemaining = Math.floor((expiresAt.getTime() - now.getTime()) / (1000 * 60 * 60 * 24));

      // Extract issuer organization
      const issuerOrg = cert.issuer?.O || cert.issuer?.CN || 'Unknown';

      resolve({
        valid: expiresAt > now,
        issuer: issuerOrg,
        expiresAt,
        daysRemaining,
      });
    });

    req.on('error', (error) => {
      console.error(`SSL verification failed for ${domain}:`, error.message);
      resolve({
        valid: false,
        issuer: 'Unknown',
        expiresAt: new Date(),
        daysRemaining: 0,
        error: error.message,
      });
    });

    req.on('timeout', () => {
      req.destroy();
      resolve({
        valid: false,
        issuer: 'Unknown',
        expiresAt: new Date(),
        daysRemaining: 0,
        error: 'Connection timeout',
      });
    });

    req.end();
  });
}

/**
 * Verify DNS records for a domain
 */
async function verifyDNS(domain: string): Promise<DNSVerificationResult> {
  try {
    const records: { a_records?: string[]; cname_records?: string[] } = {};

    // Try to resolve A records
    try {
      const aRecords = await resolve4(domain);
      records.a_records = aRecords;
    } catch (error: any) {
      console.log(`No A records for ${domain}:`, error.message);
    }

    // Try to resolve CNAME records
    try {
      const cnameRecords = await resolveCname(domain);
      records.cname_records = cnameRecords;
    } catch (error: any) {
      console.log(`No CNAME records for ${domain}:`, error.message);
    }

    // Consider verified if we found at least one record type
    const verified = !!(records.a_records?.length || records.cname_records?.length);

    return {
      verified,
      records,
      error: verified ? undefined : 'No DNS records found',
    };

  } catch (error: any) {
    console.error(`DNS verification failed for ${domain}:`, error);
    return {
      verified: false,
      records: {},
      error: error.message,
    };
  }
}

/**
 * Send alert for expiring SSL certificate
 */
async function sendExpirationAlert(domain: string, daysRemaining: number): Promise<void> {
  // TODO: Implement Slack/email notification
  console.warn(`⚠️ SSL Alert: ${domain} expires in ${daysRemaining} days`);
  
  // Example Slack webhook (if configured)
  const slackWebhook = process.env.SLACK_WEBHOOK_URL;
  if (slackWebhook) {
    try {
      await fetch(slackWebhook, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          text: `🚨 SSL Certificate Alert`,
          blocks: [
            {
              type: 'section',
              text: {
                type: 'mrkdwn',
                text: `*SSL Certificate Expiring Soon*\n\n*Domain:* ${domain}\n*Days Remaining:* ${daysRemaining}\n*Priority:* ${daysRemaining <= 7 ? 'URGENT' : 'Medium'}`,
              },
            },
          ],
        }),
      });
    } catch (error) {
      console.error('Failed to send Slack alert:', error);
    }
  }
}

/**
 * Helper: JSON response
 */
function jsonResponse(data: any, status: number = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
    },
  });
}

/**
 * Helper: Sleep for rate limiting
 */
function sleep(ms: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms));
}

/**
 * Helper: Get yesterday's date in ISO format
 */
function getYesterdayISO(): string {
  const yesterday = new Date();
  yesterday.setDate(yesterday.getDate() - 1);
  return yesterday.toISOString();
}


