import 'loan_exporter_impl_stub.dart'
  if (dart.library.html) 'loan_exporter_impl_web.dart';

import '../data/models/loan.dart';

/// Public facade for exporting/printing a single loan.
class LoanExporter {
  static final LoanExporterPlatform _platform = const LoanExporterPlatform();

  static String buildCsv(Loan loan) => _platform.buildCsv(loan);

  /// Attempts to trigger a CSV download (web) or returns false if unsupported.
  static bool downloadCsv(Loan loan) => _platform.downloadCsv(loan);

  /// Attempts to open a print dialog with a formatted report (web) or returns false.
  static bool printLoan(Loan loan) => _platform.printLoan(loan);
}
