/**
 * Task 1.2: Migrate Admin Users to Supabase Auth
 * 
 * Purpose: Bulk create auth.users entries for all existing menuca_v3.admin_users
 * and link them via auth_user_id column.
 * 
 * Usage:
 *   deno run --allow-net --allow-env task_1.2_migrate_admins_to_auth.ts
 * 
 * Environment Variables Required:
 *   SUPABASE_URL
 *   SUPABASE_SERVICE_ROLE_KEY
 */

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// Configuration
const BATCH_SIZE = 50;
const PARALLEL_BATCH = 5; // Process 5 admins simultaneously
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SUPABASE_SERVICE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

if (!SUPABASE_URL || !SUPABASE_SERVICE_KEY) {
  console.error('❌ Missing required environment variables');
  console.error('   Required: SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY');
  Deno.exit(1);
}

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
});

/**
 * Generate a secure random password for force-reset flow
 */
function generateRandomPassword(): string {
  const length = 32;
  const charset = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*';
  let password = '';
  const array = new Uint8Array(length);
  crypto.getRandomValues(array);
  for (let i = 0; i < length; i++) {
    password += charset[array[i] % charset.length];
  }
  return password;
}

/**
 * Fetch admin users without auth_user_id
 */
async function fetchUnmigratedAdmins(offset: number, limit: number) {
  const { data, error, count } = await supabase
    .schema('menuca_v3')
    .from('admin_users')
    .select('id, email, password_hash, created_at, first_name, last_name', { count: 'exact' })
    .is('auth_user_id', null)
    .order('id')
    .range(offset, offset + limit - 1);

  if (error) {
    console.error('❌ Error fetching admin users:', error);
    return { admins: [], total: 0 };
  }

  return { admins: data || [], total: count || 0 };
}

/**
 * Migrate a single admin to auth.users
 */
async function migrateAdmin(admin: any) {
  try {
    // Create auth.users entry
    const { data: authUser, error: authError } = await supabase.auth.admin.createUser({
      email: admin.email,
      password: generateRandomPassword(), // Force password reset on first login
      email_confirm: true, // Auto-confirm admin emails
      user_metadata: {
        migrated_from_v1v2: true,
        original_admin_id: admin.id,
        original_created_at: admin.created_at,
        first_name: admin.first_name,
        last_name: admin.last_name,
        user_type: 'admin'
      }
    });

    if (authError) {
      // Check if user already exists in auth
      if (authError.message?.includes('User already registered')) {
        console.warn(`⚠️  Admin ${admin.email} already exists in auth.users - attempting to link`);
        
        // Try to find existing auth user by email
        const { data: existingAuthData } = await supabase.auth.admin.listUsers();
        const existingAuth = existingAuthData?.users?.find(u => u.email === admin.email);
        
        if (existingAuth) {
          // Link to existing auth user
          const { error: updateError } = await supabase
            .schema('menuca_v3')
            .from('admin_users')
            .update({ 
              auth_user_id: existingAuth.id,
              status: 'active'
            })
            .eq('id', admin.id);

          if (updateError) throw updateError;
          
          console.log(`✅ Linked existing auth user: ${admin.email}`);
          return { success: true, email: admin.email, action: 'linked' };
        }
      }
      
      throw authError;
    }

    if (!authUser.user) {
      throw new Error('No user returned from auth.admin.createUser');
    }

    // Link menuca_v3.admin_users to auth.users
    const { error: linkError } = await supabase
      .schema('menuca_v3')
      .from('admin_users')
      .update({ 
        auth_user_id: authUser.user.id,
        status: 'active'
      })
      .eq('id', admin.id);

    if (linkError) throw linkError;

    console.log(`✅ Migrated: ${admin.email} (ID: ${admin.id})`);
    return { success: true, email: admin.email, action: 'created' };

  } catch (error) {
    console.error(`❌ Failed to migrate ${admin.email}:`, error);
    return { success: false, email: admin.email, error: error.message };
  }
}

/**
 * Main migration function
 */
async function main() {
  console.log('🚀 Starting admin user migration to Supabase Auth...\n');

  // Get total count
  const { admins: initialBatch, total } = await fetchUnmigratedAdmins(0, 1);
  console.log(`📊 Total admin users to migrate: ${total}\n`);

  if (total === 0) {
    console.log('✅ No admin users to migrate. All are already linked to auth.users.');
    return;
  }

  let offset = 0;
  let totalMigrated = 0;
  let totalFailed = 0;
  let totalLinked = 0;
  const failedAdmins: any[] = [];

  // Process in batches
  while (offset < total) {
    console.log(`\n📦 Processing batch: ${offset + 1} to ${Math.min(offset + BATCH_SIZE, total)} of ${total}`);
    
    const { admins } = await fetchUnmigratedAdmins(offset, BATCH_SIZE);
    
    if (admins.length === 0) {
      break;
    }

    // Process admins in parallel chunks (5 at a time)
    for (let i = 0; i < admins.length; i += PARALLEL_BATCH) {
      const chunk = admins.slice(i, i + PARALLEL_BATCH);
      
      // Migrate chunk in parallel
      const results = await Promise.all(
        chunk.map(admin => migrateAdmin(admin))
      );
      
      // Count results
      for (const result of results) {
        if (result.success) {
          if (result.action === 'created') {
            totalMigrated++;
          } else if (result.action === 'linked') {
            totalLinked++;
          }
        } else {
          totalFailed++;
          failedAdmins.push(result);
        }
      }

      // Small delay between parallel chunks
      await new Promise(resolve => setTimeout(resolve, 10));
    }

    offset += BATCH_SIZE;
  }

  // Summary
  console.log('\n' + '='.repeat(60));
  console.log('📊 MIGRATION SUMMARY');
  console.log('='.repeat(60));
  console.log(`✅ Successfully created: ${totalMigrated}`);
  console.log(`🔗 Successfully linked:  ${totalLinked}`);
  console.log(`❌ Failed:               ${totalFailed}`);
  console.log(`📈 Total processed:      ${totalMigrated + totalLinked + totalFailed}`);
  
  if (failedAdmins.length > 0) {
    console.log('\n❌ Failed admin users:');
    failedAdmins.slice(0, 10).forEach(admin => {
      console.log(`   - ${admin.email}: ${admin.error}`);
    });
    if (failedAdmins.length > 10) {
      console.log(`   ... and ${failedAdmins.length - 10} more`);
    }
  }

  // Verification query
  console.log('\n' + '='.repeat(60));
  console.log('🔍 VERIFICATION');
  console.log('='.repeat(60));
  
  const { data: verificationData } = await supabase
    .schema('menuca_v3')
    .from('admin_users')
    .select('id, auth_user_id', { count: 'exact' });

  const totalAdmins = verificationData?.length || 0;
  const adminsWithAuth = verificationData?.filter(u => u.auth_user_id).length || 0;
  const adminsWithoutAuth = totalAdmins - adminsWithAuth;

  console.log(`Total admin users:        ${totalAdmins}`);
  console.log(`Admins with auth link:    ${adminsWithAuth} (${((adminsWithAuth/totalAdmins)*100).toFixed(2)}%)`);
  console.log(`Admins without auth link: ${adminsWithoutAuth}`);
  
  console.log('\n✅ Admin migration complete!\n');
}

// Run the migration
main().catch(error => {
  console.error('💥 Migration failed:', error);
  Deno.exit(1);
});

