import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../data/models/loan.dart';
import '../../services/loan_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/font_styles.dart';
import '../../utils/formatters.dart';
import '../../widgets/payment_button.dart';

/// Screen for viewing loan details and adding payments
class LoanDetailScreen extends StatefulWidget {
  final String loanId;

  const LoanDetailScreen({super.key, required this.loanId});

  @override
  State<LoanDetailScreen> createState() => _LoanDetailScreenState();
}

class _LoanDetailScreenState extends State<LoanDetailScreen> {
  Loan? _loan;
  bool _isLoading = true;
  bool _isAddingPayment = false;
  final _customAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLoan();
  }

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  /// Load loan details
  Future<void> _loadLoan() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final loanService = Provider.of<LoanService>(context, listen: false);
      final loan = loanService.getLoanById(widget.loanId);

      setState(() {
        _loan = loan;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Error loading loan: $e');
    }
  }

  /// Add payment with default amount
  Future<void> _addDefaultPayment() async {
    if (_loan == null) return;

    await _addPayment(_loan!.dailyInstallmentAmount);
  }

  /// Add payment with custom amount
  Future<void> _addCustomPayment() async {
    if (_loan == null) return;

    final amount = double.tryParse(_customAmountController.text);
    if (amount == null || amount <= 0) {
      _showErrorSnackBar('Please enter a valid amount');
      return;
    }

    await _addPayment(amount);
    _customAmountController.clear();
  }

  /// Add payment to the loan
  Future<void> _addPayment(double amount) async {
    if (_loan == null) return;

    setState(() {
      _isAddingPayment = true;
    });

    try {
      final payment = Payment(amount: amount);
      final loanService = Provider.of<LoanService>(context, listen: false);
      await loanService.addPayment(_loan!.id, payment);

      await _loadLoan(); // Reload loan to get updated data
      _showSuccessSnackBar('Payment added successfully!');
    } catch (e) {
      _showErrorSnackBar('Error adding payment: $e');
    } finally {
      setState(() {
        _isAddingPayment = false;
      });
    }
  }

  /// Show custom payment dialog
  void _showCustomPaymentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Custom Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _customAmountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _addCustomPayment();
            },
            child: const Text('Add Payment'),
          ),
        ],
      ),
    );
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

  /// Show success message
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.secondaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_loan == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loan Details')),
        body: const Center(child: Text('Loan not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_loan!.borrowerName, style: FontStyles.heading,),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLoan,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Loan summary card
            _buildLoanSummaryCard(),
            const SizedBox(height: 8),

            // Payment section
            Center(child: _buildPaymentSection()),
            const SizedBox(height: 16),

            // Payment history
            Center(child: _buildPaymentHistory()),
          ],
        ),
      ),
    );
  }

  /// Build loan summary card with enhanced vertical layout
  Widget _buildLoanSummaryCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Loan Summary',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildStatusChip(),
              ],
            ),
            const SizedBox(height: 24),

            // Progress section with larger visual emphasis
            _buildProgressSection(),
            const SizedBox(height: 24),

            // Amount details in vertical layout for better readability
            _buildAmountDetails(),
            const SizedBox(height: 20),

            // Days and daily payment info
            Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.secondaryColor.withAlpha(5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daily Payment: ${Formatters.formatCurrency(_loan!.dailyInstallmentAmount)}',
                  style: AppTheme.cardSubtitleText,
                ),
                Text(
                  '${_loan!.daysLeft} days left',
                  style: AppTheme.cardSubtitleText.copyWith(
                    color: _loan!.daysLeft <= 3 ? AppTheme.errorColor : null,
                    fontWeight: _loan!.daysLeft <= 3 ? FontWeight.bold : null,
                  ),
                ),
              ],
            ),
          ),
          ],
        ),
      ),
    );
  }

  /// Build enhanced progress section
  Widget _buildProgressSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.05),
            AppTheme.secondaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Loan Progress',
                style: AppTheme.cardSubtitleText.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _loan!.progressPercentage >= 1.0
                      ? AppTheme.secondaryColor.withOpacity(0.1)
                      : AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(_loan!.progressPercentage * 100).toInt()}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: _loan!.progressPercentage >= 1.0
                        ? AppTheme.secondaryColor
                        : AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _loan!.progressPercentage,
              backgroundColor: AppTheme.textSecondaryColor.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                _loan!.progressPercentage >= 1.0
                    ? AppTheme.secondaryColor
                    : AppTheme.primaryColor,
              ),
              minHeight: 16,
            ),
          ),
        ],
      ),
    );
  }

  /// Build amount details in vertical layout
  Widget _buildAmountDetails() {
    return Column(
      children: [
        // Total Amount Card
        _buildAmountCard(
          'Total Loan Amount',
          _loan!.totalAmount,
          Icons.account_balance_wallet_outlined,
          AppTheme.primaryColor,
          isTotal: true,
        ),
        const SizedBox(height: 12),
        
        // Row for Paid and Remaining
        Row(
          children: [
            // Amount Paid Card
            Expanded(
              child: _buildAmountCard(
                'Amount Paid',
                _loan!.amountPaid,
                Icons.check_circle_outline,
                AppTheme.secondaryColor,
              ),
            ),
            const SizedBox(width: 12),
            
            // Remaining Balance Card
            Expanded(
              child: _buildAmountCard(
                'Remaining Balance',
                _loan!.remainingBalance,
                Icons.warning_amber_outlined,
                AppTheme.errorColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build individual amount card
  Widget _buildAmountCard(
    String label,
    double amount,
    IconData icon,
    Color color, {
    bool isTotal = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: isTotal ? 24 : 20,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: isTotal ? 16 : 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(
              Formatters.formatCurrency(amount),
              style: TextStyle(
                fontSize: isTotal ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  /// Build days and daily payment info
  Widget _buildDaysInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.accentColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.payment_outlined,
                      color: AppTheme.accentColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Daily Payment',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                FittedBox(
                  child: Text(
                    Formatters.formatCurrency(_loan!.dailyInstallmentAmount),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppTheme.textSecondaryColor.withOpacity(0.2),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Days Remaining',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.calendar_today_outlined,
                      color: _loan!.daysLeft <= 3 
                          ? AppTheme.errorColor 
                          : AppTheme.accentColor,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${_loan!.daysLeft} days',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _loan!.daysLeft <= 3 
                        ? AppTheme.errorColor 
                        : AppTheme.accentColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build payment section
  Widget _buildPaymentSection() {
    if (_loan!.remainingBalance <= 0) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                Icons.check_circle,
                color: AppTheme.secondaryColor,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                'Loan Completed!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.secondaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'All payments have been collected.',
                style: AppTheme.cardSubtitleText,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Add Payment', style: FontStyles.body.copyWith(fontWeight: FontWeight.w900),),
        const SizedBox(height: 8),

        // Default payment button
        PaymentButton(
          amount: _loan!.dailyInstallmentAmount,
          onPressed: _addDefaultPayment,
          isLoading: _isAddingPayment,
          customText: 'Add Daily Payment',
        ),

        const SizedBox(height: 12),

        // Custom payment button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _showCustomPaymentDialog,
            icon: const Icon(Icons.edit),
            label: Text('Custom Amount', style: FontStyles.bodySmall,),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build payment history
  Widget _buildPaymentHistory() {
    final payments = _loan!.payments;

    if (payments.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(Icons.history, size: 48, color: AppTheme.textSecondaryColor),
              const SizedBox(height: 12),
              Text('No payments yet', style: AppTheme.cardSubtitleText),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Payment History',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Card(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final payment = payments[index];
              return Dismissible(
                key: ValueKey(payment.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Payment'),
                      content: const Text(
                        'Are you sure you want to delete this payment?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (direction) {
                  setState(() {
                    payments.removeAt(index);
                  });
                  context.read<LoanService>().deletePayment(
                    payment.id,
                    payment.id,
                  );
                },
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.secondaryColor.withOpacity(0.1),
                    child: Icon(Icons.payment, color: AppTheme.secondaryColor),
                  ),
                  title: Text(
                    Formatters.formatCurrency(payment.amount),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    Formatters.formatDateTime(payment.date),
                    style: AppTheme.cardSubtitleText,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (payment.note != null)
                        Icon(
                          Icons.note,
                          color: AppTheme.textSecondaryColor,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Build status chip
  Widget _buildStatusChip() {
    Color chipColor;
    String chipText;

    if (_loan!.remainingBalance <= 0) {
      chipColor = AppTheme.secondaryColor;
      chipText = 'Completed';
    } else if (_loan!.daysLeft <= 3) {
      chipColor = AppTheme.errorColor;
      chipText = 'Due Soon';
    } else {
      chipColor = AppTheme.accentColor;
      chipText = 'Active';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: chipColor, width: 1),
      ),
      child: Text(
        chipText,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: chipColor,
        ),
      ),
    );
  }
}