// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import '../data/models/loan.dart';
import 'dart:js' as js;

class LoanExporterPlatform {
  const LoanExporterPlatform();

  String buildCsv(Loan loan) => _buildCsvSync(loan);

  bool downloadCsv(Loan loan) {
    try {
      final csv = buildCsv(loan);
      final bytes = html.Blob([csv], 'text/csv');
      final url = html.Url.createObjectUrlFromBlob(bytes);
      final anchor = html.AnchorElement(href: url)
        ..download = 'loan_${loan.borrowerName.replaceAll(' ', '_')}.csv'
        ..style.display = 'none';
      html.document.body!.children.add(anchor);
      anchor.click();
      anchor.remove();
      html.Url.revokeObjectUrl(url);
      return true;
    } catch (_) {
      return false;
    }
  }

  bool printLoan(Loan loan) {
    try {
      final htmlContent = _buildPrintHtml(loan);
  html.window.open('', '_blank');
      // Use JS interop for write sequence to ensure availability.
      js.context.callMethod('eval', [
        "(function(w,html){w.document.open();w.document.write(html);w.document.close();})(window.open('','_self'),'" +
            htmlContent.replaceAll("'", "\\'") +
            "')"
      ]);
  Future.delayed(const Duration(milliseconds: 150), () => html.window.print());
      return true;
    } catch (_) {
      return false;
    }
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

String _buildPrintHtml(Loan loan) {
  final rows = loan.payments.map((p) => '<tr>'
      '<td>${p.id}</td>'
      '<td>${p.amount}</td>'
      '<td>${p.date.toIso8601String()}</td>'
      '<td>${_escape(p.note ?? '')}</td>'
      '</tr>').join();

  return '''<!DOCTYPE html><html><head><meta charset="utf-8" />
<title>Loan ${loan.borrowerName}</title>
<style>
  body { font-family: Arial, sans-serif; padding: 24px; color:#222; }
  h1 { margin-top:0; }
  table { border-collapse: collapse; width:100%; margin-top:16px; }
  th, td { border:1px solid #999; padding:6px 8px; font-size:12px; }
  th { background:#f0f0f0; text-align:left; }
  .summary { margin-top:16px; }
  .summary div { margin:4px 0; }
</style>
</head><body>
<h1>Loan Report – ${_escape(loan.borrowerName)}</h1>
<div class="summary">
  <div><strong>Loan ID:</strong> ${loan.id}</div>
  <div><strong>Total Amount:</strong> ${loan.totalAmount}</div>
  <div><strong>Amount Paid:</strong> ${loan.amountPaid}</div>
  <div><strong>Remaining:</strong> ${loan.remainingBalance}</div>
  <div><strong>Daily Installment:</strong> ${loan.dailyInstallmentAmount}</div>
  <div><strong>Progress:</strong> ${(loan.progressPercentage * 100).toStringAsFixed(0)}%</div>
</div>
<h2>Payments (${loan.payments.length})</h2>
<table>
  <thead><tr><th>ID</th><th>Amount</th><th>Date</th><th>Note</th></tr></thead>
  <tbody>$rows</tbody>
</table>
</body></html>''';
}
