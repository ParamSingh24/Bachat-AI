import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/expense.dart';
import 'ai_logic_engine.dart';

class PdfService {
  static Future<void> generateAndPrintReport(
      List<Expense> expenses, double totalExpense) async {
    final pdf = pw.Document();

    // Calculate breakdown
    final Map<String, double> breakdown = {};
    for (var e in expenses) {
      breakdown[e.category] = (breakdown[e.category] ?? 0) + e.amount;
    }

    final sortedBreakdown = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Build bar chart data
    final maxVal = sortedBreakdown.isEmpty ? 1.0 : sortedBreakdown.first.value;

    // Color palette for categories
    final List<PdfColor> barColors = [
      PdfColors.deepPurple,
      PdfColors.indigo,
      PdfColors.blue,
      PdfColors.teal,
      PdfColors.green,
      PdfColors.amber,
      PdfColors.orange,
      PdfColors.red,
    ];

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // ── HEADER ──────────────────────────────────────────
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: const pw.BoxDecoration(
                color: PdfColors.deepPurple,
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Bachat AI - Budget Summary Report',
                      style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white)),
                  pw.SizedBox(height: 4),
                  pw.Text(
                      'Generated on ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                      style: const pw.TextStyle(
                          fontSize: 11, color: PdfColors.white)),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // ── TOTAL SPEND CARD ─────────────────────────────────
            pw.Row(children: [
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(14),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.deepPurple50,
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(8)),
                    border: pw.Border.all(color: PdfColors.deepPurple200),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Total Spend',
                          style: pw.TextStyle(
                              fontSize: 12,
                              color: PdfColors.deepPurple,
                              fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 4),
                      pw.Text('Rs. ${totalExpense.toStringAsFixed(2)}',
                          style: pw.TextStyle(
                              fontSize: 22, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(width: 12),
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(14),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.indigo50,
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(8)),
                    border: pw.Border.all(color: PdfColors.indigo200),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Total Transactions',
                          style: pw.TextStyle(
                              fontSize: 12,
                              color: PdfColors.indigo,
                              fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 4),
                      pw.Text('${expenses.length}',
                          style: pw.TextStyle(
                              fontSize: 22, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ]),
            pw.SizedBox(height: 24),

            // ── BAR CHART - CATEGORY SPEND ────────────────────────
            pw.Text('Category Breakdown - Bar Chart',
                style: pw.TextStyle(
                    fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 12),
            pw.Container(
              height: 180,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius:
                    const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              padding: const pw.EdgeInsets.all(12),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                children: sortedBreakdown.asMap().entries.map((entry) {
                  final i = entry.key;
                  final e = entry.value;
                  final barH = maxVal > 0 ? (e.value / maxVal) * 130 : 0.0;
                  final color = barColors[i % barColors.length];
                  return pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      pw.Text('Rs.${e.value.toStringAsFixed(0)}',
                          style: pw.TextStyle(
                              fontSize: 7, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 2),
                      pw.Container(
                        width: 36,
                        height: barH,
                        decoration: pw.BoxDecoration(
                          color: color,
                          borderRadius:
                              const pw.BorderRadius.all(pw.Radius.circular(3)),
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Container(
                        width: 36,
                        child: pw.Text(e.key,
                            maxLines: 2,
                            style: const pw.TextStyle(fontSize: 7),
                            textAlign: pw.TextAlign.center),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
            pw.SizedBox(height: 24),

            // ── PIE LEGEND TABLE ──────────────────────────────────
            pw.Text('Spending Distribution',
                style: pw.TextStyle(
                    fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.TableHelper.fromTextArray(
              headers: ['Category', 'Amount (Rs.)', 'Share (%)'],
              data: sortedBreakdown.map((e) {
                double perc =
                    totalExpense > 0 ? (e.value / totalExpense) * 100 : 0;
                return [
                  e.key,
                  e.value.toStringAsFixed(2),
                  '${perc.toStringAsFixed(1)}%'
                ];
              }).toList(),
              headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.deepPurple),
              cellAlignment: pw.Alignment.centerLeft,
              cellStyle: const pw.TextStyle(fontSize: 11),
              rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
              oddRowDecoration:
                  const pw.BoxDecoration(color: PdfColors.grey100),
            ),
            pw.SizedBox(height: 24),

            // ── AI SUGGESTIONS ────────────────────────────────────
            pw.Text('AI Budget Suggestions',
                style: pw.TextStyle(
                    fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            ...sortedBreakdown.map((entry) {
              if (entry.value <= 0) return pw.SizedBox.shrink();
              final insight = BudgetStrategist.generateLocalSuggestion(
                  0, entry.key, entry.value);
              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 8),
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.indigo50,
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(6)),
                  border: pw.Border(
                    left: pw.BorderSide(
                        color: PdfColors.deepPurple, width: 3)),
                ),
                child: pw.Text('${'(' + entry.key + ')'} $insight',
                    style: const pw.TextStyle(fontSize: 11)),
              );
            }),
            pw.SizedBox(height: 24),

            // ── TRANSACTION LOG ───────────────────────────────────
            pw.Text('Detailed Transaction Log',
                style: pw.TextStyle(
                    fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.TableHelper.fromTextArray(
              headers: ['Date', 'Vendor', 'Category', 'Amount (Rs.)'],
              data: expenses
                  .map((e) => [
                        '${e.date.day}/${e.date.month}/${e.date.year}',
                        e.vendor,
                        e.category,
                        e.amount.toStringAsFixed(2),
                      ])
                  .toList(),
              headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.indigo),
              cellStyle: const pw.TextStyle(fontSize: 10),
              rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
              oddRowDecoration:
                  const pw.BoxDecoration(color: PdfColors.grey100),
            ),

            pw.SizedBox(height: 30),
            pw.Divider(),
            pw.Text('Generated by Bachat AI - Your Smart Financial Assistant',
                style: const pw.TextStyle(
                    fontSize: 9, color: PdfColors.grey600),
                textAlign: pw.TextAlign.center),
          ];
        },
      ),
    );

    await Printing.sharePdf(
        bytes: await pdf.save(), filename: 'bachat_ai_report.pdf');
  }
}
