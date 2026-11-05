
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  String _result = 'Not tested yet';
  bool _isLoading = false;

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _result = 'Connecting to backend...';
    });

    final result = await ApiService.checkHealth();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _result = result.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backend Connection Test'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_result, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _testConnection,
                child: Text(
                  _isLoading ? 'Testing...' : 'Test Backend Connection',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
