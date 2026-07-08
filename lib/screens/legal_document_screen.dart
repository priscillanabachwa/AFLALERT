import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

// Generic screen for displaying static legal text (Terms of Service,
// Privacy Policy, etc.) so both can share one layout. Replace [body] with
// the actual legal copy when it's ready.
class LegalDocumentScreen extends StatelessWidget {
  final String title;
  final String body;

  const LegalDocumentScreen({
    super.key,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(title, style: const TextStyle(color: AppColors.text)),
        iconTheme: const IconThemeData(color: AppColors.text),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Text(
            body,
            style: const TextStyle(color: AppColors.text, fontSize: 14, height: 1.5),
          ),
        ),
      ),
    );
  }
}

const String kTermsOfServiceText = '''
Terms of Service

This is placeholder text for AflAlert's Terms of Service. Replace this
content with your finalized terms before release.
''';

const String kPrivacyPolicyText = '''
Privacy Policy

This is placeholder text for AflAlert's Privacy Policy. Replace this
content with your finalized policy before release.
''';
