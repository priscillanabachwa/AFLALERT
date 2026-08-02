import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../models/report_model.dart';
import '../services/firestore_service.dart';
import '../services/location_service.dart';
import '../services/pdf_service.dart';
import '../services/report_storage_service.dart';
import '../widgets/pdf_export_dialog.dart';
import 'analysis_screen.dart';
import 'voice_assistant_screen.dart';

class ResultsScreenArgs {
  final bool isSafe;
  final double confidence;
  final String? imagePath;
  final bool fromHistory;
  final String? scanId;

  const ResultsScreenArgs({
    required this.isSafe,
    required this.confidence,
    this.imagePath,
    this.fromHistory = false,
    this.scanId,
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
  final String? imagePath;
  final bool fromHistory;
  final String? scanId;

  const ResultsScreen({
    super.key,
    required this.isSafe,
    required this.confidence,
    this.imagePath,
    this.fromHistory = false,
    this.scanId,
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

  // The classifier only ever distinguishes healthy vs. moldy — there's no
  // richer label to preserve — so this is always the localized text for
  // the current locale rather than a raw (always-English) model string.
  String displayAnalysisLabel(AppLocalizations l10n) =>
      isSafe ? l10n.healthyMaize : l10n.unsafeForConsumption;

  String title(AppLocalizations l10n) => displayAnalysisLabel(l10n);
  String subtitle(AppLocalizations l10n) => isSafe
      ? l10n.diagnosisCompletedSuccessfully
      : l10n.analysisFlaggedForReview;

  int get confidencePercent => (confidence * 100).round();

  // The model is only ever shown to the user once it clears TfliteService's
  // 60% floor (lower results get rejected upstream as "not maize"), so the
  // practical range here is 60-100%. Below 85% is close enough to that floor
  // that the guidance should nudge toward a retest rather than state the
  // call as flatly certain.
  bool get _isHighConfidence => confidence >= 0.85;

  RecommendationSource _fromAflalert(String text) => RecommendationSource(
        text: text,
        sourceName: 'AFLALERT AI',
        badgeBg: isSafe ? AppColors.primaryContainer : AppColors.error,
        badgeText: Colors.white,
      );

  RecommendationSource _fromUnbs(String text) => RecommendationSource(
        text: text,
        sourceName: 'UNBS',
        badgeBg: AppColors.error,
        badgeText: Colors.white,
      );

  RecommendationSource _fromMaaif(String text) => RecommendationSource(
        text: text,
        sourceName: 'MAAIF',
        badgeBg: isSafe ? AppColors.successLight : AppColors.errorLight,
        badgeText: isSafe ? AppColors.primaryContainer : AppColors.error,
      );

  List<RecommendationSource> get attributedRecommendations {
    if (isSafe) {
      final findingText = _isHighConfidence
          ? 'No visible mold or aflatoxin indicators were found in this sample ($confidencePercent% confidence).'
          : 'No mold indicators were found, but confidence is only $confidencePercent%. Rescan in bright, even light to confirm before relying on this result.';

      return [
        _fromAflalert(findingText),
        _fromMaaif(
          'Keep grain moisture below 13% and store in a cool, dry, well-ventilated space raised off '
          'the ground to prevent mold developing after this scan.',
        ),
        _fromMaaif(
          'Re-check stored batches periodically — aflatoxin risk can develop after storage even '
          'when the grain started out clean.',
        ),
      ];
    }

    final findingText = _isHighConfidence
        ? 'Visible mold consistent with aflatoxin contamination was detected ($confidencePercent% confidence).'
        : 'Possible mold contamination was detected, but confidence is only $confidencePercent%. Treat this '
            'batch as high-risk and rescan in better light to confirm.';

    return [
      _fromAflalert(findingText),
      _fromUnbs(
        'Do not sell or consume this batch. Isolate it immediately and arrange certified laboratory '
        'testing before any further use.',
      ),
      _fromMaaif(
        'Do not feed this batch to livestock either — aflatoxins carry over into milk and meat, so '
        'contaminated feed puts the animals and consumers at risk too.',
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
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    _showActionStatus(
      context,
      l10n.generatingPdfReport,
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
          result: displayAnalysisLabel(l10n),
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
        l10n.couldNotSavePdfReport,
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

  Widget _buildPhoto() {
    if (imagePath != null && imagePath!.startsWith('http')) {
      return Image.network(
        imagePath!,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const SizedBox(height: 180),
      );
    }
    return Image.file(
      File(imagePath!),
      height: 180,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }

  Widget _buildDiagnosisCard(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final bool isNetworkImage = imagePath != null && imagePath!.startsWith('http');
    final File? photoFile =
        (!isNetworkImage && imagePath != null && imagePath!.isNotEmpty) ? File(imagePath!) : null;
    final bool hasPhoto = isNetworkImage || (photoFile != null && photoFile.existsSync());

    return Container(
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
          if (hasPhoto)
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: _buildPhoto(),
                ),
                Positioned(
                  bottom: -24,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: iconBg,
                      shape: BoxShape.circle,
                      border: Border.all(color: cardBg, width: 3),
                    ),
                    child: Icon(
                      isSafe ? Icons.check_rounded : Icons.warning_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ],
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 28),
              child: Container(
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
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, hasPhoto ? 32 : 14, 16, 24),
            child: Column(
              children: [
                Text(
                  title(l10n),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                _buildConfidenceBadge(l10n),
                const SizedBox(height: 6),
                Text(
                  subtitle(l10n),
                  style: const TextStyle(fontSize: 12, color: textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceBadge(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: iconBg.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        l10n.confidencePercentLabel(confidencePercent),
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: iconBg),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: pageBg,
      floatingActionButton: _buildVoiceAssistantBubble(context),
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
                    Text(
                      fromHistory ? l10n.scanDetails : l10n.aflatoxinDetector,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Main Diagnosis Card
                _buildDiagnosisCard(context),

                // Feedback loop: only offered right after a fresh scan (not
                // when reviewing an old one from History) — the point is to
                // capture whether the model got THIS call right while the
                // user still remembers what they actually saw, building a
                // labeled dataset for future retraining.
                if (!fromHistory && scanId != null) _FeedbackPrompt(scanId: scanId!),
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
                            l10n.recommendationsAndDirectives,
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
                  label: Text(
                    l10n.exportPdf,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: AppColors.primaryContainer,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
                if (!fromHistory) ...[
                  const SizedBox(height: 16),

                  // Scan Again Button (opens the camera to capture and analyze a new batch)
                  ElevatedButton.icon(
                    onPressed: () => _scanAnotherBatch(context),
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: Text(l10n.scanAnotherBatch),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceAssistantBubble(BuildContext context) {
    return Tooltip(
      message: AppLocalizations.of(context)!.voiceAssistantEntryTooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(32),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const VoiceAssistantScreen()),
        ),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryContainer,
            border: Border.all(color: const Color(0xFFE8F5EE), width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Image.asset('lib/assets/images/AI_icon.png'),
          ),
        ),
      ),
    );
  }
}

class _FeedbackPrompt extends StatefulWidget {
  final String scanId;

  const _FeedbackPrompt({required this.scanId});

  @override
  State<_FeedbackPrompt> createState() => _FeedbackPromptState();
}

class _FeedbackPromptState extends State<_FeedbackPrompt> {
  bool? _submittedAccurate;
  bool _submitting = false;

  Future<void> _submit(bool isAccurate) async {
    if (_submitting || _submittedAccurate != null) return;
    setState(() => _submitting = true);

    final bool success = await FirestoreService().submitScanFeedback(widget.scanId, isAccurate);
    if (!mounted) return;
    setState(() {
      _submitting = false;
      if (success) _submittedAccurate = isAccurate;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: ResultsScreen.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ResultsScreen.textMuted.withValues(alpha: 0.15)),
      ),
      child: _submittedAccurate != null
          ? Row(
              children: [
                const Icon(Icons.check_circle, size: 16, color: AppColors.primaryContainer),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.feedbackThanks,
                    style: const TextStyle(fontSize: 12.5, color: ResultsScreen.textPrimary),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.wasThisDiagnosisAccurate,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: ResultsScreen.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (_submitting)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else ...[
                  IconButton(
                    onPressed: () => _submit(true),
                    icon: const Icon(Icons.thumb_up_outlined, size: 18),
                    color: AppColors.primaryContainer,
                    tooltip: l10n.feedbackYesTooltip,
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    onPressed: () => _submit(false),
                    icon: const Icon(Icons.thumb_down_outlined, size: 18),
                    color: AppColors.error,
                    tooltip: l10n.feedbackNoTooltip,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ],
            ),
    );
  }
}
