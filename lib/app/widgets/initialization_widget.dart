import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/loan_service.dart';
import '../modules/loan_list/loan_list_screen.dart';

/// Widget to handle async initialization of services
class InitializationWidget extends StatefulWidget {
  const InitializationWidget({super.key});

  @override
  State<InitializationWidget> createState() => _InitializationWidgetState();
}

class _InitializationWidgetState extends State<InitializationWidget> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  /// Initialize all services
  Future<void> _initializeServices() async {
    try {
      final loanService = Provider.of<LoanService>(context, listen: false);
      await loanService.initialize();
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      // Handle initialization error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error initializing app: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Initializing...'),
            ],
          ),
        ),
      );
    }

    return const LoanListScreen();
  }
}
