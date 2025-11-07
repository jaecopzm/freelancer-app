import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/screens/sign_in_screen.dart';
import '../../features/auth/screens/sign_up_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/verify_email_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/clients/screens/clients_list_screen.dart';
import '../../features/clients/screens/client_detail_screen.dart';
import '../../features/clients/screens/client_form_screen.dart';
import '../../features/projects/screens/projects_list_screen.dart';
import '../../features/projects/screens/project_detail_screen.dart';
import '../../features/projects/screens/project_form_screen.dart';
import '../../features/invoices/screens/invoices_list_screen.dart';
import '../../features/invoices/screens/invoice_detail_screen.dart';
import '../../features/invoices/screens/invoice_form_screen.dart';
import '../../features/time_tracking/screens/time_tracking_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/reports/screens/reports_screen.dart';
import '../config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// App router configuration using GoRouter
/// Handles navigation and route protection
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/signin',
    debugLogDiagnostics: SupabaseConfig.debugMode,
    refreshListenable: GoRouterRefreshStream(
      Supabase.instance.client.auth.onAuthStateChange,
    ),
    redirect: (context, state) {
      // Check if user is authenticated
      final isAuthenticated = Supabase.instance.client.auth.currentUser != null;
      final isAuthRoute =
          state.matchedLocation.startsWith('/signin') ||
          state.matchedLocation.startsWith('/signup') ||
          state.matchedLocation.startsWith('/forgot-password') ||
          state.matchedLocation.startsWith('/verify-email');

      // Redirect to dashboard if authenticated and trying to access auth routes
      if (isAuthenticated && isAuthRoute) {
        return '/dashboard';
      }

      // Redirect to sign in if not authenticated and trying to access protected routes
      if (!isAuthenticated && !isAuthRoute) {
        return '/signin';
      }

      return null; // No redirect needed
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/signin',
        name: 'signin',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const SignInScreen()),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const SignUpScreen()),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const ForgotPasswordScreen(),
        ),
      ),
      GoRoute(
        path: '/verify-email',
        name: 'verify-email',
        pageBuilder: (context, state) {
          final email = state.extra as String? ?? '';
          return MaterialPage(
            key: state.pageKey,
            child: VerifyEmailScreen(email: email),
          );
        },
      ),

      // Protected routes
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const DashboardScreen()),
      ),

      // Client routes
      GoRoute(
        path: '/clients',
        name: 'clients',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const ClientsListScreen()),
      ),
      GoRoute(
        path: '/clients/new',
        name: 'clients-new',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const ClientFormScreen()),
      ),
      GoRoute(
        path: '/clients/:id',
        name: 'client-detail',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return MaterialPage(
            key: state.pageKey,
            child: ClientDetailScreen(clientId: id),
          );
        },
      ),
      GoRoute(
        path: '/clients/:id/edit',
        name: 'client-edit',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return MaterialPage(
            key: state.pageKey,
            child: ClientFormScreen(clientId: id),
          );
        },
      ),

      // Project routes
      GoRoute(
        path: '/projects',
        name: 'projects',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const ProjectsListScreen()),
      ),
      GoRoute(
        path: '/projects/new',
        name: 'projects-new',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const ProjectFormScreen()),
      ),
      GoRoute(
        path: '/projects/:id',
        name: 'project-detail',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return MaterialPage(
            key: state.pageKey,
            child: ProjectDetailScreen(projectId: id),
          );
        },
      ),
      GoRoute(
        path: '/projects/:id/edit',
        name: 'project-edit',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return MaterialPage(
            key: state.pageKey,
            child: ProjectFormScreen(projectId: id),
          );
        },
      ),

      // Invoice routes
      GoRoute(
        path: '/invoices',
        name: 'invoices',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const InvoicesListScreen()),
      ),
      GoRoute(
        path: '/invoices/new',
        name: 'invoices-new',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const InvoiceFormScreen()),
      ),
      GoRoute(
        path: '/invoices/:id',
        name: 'invoice-detail',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return MaterialPage(
            key: state.pageKey,
            child: InvoiceDetailScreen(invoiceId: id),
          );
        },
      ),
      GoRoute(
        path: '/invoices/:id/edit',
        name: 'invoice-edit',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return MaterialPage(
            key: state.pageKey,
            child: InvoiceFormScreen(invoiceId: id),
          );
        },
      ),

      // Time tracking routes
      GoRoute(
        path: '/time-tracking',
        name: 'time-tracking',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const TimeTrackingScreen()),
      ),

      // Settings routes
      GoRoute(
        path: '/settings',
        name: 'settings',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const SettingsScreen()),
      ),

      // Reports routes
      GoRoute(
        path: '/reports',
        name: 'reports',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const ReportsScreen()),
      ),

      // Add more routes here as we build features
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    ),
  );
});

/// Helper class to refresh GoRouter when auth state changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<AuthState> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (AuthState _) => notifyListeners(),
    );
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
