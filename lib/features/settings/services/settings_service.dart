import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_settings.dart';

class SettingsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String? get _userId => _supabase.auth.currentUser?.id;

  /// Get user settings
  Future<UserSettings> getSettings() async {
    try {
      final response = await _supabase
          .from('user_settings')
          .select()
          .eq('user_id', _userId!)
          .maybeSingle();

      if (response == null) {
        // Create default settings if none exist
        return createSettings(UserSettings.defaults(_userId!));
      }

      return UserSettings.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load settings: ${e.toString()}');
    }
  }

  /// Create user settings
  Future<UserSettings> createSettings(UserSettings settings) async {
    try {
      final data = settings.toJson();
      final response = await _supabase
          .from('user_settings')
          .insert(data)
          .select()
          .single();

      return UserSettings.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create settings: ${e.toString()}');
    }
  }

  /// Update user settings
  Future<UserSettings> updateSettings(UserSettings settings) async {
    try {
      final data = settings.toJson()
        ..['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('user_settings')
          .update(data)
          .eq('user_id', _userId!)
          .select()
          .single();

      return UserSettings.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update settings: ${e.toString()}');
    }
  }

  /// Update specific setting
  Future<void> updateSetting(String key, dynamic value) async {
    try {
      await _supabase
          .from('user_settings')
          .update({key: value, 'updated_at': DateTime.now().toIso8601String()})
          .eq('user_id', _userId!);
    } catch (e) {
      throw Exception('Failed to update setting: ${e.toString()}');
    }
  }

  /// Delete user settings
  Future<void> deleteSettings() async {
    try {
      await _supabase.from('user_settings').delete().eq('user_id', _userId!);
    } catch (e) {
      throw Exception('Failed to delete settings: ${e.toString()}');
    }
  }

  /// Export user data
  Future<Map<String, dynamic>> exportUserData() async {
    try {
      // Get all user data
      final settings = await getSettings();

      final clients = await _supabase
          .from('clients')
          .select()
          .eq('user_id', _userId!);

      final projects = await _supabase
          .from('projects')
          .select()
          .eq('user_id', _userId!);

      final invoices = await _supabase
          .from('invoices')
          .select()
          .eq('user_id', _userId!);

      final timeEntries = await _supabase
          .from('time_entries')
          .select()
          .eq('user_id', _userId!);

      return {
        'settings': settings.toJson(),
        'clients': clients,
        'projects': projects,
        'invoices': invoices,
        'time_entries': timeEntries,
        'exported_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to export data: ${e.toString()}');
    }
  }
}
