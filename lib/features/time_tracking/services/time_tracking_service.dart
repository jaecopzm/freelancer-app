import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/time_entry.dart';

class TimeTrackingService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String? get _userId => _supabase.auth.currentUser?.id;

  /// Get all time entries for current user
  Future<List<TimeEntry>> getTimeEntries() async {
    try {
      final response = await _supabase
          .from('time_entries')
          .select()
          .eq('user_id', _userId!)
          .order('start_time', ascending: false);

      return (response as List)
          .map((json) => TimeEntry.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load time entries: ${e.toString()}');
    }
  }

  /// Get running time entry
  Future<TimeEntry?> getRunningEntry() async {
    try {
      final response = await _supabase
          .from('time_entries')
          .select()
          .eq('user_id', _userId!)
          .eq('is_running', true)
          .maybeSingle();

      if (response == null) return null;
      return TimeEntry.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load running entry: ${e.toString()}');
    }
  }

  /// Get time entries by project
  Future<List<TimeEntry>> getEntriesByProject(String projectId) async {
    try {
      final response = await _supabase
          .from('time_entries')
          .select()
          .eq('user_id', _userId!)
          .eq('project_id', projectId)
          .order('start_time', ascending: false);

      return (response as List)
          .map((json) => TimeEntry.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load time entries: ${e.toString()}');
    }
  }

  /// Get time entries by client
  Future<List<TimeEntry>> getEntriesByClient(String clientId) async {
    try {
      final response = await _supabase
          .from('time_entries')
          .select()
          .eq('user_id', _userId!)
          .eq('client_id', clientId)
          .order('start_time', ascending: false);

      return (response as List)
          .map((json) => TimeEntry.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load time entries: ${e.toString()}');
    }
  }

  /// Get time entries by date range
  Future<List<TimeEntry>> getEntriesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await _supabase
          .from('time_entries')
          .select()
          .eq('user_id', _userId!)
          .gte('start_time', startDate.toIso8601String())
          .lte('start_time', endDate.toIso8601String())
          .order('start_time', ascending: false);

      return (response as List)
          .map((json) => TimeEntry.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load time entries: ${e.toString()}');
    }
  }

  /// Get single time entry
  Future<TimeEntry> getTimeEntry(String id) async {
    try {
      final response = await _supabase
          .from('time_entries')
          .select()
          .eq('id', id)
          .eq('user_id', _userId!)
          .single();

      return TimeEntry.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load time entry: ${e.toString()}');
    }
  }

  /// Start timer
  Future<TimeEntry> startTimer({
    required String description,
    String? projectId,
    String? clientId,
    double? hourlyRate,
    String? tags,
  }) async {
    try {
      // Stop any running timers first
      await stopAllRunningTimers();

      final data = {
        'user_id': _userId,
        'description': description,
        'project_id': projectId,
        'client_id': clientId,
        'start_time': DateTime.now().toIso8601String(),
        'is_running': true,
        'hourly_rate': hourlyRate,
        'tags': tags,
      };

      final response = await _supabase
          .from('time_entries')
          .insert(data)
          .select()
          .single();

      return TimeEntry.fromJson(response);
    } catch (e) {
      throw Exception('Failed to start timer: ${e.toString()}');
    }
  }

  /// Stop timer
  Future<TimeEntry> stopTimer(String id) async {
    try {
      final entry = await getTimeEntry(id);
      final endTime = DateTime.now();
      final duration = endTime.difference(entry.startTime).inSeconds;
      final amount = entry.hourlyRate != null
          ? (duration / 3600) * entry.hourlyRate!
          : null;

      final response = await _supabase
          .from('time_entries')
          .update({
            'end_time': endTime.toIso8601String(),
            'duration_seconds': duration,
            'is_running': false,
            'amount': amount,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .eq('user_id', _userId!)
          .select()
          .single();

      return TimeEntry.fromJson(response);
    } catch (e) {
      throw Exception('Failed to stop timer: ${e.toString()}');
    }
  }

  /// Stop all running timers
  Future<void> stopAllRunningTimers() async {
    try {
      final running = await getRunningEntry();
      if (running != null) {
        await stopTimer(running.id);
      }
    } catch (e) {
      // Ignore errors when stopping running timers
    }
  }

  /// Create manual time entry
  Future<TimeEntry> createTimeEntry(TimeEntry entry) async {
    try {
      final data = entry.toJson()
        ..['user_id'] = _userId
        ..remove('id'); // Let PostgreSQL generate the ID

      final response = await _supabase
          .from('time_entries')
          .insert(data)
          .select()
          .single();

      return TimeEntry.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create time entry: ${e.toString()}');
    }
  }

  /// Update time entry
  Future<TimeEntry> updateTimeEntry(TimeEntry entry) async {
    try {
      final data = entry.toJson()
        ..['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('time_entries')
          .update(data)
          .eq('id', entry.id)
          .eq('user_id', _userId!)
          .select()
          .single();

      return TimeEntry.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update time entry: ${e.toString()}');
    }
  }

  /// Delete time entry
  Future<void> deleteTimeEntry(String id) async {
    try {
      await _supabase
          .from('time_entries')
          .delete()
          .eq('id', id)
          .eq('user_id', _userId!);
    } catch (e) {
      throw Exception('Failed to delete time entry: ${e.toString()}');
    }
  }

  /// Get time statistics
  Future<TimeStats> getTimeStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      List<TimeEntry> entries;

      if (startDate != null && endDate != null) {
        entries = await getEntriesByDateRange(startDate, endDate);
      } else {
        entries = await getTimeEntries();
      }

      final totalHours = entries.fold<double>(
        0,
        (sum, entry) => sum + entry.durationHours,
      );

      final billableHours = entries
          .where((entry) => entry.hourlyRate != null)
          .fold<double>(0, (sum, entry) => sum + entry.durationHours);

      final totalAmount = entries.fold<double>(
        0,
        (sum, entry) => sum + (entry.amount ?? 0),
      );

      final hoursByProject = <String, double>{};
      final hoursByClient = <String, double>{};

      for (final entry in entries) {
        if (entry.projectId != null) {
          hoursByProject[entry.projectId!] =
              (hoursByProject[entry.projectId!] ?? 0) + entry.durationHours;
        }
        if (entry.clientId != null) {
          hoursByClient[entry.clientId!] =
              (hoursByClient[entry.clientId!] ?? 0) + entry.durationHours;
        }
      }

      return TimeStats(
        totalHours: totalHours,
        billableHours: billableHours,
        totalAmount: totalAmount,
        totalEntries: entries.length,
        hoursByProject: hoursByProject,
        hoursByClient: hoursByClient,
      );
    } catch (e) {
      throw Exception('Failed to get time stats: ${e.toString()}');
    }
  }

  /// Get today's entries
  Future<List<TimeEntry>> getTodayEntries() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return getEntriesByDateRange(startOfDay, endOfDay);
  }

  /// Get this week's entries
  Future<List<TimeEntry>> getWeekEntries() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfDay = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );
    return getEntriesByDateRange(startOfDay, now);
  }

  /// Get this month's entries
  Future<List<TimeEntry>> getMonthEntries() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    return getEntriesByDateRange(startOfMonth, now);
  }
}
