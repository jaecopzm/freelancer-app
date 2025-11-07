import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralized error handling service
class ErrorHandler {
  /// Parse and format Supabase errors into user-friendly messages
  static String getErrorMessage(dynamic error) {
    if (error is PostgrestException) {
      return _handlePostgrestError(error);
    } else if (error is AuthException) {
      return _handleAuthError(error);
    } else if (error is Exception) {
      return _handleGenericException(error);
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Handle PostgreSQL/Postgrest errors
  static String _handlePostgrestError(PostgrestException error) {
    final message = error.message.toLowerCase();
    final code = error.code ?? '';

    // Connection errors
    if (message.contains('network') || 
        message.contains('connection') ||
        message.contains('timeout')) {
      return 'Network connection error. Please check your internet and try again.';
    }

    // Constraint violations
    if (message.contains('duplicate key') || code == '23505') {
      return 'This record already exists. Please use a different value.';
    }

    if (message.contains('foreign key') || code == '23503') {
      return 'Cannot complete this action due to related records. Please remove dependencies first.';
    }

    if (message.contains('not null') || code == '23502') {
      return 'Required information is missing. Please fill in all required fields.';
    }

    // Permission errors
    if (message.contains('permission') || 
        message.contains('access denied') ||
        code == '42501') {
      return 'You don\'t have permission to perform this action.';
    }

    // Not found errors
    if (message.contains('not found') || code == 'PGRST116') {
      return 'The requested record was not found.';
    }

    // Return original message if no match
    return 'Database error: ${error.message}';
  }

  /// Handle authentication errors
  static String _handleAuthError(AuthException error) {
    final message = error.message.toLowerCase();

    if (message.contains('invalid login credentials') || 
        message.contains('invalid email or password')) {
      return 'Invalid email or password. Please try again.';
    }
    
    if (message.contains('email not confirmed') || 
        message.contains('email not verified')) {
      return 'Please verify your email before signing in. Check your inbox for the verification link.';
    }
    
    if (message.contains('user already registered') || 
        message.contains('already been registered')) {
      return 'This email is already registered. Please sign in instead.';
    }
    
    if (message.contains('weak password') || 
        message.contains('password is too weak')) {
      return 'Password is too weak. Please use at least 8 characters with uppercase, lowercase, numbers, and special characters.';
    }
    
    if (message.contains('invalid email')) {
      return 'Please enter a valid email address.';
    }
    
    if (message.contains('network') || 
        message.contains('connection')) {
      return 'Network error. Please check your connection and try again.';
    }
    
    if (message.contains('rate limit')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    
    if (message.contains('user not found')) {
      return 'No account found with this email. Please sign up first.';
    }

    return error.message;
  }

  /// Handle generic exceptions
  static String _handleGenericException(Exception error) {
    final message = error.toString().toLowerCase();

    if (message.contains('network') || 
        message.contains('socket') ||
        message.contains('connection')) {
      return 'Network connection error. Please check your internet and try again.';
    }

    if (message.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }

    if (message.contains('format')) {
      return 'Invalid data format. Please check your input.';
    }

    return error.toString().replaceAll('Exception: ', '');
  }

  /// Check if error is a network/connection error
  static bool isNetworkError(dynamic error) {
    final message = error.toString().toLowerCase();
    return message.contains('network') ||
        message.contains('connection') ||
        message.contains('socket') ||
        message.contains('timeout');
  }

  /// Check if error is recoverable (worth retrying)
  static bool isRecoverableError(dynamic error) {
    if (error is PostgrestException) {
      final code = error.code ?? '';
      // Temporary errors that might succeed on retry
      return code.isEmpty || 
             code == 'PGRST301' || // Connection error
             code == '57P03' || // Cannot connect now
             code == '08006'; // Connection failure
    }
    return isNetworkError(error);
  }
}
