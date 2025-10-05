import 'package:flutter/material.dart';

import '../modules/add_loan/add_loan_screen.dart';
import '../modules/loan_detail/loan_detail_screen.dart';
import '../modules/about/about_screen.dart';
import '../modules/loan_list/loan_list_screen.dart';

/// App routes configuration
class AppRoutes {
  static const String home = '/';
  static const String loanDetail = '/loan-detail';
  static const String addLoan = '/add-loan';
  static const String about = '/about';

  /// Get the route configuration for the app
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const LoanListScreen(),
          settings: settings,
        );
      
      case loanDetail:
        final args = settings.arguments as Map<String, dynamic>;
        final loanId = args['loanId'] as String;
        return MaterialPageRoute(
          builder: (_) => LoanDetailScreen(loanId: loanId),
          settings: settings,
        );
      
      case addLoan:
        return MaterialPageRoute(
          builder: (_) => const AddLoanScreen(),
          settings: settings,
        );
      case about:
        return MaterialPageRoute(
          builder: (_) => const AboutScreen(),
          settings: settings,
        );
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text(
                'Route not found: ${settings.name}',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        );
    }
  }

  /// Navigate to loan detail screen
  static void navigateToLoanDetail(BuildContext context, String loanId) {
    Navigator.pushNamed(
      context,
      loanDetail,
      arguments: {'loanId': loanId},
    );
  }

  /// Navigate to add loan screen
  static Future<dynamic> navigateToAddLoan(BuildContext context) {
    return Navigator.pushNamed(context, addLoan);
  }

  /// Navigate back to home screen
  static void navigateToHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      home,
      (route) => false,
    );
  }

  /// Navigate back
  static void navigateBack(BuildContext context) {
    Navigator.pop(context);
  }

  /// Navigate back with result
  static void navigateBackWithResult(BuildContext context, dynamic result) {
    Navigator.pop(context, result);
  }
}
