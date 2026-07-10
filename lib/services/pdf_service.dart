import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

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
        "Report_${DateTime.now().millisecondsSinceEpoch}.pdf",
      ),
    );

    await file.writeAsBytes(await pdf.save());

    return file;
  }
}