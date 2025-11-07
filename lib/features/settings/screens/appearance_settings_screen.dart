import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/custom_navbar.dart';
import '../providers/settings_provider.dart';

class AppearanceSettingsScreen extends ConsumerStatefulWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  ConsumerState<AppearanceSettingsScreen> createState() =>
      _AppearanceSettingsScreenState();
}

class _AppearanceSettingsScreenState
    extends ConsumerState<AppearanceSettingsScreen> {
  String _selectedTheme = 'system';
  String _selectedTimeFormat = '12h';
  String _selectedDateFormat = 'MM/dd/yyyy';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await ref.read(userSettingsProvider.future);
    setState(() {
      _selectedTheme = settings.theme ?? 'system';
      _selectedTimeFormat = settings.timeFormat ?? '12h';
      _selectedDateFormat = settings.dateFormat ?? 'MM/dd/yyyy';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomNavBar(title: 'Appearance', showBackButton: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Theme'),
            subtitle: Text(
              _selectedTheme == 'system'
                  ? 'System Default'
                  : _selectedTheme == 'light'
                  ? 'Light'
                  : 'Dark',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemeDialog(),
          ),
          ListTile(
            title: const Text('Time Format'),
            subtitle: Text(
              _selectedTimeFormat == '12h' ? '12-hour' : '24-hour',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showTimeFormatDialog(),
          ),
          ListTile(
            title: const Text('Date Format'),
            subtitle: Text(_selectedDateFormat),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showDateFormatDialog(),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('System Default'),
              value: 'system',
              groupValue: _selectedTheme,
              onChanged: (value) {
                Navigator.pop(context);
                setState(() => _selectedTheme = value!);
                _saveSetting('theme', value!);
              },
            ),
            RadioListTile<String>(
              title: const Text('Light'),
              value: 'light',
              groupValue: _selectedTheme,
              onChanged: (value) {
                Navigator.pop(context);
                setState(() => _selectedTheme = value!);
                _saveSetting('theme', value!);
              },
            ),
            RadioListTile<String>(
              title: const Text('Dark'),
              value: 'dark',
              groupValue: _selectedTheme,
              onChanged: (value) {
                Navigator.pop(context);
                setState(() => _selectedTheme = value!);
                _saveSetting('theme', value!);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTimeFormatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Time Format'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('12-hour'),
              value: '12h',
              groupValue: _selectedTimeFormat,
              onChanged: (value) {
                Navigator.pop(context);
                setState(() => _selectedTimeFormat = value!);
                _saveSetting('time_format', value!);
              },
            ),
            RadioListTile<String>(
              title: const Text('24-hour'),
              value: '24h',
              groupValue: _selectedTimeFormat,
              onChanged: (value) {
                Navigator.pop(context);
                setState(() => _selectedTimeFormat = value!);
                _saveSetting('time_format', value!);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDateFormatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Date Format'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('MM/dd/yyyy'),
              value: 'MM/dd/yyyy',
              groupValue: _selectedDateFormat,
              onChanged: (value) {
                Navigator.pop(context);
                setState(() => _selectedDateFormat = value!);
                _saveSetting('date_format', value!);
              },
            ),
            RadioListTile<String>(
              title: const Text('dd/MM/yyyy'),
              value: 'dd/MM/yyyy',
              groupValue: _selectedDateFormat,
              onChanged: (value) {
                Navigator.pop(context);
                setState(() => _selectedDateFormat = value!);
                _saveSetting('date_format', value!);
              },
            ),
            RadioListTile<String>(
              title: const Text('yyyy-MM-dd'),
              value: 'yyyy-MM-dd',
              groupValue: _selectedDateFormat,
              onChanged: (value) {
                Navigator.pop(context);
                setState(() => _selectedDateFormat = value!);
                _saveSetting('date_format', value!);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveSetting(String key, String value) async {
    try {
      await ref
          .read(settingsControllerProvider.notifier)
          .updateSetting(key, value);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
