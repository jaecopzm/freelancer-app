import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/connection_test.dart';

/// Screen for testing Supabase connection
/// Add this to your router for debugging
class ConnectionTestScreen extends StatefulWidget {
  const ConnectionTestScreen({super.key});

  @override
  State<ConnectionTestScreen> createState() => _ConnectionTestScreenState();
}

class _ConnectionTestScreenState extends State<ConnectionTestScreen> {
  String _status = 'Ready to test connection';
  bool _isLoading = false;
  bool? _allPassed;

  @override
  void initState() {
    super.initState();
    // Auto-run test on screen load
    Future.delayed(const Duration(milliseconds: 500), _runTests);
  }

  Future<void> _runTests() async {
    setState(() {
      _status = 'Running connection tests...\n\nThis may take a few seconds.';
      _isLoading = true;
      _allPassed = null;
    });

    try {
      final result = await ConnectionTest.runTests();

      setState(() {
        _status = result.fullReport;
        _isLoading = false;
        _allPassed = result.allPassed;
      });
    } catch (e, stackTrace) {
      setState(() {
        _status = '❌ Test execution failed:\n\n$e\n\nStack trace:\n$stackTrace';
        _isLoading = false;
        _allPassed = false;
      });
    }
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _status));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Test results copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connection Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: _copyToClipboard,
            tooltip: 'Copy results',
          ),
        ],
      ),
      body: Column(
        children: [
          // Status indicator
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: _allPassed == null
                ? Colors.grey.shade200
                : _allPassed!
                ? Colors.green.shade100
                : Colors.red.shade100,
            child: Row(
              children: [
                if (_isLoading)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(
                    _allPassed == null
                        ? Icons.info_outline
                        : _allPassed!
                        ? Icons.check_circle
                        : Icons.error_outline,
                    color: _allPassed == null
                        ? Colors.grey.shade700
                        : _allPassed!
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _isLoading
                        ? 'Testing...'
                        : _allPassed == null
                        ? 'Ready to test'
                        : _allPassed!
                        ? 'All tests passed!'
                        : 'Some tests failed',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _allPassed == null
                          ? Colors.grey.shade700
                          : _allPassed!
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Test results
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SelectableText(
                  _status,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                ),
              ),
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _runTests,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Run Tests Again'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _copyToClipboard,
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy Results'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
