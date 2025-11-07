import 'package:supabase_flutter/supabase_flutter.dart';

/// Advanced analytics service for business intelligence
class AnalyticsService {
  final _supabase = Supabase.instance.client;

  /// Get revenue analytics for a date range
  Future<Map<String, dynamic>> getRevenueAnalytics(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    // Get paid invoices
    final paidInvoices = await _supabase
        .from('invoices')
        .select('total, paid_at, client_id')
        .eq('user_id', userId)
        .eq('status', 'paid')
        .gte('paid_at', startDate.toIso8601String())
        .lte('paid_at', endDate.toIso8601String());

    // Get expenses
    final expenses = await _supabase
        .from('expenses')
        .select('amount, date, category')
        .eq('user_id', userId)
        .gte('date', startDate.toIso8601String())
        .lte('date', endDate.toIso8601String());

    final totalRevenue = (paidInvoices as List).fold<double>(
      0.0,
      (sum, invoice) => sum + (invoice['total'] as num).toDouble(),
    );

    final totalExpenses = (expenses as List).fold<double>(
      0.0,
      (sum, expense) => sum + (expense['amount'] as num).toDouble(),
    );

    final profit = totalRevenue - totalExpenses;
    final profitMargin = totalRevenue > 0 ? (profit / totalRevenue) * 100 : 0.0;

    return {
      'total_revenue': totalRevenue,
      'total_expenses': totalExpenses,
      'profit': profit,
      'profit_margin': profitMargin,
      'invoice_count': paidInvoices.length,
      'average_invoice': paidInvoices.isNotEmpty
          ? totalRevenue / paidInvoices.length
          : 0.0,
    };
  }

  /// Get time analytics
  Future<Map<String, dynamic>> getTimeAnalytics(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final timeEntries = await _supabase
        .from('time_entries')
        .select('duration_hours, is_billable, project_id')
        .eq('user_id', userId)
        .gte('start_time', startDate.toIso8601String())
        .lte('start_time', endDate.toIso8601String());

    final entries = timeEntries as List;
    final totalHours = entries.fold<double>(
      0.0,
      (sum, entry) => sum + (entry['duration_hours'] as num).toDouble(),
    );

    final billableHours = entries
        .where((e) => e['is_billable'] == true)
        .fold<double>(
          0.0,
          (sum, entry) => sum + (entry['duration_hours'] as num).toDouble(),
        );

    final utilizationRate = totalHours > 0
        ? (billableHours / totalHours) * 100
        : 0.0;

    return {
      'total_hours': totalHours,
      'billable_hours': billableHours,
      'non_billable_hours': totalHours - billableHours,
      'utilization_rate': utilizationRate,
      'entry_count': entries.length,
      'average_hours_per_day':
          totalHours / (endDate.difference(startDate).inDays + 1),
    };
  }

  /// Get client analytics
  Future<Map<String, dynamic>> getClientAnalytics() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    // Get all clients
    final clients = await _supabase
        .from('clients')
        .select('id, name')
        .eq('user_id', userId);

    // Get invoices by client
    final invoices = await _supabase
        .from('invoices')
        .select('client_id, total, status, paid_at')
        .eq('user_id', userId);

    final clientRevenue = <String, double>{};
    final clientInvoiceCount = <String, int>{};
    final clientPaymentBehavior = <String, Map<String, int>>{};

    for (final invoice in invoices as List) {
      final clientId = invoice['client_id'] as String?;
      if (clientId == null) continue;

      final total = (invoice['total'] as num).toDouble();
      clientRevenue[clientId] = (clientRevenue[clientId] ?? 0) + total;
      clientInvoiceCount[clientId] = (clientInvoiceCount[clientId] ?? 0) + 1;

      // Track payment behavior
      if (!clientPaymentBehavior.containsKey(clientId)) {
        clientPaymentBehavior[clientId] = {
          'on_time': 0,
          'late': 0,
          'pending': 0,
        };
      }

      final status = invoice['status'] as String;
      if (status == 'paid') {
        // Simple classification - can be enhanced with due date comparison
        clientPaymentBehavior[clientId]!['on_time'] =
            clientPaymentBehavior[clientId]!['on_time']! + 1;
      } else if (status == 'overdue') {
        clientPaymentBehavior[clientId]!['late'] =
            clientPaymentBehavior[clientId]!['late']! + 1;
      } else {
        clientPaymentBehavior[clientId]!['pending'] =
            clientPaymentBehavior[clientId]!['pending']! + 1;
      }
    }

    // Find top clients
    final sortedClients = clientRevenue.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topClients = sortedClients.take(5).map((entry) {
      final client = (clients as List).firstWhere(
        (c) => c['id'] == entry.key,
        orElse: () => {'id': entry.key, 'name': 'Unknown'},
      );
      return {
        'client_id': entry.key,
        'client_name': client['name'],
        'revenue': entry.value,
        'invoice_count': clientInvoiceCount[entry.key] ?? 0,
      };
    }).toList();

    return {
      'total_clients': (clients as List).length,
      'active_clients': clientRevenue.length,
      'top_clients': topClients,
      'average_revenue_per_client': clientRevenue.isNotEmpty
          ? clientRevenue.values.reduce((a, b) => a + b) / clientRevenue.length
          : 0.0,
    };
  }

  /// Get productivity heatmap data (hours by day of week and hour of day)
  Future<Map<String, dynamic>> getProductivityHeatmap(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final timeEntries = await _supabase
        .from('time_entries')
        .select('start_time, duration_hours')
        .eq('user_id', userId)
        .gte('start_time', startDate.toIso8601String())
        .lte('start_time', endDate.toIso8601String());

    final hoursByDayOfWeek = <int, double>{};
    final hoursByHourOfDay = <int, double>{};

    for (final entry in timeEntries as List) {
      final startTime = DateTime.parse(entry['start_time'] as String);
      final duration = (entry['duration_hours'] as num).toDouble();

      // Day of week (1 = Monday, 7 = Sunday)
      final dayOfWeek = startTime.weekday;
      hoursByDayOfWeek[dayOfWeek] =
          (hoursByDayOfWeek[dayOfWeek] ?? 0) + duration;

      // Hour of day (0-23)
      final hourOfDay = startTime.hour;
      hoursByHourOfDay[hourOfDay] =
          (hoursByHourOfDay[hourOfDay] ?? 0) + duration;
    }

    return {
      'hours_by_day_of_week': hoursByDayOfWeek,
      'hours_by_hour_of_day': hoursByHourOfDay,
      'most_productive_day': hoursByDayOfWeek.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key,
      'most_productive_hour': hoursByHourOfDay.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key,
    };
  }

  /// Get monthly trend data for charts
  Future<List<Map<String, dynamic>>> getMonthlyTrends(int months) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final trends = <Map<String, dynamic>>[];
    final now = DateTime.now();

    for (int i = months - 1; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final nextMonth = DateTime(now.year, now.month - i + 1, 1);

      final analytics = await getRevenueAnalytics(month, nextMonth);
      final timeAnalytics = await getTimeAnalytics(month, nextMonth);

      trends.add({
        'month': month,
        'revenue': analytics['total_revenue'],
        'expenses': analytics['total_expenses'],
        'profit': analytics['profit'],
        'hours': timeAnalytics['total_hours'],
        'billable_hours': timeAnalytics['billable_hours'],
      });
    }

    return trends;
  }

  /// Get dashboard summary
  Future<Map<String, dynamic>> getDashboardSummary() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final revenue = await getRevenueAnalytics(startOfMonth, endOfMonth);
    final time = await getTimeAnalytics(startOfMonth, endOfMonth);
    final clients = await getClientAnalytics();

    return {
      'revenue': revenue,
      'time': time,
      'clients': clients,
      'period': 'current_month',
    };
  }
}
