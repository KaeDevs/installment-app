import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instalment/app/utils/font_styles.dart';
import 'package:provider/provider.dart';

import '../../data/models/loan.dart';
import '../../services/loan_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';

/// Screen for adding a new loan
class AddLoanScreen extends StatefulWidget {
  const AddLoanScreen({super.key});

  @override
  State<AddLoanScreen> createState() => _AddLoanScreenState();
}

class _AddLoanScreenState extends State<AddLoanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _borrowerNameController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _dailyInstallmentController = TextEditingController();
  
  bool _isLoading = false;
  double _suggestedDailyAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _dailyInstallmentController.text = 
        Provider.of<LoanService>(context, listen: false)
            .getDefaultDailyInstallment()
            .toString();
  }

  @override
  void dispose() {
    _borrowerNameController.dispose();
    _totalAmountController.dispose();
    _dailyInstallmentController.dispose();
    super.dispose();
  }

  /// Calculate suggested daily installment
  void _calculateSuggestedAmount() {
    final totalAmount = double.tryParse(_totalAmountController.text) ?? 0.0;
    if (totalAmount > 0) {
      final loanService = Provider.of<LoanService>(context, listen: false);
      final suggested = loanService.calculateSuggestedDailyInstallment(totalAmount, 30); // Default 30 days
      setState(() {
        _suggestedDailyAmount = suggested;
      });
    }
  }

  /// Save the new loan
  Future<void> _saveLoan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final borrowerName = _borrowerNameController.text.trim();
      final totalAmount = double.parse(_totalAmountController.text);
      final dailyAmount = double.parse(_dailyInstallmentController.text);

      final loan = Loan(
        borrowerName: borrowerName,
        totalAmount: totalAmount,
        dailyInstallmentAmount: dailyAmount,
      );

      final loanService = Provider.of<LoanService>(context, listen: false);
      await loanService.addLoan(loan);

      if (mounted) {
        Navigator.pop(context, true); // Return success
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Error creating loan: $e');
    }
  }

  /// Show error message
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Loan', style: FontStyles.heading,),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Borrower name field
              TextFormField(
                controller: _borrowerNameController,
                decoration: const InputDecoration(
                  labelText: 'Borrower Name',
                  hintText: 'Enter borrower\'s full name',
                  prefixIcon: Icon(Icons.person),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter borrower name';
                  }
                  if (value.trim().length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Total amount field
              TextFormField(
                controller: _totalAmountController,
                decoration: const InputDecoration(
                  labelText: 'Total Loan Amount',
                  hintText: 'Enter total amount',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                onChanged: (value) => _calculateSuggestedAmount(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter total amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Daily installment field
              TextFormField(
                controller: _dailyInstallmentController,
                decoration: const InputDecoration(
                  labelText: 'Daily Installment Amount',
                  hintText: 'Enter daily payment amount',
                  prefixIcon: Icon(Icons.payment),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter daily amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Suggested amount
              if (_suggestedDailyAmount > 0)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.primaryColor),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Suggested daily amount: ${Formatters.formatCurrency(_suggestedDailyAmount)} (30 days)',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _dailyInstallmentController.text = 
                              _suggestedDailyAmount.toStringAsFixed(2);
                        },
                        child: const Text('Use'),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // Loan summary
              if (_totalAmountController.text.isNotEmpty && 
                  _dailyInstallmentController.text.isNotEmpty)
                _buildLoanSummary(),
              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveLoan,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Create Loan',
                          style: FontStyles.subheading,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build loan summary card
Widget _buildLoanSummary() {
  return ValueListenableBuilder<TextEditingValue>(
    valueListenable: _totalAmountController,
    builder: (context, totalValue, _) {
      return ValueListenableBuilder<TextEditingValue>(
        valueListenable: _dailyInstallmentController,
        builder: (context, dailyValue, _) {
          final totalAmount = double.tryParse(totalValue.text) ?? 0.0;
          final dailyAmount = double.tryParse(dailyValue.text) ?? 0.0;

          if (totalAmount <= 0 || dailyAmount <= 0) {
            return const SizedBox.shrink();
          }

          final totalDays = (totalAmount / dailyAmount).ceil();
          final estimatedCompletion =
              DateTime.now().add(Duration(days: totalDays));

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Loan Summary',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Total Days', '$totalDays days'),
                  _buildSummaryRow(
                    'Daily Payment',
                    Formatters.formatCurrency(dailyAmount),
                  ),
                  _buildSummaryRow(
                    'Estimated Completion',
                    Formatters.formatDate(estimatedCompletion),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'This loan will be completed in approximately '
                      '$totalDays days with daily payments of '
                      '${Formatters.formatCurrency(dailyAmount)}.',
                      style: TextStyle(
                        color: AppTheme.secondaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

  /// Build summary row
  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.cardSubtitleText,
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
