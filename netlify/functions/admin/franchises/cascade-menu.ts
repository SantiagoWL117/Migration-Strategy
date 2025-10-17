/**
 * Cascade Menu Items - Edge Function
 * 
 * Endpoint: POST /api/admin/franchises/cascade-menu
 * Auth: Required (Admin only)
 * 
 * Wraps the SQL functions:
 * - menuca_v3.cascade_dish_to_children() - Cascade single dish
 * - menuca_v3.cascade_pricing_to_children() - Cascade pricing updates
 * - menuca_v3.sync_menu_from_parent() - Full menu sync
 */

import type { CascadeMenuRequest } from '../../shared/types';
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
      user = await requirePermission(req, 'franchise.menu_cascade');
    } catch (error: any) {
      if (error.message.includes('Authentication')) {
        return unauthorized();
      }
      return forbidden(error.message);
    }

    // 2. Parse and validate request body
    let body: CascadeMenuRequest;
    try {
      body = await req.json();
    } catch (error) {
      return badRequest('Invalid JSON body');
    }

    // 3. Validate required fields
    const requiredFields = validateRequired(body, ['parent_restaurant_id']);
    if (!requiredFields.valid) {
      return badRequest(requiredFields.error!, requiredFields.errors);
    }

    if (!validatePositiveInteger(body.parent_restaurant_id)) {
      return badRequest('Invalid parent_restaurant_id');
    }

    // 4. Determine operation type and execute
    if (body.dish_id) {
      // Single dish cascade
      return await handleDishCascade(body, user);
    } else if (body.include_pricing) {
      // Pricing cascade only
      return await handlePricingCascade(body, user);
    } else {
      // Full menu sync
      return await handleFullMenuSync(body, user);
    }

  } catch (error: any) {
    console.error('Unexpected error:', error);
    return internalError(
      'Failed to cascade menu',
      process.env.NODE_ENV === 'development' ? error.message : undefined
    );
  }
};

/**
 * Handle single dish cascade to children
 */
async function handleDishCascade(
  body: CascadeMenuRequest,
  user: any
): Promise<Response> {
  if (!validatePositiveInteger(body.dish_id!)) {
    return badRequest('Invalid dish_id');
  }

  const supabase = createAdminClient();

  // Validate child_restaurant_ids if provided
  let childIds = body.child_restaurant_ids;
  if (childIds) {
    if (!Array.isArray(childIds) || childIds.length === 0) {
      return badRequest('child_restaurant_ids must be a non-empty array');
    }
    for (const id of childIds) {
      if (!validatePositiveInteger(id)) {
        return badRequest(`Invalid restaurant ID: ${id}`);
      }
    }
  }

  // Call SQL function
  const { data, error } = await supabase.rpc('cascade_dish_to_children', {
    p_parent_restaurant_id: body.parent_restaurant_id,
    p_dish_id: body.dish_id,
    p_child_restaurant_ids: childIds || null,
    p_include_pricing: body.include_pricing || false,
  });

  if (error) {
    console.error('SQL function error:', error);
    
    if (error.message.includes('not found')) {
      return badRequest('Parent restaurant or dish not found');
    }
    
    throw error;
  }

  if (!data || data.length === 0) {
    return badRequest('Failed to cascade dish');
  }

  const result = data[0];

  // Post-operation actions (async)
  Promise.all([
    logAdminAction(
      supabase,
      user.id,
      'franchise.cascade_dish',
      'dishes',
      body.dish_id,
      {
        parent_restaurant_id: body.parent_restaurant_id,
        children_updated: result.children_updated,
        include_pricing: body.include_pricing,
      }
    ),
    invalidateCache([
      `franchise:${body.parent_restaurant_id}:menu`,
      ...(childIds || []).map(id => `restaurant:${id}:menu`),
    ]),
    sendNotification(
      'slack',
      `📋 Dish cascaded: ${result.dish_name} to ${result.children_updated} locations`,
      {
        parent_id: body.parent_restaurant_id,
        dish_id: body.dish_id,
        children_updated: result.children_updated,
        updated_by: user.email,
      }
    ),
  ]).catch(console.error);

  return successResponse(
    {
      parent_restaurant_id: body.parent_restaurant_id,
      dish_id: body.dish_id,
      dish_name: result.dish_name,
      children_updated: result.children_updated,
      include_pricing: body.include_pricing || false,
    },
    `Dish cascaded to ${result.children_updated} franchise locations`
  );
}

/**
 * Handle pricing cascade to children
 */
async function handlePricingCascade(
  body: CascadeMenuRequest,
  user: any
): Promise<Response> {
  const supabase = createAdminClient();

  // Validate child_restaurant_ids if provided
  let childIds = body.child_restaurant_ids;
  if (childIds) {
    if (!Array.isArray(childIds) || childIds.length === 0) {
      return badRequest('child_restaurant_ids must be a non-empty array');
    }
    for (const id of childIds) {
      if (!validatePositiveInteger(id)) {
        return badRequest(`Invalid restaurant ID: ${id}`);
      }
    }
  }

  // Call SQL function
  const { data, error } = await supabase.rpc('cascade_pricing_to_children', {
    p_parent_restaurant_id: body.parent_restaurant_id,
    p_child_restaurant_ids: childIds || null,
  });

  if (error) {
    console.error('SQL function error:', error);
    
    if (error.message.includes('not found')) {
      return badRequest('Parent restaurant not found');
    }
    
    throw error;
  }

  if (!data || data.length === 0) {
    return badRequest('Failed to cascade pricing');
  }

  const result = data[0];

  // Post-operation actions (async)
  Promise.all([
    logAdminAction(
      supabase,
      user.id,
      'franchise.cascade_pricing',
      'restaurants',
      body.parent_restaurant_id,
      {
        children_updated: result.children_updated,
        dishes_updated: result.dishes_updated,
      }
    ),
    invalidateCache([
      `franchise:${body.parent_restaurant_id}:menu`,
      ...(childIds || []).map(id => `restaurant:${id}:menu`),
    ]),
    sendNotification(
      'slack',
      `💰 Pricing cascaded: ${result.dishes_updated} dishes to ${result.children_updated} locations`,
      {
        parent_id: body.parent_restaurant_id,
        children_updated: result.children_updated,
        dishes_updated: result.dishes_updated,
        updated_by: user.email,
      }
    ),
  ]).catch(console.error);

  return successResponse(
    {
      parent_restaurant_id: body.parent_restaurant_id,
      children_updated: result.children_updated,
      dishes_updated: result.dishes_updated,
    },
    `Pricing cascaded to ${result.children_updated} franchise locations`
  );
}

/**
 * Handle full menu sync from parent
 */
async function handleFullMenuSync(
  body: CascadeMenuRequest,
  user: any
): Promise<Response> {
  const supabase = createAdminClient();

  // Validate child_restaurant_ids if provided
  let childIds = body.child_restaurant_ids;
  if (childIds) {
    if (!Array.isArray(childIds) || childIds.length === 0) {
      return badRequest('child_restaurant_ids must be a non-empty array');
    }
    for (const id of childIds) {
      if (!validatePositiveInteger(id)) {
        return badRequest(`Invalid restaurant ID: ${id}`);
      }
    }
  }

  // Call SQL function
  const { data, error } = await supabase.rpc('sync_menu_from_parent', {
    p_parent_restaurant_id: body.parent_restaurant_id,
    p_child_restaurant_ids: childIds || null,
  });

  if (error) {
    console.error('SQL function error:', error);
    
    if (error.message.includes('not found')) {
      return badRequest('Parent restaurant not found');
    }
    
    throw error;
  }

  if (!data || data.length === 0) {
    return badRequest('Failed to sync menu');
  }

  const result = data[0];

  // Post-operation actions (async)
  Promise.all([
    logAdminAction(
      supabase,
      user.id,
      'franchise.sync_menu',
      'restaurants',
      body.parent_restaurant_id,
      {
        children_updated: result.children_updated,
        dishes_synced: result.dishes_synced,
      }
    ),
    invalidateCache([
      `franchise:${body.parent_restaurant_id}:menu`,
      ...(childIds || []).map(id => `restaurant:${id}:menu`),
    ]),
    sendNotification(
      'slack',
      `🔄 Full menu sync: ${result.dishes_synced} dishes synced to ${result.children_updated} locations`,
      {
        parent_id: body.parent_restaurant_id,
        children_updated: result.children_updated,
        dishes_synced: result.dishes_synced,
        updated_by: user.email,
      }
    ),
  ]).catch(console.error);

  return successResponse(
    {
      parent_restaurant_id: body.parent_restaurant_id,
      children_updated: result.children_updated,
      dishes_synced: result.dishes_synced,
    },
    `Menu synced to ${result.children_updated} franchise locations`
  );
}












