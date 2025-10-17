/**
 * Create Restaurant with Cuisine - Edge Function
 * 
 * Endpoint: POST /api/admin/restaurants/create-with-cuisine
 * Auth: Required (Admin only)
 * 
 * Wraps the SQL function menuca_v3.create_restaurant_with_cuisine()
 * with authentication, authorization, audit logging, and cache invalidation.
 */

import type { CreateRestaurantRequest } from '../../shared/types';
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
  validateRestaurantStatus,
  validateTimezone,
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
      user = await requirePermission(req, 'restaurant.create');
    } catch (error) {
      if (error.message.includes('Authentication')) {
        return unauthorized();
      }
      return forbidden(error.message);
    }

    // 2. Parse and validate request body
    let body: CreateRestaurantRequest;
    try {
      body = await req.json();
    } catch (error) {
      return badRequest('Invalid JSON body');
    }

    // 3. Input validation
    const requiredFields = validateRequired(body, [
      'name',
      'status',
      'timezone',
      'cuisine_slug',
    ]);
    if (!requiredFields.valid) {
      return badRequest(requiredFields.error!, requiredFields.errors);
    }

    const nameValidation = validateRestaurantName(body.name);
    if (!nameValidation.valid) {
      return badRequest(nameValidation.error!);
    }

    if (!validateRestaurantStatus(body.status)) {
      return badRequest('Invalid restaurant status');
    }

    if (!validateTimezone(body.timezone)) {
      return badRequest('Invalid timezone');
    }

    // Sanitize inputs
    const sanitizedName = sanitizeString(body.name);
    const sanitizedCuisineSlug = sanitizeString(body.cuisine_slug);

    // 4. Initialize Supabase client (admin mode)
    const supabase = createAdminClient();

    // 5. Call SQL function (atomic operation)
    const { data, error } = await supabase.rpc('create_restaurant_with_cuisine', {
      p_name: sanitizedName,
      p_status: body.status,
      p_timezone: body.timezone,
      p_cuisine_name: sanitizedCuisineSlug,
      p_created_by: body.created_by || null,
    });

    if (error) {
      console.error('SQL function error:', error);
      
      // Handle specific SQL errors
      if (error.message.includes('not found')) {
        return badRequest(`Cuisine not found: ${sanitizedCuisineSlug}`);
      }
      
      throw error;
    }

    if (!data || !data[0]?.success) {
      return badRequest(data?.[0]?.message || 'Failed to create restaurant');
    }

    const result = data[0];

    // 6. Post-creation actions (async, don't block response)
    Promise.all([
      // Log admin action
      logAdminAction(
        supabase,
        user.id,
        'restaurant.create',
        'restaurant',
        result.restaurant_id,
        {
          name: sanitizedName,
          cuisine: result.cuisine_assigned,
          status: body.status,
        }
      ),

      // Invalidate restaurant list cache
      invalidateCache(['restaurants', 'restaurants:active']),

      // Send notification
      sendNotification(
        'slack',
        `🏪 New restaurant created: ${sanitizedName} (${result.cuisine_assigned})`,
        {
          restaurant_id: result.restaurant_id,
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
        restaurant_id: result.restaurant_id,
        name: result.restaurant_name,
        cuisine: result.cuisine_assigned,
        status: body.status,
        timezone: body.timezone,
      },
      'Restaurant created successfully'
    );

  } catch (error) {
    console.error('Unexpected error:', error);
    return internalError(
      'Failed to create restaurant',
      process.env.NODE_ENV === 'development' ? error.message : undefined
    );
  }
};


