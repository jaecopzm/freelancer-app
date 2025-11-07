import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/custom_navbar.dart';
import '../providers/settings_provider.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _reminderNotifications = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await ref.read(userSettingsProvider.future);
    setState(() {
      _emailNotifications = settings.emailNotifications ?? true;
      _pushNotifications = settings.pushNotifications ?? true;
      _reminderNotifications = settings.reminderNotifications ?? true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomNavBar(title: 'Notifications', showBackButton: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Email Notifications'),
            subtitle: const Text('Receive updates via email'),
            value: _emailNotifications,
            onChanged: (value) {
              setState(() => _emailNotifications = value);
              _saveSetting('email_notifications', value);
            },
          ),
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive push notifications'),
            value: _pushNotifications,
            onChanged: (value) {
              setState(() => _pushNotifications = value);
              _saveSetting('push_notifications', value);
            },
          ),
          SwitchListTile(
            title: const Text('Reminder Notifications'),
            subtitle: const Text('Get reminders for due invoices'),
            value: _reminderNotifications,
            onChanged: (value) {
              setState(() => _reminderNotifications = value);
              _saveSetting('reminder_notifications', value);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _saveSetting(String key, bool value) async {
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
