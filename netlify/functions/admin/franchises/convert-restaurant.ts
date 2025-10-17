/**
 * Convert Restaurant to Franchise - Edge Function
 * 
 * Endpoint: POST /api/admin/franchises/convert-restaurant
 * Auth: Required (Admin only)
 * 
 * Wraps the SQL functions:
 * - menuca_v3.convert_to_franchise() - Single conversion
 * - menuca_v3.batch_link_franchise_children() - Bulk conversion
 */

import type { ConvertToFranchiseRequest, BatchLinkFranchiseRequest } from '../../shared/types';
import { requirePermission } from '../../shared/auth';
import {
  handleOptions,
  successResponse,
  badRequest,
  unauthorized,
  forbidden,
  internalError,
} from '../../shared/response';
import {
  validateRequired,
  validatePositiveInteger,
} from '../../shared/validation';
import {
  createAdminClient,
  logAdminAction,
  invalidateCache,
  sendNotification,
} from '../../shared/supabase';

export default async (req: Request): Promise<Response> => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return handleOptions();
  }

  // Only accept POST
  if (req.method !== 'POST') {
    return badRequest('Method not allowed');
  }

  try {
    // 1. Authentication & Authorization
    let user;
    try {
      user = await requirePermission(req, 'franchise.update');
    } catch (error: any) {
      if (error.message.includes('Authentication')) {
        return unauthorized();
      }
      return forbidden(error.message);
    }

    // 2. Parse and validate request body
    let body: ConvertToFranchiseRequest | BatchLinkFranchiseRequest;
    try {
      body = await req.json();
    } catch (error) {
      return badRequest('Invalid JSON body');
    }

    // 3. Determine if single or batch conversion
    const isBatch = 'child_restaurant_ids' in body && Array.isArray(body.child_restaurant_ids);

    if (isBatch) {
      return await handleBatchConversion(body as BatchLinkFranchiseRequest, user, supabase);
    } else {
      return await handleSingleConversion(body as ConvertToFranchiseRequest, user);
    }

  } catch (error: any) {
    console.error('Unexpected error:', error);
    return internalError(
      'Failed to convert restaurant',
      process.env.NODE_ENV === 'development' ? error.message : undefined
    );
  }
};

/**
 * Handle single restaurant conversion
 */
async function handleSingleConversion(
  body: ConvertToFranchiseRequest,
  user: any
): Promise<Response> {
  // Validate required fields
  const requiredFields = validateRequired(body, [
    'restaurant_id',
    'parent_restaurant_id',
  ]);
  if (!requiredFields.valid) {
    return badRequest(requiredFields.error!, requiredFields.errors);
  }

  if (!validatePositiveInteger(body.restaurant_id)) {
    return badRequest('Invalid restaurant_id');
  }

  if (!validatePositiveInteger(body.parent_restaurant_id)) {
    return badRequest('Invalid parent_restaurant_id');
  }

  // Initialize Supabase client
  const supabase = createAdminClient();

  // Call SQL function
  const { data, error } = await supabase.rpc('convert_to_franchise', {
    p_restaurant_id: body.restaurant_id,
    p_parent_restaurant_id: body.parent_restaurant_id,
    p_updated_by: body.updated_by || null,
  });

  if (error) {
    console.error('SQL function error:', error);
    
    if (error.message.includes('not found')) {
      return badRequest('Restaurant or parent not found');
    }
    
    if (error.message.includes('already')) {
      return badRequest('Restaurant is already part of a franchise');
    }
    
    throw error;
  }

  if (!data || data.length === 0) {
    return badRequest('Failed to convert restaurant');
  }

  const result = data[0];

  // Post-conversion actions (async)
  Promise.all([
    logAdminAction(
      supabase,
      user.id,
      'franchise.convert',
      'restaurants',
      body.restaurant_id,
      {
        parent_restaurant_id: body.parent_restaurant_id,
      }
    ),
    invalidateCache([
      `restaurant:${body.restaurant_id}`,
      `franchise:${body.parent_restaurant_id}`,
      'franchises:list',
    ]),
    sendNotification(
      'slack',
      `🔗 Restaurant converted to franchise: ${result.restaurant_name} → ${result.parent_brand_name}`,
      {
        restaurant_id: body.restaurant_id,
        parent_id: body.parent_restaurant_id,
        converted_by: user.email,
      }
    ),
  ]).catch(console.error);

  return successResponse(
    {
      restaurant_id: result.restaurant_id,
      restaurant_name: result.restaurant_name,
      parent_restaurant_id: result.parent_restaurant_id,
      parent_brand_name: result.parent_brand_name,
    },
    'Restaurant converted to franchise successfully'
  );
}

/**
 * Handle batch restaurant conversion
 */
async function handleBatchConversion(
  body: BatchLinkFranchiseRequest,
  user: any,
  supabase: any
): Promise<Response> {
  // Validate required fields
  const requiredFields = validateRequired(body, [
    'parent_restaurant_id',
    'child_restaurant_ids',
  ]);
  if (!requiredFields.valid) {
    return badRequest(requiredFields.error!, requiredFields.errors);
  }

  if (!validatePositiveInteger(body.parent_restaurant_id)) {
    return badRequest('Invalid parent_restaurant_id');
  }

  if (!Array.isArray(body.child_restaurant_ids) || body.child_restaurant_ids.length === 0) {
    return badRequest('child_restaurant_ids must be a non-empty array');
  }

  // Validate all child IDs
  for (const id of body.child_restaurant_ids) {
    if (!validatePositiveInteger(id)) {
      return badRequest(`Invalid restaurant ID: ${id}`);
    }
  }

  // Initialize Supabase client
  const supabaseClient = createAdminClient();

  // Call SQL function
  const { data, error } = await supabaseClient.rpc('batch_link_franchise_children', {
    p_parent_restaurant_id: body.parent_restaurant_id,
    p_child_restaurant_ids: body.child_restaurant_ids,
    p_updated_by: body.updated_by || null,
  });

  if (error) {
    console.error('SQL function error:', error);
    
    if (error.message.includes('not found')) {
      return badRequest('Parent restaurant not found');
    }
    
    throw error;
  }

  if (!data || data.length === 0) {
    return badRequest('Failed to link restaurants to franchise');
  }

  const result = data[0];

  // Post-conversion actions (async)
  Promise.all([
    logAdminAction(
      supabaseClient,
      user.id,
      'franchise.batch_link',
      'restaurants',
      body.parent_restaurant_id,
      {
        child_count: result.linked_count,
        child_restaurant_ids: body.child_restaurant_ids,
      }
    ),
    invalidateCache([
      `franchise:${body.parent_restaurant_id}`,
      'franchises:list',
      ...body.child_restaurant_ids.map(id => `restaurant:${id}`),
    ]),
    sendNotification(
      'slack',
      `🔗 Batch franchise link: ${result.linked_count} restaurants linked to ${result.parent_brand_name}`,
      {
        parent_id: body.parent_restaurant_id,
        linked_count: result.linked_count,
        converted_by: user.email,
      }
    ),
  ]).catch(console.error);

  return successResponse(
    {
      parent_restaurant_id: result.parent_restaurant_id,
      parent_brand_name: result.parent_brand_name,
      linked_count: result.linked_count,
      child_restaurants: result.child_restaurants || [],
    },
    `Successfully linked ${result.linked_count} restaurants to franchise`
  );
}












