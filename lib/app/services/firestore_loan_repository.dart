import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/loan.dart';

/// Firestore repository for syncing loans for an authenticated user.
class FirestoreLoanRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userLoansCollection(String uid) =>
      _firestore.collection('users').doc(uid).collection('loans');

  Future<void> upsertLoan(String uid, Loan loan) async {
    await _userLoansCollection(uid).doc(loan.id).set(_loanToMap(loan));
  }

  Future<List<Loan>> fetchLoans(String uid) async {
    final snapshot = await _userLoansCollection(uid).get();
    return snapshot.docs.map((d) => _loanFromMap(d.data())).toList();
  }

  Future<void> deleteLoan(String uid, String loanId) async {
    await _userLoansCollection(uid).doc(loanId).delete();
  }

  /// Stream realtime loan changes for a user
  Stream<List<Loan>> realtimeLoans(String uid) {
    return _userLoansCollection(uid).snapshots().map(
      (snapshot) => snapshot.docs.map((d) => _loanFromMap(d.data())).toList(),
    );
  }

  Map<String, dynamic> _loanToMap(Loan loan) => {
        'id': loan.id,
        'borrowerName': loan.borrowerName,
        'totalAmount': loan.totalAmount,
        'dailyInstallmentAmount': loan.dailyInstallmentAmount,
        'createdAt': loan.createdAt.toIso8601String(),
        'isActive': loan.isActive,
        'payments': loan.payments
            .map((p) => {
                  'id': p.id,
                  'amount': p.amount,
                  'date': p.date.toIso8601String(),
                  'note': p.note,
                })
            .toList(),
      };

  Loan _loanFromMap(Map<String, dynamic> map) {
    return Loan(
      id: map['id'] as String?,
      borrowerName: map['borrowerName'] as String,
      totalAmount: (map['totalAmount'] as num).toDouble(),
      dailyInstallmentAmount: (map['dailyInstallmentAmount'] as num).toDouble(),
      createdAt: DateTime.parse(map['createdAt'] as String),
      isActive: map['isActive'] as bool? ?? true,
      payments: ((map['payments'] as List?) ?? [])
          .map((p) => Payment(
                id: p['id'] as String?,
                amount: (p['amount'] as num).toDouble(),
                date: DateTime.parse(p['date'] as String),
                note: p['note'] as String?,
              ))
          .toList(),
    );
  }
}
