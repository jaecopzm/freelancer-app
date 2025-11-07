import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

/// Utility class for testing Supabase connection
class ConnectionTest {
  static final _supabase = Supabase.instance.client;

  /// Run comprehensive connection tests
  static Future<ConnectionTestResult> runTests() async {
    final results = <String, bool>{};
    final messages = <String>[];

    try {
      // Test 1: Client initialization
      messages.add('Testing Supabase client initialization...');
      if (_supabase.auth.currentSession != null ||
          _supabase.auth.currentUser == null) {
        results['client_init'] = true;
        messages.add('✅ Supabase client initialized');
      } else {
        results['client_init'] = true;
        messages.add('✅ Supabase client initialized (no user)');
      }
    } catch (e) {
      results['client_init'] = false;
      messages.add('❌ Client initialization failed: $e');
    }

    try {
      // Test 2: Network connectivity
      messages.add('\nTesting network connectivity...');
      final response = await _supabase
          .from('profiles')
          .select('count')
          .limit(1)
          .timeout(const Duration(seconds: 10));

      results['network'] = true;
      messages.add('✅ Network connection successful');
      messages.add('   Response: $response');
    } catch (e) {
      results['network'] = false;
      messages.add('❌ Network connection failed: $e');
    }

    try {
      // Test 3: Authentication state
      messages.add('\nChecking authentication state...');
      final user = _supabase.auth.currentUser;

      if (user != null) {
        results['auth'] = true;
        messages.add('✅ User authenticated');
        messages.add('   Email: ${user.email}');
        messages.add('   ID: ${user.id}');
      } else {
        results['auth'] = false;
        messages.add('⚠️  No user authenticated');
      }
    } catch (e) {
      results['auth'] = false;
      messages.add('❌ Auth check failed: $e');
    }

    try {
      // Test 4: Database access (if authenticated)
      if (results['auth'] == true) {
        messages.add('\nTesting database access...');
        final profile = await _supabase
            .from('profiles')
            .select()
            .eq('id', _supabase.auth.currentUser!.id)
            .maybeSingle()
            .timeout(const Duration(seconds: 10));

        results['database'] = true;
        messages.add('✅ Database access successful');
        if (profile != null) {
          messages.add('   Profile found: ${profile['email']}');
        }
      }
    } catch (e) {
      results['database'] = false;
      messages.add('❌ Database access failed: $e');
    }

    // Summary
    messages.add('\n' + '=' * 50);
    messages.add('TEST SUMMARY');
    messages.add('=' * 50);

    final passed = results.values.where((v) => v).length;
    final total = results.length;

    messages.add('Tests passed: $passed/$total');

    if (passed == total) {
      messages.add('🎉 All tests passed!');
    } else {
      messages.add('⚠️  Some tests failed. Check details above.');
    }

    return ConnectionTestResult(
      allPassed: passed == total,
      results: results,
      messages: messages,
    );
  }

  /// Quick connection check
  static Future<bool> quickCheck() async {
    try {
      await _supabase
          .from('profiles')
          .select('count')
          .limit(1)
          .timeout(const Duration(seconds: 5));
      return true;
    } catch (e) {
      debugPrint('Connection check failed: $e');
      return false;
    }
  }

  /// Log connection info
  static void logConnectionInfo() {
    debugPrint('=== Supabase Connection Info ===');
    debugPrint('URL: ${SupabaseConfig.supabaseUrl}');
    debugPrint(
      'Auth State: ${_supabase.auth.currentSession != null ? "Authenticated" : "Not authenticated"}',
    );
    if (_supabase.auth.currentUser != null) {
      debugPrint('User: ${_supabase.auth.currentUser!.email}');
    }
    debugPrint('================================');
  }
}

/// Result of connection tests
class ConnectionTestResult {
  final bool allPassed;
  final Map<String, bool> results;
  final List<String> messages;

  ConnectionTestResult({
    required this.allPassed,
    required this.results,
    required this.messages,
  });

  String get fullReport => messages.join('\n');

  @override
  String toString() => fullReport;
}
