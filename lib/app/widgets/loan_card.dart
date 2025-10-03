import 'package:flutter/material.dart';

import '../data/models/loan.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

/// Reusable widget for displaying loan information in a card format
class LoanCard extends StatelessWidget {
  final Loan loan;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const LoanCard({
    super.key,
    required this.loan,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with borrower name and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      loan.borrowerName,
                      style: AppTheme.cardTitleText,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusChip(),
                ],
              ),
              const SizedBox(height: 12),
              
              // Progress bar
              _buildProgressBar(),
              const SizedBox(height: 12),
              
              // Amount details
              Row(
                children: [
                  Expanded(
                    child: _buildAmountInfo(
                      'Total',
                      loan.totalAmount,
                      AppTheme.amountText,
                    ),
                  ),
                  Expanded(
                    child: _buildAmountInfo(
                      'Paid',
                      loan.amountPaid,
                      AppTheme.amountText.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 92, 132, 93),
                      ),
                    ),
                  ),
                  // Expanded(
                  //   child: _buildAmountInfo(
                  //     'Remaining',
                  //     loan.remainingBalance,
                  //     const TextStyle(
                  //       fontSize: 18,
                  //       fontWeight: FontWeight.bold,
                  //       color: AppTheme.errorColor,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Days information
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daily: ${Formatters.formatCurrency(loan.dailyInstallmentAmount)}',
                    style: AppTheme.cardSubtitleText,
                  ),
                  Text(
                    '${loan.daysLeft} days left',
                    style: AppTheme.cardSubtitleText.copyWith(
                      color: loan.daysLeft <= 3 ? AppTheme.errorColor : null,
                      fontWeight: loan.daysLeft <= 3 ? FontWeight.bold : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the status chip showing loan status
  Widget _buildStatusChip() {
    Color chipColor;
    String chipText;
    
    if (loan.remainingBalance <= 0) {
      chipColor = AppTheme.secondaryColor;
      chipText = 'Completed';
    } else if (loan.daysLeft <= 3) {
      chipColor = AppTheme.errorColor;
      chipText = 'Due Soon';
    } else {
      chipColor = AppTheme.accentColor;
      chipText = 'Active';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor, width: 1),
      ),
      child: Text(
        chipText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: chipColor,
        ),
      ),
    );
  }

  /// Build the progress bar showing payment progress
  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: AppTheme.cardSubtitleText,
            ),
            Text(
              '${(loan.progressPercentage * 100).toInt()}%',
              style: AppTheme.cardSubtitleText.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: loan.progressPercentage,
          backgroundColor: AppTheme.textSecondaryColor.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(
            loan.progressPercentage >= 1.0 
                ? AppTheme.secondaryColor 
                : AppTheme.primaryColor,
          ),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  /// Build amount information display
  Widget _buildAmountInfo(String label, double amount, TextStyle amountStyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.cardSubtitleText,
        ),
        const SizedBox(height: 2),
        Text(
          Formatters.formatCurrency(amount),
          style: amountStyle,
        ),
      ],
    );
  }
}
