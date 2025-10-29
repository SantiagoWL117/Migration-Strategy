'use client';

import { useState, useEffect } from 'react';
import { parsePhoneNumber, isValidPhoneNumber, CountryCode } from 'libphonenumber-js';

interface PhoneInputProps {
  value: string;
  onChange: (value: string) => void;
  onValidChange?: (isValid: boolean, e164: string) => void;
  defaultCountry?: CountryCode;
  placeholder?: string;
  className?: string;
  required?: boolean;
}

export function PhoneInput({
  value,
  onChange,
  onValidChange,
  defaultCountry = 'CA',
  placeholder = '(555) 555-1234',
  className = '',
  required = false
}: PhoneInputProps) {
  const [isValid, setIsValid] = useState(false);
  const [formattedValue, setFormattedValue] = useState(value);

  useEffect(() => {
    if (!value) {
      setIsValid(false);
      setFormattedValue('');
      return;
    }

    try {
      // Add country code if not present
      let phoneToValidate = value;
      if (!value.startsWith('+')) {
        phoneToValidate = `+1${value.replace(/\D/g, '')}`;
      }

      const valid = isValidPhoneNumber(phoneToValidate, defaultCountry);
      setIsValid(valid);

      if (valid) {
        const phoneNumber = parsePhoneNumber(phoneToValidate, defaultCountry);
        const e164Format = phoneNumber.number;
        onValidChange?.(true, e164Format);
        setFormattedValue(phoneNumber.formatNational());
      } else {
        onValidChange?.(false, '');
        setFormattedValue(value);
      }
    } catch (error) {
      setIsValid(false);
      onValidChange?.(false, '');
      setFormattedValue(value);
    }
  }, [value, defaultCountry, onValidChange]);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const input = e.target.value;
    // Only allow numbers, spaces, parentheses, hyphens, and plus
    const cleaned = input.replace(/[^\d\s()+-]/g, '');
    onChange(cleaned);
  };

  return (
    <div className="relative">
      <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
        <span className="text-gray-500 sm:text-sm">+1</span>
      </div>
      <input
        type="tel"
        value={formattedValue}
        onChange={handleChange}
        placeholder={placeholder}
        required={required}
        className={`
          block w-full pl-10 pr-3 py-2
          border rounded-lg
          ${isValid && value ? 'border-green-500 focus:ring-green-500' : 'border-gray-300'}
          ${!isValid && value ? 'border-red-500 focus:ring-red-500' : ''}
          focus:outline-none focus:ring-2 focus:border-transparent
          ${className}
        `}
        aria-label="Phone number"
        aria-invalid={!isValid && value.length > 0}
      />
      {value && (
        <div className="absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none">
          {isValid ? (
            <svg className="h-5 w-5 text-green-500" fill="currentColor" viewBox="0 0 20 20">
              <path
                fillRule="evenodd"
                d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                clipRule="evenodd"
              />
            </svg>
          ) : (
            <svg className="h-5 w-5 text-red-500" fill="currentColor" viewBox="0 0 20 20">
              <path
                fillRule="evenodd"
                d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z"
                clipRule="evenodd"
              />
            </svg>
          )}
        </div>
      )}
    </div>
  );
}
