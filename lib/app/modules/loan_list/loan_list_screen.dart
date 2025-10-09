import 'package:flutter/material.dart';
import 'package:instalment/app/utils/font_styles.dart';
import 'package:provider/provider.dart';

import '../../data/models/loan.dart';
import '../../routes/app_routes.dart';
import '../../services/loan_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../utils/responsive.dart';
import '../../widgets/loan_card.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_footer.dart';

/// Main screen displaying all active loans
class LoanListScreen extends StatefulWidget {
  const LoanListScreen({super.key});

  @override
  State<LoanListScreen> createState() => _LoanListScreenState();
}

class _LoanListScreenState extends State<LoanListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Loan> _filteredLoans = [];
  bool _isLoading = true;
  VoidCallback? _searchListener;

  // Sorting state
  LoanSortField _sortField = LoanSortField.createdAt; // default: newest first
  bool _ascending = false; // newest -> oldest

  @override
  void initState() {
    super.initState();
    _searchListener = () => setState(() {}); // rebuild suffix clear icon
    _searchController.addListener(_searchListener!);
    _loadLoans();
  }

  @override
  void dispose() {
    if (_searchListener != null) {
      _searchController.removeListener(_searchListener!);
    }
    _searchController.dispose();
    super.dispose();
  }

  /// Load all loans from the service
  Future<void> _loadLoans() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final loanService = Provider.of<LoanService>(context, listen: false);
      final loans = loanService.getAllLoans();
      
      setState(() {
        _filteredLoans = loans;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Error loading loans: $e');
    }
  }

  /// Filter loans based on search query
  void _filterLoans(String query) {
    if (query.isEmpty) {
      _loadLoans();
      return;
    }

    final loanService = Provider.of<LoanService>(context, listen: false);
    final filtered = loanService.searchLoansByName(query);
    
    setState(() {
      _filteredLoans = filtered;
      _sortLoans();
    });
  }

  void _sortLoans() {
    _filteredLoans.sort((a, b) {
      int cmp = 0;
      switch (_sortField) {
        case LoanSortField.borrower:
          cmp = a.borrowerName.toLowerCase().compareTo(b.borrowerName.toLowerCase());
          break;
        case LoanSortField.totalAmount:
          cmp = a.totalAmount.compareTo(b.totalAmount);
          break;
        case LoanSortField.amountPaid:
          cmp = a.amountPaid.compareTo(b.amountPaid);
          break;
        case LoanSortField.remaining:
          cmp = a.remainingBalance.compareTo(b.remainingBalance);
          break;
        case LoanSortField.progress:
          cmp = a.progressPercentage.compareTo(b.progressPercentage);
          break;
        case LoanSortField.daysLeft:
          cmp = a.daysLeft.compareTo(b.daysLeft);
          break;
        case LoanSortField.createdAt:
          cmp = a.createdAt.compareTo(b.createdAt);
          break;
      }
      return _ascending ? cmp : -cmp;
    });
  }

  void _changeSortField(LoanSortField field) {
    setState(() {
      if (_sortField == field) {
        // toggle direction if same field tapped again
        _ascending = !_ascending;
      } else {
        _sortField = field;
        // sensible defaults per field
        if (field == LoanSortField.createdAt) {
          _ascending = false; // newest first
        } else if (field == LoanSortField.borrower) {
          _ascending = true; // A->Z
        } else {
          _ascending = false; // high->low for numeric metrics
        }
      }
      _sortLoans();
    });
  }

  String _sortLabelShort(LoanSortField field) {
    switch (field) {
      case LoanSortField.borrower:
        return 'Name';
      case LoanSortField.totalAmount:
        return 'Total';
      case LoanSortField.amountPaid:
        return 'Paid';
      case LoanSortField.remaining:
        return 'Remain';
      case LoanSortField.progress:
        return 'Prog';
      case LoanSortField.daysLeft:
        return 'Days';
      case LoanSortField.createdAt:
        return 'Recent';
    }
  }

  /// Show error message
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
  backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show success message
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
  backgroundColor: AppColors.secondary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
Widget build(BuildContext context) {
  return ResponsiveLayout(
    appBar: AppHeader(
      onAddLoan: () async {
        final result = await AppRoutes.navigateToAddLoan(context);
        if (result == true) {
          _loadLoans();
          _showSuccessSnackBar('Loan added successfully!');
        }
      },
      onRefresh: _loadLoans,
    ),
    floatingActionButton: _buildResponsiveFAB(context),
    body: LayoutBuilder(
      builder: (ctx, constraints) {
        final width = constraints.maxWidth;
        final horizontalPad = width < 600
            ? 12.0
            : width < 960
                ? 18.0
                : 28.0;
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(horizontalPad, 12, horizontalPad, 4),
              child: Row(
                children: [
                  Expanded(child: _buildSearchBar()),
                  const SizedBox(width: 8),
                  _buildSortControl(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: horizontalPad, vertical: 4),
              child: _buildStatisticsCards(),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredLoans.isEmpty
                        ? _buildEmptyState()
                        : _buildAdaptiveCollection(width),
              ),
            ),
            const AppFooter(),
          ],
        );
      },
    ),
  );
}

  /// Build the search bar
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderMedium, width: 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            isDense: true,
            border: InputBorder.none,
            hintText: 'Search by borrower name...',
            hintStyle: TextStyle(color: AppColors.textTertiary),
            prefixIcon: const Icon(Icons.search, size: 20),
            prefixIconConstraints: const BoxConstraints(minWidth: 36),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    splashRadius: 18,
                    onPressed: () {
                      _searchController.clear();
                      _filterLoans('');
                    },
                  )
                : null,
          ),
          onChanged: _filterLoans,
        ),
      ),
    );
  }

  /// Build statistics cards
  Widget _buildStatisticsCards() {
    final loanService = Provider.of<LoanService>(context, listen: false);
    final stats = loanService.getLoanStatistics();

    return ResponsiveContainer(
      child: Responsive.isDesktop(context) 
          ? _buildDesktopStats(stats)
          : _buildMobileStats(stats),
    );
  }

  /// Build desktop statistics layout
  Widget _buildDesktopStats(Map<String, dynamic> stats) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Active Loans',
            stats['activeLoans'].toString(),
            Icons.account_balance_wallet,
            AppColors.primary,
          ),
        ),
        SizedBox(width: Responsive.getSpacing(context)),
        Expanded(
          child: _buildStatCard(
            'Total Collected',
            Formatters.formatCurrency(stats['totalAmountCollected']),
            Icons.attach_money,
            AppColors.secondary,
          ),
        ),
        SizedBox(width: Responsive.getSpacing(context)),
        Expanded(
          child: _buildStatCard(
            'Total Lent',
            Formatters.formatCurrency(stats['totalAmountLent']),
            Icons.trending_up,
            AppColors.accent,
          ),
        ),
        SizedBox(width: Responsive.getSpacing(context)),
        Expanded(
          child: _buildStatCard(
            'Remaining',
            Formatters.formatCurrency(stats['totalRemainingBalance']),
            Icons.pending,
            AppColors.error,
          ),
        ),
      ],
    );
  }

  /// Build mobile statistics layout
  Widget _buildMobileStats(Map<String, dynamic> stats) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Active Loans',
                stats['activeLoans'].toString(),
                Icons.account_balance_wallet,
                AppColors.primary,
              ),
            ),
            SizedBox(width: Responsive.getSpacing(context) / 2),
            Expanded(
              child: _buildStatCard(
                'Total Collected',
                Formatters.formatCurrency(stats['totalAmountCollected']),
                Icons.attach_money,
                AppColors.secondary,
              ),
            ),
          ],
        ),
        if (Responsive.isTablet(context)) ...[
          SizedBox(height: Responsive.getSpacing(context) / 2),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Lent',
                  Formatters.formatCurrency(stats['totalAmountLent']),
                  Icons.trending_up,
                  AppColors.accent,
                ),
              ),
              SizedBox(width: Responsive.getSpacing(context) / 2),
              Expanded(
                child: _buildStatCard(
                  'Remaining',
                  Formatters.formatCurrency(stats['totalRemainingBalance']),
                  Icons.pending,
                  AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// Build individual stat card
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderMedium, width: 1),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(.4), width: 1),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                letterSpacing: .2,
                color: color,
              ),
            ),
          const SizedBox(height: 4),
          Text(
            title,
            style: FontStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build responsive floating action button
  Widget _buildResponsiveFAB(BuildContext context) {
    if (Responsive.isMobile(context)) {
      return FloatingActionButton.extended(
        onPressed: () async {
          final result = await AppRoutes.navigateToAddLoan(context);
          if (result == true) {
            _loadLoans();
            _showSuccessSnackBar('Loan added successfully!');
          }
        },
  backgroundColor: AppColors.secondary,
        icon: const Icon(Icons.add, size: 26),
        label: const Text(
          "Add Loan",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );
    } else {
      // Desktop/tablet: Use a regular FAB
      return FloatingActionButton(
        onPressed: () async {
          final result = await AppRoutes.navigateToAddLoan(context);
          if (result == true) {
            _loadLoans();
            _showSuccessSnackBar('Loan added successfully!');
          }
        },
  backgroundColor: AppColors.secondary,
        tooltip: 'Add New Loan',
        child: const Icon(Icons.add, size: 28),
      );
    }
  }

  /// Adaptive collection builder (list or grid based on width)
  Widget _buildAdaptiveCollection(double width) {
    if (width < 600) return _buildMobileList();
    int columns;
    if (width < 960) {
      columns = 2;
    } else if (width < 1280) {
      columns = 3;
    } else if (width < 1600) {
      columns = 4;
    } else {
      columns = 5;
    }
    return _buildGrid(columns, width);
  }

  Widget _buildMobileList() => RefreshIndicator(
        onRefresh: _loadLoans,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
          itemCount: _filteredLoans.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final loan = _filteredLoans[index];
            return LoanCard(
              loan: loan,
              onTap: () => AppRoutes.navigateToLoanDetail(context, loan.id),
              onLongPress: () => _showLoanOptions(loan),
            );
          },
        ),
      );

    Widget _buildGrid(int columns, double width) {
      final gap = 16.0;
      final horizontalPadding = 12.0;
      final usableWidth = width - (horizontalPadding * 2) - (gap * (columns - 1));
      final cardWidth = usableWidth / columns;

      return RefreshIndicator(
        onRefresh: _loadLoans,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(horizontalPadding, 4, horizontalPadding, 16),
          child: Wrap(
            spacing: gap,
              runSpacing: gap,
            children: _filteredLoans.map((loan) {
              return SizedBox(
                width: cardWidth,
                child: _gridTile(loan),
              );
            }).toList(),
          ),
        ),
      );
    }

    Widget _gridTile(Loan loan) {
      final completed = loan.remainingBalance <= 0 || loan.progressPercentage >= 1.0;
      final dueSoon = !completed && loan.daysLeft <= 3;
      return InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => AppRoutes.navigateToLoanDetail(context, loan.id),
        onLongPress: () => _showLoanOptions(loan),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderMedium, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      loan.borrowerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.cardTitleText.copyWith(fontSize: 16),
                    ),
                  ),
                  _buildStatusChip(loan),
                ],
              ),
              const SizedBox(height: 10),
              _buildProgressBar(loan),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildAmountInfo('Total', loan.totalAmount,
                        AppTheme.amountText.copyWith(fontSize: 13)),
                  ),
                  Expanded(
                    child: _buildAmountInfo('Paid', loan.amountPaid,
                        AppTheme.amountText.copyWith(fontSize: 13, color: AppColors.success)),
                  ),
                  Expanded(
                    child: _buildAmountInfo('Remain', loan.remainingBalance < 0 ? 0 : loan.remainingBalance,
                        AppTheme.amountText.copyWith(fontSize: 13, color: AppColors.textSecondary)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daily: ${Formatters.formatCurrency(loan.dailyInstallmentAmount)}',
                    style: AppTheme.cardSubtitleText.copyWith(fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    completed ? 'Done' : '${loan.daysLeft} d',
                    style: AppTheme.cardSubtitleText.copyWith(
                      fontSize: 11,
                      color: completed
                          ? AppColors.secondary
                          : dueSoon
                              ? AppColors.error
                              : AppColors.textSecondary,
                      fontWeight: (completed || dueSoon) ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    Widget _buildSortControl() {
      final arrow = _ascending ? Icons.arrow_upward : Icons.arrow_downward;
      return Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderMedium, width: 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PopupMenuButton<LoanSortField>(
              tooltip: 'Sort field',
              position: PopupMenuPosition.under,
              onSelected: _changeSortField,
              itemBuilder: (_) => [
                _sortMenuItem(LoanSortField.createdAt, 'Created (Recent)') ,
                _sortMenuItem(LoanSortField.borrower, 'Borrower A-Z'),
                _sortMenuItem(LoanSortField.totalAmount, 'Total Amount'),
                _sortMenuItem(LoanSortField.amountPaid, 'Amount Paid'),
                _sortMenuItem(LoanSortField.remaining, 'Remaining'),
                _sortMenuItem(LoanSortField.progress, 'Progress'),
                _sortMenuItem(LoanSortField.daysLeft, 'Days Left'),
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.sort, size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      _sortLabelShort(_sortField),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => _changeSortField(_sortField),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: Icon(arrow, size: 16, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      );
    }

    PopupMenuItem<LoanSortField> _sortMenuItem(LoanSortField field, String label) {
      final selected = field == _sortField;
      return PopupMenuItem<LoanSortField>(
        value: field,
        child: Row(
          children: [
            if (selected)
              Icon(
                _ascending ? Icons.north_east : Icons.south_west,
                size: 16,
                color: AppColors.primary,
              )
            else
              const SizedBox(width: 16),
          ],
        ),
      );
    }
  /// Build status chip for loan
  Widget _buildStatusChip(Loan loan) {
    Color chipColor;
    String chipText;
    
    if (loan.remainingBalance <= 0) {
  chipColor = AppColors.secondary;
      chipText = 'Completed';
    } else if (loan.daysLeft <= 3) {
  chipColor = AppColors.error;
      chipText = 'Due Soon';
    } else {
  chipColor = AppColors.accent;
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

  /// Build progress bar for loan
  Widget _buildProgressBar(Loan loan) {
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
          backgroundColor: AppColors.textSecondary.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(
      loan.progressPercentage >= 1.0 
        ? AppColors.secondary 
        : AppColors.primary,
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
        FittedBox(
          child: Text(
            Formatters.formatCurrency(amount),
            style: amountStyle,
          ),
        ),
      ],
    );
  }

  /// Build empty state when no loans exist
  
Widget _buildEmptyState() {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.account_balance_wallet_outlined,
              size: 80, color: AppColors.textSecondary),
          const SizedBox(height: 20),
          Text(
            _searchController.text.isEmpty
                ? 'No loans yet'
                : 'No loans found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            _searchController.text.isEmpty
                ? 'Tap the button below to add your first loan.'
                : 'Try searching for a different name.',
            style: AppTheme.cardSubtitleText.copyWith(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

  /// Show loan options on long press
  void _showLoanOptions(Loan loan) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Loan'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to edit loan screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: const Text('Delete Loan', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(loan);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Show delete confirmation dialog
  void _showDeleteConfirmation(Loan loan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Loan'),
        content: Text('Are you sure you want to delete the loan for ${loan.borrowerName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteLoan(loan.id);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Delete a loan
  Future<void> _deleteLoan(String loanId) async {
    try {
      final loanService = Provider.of<LoanService>(context, listen: false);
      await loanService.deleteLoan(loanId);
      _loadLoans();
      _showSuccessSnackBar('Loan deleted successfully!');
    } catch (e) {
      _showErrorSnackBar('Error deleting loan: $e');
    }
  }
}

/// Sortable fields for loans list (top-level)
enum LoanSortField { createdAt, borrower, totalAmount, amountPaid, remaining, progress, daysLeft }
