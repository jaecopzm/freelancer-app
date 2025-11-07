import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/custom_navbar.dart';
import '../providers/settings_provider.dart';

class InvoiceSettingsScreen extends ConsumerStatefulWidget {
  const InvoiceSettingsScreen({super.key});

  @override
  ConsumerState<InvoiceSettingsScreen> createState() =>
      _InvoiceSettingsScreenState();
}

class _InvoiceSettingsScreenState extends ConsumerState<InvoiceSettingsScreen> {
  final _hourlyRateController = TextEditingController();
  final _taxRateController = TextEditingController();
  final _paymentTermsController = TextEditingController();
  final _invoicePrefixController = TextEditingController();
  String _selectedCurrency = 'USD';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await ref.read(userSettingsProvider.future);
    _hourlyRateController.text = settings.defaultHourlyRate?.toString() ?? '';
    _taxRateController.text = settings.defaultTaxRate?.toString() ?? '';
    _paymentTermsController.text =
        settings.defaultPaymentTerms?.toString() ?? '30';
    _invoicePrefixController.text = settings.invoicePrefix ?? 'INV';
    _selectedCurrency = settings.currency ?? 'USD';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomNavBar(
        title: 'Invoice Settings',
        showBackButton: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            initialValue: _selectedCurrency,
            decoration: const InputDecoration(
              labelText: 'Currency',
              prefixIcon: Icon(Icons.attach_money),
              border: OutlineInputBorder(),
            ),
            items: ['USD', 'EUR', 'GBP', 'CAD', 'AUD']
                .map(
                  (currency) =>
                      DropdownMenuItem(value: currency, child: Text(currency)),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedCurrency = value);
              }
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _hourlyRateController,
            decoration: const InputDecoration(
              labelText: 'Default Hourly Rate',
              prefixText: '\$',
              prefixIcon: Icon(Icons.schedule),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _taxRateController,
            decoration: const InputDecoration(
              labelText: 'Default Tax Rate',
              suffixText: '%',
              prefixIcon: Icon(Icons.percent),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _paymentTermsController,
            decoration: const InputDecoration(
              labelText: 'Default Payment Terms',
              suffixText: 'days',
              prefixIcon: Icon(Icons.calendar_today),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _invoicePrefixController,
            decoration: const InputDecoration(
              labelText: 'Invoice Prefix',
              hintText: 'INV',
              prefixIcon: Icon(Icons.tag),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _saveSettings,
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSettings() async {
    try {
      final currentSettings = await ref.read(userSettingsProvider.future);
      final updatedSettings = currentSettings.copyWith(
        currency: _selectedCurrency,
        defaultHourlyRate: double.tryParse(_hourlyRateController.text),
        defaultTaxRate: double.tryParse(_taxRateController.text),
        defaultPaymentTerms: int.tryParse(_paymentTermsController.text),
        invoicePrefix: _invoicePrefixController.text,
      );

      await ref
          .read(settingsControllerProvider.notifier)
          .updateSettings(updatedSettings);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
