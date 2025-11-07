import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../../../shared/models/user_profile.dart';

/// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Auth state provider
/// Listens to Supabase auth state changes
final authStateProvider = StreamProvider<AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.currentUser;
});

/// User profile provider
/// Fetches and caches the current user's profile
final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  
  // Watch auth state to trigger refetch on auth changes
  ref.watch(authStateProvider);
  
  return authService.getUserProfile();
});

/// Auth controller provider
/// Handles auth actions (sign in, sign up, sign out)
final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(ref.watch(authServiceProvider));
});

/// Auth controller
/// Manages authentication state and actions
class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthService _authService;

  AuthController(this._authService) : super(const AsyncValue.data(null));

  /// Sign up with email and password
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );
    });
  }

  /// Sign in with email and password
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _authService.signIn(email: email, password: password);
    });
  }

  /// Sign out
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _authService.signOut();
    });
  }

  /// Reset password
  Future<void> resetPassword({required String email}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _authService.resetPassword(email: email);
    });
  }

  /// Update password
  Future<void> updatePassword({required String newPassword}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _authService.updatePassword(newPassword: newPassword);
    });
  }

  /// Resend verification email
  Future<void> resendVerificationEmail() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _authService.resendVerificationEmail();
    });
  }
}

/// Email verification status provider
final emailVerificationStatusProvider = Provider<bool>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.isEmailVerified;
});
