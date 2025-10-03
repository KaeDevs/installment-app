import 'package:flutter/material.dart';
import 'package:instalment/app/utils/font_styles.dart';
import 'package:provider/provider.dart';

import '../../data/models/loan.dart';
import '../../routes/app_routes.dart';
import '../../services/loan_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/loan_card.dart';

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

  @override
  void initState() {
    super.initState();
    _loadLoans();
  }

  @override
  void dispose() {
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
    });
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
  return Scaffold(
    resizeToAvoidBottomInset: false,
    backgroundColor: AppTheme.backgroundColor,
    appBar: AppBar(
      elevation: 0,
      backgroundColor: AppTheme.primaryColor,
      title:  Text(
        'Installment Tracker',
        style: FontStyles.heading,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, size: 26),
          onPressed: _loadLoans,
          tooltip: 'Refresh Loans',
        ),
      ],
    ),
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search bar section
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: _buildSearchBar(),
        ),

        // Stats section with background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, end:  Alignment.bottomCenter,colors: [
              Colors.white,
              Colors.white12,

            ])
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: _buildStatisticsCards(),
        ),

        const SizedBox(height: 8),

        // Loans list section
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredLoans.isEmpty
                    ? Center(child: _buildEmptyState())
                    : _buildLoansList(),
          ),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () async {
        final result = await AppRoutes.navigateToAddLoan(context);
        if (result == true) {
          _loadLoans();
          _showSuccessSnackBar('Loan added successfully!');
        }
      },
      backgroundColor: AppTheme.secondaryColor,
      icon: const Icon(Icons.add, size: 26),
      label: const Text(
        "Add Loan",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
  );
}

  /// Build the search bar
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by borrower name...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterLoans('');
                  },
                )
              : null,
        ),
        onChanged: _filterLoans,
      ),
    );
  }

  /// Build statistics cards
  Widget _buildStatisticsCards() {
    final loanService = Provider.of<LoanService>(context, listen: false);
    final stats = loanService.getLoanStatistics();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
     
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Active Loans',
              stats['activeLoans'].toString(),
              Icons.account_balance_wallet,
              AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Total Collected',
              Formatters.formatCurrency(stats['totalAmountCollected']),
              Icons.attach_money,
              AppTheme.secondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Build individual stat card
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            // style: AppTheme.cardSubtitleText.copyWith(fontSize: 14),
            style: FontStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

  /// Build the loans list
  Widget _buildLoansList() {
    return RefreshIndicator(
      onRefresh: _loadLoans,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _filteredLoans.length,
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
              size: 80, color: AppTheme.textSecondaryColor),
          const SizedBox(height: 20),
          Text(
            _searchController.text.isEmpty
                ? 'No loans yet'
                : 'No loans found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondaryColor,
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
              leading: const Icon(Icons.delete, color: AppTheme.errorColor),
              title: const Text('Delete Loan', style: TextStyle(color: AppTheme.errorColor)),
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
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
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
