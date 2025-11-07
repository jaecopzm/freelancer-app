import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/time_entry.dart';
import '../services/time_tracking_service.dart';

/// Time tracking service provider
final timeTrackingServiceProvider = Provider<TimeTrackingService>((ref) {
  return TimeTrackingService();
});

/// All time entries provider
final timeEntriesProvider = FutureProvider<List<TimeEntry>>((ref) async {
  final service = ref.watch(timeTrackingServiceProvider);
  return service.getTimeEntries();
});

/// Running time entry provider
final runningEntryProvider = FutureProvider<TimeEntry?>((ref) async {
  final service = ref.watch(timeTrackingServiceProvider);
  return service.getRunningEntry();
});

/// Time entries by project provider
final entriesByProjectProvider = FutureProvider.family<List<TimeEntry>, String>(
  (ref, projectId) async {
    final service = ref.watch(timeTrackingServiceProvider);
    return service.getEntriesByProject(projectId);
  },
);

/// Time entries by client provider
final entriesByClientProvider = FutureProvider.family<List<TimeEntry>, String>((
  ref,
  clientId,
) async {
  final service = ref.watch(timeTrackingServiceProvider);
  return service.getEntriesByClient(clientId);
});

/// Today's entries provider
final todayEntriesProvider = FutureProvider<List<TimeEntry>>((ref) async {
  final service = ref.watch(timeTrackingServiceProvider);
  return service.getTodayEntries();
});

/// This week's entries provider
final weekEntriesProvider = FutureProvider<List<TimeEntry>>((ref) async {
  final service = ref.watch(timeTrackingServiceProvider);
  return service.getWeekEntries();
});

/// This month's entries provider
final monthEntriesProvider = FutureProvider<List<TimeEntry>>((ref) async {
  final service = ref.watch(timeTrackingServiceProvider);
  return service.getMonthEntries();
});

/// Time statistics provider
final timeStatsProvider = FutureProvider<TimeStats>((ref) async {
  final service = ref.watch(timeTrackingServiceProvider);
  return service.getTimeStats();
});

/// Time tracking controller for CRUD operations
final timeTrackingControllerProvider =
    StateNotifierProvider<TimeTrackingController, AsyncValue<void>>((ref) {
      return TimeTrackingController(ref);
    });

class TimeTrackingController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  TimeTrackingController(this._ref) : super(const AsyncValue.data(null));

  TimeTrackingService get _service => _ref.read(timeTrackingServiceProvider);

  Future<TimeEntry> startTimer({
    required String description,
    String? projectId,
    String? clientId,
    double? hourlyRate,
    String? tags,
  }) async {
    state = const AsyncValue.loading();
    try {
      final entry = await _service.startTimer(
        description: description,
        projectId: projectId,
        clientId: clientId,
        hourlyRate: hourlyRate,
        tags: tags,
      );
      _invalidateAll();
      state = const AsyncValue.data(null);
      return entry;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<TimeEntry> stopTimer(String id) async {
    state = const AsyncValue.loading();
    try {
      final entry = await _service.stopTimer(id);
      _invalidateAll();
      state = const AsyncValue.data(null);
      return entry;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> createTimeEntry(TimeEntry entry) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.createTimeEntry(entry);
      _invalidateAll();
    });
  }

  Future<void> updateTimeEntry(TimeEntry entry) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.updateTimeEntry(entry);
      _invalidateAll();
    });
  }

  Future<void> deleteTimeEntry(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.deleteTimeEntry(id);
      _invalidateAll();
    });
  }

  void _invalidateAll() {
    _ref.invalidate(timeEntriesProvider);
    _ref.invalidate(runningEntryProvider);
    _ref.invalidate(todayEntriesProvider);
    _ref.invalidate(weekEntriesProvider);
    _ref.invalidate(monthEntriesProvider);
    _ref.invalidate(timeStatsProvider);
  }
}

/// Timer state provider for UI updates
final timerTickProvider = StreamProvider<DateTime>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
});
