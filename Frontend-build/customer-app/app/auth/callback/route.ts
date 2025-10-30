import { createClient } from '@/lib/supabase/server'
import { NextResponse } from 'next/server'
import { cookies } from 'next/headers'

export async function GET(request: Request) {
  const requestUrl = new URL(request.url)
  const code = requestUrl.searchParams.get('code')
  const redirect = requestUrl.searchParams.get('redirect') || '/'

  if (code) {
    const cookieStore = await cookies()
    const supabase = await createClient()

    // Exchange the code for a session
    const { data, error } = await supabase.auth.exchangeCodeForSession(code)

    if (error) {
      console.error('Auth callback error:', error)
      return NextResponse.redirect(new URL('/auth/login-sms?error=oauth_error', requestUrl.origin))
    }

    if (data.user) {
      // Check if user profile exists in our users table
      const { data: profile } = await supabase
        .from('users')
        .select('id, first_name, last_name')
        .eq('auth_user_id', data.user.id)
        .single()

      if (!profile) {
        // User authenticated via Google but no profile exists
        // Create a basic profile from Google data
        const firstName = data.user.user_metadata?.given_name || data.user.user_metadata?.name?.split(' ')[0] || ''
        const lastName = data.user.user_metadata?.family_name || data.user.user_metadata?.name?.split(' ').slice(1).join(' ') || ''

        const { error: insertError } = await supabase
          .from('users')
          .insert({
            auth_user_id: data.user.id,
            email: data.user.email,
            first_name: firstName,
            last_name: lastName,
            phone_number: null
          })

        if (insertError) {
          console.error('Error creating user profile:', insertError)
        }
      }

      // Successful authentication - redirect to intended destination
      return NextResponse.redirect(new URL(redirect, requestUrl.origin))
    }
  }

  // No code present, redirect to login
  return NextResponse.redirect(new URL('/auth/login-sms', requestUrl.origin))
}
