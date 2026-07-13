import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// A single row for the bulk scan-history export — kept independent of
// history_screen.dart's ScanRecord so this service doesn't have to import
// a screen.
class PdfReportEntry {
  final String title;
  final bool isSafe;
  final double confidence; // 0.0 - 1.0
  final String date;
  final String location;

  const PdfReportEntry({
    required this.title,
    required this.isSafe,
    required this.confidence,
    required this.date,
    required this.location,
  });
}

class PdfService {
  Future<File> generateReport({
    required bool isSafe,
    required double confidence,
  }) async {
    final pdf = pw.Document();

    final result = isSafe
        ? "Healthy Maize"
        : "Unsafe for Human Consumption";

    final recommendations = isSafe
        ? [
            "Safe for storage and immediate human consumption.",
            "Continue drying properly to keep moisture below 13%.",
            "Store in a cool, dry place away from ground contact.",
          ]
        : [
            "Do not consume or sell this maize.",
            "Isolate this batch immediately.",
            "Arrange certified laboratory testing.",
          ];

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "AFLALERT REPORT",
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

                pw.SizedBox(height: 20),

                pw.Text(
                  "Date: ${DateTime.now()}",
                ),

                pw.SizedBox(height: 20),

                pw.Text(
                  "Result: $result",
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

                pw.SizedBox(height: 10),

                pw.Text(
                  "Confidence: ${(confidence * 100).toStringAsFixed(1)}%",
                ),

                pw.SizedBox(height: 20),

                pw.Text(
                  "Recommendations",
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

                pw.SizedBox(height: 10),

                ...recommendations.map(
                  (item) => pw.Bullet(text: item),
                ),
              ],
            ),
          );
        },
      ),
    );

    return _saveToDownloadedReports(pdf, "Report");
  }

  // Generates a single PDF summarizing multiple scan records as a table —
  // used by the History screen's "Export PDF" button to export the
  // currently filtered list in one document.
  Future<File> generateBulkReport(List<PdfReportEntry> entries) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text(
            "AFLALERT SCAN HISTORY REPORT",
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text("Generated: ${DateTime.now()}"),
          pw.SizedBox(height: 8),
          pw.Text("Total scans: ${entries.length}"),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: ['Result', 'Status', 'Confidence', 'Date', 'Location'],
            data: entries
                .map((e) => [
                      e.title,
                      e.isSafe ? 'Healthy' : 'At Risk',
                      '${(e.confidence * 100).toStringAsFixed(0)}%',
                      e.date,
                      e.location,
                    ])
                .toList(),
          ),
        ],
      ),
    );

    return _saveToDownloadedReports(pdf, "History_Report");
  }

  Future<File> _saveToDownloadedReports(pw.Document pdf, String fileNamePrefix) async {
    final directory = await getApplicationDocumentsDirectory();

    final reportsFolder = Directory(
      p.join(directory.path, "Downloaded Reports"),
    );

    if (!reportsFolder.existsSync()) {
      reportsFolder.createSync(recursive: true);
    }

    final file = File(
      p.join(
        reportsFolder.path,
        "${fileNamePrefix}_${DateTime.now().millisecondsSinceEpoch}.pdf",
      ),
    );

    await file.writeAsBytes(await pdf.save());

    return file;
  }
}