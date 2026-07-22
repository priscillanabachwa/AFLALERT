import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../l10n/app_localizations.dart';
import 'legal_document_screen.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.t95,
      appBar: AppBar(
        backgroundColor: AppColors.t95,
        title: Text(
          l10n.legal,
          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.description_outlined, color: AppColors.primary),
              title: Text(l10n.termsOfService, style: const TextStyle(color: AppColors.primary)),
              trailing: const Icon(Icons.chevron_right, color: AppColors.grey),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LegalDocumentScreen(
                      title: 'Terms of Service',
                      body: kTermsOfServiceText,
                    ),
                  ),
                );
              },
            ),
            const Divider(height: 1, color: Color(0xFFEDEDED)),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.primary),
              title: Text(l10n.privacyPolicy, style: const TextStyle(color: AppColors.primary)),
              trailing: const Icon(Icons.chevron_right, color: AppColors.grey),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LegalDocumentScreen(
                      title: 'Privacy Policy',
                      body: kPrivacyPolicyText,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
