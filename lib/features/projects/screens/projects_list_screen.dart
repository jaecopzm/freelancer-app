import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/advanced_navbar.dart';
import '../../../shared/widgets/custom_bottom_navbar.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/snackbar_helper.dart';
import '../models/project.dart';
import '../providers/project_provider.dart';
import '../widgets/project_card.dart';
import '../widgets/project_status_filter.dart';

class ProjectsListScreen extends ConsumerStatefulWidget {
  const ProjectsListScreen({super.key});

  @override
  ConsumerState<ProjectsListScreen> createState() => _ProjectsListScreenState();
}

class _ProjectsListScreenState extends ConsumerState<ProjectsListScreen> {
  String _selectedStatus = 'all';
  int _currentBottomIndex = 1; // Projects tab

  @override
  Widget build(BuildContext context) {
    final projectsAsync = _selectedStatus == 'all'
        ? ref.watch(projectsProvider)
        : ref.watch(projectsByStatusProvider(_selectedStatus));

    return Scaffold(
      appBar: AdvancedNavBar(
        title: 'Projects',
        showSearch: true,
        showProfile: true,
        showNotifications: true,
        notificationCount: 0,
        onSearchTap: () => _showSearchDialog(context),
        onMenuItemSelected: (value) => _handleMenuAction(context, value),
      ),
      body: Column(
        children: [
          // Status filter
          ProjectStatusFilter(
            selectedStatus: _selectedStatus,
            onStatusChanged: (status) {
              setState(() => _selectedStatus = status);
            },
          ),

          // Projects list
          Expanded(
            child: projectsAsync.when(
              data: (projects) {
                if (projects.isEmpty) {
                  return _buildEmptyState(context);
                }
                return _buildProjectsList(projects);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildErrorState(context, error),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/projects/new'),
        icon: const Icon(Icons.add),
        label: const Text('New Project'),
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

  Widget _buildProjectsList(List<Project> projects) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(projectsProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: projects.length,
        itemBuilder: (context, index) {
          final project = projects[index];
          return ProjectCard(
            project: project,
            onTap: () => context.push('/projects/${project.id}'),
            onEdit: () => context.push('/projects/${project.id}/edit'),
            onDelete: () => _confirmDelete(context, project),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return EmptyState(
      icon: Icons.folder_open,
      title: _selectedStatus == 'all'
          ? 'No projects yet'
          : 'No ${ProjectStatus.getLabel(_selectedStatus).toLowerCase()} projects',
      description: _selectedStatus == 'all'
          ? 'Create your first project to get started'
          : 'Try selecting a different status filter',
      actionLabel: _selectedStatus == 'all' ? 'Create Project' : null,
      onAction:
          _selectedStatus == 'all' ? () => context.push('/projects/new') : null,
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return ErrorView(
      message: error.toString(),
      onRetry: () => ref.invalidate(projectsProvider),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Projects'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter project name...',
            prefixIcon: Icon(Icons.search),
          ),
          onSubmitted: (query) async {
            if (query.isNotEmpty) {
              Navigator.pop(context);
              final results = await ref
                  .read(projectControllerProvider.notifier)
                  .searchProjects(query);
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

  void _showSearchResults(BuildContext context, List<Project> results) {
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
                        final project = results[index];
                        return ListTile(
                          title: Text(project.name),
                          subtitle: Text(project.description ?? ''),
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/projects/${project.id}');
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

  Future<void> _confirmDelete(BuildContext context, Project project) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text('Are you sure you want to delete "${project.name}"?'),
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
          .read(projectControllerProvider.notifier)
          .deleteProject(project.id);
      if (context.mounted) {
        SnackBarHelper.showSuccess(context, '${project.name} deleted');
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
        // Already on projects
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
