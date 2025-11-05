'use client';

import { useState, useRef, useEffect, KeyboardEvent } from 'react';

interface OTPInputProps {
  length?: number;
  value: string;
  onChange: (value: string) => void;
  onComplete?: (value: string) => void;
  disabled?: boolean;
  autoFocus?: boolean;
}

export function OTPInput({
  length = 6,
  value,
  onChange,
  onComplete,
  disabled = false,
  autoFocus = true
}: OTPInputProps) {
  const [otp, setOtp] = useState<string[]>(Array(length).fill(''));
  const inputRefs = useRef<(HTMLInputElement | null)[]>([]);

  // Initialize refs array
  useEffect(() => {
    inputRefs.current = inputRefs.current.slice(0, length);
  }, [length]);

  // Sync external value with internal state
  useEffect(() => {
    if (value.length <= length) {
      const newOtp = value.split('').concat(Array(length - value.length).fill(''));
      setOtp(newOtp);
    }
  }, [value, length]);

  // Auto-focus first input
  useEffect(() => {
    if (autoFocus && inputRefs.current[0]) {
      inputRefs.current[0].focus();
    }
  }, [autoFocus]);

  const handleChange = (index: number, digit: string) => {
    // Only allow single digits
    if (!/^\d*$/.test(digit)) return;

    const newOtp = [...otp];
    newOtp[index] = digit.slice(-1); // Only take the last digit if multiple entered
    setOtp(newOtp);

    const otpString = newOtp.join('');
    onChange(otpString);

    // Move to next input if digit entered
    if (digit && index < length - 1) {
      inputRefs.current[index + 1]?.focus();
    }

    // Call onComplete if all digits filled
    if (otpString.length === length && !otpString.includes('')) {
      onComplete?.(otpString);
    }
  };

  const handleKeyDown = (index: number, e: KeyboardEvent<HTMLInputElement>) => {
    // Move to previous input on backspace if current is empty
    if (e.key === 'Backspace' && !otp[index] && index > 0) {
      inputRefs.current[index - 1]?.focus();
    }

    // Move forward on right arrow
    if (e.key === 'ArrowRight' && index < length - 1) {
      inputRefs.current[index + 1]?.focus();
    }

    // Move backward on left arrow
    if (e.key === 'ArrowLeft' && index > 0) {
      inputRefs.current[index - 1]?.focus();
    }
  };

  const handlePaste = (e: React.ClipboardEvent) => {
    e.preventDefault();
    const pastedData = e.clipboardData.getData('text/plain').replace(/\D/g, '').slice(0, length);
    const newOtp = pastedData.split('').concat(Array(length - pastedData.length).fill(''));
    setOtp(newOtp);
    onChange(pastedData);

    // Focus the next empty input or the last input
    const nextEmptyIndex = newOtp.findIndex(digit => !digit);
    const focusIndex = nextEmptyIndex === -1 ? length - 1 : nextEmptyIndex;
    inputRefs.current[focusIndex]?.focus();

    // Call onComplete if fully pasted
    if (pastedData.length === length) {
      onComplete?.(pastedData);
    }
  };

  const handleFocus = (index: number) => {
    // Select the content on focus for easy replacement
    inputRefs.current[index]?.select();
  };

  return (
    <div className="flex gap-2 justify-center">
      {otp.map((digit, index) => (
        <input
          key={index}
          ref={(el) => {
            inputRefs.current[index] = el;
          }}
          type="text"
          inputMode="numeric"
          pattern="\d*"
          maxLength={1}
          value={digit}
          onChange={(e) => handleChange(index, e.target.value)}
          onKeyDown={(e) => handleKeyDown(index, e)}
          onPaste={handlePaste}
          onFocus={() => handleFocus(index)}
          disabled={disabled}
          className={`
            w-12 h-14 text-center text-2xl font-semibold
            border-2 rounded-lg
            focus:outline-none focus:ring-2 focus:ring-red-500 focus:border-transparent
            ${digit ? 'border-red-500 bg-red-50' : 'border-gray-300'}
            ${disabled ? 'bg-gray-100 cursor-not-allowed' : 'bg-white'}
            transition-all duration-200
          `}
          aria-label={`Digit ${index + 1}`}
        />
      ))}
    </div>
  );
}
