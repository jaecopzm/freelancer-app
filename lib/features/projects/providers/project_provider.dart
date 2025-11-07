import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/project.dart';
import '../services/project_service.dart';

/// Project service provider
final projectServiceProvider = Provider<ProjectService>((ref) {
  return ProjectService();
});

/// All projects provider
final projectsProvider = FutureProvider<List<Project>>((ref) async {
  final service = ref.watch(projectServiceProvider);
  return service.getProjects();
});

/// Projects by status provider
final projectsByStatusProvider = FutureProvider.family<List<Project>, String>((
  ref,
  status,
) async {
  final service = ref.watch(projectServiceProvider);
  return service.getProjectsByStatus(status);
});

/// Projects by client provider
final projectsByClientProvider = FutureProvider.family<List<Project>, String>((
  ref,
  clientId,
) async {
  final service = ref.watch(projectServiceProvider);
  return service.getProjectsByClient(clientId);
});

/// Single project provider
final projectProvider = FutureProvider.family<Project, String>((ref, id) async {
  final service = ref.watch(projectServiceProvider);
  return service.getProject(id);
});

/// Project controller for CRUD operations
final projectControllerProvider =
    StateNotifierProvider<ProjectController, AsyncValue<void>>((ref) {
      return ProjectController(ref);
    });

class ProjectController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  ProjectController(this._ref) : super(const AsyncValue.data(null));

  ProjectService get _service => _ref.read(projectServiceProvider);

  Future<void> createProject(Project project) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.createProject(project);
      _ref.invalidate(projectsProvider);
    });
  }

  Future<void> updateProject(Project project) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.updateProject(project);
      _ref.invalidate(projectsProvider);
      _ref.invalidate(projectProvider(project.id));
    });
  }

  Future<void> deleteProject(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.deleteProject(id);
      _ref.invalidate(projectsProvider);
    });
  }

  Future<List<Project>> searchProjects(String query) async {
    return _service.searchProjects(query);
  }
}
