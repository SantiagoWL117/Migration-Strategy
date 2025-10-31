import { createClient } from 'jsr:@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

interface CreateAdminRequest {
  email: string;
  password: string;
  first_name: string;
  last_name: string;
  role_id?: number;
  restaurant_ids?: number[];
  mfa_enabled?: boolean;
}

interface CreateAdminResponse {
  success: boolean;
  admin_user_id?: number;
  auth_user_id?: string;
  email?: string;
  restaurants_assigned?: number;
  error?: string;
  details?: string;
}

interface PasswordValidationResult {
  isValid: boolean;
  errors: string[];
  strength?: 'weak' | 'medium' | 'strong';
}

// Common weak passwords to reject
const COMMON_PASSWORDS = [
  'password', 'password123', '12345678', 'qwerty', 'abc123',
  'monkey', '1234567', 'letmein', 'trustno1', 'dragon',
  'baseball', 'iloveyou', 'master', 'sunshine', 'ashley',
  'bailey', 'passw0rd', 'shadow', '123123', '654321',
  'superman', 'qazwsx', 'michael', 'football', 'welcome',
  'admin', 'adminpass', 'admin123', 'root', 'test123'
];

/**
 * Logs an admin audit event to the database
 * @param supabaseClient - Supabase admin client
 * @param performedBy - Admin who performed the action
 * @param action - Type of action performed
 * @param targetAdminId - ID of the affected admin (optional)
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

/**
 * Validates password strength with comprehensive security requirements
 * @param password - Password to validate
 * @returns Validation result with isValid flag and error messages
 */
function validatePasswordStrength(password: string): PasswordValidationResult {
  const errors: string[] = [];

  // Minimum length check
  if (password.length < 8) {
    errors.push('Password must be at least 8 characters long');
  }

  // Maximum length check (reasonable limit)
  if (password.length > 128) {
    errors.push('Password must be less than 128 characters');
  }

  // Uppercase letter check
  if (!/[A-Z]/.test(password)) {
    errors.push('Password must contain at least one uppercase letter (A-Z)');
  }

  // Lowercase letter check
  if (!/[a-z]/.test(password)) {
    errors.push('Password must contain at least one lowercase letter (a-z)');
  }

  // Number check
  if (!/[0-9]/.test(password)) {
    errors.push('Password must contain at least one number (0-9)');
  }

  // Special character check
  if (!/[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(password)) {
    errors.push('Password must contain at least one special character (!@#$%^&* etc.)');
  }

  // Check against common passwords (case-insensitive)
  const lowerPassword = password.toLowerCase();
  if (COMMON_PASSWORDS.includes(lowerPassword)) {
    errors.push('Password is too common. Please choose a more unique password');
  }

  // Check for sequential characters (e.g., "123456", "abcdef")
  const hasSequential = /(?:abc|bcd|cde|def|efg|fgh|ghi|hij|ijk|jkl|klm|lmn|mno|nop|opq|pqr|qrs|rst|stu|tuv|uvw|vwx|wxy|xyz|012|123|234|345|456|567|678|789)/i.test(password);
  if (hasSequential) {
    errors.push('Password should not contain sequential characters (e.g., "123" or "abc")');
  }

  // Check for repeated characters (e.g., "aaa", "111")
  const hasRepeated = /(.)\1{2,}/.test(password);
  if (hasRepeated) {
    errors.push('Password should not contain repeated characters (e.g., "aaa" or "111")');
  }

  // Calculate strength based on criteria met
  let strength: 'weak' | 'medium' | 'strong' = 'weak';
  if (errors.length === 0) {
    const criteriaCount = [
      password.length >= 12,
      /[A-Z]/.test(password) && /[a-z]/.test(password),
      /[0-9]/.test(password),
      /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(password),
      password.length >= 16
    ].filter(Boolean).length;

    if (criteriaCount >= 4) {
      strength = 'strong';
    } else if (criteriaCount >= 2) {
      strength = 'medium';
    }
  }

  return {
    isValid: errors.length === 0,
    errors,
    strength: errors.length === 0 ? strength : undefined
  };
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get('Authorization');

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return new Response(
        JSON.stringify({ success: false, error: 'Missing authorization header' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
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
        JSON.stringify({ success: false, error: 'Invalid token' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const callingUserId = user.id;
    console.log(`Calling user: ${callingUserId}`);

    // Check Super Admin role
    const { data: adminUser, error: adminCheckError } = await supabaseAdmin
      .schema('menuca_v3')
      .from('admin_users')
      .select('id, email, role_id, status')
      .eq('auth_user_id', callingUserId)
      .single();

    if (adminCheckError || !adminUser) {
      return new Response(
        JSON.stringify({ success: false, error: 'User is not an admin' }),
        { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    if (adminUser.status !== 'active') {
      return new Response(
        JSON.stringify({ success: false, error: 'Admin account not active' }),
        { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    if (adminUser.role_id !== 1) {
      return new Response(
        JSON.stringify({ success: false, error: 'Super Admin role required' }),
        { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    console.log(`✅ Super Admin validated: ${adminUser.email}`);

    // Parse request body
    const body: CreateAdminRequest = await req.json();
    const { email, password, first_name, last_name, role_id, restaurant_ids = [], mfa_enabled = false } = body;

    // Validate required fields
    if (!email || !password || !first_name || !last_name) {
      return new Response(
        JSON.stringify({ success: false, error: 'Missing required fields' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return new Response(
        JSON.stringify({ success: false, error: 'Invalid email format' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // Enhanced password validation
    const passwordValidation = validatePasswordStrength(password);
    if (!passwordValidation.isValid) {
      // Log failed creation attempt
      await logAuditEvent(
        supabaseAdmin,
        { id: adminUser.id, email: adminUser.email },
        'failed_create',
        null,
        email,
        { reason: 'weak_password', validation_errors: passwordValidation.errors },
        false,
        'Password does not meet security requirements'
      );

      return new Response(
        JSON.stringify({
          success: false,
          error: 'Password does not meet security requirements',
          details: passwordValidation.errors.join('; ')
        }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    console.log(`Creating admin user: ${email}`);

    // STEP 1: Create auth user
    const { data: authUser, error: authError } = await supabaseAdmin.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
      user_metadata: {
        first_name,
        last_name,
        is_admin: true,
        created_via: 'admin-portal',
        created_at: new Date().toISOString()
      }
    });

    if (authError) {
      console.error('Failed to create auth user:', authError);

      // Log failed creation attempt
      await logAuditEvent(
        supabaseAdmin,
        { id: adminUser.id, email: adminUser.email },
        'failed_create',
        null,
        email,
        { reason: 'auth_user_creation_failed', error_code: authError.code },
        false,
        authError.message
      );

      return new Response(
        JSON.stringify({ success: false, error: 'Failed to create auth user', details: authError.message }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const newAuthUserId = authUser.user!.id;
    console.log(`✅ Auth user created: ${newAuthUserId}`);

    // STEP 2: Create admin_users record
    const insertData: Record<string, unknown> = {
      auth_user_id: newAuthUserId,
      email,
      first_name,
      last_name,
      mfa_enabled,
      status: 'active'
    };

    if (role_id !== undefined) {
      insertData.role_id = role_id;
    }

    const { data: newAdminUser, error: adminError } = await supabaseAdmin
      .schema('menuca_v3')
      .from('admin_users')
      .insert(insertData)
      .select('id')
      .single();

    if (adminError) {
      console.error('Failed to create admin user:', adminError);

      // Log failed creation attempt
      await logAuditEvent(
        supabaseAdmin,
        { id: adminUser.id, email: adminUser.email },
        'failed_create',
        null,
        email,
        {
          reason: 'admin_record_creation_failed',
          error_code: adminError.code,
          auth_user_id: newAuthUserId,
          rollback: 'auth_user_deleted'
        },
        false,
        adminError.message
      );

      await supabaseAdmin.auth.admin.deleteUser(newAuthUserId);
      return new Response(
        JSON.stringify({ success: false, error: 'Failed to create admin user record', details: adminError.message }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const adminUserId = newAdminUser.id;
    console.log(`✅ Admin user created: ${adminUserId}`);

    // STEP 3: Assign restaurants
    let assignedCount = 0;
    if (restaurant_ids && restaurant_ids.length > 0) {
      const { data: restaurants, error: restaurantError } = await supabaseAdmin
        .schema('menuca_v3')
        .from('restaurants')
        .select('id, name')
        .in('id', restaurant_ids)
        .is('deleted_at', null);

      if (!restaurantError && restaurants && restaurants.length > 0) {
        const validRestaurantIds = restaurants.map(r => r.id);
        const assignments = validRestaurantIds.map(restaurantId => ({
          admin_user_id: adminUserId,
          restaurant_id: restaurantId
        }));

        const { error: assignError } = await supabaseAdmin
          .schema('menuca_v3')
          .from('admin_user_restaurants')
          .insert(assignments);

        if (!assignError) {
          assignedCount = validRestaurantIds.length;
          console.log(`✅ Assigned ${assignedCount} restaurants`);
        }
      }
    }

    // Log successful user creation to audit log
    await logAuditEvent(
      supabaseAdmin,
      { id: adminUser.id, email: adminUser.email },
      'create_user',
      adminUserId,
      email,
      {
        role_id: role_id || 'default',
        restaurants_assigned: assignedCount,
        restaurant_ids: restaurant_ids,
        mfa_enabled
      },
      true
    );

    console.log(`✅ Audit log entry created for user creation`);

    // Success response
    return new Response(
      JSON.stringify({
        success: true,
        admin_user_id: adminUserId,
        auth_user_id: newAuthUserId,
        email,
        restaurants_assigned: assignedCount,
        message: `Admin user created successfully${assignedCount > 0 ? ` with ${assignedCount} restaurant(s)` : ''}`
      } as CreateAdminResponse),
      { status: 201, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );

  } catch (error) {
    console.error('Fatal error:', error);
    return new Response(
      JSON.stringify({
        success: false,
        error: 'Internal server error',
        details: error instanceof Error ? error.message : 'Unknown error'
      } as CreateAdminResponse),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }
});
