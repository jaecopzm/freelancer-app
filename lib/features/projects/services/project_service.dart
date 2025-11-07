import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/project.dart';

class ProjectService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String? get _userId => _supabase.auth.currentUser?.id;

  /// Get all projects for current user
  Future<List<Project>> getProjects() async {
    try {
      final response = await _supabase
          .from('projects')
          .select()
          .eq('user_id', _userId!)
          .order('created_at', ascending: false);

      return (response as List).map((json) => Project.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load projects: ${e.toString()}');
    }
  }

  /// Get projects by client
  Future<List<Project>> getProjectsByClient(String clientId) async {
    try {
      final response = await _supabase
          .from('projects')
          .select()
          .eq('user_id', _userId!)
          .eq('client_id', clientId)
          .order('created_at', ascending: false);

      return (response as List).map((json) => Project.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load projects: ${e.toString()}');
    }
  }

  /// Get projects by status
  Future<List<Project>> getProjectsByStatus(String status) async {
    try {
      final response = await _supabase
          .from('projects')
          .select()
          .eq('user_id', _userId!)
          .eq('status', status)
          .order('created_at', ascending: false);

      return (response as List).map((json) => Project.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load projects: ${e.toString()}');
    }
  }

  /// Get single project by ID
  Future<Project> getProject(String id) async {
    try {
      final response = await _supabase
          .from('projects')
          .select()
          .eq('id', id)
          .eq('user_id', _userId!)
          .single();

      return Project.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load project: ${e.toString()}');
    }
  }

  /// Create new project
  Future<Project> createProject(Project project) async {
    try {
      final data = project.toJson()
        ..['user_id'] = _userId
        ..remove('id'); // Let PostgreSQL generate the ID

      final response = await _supabase
          .from('projects')
          .insert(data)
          .select()
          .single();

      return Project.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create project: ${e.toString()}');
    }
  }

  /// Update existing project
  Future<Project> updateProject(Project project) async {
    try {
      final data = project.toJson()
        ..['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('projects')
          .update(data)
          .eq('id', project.id)
          .eq('user_id', _userId!)
          .select()
          .single();

      return Project.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update project: ${e.toString()}');
    }
  }

  /// Delete project
  Future<void> deleteProject(String id) async {
    try {
      await _supabase
          .from('projects')
          .delete()
          .eq('id', id)
          .eq('user_id', _userId!);
    } catch (e) {
      throw Exception('Failed to delete project: ${e.toString()}');
    }
  }

  /// Search projects by name or description
  Future<List<Project>> searchProjects(String query) async {
    try {
      final response = await _supabase
          .from('projects')
          .select()
          .eq('user_id', _userId!)
          .or('name.ilike.%$query%,description.ilike.%$query%')
          .order('created_at', ascending: false);

      return (response as List).map((json) => Project.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search projects: ${e.toString()}');
    }
  }
}
