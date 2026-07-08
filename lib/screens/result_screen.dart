import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class ResultsScreenArgs {
  final bool isSafe;
  final double confidence;
  final String? userPhotoUrl;
  final String userInitial;
  final String? analysisLabel;

  const ResultsScreenArgs({
    required this.isSafe,
    required this.confidence,
    this.userPhotoUrl,
    this.userInitial = 'U',
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
  final String? userPhotoUrl;
  final String userInitial;
  final String? analysisLabel;

  const ResultsScreen({
    super.key,
    required this.isSafe,
    required this.confidence,
    this.userPhotoUrl,
    this.userInitial = 'U',
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
  String get riskLevel => isSafe ? 'Very low' : 'High';
  String get riskTag => isSafe ? 'SAFE · GRADE A' : 'UNSAFE · REJECTED';

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
    final confidencePercent = (confidence * 100).toStringAsFixed(0);
    final confidenceLabel = confidence >= 0.85 ? 'high' : confidence >= 0.6 ? 'medium' : 'low';

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
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/profile'),
                      child: CircleAvatar(
                        radius: 19,
                        backgroundColor: AppColors.secondary,
                        backgroundImage:
                            userPhotoUrl != null ? NetworkImage(userPhotoUrl!) : null,
                        child: userPhotoUrl == null
                            ? Text(
                                userInitial.toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            : null,
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

                // Analytics Metrics Box Row
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Confidence score',
                                style: TextStyle(fontSize: 11, color: textMuted)),
                            const SizedBox(height: 4),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '$confidencePercent% ',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: textPrimary,
                                    ),
                                  ),
                                  TextSpan(
                                    text: confidenceLabel,
                                    style: const TextStyle(fontSize: 12, color: textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Risk level',
                                style: TextStyle(fontSize: 11, color: textMuted)),
                            const SizedBox(height: 4),
                            Text(
                              riskLevel,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: iconBg,
                              ),
                            ),
                            Text(
                              riskTag,
                              style: const TextStyle(fontSize: 10, color: textMuted),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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

                // Action Button (Toggled dynamic layout)
                ElevatedButton.icon(
                  onPressed: () {
                    final statusMessage = isSafe
                        ? 'Batch logged as Healthy'
                        : 'Batch logged as Contaminated';
                    _showActionStatus(context, statusMessage, isSafe ? Icons.check_circle : Icons.cancel, iconBg);
                  },
                  icon: Icon(isSafe ? Icons.check_circle_rounded : Icons.cancel_rounded, size: 18),
                  label: Text(isSafe ? 'Approve & Save Batch' : 'Log Contaminated Batch'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSafe ? safeIconBg : unsafeIconBg,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 1,
                  ),
                ),
                const SizedBox(height: 10),

                // Save PDF Report Button
                OutlinedButton.icon(
                  onPressed: () {
                    // Triggers download feedback alert hook
                    _showActionStatus(context, 'Downloading PDF Report to Device...', Icons.file_download_done_rounded, AppColors.primaryContainer);
                  },
                  icon: const Icon(Icons.save_alt_rounded),
                  label: const Text('Save Report PDF'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.outline),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 10),

                // Share Results Button
                OutlinedButton.icon(
                  onPressed: () {
                    _showActionStatus(context, 'Opening share options...', Icons.share_rounded, AppColors.secondary);
                  },
                  icon: const Icon(Icons.share_rounded),
                  label: const Text('Share Results'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.outline),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),

                // Scan Again Button (Pops route out back into Camera viewfinder layout)
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Scan Another Batch'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cardBg,
                    foregroundColor: textPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.outline),
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
