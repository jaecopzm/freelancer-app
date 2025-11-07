import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/client.dart';

class ClientService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String? get _userId => _supabase.auth.currentUser?.id;

  /// Get all clients for current user
  Future<List<Client>> getClients() async {
    try {
      final response = await _supabase
          .from('clients')
          .select()
          .eq('user_id', _userId!)
          .order('created_at', ascending: false);

      return (response as List).map((json) => Client.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load clients: ${e.toString()}');
    }
  }

  /// Get single client by ID
  Future<Client> getClient(String id) async {
    try {
      final response = await _supabase
          .from('clients')
          .select()
          .eq('id', id)
          .eq('user_id', _userId!)
          .single();

      return Client.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load client: ${e.toString()}');
    }
  }

  /// Create new client
  Future<Client> createClient(Client client) async {
    try {
      final data = client.toJson()..['user_id'] = _userId;
      final response = await _supabase
          .from('clients')
          .insert(data)
          .select()
          .single();

      return Client.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create client: ${e.toString()}');
    }
  }

  /// Update existing client
  Future<Client> updateClient(Client client) async {
    try {
      final data = client.toJson()
        ..['updated_at'] = DateTime.now().toIso8601String();
      
      final response = await _supabase
          .from('clients')
          .update(data)
          .eq('id', client.id)
          .eq('user_id', _userId!)
          .select()
          .single();

      return Client.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update client: ${e.toString()}');
    }
  }

  /// Delete client
  Future<void> deleteClient(String id) async {
    try {
      await _supabase
          .from('clients')
          .delete()
          .eq('id', id)
          .eq('user_id', _userId!);
    } catch (e) {
      throw Exception('Failed to delete client: ${e.toString()}');
    }
  }

  /// Search clients by name or company
  Future<List<Client>> searchClients(String query) async {
    try {
      final response = await _supabase
          .from('clients')
          .select()
          .eq('user_id', _userId!)
          .or('name.ilike.%$query%,company.ilike.%$query%')
          .order('created_at', ascending: false);

      return (response as List).map((json) => Client.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search clients: ${e.toString()}');
    }
  }
}
