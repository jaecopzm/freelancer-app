import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Production-ready error handler with logging
class AppErrorHandler {
  static void handleError(Object error, StackTrace stackTrace, {String? context}) {
    // Log error
    debugPrint('═══════════════════════════════════════════');
    debugPrint('ERROR: ${error.toString()}');
    if (context != null) {
      debugPrint('CONTEXT: $context');
    }
    debugPrint('STACK TRACE:\n$stackTrace');
    debugPrint('═══════════════════════════════════════════');

    // In production, you would send this to a logging service like Sentry, Firebase Crashlytics, etc.
    if (kReleaseMode) {
      // TODO: Send to error tracking service
      // Sentry.captureException(error, stackTrace: stackTrace);
    }
  }

  static String getErrorMessage(Object error) {
    if (error is NetworkError) {
      return error.message;
    } else if (error is ValidationError) {
      return error.message;
    } else if (error is AuthError) {
      return error.message;
    } else if (error is ServerError) {
      return error.message;
    }
    
    // Default error message
    return 'An unexpected error occurred. Please try again.';
  }

  static void showErrorDialog(BuildContext context, Object error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Error'),
          ],
        ),
        content: Text(getErrorMessage(error)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

/// Base error class
abstract class AppError implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppError(this.message, {this.code, this.originalError});

  @override
  String toString() => message;
}

/// Network-related errors
class NetworkError extends AppError {
  NetworkError(super.message, {super.code, super.originalError});

  factory NetworkError.noConnection() {
    return NetworkError(
      'No internet connection. Please check your network settings.',
      code: 'NO_CONNECTION',
    );
  }

  factory NetworkError.timeout() {
    return NetworkError(
      'Request timed out. Please try again.',
      code: 'TIMEOUT',
    );
  }

  factory NetworkError.serverError() {
    return NetworkError(
      'Server error. Please try again later.',
      code: 'SERVER_ERROR',
    );
  }
}

/// Validation errors
class ValidationError extends AppError {
  final Map<String, String>? fieldErrors;

  ValidationError(super.message, {this.fieldErrors, super.code});

  factory ValidationError.required(String field) {
    return ValidationError('$field is required', code: 'REQUIRED');
  }

  factory ValidationError.invalid(String field) {
    return ValidationError('$field is invalid', code: 'INVALID');
  }

  factory ValidationError.tooShort(String field, int minLength) {
    return ValidationError(
      '$field must be at least $minLength characters',
      code: 'TOO_SHORT',
    );
  }

  factory ValidationError.tooLong(String field, int maxLength) {
    return ValidationError(
      '$field must be no more than $maxLength characters',
      code: 'TOO_LONG',
    );
  }
}

/// Authentication errors
class AuthError extends AppError {
  AuthError(super.message, {super.code, super.originalError});

  factory AuthError.invalidCredentials() {
    return AuthError(
      'Invalid email or password',
      code: 'INVALID_CREDENTIALS',
    );
  }

  factory AuthError.userNotFound() {
    return AuthError(
      'User not found',
      code: 'USER_NOT_FOUND',
    );
  }

  factory AuthError.emailAlreadyInUse() {
    return AuthError(
      'Email is already in use',
      code: 'EMAIL_IN_USE',
    );
  }

  factory AuthError.weakPassword() {
    return AuthError(
      'Password is too weak',
      code: 'WEAK_PASSWORD',
    );
  }

  factory AuthError.sessionExpired() {
    return AuthError(
      'Your session has expired. Please sign in again.',
      code: 'SESSION_EXPIRED',
    );
  }
}

/// Server errors
class ServerError extends AppError {
  final int? statusCode;

  ServerError(super.message, {this.statusCode, super.code, super.originalError});

  factory ServerError.notFound() {
    return ServerError(
      'Resource not found',
      statusCode: 404,
      code: 'NOT_FOUND',
    );
  }

  factory ServerError.forbidden() {
    return ServerError(
      'Access forbidden',
      statusCode: 403,
      code: 'FORBIDDEN',
    );
  }

  factory ServerError.internalError() {
    return ServerError(
      'Internal server error',
      statusCode: 500,
      code: 'INTERNAL_ERROR',
    );
  }
}

/// Database errors
class DatabaseError extends AppError {
  DatabaseError(super.message, {super.code, super.originalError});

  factory DatabaseError.connectionFailed() {
    return DatabaseError(
      'Failed to connect to database',
      code: 'CONNECTION_FAILED',
    );
  }

  factory DatabaseError.queryFailed() {
    return DatabaseError(
      'Database query failed',
      code: 'QUERY_FAILED',
    );
  }
}
