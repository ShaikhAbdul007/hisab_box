import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseErrorHandler {
  SupabaseErrorHandler._();

  static String getMessage(dynamic error) {
    // Auth related errors
    if (error is AuthException) {
      return _authMessage(error.message);
    }

    // PostgREST / DB errors
    if (error is PostgrestException) {
      return _dbMessage(error.message);
    }

    // Network / unknown
    return 'Something went wrong. Please try again.';
  }

  // ---------------- PRIVATE ----------------

  static String _authMessage(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'Email or password is incorrect';
    }

    if (message.contains('Email not confirmed')) {
      return 'Please verify your email before login';
    }

    if (message.contains('User already registered')) {
      return 'Account already exists with this email';
    }

    return message; // fallback (safe)
  }

  static String _dbMessage(String message) {
    if (message.contains('duplicate key')) {
      return 'Data already exists';
    }

    if (message.contains('permission denied')) {
      return 'You do not have permission to perform this action';
    }

    return 'Database error occurred';
  }
}
