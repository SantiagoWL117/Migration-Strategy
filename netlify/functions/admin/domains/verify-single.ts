/**
 * Single Domain Verification Edge Function
 * 
 * Purpose: Verify a single domain on-demand (admin request)
 * Method: POST
 * Auth: Required (Admin only)
 * 
 * Usage:
 * POST /api/admin/domains/verify-single
 * Body: { domain_id: 2120 }
 * Headers: { Authorization: "Bearer <token>" }
 */

import { createClient } from '@supabase/supabase-js';
import * as https from 'https';
import * as dns from 'dns';
import { promisify } from 'util';

const resolveCname = promisify(dns.resolveCname);
const resolve4 = promisify(dns.resolve4);

interface RequestBody {
  domain_id: number;
}

export default async (req: Request): Promise<Response> => {
  // CORS
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
    // 1. Authentication
    const authHeader = req.headers.get('Authorization');
    if (!authHeader?.startsWith('Bearer ')) {
      return jsonResponse({ error: 'Unauthorized' }, 401);
    }

    // TODO: Implement proper JWT verification
    // const token = authHeader.substring(7);
    // const user = await verifyAdminToken(token);

    // 2. Parse request body
    const body: RequestBody = await req.json();
    
    if (!body.domain_id) {
      return jsonResponse({ error: 'domain_id is required' }, 400);
    }

    // 3. Initialize Supabase
    const supabase = createClient(
      process.env.SUPABASE_URL!,
      process.env.SUPABASE_SERVICE_KEY!
    );

    // 4. Fetch domain details
    const { data: domain, error: fetchError } = await supabase
      .from('restaurant_domains')
      .select('id, domain, restaurant_id, is_enabled')
      .eq('id', body.domain_id)
      .is('deleted_at', null)
      .single();

    if (fetchError || !domain) {
      return jsonResponse({ error: 'Domain not found' }, 404);
    }

    console.log(`Verifying domain: ${domain.domain}`);

    // 5. Verify SSL
    const sslResult = await verifySSL(domain.domain);
    
    // 6. Verify DNS
    const dnsResult = await verifyDNS(domain.domain);

    // 7. Update database
    const { error: updateError } = await supabase.rpc('mark_domain_verified', {
      p_domain_id: domain.id,
      p_ssl_verified: sslResult.valid,
      p_dns_verified: dnsResult.verified,
      p_ssl_expires_at: sslResult.valid ? sslResult.expiresAt.toISOString() : null,
      p_ssl_issuer: sslResult.valid ? sslResult.issuer : null,
      p_dns_records: {
        ...dnsResult.records,
        verified_at: new Date().toISOString(),
      },
      p_verification_errors: [sslResult.error, dnsResult.error].filter(Boolean).join('; ') || null,
    });

    if (updateError) {
      throw new Error(`Failed to update domain: ${updateError.message}`);
    }

    // 8. Fetch updated verification status
    const { data: status } = await supabase.rpc('get_domain_verification_status', {
      p_domain_id: domain.id,
    });

    // 9. Response
    return jsonResponse({
      success: true,
      message: 'Domain verified successfully',
      domain: domain.domain,
      verification: {
        ssl_verified: sslResult.valid,
        ssl_expires_at: sslResult.valid ? sslResult.expiresAt.toISOString() : null,
        ssl_issuer: sslResult.issuer,
        ssl_days_remaining: sslResult.daysRemaining,
        dns_verified: dnsResult.verified,
        dns_records: dnsResult.records,
      },
      status: status?.[0] || null,
    }, 200);

  } catch (error: any) {
    console.error('Domain verification failed:', error);
    return jsonResponse({
      error: 'Verification failed',
      message: error.message,
    }, 500);
  }
};

/**
 * Verify SSL certificate
 */
async function verifySSL(domain: string): Promise<{
  valid: boolean;
  issuer: string;
  expiresAt: Date;
  daysRemaining: number;
  error?: string;
}> {
  return new Promise((resolve) => {
    const req = https.request({
      host: domain,
      port: 443,
      method: 'GET',
      rejectUnauthorized: false,
      timeout: 10000,
    }, (res) => {
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
      const daysRemaining = Math.floor((expiresAt.getTime() - Date.now()) / (1000 * 60 * 60 * 24));

      resolve({
        valid: expiresAt > new Date(),
        issuer: cert.issuer?.O || cert.issuer?.CN || 'Unknown',
        expiresAt,
        daysRemaining,
      });
    });

    req.on('error', (error) => {
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
        error: 'Timeout',
      });
    });

    req.end();
  });
}

/**
 * Verify DNS records
 */
async function verifyDNS(domain: string): Promise<{
  verified: boolean;
  records: { a_records?: string[]; cname_records?: string[] };
  error?: string;
}> {
  try {
    const records: any = {};

    try {
      records.a_records = await resolve4(domain);
    } catch {}

    try {
      records.cname_records = await resolveCname(domain);
    } catch {}

    const verified = !!(records.a_records?.length || records.cname_records?.length);

    return {
      verified,
      records,
      error: verified ? undefined : 'No DNS records found',
    };
  } catch (error: any) {
    return {
      verified: false,
      records: {},
      error: error.message,
    };
  }
}

function jsonResponse(data: any, status: number = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
    },
  });
}


