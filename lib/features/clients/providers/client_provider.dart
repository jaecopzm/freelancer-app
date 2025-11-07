import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/client.dart';
import '../services/client_service.dart';

final clientServiceProvider = Provider((ref) => ClientService());

final clientsProvider = FutureProvider<List<Client>>((ref) async {
  final service = ref.read(clientServiceProvider);
  return service.getClients();
});

final clientProvider = FutureProvider.family<Client, String>((ref, id) async {
  final service = ref.read(clientServiceProvider);
  return service.getClient(id);
});

class ClientNotifier extends Notifier<AsyncValue<List<Client>>> {
  @override
  AsyncValue<List<Client>> build() {
    loadClients();
    return const AsyncValue.loading();
  }

  Future<void> loadClients() async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(clientServiceProvider);
      final clients = await service.getClients();
      state = AsyncValue.data(clients);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createClient(Client client) async {
    try {
      final service = ref.read(clientServiceProvider);
      await service.createClient(client);
      await loadClients();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateClient(Client client) async {
    try {
      final service = ref.read(clientServiceProvider);
      await service.updateClient(client);
      await loadClients();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteClient(String id) async {
    try {
      final service = ref.read(clientServiceProvider);
      await service.deleteClient(id);
      await loadClients();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> searchClients(String query) async {
    if (query.isEmpty) {
      await loadClients();
      return;
    }
    
    state = const AsyncValue.loading();
    try {
      final service = ref.read(clientServiceProvider);
      final clients = await service.searchClients(query);
      state = AsyncValue.data(clients);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final clientNotifierProvider = NotifierProvider<ClientNotifier, AsyncValue<List<Client>>>(ClientNotifier.new);
