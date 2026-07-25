import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../l10n/app_localizations.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.t95,
      appBar: AppBar(
        backgroundColor: AppColors.t95,
        title: Text(
          l10n.aboutAflAlert,
          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'lib/assets/images/aflalert_logo.png',
                      width: 84,
                      height: 84,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'AflAlert',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.splashTagline,
                    style: const TextStyle(color: AppColors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.aboutVersion,
                    style: const TextStyle(color: AppColors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.aboutDescription,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.text, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 28),
            _SectionHeader(title: l10n.aboutFeaturesTitle),
            _AboutCard(
              children: [
                _FeatureTile(
                  icon: Icons.document_scanner_outlined,
                  title: l10n.aboutFeatureScanTitle,
                  description: l10n.aboutFeatureScanDesc,
                ),
                const Divider(height: 1, color: Color(0xFFEDEDED)),
                _FeatureTile(
                  icon: Icons.fact_check_outlined,
                  title: l10n.aboutFeatureRecommendationsTitle,
                  description: l10n.aboutFeatureRecommendationsDesc,
                ),
                const Divider(height: 1, color: Color(0xFFEDEDED)),
                _FeatureTile(
                  icon: Icons.water_drop_outlined,
                  title: l10n.aboutFeatureRainAlertsTitle,
                  description: l10n.aboutFeatureRainAlertsDesc,
                ),
                const Divider(height: 1, color: Color(0xFFEDEDED)),
                _FeatureTile(
                  icon: Icons.mic_none_outlined,
                  title: l10n.aboutFeatureVoiceTitle,
                  description: l10n.aboutFeatureVoiceDesc,
                ),
                const Divider(height: 1, color: Color(0xFFEDEDED)),
                _FeatureTile(
                  icon: Icons.history_outlined,
                  title: l10n.aboutFeatureReportsTitle,
                  description: l10n.aboutFeatureReportsDesc,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              l10n.recommendationsSourced,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.grey, fontSize: 12),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.aboutCopyright,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(color: Colors.transparent, child: Column(children: children)),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: AppColors.grey, fontSize: 12.5, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
