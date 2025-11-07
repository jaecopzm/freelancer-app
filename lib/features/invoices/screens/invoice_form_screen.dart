import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/custom_navbar.dart';
import '../../clients/providers/client_provider.dart';
import '../../projects/providers/project_provider.dart';
import '../models/invoice.dart';
import '../providers/invoice_provider.dart';

class InvoiceFormScreen extends ConsumerStatefulWidget {
  final String? invoiceId;

  const InvoiceFormScreen({super.key, this.invoiceId});

  @override
  ConsumerState<InvoiceFormScreen> createState() => _InvoiceFormScreenState();
}

class _InvoiceFormScreenState extends ConsumerState<InvoiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _invoiceNumberController = TextEditingController();
  final _taxRateController = TextEditingController(text: '0');
  final _notesController = TextEditingController();
  final _paymentTermsController = TextEditingController();

  String? _selectedClientId;
  String? _selectedProjectId;
  DateTime _issueDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  bool _isLoading = false;

  final List<_LineItem> _lineItems = [_LineItem()];

  @override
  void initState() {
    super.initState();
    _generateInvoiceNumber();
    if (widget.invoiceId != null) {
      _loadInvoice();
    }
  }

  Future<void> _generateInvoiceNumber() async {
    final number = await ref
        .read(invoiceControllerProvider.notifier)
        .generateInvoiceNumber();
    _invoiceNumberController.text = number;
  }

  Future<void> _loadInvoice() async {
    // Load invoice data for editing
    final invoice = await ref.read(invoiceProvider(widget.invoiceId!).future);
    final items = await ref.read(
      invoiceItemsProvider(widget.invoiceId!).future,
    );

    _invoiceNumberController.text = invoice.invoiceNumber;
    _selectedClientId = invoice.clientId;
    _selectedProjectId = invoice.projectId;
    _issueDate = invoice.issueDate;
    _dueDate = invoice.dueDate;
    _taxRateController.text = invoice.taxRate.toString();
    _notesController.text = invoice.notes ?? '';
    _paymentTermsController.text = invoice.paymentTerms ?? '';

    _lineItems.clear();
    _lineItems.addAll(
      items.map(
        (item) => _LineItem(
          description: item.description,
          quantity: item.quantity,
          rate: item.rate,
        ),
      ),
    );

    setState(() {});
  }

  @override
  void dispose() {
    _invoiceNumberController.dispose();
    _taxRateController.dispose();
    _notesController.dispose();
    _paymentTermsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.invoiceId != null;
    final clientsAsync = ref.watch(clientNotifierProvider);
    final projectsAsync = ref.watch(projectsProvider);

    return Scaffold(
      appBar: CustomNavBar(
        title: isEdit ? 'Edit Invoice' : 'New Invoice',
        showBackButton: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Invoice number
            TextFormField(
              controller: _invoiceNumberController,
              decoration: const InputDecoration(
                labelText: 'Invoice Number',
                prefixIcon: Icon(Icons.tag),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter invoice number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Client selection
            clientsAsync.when(
              data: (clients) => DropdownButtonFormField<String>(
                value: _selectedClientId,
                decoration: const InputDecoration(
                  labelText: 'Client (Optional)',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                items: clients.map((client) {
                  return DropdownMenuItem(
                    value: client.id,
                    child: Text(client.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedClientId = value);
                },
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Failed to load clients'),
            ),
            const SizedBox(height: 16),

            // Project selection
            projectsAsync.when(
              data: (projects) => DropdownButtonFormField<String>(
                value: _selectedProjectId,
                decoration: const InputDecoration(
                  labelText: 'Project (Optional)',
                  prefixIcon: Icon(Icons.folder),
                  border: OutlineInputBorder(),
                ),
                items: projects.map((project) {
                  return DropdownMenuItem(
                    value: project.id,
                    child: Text(project.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedProjectId = value);
                },
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Failed to load projects'),
            ),
            const SizedBox(height: 16),

            // Dates
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Issue Date'),
                    subtitle: Text(_issueDate.toString().split(' ')[0]),
                    leading: const Icon(Icons.calendar_today),
                    onTap: () => _selectDate(context, true),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ListTile(
                    title: const Text('Due Date'),
                    subtitle: Text(_dueDate.toString().split(' ')[0]),
                    leading: const Icon(Icons.event),
                    onTap: () => _selectDate(context, false),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Line items section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Line Items',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () {
                    setState(() => _lineItems.add(_LineItem()));
                  },
                  icon: const Icon(Icons.add_circle),
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Line items list
            ..._lineItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _buildLineItemCard(context, item, index);
            }),

            const SizedBox(height: 24),

            // Tax rate
            TextFormField(
              controller: _taxRateController,
              decoration: const InputDecoration(
                labelText: 'Tax Rate (%)',
                prefixIcon: Icon(Icons.percent),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Totals summary
            _buildTotalsSummary(context),
            const SizedBox(height: 16),

            // Payment terms
            TextFormField(
              controller: _paymentTermsController,
              decoration: const InputDecoration(
                labelText: 'Payment Terms',
                hintText: 'e.g., Net 30, Due on receipt',
                prefixIcon: Icon(Icons.payment),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Additional information',
                prefixIcon: Icon(Icons.note),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            // Save button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveInvoice,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Text(isEdit ? 'Update Invoice' : 'Create Invoice'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineItemCard(BuildContext context, _LineItem item, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Item ${index + 1}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (_lineItems.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() => _lineItems.removeAt(index));
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: item.description,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (value) {
                item.description = value;
                setState(() {});
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: item.quantity.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Qty',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      item.quantity = double.tryParse(value) ?? 0;
                      setState(() {});
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: item.rate.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Rate',
                      prefixText: '\$',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      item.rate = double.tryParse(value) ?? 0;
                      setState(() {});
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Amount',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '\$${item.amount.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalsSummary(BuildContext context) {
    final subtotal = _calculateSubtotal();
    final taxRate = double.tryParse(_taxRateController.text) ?? 0;
    final taxAmount = subtotal * (taxRate / 100);
    final total = subtotal + taxAmount;

    return Card(
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTotalRow('Subtotal', subtotal),
            _buildTotalRow('Tax ($taxRate%)', taxAmount),
            const Divider(),
            _buildTotalRow('Total', total, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 14,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isTotal ? 18 : 14,
              color: isTotal ? Theme.of(context).primaryColor : null,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateSubtotal() {
    return _lineItems.fold(0, (sum, item) => sum + item.amount);
  }

  Future<void> _selectDate(BuildContext context, bool isIssueDate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isIssueDate ? _issueDate : _dueDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        if (isIssueDate) {
          _issueDate = date;
        } else {
          _dueDate = date;
        }
      });
    }
  }

  Future<void> _saveInvoice() async {
    if (!_formKey.currentState!.validate()) return;
    if (_lineItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one line item')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final subtotal = _calculateSubtotal();
      final taxRate = double.tryParse(_taxRateController.text) ?? 0;
      final taxAmount = subtotal * (taxRate / 100);
      final total = subtotal + taxAmount;

      final invoice = Invoice(
        id: widget.invoiceId ?? '',
        userId: '',
        clientId: _selectedClientId,
        projectId: _selectedProjectId,
        invoiceNumber: _invoiceNumberController.text,
        status: InvoiceStatus.draft,
        issueDate: _issueDate,
        dueDate: _dueDate,
        subtotal: subtotal,
        taxRate: taxRate,
        taxAmount: taxAmount,
        total: total,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        paymentTerms: _paymentTermsController.text.isEmpty
            ? null
            : _paymentTermsController.text,
        createdAt: DateTime.now(),
      );

      final items = _lineItems
          .asMap()
          .entries
          .map(
            (entry) => InvoiceItem(
              id: '',
              invoiceId: '',
              description: entry.value.description,
              quantity: entry.value.quantity,
              rate: entry.value.rate,
              amount: entry.value.amount,
              sortOrder: entry.key,
            ),
          )
          .toList();

      if (widget.invoiceId != null) {
        await ref
            .read(invoiceControllerProvider.notifier)
            .updateInvoice(invoice);
      } else {
        await ref
            .read(invoiceControllerProvider.notifier)
            .createInvoice(invoice, items);
      }

      if (mounted) {
        context.go('/invoices');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.invoiceId != null
                  ? 'Invoice updated successfully'
                  : 'Invoice created successfully',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

class _LineItem {
  String description;
  double quantity;
  double rate;

  _LineItem({this.description = '', this.quantity = 1, this.rate = 0});

  double get amount => quantity * rate;
}
