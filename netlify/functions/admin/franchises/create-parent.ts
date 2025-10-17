/**
 * Create Franchise Parent - Edge Function
 * 
 * Endpoint: POST /api/admin/franchises/create-parent
 * Auth: Required (Admin only)
 * 
 * Wraps the SQL function menuca_v3.create_franchise_parent()
 * with authentication, authorization, audit logging, and cache invalidation.
 */

import type { CreateFranchiseParentRequest } from '../../shared/types';
import { requirePermission } from '../../shared/auth';
import {
  handleOptions,
  created,
  badRequest,
  unauthorized,
  forbidden,
  internalError,
} from '../../shared/response';
import {
  validateRequired,
  validateRestaurantName,
  validatePositiveInteger,
  sanitizeString,
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
      user = await requirePermission(req, 'franchise.create');
    } catch (error: any) {
      if (error.message.includes('Authentication')) {
        return unauthorized();
      }
      return forbidden(error.message);
    }

    // 2. Parse and validate request body
    let body: CreateFranchiseParentRequest;
    try {
      body = await req.json();
    } catch (error) {
      return badRequest('Invalid JSON body');
    }

    // 3. Input validation
    const requiredFields = validateRequired(body, [
      'name',
      'franchise_brand_name',
      'city_id',
      'province_id',
    ]);
    if (!requiredFields.valid) {
      return badRequest(requiredFields.error!, requiredFields.errors);
    }

    const nameValidation = validateRestaurantName(body.name);
    if (!nameValidation.valid) {
      return badRequest(nameValidation.error!);
    }

    if (!validatePositiveInteger(body.city_id)) {
      return badRequest('Invalid city_id');
    }

    if (!validatePositiveInteger(body.province_id)) {
      return badRequest('Invalid province_id');
    }

    // Sanitize inputs
    const sanitizedName = sanitizeString(body.name);
    const sanitizedBrandName = sanitizeString(body.franchise_brand_name);

    // 4. Initialize Supabase client (admin mode)
    const supabase = createAdminClient();

    // 5. Call SQL function (atomic operation)
    const { data, error } = await supabase.rpc('create_franchise_parent', {
      p_name: sanitizedName,
      p_franchise_brand_name: sanitizedBrandName,
      p_city_id: body.city_id,
      p_province_id: body.province_id,
      p_timezone: body.timezone || 'America/Toronto',
      p_created_by: body.created_by || null,
    });

    if (error) {
      console.error('SQL function error:', error);
      
      // Handle specific SQL errors
      if (error.message.includes('already exists')) {
        return badRequest(`Franchise brand name already exists: ${sanitizedBrandName}`);
      }
      
      if (error.message.includes('city') || error.message.includes('province')) {
        return badRequest('Invalid city_id or province_id');
      }
      
      throw error;
    }

    if (!data || data.length === 0) {
      return badRequest('Failed to create franchise parent');
    }

    const result = data[0];

    // 6. Post-creation actions (async, don't block response)
    Promise.all([
      // Log admin action
      logAdminAction(
        supabase,
        user.id,
        'franchise.create',
        'restaurants',
        result.parent_id,
        {
          name: sanitizedName,
          brand_name: sanitizedBrandName,
          city_id: body.city_id,
          province_id: body.province_id,
        }
      ),

      // Invalidate franchise list cache
      invalidateCache(['franchises', 'franchises:list', 'restaurants:franchises']),

      // Send notification
      sendNotification(
        'slack',
        `🏢 New franchise parent created: ${sanitizedBrandName}`,
        {
          parent_id: result.parent_id,
          brand_name: sanitizedBrandName,
          created_by: user.email,
        }
      ),
    ]).catch(error => {
      console.error('Post-creation actions failed:', error);
      // Don't block response for non-critical errors
    });

    // 7. Return success response
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
    console.error('Unexpected error:', error);
    return internalError(
      'Failed to create franchise parent',
      process.env.NODE_ENV === 'development' ? error.message : undefined
    );
  }
};












