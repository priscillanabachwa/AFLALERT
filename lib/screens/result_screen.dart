import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/report_model.dart';
import '../services/location_service.dart';
import '../services/pdf_service.dart';
import '../services/report_storage_service.dart';
import '../widgets/pdf_export_dialog.dart';
import 'analysis_screen.dart';

class ResultsScreenArgs {
  final bool isSafe;
  final double confidence;
  final String? analysisLabel;

  const ResultsScreenArgs({
    required this.isSafe,
    required this.confidence,
    this.analysisLabel,
  });
}

class RecommendationSource {
  final String text;
  final String sourceName;
  final Color badgeBg;
  final Color badgeText;

  const RecommendationSource({
    required this.text,
    required this.sourceName,
    required this.badgeBg,
    required this.badgeText,
  });
}

class ResultsScreen extends StatelessWidget {
  final bool isSafe; // true = Healthy Maize, false = Contaminated
  final double confidence; // 0.0 - 1.0
  final String? analysisLabel;

  const ResultsScreen({
    super.key,
    required this.isSafe,
    required this.confidence,
    this.analysisLabel,
  });

  // ---- Palette matched to the shared AppColors theme (registration screen) ----
  static const pageBg = AppColors.logoCream;
  static const cardBg = AppColors.surface;
  static const textPrimary = AppColors.text;
  static const textMuted = AppColors.grey;

  // Safe (green) accents
  static const safeIconBg = AppColors.primaryContainer;
  static const safeBoxBg = AppColors.successLight;
  static const safeCheckColor = AppColors.primaryContainer;
  static const safeHeading = AppColors.primaryContainer;

  // Unsafe (red) accents
  static const unsafeIconBg = AppColors.error;
  static const unsafeBoxBg = AppColors.errorLight;
  static const unsafeCheckColor = AppColors.error;
  static const unsafeHeading = AppColors.error;

  Color get iconBg => isSafe ? safeIconBg : unsafeIconBg;
  Color get boxBg => isSafe ? safeBoxBg : unsafeBoxBg;
  Color get checkColor => isSafe ? safeCheckColor : unsafeCheckColor;
  Color get boxTextColor => textPrimary;
  Color get headingColor => isSafe ? safeHeading : unsafeHeading;

  String get displayAnalysisLabel {
    final label = analysisLabel?.trim();
    if (label != null && label.isNotEmpty) {
      return label;
    }
    return isSafe ? 'Healthy Maize' : 'Unsafe for Human Consumption';
  }

  String get title => displayAnalysisLabel;
  String get subtitle => isSafe
      ? 'Diagnosis completed successfully'
      : 'Analysis flagged this sample for review';

  List<RecommendationSource> get attributedRecommendations {
    final primaryText = isSafe
        ? 'The model classified this sample as $displayAnalysisLabel.'
        : 'The model flagged this sample as $displayAnalysisLabel and recommends review before use.';
    final secondaryText = isSafe
        ? 'Store the batch in a cool, dry place and keep moisture levels controlled.'
        : 'Separate the batch and arrange confirmatory testing before handling or sale.';

    return [
      RecommendationSource(
        text: primaryText,
        sourceName: 'AI ANALYSIS',
        badgeBg: isSafe ? AppColors.primaryContainer : AppColors.error,
        badgeText: Colors.white,
      ),
      RecommendationSource(
        text: secondaryText,
        sourceName: 'AFLALERT',
        badgeBg: isSafe ? AppColors.successLight : AppColors.errorLight,
        badgeText: Colors.white,
      ),
    ];
  }

  // Re-runs the same capture flow used from Home: open the camera, then hand
  // the photo off to analysis. Replaces this Results screen so the back
  // stack stays [Home, Results] once the new analysis completes, instead of
  // stacking another Results screen underneath.
  Future<void> _scanAnotherBatch(BuildContext context) async {
    final String? location = await LocationService().getCurrentPlaceName();
    if (!context.mounted) return;

    final Object? photo = await Navigator.pushNamed(context, '/camera');
    if (photo is! XFile || !context.mounted) return;

    Navigator.pushReplacementNamed(
      context,
      '/analysis',
      arguments: AnalysisScreenArgs(photo: photo, location: location),
    );
  }

  Future<void> _exportPdf(BuildContext context) async {
    _showActionStatus(
      context,
      'Generating PDF report...',
      Icons.picture_as_pdf_rounded,
      AppColors.primaryContainer,
    );

    try {
      final file = await PdfService().generateReport(
        isSafe: isSafe,
        confidence: confidence,
      );

      await ReportStorageService().saveReport(
        ReportModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          result: displayAnalysisLabel,
          confidence: confidence,
          date: DateTime.now(),
          pdfPath: file.path,
        ),
      );

      if (!context.mounted) return;
      await showPdfExportDialog(context, file);
    } catch (e) {
      if (!context.mounted) return;
      _showActionStatus(
        context,
        'Could not save PDF report',
        Icons.error_outline_rounded,
        AppColors.error,
      );
    }
  }

  // Helper method to display clean snackbar alerts
  void _showActionStatus(BuildContext context, String title, IconData icon, Color color) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: cardBg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(color: textPrimary, fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Row
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context), // Goes back to Camera screen
                      icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Aflatoxin Detector',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Main Diagnosis Card
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: iconBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          isSafe ? Icons.check_rounded : Icons.warning_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(fontSize: 12, color: textMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Certified Recommendations Box
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: boxBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.fact_check_outlined, size: 16, color: headingColor),
                          const SizedBox(width: 6),
                          Text(
                            'Recommendations & Directives',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: headingColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...attributedRecommendations.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.check_circle, size: 15, color: checkColor),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: [
                                    Text(
                                      item.text,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: boxTextColor,
                                        height: 1.4,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: item.badgeBg,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        item.sourceName,
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: item.badgeText,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Export PDF Button
                ElevatedButton.icon(
                  onPressed: () => _exportPdf(context),
                  icon: const Icon(Icons.save_alt_rounded, size: 16),
                  label: const Text(
                    'Export PDF',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: AppColors.primaryContainer,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
                const SizedBox(height: 16),

                // Scan Again Button (opens the camera to capture and analyze a new batch)
                ElevatedButton.icon(
                  onPressed: () => _scanAnotherBatch(context),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Scan Another Batch'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
