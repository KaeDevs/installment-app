import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'loan.g.dart';

/// Model representing a loan with installment payment tracking
@HiveType(typeId: 0)
class Loan extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String borrowerName;

  @HiveField(2)
  final double totalAmount;

  @HiveField(3)
  final double dailyInstallmentAmount;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final List<Payment> payments;

  @HiveField(6)
  bool isActive;

  /// Constructor for creating a new loan
  Loan({
    String? id,
    required this.borrowerName,
    required this.totalAmount,
    required this.dailyInstallmentAmount,
    DateTime? createdAt,
    List<Payment>? payments,
    this.isActive = true,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        payments = payments ?? [];

  /// Get the total amount paid so far
  double get amountPaid {
    return payments.fold(0.0, (sum, payment) => sum + payment.amount);
  }

  /// Get the remaining balance
  double get remainingBalance {
    return totalAmount - amountPaid;
  }

  /// Get the number of days left based on daily installment
  int get daysLeft {
    if (dailyInstallmentAmount <= 0) return 0;
    return (remainingBalance / dailyInstallmentAmount).ceil();
  }

  /// Get the total number of days for the loan
  int get totalDays {
    if (dailyInstallmentAmount <= 0) return 0;
    return (totalAmount / dailyInstallmentAmount).ceil();
  }

  /// Get the number of days completed
  int get daysCompleted {
    return totalDays - daysLeft;
  }

  /// Get the progress percentage (0.0 to 1.0)
  double get progressPercentage {
    if (totalAmount <= 0) return 0.0;
    return amountPaid / totalAmount;
  }

  /// Add a new payment to the loan
  void addPayment(Payment payment) {
    payments.add(payment);
    payments.sort((a, b) => b.date.compareTo(a.date)); // Sort by date descending
  }

  /// Create a copy of the loan with updated fields
  Loan copyWith({
    String? id,
    String? borrowerName,
    double? totalAmount,
    double? dailyInstallmentAmount,
    DateTime? createdAt,
    List<Payment>? payments,
    bool? isActive,
  }) {
    return Loan(
      id: id ?? this.id,
      borrowerName: borrowerName ?? this.borrowerName,
      totalAmount: totalAmount ?? this.totalAmount,
      dailyInstallmentAmount: dailyInstallmentAmount ?? this.dailyInstallmentAmount,
      createdAt: createdAt ?? this.createdAt,
      payments: payments ?? this.payments,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// Model representing a payment made towards a loan
@HiveType(typeId: 1)
class Payment extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final String? note;

  /// Constructor for creating a new payment
  Payment({
    String? id,
    required this.amount,
    DateTime? date,
    this.note,
  })  : id = id ?? const Uuid().v4(),
        date = date ?? DateTime.now();

  /// Create a copy of the payment with updated fields
  Payment copyWith({
    String? id,
    double? amount,
    DateTime? date,
    String? note,
  }) {
    return Payment(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }
}
