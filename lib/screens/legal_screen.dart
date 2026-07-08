import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'legal_document_screen.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Legal', style: TextStyle(color: AppColors.text)),
        iconTheme: const IconThemeData(color: AppColors.text),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.description_outlined, color: AppColors.primary),
              title: const Text('Terms of Service', style: TextStyle(color: AppColors.text)),
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
              title: const Text('Privacy Policy', style: TextStyle(color: AppColors.text)),
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
