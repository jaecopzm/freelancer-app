import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/invoice.dart';
import '../services/invoice_service.dart';

/// Invoice service provider
final invoiceServiceProvider = Provider<InvoiceService>((ref) {
  return InvoiceService();
});

/// All invoices provider
final invoicesProvider = FutureProvider<List<Invoice>>((ref) async {
  final service = ref.watch(invoiceServiceProvider);
  return service.getInvoices();
});

/// Invoices by status provider
final invoicesByStatusProvider = FutureProvider.family<List<Invoice>, String>((
  ref,
  status,
) async {
  final service = ref.watch(invoiceServiceProvider);
  return service.getInvoicesByStatus(status);
});

/// Invoices by client provider
final invoicesByClientProvider = FutureProvider.family<List<Invoice>, String>((
  ref,
  clientId,
) async {
  final service = ref.watch(invoiceServiceProvider);
  return service.getInvoicesByClient(clientId);
});

/// Invoices by project provider
final invoicesByProjectProvider = FutureProvider.family<List<Invoice>, String>((
  ref,
  projectId,
) async {
  final service = ref.watch(invoiceServiceProvider);
  return service.getInvoicesByProject(projectId);
});

/// Single invoice provider
final invoiceProvider = FutureProvider.family<Invoice, String>((ref, id) async {
  final service = ref.watch(invoiceServiceProvider);
  return service.getInvoice(id);
});

/// Invoice items provider
final invoiceItemsProvider = FutureProvider.family<List<InvoiceItem>, String>((
  ref,
  invoiceId,
) async {
  final service = ref.watch(invoiceServiceProvider);
  return service.getInvoiceItems(invoiceId);
});

/// Invoice statistics provider
final invoiceStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(invoiceServiceProvider);
  return service.getInvoiceStats();
});

/// Invoice controller for CRUD operations
final invoiceControllerProvider =
    StateNotifierProvider<InvoiceController, AsyncValue<void>>((ref) {
      return InvoiceController(ref);
    });

class InvoiceController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  InvoiceController(this._ref) : super(const AsyncValue.data(null));

  InvoiceService get _service => _ref.read(invoiceServiceProvider);

  Future<Invoice> createInvoice(
    Invoice invoice,
    List<InvoiceItem> items,
  ) async {
    state = const AsyncValue.loading();
    try {
      final createdInvoice = await _service.createInvoice(invoice);

      // Create items with the invoice ID
      final itemsWithInvoiceId = items
          .map((item) => item.copyWith(invoiceId: createdInvoice.id))
          .toList();
      await _service.createInvoiceItems(itemsWithInvoiceId);

      _ref.invalidate(invoicesProvider);
      _ref.invalidate(invoiceStatsProvider);
      state = const AsyncValue.data(null);
      return createdInvoice;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> updateInvoice(Invoice invoice) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.updateInvoice(invoice);
      _ref.invalidate(invoicesProvider);
      _ref.invalidate(invoiceProvider(invoice.id));
      _ref.invalidate(invoiceStatsProvider);
    });
  }

  Future<void> deleteInvoice(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.deleteInvoice(id);
      _ref.invalidate(invoicesProvider);
      _ref.invalidate(invoiceStatsProvider);
    });
  }

  Future<void> markAsSent(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.markAsSent(id);
      _ref.invalidate(invoicesProvider);
      _ref.invalidate(invoiceProvider(id));
      _ref.invalidate(invoiceStatsProvider);
    });
  }

  Future<void> markAsPaid(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.markAsPaid(id);
      _ref.invalidate(invoicesProvider);
      _ref.invalidate(invoiceProvider(id));
      _ref.invalidate(invoiceStatsProvider);
    });
  }

  Future<List<Invoice>> searchInvoices(String query) async {
    return _service.searchInvoices(query);
  }

  Future<String> generateInvoiceNumber() async {
    return _service.generateInvoiceNumber();
  }
}
