import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// Mirrors lib/constants/app_colors.dart so generated PDFs match the app's
// green/gold theme instead of the pdf package's default black-on-white.
class _PdfColors {
  static final primary = PdfColor.fromHex('#00462D');
  static final primaryContainer = PdfColor.fromHex('#1F5E43');
  static final secondary = PdfColor.fromHex('#FECE4B');
  static final error = PdfColor.fromHex('#C62828');
  static final successLight = PdfColor.fromHex('#E8F5E9');
  static final errorLight = PdfColor.fromHex('#FDECEA');
  static final grey = PdfColor.fromHex('#707973');
  static final outline = PdfColor.fromHex('#BFC9C1');
}

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
    final statusColor = isSafe ? _PdfColors.primaryContainer : _PdfColors.error;
    final statusBg = isSafe ? _PdfColors.successLight : _PdfColors.errorLight;

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
                _buildHeaderBanner("AFLALERT REPORT"),
                pw.SizedBox(height: 20),

                pw.Text(
                  "Date: ${DateTime.now()}",
                  style: pw.TextStyle(color: _PdfColors.grey),
                ),

                pw.SizedBox(height: 16),

                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(14),
                  decoration: pw.BoxDecoration(
                    color: statusBg,
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: statusColor, width: 1),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "Result: $result",
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        "Confidence: ${(confidence * 100).toStringAsFixed(1)}%",
                        style: pw.TextStyle(color: statusColor),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 20),

                pw.Text(
                  "Recommendations",
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: _PdfColors.primary,
                  ),
                ),

                pw.SizedBox(height: 10),

                ...recommendations.map((item) => _buildBullet(item, statusColor)),
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
          _buildHeaderBanner("AFLALERT SCAN HISTORY REPORT"),
          pw.SizedBox(height: 20),
          pw.Text("Generated: ${DateTime.now()}", style: pw.TextStyle(color: _PdfColors.grey)),
          pw.SizedBox(height: 4),
          pw.Text("Total scans: ${entries.length}", style: pw.TextStyle(color: _PdfColors.grey)),
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
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
              color: PdfColors.white,
            ),
            headerDecoration: pw.BoxDecoration(color: _PdfColors.primary),
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellHeight: 26,
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.center,
              2: pw.Alignment.center,
              3: pw.Alignment.center,
              4: pw.Alignment.centerLeft,
            },
            border: pw.TableBorder.all(color: _PdfColors.outline, width: 0.5),
          ),
        ],
      ),
    );

    return _saveToDownloadedReports(pdf, "History_Report");
  }

  pw.Widget _buildHeaderBanner(String title) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(vertical: 18, horizontal: 18),
      decoration: pw.BoxDecoration(
        color: _PdfColors.primary,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Expanded(
            child: pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: pw.BoxDecoration(
              color: _PdfColors.secondary,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Text(
              "AflAlert",
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: _PdfColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildBullet(String text, PdfColor accentColor) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            "•  ",
            style: pw.TextStyle(color: accentColor, fontWeight: pw.FontWeight.bold),
          ),
          pw.Expanded(child: pw.Text(text)),
        ],
      ),
    );
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
