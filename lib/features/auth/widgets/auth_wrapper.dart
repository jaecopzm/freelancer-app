import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'email_verification_banner.dart';

/// Wrapper widget that handles authentication state
/// Shows loading, error, or authenticated content
class AuthWrapper extends ConsumerWidget {
  final Widget child;
  final bool showVerificationBanner;

  const AuthWrapper({
    super.key,
    required this.child,
    this.showVerificationBanner = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (state) {
        // User is authenticated
        if (state.session != null) {
          if (showVerificationBanner) {
            return Column(
              children: [
                const EmailVerificationBanner(),
                Expanded(child: child),
              ],
            );
          }
          return child;
        }
        
        // User is not authenticated - this shouldn't happen in protected routes
        // The router will handle redirects
        return child;
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Authentication Error',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  ref.invalidate(authStateProvider);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
