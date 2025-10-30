'use client';

import { useRouter } from 'next/navigation';
import { Phone } from 'lucide-react';
import { GoogleSignInButton } from '@/components/google-signin-button';

interface QuickSignInPromptProps {
  message?: string;
  showGuestOption?: boolean;
  redirectTo?: string;
}

export function QuickSignInPrompt({
  message = 'Create an account to track your order!',
  showGuestOption = true,
  redirectTo
}: QuickSignInPromptProps) {
  const router = useRouter();

  const handleSignUp = () => {
    const url = redirectTo
      ? `/auth/signup-sms?redirect=${encodeURIComponent(redirectTo)}`
      : '/auth/signup-sms';
    router.push(url);
  };

  const handleSignIn = () => {
    const url = redirectTo
      ? `/auth/login-sms?redirect=${encodeURIComponent(redirectTo)}`
      : '/auth/login-sms';
    router.push(url);
  };

  return (
    <div className="bg-gradient-to-r from-red-50 to-orange-50 rounded-lg p-6 border border-red-100">
      <div className="flex items-start gap-4">
        {/* Icon */}
        <div className="flex-shrink-0">
          <div className="w-12 h-12 bg-red-100 rounded-full flex items-center justify-center">
            <Phone className="w-6 h-6 text-red-600" />
          </div>
        </div>

        {/* Content */}
        <div className="flex-1">
          <h3 className="text-lg font-semibold text-gray-900 mb-1">
            Quick Sign Up with Phone
          </h3>
          <p className="text-sm text-gray-600 mb-4">
            {message}
          </p>

          {/* Benefits */}
          <ul className="space-y-1 mb-4">
            <li className="text-sm text-gray-700 flex items-center gap-2">
              <svg className="w-4 h-4 text-green-500" fill="currentColor" viewBox="0 0 20 20">
                <path
                  fillRule="evenodd"
                  d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                  clipRule="evenodd"
                />
              </svg>
              Track your order in real-time
            </li>
            <li className="text-sm text-gray-700 flex items-center gap-2">
              <svg className="w-4 h-4 text-green-500" fill="currentColor" viewBox="0 0 20 20">
                <path
                  fillRule="evenodd"
                  d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                  clipRule="evenodd"
                />
              </svg>
              Save addresses & payment methods
            </li>
            <li className="text-sm text-gray-700 flex items-center gap-2">
              <svg className="w-4 h-4 text-green-500" fill="currentColor" viewBox="0 0 20 20">
                <path
                  fillRule="evenodd"
                  d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                  clipRule="evenodd"
                />
              </svg>
              View order history & reorder
            </li>
          </ul>

          {/* Action Buttons */}
          <div className="space-y-3">
            {/* Google Sign-In */}
            <GoogleSignInButton redirectTo={redirectTo} mode="signup" />

            {/* Divider */}
            <div className="relative">
              <div className="absolute inset-0 flex items-center">
                <div className="w-full border-t border-gray-300"></div>
              </div>
              <div className="relative flex justify-center text-xs">
                <span className="px-2 bg-gradient-to-r from-red-50 to-orange-50 text-gray-500">Or with phone</span>
              </div>
            </div>

            {/* Phone Sign-Up Button */}
            <button
              onClick={handleSignUp}
              className="w-full bg-red-600 text-white px-4 py-2 rounded-lg font-medium
                       hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-offset-2
                       transition-colors duration-200"
            >
              <div className="flex items-center justify-center gap-2">
                <Phone className="w-4 h-4" />
                <span>Sign Up with Phone (30 sec)</span>
              </div>
            </button>

            {/* Already have account */}
            <button
              onClick={handleSignIn}
              className="w-full text-sm text-red-600 hover:text-red-700 font-medium"
            >
              Already have an account? Sign in
            </button>
          </div>

          {showGuestOption && (
            <p className="text-xs text-gray-500 text-center mt-3">
              Or continue as guest (you can create an account later)
            </p>
          )}
        </div>
      </div>
    </div>
  );
}
