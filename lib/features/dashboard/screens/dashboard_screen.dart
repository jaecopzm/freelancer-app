import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui';
import '../../auth/providers/auth_provider.dart';
import '../../auth/widgets/email_verification_banner.dart';
import '../../../shared/widgets/advanced_navbar.dart';
import '../../../shared/widgets/custom_bottom_navbar.dart';
import '../../invoices/providers/invoice_provider.dart';
import '../../projects/providers/project_provider.dart';
import '../../clients/providers/client_provider.dart';
import '../../time_tracking/providers/time_tracking_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Modern Dashboard with Glass Morphism and Data Visualization
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  int _currentBottomIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade900
          : Colors.grey.shade50,
      appBar: AdvancedNavBar(
        title: 'Dashboard',
        showSearch: true,
        showProfile: true,
        showNotifications: true,
        notificationCount: 0,
        onSearchTap: () => _showSearchDialog(context),
        onNotificationTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notifications coming soon')),
          );
        },
        onMenuItemSelected: (value) => _handleMenuAction(context, value),
      ),
      body: Column(
        children: [
          const EmailVerificationBanner(),
          Expanded(
            child: userProfile.when(
              data: (profile) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(todayEntriesProvider);
                      ref.invalidate(clientNotifierProvider);
                      ref.invalidate(projectsProvider);
                      ref.invalidate(invoiceStatsProvider);
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildWelcomeCard(context, profile),
                          const SizedBox(height: 20),
                          _buildFinancialOverview(context, ref),
                          const SizedBox(height: 20),
                          _buildQuickStats(context, ref),
                          const SizedBox(height: 20),
                          _buildSmartInsights(context, ref),
                          const SizedBox(height: 20),
                          _buildRecentActivity(context, ref),
                          const SizedBox(height: 20),
                          _buildQuickActions(context),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading dashboard',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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

  Widget _buildWelcomeCard(BuildContext context, dynamic profile) {
    final hour = DateTime.now().hour;
    String greeting = hour < 12
        ? 'Good morning'
        : hour < 17
        ? 'Good afternoon'
        : 'Good evening';

    return _GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$greeting, ${profile?.fullName ?? 'User'}! 👋',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('EEEE, MMMM d, y').format(DateTime.now()),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.wb_sunny, color: Colors.white, size: 32),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialOverview(BuildContext context, WidgetRef ref) {
    final invoiceStatsAsync = ref.watch(invoiceStatsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Financial Overview',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        invoiceStatsAsync.when(
          data: (stats) {
            final unpaidAmount =
                (stats['unpaid_amount'] as num?)?.toDouble() ?? 0.0;
            final paidAmount =
                (stats['paid_amount'] as num?)?.toDouble() ?? 0.0;
            final totalRevenue = unpaidAmount + paidAmount;

            return _GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _FinancialMetric(
                            label: 'Total Revenue',
                            value: '\$${totalRevenue.toStringAsFixed(0)}',
                            icon: Icons.trending_up,
                            color: Colors.green,
                            trend: '+12%',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _FinancialMetric(
                            label: 'Outstanding',
                            value: '\$${unpaidAmount.toStringAsFixed(0)}',
                            icon: Icons.pending_actions,
                            color: Colors.orange,
                            trend: '${stats['unpaid_count'] ?? 0} invoices',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 120,
                      child: _buildRevenueChart(paidAmount, unpaidAmount),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => _GlassCard(
            child: Container(
              height: 200,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            ),
          ),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildRevenueChart(double paid, double unpaid) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (paid + unpaid) * 1.2,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                switch (value.toInt()) {
                  case 0:
                    return const Text('Paid', style: TextStyle(fontSize: 12));
                  case 1:
                    return const Text(
                      'Pending',
                      style: TextStyle(fontSize: 12),
                    );
                  default:
                    return const Text('');
                }
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: paid,
                gradient: const LinearGradient(
                  colors: [Colors.green, Colors.lightGreen],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 40,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
              ),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: unpaid,
                gradient: const LinearGradient(
                  colors: [Colors.orange, Colors.amber],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 40,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, WidgetRef ref) {
    final todayEntriesAsync = ref.watch(todayEntriesProvider);
    final clientsAsync = ref.watch(clientNotifierProvider);
    final projectsAsync = ref.watch(projectsProvider);
    final invoiceStatsAsync = ref.watch(invoiceStatsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Icon(
                Icons.speed,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Quick Stats',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: todayEntriesAsync.when(
                data: (entries) {
                  final totalHours = entries.fold<double>(
                    0,
                    (sum, entry) => sum + entry.durationHours,
                  );
                  return _ModernStatCard(
                    icon: Icons.access_time,
                    title: 'Hours Today',
                    value: totalHours.toStringAsFixed(1),
                    color: Colors.blue,
                    onTap: () => context.push('/time-tracking'),
                  );
                },
                loading: () => _ModernStatCard(
                  icon: Icons.access_time,
                  title: 'Hours Today',
                  value: '...',
                  color: Colors.blue,
                ),
                error: (_, __) => _ModernStatCard(
                  icon: Icons.access_time,
                  title: 'Hours Today',
                  value: '0.0',
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: clientsAsync.when(
                data: (clients) => _ModernStatCard(
                  icon: Icons.people,
                  title: 'Clients',
                  value: clients.length.toString(),
                  color: Colors.green,
                  onTap: () => context.push('/clients'),
                ),
                loading: () => _ModernStatCard(
                  icon: Icons.people,
                  title: 'Clients',
                  value: '...',
                  color: Colors.green,
                ),
                error: (_, __) => _ModernStatCard(
                  icon: Icons.people,
                  title: 'Clients',
                  value: '0',
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: projectsAsync.when(
                data: (projects) {
                  final activeProjects = projects
                      .where((p) => p.status == 'active')
                      .length;
                  return _ModernStatCard(
                    icon: Icons.folder,
                    title: 'Projects',
                    value: activeProjects.toString(),
                    color: Colors.purple,
                    onTap: () => context.push('/projects'),
                  );
                },
                loading: () => _ModernStatCard(
                  icon: Icons.folder,
                  title: 'Projects',
                  value: '...',
                  color: Colors.purple,
                ),
                error: (_, __) => _ModernStatCard(
                  icon: Icons.folder,
                  title: 'Projects',
                  value: '0',
                  color: Colors.purple,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: invoiceStatsAsync.when(
                data: (stats) => _ModernStatCard(
                  icon: Icons.receipt,
                  title: 'Invoices',
                  value: (stats['unpaid_count'] ?? 0).toString(),
                  color: Colors.orange,
                  subtitle: 'pending',
                  onTap: () => context.push('/invoices'),
                ),
                loading: () => _ModernStatCard(
                  icon: Icons.receipt,
                  title: 'Invoices',
                  value: '...',
                  color: Colors.orange,
                ),
                error: (_, __) => _ModernStatCard(
                  icon: Icons.receipt,
                  title: 'Invoices',
                  value: '0',
                  color: Colors.orange,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSmartInsights(BuildContext context, WidgetRef ref) {
    final invoiceStatsAsync = ref.watch(invoiceStatsProvider);
    final todayEntriesAsync = ref.watch(todayEntriesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Smart Insights',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        invoiceStatsAsync.when(
          data: (stats) {
            final unpaidCount = stats['unpaid_count'] ?? 0;
            final insights = <Widget>[];

            if (unpaidCount > 0) {
              insights.add(
                _InsightCard(
                  icon: Icons.notification_important,
                  title: 'Outstanding Invoices',
                  message:
                      'You have $unpaidCount unpaid invoice${unpaidCount > 1 ? 's' : ''}',
                  actionLabel: 'Review',
                  color: Colors.orange,
                  onTap: () => context.push('/invoices'),
                ),
              );
            }

            return todayEntriesAsync.when(
              data: (entries) {
                final totalHours = entries.fold<double>(
                  0,
                  (sum, entry) => sum + entry.durationHours,
                );

                if (totalHours < 2 && DateTime.now().hour > 14) {
                  insights.add(
                    _InsightCard(
                      icon: Icons.timer,
                      title: 'Low Activity Today',
                      message:
                          'Only ${totalHours.toStringAsFixed(1)} hours logged today',
                      actionLabel: 'Start Timer',
                      color: Colors.blue,
                      onTap: () => context.push('/time-tracking'),
                    ),
                  );
                }

                if (insights.isEmpty) {
                  insights.add(
                    _InsightCard(
                      icon: Icons.check_circle,
                      title: 'All Caught Up!',
                      message: 'Everything looks good. Keep up the great work!',
                      color: Colors.green,
                    ),
                  );
                }

                return Column(children: insights);
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildRecentActivity(BuildContext context, WidgetRef ref) {
    final todayEntriesAsync = ref.watch(todayEntriesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Icon(
                Icons.history,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Recent Activity',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        _GlassCard(
          child: todayEntriesAsync.when(
            data: (entries) {
              if (entries.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.inbox, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(
                        'No activity today',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => context.push('/time-tracking'),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Start Tracking'),
                      ),
                    ],
                  ),
                );
              }

              final recentEntries = entries.take(5).toList();
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: recentEntries.length,
                separatorBuilder: (_, __) => const Divider(height: 24),
                itemBuilder: (context, index) {
                  final entry = recentEntries[index];
                  return _ActivityItem(
                    icon: Icons.timer,
                    title: entry.description ?? 'Time Entry',
                    subtitle: '${entry.durationHours.toStringAsFixed(2)} hours',
                    time: DateFormat('h:mm a').format(entry.startTime),
                    color: Colors.blue,
                  );
                },
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: Text('Unable to load activity')),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Icon(
                Icons.flash_on,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Quick Actions',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _QuickActionCard(
                icon: Icons.play_arrow,
                title: 'Start Timer',
                gradient: const LinearGradient(
                  colors: [Colors.blue, Colors.lightBlue],
                ),
                onTap: () => context.push('/time-tracking'),
              ),
              _QuickActionCard(
                icon: Icons.receipt_long,
                title: 'New Invoice',
                gradient: const LinearGradient(
                  colors: [Colors.purple, Colors.deepPurple],
                ),
                onTap: () => context.push('/invoices/new'),
              ),
              _QuickActionCard(
                icon: Icons.person_add,
                title: 'Add Client',
                gradient: const LinearGradient(
                  colors: [Colors.green, Colors.lightGreen],
                ),
                onTap: () => context.push('/clients/new'),
              ),
              _QuickActionCard(
                icon: Icons.folder_open,
                title: 'New Project',
                gradient: const LinearGradient(
                  colors: [Colors.orange, Colors.deepOrange],
                ),
                onTap: () => context.push('/projects/new'),
              ),
              _QuickActionCard(
                icon: Icons.analytics,
                title: 'Reports',
                gradient: const LinearGradient(
                  colors: [Colors.teal, Colors.cyan],
                ),
                onTap: () => context.push('/reports'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quick Search'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search clients, projects, invoices...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onSubmitted: (query) {
                Navigator.pop(context);
                if (query.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Searching for: $query')),
                  );
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String value) {
    switch (value) {
      case 'profile':
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profile coming soon')));
        break;
      case 'settings':
        context.push('/settings');
        break;
      case 'logout':
        ref.read(authControllerProvider.notifier).signOut();
        context.go('/signin');
        break;
    }
  }

  void _handleBottomNavTap(BuildContext context, int index) {
    setState(() => _currentBottomIndex = index);
    switch (index) {
      case 0:
        break;
      case 1:
        context.push('/projects');
        break;
      case 2:
        context.push('/clients');
        break;
      case 3:
        context.push('/invoices');
        break;
    }
  }
}

// ============================================================================
// WIDGET COMPONENTS
// ============================================================================

/// Glass morphism card with backdrop blur effect
class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const _GlassCard({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// Financial metric display with icon and trend
class _FinancialMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? trend;

  const _FinancialMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        if (trend != null) ...[
          const SizedBox(height: 4),
          Text(
            trend!,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade500),
          ),
        ],
      ],
    );
  }
}

/// Modern stat card with glass effect
class _ModernStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final String? subtitle;
  final VoidCallback? onTap;

  const _ModernStatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Insight card with actionable information
class _InsightCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final Color color;
  final VoidCallback? onTap;

  const _InsightCard({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (actionLabel != null && onTap != null)
              TextButton(onPressed: onTap, child: Text(actionLabel!)),
          ],
        ),
      ),
    );
  }
}

/// Activity timeline item
class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade500),
        ),
      ],
    );
  }
}

/// Quick action card with gradient
class _QuickActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final Gradient gradient;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            width: 120,
            decoration: BoxDecoration(
              gradient: widget.gradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: widget.gradient.colors.first.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icon, color: Colors.white, size: 36),
                const SizedBox(height: 12),
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
