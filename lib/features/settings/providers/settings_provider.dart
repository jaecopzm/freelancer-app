import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/user_settings.dart';
import '../services/settings_service.dart';

/// Settings service provider
final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

/// User settings provider
final userSettingsProvider = FutureProvider<UserSettings>((ref) async {
  final service = ref.watch(settingsServiceProvider);
  return service.getSettings();
});

/// Settings controller
final settingsControllerProvider =
    StateNotifierProvider<SettingsController, AsyncValue<void>>((ref) {
      return SettingsController(ref);
    });

class SettingsController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  SettingsController(this._ref) : super(const AsyncValue.data(null));

  SettingsService get _service => _ref.read(settingsServiceProvider);

  Future<void> updateSettings(UserSettings settings) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.updateSettings(settings);
      _ref.invalidate(userSettingsProvider);
    });
  }

  Future<void> updateSetting(String key, dynamic value) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.updateSetting(key, value);
      _ref.invalidate(userSettingsProvider);
    });
  }

  Future<Map<String, dynamic>> exportUserData() async {
    return _service.exportUserData();
  }

  Future<void> deleteSettings() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.deleteSettings();
      _ref.invalidate(userSettingsProvider);
    });
  }
}
