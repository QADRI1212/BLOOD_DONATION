/// Maps exceptions and error strings to user-friendly messages.
///
/// Uses [AuthException.code] when available for reliable matching,
/// with fallback to [message] string matching for unhandled cases.
library;

import 'app_exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;

/// Returns a user-friendly message suitable for displaying in a SnackBar,
/// dialog, or inline error widget.
String getUserFriendlyMessage(dynamic error, [String? fallback]) {
  // --- AuthException from Supabase (preferred: match on code) ---
  if (error is AuthException) {
    return _mapAuthCode(error.code) ??
        _mapAuthMessage(error.message) ??
        fallback ??
        error.message;
  }

  // --- Custom AppExceptions ---
  if (error is AppException) {
    return error.message;
  }

  // --- Dart FormatException ---
  if (error is FormatException) {
    return 'Invalid data format received. Please try again.';
  }

  // --- Fallback ---
  return fallback ?? 'Something went wrong. Please try again.';
}

/// Maps [AuthException.code] to a user-friendly message.
/// Returns null if the code is unrecognised.
String? _mapAuthCode(String? code) {
  if (code == null) return null;

  switch (code) {
    // Sign in
    case 'invalid_credentials':
      return 'Incorrect email or password. Please try again.';
    case 'email_not_confirmed':
      return 'Please verify your email address before logging in. Check your inbox for the verification link.';
    case 'user_not_found':
      return 'No account found with this email. Please sign up first.';
    case 'user_disabled':
      return 'This account has been disabled. Please contact support.';
    case 'sso_not_found':
      return 'Unable to sign in with this method. Please use email and password.';

    // Sign up
    case 'user_already_exists':
    case 'user_already_registered':
      return 'An account with this email already exists. Try signing in instead.';
    case 'weak_password':
      return 'Password is too weak. Please use at least 6 characters with a mix of letters and numbers.';
    case 'invalid_email':
      return 'Please enter a valid email address.';
    case 'signup_disabled':
      return 'New account registration is currently disabled. Please try again later.';

    // Password reset
    case 'same_password':
      return 'New password must be different from your current password.';
    case 'token_expired':
      return 'This reset link has expired. Please request a new one.';
    case 'invalid_grant':
      return 'The reset link or verification code is invalid or has expired. Please try again.';

    // OTP / Verification
    case 'otp_expired':
      return 'The verification code has expired. Please request a new one.';
    case 'otp_invalid':
      return 'Invalid verification code. Please check and try again.';
    case 'otp_disabled':
      return 'Verification codes are not enabled for this account.';

    // Rate limiting
    case 'over_email_send_rate_limit':
      return 'Too many emails sent. Please wait a moment before requesting another.';
    case 'over_request_rate_limit':
      return 'Too many attempts. Please wait a bit and try again.';
    case 'over_otp_send_rate_limit':
      return 'Too many verification code requests. Please wait before trying again.';

    // Session / MFA
    case 'session_not_found':
      return 'Your session has expired. Please sign in again.';
    case 'refresh_token_not_found':
      return 'Session expired. Please sign in again.';
    case 'mfa_not_enabled':
      return 'Two-factor authentication is not enabled for your account.';
    case 'mfa_enrolled_required':
      return 'Please set up two-factor authentication first.';
    case 'mfa_factor_not_found':
      return 'Verification factor not found. Please try again.';

    // General / default
    default:
      return null;
  }
}

/// Fallback: map common [AuthException.message] strings that the `code`
/// field may not cover (e.g. older server versions).
String? _mapAuthMessage(String message) {
  final lower = message.toLowerCase();

  if (lower.contains('invalid login') || lower.contains('invalid credentials')) {
    return 'Incorrect email or password. Please try again.';
  }
  if (lower.contains('email not confirmed') || lower.contains('email not verified')) {
    return 'Please verify your email address before logging in.';
  }
  if (lower.contains('already registered') || lower.contains('already exists')) {
    return 'An account with this email already exists. Try signing in instead.';
  }
  if (lower.contains('weak password') || lower.contains('at least 6')) {
    return 'Password must be at least 6 characters with a mix of letters and numbers.';
  }
  if (lower.contains('too many request') || lower.contains('rate limit')) {
    return 'Too many attempts. Please wait a moment and try again.';
  }
  if (lower.contains('token expired') || lower.contains('link is invalid or has expired')) {
    return 'The verification link or code has expired. Please request a new one.';
  }
  if (lower.contains('not found') && lower.contains('user')) {
    return 'No account found with this email. Please sign up first.';
  }
  if (lower.contains('invalid email')) {
    return 'Please enter a valid email address.';
  }
  if (lower.contains('password should')) {
    return 'Password must be at least 6 characters.';
  }

  return null;
}
