import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';

// Firestore sync (web only) - optional lazy import via interface
import 'firestore_loan_repository.dart';
import 'auth_service.dart';

import '../data/models/loan.dart';

/// Service class for managing loan operations
class LoanService extends ChangeNotifier {
  static const String _loanBoxName = 'loans';
  static const String _paymentBoxName = 'payments';
  
  late Box<Loan> _loanBox;
  late Box<Payment> _paymentBox;
  FirestoreLoanRepository? _firestoreRepo; // only initialized on web with auth
  String? _currentUid;
  StreamSubscription? _realtimeSub;

  bool get _isRemoteAttached => _firestoreRepo != null && _currentUid != null;

  /// Delete a payment from a loan (also sync remote if attached)
Future<void> deletePayment(String loanId, String paymentId) async {
  final loan = _loanBox.get(loanId);
  if (loan != null) {
    loan.payments.removeWhere((p) => p.id == paymentId);
    await _loanBox.put(loanId, loan);
    await _paymentBox.delete(paymentId);
    await _upsertRemote(loan); // reflect removal remotely (guarded internally)
    notifyListeners();
  }
}


  /// Initialize the service and open Hive boxes
  Future<void> initialize() async {
    _loanBox = await Hive.openBox<Loan>(_loanBoxName);
    _paymentBox = await Hive.openBox<Payment>(_paymentBoxName);
  }

  /// Attach Firestore repo after user logs in (web only)
  void attachRemote(AuthService auth) {
    if (kIsWeb && auth.isSignedIn) {
      _firestoreRepo ??= FirestoreLoanRepository();
      _currentUid = auth.user!.uid;
      // Initial pull + push any local-only loans then start realtime
      syncFromRemote(pushLocalAfter: true);
      _listenRealtime();
    }
  }

  void detachRemote() {
    _realtimeSub?.cancel();
    _realtimeSub = null;
    _currentUid = null;
  }

  void _listenRealtime() {
    if (_firestoreRepo == null || _currentUid == null) return;
    _realtimeSub?.cancel();
    _realtimeSub = _firestoreRepo!
        .realtimeLoans(_currentUid!)
        .listen((remoteLoans) async {
          await _reconcileRemote(remoteLoans);
        }, onError: (e) {
          // Swallow permission errors that can occur during sign-out race
          final msg = e.toString();
          if (msg.contains('permission-denied') || msg.contains('PERMISSION_DENIED')) {
            // Optionally detach to be safe
            _realtimeSub?.cancel();
            _realtimeSub = null;
          }
          // Ignore other errors here to avoid UI disruption
        }, cancelOnError: true);
  }

  Future<void> syncFromRemote({bool pushLocalAfter = false}) async {
    if (!_isRemoteAttached) return;
    final remoteLoans = await _firestoreRepo!.fetchLoans(_currentUid!);
    await _reconcileRemote(remoteLoans);
    if (pushLocalAfter) {
      await _pushLocalMissing(remoteLoans.map((l) => l.id).toSet());
    }
  }

  Future<void> _reconcileRemote(List<Loan> remoteLoans) async {
    final remoteIds = remoteLoans.map((l) => l.id).toSet();

    // Upsert remote loans locally
    for (final loan in remoteLoans) {
      await _loanBox.put(loan.id, loan);
      for (final p in loan.payments) {
        await _paymentBox.put(p.id, p);
      }
    }

    // Remove local loans not in remote (remote wins after login)
    final localIds = _loanBox.keys.cast<String>().toSet();
    for (final localId in localIds) {
      if (!remoteIds.contains(localId)) {
        await _loanBox.delete(localId);
      }
    }

    notifyListeners();
  }

  Future<void> _pushLocalMissing(Set<String> remoteIds) async {
    if (!_isRemoteAttached) return;
    for (final loan in _loanBox.values) {
      if (!remoteIds.contains(loan.id)) {
        try { await _firestoreRepo!.upsertLoan(_currentUid!, loan); } catch (_) {}
      }
    }
  }

  Future<void> _upsertRemote(Loan loan) async {
    if (_isRemoteAttached) {
      try { await _firestoreRepo!.upsertLoan(_currentUid!, loan); } catch (_) {/* swallow permission after sign-out */}
    }
  }

  Future<void> _deleteRemote(String loanId) async {
    if (_isRemoteAttached) {
      try { await _firestoreRepo!.deleteLoan(_currentUid!, loanId); } catch (_) {}
    }
  }

  /// Get all active loans
  List<Loan> getAllLoans() {
    return _loanBox.values.where((loan) => loan.isActive).toList();
  }

  /// Get all loans (including inactive)
  List<Loan> getAllLoansIncludingInactive() {
    return _loanBox.values.toList();
  }

  /// Get a specific loan by ID
  Loan? getLoanById(String id) {
    return _loanBox.get(id);
  }

  /// Add a new loan
  Future<void> addLoan(Loan loan) async {
    await _loanBox.put(loan.id, loan);
    await _upsertRemote(loan);
    notifyListeners();
  }

  /// Update an existing loan
  Future<void> updateLoan(Loan loan) async {
    await _loanBox.put(loan.id, loan);
    await _upsertRemote(loan);
    notifyListeners();
  }

  /// Delete a loan
  Future<void> deleteLoan(String loanId) async {
    await _loanBox.delete(loanId);
    await _deleteRemote(loanId);
    notifyListeners();
  }

  /// Mark a loan as inactive (soft delete)
  Future<void> deactivateLoan(String loanId) async {
    final loan = _loanBox.get(loanId);
    if (loan != null) {
      loan.isActive = false;
      await _loanBox.put(loanId, loan);
      await _upsertRemote(loan);
      notifyListeners();
    }
  }

  /// Add a payment to a loan
  Future<void> addPayment(String loanId, Payment payment) async {
    final loan = _loanBox.get(loanId);
    if (loan != null) {
      loan.addPayment(payment);
      await _loanBox.put(loanId, loan);
      await _paymentBox.put(payment.id, payment);
      await _upsertRemote(loan);
      notifyListeners();
    }
  }

  /// Get all payments for a specific loan
  List<Payment> getPaymentsForLoan(String loanId) {
    final loan = _loanBox.get(loanId);
    return loan?.payments ?? [];
  }

  /// Get recent payments across all loans
  List<Payment> getRecentPayments({int limit = 10}) {
    final allPayments = <Payment>[];
    
    for (final loan in _loanBox.values) {
      allPayments.addAll(loan.payments);
    }
    
    // Sort by date descending and take the most recent
    allPayments.sort((a, b) => b.date.compareTo(a.date));
    return allPayments.take(limit).toList();
  }

  /// Get loans that are overdue (no payment in the last day)
  List<Loan> getOverdueLoans() {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    
    return _loanBox.values.where((loan) {
      if (!loan.isActive || loan.remainingBalance <= 0) return false;
      
      // Check if there's a payment from today or yesterday
      final recentPayments = loan.payments.where(
        (payment) => payment.date.isAfter(yesterday)
      );
      
      return recentPayments.isEmpty;
    }).toList();
  }

  /// Get loans that are due today (no payment today)
  List<Loan> getLoansDueToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return _loanBox.values.where((loan) {
      if (!loan.isActive || loan.remainingBalance <= 0) return false;
      
      // Check if there's a payment from today
      final todayPayments = loan.payments.where(
        (payment) => payment.date.isAfter(today)
      );
      
      return todayPayments.isEmpty;
    }).toList();
  }

  /// Get total amount lent across all active loans
  double getTotalAmountLent() {
    return _loanBox.values
        .where((loan) => loan.isActive)
        .fold(0.0, (sum, loan) => sum + loan.totalAmount);
  }

  /// Get total amount collected across all active loans
  double getTotalAmountCollected() {
    return _loanBox.values
        .where((loan) => loan.isActive)
        .fold(0.0, (sum, loan) => sum + loan.amountPaid);
  }

  /// Get total remaining balance across all active loans
  double getTotalRemainingBalance() {
    return _loanBox.values
        .where((loan) => loan.isActive)
        .fold(0.0, (sum, loan) => sum + loan.remainingBalance);
  }

  /// Get default daily installment amount (can be customized)
  double getDefaultDailyInstallment() {
    return 100.0; // Default $100 per day
  }

  /// Calculate suggested daily installment based on total amount and days
  double calculateSuggestedDailyInstallment(double totalAmount, int numberOfDays) {
    if (numberOfDays <= 0) return totalAmount;
    return totalAmount / numberOfDays;
  }

  /// Search loans by borrower name
  List<Loan> searchLoansByName(String query) {
    if (query.isEmpty) return getAllLoans();
    
    return _loanBox.values.where((loan) {
      return loan.isActive && 
             loan.borrowerName.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  /// Get loan statistics
  Map<String, dynamic> getLoanStatistics() {
    final activeLoans = getAllLoans();
    final totalLoans = activeLoans.length;
    final completedLoans = activeLoans.where((loan) => loan.remainingBalance <= 0).length;
    final activeLoansCount = totalLoans - completedLoans;
    
    return {
      'totalLoans': totalLoans,
      'activeLoans': activeLoansCount,
      'completedLoans': completedLoans,
      'totalAmountLent': getTotalAmountLent(),
      'totalAmountCollected': getTotalAmountCollected(),
      'totalRemainingBalance': getTotalRemainingBalance(),
      'overdueLoans': getOverdueLoans().length,
      'loansDueToday': getLoansDueToday().length,
    };
  }

  /// Close the Hive boxes
  Future<void> close() async {
    detachRemote();
    await _loanBox.close();
    await _paymentBox.close();
  }
}
