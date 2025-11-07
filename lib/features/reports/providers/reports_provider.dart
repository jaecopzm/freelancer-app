import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../invoices/services/reports_service.dart';

/// Reports service provider
final reportsServiceProvider = Provider<ReportsService>((ref) {
  return ReportsService();
});

/// Revenue report provider
final revenueReportProvider = FutureProvider.family<RevenueReport, DateRange?>((
  ref,
  dateRange,
) async {
  final service = ref.watch(reportsServiceProvider);
  return service.getRevenueReport(
    startDate: dateRange?.startDate,
    endDate: dateRange?.endDate,
  );
});

/// Time report provider
final timeReportProvider = FutureProvider.family<TimeReport, DateRange?>((
  ref,
  dateRange,
) async {
  final service = ref.watch(reportsServiceProvider);
  return service.getTimeReport(
    startDate: dateRange?.startDate,
    endDate: dateRange?.endDate,
  );
});

/// Business report provider
final businessReportProvider =
    FutureProvider.family<BusinessReport, DateRange?>((ref, dateRange) async {
      final service = ref.watch(reportsServiceProvider);
      return service.getBusinessReport(
        startDate: dateRange?.startDate,
        endDate: dateRange?.endDate,
      );
    });

/// Date range model
class DateRange {
  final DateTime startDate;
  final DateTime endDate;

  const DateRange({required this.startDate, required this.endDate});

  factory DateRange.thisMonth() {
    final now = DateTime.now();
    return DateRange(
      startDate: DateTime(now.year, now.month, 1),
      endDate: DateTime(now.year, now.month + 1, 0),
    );
  }

  factory DateRange.lastMonth() {
    final now = DateTime.now();
    return DateRange(
      startDate: DateTime(now.year, now.month - 1, 1),
      endDate: DateTime(now.year, now.month, 0),
    );
  }

  factory DateRange.thisYear() {
    final now = DateTime.now();
    return DateRange(
      startDate: DateTime(now.year, 1, 1),
      endDate: DateTime(now.year, 12, 31),
    );
  }
}
