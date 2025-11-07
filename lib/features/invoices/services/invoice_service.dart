import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/invoice.dart';

class InvoiceService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String? get _userId => _supabase.auth.currentUser?.id;

  /// Get all invoices for current user
  Future<List<Invoice>> getInvoices() async {
    try {
      final response = await _supabase
          .from('invoices')
          .select()
          .eq('user_id', _userId!)
          .order('created_at', ascending: false);

      return (response as List).map((json) => Invoice.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load invoices: ${e.toString()}');
    }
  }

  /// Get invoices by status
  Future<List<Invoice>> getInvoicesByStatus(String status) async {
    try {
      final response = await _supabase
          .from('invoices')
          .select()
          .eq('user_id', _userId!)
          .eq('status', status)
          .order('created_at', ascending: false);

      return (response as List).map((json) => Invoice.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load invoices: ${e.toString()}');
    }
  }

  /// Get invoices by client
  Future<List<Invoice>> getInvoicesByClient(String clientId) async {
    try {
      final response = await _supabase
          .from('invoices')
          .select()
          .eq('user_id', _userId!)
          .eq('client_id', clientId)
          .order('created_at', ascending: false);

      return (response as List).map((json) => Invoice.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load invoices: ${e.toString()}');
    }
  }

  /// Get invoices by project
  Future<List<Invoice>> getInvoicesByProject(String projectId) async {
    try {
      final response = await _supabase
          .from('invoices')
          .select()
          .eq('user_id', _userId!)
          .eq('project_id', projectId)
          .order('created_at', ascending: false);

      return (response as List).map((json) => Invoice.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load invoices: ${e.toString()}');
    }
  }

  /// Get single invoice by ID
  Future<Invoice> getInvoice(String id) async {
    try {
      final response = await _supabase
          .from('invoices')
          .select()
          .eq('id', id)
          .eq('user_id', _userId!)
          .single();

      return Invoice.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load invoice: ${e.toString()}');
    }
  }

  /// Get invoice items
  Future<List<InvoiceItem>> getInvoiceItems(String invoiceId) async {
    try {
      final response = await _supabase
          .from('invoice_items')
          .select()
          .eq('invoice_id', invoiceId)
          .order('sort_order', ascending: true);

      return (response as List)
          .map((json) => InvoiceItem.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load invoice items: ${e.toString()}');
    }
  }

  /// Create new invoice
  Future<Invoice> createInvoice(Invoice invoice) async {
    try {
      final data = invoice.toJson()
        ..['user_id'] = _userId
        ..remove('id'); // Let PostgreSQL generate the ID

      final response = await _supabase
          .from('invoices')
          .insert(data)
          .select()
          .single();

      return Invoice.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create invoice: ${e.toString()}');
    }
  }

  /// Create invoice items
  Future<List<InvoiceItem>> createInvoiceItems(List<InvoiceItem> items) async {
    try {
      final data = items.map((item) {
        final json = item.toJson();
        json.remove('id'); // Let PostgreSQL generate the ID
        return json;
      }).toList();

      final response = await _supabase
          .from('invoice_items')
          .insert(data)
          .select();

      return (response as List)
          .map((json) => InvoiceItem.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to create invoice items: ${e.toString()}');
    }
  }

  /// Update existing invoice
  Future<Invoice> updateInvoice(Invoice invoice) async {
    try {
      final data = invoice.toJson()
        ..['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('invoices')
          .update(data)
          .eq('id', invoice.id)
          .eq('user_id', _userId!)
          .select()
          .single();

      return Invoice.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update invoice: ${e.toString()}');
    }
  }

  /// Delete invoice
  Future<void> deleteInvoice(String id) async {
    try {
      // Delete invoice items first
      await _supabase.from('invoice_items').delete().eq('invoice_id', id);

      // Delete invoice
      await _supabase
          .from('invoices')
          .delete()
          .eq('id', id)
          .eq('user_id', _userId!);
    } catch (e) {
      throw Exception('Failed to delete invoice: ${e.toString()}');
    }
  }

  /// Mark invoice as sent
  Future<Invoice> markAsSent(String id) async {
    try {
      final response = await _supabase
          .from('invoices')
          .update({
            'status': InvoiceStatus.sent,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .eq('user_id', _userId!)
          .select()
          .single();

      return Invoice.fromJson(response);
    } catch (e) {
      throw Exception('Failed to mark invoice as sent: ${e.toString()}');
    }
  }

  /// Mark invoice as paid
  Future<Invoice> markAsPaid(String id) async {
    try {
      final response = await _supabase
          .from('invoices')
          .update({
            'status': InvoiceStatus.paid,
            'paid_date': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .eq('user_id', _userId!)
          .select()
          .single();

      return Invoice.fromJson(response);
    } catch (e) {
      throw Exception('Failed to mark invoice as paid: ${e.toString()}');
    }
  }

  /// Generate next invoice number
  Future<String> generateInvoiceNumber() async {
    try {
      final response = await _supabase
          .from('invoices')
          .select('invoice_number')
          .eq('user_id', _userId!)
          .order('created_at', ascending: false)
          .limit(1);

      if (response.isEmpty) {
        return 'INV-0001';
      }

      final lastNumber = response[0]['invoice_number'] as String;
      final number = int.tryParse(lastNumber.split('-').last) ?? 0;
      return 'INV-${(number + 1).toString().padLeft(4, '0')}';
    } catch (e) {
      return 'INV-0001';
    }
  }

  /// Search invoices
  Future<List<Invoice>> searchInvoices(String query) async {
    try {
      final response = await _supabase
          .from('invoices')
          .select()
          .eq('user_id', _userId!)
          .or('invoice_number.ilike.%$query%,notes.ilike.%$query%')
          .order('created_at', ascending: false);

      return (response as List).map((json) => Invoice.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search invoices: ${e.toString()}');
    }
  }

  /// Get invoice statistics
  Future<Map<String, dynamic>> getInvoiceStats() async {
    try {
      final invoices = await getInvoices();

      final totalRevenue = invoices
          .where((inv) => inv.status == InvoiceStatus.paid)
          .fold(0.0, (sum, inv) => sum + inv.total);

      final unpaidAmount = invoices
          .where(
            (inv) =>
                inv.status != InvoiceStatus.paid &&
                inv.status != InvoiceStatus.cancelled,
          )
          .fold(0.0, (sum, inv) => sum + inv.total);

      final overdueAmount = invoices
          .where((inv) => inv.isOverdue)
          .fold(0.0, (sum, inv) => sum + inv.total);

      return {
        'total_revenue': totalRevenue,
        'unpaid_amount': unpaidAmount,
        'overdue_amount': overdueAmount,
        'total_invoices': invoices.length,
        'paid_invoices': invoices
            .where((inv) => inv.status == InvoiceStatus.paid)
            .length,
        'unpaid_invoices': invoices
            .where(
              (inv) =>
                  inv.status != InvoiceStatus.paid &&
                  inv.status != InvoiceStatus.cancelled,
            )
            .length,
        'overdue_invoices': invoices.where((inv) => inv.isOverdue).length,
      };
    } catch (e) {
      throw Exception('Failed to get invoice stats: ${e.toString()}');
    }
  }
}
