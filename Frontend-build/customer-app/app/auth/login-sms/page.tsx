'use client';

import { Suspense, useState } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { PhoneInput } from '@/components/phone-input';
import { OTPInput } from '@/components/otp-input';
import { GoogleSignInButton } from '@/components/google-signin-button';
import { createClient } from '@/lib/supabase/client';

type Step = 'phone' | 'verify';

function LoginSMSContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const redirectTo = searchParams.get('redirect') || '/';
  const supabase = createClient();

  // Form state
  const [step, setStep] = useState<Step>('phone');
  const [phone, setPhone] = useState('');
  const [phoneE164, setPhoneE164] = useState('');
  const [isPhoneValid, setIsPhoneValid] = useState(false);
  const [otp, setOtp] = useState('');

  // UI state
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [resendTimer, setResendTimer] = useState(0);

  // Handle phone validation
  const handlePhoneValidChange = (valid: boolean, e164: string) => {
    setIsPhoneValid(valid);
    if (valid) {
      setPhoneE164(e164);
    }
  };

  // Step 1: Send OTP to phone
  const handleSendOTP = async () => {
    if (!isPhoneValid || !phoneE164) {
      setError('Please enter a valid phone number');
      return;
    }

    setLoading(true);
    setError('');

    try {
      const { error } = await supabase.auth.signInWithOtp({
        phone: phoneE164,
        options: {
          shouldCreateUser: false // Don't create new accounts on login
        }
      });

      if (error) throw error;

      setStep('verify');
      setResendTimer(60); // Start 60 second cooldown

      // Countdown timer
      const interval = setInterval(() => {
        setResendTimer((prev) => {
          if (prev <= 1) {
            clearInterval(interval);
            return 0;
          }
          return prev - 1;
        });
      }, 1000);

    } catch (err: any) {
      console.error('Send OTP error:', err);

      // Check if account doesn't exist
      if (err.message?.includes('User not found')) {
        setError('No account found with this phone number. Please sign up first.');
      } else {
        setError(err.message || 'Failed to send verification code');
      }
    } finally {
      setLoading(false);
    }
  };

  // Step 2: Verify OTP
  const handleVerifyOTP = async (code: string) => {
    if (code.length !== 6) return;

    setLoading(true);
    setError('');

    try {
      const { data, error } = await supabase.auth.verifyOtp({
        phone: phoneE164,
        token: code,
        type: 'sms'
      });

      if (error) throw error;

      if (data.user) {
        // Verify user profile exists
        const { data: profile } = await supabase
          .from('users')
          .select('id, first_name, last_name')
          .eq('auth_user_id', data.user.id)
          .single();

        if (profile) {
          // Successful login, redirect
          router.push(redirectTo);
        } else {
          // Profile doesn't exist (shouldn't happen, but handle gracefully)
          setError('Account setup incomplete. Please contact support.');
        }
      }

    } catch (err: any) {
      console.error('Verify OTP error:', err);
      setError(err.message || 'Invalid verification code');
      setOtp(''); // Clear OTP for retry
    } finally {
      setLoading(false);
    }
  };

  // Resend OTP
  const handleResendOTP = async () => {
    if (resendTimer > 0) return;
    await handleSendOTP();
  };

  return (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center px-4">
      <div className="max-w-md w-full bg-white rounded-lg shadow-lg p-8">
        {/* Header */}
        <div className="text-center mb-8">
          <h1 className="text-3xl font-bold text-gray-900 mb-2">
            Sign In with Phone
          </h1>
          <p className="text-gray-600">
            {step === 'phone' && 'Enter your phone number to receive a verification code'}
            {step === 'verify' && 'Enter the verification code we sent you'}
          </p>
        </div>

        {/* Error message */}
        {error && (
          <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-lg">
            <p className="text-sm text-red-600">{error}</p>
            {error.includes('No account found') && (
              <button
                onClick={() => router.push('/auth/signup-sms')}
                className="mt-2 text-sm text-red-700 underline hover:text-red-800"
              >
                Create an account
              </button>
            )}
          </div>
        )}

        {/* Step 1: Phone input */}
        {step === 'phone' && (
          <div className="space-y-6">
            {/* Google Sign-In */}
            <GoogleSignInButton redirectTo={redirectTo} mode="signin" />

            {/* Divider */}
            <div className="relative">
              <div className="absolute inset-0 flex items-center">
                <div className="w-full border-t border-gray-300"></div>
              </div>
              <div className="relative flex justify-center text-sm">
                <span className="px-2 bg-white text-gray-500">Or continue with phone</span>
              </div>
            </div>

            {/* Phone Input */}
            <div>
              <label htmlFor="phone" className="block text-sm font-medium text-gray-700 mb-2">
                Phone Number
              </label>
              <PhoneInput
                value={phone}
                onChange={setPhone}
                onValidChange={handlePhoneValidChange}
                placeholder="(555) 555-1234"
                required
                autoFocus
              />
            </div>

            <button
              onClick={handleSendOTP}
              disabled={!isPhoneValid || loading}
              className="w-full bg-red-600 text-white py-3 px-4 rounded-lg font-medium
                       hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-offset-2
                       disabled:bg-gray-300 disabled:cursor-not-allowed
                       transition-colors duration-200"
            >
              {loading ? 'Sending...' : 'Send Verification Code'}
            </button>

            <div className="text-center space-y-2">
              <button
                onClick={() => router.push('/auth/signup-sms')}
                className="text-sm text-red-600 hover:text-red-700 block w-full"
              >
                Don't have an account? Sign up
              </button>
              <button
                onClick={() => router.push('/')}
                className="text-sm text-gray-600 hover:text-gray-900 block w-full"
              >
                Continue as guest
              </button>
            </div>
          </div>
        )}

        {/* Step 2: OTP verification */}
        {step === 'verify' && (
          <div className="space-y-6">
            <div>
              <p className="text-sm text-gray-600 text-center mb-6">
                Sent to {phone}
              </p>
              <OTPInput
                value={otp}
                onChange={setOtp}
                onComplete={handleVerifyOTP}
                disabled={loading}
              />
            </div>

            {loading && (
              <div className="text-center">
                <p className="text-sm text-gray-600">Verifying...</p>
              </div>
            )}

            <div className="text-center">
              <button
                onClick={handleResendOTP}
                disabled={resendTimer > 0}
                className="text-sm text-red-600 hover:text-red-700 disabled:text-gray-400 disabled:cursor-not-allowed"
              >
                {resendTimer > 0
                  ? `Resend code in ${resendTimer}s`
                  : 'Resend verification code'}
              </button>
            </div>

            <button
              onClick={() => {
                setStep('phone');
                setOtp('');
                setError('');
              }}
              className="w-full text-center text-gray-600 hover:text-gray-900 py-2"
            >
              ← Change phone number
            </button>
          </div>
        )}
      </div>
    </div>
  );
}

export default function LoginSMSPage() {
  return (
    <Suspense fallback={<div className="min-h-screen flex items-center justify-center">Loading...</div>}>
      <LoginSMSContent />
    </Suspense>
  );
}
