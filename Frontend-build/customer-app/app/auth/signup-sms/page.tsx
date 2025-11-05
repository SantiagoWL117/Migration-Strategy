'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { PhoneInput } from '@/components/phone-input';
import { OTPInput } from '@/components/otp-input';
import { GoogleSignInButton } from '@/components/google-signin-button';
import { createClient } from '@/lib/supabase/client';

type Step = 'phone' | 'verify' | 'profile';

export default function SignUpSMSPage() {
  const router = useRouter();
  const supabase = createClient();

  // Form state
  const [step, setStep] = useState<Step>('phone');
  const [phone, setPhone] = useState('');
  const [phoneE164, setPhoneE164] = useState('');
  const [isPhoneValid, setIsPhoneValid] = useState(false);
  const [otp, setOtp] = useState('');
  const [firstName, setFirstName] = useState('');
  const [lastName, setLastName] = useState('');

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
          shouldCreateUser: true
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
      setError(err.message || 'Failed to send verification code');
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
        // Check if profile already exists
        const { data: existingProfile } = await supabase
          .from('users')
          .select('id, first_name, last_name')
          .eq('auth_user_id', data.user.id)
          .single();

        if (existingProfile?.first_name && existingProfile?.last_name) {
          // Profile complete, redirect to home
          router.push('/');
        } else {
          // Need to complete profile
          setStep('profile');
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

  // Step 3: Complete profile
  const handleCompleteProfile = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!firstName.trim() || !lastName.trim()) {
      setError('Please enter your first and last name');
      return;
    }

    setLoading(true);
    setError('');

    try {
      const { data: { user } } = await supabase.auth.getUser();

      if (!user) throw new Error('No authenticated user');

      // Update profile in menuca_v3.users
      const { error: updateError } = await supabase
        .from('users')
        .update({
          first_name: firstName.trim(),
          last_name: lastName.trim(),
          phone: phoneE164
        })
        .eq('auth_user_id', user.id);

      if (updateError) throw updateError;

      // Success! Redirect to home
      router.push('/');

    } catch (err: any) {
      console.error('Profile update error:', err);
      setError(err.message || 'Failed to complete profile');
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
            Sign Up with Phone
          </h1>
          <p className="text-gray-600">
            {step === 'phone' && 'Enter your phone number to get started'}
            {step === 'verify' && 'Enter the verification code we sent you'}
            {step === 'profile' && 'Complete your profile'}
          </p>
        </div>

        {/* Error message */}
        {error && (
          <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-lg">
            <p className="text-sm text-red-600">{error}</p>
          </div>
        )}

        {/* Step 1: Phone input */}
        {step === 'phone' && (
          <div className="space-y-6">
            {/* Google Sign-In */}
            <GoogleSignInButton redirectTo="/" mode="signup" />

            {/* Divider */}
            <div className="relative">
              <div className="absolute inset-0 flex items-center">
                <div className="w-full border-t border-gray-300"></div>
              </div>
              <div className="relative flex justify-center text-sm">
                <span className="px-2 bg-white text-gray-500">Or sign up with phone</span>
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

            <div className="text-center">
              <button
                onClick={() => router.push('/auth/login-sms')}
                className="text-sm text-red-600 hover:text-red-700"
              >
                Already have an account? Sign in
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
              onClick={() => setStep('phone')}
              className="w-full text-gray-600 hover:text-gray-900"
            >
              ← Change phone number
            </button>
          </div>
        )}

        {/* Step 3: Profile completion */}
        {step === 'profile' && (
          <form onSubmit={handleCompleteProfile} className="space-y-6">
            <div>
              <label htmlFor="firstName" className="block text-sm font-medium text-gray-700 mb-2">
                First Name
              </label>
              <input
                id="firstName"
                type="text"
                value={firstName}
                onChange={(e) => setFirstName(e.target.value)}
                required
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-red-500 focus:border-transparent"
                placeholder="John"
              />
            </div>

            <div>
              <label htmlFor="lastName" className="block text-sm font-medium text-gray-700 mb-2">
                Last Name
              </label>
              <input
                id="lastName"
                type="text"
                value={lastName}
                onChange={(e) => setLastName(e.target.value)}
                required
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-red-500 focus:border-transparent"
                placeholder="Doe"
              />
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full bg-red-600 text-white py-3 px-4 rounded-lg font-medium
                       hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-offset-2
                       disabled:bg-gray-300 disabled:cursor-not-allowed
                       transition-colors duration-200"
            >
              {loading ? 'Completing...' : 'Complete Sign Up'}
            </button>
          </form>
        )}
      </div>
    </div>
  );
}
