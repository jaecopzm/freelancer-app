import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/invoice.dart';
import '../../time_tracking/models/time_entry.dart';

class ReportsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String? get _userId => _supabase.auth.currentUser?.id;

  /// Get revenue report for date range
  Future<RevenueReport> getRevenueReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Get invoices
      var query = _supabase.from('invoices').select().eq('user_id', _userId!);

      if (startDate != null) {
        query = query.gte('issue_date', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('issue_date', endDate.toIso8601String());
      }

      final invoicesData = await query;
      final invoices = (invoicesData as List)
          .map((json) => Invoice.fromJson(json))
          .toList();

      // Calculate metrics
      final totalRevenue = invoices
          .where((inv) => inv.status == InvoiceStatus.paid)
          .fold(0.0, (sum, inv) => sum + inv.total);

      final outstandingAmount = invoices
          .where(
            (inv) =>
                inv.status != InvoiceStatus.paid &&
                inv.status != InvoiceStatus.cancelled,
          )
          .fold(0.0, (sum, inv) => sum + inv.total);

      final overdueAmount = invoices
          .where((inv) => inv.isOverdue)
          .fold(0.0, (sum, inv) => sum + inv.total);

      final averageInvoiceValue = invoices.isNotEmpty
          ? invoices.fold(0.0, (sum, inv) => sum + inv.total) / invoices.length
          : 0.0;

      // Revenue by month
      final revenueByMonth = <String, double>{};
      for (final invoice in invoices.where(
        (inv) => inv.status == InvoiceStatus.paid,
      )) {
        final monthKey =
            '${invoice.issueDate.year}-${invoice.issueDate.month.toString().padLeft(2, '0')}';
        revenueByMonth[monthKey] =
            (revenueByMonth[monthKey] ?? 0) + invoice.total;
      }

      // Revenue by client
      final revenueByClient = <String, double>{};
      for (final invoice in invoices.where(
        (inv) => inv.status == InvoiceStatus.paid,
      )) {
        if (invoice.clientId != null) {
          revenueByClient[invoice.clientId!] =
              (revenueByClient[invoice.clientId!] ?? 0) + invoice.total;
        }
      }

      return RevenueReport(
        totalRevenue: totalRevenue,
        outstandingAmount: outstandingAmount,
        overdueAmount: overdueAmount,
        totalInvoices: invoices.length,
        paidInvoices: invoices
            .where((inv) => inv.status == InvoiceStatus.paid)
            .length,
        unpaidInvoices: invoices
            .where(
              (inv) =>
                  inv.status != InvoiceStatus.paid &&
                  inv.status != InvoiceStatus.cancelled,
            )
            .length,
        overdueInvoices: invoices.where((inv) => inv.isOverdue).length,
        averageInvoiceValue: averageInvoiceValue,
        revenueByMonth: revenueByMonth,
        revenueByClient: revenueByClient,
      );
    } catch (e) {
      throw Exception('Failed to generate revenue report: ${e.toString()}');
    }
  }

  /// Get time tracking report
  Future<TimeReport> getTimeReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _supabase
          .from('time_entries')
          .select()
          .eq('user_id', _userId!);

      if (startDate != null) {
        query = query.gte('start_time', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('start_time', endDate.toIso8601String());
      }

      final entriesData = await query;
      final entries = (entriesData as List)
          .map((json) => TimeEntry.fromJson(json))
          .toList();

      final totalHours = entries.fold<double>(
        0,
        (sum, entry) => sum + entry.durationHours,
      );

      final billableHours = entries
          .where((entry) => entry.hourlyRate != null)
          .fold<double>(0, (sum, entry) => sum + entry.durationHours);

      final totalEarnings = entries.fold<double>(
        0,
        (sum, entry) => sum + (entry.amount ?? 0),
      );

      // Hours by project
      final hoursByProject = <String, double>{};
      for (final entry in entries) {
        if (entry.projectId != null) {
          hoursByProject[entry.projectId!] =
              (hoursByProject[entry.projectId!] ?? 0) + entry.durationHours;
        }
      }

      // Hours by client
      final hoursByClient = <String, double>{};
      for (final entry in entries) {
        if (entry.clientId != null) {
          hoursByClient[entry.clientId!] =
              (hoursByClient[entry.clientId!] ?? 0) + entry.durationHours;
        }
      }

      return TimeReport(
        totalHours: totalHours,
        billableHours: billableHours,
        nonBillableHours: totalHours - billableHours,
        totalEarnings: totalEarnings,
        averageHourlyRate: billableHours > 0
            ? totalEarnings / billableHours
            : 0,
        totalEntries: entries.length,
        hoursByProject: hoursByProject,
        hoursByClient: hoursByClient,
      );
    } catch (e) {
      throw Exception('Failed to generate time report: ${e.toString()}');
    }
  }

  /// Get combined business report
  Future<BusinessReport> getBusinessReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final revenueReport = await getRevenueReport(
      startDate: startDate,
      endDate: endDate,
    );
    final timeReport = await getTimeReport(
      startDate: startDate,
      endDate: endDate,
    );

    return BusinessReport(
      revenueReport: revenueReport,
      timeReport: timeReport,
      startDate: startDate,
      endDate: endDate,
    );
  }
}

/// Revenue report model
class RevenueReport {
  final double totalRevenue;
  final double outstandingAmount;
  final double overdueAmount;
  final int totalInvoices;
  final int paidInvoices;
  final int unpaidInvoices;
  final int overdueInvoices;
  final double averageInvoiceValue;
  final Map<String, double> revenueByMonth;
  final Map<String, double> revenueByClient;

  const RevenueReport({
    required this.totalRevenue,
    required this.outstandingAmount,
    required this.overdueAmount,
    required this.totalInvoices,
    required this.paidInvoices,
    required this.unpaidInvoices,
    required this.overdueInvoices,
    required this.averageInvoiceValue,
    required this.revenueByMonth,
    required this.revenueByClient,
  });
}

/// Time report model
class TimeReport {
  final double totalHours;
  final double billableHours;
  final double nonBillableHours;
  final double totalEarnings;
  final double averageHourlyRate;
  final int totalEntries;
  final Map<String, double> hoursByProject;
  final Map<String, double> hoursByClient;

  const TimeReport({
    required this.totalHours,
    required this.billableHours,
    required this.nonBillableHours,
    required this.totalEarnings,
    required this.averageHourlyRate,
    required this.totalEntries,
    required this.hoursByProject,
    required this.hoursByClient,
  });
}

/// Combined business report
class BusinessReport {
  final RevenueReport revenueReport;
  final TimeReport timeReport;
  final DateTime? startDate;
  final DateTime? endDate;

  const BusinessReport({
    required this.revenueReport,
    required this.timeReport,
    this.startDate,
    this.endDate,
  });
}
