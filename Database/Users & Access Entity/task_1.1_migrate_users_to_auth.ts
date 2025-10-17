/**
 * Task 1.1: Migrate Existing Users to Supabase Auth
 * 
 * Purpose: Bulk create auth.users entries for all existing menuca_v3.users
 * and link them via auth_user_id column.
 * 
 * Usage:
 *   deno run --allow-net --allow-env task_1.1_migrate_users_to_auth.ts
 * 
 * Environment Variables Required:
 *   SUPABASE_URL
 *   SUPABASE_SERVICE_ROLE_KEY
 */

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// Configuration
const BATCH_SIZE = 100;
const PARALLEL_BATCH = 5; // Process 5 users simultaneously
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
 * Fetch users without auth_user_id
 */
async function fetchUnmigratedUsers(offset: number, limit: number) {
  const { data, error, count } = await supabase
    .schema('menuca_v3')
    .from('users')
    .select('id, email, password_hash, created_at, has_email_verified', { count: 'exact' })
    .is('auth_user_id', null)
    .order('id')
    .range(offset, offset + limit - 1);

  if (error) {
    console.error('❌ Error fetching users:', error);
    return { users: [], total: 0 };
  }

  return { users: data || [], total: count || 0 };
}

/**
 * Migrate a single user to auth.users
 */
async function migrateUser(user: any) {
  try {
    // Create auth.users entry
    const { data: authUser, error: authError } = await supabase.auth.admin.createUser({
      email: user.email,
      password: generateRandomPassword(), // Force password reset on first login
      email_confirm: user.has_email_verified || false,
      user_metadata: {
        migrated_from_v1v2: true,
        original_user_id: user.id,
        original_created_at: user.created_at
      }
    });

    if (authError) {
      // Check if user already exists in auth
      if (authError.message?.includes('User already registered')) {
        console.warn(`⚠️  User ${user.email} already exists in auth.users - attempting to link`);
        
        // Try to find existing auth user by email
        const { data: existingAuthData } = await supabase.auth.admin.listUsers();
        const existingAuth = existingAuthData?.users?.find(u => u.email === user.email);
        
        if (existingAuth) {
          // Link to existing auth user
          const { error: updateError } = await supabase
            .schema('menuca_v3')
            .from('users')
            .update({ 
              auth_user_id: existingAuth.id,
              email_verified_at: existingAuth.email_confirmed_at || null
            })
            .eq('id', user.id);

          if (updateError) throw updateError;
          
          console.log(`✅ Linked existing auth user: ${user.email}`);
          return { success: true, email: user.email, action: 'linked' };
        }
      }
      
      throw authError;
    }

    if (!authUser.user) {
      throw new Error('No user returned from auth.admin.createUser');
    }

    // Link menuca_v3.users to auth.users
    const { error: linkError } = await supabase
      .schema('menuca_v3')
      .from('users')
      .update({ 
        auth_user_id: authUser.user.id,
        email_verified_at: authUser.user.email_confirmed_at || null,
        auth_provider: 'email'
      })
      .eq('id', user.id);

    if (linkError) throw linkError;

    console.log(`✅ Migrated: ${user.email} (ID: ${user.id})`);
    return { success: true, email: user.email, action: 'created' };

  } catch (error) {
    console.error(`❌ Failed to migrate ${user.email}:`, error);
    return { success: false, email: user.email, error: error.message };
  }
}

/**
 * Main migration function
 */
async function main() {
  console.log('🚀 Starting user migration to Supabase Auth...\n');

  // Get total count
  const { users: initialBatch, total } = await fetchUnmigratedUsers(0, 1);
  console.log(`📊 Total users to migrate: ${total}\n`);

  if (total === 0) {
    console.log('✅ No users to migrate. All users are already linked to auth.users.');
    return;
  }

  let offset = 0;
  let totalMigrated = 0;
  let totalFailed = 0;
  let totalLinked = 0;
  const failedUsers: any[] = [];

  // Process in batches
  while (offset < total) {
    console.log(`\n📦 Processing batch: ${offset + 1} to ${Math.min(offset + BATCH_SIZE, total)} of ${total}`);
    
    const { users } = await fetchUnmigratedUsers(offset, BATCH_SIZE);
    
    if (users.length === 0) {
      break;
    }

    // Process users in parallel chunks (5 at a time)
    for (let i = 0; i < users.length; i += PARALLEL_BATCH) {
      const chunk = users.slice(i, i + PARALLEL_BATCH);
      
      // Migrate chunk in parallel
      const results = await Promise.all(
        chunk.map(user => migrateUser(user))
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
          failedUsers.push(result);
        }
      }

      // Small delay between parallel chunks (10ms instead of 100ms)
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
  
  if (failedUsers.length > 0) {
    console.log('\n❌ Failed users:');
    failedUsers.slice(0, 10).forEach(user => {
      console.log(`   - ${user.email}: ${user.error}`);
    });
    if (failedUsers.length > 10) {
      console.log(`   ... and ${failedUsers.length - 10} more`);
    }
  }

  // Verification query
  console.log('\n' + '='.repeat(60));
  console.log('🔍 VERIFICATION');
  console.log('='.repeat(60));
  
  const { data: verificationData } = await supabase
    .schema('menuca_v3')
    .from('users')
    .select('id, auth_user_id', { count: 'exact' });

  const totalUsers = verificationData?.length || 0;
  const usersWithAuth = verificationData?.filter(u => u.auth_user_id).length || 0;
  const usersWithoutAuth = totalUsers - usersWithAuth;

  console.log(`Total users:              ${totalUsers}`);
  console.log(`Users with auth link:     ${usersWithAuth} (${((usersWithAuth/totalUsers)*100).toFixed(2)}%)`);
  console.log(`Users without auth link:  ${usersWithoutAuth}`);
  
  console.log('\n✅ Migration complete!\n');
}

// Run the migration
main().catch(error => {
  console.error('💥 Migration failed:', error);
  Deno.exit(1);
});

