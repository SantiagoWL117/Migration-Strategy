import { createClient } from 'jsr:@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

interface AssignRestaurantsRequest {
  admin_user_id: number;
  restaurant_ids: number[];
  action: 'add' | 'remove' | 'replace';
}

interface AssignRestaurantsResponse {
  success: boolean;
  action?: string;
  admin_user_id?: number;
  admin_email?: string;
  assignments_before?: number;
  assignments_after?: number;
  affected_count?: number;
  error?: string;
  details?: string;
}

/**
 * Logs an admin audit event to the database
 * @param supabaseClient - Supabase admin client
 * @param performedBy - Admin who performed the action
 * @param action - Type of action performed
 * @param targetAdminId - ID of the affected admin
 * @param targetEmail - Email of the affected admin
 * @param details - Additional details as JSON
 * @param success - Whether the action succeeded
 * @param errorMessage - Error message if action failed
 */
async function logAuditEvent(
  supabaseClient: any,
  performedBy: { id: number; email: string },
  action: string,
  targetAdminId: number | null,
  targetEmail: string,
  details: Record<string, any>,
  success: boolean,
  errorMessage?: string
): Promise<void> {
  try {
    const { error } = await supabaseClient
      .schema('menuca_v3')
      .from('admin_audit_log')
      .insert({
        performed_by_admin_id: performedBy.id,
        performed_by_email: performedBy.email,
        action,
        target_admin_id: targetAdminId,
        target_email: targetEmail,
        details,
        success,
        error_message: errorMessage
      });

    if (error) {
      console.error('Failed to log audit event:', error);
    }
  } catch (err) {
    console.error('Exception logging audit event:', err);
  }
}

Deno.serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // Verify JWT token and Super Admin role
    const authHeader = req.headers.get('Authorization');

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Missing authorization header',
          details: 'JWT token required in Authorization header'
        }),
        {
          status: 401,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    // Create Supabase admin client
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
      { auth: { autoRefreshToken: false, persistSession: false } }
    );

    // Verify JWT and get calling user
    const token = authHeader.substring(7);
    const { data: { user }, error: userError } = await supabaseAdmin.auth.getUser(token);

    if (userError || !user) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Invalid token',
          details: 'JWT token is invalid or expired'
        }),
        {
          status: 401,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    const callingUserId = user.id;

    // Check if calling user is a Super Admin
    const { data: callingAdmin, error: adminCheckError } = await supabaseAdmin
      .schema('menuca_v3')
      .from('admin_users')
      .select('id, email, role_id, status')
      .eq('auth_user_id', callingUserId)
      .single();

    if (adminCheckError || !callingAdmin) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'User is not an admin',
          details: 'Only admin users can manage restaurant assignments'
        }),
        {
          status: 403,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    if (callingAdmin.status !== 'active') {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Admin account not active',
          details: 'Your admin account must be active to perform this action'
        }),
        {
          status: 403,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    if (callingAdmin.role_id !== 1) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Super Admin role required',
          details: 'Only Super Admins can manage restaurant assignments'
        }),
        {
          status: 403,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    // Parse request body
    const body: AssignRestaurantsRequest = await req.json();
    const { admin_user_id, restaurant_ids, action } = body;

    // Validate required fields
    if (!admin_user_id || !restaurant_ids || !action) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Missing required fields',
          details: 'admin_user_id, restaurant_ids, and action are required'
        }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    // Validate action
    if (!['add', 'remove', 'replace'].includes(action)) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Invalid action',
          details: 'action must be one of: add, remove, replace'
        }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    // Validate restaurant_ids is an array
    if (!Array.isArray(restaurant_ids) || restaurant_ids.length === 0) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Invalid restaurant_ids',
          details: 'restaurant_ids must be a non-empty array of numbers'
        }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    console.log(`${action.toUpperCase()} restaurants for admin ${admin_user_id}`);

    // STEP 1: Validate admin exists and get current assignments count
    const { data: admin, error: adminError } = await supabaseAdmin
      .schema('menuca_v3')
      .from('admin_users')
      .select('id, email, status')
      .eq('id', admin_user_id)
      .is('deleted_at', null)
      .single();

    if (adminError || !admin) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Admin user not found',
          details: `Admin user with id ${admin_user_id} does not exist or is deleted`
        }),
        {
          status: 404,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    if (admin.status !== 'active') {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Admin user is not active',
          details: `Admin user status is ${admin.status}`
        }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    // Get current assignments count
    const { count: assignmentsBefore } = await supabaseAdmin
      .schema('menuca_v3')
      .from('admin_user_restaurants')
      .select('id', { count: 'exact', head: true })
      .eq('admin_user_id', admin_user_id);

    console.log(`Admin ${admin.email} has ${assignmentsBefore || 0} assignments`);

    // STEP 2: Validate restaurants exist
    const { data: restaurants, error: restaurantsError } = await supabaseAdmin
      .schema('menuca_v3')
      .from('restaurants')
      .select('id, name, slug')
      .in('id', restaurant_ids)
      .is('deleted_at', null);

    if (restaurantsError) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Failed to validate restaurants',
          details: restaurantsError.message
        }),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    if (!restaurants || restaurants.length === 0) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'No valid restaurants found',
          details: `None of the provided restaurant IDs exist or all are deleted`
        }),
        {
          status: 404,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    if (restaurants.length !== restaurant_ids.length) {
      console.warn(`Some restaurants not found. Requested: ${restaurant_ids.length}, Found: ${restaurants.length}`);
    }

    const validRestaurantIds = restaurants.map(r => r.id);
    let affectedCount = 0;

    // STEP 3: Perform action
    if (action === 'remove') {
      // Remove specified restaurant assignments
      const { error: deleteError, count } = await supabaseAdmin
        .schema('menuca_v3')
        .from('admin_user_restaurants')
        .delete({ count: 'exact' })
        .eq('admin_user_id', admin_user_id)
        .in('restaurant_id', validRestaurantIds);

      if (deleteError) {
        return new Response(
          JSON.stringify({
            success: false,
            error: 'Failed to remove restaurant assignments',
            details: deleteError.message
          }),
          {
            status: 500,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' }
          }
        );
      }

      affectedCount = count || 0;
      console.log(`✅ Removed ${affectedCount} restaurant assignments`);

    } else if (action === 'replace') {
      // Remove ALL existing assignments first
      const { error: deleteError } = await supabaseAdmin
        .schema('menuca_v3')
        .from('admin_user_restaurants')
        .delete()
        .eq('admin_user_id', admin_user_id);

      if (deleteError) {
        return new Response(
          JSON.stringify({
            success: false,
            error: 'Failed to clear existing assignments',
            details: deleteError.message
          }),
          {
            status: 500,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' }
          }
        );
      }

      // Add new assignments
      const assignments = validRestaurantIds.map(rid => ({
        admin_user_id,
        restaurant_id: rid
      }));

      const { error: insertError, count } = await supabaseAdmin
        .schema('menuca_v3')
        .from('admin_user_restaurants')
        .insert(assignments, { count: 'exact' });

      if (insertError) {
        return new Response(
          JSON.stringify({
            success: false,
            error: 'Failed to create new assignments',
            details: insertError.message
          }),
          {
            status: 500,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' }
          }
        );
      }

      affectedCount = count || 0;
      console.log(`✅ Replaced all assignments with ${affectedCount} new ones`);

    } else if (action === 'add') {
      // Add new assignments (ignore duplicates)
      const assignments = validRestaurantIds.map(rid => ({
        admin_user_id,
        restaurant_id: rid
      }));

      const { error: insertError, count } = await supabaseAdmin
        .schema('menuca_v3')
        .from('admin_user_restaurants')
        .insert(assignments, { count: 'exact' })
        .select('id');

      if (insertError) {
        // Check if error is due to duplicates
        if (insertError.code === '23505') {
          console.log('⚠️  Some assignments already exist (duplicates ignored)');
        } else {
          return new Response(
            JSON.stringify({
              success: false,
              error: 'Failed to add restaurant assignments',
              details: insertError.message
            }),
            {
              status: 500,
              headers: { ...corsHeaders, 'Content-Type': 'application/json' }
            }
          );
        }
      }

      affectedCount = count || 0;
      console.log(`✅ Added ${affectedCount} new restaurant assignments`);
    }

    // Get final assignments count
    const { count: assignmentsAfter } = await supabaseAdmin
      .schema('menuca_v3')
      .from('admin_user_restaurants')
      .select('id', { count: 'exact', head: true })
      .eq('admin_user_id', admin_user_id);

    // Log successful restaurant assignment change to audit log
    const auditAction = action === 'add' ? 'assign_restaurants' : action === 'remove' ? 'remove_restaurants' : 'replace_restaurants';
    await logAuditEvent(
      supabaseAdmin,
      { id: callingAdmin.id, email: callingAdmin.email },
      auditAction,
      admin_user_id,
      admin.email,
      {
        action,
        restaurant_ids: validRestaurantIds,
        assignments_before: assignmentsBefore || 0,
        assignments_after: assignmentsAfter || 0,
        affected_count: affectedCount
      },
      true
    );

    console.log(`✅ Audit log entry created for restaurant assignment ${action}`);

    // Success response
    return new Response(
      JSON.stringify({
        success: true,
        action,
        admin_user_id,
        admin_email: admin.email,
        assignments_before: assignmentsBefore || 0,
        assignments_after: assignmentsAfter || 0,
        affected_count: affectedCount,
        message: `Successfully ${action}ed ${affectedCount} restaurant assignment(s) for ${admin.email}`
      } as AssignRestaurantsResponse),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    );

  } catch (error) {
    console.error('Fatal error:', error);
    return new Response(
      JSON.stringify({
        success: false,
        error: 'Internal server error',
        details: error instanceof Error ? error.message : 'Unknown error'
      } as AssignRestaurantsResponse),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    );
  }
});
