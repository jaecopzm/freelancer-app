import 'dart:async';
import 'error_handler.dart';

/// Retry configuration
class RetryConfig {
  final int maxAttempts;
  final Duration initialDelay;
  final Duration maxDelay;
  final double backoffMultiplier;

  const RetryConfig({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(milliseconds: 500),
    this.maxDelay = const Duration(seconds: 10),
    this.backoffMultiplier = 2.0,
  });

  /// Default configuration for most operations
  static const standard = RetryConfig();

  /// Configuration for critical operations
  static const critical = RetryConfig(
    maxAttempts: 5,
    initialDelay: Duration(milliseconds: 300),
    maxDelay: Duration(seconds: 30),
  );

  /// Configuration for background operations
  static const background = RetryConfig(
    maxAttempts: 10,
    initialDelay: Duration(seconds: 1),
    maxDelay: Duration(minutes: 5),
    backoffMultiplier: 3.0,
  );
}

/// Retry handler with exponential backoff
class RetryHandler {
  /// Execute a function with retry logic
  static Future<T> execute<T>({
    required Future<T> Function() action,
    RetryConfig config = RetryConfig.standard,
    bool Function(dynamic error)? shouldRetry,
    void Function(int attempt, dynamic error)? onRetry,
  }) async {
    int attempt = 0;
    Duration delay = config.initialDelay;

    while (true) {
      attempt++;
      
      try {
        return await action();
      } catch (error) {
        // Check if we should retry
        final shouldRetryError = shouldRetry?.call(error) ?? 
                                 ErrorHandler.isRecoverableError(error);
        
        // If we've exhausted attempts or shouldn't retry, throw
        if (attempt >= config.maxAttempts || !shouldRetryError) {
          rethrow;
        }

        // Notify about retry
        onRetry?.call(attempt, error);

        // Wait before retrying with exponential backoff
        await Future.delayed(delay);
        
        // Calculate next delay (exponential backoff with max cap)
        delay = Duration(
          milliseconds: (delay.inMilliseconds * config.backoffMultiplier).toInt(),
        );
        
        if (delay > config.maxDelay) {
          delay = config.maxDelay;
        }
      }
    }
  }

  /// Execute with timeout
  static Future<T> executeWithTimeout<T>({
    required Future<T> Function() action,
    Duration timeout = const Duration(seconds: 30),
    RetryConfig config = RetryConfig.standard,
  }) async {
    return execute(
      action: () => action().timeout(timeout),
      config: config,
    );
  }
}
