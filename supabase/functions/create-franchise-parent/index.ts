import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from 'jsr:@supabase/supabase-js@2';

// Types
interface CreateFranchiseParentRequest {
  name: string;
  franchise_brand_name: string;
  city_id: number;
  province_id: number;
  timezone?: string;
  created_by?: number;
}

// CORS
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

// Utilities
function jsonResponse(data: any, status: number = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { 'Content-Type': 'application/json', ...corsHeaders },
  });
}

function badRequest(error: string, details?: any): Response {
  return jsonResponse({ success: false, error, ...details && { details } }, 400);
}

function created(data: any, message?: string): Response {
  return jsonResponse({ success: true, data, message }, 201);
}

function internalError(error: string): Response {
  return jsonResponse({ success: false, error }, 500);
}

async function logAdminAction(supabase: any, userId: string, action: string, resourceType: string, resourceId: number, metadata: any) {
  try {
    await supabase.from('admin_action_logs').insert({
      user_id: userId,
      action,
      resource_type: resourceType,
      resource_id: resourceId,
      metadata,
    });
  } catch (error) {
    console.error('Failed to log admin action:', error);
  }
}

Deno.serve(async (req) => {
  // CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  if (req.method !== 'POST') {
    return badRequest('Method not allowed');
  }

  try {
    // Auth
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return jsonResponse({ success: false, error: 'Missing authorization header' }, 401);
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const supabase = createClient(supabaseUrl, supabaseKey);

    // Get user (for audit trail)
    const userClient = createClient(supabaseUrl, Deno.env.get('SUPABASE_ANON_KEY')!, {
      global: { headers: { Authorization: authHeader } },
    });
    const { data: { user } } = await userClient.auth.getUser();
    
    if (!user) {
      return jsonResponse({ success: false, error: 'Invalid or expired token' }, 401);
    }

    // Parse body
    const body: CreateFranchiseParentRequest = await req.json();

    // Validation
    if (!body.name || !body.franchise_brand_name || !body.city_id || !body.province_id) {
      return badRequest('Missing required fields: name, franchise_brand_name, city_id, province_id');
    }

    // Sanitize
    const sanitizedName = body.name.trim().replace(/\s+/g, ' ').substring(0, 255);
    const sanitizedBrandName = body.franchise_brand_name.trim().replace(/\s+/g, ' ').substring(0, 255);

    // Call SQL function
    const { data, error } = await supabase.rpc('create_franchise_parent', {
      p_name: sanitizedName,
      p_franchise_brand_name: sanitizedBrandName,
      p_city_id: body.city_id,
      p_province_id: body.province_id,
      p_timezone: body.timezone || 'America/Toronto',
      p_created_by: body.created_by || null,
    });

    if (error) {
      console.error('SQL error:', error);
      if (error.message.includes('already exists')) {
        return badRequest(`Franchise brand name already exists: ${sanitizedBrandName}`);
      }
      throw error;
    }

    if (!data || data.length === 0) {
      return badRequest('Failed to create franchise parent');
    }

    const result = data[0];

    // Audit log (async)
    logAdminAction(supabase, user.id, 'franchise.create', 'restaurants', result.parent_id, {
      name: sanitizedName,
      brand_name: sanitizedBrandName,
    }).catch(console.error);

    return created(
      {
        parent_id: result.parent_id,
        brand_name: result.brand_name,
        name: result.name,
        status: result.status,
      },
      'Franchise parent created successfully'
    );

  } catch (error: any) {
    console.error('Error:', error);
    return internalError('Failed to create franchise parent');
  }
});
