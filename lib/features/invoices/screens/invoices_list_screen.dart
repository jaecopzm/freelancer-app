import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/advanced_navbar.dart';
import '../../../shared/widgets/custom_bottom_navbar.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_states.dart';
import '../models/invoice.dart';
import '../providers/invoice_provider.dart';
import '../widgets/invoice_card.dart';
import '../widgets/invoice_status_filter.dart';

class InvoicesListScreen extends ConsumerStatefulWidget {
  const InvoicesListScreen({super.key});

  @override
  ConsumerState<InvoicesListScreen> createState() => _InvoicesListScreenState();
}

class _InvoicesListScreenState extends ConsumerState<InvoicesListScreen> {
  String _selectedStatus = 'all';
  int _currentBottomIndex = 3; // Invoices tab

  @override
  Widget build(BuildContext context) {
    final invoicesAsync = _getInvoices();
    final statsAsync = ref.watch(invoiceStatsProvider);

    return Scaffold(
      appBar: AdvancedNavBar(
        title: 'Invoices',
        showSearch: true,
        showProfile: true,
        showNotifications: true,
        notificationCount: 0,
        onSearchTap: () => _showSearchDialog(context),
        onMenuItemSelected: (value) => _handleMenuAction(context, value),
      ),
      body: Column(
        children: [
          // Stats summary
          statsAsync.when(
            data: (stats) => _buildStatsBar(context, stats),
            loading: () => const SizedBox(height: 80),
            error: (_, __) => const SizedBox(height: 80),
          ),

          // Status filter
          InvoiceStatusFilter(
            selectedStatus: _selectedStatus,
            onStatusChanged: (status) {
              setState(() => _selectedStatus = status);
            },
          ),

          // Invoices list
          Expanded(
            child: invoicesAsync.when(
              data: (invoices) {
                if (invoices.isEmpty) {
                  return _buildEmptyState(context);
                }
                return _buildInvoicesList(invoices);
              },
              loading: () => const ListShimmer(itemCount: 5),
              error: (error, stack) => _buildErrorState(context, error),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/invoices/new'),
        icon: const Icon(Icons.add),
        label: const Text('New Invoice'),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentBottomIndex,
        onTap: (index) => _handleBottomNavTap(context, index),
        items: const [
          BottomNavItem(
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard,
            label: 'Dashboard',
          ),
          BottomNavItem(
            icon: Icons.folder_outlined,
            activeIcon: Icons.folder,
            label: 'Projects',
          ),
          BottomNavItem(
            icon: Icons.people_outline,
            activeIcon: Icons.people,
            label: 'Clients',
          ),
          BottomNavItem(
            icon: Icons.receipt_outlined,
            activeIcon: Icons.receipt,
            label: 'Invoices',
          ),
        ],
      ),
    );
  }

  AsyncValue<List<Invoice>> _getInvoices() {
    switch (_selectedStatus) {
      case 'all':
        return ref.watch(invoicesProvider);
      case 'unpaid':
        final invoices = ref.watch(invoicesProvider);
        return invoices.whenData(
          (list) => list
              .where(
                (inv) =>
                    inv.status != InvoiceStatus.paid &&
                    inv.status != InvoiceStatus.cancelled,
              )
              .toList(),
        );
      case 'overdue':
        final invoices = ref.watch(invoicesProvider);
        return invoices.whenData(
          (list) => list.where((inv) => inv.isOverdue).toList(),
        );
      default:
        return ref.watch(invoicesByStatusProvider(_selectedStatus));
    }
  }

  Widget _buildStatsBar(BuildContext context, Map<String, dynamic> stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              context,
              'Total Revenue',
              '\$${stats['total_revenue'].toStringAsFixed(0)}',
              Colors.green,
              Icons.trending_up,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              context,
              'Unpaid',
              '\$${stats['unpaid_amount'].toStringAsFixed(0)}',
              Colors.orange,
              Icons.pending,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              context,
              'Overdue',
              '\$${stats['overdue_amount'].toStringAsFixed(0)}',
              Colors.red,
              Icons.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInvoicesList(List<Invoice> invoices) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(invoicesProvider);
        ref.invalidate(invoiceStatsProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: invoices.length,
        itemBuilder: (context, index) {
          final invoice = invoices[index];
          return InvoiceCard(
            invoice: invoice,
            onTap: () => context.push('/invoices/${invoice.id}'),
            onEdit: () => context.push('/invoices/${invoice.id}/edit'),
            onDelete: () => _confirmDelete(context, invoice),
            onMarkAsSent: () => _markAsSent(invoice.id),
            onMarkAsPaid: () => _markAsPaid(invoice.id),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return EmptyState(
      icon: Icons.receipt_long,
      title: _selectedStatus == 'all'
          ? 'No invoices yet'
          : 'No ${_selectedStatus} invoices',
      description: _selectedStatus == 'all'
          ? 'Create your first invoice to get paid'
          : 'Try selecting a different status filter',
      actionLabel: _selectedStatus == 'all' ? 'Create Invoice' : null,
      onAction:
          _selectedStatus == 'all' ? () => context.push('/invoices/new') : null,
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return ErrorView(
      message: error.toString(),
      onRetry: () => ref.invalidate(invoicesProvider),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Invoices'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter invoice number...',
            prefixIcon: Icon(Icons.search),
          ),
          onSubmitted: (query) async {
            if (query.isNotEmpty) {
              Navigator.pop(context);
              final results = await ref
                  .read(invoiceControllerProvider.notifier)
                  .searchInvoices(query);
              if (context.mounted) {
                _showSearchResults(context, results);
              }
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showSearchResults(BuildContext context, List<Invoice> results) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Search Results (${results.length})',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: results.isEmpty
                  ? const Center(child: Text('No results found'))
                  : ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final invoice = results[index];
                        return ListTile(
                          title: Text(invoice.invoiceNumber),
                          subtitle: Text(
                            '\$${invoice.total.toStringAsFixed(2)}',
                          ),
                          trailing: Chip(
                            label: Text(InvoiceStatus.getLabel(invoice.status)),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/invoices/${invoice.id}');
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Invoice invoice) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Invoice'),
        content: Text(
          'Are you sure you want to delete ${invoice.invoiceNumber}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref
          .read(invoiceControllerProvider.notifier)
          .deleteInvoice(invoice.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${invoice.invoiceNumber} deleted')),
        );
      }
    }
  }

  Future<void> _markAsSent(String id) async {
    await ref.read(invoiceControllerProvider.notifier).markAsSent(id);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invoice marked as sent')));
    }
  }

  Future<void> _markAsPaid(String id) async {
    await ref.read(invoiceControllerProvider.notifier).markAsPaid(id);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invoice marked as paid')));
    }
  }

  void _handleMenuAction(BuildContext context, String value) {
    switch (value) {
      case 'profile':
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profile coming soon')));
        break;
      case 'settings':
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Settings coming soon')));
        break;
      case 'logout':
        context.go('/signin');
        break;
    }
  }

  void _handleBottomNavTap(BuildContext context, int index) {
    setState(() => _currentBottomIndex = index);
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/projects');
        break;
      case 2:
        context.go('/clients');
        break;
      case 3:
        // Already on invoices
        break;
    }
  }
}
