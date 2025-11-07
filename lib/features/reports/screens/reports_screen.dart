import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/custom_navbar.dart';
import '../providers/reports_provider.dart';
import '../../invoices/services/reports_service.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  DateRange? _selectedRange;

  @override
  void initState() {
    super.initState();
    _selectedRange = DateRange.thisMonth();
  }

  @override
  Widget build(BuildContext context) {
    final businessReportAsync = ref.watch(
      businessReportProvider(_selectedRange),
    );

    return Scaffold(
      appBar: const CustomNavBar(
        title: 'Reports & Analytics',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Date range selector
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'month', label: Text('This Month')),
                      ButtonSegment(value: 'year', label: Text('This Year')),
                      ButtonSegment(value: 'all', label: Text('All Time')),
                    ],
                    selected: {
                      _selectedRange == null
                          ? 'all'
                          : _selectedRange!.startDate.month ==
                                DateTime.now().month
                          ? 'month'
                          : 'year',
                    },
                    onSelectionChanged: (Set<String> selection) {
                      setState(() {
                        switch (selection.first) {
                          case 'month':
                            _selectedRange = DateRange.thisMonth();
                            break;
                          case 'year':
                            _selectedRange = DateRange.thisYear();
                            break;
                          case 'all':
                            _selectedRange = null;
                            break;
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Reports content
          Expanded(
            child: businessReportAsync.when(
              data: (report) => _buildReportContent(context, report),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text('Error: $error'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent(BuildContext context, BusinessReport report) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Revenue Section
        Text(
          'Revenue',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                'Total Revenue',
                '\$${report.revenueReport.totalRevenue.toStringAsFixed(0)}',
                Icons.trending_up,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                context,
                'Outstanding',
                '\$${report.revenueReport.outstandingAmount.toStringAsFixed(0)}',
                Icons.pending,
                Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                'Overdue',
                '\$${report.revenueReport.overdueAmount.toStringAsFixed(0)}',
                Icons.warning,
                Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                context,
                'Avg Invoice',
                '\$${report.revenueReport.averageInvoiceValue.toStringAsFixed(0)}',
                Icons.receipt,
                Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Time Tracking Section
        Text(
          'Time Tracking',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                'Total Hours',
                report.timeReport.totalHours.toStringAsFixed(1),
                Icons.access_time,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                context,
                'Billable Hours',
                report.timeReport.billableHours.toStringAsFixed(1),
                Icons.attach_money,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                'Total Earnings',
                '\$${report.timeReport.totalEarnings.toStringAsFixed(0)}',
                Icons.monetization_on,
                Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                context,
                'Avg Rate',
                '\$${report.timeReport.averageHourlyRate.toStringAsFixed(0)}/hr',
                Icons.schedule,
                Colors.indigo,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Invoice Stats
        Text(
          'Invoice Statistics',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildStatRow(
                  'Total Invoices',
                  report.revenueReport.totalInvoices.toString(),
                ),
                _buildStatRow(
                  'Paid Invoices',
                  report.revenueReport.paidInvoices.toString(),
                ),
                _buildStatRow(
                  'Unpaid Invoices',
                  report.revenueReport.unpaidInvoices.toString(),
                ),
                _buildStatRow(
                  'Overdue Invoices',
                  report.revenueReport.overdueInvoices.toString(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
