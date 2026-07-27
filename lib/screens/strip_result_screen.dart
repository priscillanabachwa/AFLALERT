import 'dart:io';

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../models/report_model.dart';
import '../services/firestore_service.dart';
import '../services/pdf_service.dart';
import '../services/report_storage_service.dart';
import '../services/strip_analysis_service.dart';
import '../widgets/pdf_export_dialog.dart';
import 'strip_camera_screen.dart';
import 'voice_assistant_screen.dart';

class StripResultsScreenArgs {
  final double ppbValue;
  final double tLineOD;
  final double cLineOD;
  final double odRatio;
  final double safeLimitPpb;
  final StripCropType cropType;
  final String? imagePath;
  final String? location;
  final bool fromHistory;
  final String? scanId;

  const StripResultsScreenArgs({
    required this.ppbValue,
    required this.tLineOD,
    required this.cLineOD,
    required this.odRatio,
    required this.safeLimitPpb,
    required this.cropType,
    this.imagePath,
    this.location,
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

class StripResultsScreen extends StatelessWidget {
  final double ppbValue;
  final double tLineOD;
  final double cLineOD;
  final double odRatio;
  final double safeLimitPpb;
  final StripCropType cropType;
  final String? imagePath;
  final String? location;
  final bool fromHistory;
  final String? scanId;

  const StripResultsScreen({
    super.key,
    required this.ppbValue,
    required this.tLineOD,
    required this.cLineOD,
    required this.odRatio,
    required this.safeLimitPpb,
    required this.cropType,
    this.imagePath,
    this.location,
    this.fromHistory = false,
    this.scanId,
  });

  static const pageBg = AppColors.logoCream;
  static const cardBg = AppColors.surface;
  static const textPrimary = AppColors.text;
  static const textMuted = AppColors.grey;

  static const safeColor = AppColors.primaryContainer;
  static const safeBoxBg = AppColors.successLight;
  static const unsafeColor = AppColors.error;
  static const unsafeBoxBg = AppColors.errorLight;

  bool get isSafe => ppbValue <= safeLimitPpb;
  Color get accentColor => isSafe ? safeColor : unsafeColor;
  Color get boxBg => isSafe ? safeBoxBg : unsafeBoxBg;

  static const double _maxDetectionPpb = StripAnalysisService.maxDetectionPpb;

  String _batchId() {
    final String suffix = (DateTime.now().millisecondsSinceEpoch % 10000)
        .toString()
        .padLeft(4, '0');
    return 'MZ-$suffix';
  }

  String _cropLabel(AppLocalizations l10n) => l10n.cropTypeMaize;

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
        badgeText: Colors.white,
      );

  List<RecommendationSource> _recommendations(AppLocalizations l10n) {
    final String ppbText = ppbValue.toStringAsFixed(1);
    if (isSafe) {
      return [
        _fromAflalert(
          'Test line ratio indicates an estimated $ppbText ppb, within the $safeLimitPpb ppb safe limit for human food.',
        ),
        _fromMaaif(
          'Keep grain moisture below 13% and store in a cool, dry, well-ventilated space raised off the ground.',
        ),
        _fromMaaif(
          'Re-test stored batches periodically — aflatoxin levels can rise during storage even when the batch started out clean.',
        ),
      ];
    }

    return [
      _fromAflalert(
        'Test line ratio indicates an estimated $ppbText ppb, exceeding the $safeLimitPpb ppb safe limit for human food.',
      ),
      _fromUnbs(
        'Do not mix this batch with clean grain. Isolate it immediately and arrange certified laboratory testing before any further use.',
      ),
      _fromMaaif(
        'Re-route this batch for disposal or approved industrial/distillery use — do not feed it to livestock either, as aflatoxins carry over into milk and meat.',
      ),
    ];
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
      final file = await PdfService().generateStripReport(
        isSafe: isSafe,
        ppbValue: ppbValue,
        safeLimitPpb: safeLimitPpb,
        tLineOD: tLineOD,
        cLineOD: cLineOD,
        odRatio: odRatio,
        cropLabel: _cropLabel(l10n),
        batchId: _batchId(),
      );

      await ReportStorageService().saveReport(
        ReportModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          result: '${isSafe ? l10n.withinSafeLimit : l10n.exceedsSafeLimit} (${ppbValue.toStringAsFixed(1)} ppb)',
          confidence: (ppbValue / _maxDetectionPpb).clamp(0, 1),
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

  Widget _buildToxicLoadCard(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    // History-opened scans store a Firebase Storage URL; a freshly-captured
    // scan still points at the local temp file, so both need handling.
    final bool isNetworkImage = imagePath != null && imagePath!.startsWith('http');
    final File? photoFile = (!isNetworkImage && imagePath != null && imagePath!.isNotEmpty)
        ? File(imagePath!)
        : null;
    final bool hasPhoto = isNetworkImage || (photoFile != null && photoFile.existsSync());

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                if (hasPhoto)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: isNetworkImage
                        ? Image.network(
                            imagePath!,
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const SizedBox(width: 44, height: 44),
                          )
                        : Image.file(photoFile!, width: 44, height: 44, fit: BoxFit.cover),
                  ),
                if (hasPhoto) const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${l10n.testBatchLabel} · ${_batchId()}',
                        style: const TextStyle(fontSize: 10, color: textMuted, letterSpacing: 0.5),
                      ),
                      Text(
                        _cropLabel(l10n),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textPrimary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(color: boxBg, borderRadius: BorderRadius.circular(14)),
              child: Column(
                children: [
                  Text(
                    l10n.toxicLoadLabel,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: accentColor, letterSpacing: 1),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: ppbValue.toStringAsFixed(0),
                          style: TextStyle(fontSize: 44, fontWeight: FontWeight.bold, color: accentColor),
                        ),
                        TextSpan(
                          text: ' ppb',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: accentColor),
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
    );
  }

  Widget _buildRegulatoryScale(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final double fraction = (ppbValue / _maxDetectionPpb).clamp(0.0, 1.0);
    final double limitFraction = (safeLimitPpb / _maxDetectionPpb).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.regulatoryScaleLabel,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textMuted, letterSpacing: 0.5),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 26,
            child: LayoutBuilder(
              builder: (context, constraints) => Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 8,
                    margin: const EdgeInsets.only(top: 9),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: const LinearGradient(
                        colors: [safeColor, AppColors.secondary, unsafeColor],
                      ),
                    ),
                  ),
                  Positioned(
                    left: (constraints.maxWidth * limitFraction - 1).clamp(0, constraints.maxWidth - 2),
                    top: 6,
                    child: Container(width: 2, height: 14, color: textPrimary.withValues(alpha: 0.4)),
                  ),
                  Positioned(
                    left: (constraints.maxWidth * fraction - 6).clamp(0, constraints.maxWidth - 12),
                    top: 0,
                    child: Icon(Icons.arrow_drop_down, color: accentColor, size: 26),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('0', style: TextStyle(fontSize: 10, color: textMuted)),
              Text(
                l10n.safeLimitTick(safeLimitPpb.toStringAsFixed(0)),
                style: const TextStyle(fontSize: 10, color: textMuted, fontWeight: FontWeight.w600),
              ),
              Text('${_maxDetectionPpb.toStringAsFixed(0)}+', style: const TextStyle(fontSize: 10, color: textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionRequiredBox(AppLocalizations l10n) {
    if (isSafe) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: unsafeBoxBg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_rounded, color: unsafeColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.actionRequiredLabel,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: unsafeColor),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.exceedsSafeLimitMessage(safeLimitPpb.toStringAsFixed(0)),
                  style: const TextStyle(fontSize: 12, color: textPrimary, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticBreakdown(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.diagnosticBreakdownLabel,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textMuted, letterSpacing: 0.5),
          ),
          const SizedBox(height: 10),
          _breakdownRow(l10n.chemicalLevelLabel, '${ppbValue.toStringAsFixed(1)} ppb'),
          _breakdownRow(l10n.testLineOdLabel, tLineOD.toStringAsFixed(2)),
          _breakdownRow(l10n.controlLineOdLabel, cLineOD.toStringAsFixed(2)),
          _breakdownRow(l10n.odRatioLabel, odRatio.toStringAsFixed(2)),
          if (location != null && location!.isNotEmpty)
            _breakdownRow(l10n.scanLocationLabel, location!),
        ],
      ),
    );
  }

  Widget _breakdownRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12.5, color: textMuted)),
          Text(value, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: textPrimary)),
        ],
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
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.chemicalStripScanTitle,
                      style: const TextStyle(color: AppColors.primary, fontSize: 17, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _buildToxicLoadCard(context),

                // Feedback loop: only offered right after a fresh scan (not
                // when reviewing an old one from History) — mirrors the
                // Tier 1 maize flow so both scan types build a labeled
                // dataset for future retraining.
                if (!fromHistory && scanId != null) _FeedbackPrompt(scanId: scanId!),
                const SizedBox(height: 14),
                _buildRegulatoryScale(context),
                _buildActionRequiredBox(l10n),
                _buildDiagnosticBreakdown(l10n),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: boxBg, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.fact_check_outlined, size: 16, color: accentColor),
                          const SizedBox(width: 6),
                          Text(
                            l10n.recommendationsAndDirectives,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: accentColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ..._recommendations(l10n).map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.check_circle, size: 15, color: accentColor),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: [
                                    Text(
                                      item.text,
                                      style: const TextStyle(fontSize: 12.5, color: textPrimary, height: 1.4),
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
                ElevatedButton.icon(
                  onPressed: () => _exportPdf(context),
                  icon: const Icon(Icons.save_alt_rounded, size: 16),
                  label: Text(l10n.exportPdf, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: AppColors.primaryContainer,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
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
        color: StripResultsScreen.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: StripResultsScreen.textMuted.withValues(alpha: 0.15)),
      ),
      child: _submittedAccurate != null
          ? Row(
              children: [
                const Icon(Icons.check_circle, size: 16, color: AppColors.primaryContainer),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.feedbackThanks,
                    style: const TextStyle(fontSize: 12.5, color: StripResultsScreen.textPrimary),
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
                      color: StripResultsScreen.textPrimary,
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
