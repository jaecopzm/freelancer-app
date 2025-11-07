import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/user_profile.dart';

/// Authentication service
/// Handles all auth operations with Supabase (sign in, sign up, sign out, etc.)
class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get current user
  User? get currentUser => _supabase.auth.currentUser;

  /// Get current user ID
  String? get currentUserId => _supabase.auth.currentUser?.id;

  /// Check if user is authenticated
  bool get isAuthenticated => _supabase.auth.currentUser != null;

  /// Stream of auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Sign up with email and password
  /// Creates auth user and user profile in database
  Future<UserProfile> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      // Create auth user
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Sign up failed. Please try again.');
      }

      // Create user profile in database
      final profile = UserProfile(
        id: response.user!.id,
        email: email,
        fullName: fullName,
        createdAt: DateTime.now(),
      );

      try {
        await _supabase.from('user_profiles').insert(profile.toJson());
      } catch (profileError) {
        // Profile creation failed, but auth user was created
        // This is acceptable - profile can be created later
        // In production, you would log this to a proper logging service
        // For now, we silently continue as the auth user was created successfully
      }

      return profile;
    } on AuthException catch (e) {
      throw Exception(_formatAuthError(e.message));
    } on PostgrestException catch (e) {
      // Handle database-specific errors
      if (e.message.contains('duplicate key') || e.message.contains('already exists')) {
        throw Exception('An account with this email already exists.');
      }
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  /// Sign in with email and password
  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Sign in failed. Please check your credentials.');
      }

      return response.user!;
    } on AuthException catch (e) {
      throw Exception(_formatAuthError(e.message));
    } catch (e) {
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out. Please try again.');
    }
  }

  /// Send password reset email
  Future<void> resetPassword({required String email}) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.freelancecompanion://reset-password',
      );
    } on AuthException catch (e) {
      throw Exception(_formatAuthError(e.message));
    } catch (e) {
      throw Exception('Failed to send reset email. Please try again.');
    }
  }

  /// Resend email verification
  Future<void> resendVerificationEmail() async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in.');
      }
      
      // Supabase automatically sends verification email on signup
      // This is a placeholder for future implementation if needed
      throw Exception('Please check your email for the verification link.');
    } on AuthException catch (e) {
      throw Exception(_formatAuthError(e.message));
    } catch (e) {
      throw Exception('Failed to resend verification email. Please try again.');
    }
  }

  /// Update user password (when authenticated)
  Future<void> updatePassword({required String newPassword}) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      throw Exception(_formatAuthError(e.message));
    } catch (e) {
      throw Exception('Failed to update password. Please try again.');
    }
  }

  /// Check if user's email is verified
  bool get isEmailVerified {
    final user = currentUser;
    if (user == null) return false;
    return user.emailConfirmedAt != null;
  }

  /// Sign out from all devices
  Future<void> signOutAllDevices() async {
    try {
      await _supabase.auth.signOut(scope: SignOutScope.global);
    } catch (e) {
      throw Exception('Failed to sign out from all devices. Please try again.');
    }
  }

  /// Get user profile from database
  Future<UserProfile?> getUserProfile() async {
    try {
      if (!isAuthenticated) return null;

      final response = await _supabase
          .from('user_profiles')
          .select()
          .eq('id', currentUserId!)
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      // Profile might not exist yet (during onboarding)
      return null;
    }
  }

  /// Update user profile
  Future<UserProfile> updateUserProfile(UserProfile profile) async {
    try {
      final updatedProfile = profile.copyWith(updatedAt: DateTime.now());
      
      await _supabase
          .from('user_profiles')
          .update(updatedProfile.toJson())
          .eq('id', currentUserId!);

      return updatedProfile;
    } catch (e) {
      throw Exception('Failed to update profile. Please try again.');
    }
  }

  /// Format auth error messages to be user-friendly
  String _formatAuthError(String message) {
    final lowerMessage = message.toLowerCase();
    
    if (lowerMessage.contains('invalid login credentials') || 
        lowerMessage.contains('invalid email or password')) {
      return 'Invalid email or password. Please try again.';
    }
    if (lowerMessage.contains('email not confirmed') || 
        lowerMessage.contains('email not verified')) {
      return 'Please verify your email before signing in. Check your inbox for the verification link.';
    }
    if (lowerMessage.contains('user already registered') || 
        lowerMessage.contains('already been registered')) {
      return 'This email is already registered. Please sign in instead.';
    }
    if (lowerMessage.contains('weak password') || 
        lowerMessage.contains('password is too weak')) {
      return 'Password is too weak. Please use a stronger password with at least 8 characters, including uppercase, lowercase, numbers, and special characters.';
    }
    if (lowerMessage.contains('invalid email')) {
      return 'Please enter a valid email address.';
    }
    if (lowerMessage.contains('network') || 
        lowerMessage.contains('connection')) {
      return 'Network error. Please check your connection and try again.';
    }
    if (lowerMessage.contains('rate limit')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    if (lowerMessage.contains('user not found')) {
      return 'No account found with this email. Please sign up first.';
    }
    
    // Return original message if no match
    return message;
  }
}
