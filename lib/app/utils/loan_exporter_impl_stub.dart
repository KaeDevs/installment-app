import '../data/models/loan.dart';

/// Stub (non-web) implementation of loan export utilities.
class LoanExporterPlatform {
  const LoanExporterPlatform();

  String buildCsv(Loan loan) => _buildCsvSync(loan);

  bool downloadCsv(Loan loan) {
    // Not supported on this platform yet.
    return false;
  }

  bool printLoan(Loan loan) {
    // Not supported on this platform yet.
    return false;
  }
}

String _buildCsvSync(Loan loan) {
  final buffer = StringBuffer();
  buffer.writeln('Loan ID,${loan.id}');
  buffer.writeln('Borrower,${_escape(loan.borrowerName)}');
  buffer.writeln('Total Amount,${loan.totalAmount}');
  buffer.writeln('Amount Paid,${loan.amountPaid}');
  buffer.writeln('Remaining,${loan.remainingBalance}');
  buffer.writeln('Daily Installment,${loan.dailyInstallmentAmount}');
  buffer.writeln();
  buffer.writeln('Payments:');
  buffer.writeln('Payment ID,Amount,Date,Note');
  for (final p in loan.payments) {
    buffer.writeln('${p.id},${p.amount},${p.date.toIso8601String()},${_escape(p.note ?? '')}');
  }
  return buffer.toString();
}

String _escape(String input) {
  if (input.contains(',') || input.contains('"') || input.contains('\n')) {
    return '"' + input.replaceAll('"', '""') + '"';
  }
  return input;
}
