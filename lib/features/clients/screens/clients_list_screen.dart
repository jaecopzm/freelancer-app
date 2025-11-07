import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/advanced_navbar.dart';
import '../../../shared/widgets/custom_bottom_navbar.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_view.dart';
import '../providers/client_provider.dart';

class ClientsListScreen extends ConsumerStatefulWidget {
  const ClientsListScreen({super.key});

  @override
  ConsumerState<ClientsListScreen> createState() => _ClientsListScreenState();
}

class _ClientsListScreenState extends ConsumerState<ClientsListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  int _currentBottomIndex = 2; // Clients tab

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(clientNotifierProvider);

    return Scaffold(
      appBar: AdvancedNavBar(
        title: 'Clients',
        showSearch: true,
        showProfile: true,
        showNotifications: true,
        notificationCount: 0,
        onSearchTap: () => _focusSearch(),
        onMenuItemSelected: (value) => _handleMenuAction(context, value),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search clients...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                          ref
                              .read(clientNotifierProvider.notifier)
                              .loadClients();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
                if (value.isEmpty) {
                  ref.read(clientNotifierProvider.notifier).loadClients();
                } else {
                  ref
                      .read(clientNotifierProvider.notifier)
                      .searchClients(value);
                }
              },
            ),
          ),

          // Clients list
          Expanded(
            child: clientsAsync.when(
              data: (clients) {
                if (clients.isEmpty) {
                  return EmptyState(
                    icon: Icons.people_outline,
                    title: _searchQuery.isEmpty
                        ? 'No clients yet'
                        : 'No clients found',
                    description: _searchQuery.isEmpty
                        ? 'Add your first client to get started'
                        : 'Try adjusting your search',
                    actionLabel: _searchQuery.isEmpty ? 'Add Client' : null,
                    onAction: _searchQuery.isEmpty
                        ? () => context.push('/clients/new')
                        : null,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(clientNotifierProvider.notifier).loadClients(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: clients.length,
                    itemBuilder: (context, index) {
                      final client = clients[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: Hero(
                            tag: 'client_${client.id}',
                            child: CircleAvatar(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              child: Text(
                                client.name[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            client.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            client.company ?? client.email ?? 'No details',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Icon(
                            Icons.chevron_right,
                            color: Colors.grey.shade400,
                          ),
                          onTap: () => context.push('/clients/${client.id}'),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => ErrorView(
                message: error.toString(),
                onRetry: () =>
                    ref.read(clientNotifierProvider.notifier).loadClients(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/clients/new'),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Client'),
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

  void _focusSearch() {
    // Focus on the search field
    FocusScope.of(context).requestFocus(FocusNode());
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
        // Already on clients
        break;
      case 3:
        context.go('/invoices');
        break;
    }
  }
}
