import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/advanced_navbar.dart';
import '../../../shared/widgets/custom_bottom_navbar.dart';
import '../models/time_entry.dart';
import '../providers/time_tracking_provider.dart';
import '../widgets/timer_widget.dart';
import '../widgets/time_entry_card.dart';
import '../../projects/providers/project_provider.dart';
import '../../clients/providers/client_provider.dart';

class TimeTrackingScreen extends ConsumerStatefulWidget {
  const TimeTrackingScreen({super.key});

  @override
  ConsumerState<TimeTrackingScreen> createState() => _TimeTrackingScreenState();
}

class _TimeTrackingScreenState extends ConsumerState<TimeTrackingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentBottomIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final runningEntryAsync = ref.watch(runningEntryProvider);
    final statsAsync = ref.watch(timeStatsProvider);

    return Scaffold(
      appBar: AdvancedNavBar(
        title: 'Time Tracking',
        showSearch: false,
        showProfile: true,
        showNotifications: true,
        notificationCount: 0,
        onMenuItemSelected: (value) => _handleMenuAction(context, value),
      ),
      body: Column(
        children: [
          // Stats bar
          statsAsync.when(
            data: (stats) => _buildStatsBar(context, stats),
            loading: () => const SizedBox(height: 80),
            error: (_, __) => const SizedBox(height: 80),
          ),

          // Timer widget
          Padding(
            padding: const EdgeInsets.all(16),
            child: runningEntryAsync.when(
              data: (runningEntry) => TimerWidget(
                runningEntry: runningEntry,
                onStart: () => _showStartTimerDialog(context),
                onStop: () => _stopTimer(runningEntry!.id),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) =>
                  TimerWidget(onStart: () => _showStartTimerDialog(context)),
            ),
          ),

          // Tabs
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Today'),
              Tab(text: 'This Week'),
              Tab(text: 'This Month'),
            ],
          ),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildEntriesList(ref.watch(todayEntriesProvider)),
                _buildEntriesList(ref.watch(weekEntriesProvider)),
                _buildEntriesList(ref.watch(monthEntriesProvider)),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showStartTimerDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Entry'),
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

  Widget _buildStatsBar(BuildContext context, TimeStats stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              context,
              'Total Hours',
              stats.totalHours.toStringAsFixed(1),
              Colors.blue,
              Icons.access_time,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              context,
              'Billable',
              stats.billableHours.toStringAsFixed(1),
              Colors.green,
              Icons.attach_money,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              context,
              'Earned',
              '\$${stats.totalAmount.toStringAsFixed(0)}',
              Colors.purple,
              Icons.trending_up,
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

  Widget _buildEntriesList(AsyncValue<List<TimeEntry>> entriesAsync) {
    return entriesAsync.when(
      data: (entries) {
        if (entries.isEmpty) {
          return _buildEmptyState();
        }
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(todayEntriesProvider);
            ref.invalidate(weekEntriesProvider);
            ref.invalidate(monthEntriesProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return TimeEntryCard(
                entry: entry,
                onEdit: () => _showEditDialog(entry),
                onDelete: () => _confirmDelete(entry),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(todayEntriesProvider);
                ref.invalidate(weekEntriesProvider);
                ref.invalidate(monthEntriesProvider);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timer_off, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 24),
          Text(
            'No time entries yet',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          Text(
            'Start tracking your time',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _showStartTimerDialog(BuildContext context) {
    final descriptionController = TextEditingController();
    String? selectedProjectId;
    String? selectedClientId;
    final hourlyRateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final projectsAsync = ref.watch(projectsProvider);
          final clientsAsync = ref.watch(clientNotifierProvider);

          return AlertDialog(
            title: const Text('Start Timer'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'What are you working on?',
                      border: OutlineInputBorder(),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  projectsAsync.when(
                    data: (projects) => DropdownButtonFormField<String>(
                      value: selectedProjectId,
                      decoration: const InputDecoration(
                        labelText: 'Project (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      items: projects.map((project) {
                        return DropdownMenuItem(
                          value: project.id,
                          child: Text(project.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => selectedProjectId = value);
                      },
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const SizedBox(),
                  ),
                  const SizedBox(height: 16),
                  clientsAsync.when(
                    data: (clients) => DropdownButtonFormField<String>(
                      value: selectedClientId,
                      decoration: const InputDecoration(
                        labelText: 'Client (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      items: clients.map((client) {
                        return DropdownMenuItem(
                          value: client.id,
                          child: Text(client.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => selectedClientId = value);
                      },
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const SizedBox(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: hourlyRateController,
                    decoration: const InputDecoration(
                      labelText: 'Hourly Rate (Optional)',
                      prefixText: '\$',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (descriptionController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a description'),
                      ),
                    );
                    return;
                  }

                  Navigator.pop(context);
                  await _startTimer(
                    description: descriptionController.text,
                    projectId: selectedProjectId,
                    clientId: selectedClientId,
                    hourlyRate: hourlyRateController.text.isEmpty
                        ? null
                        : double.tryParse(hourlyRateController.text),
                  );
                },
                child: const Text('Start'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _startTimer({
    required String description,
    String? projectId,
    String? clientId,
    double? hourlyRate,
  }) async {
    try {
      await ref
          .read(timeTrackingControllerProvider.notifier)
          .startTimer(
            description: description,
            projectId: projectId,
            clientId: clientId,
            hourlyRate: hourlyRate,
          );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Timer started')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _stopTimer(String id) async {
    try {
      await ref.read(timeTrackingControllerProvider.notifier).stopTimer(id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Timer stopped')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showEditDialog(TimeEntry entry) {
    // TODO: Implement edit dialog
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Edit coming soon')));
  }

  Future<void> _confirmDelete(TimeEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Time Entry'),
        content: Text('Are you sure you want to delete this entry?'),
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

    if (confirmed == true && mounted) {
      await ref
          .read(timeTrackingControllerProvider.notifier)
          .deleteTimeEntry(entry.id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Entry deleted')));
      }
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
        context.go('/invoices');
        break;
    }
  }
}
