// HTTP Response utilities for Supabase Edge Functions

import { corsHeaders } from './cors.ts';
import type { ApiResponse } from './types.ts';

/**
 * Create JSON response with CORS headers
 */
export function jsonResponse<T = any>(
  data: ApiResponse<T> | any,
  status: number = 200
): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      'Content-Type': 'application/json',
      ...corsHeaders,
    },
  });
}

/**
 * Success response (200/201)
 */
export function successResponse<T = any>(
  data: T,
  message?: string,
  status: number = 200
): Response {
  return jsonResponse<T>({
    success: true,
    data,
    message,
  }, status);
}

/**
 * Error response (400/401/403/404/500)
 */
export function errorResponse(
  error: string,
  status: number = 400,
  details?: any
): Response {
  return jsonResponse({
    success: false,
    error,
    ...(details && { details }),
  }, status);
}

/**
 * 400 Bad Request
 */
export function badRequest(error: string, details?: any): Response {
  return errorResponse(error, 400, details);
}

/**
 * 401 Unauthorized
 */
export function unauthorized(error: string = 'Authentication required'): Response {
  return errorResponse(error, 401);
}

/**
 * 403 Forbidden
 */
export function forbidden(error: string = 'Permission denied'): Response {
  return errorResponse(error, 403);
}

/**
 * 404 Not Found
 */
export function notFound(error: string = 'Resource not found'): Response {
  return errorResponse(error, 404);
}

/**
 * 500 Internal Server Error
 */
export function internalError(error: string = 'Internal server error', details?: any): Response {
  return errorResponse(error, 500, details);
}

/**
 * 201 Created
 */
export function created<T = any>(data: T, message?: string): Response {
  return successResponse(data, message, 201);
}










