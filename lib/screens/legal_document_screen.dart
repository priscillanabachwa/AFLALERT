import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

// Generic screen for displaying static legal text (Terms of Service,
// Privacy Policy, etc.) so both can share one layout. The [body] string is
// parsed line-by-line to style numbered sections, sub-sections, and
// "Label: description" lines without needing markup in the source text.
class LegalDocumentScreen extends StatelessWidget {
  final String title;
  final String body;

  const LegalDocumentScreen({
    super.key,
    required this.title,
    required this.body,
  });

  static final RegExp _sectionHeaderReg = RegExp(r'^(\d+)\.\s+(.*)$');
  static final RegExp _subHeaderReg = RegExp(r'^([A-Z])\.\s+(.*)$');
  static final RegExp _labelLineReg = RegExp(r'^([^:]{2,40}):\s+(.+)$');
  static const Set<String> _labelConnectors = {
    'of', 'to', 'the', 'in', 'for', 'and', 'or', 'on', 'at',
  };

  bool _isPrivacyDoc() => title.toLowerCase().contains('privacy');

  MapEntry<String, String>? _extractLabel(String line) {
    final match = _labelLineReg.firstMatch(line);
    if (match == null) return null;
    final label = match.group(1)!;
    final rest = match.group(2)!;
    final words = label.split(' ');
    if (words.length > 7) return null;
    final looksLikeLabel = words.every((w) {
      if (w.isEmpty) return true;
      if (_labelConnectors.contains(w.toLowerCase())) return true;
      return RegExp(r'^[A-Z][A-Za-z()]*$').hasMatch(w);
    });
    return looksLikeLabel ? MapEntry(label, rest) : null;
  }

  List<Widget> _buildBody(String docTitle, String lastUpdated, List<String> lines) {
    final widgets = <Widget>[];
    var firstBlock = true;

    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      final sectionMatch = _sectionHeaderReg.firstMatch(line);
      final subMatch = _subHeaderReg.firstMatch(line);

      if (sectionMatch != null) {
        widgets.add(Padding(
          padding: EdgeInsets.only(top: firstBlock ? 0 : 24, bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  sectionMatch.group(1)!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  sectionMatch.group(2)!,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ));
        firstBlock = false;
        continue;
      }

      if (subMatch != null) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 6),
          child: Text(
            '${subMatch.group(1)}. ${subMatch.group(2)}',
            style: const TextStyle(
              color: AppColors.primaryContainer,
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ));
        firstBlock = false;
        continue;
      }

      final label = _extractLabel(line);
      widgets.add(Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: label != null
            ? RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  style: const TextStyle(color: AppColors.text, fontSize: 14, height: 1.5),
                  children: [
                    TextSpan(
                      text: '${label.key}: ',
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: label.value),
                  ],
                ),
              )
            : Text(
                line,
                textAlign: TextAlign.justify,
                style: const TextStyle(color: AppColors.text, fontSize: 14, height: 1.5),
              ),
      ));
      firstBlock = false;
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final lines = body.split('\n');
    final docTitle = lines.isNotEmpty ? lines[0].trim() : title;
    final lastUpdated = lines.length > 1 ? lines[1].trim() : '';
    final contentLines = lines.length > 2 ? lines.sublist(2) : <String>[];
    final icon = _isPrivacyDoc() ? Icons.privacy_tip_outlined : Icons.description_outlined;

    return Scaffold(
      backgroundColor: AppColors.t95,
      appBar: AppBar(
        backgroundColor: AppColors.t95,
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: AppColors.secondary, size: 30),
                    const SizedBox(height: 12),
                    Text(
                      docTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    if (lastUpdated.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          lastUpdated,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildBody(docTitle, lastUpdated, contentLines),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const String kTermsOfServiceText = '''
TERMS AND CONDITIONS FOR AFLALERT
Last Updated: July 8, 2026

Please read these Terms and Conditions ("Terms") carefully before downloading, installing, or using the AflAlert mobile application ("App") operated by AflAlert ("us", "we", or "our").

By downloading or using the App, you agree to be bound by these Terms. If you disagree with any part of these terms, you must not use or download the App.

1. Description of Service
AflAlert is a software-driven mobile application that utilizes on-device machine learning (computer vision) to analyze images of maize kernels. The App is designed to detect visible indicators of crop degradation, physical damage, and surface mold growth (specifically Aspergillus species) to estimate the potential risk of aflatoxin contamination.

2. Critical Medical & Liability Disclaimer (IMPORTANT)
No Direct Chemical Detection: You explicitly acknowledge and agree that AflAlert operates purely via optical image recognition. Aflatoxins are microscopic chemical compounds that are completely invisible, odorless, and tasteless. The App cannot physically test for, chemically isolate, or directly measure chemical parts-per-billion (ppb) toxicity levels.

Risk Indicator Only: The App provides an educational risk estimate based on visible indicators. A "Safe" or "Low Risk" result from the App does not guarantee that the maize is entirely free from aflatoxins. Conversely, a "High Risk" result indicates the presence of visual defects but is not a certified laboratory diagnosis.

No Alternative to Lab Testing: AflAlert is an initial field-screening tool. It is not a replacement for regulatory, chemical, or laboratory-grade diagnostic testing.

Limitation of Liability: To the maximum extent permitted by applicable law, AflAlert shall not be held liable for any financial losses, crop rejections, livestock illness, human sickness, or legal disputes arising from decisions made based on the App's visual AI outputs. Users accept all financial and health risks associated with the consumption, sale, or distribution of their crops.

3. Offline Usage and Data Synchronization
Local Processing: The App's machine learning model runs entirely on your device's internal hardware and does not require an active internet connection to deliver visual scan estimates.

Cloud Syncing: When your device establishes a data or Wi-Fi connection, the App may automatically sync your saved test logs, timestamps, and localized GPS coordinates to our secure cloud server to map regional contamination trends. You are solely responsible for any mobile network data charges incurred during synchronization.

4. Acceptable Use and Image Quality
To ensure the machine learning engine performs at its highest possible accuracy, you agree to follow the in-app camera guidelines (ensuring proper lighting, clean flat surfaces, and sharp focus). You agree not to upload fraudulent, non-maize, or intentionally distorted images designed to manipulate the App's scoring algorithms.

5. Intellectual Property
The App, including its custom machine learning models (.tflite files), software code, user interface designs, logos, and graphics, is the exclusive property of AflAlert and is protected by copyright and intellectual property laws. You may not reverse-engineer, decompile, or copy the underlying AI model architecture.

6. Termination
We reserve the right to terminate or suspend your access to the App immediately, without prior notice or liability, for any reason whatsoever, including without limitation if you breach these Terms.

7. Changes to These Terms
We reserve the right, at our sole discretion, to modify or replace these Terms at any time. We will notify users of any major changes by updating the "Last Updated" date at the top of this document or via an in-app alert.

8. Contact Information
If you have any questions about these Terms, please contact us at: aflalert.support@gmail.com.
''';

const String kPrivacyPolicyText = '''
PRIVACY POLICY FOR AFLALERT
Last Updated: July 8, 2026

AflAlert ("we", "our", or "us") is committed to protecting your privacy. This Privacy Policy explains how AflAlert ("App") collects, uses, discloses, and safeguards your information when you use our mobile application.

By installing and using the App, you agree to the collection and use of information in accordance with this Privacy Policy. If you do not agree with the terms of this Privacy Policy, please do not access or use the App.

1. Information We Collect

A. Local Device Data (Processed Completely Offline)
To provide instant visual screening without an internet connection, the following data is processed and stored locally within your device's secure internal storage:
Camera Images: The App requires access to your smartphone's camera. Images captured of maize kernels are processed entirely on-device by our local machine learning model (.tflite file).
Scan Diagnostics: The percentage of mold detected, physical grain defects, batch names, and timestamps are logged directly into a local device database (such as SQLite or Hive).

B. Location Data (GPS Coordinates)
With your explicit permission, the App collects your precise geographical location (GPS coordinates) at the exact moment a maize scan is completed.
Purpose: Location mapping is vital to track and predict regional Aspergillus mold outbreaks, helping agricultural extensions issue early warnings to nearby farmers. You can enable or disable location tracking at any time through your mobile device settings.

C. Cloud Synchronization Data (Processed Online)
When your mobile device connects to the internet (via cellular data or Wi-Fi), the App may securely transmit your saved scan logs, timestamps, and GPS coordinates to our centralized cloud database. Raw photos of your maize are NOT uploaded to our servers to save your mobile data bundles, unless you explicitly choose to submit an image to help improve our AI model.

2. How We Use Your Information
We use the data collected through the App for the following purposes:
To display an immediate, color-coded contamination risk analysis on your screen.
To maintain an offline historical log of your tests so you can track your harvest quality over time.
To generate anonymized, aggregated regional risk maps to identify hotspot areas facing high mold development risks.
To update, refine, and improve the accuracy of our on-device machine learning algorithms.

3. Data Sharing and Disclosure
We respect your privacy and will never sell your personal data. We may share anonymized, aggregated geographical data (with zero personal identifying information) with the following trusted third parties:
Local ministries of agriculture and agricultural research extension offices.
International food safety organizations and NGOs focused on food security.
Non-profit farming cooperatives seeking to protect regional supply chains from toxic contamination.

4. Data Security
The security of your data is highly important to us. Your offline logs are stored using standard local encryption measures. Cloud transmission is fully secured using Industry-standard Secure Socket Layer (SSL/TLS) encryption. However, please remember that no method of mobile storage or electronic transmission over the internet is 100% secure.

5. Children's Privacy
Our services do not address anyone under the age of 13. We do not knowingly collect personally identifiable information from children under 13. If we discover that a child under 13 has provided us with personal information, we immediately delete this from our servers.

6. Your Data Rights
Depending on your regional regulations (such as the African Union Convention on Cyber Security and Personal Data Protection or localized Data Protection Acts), you have the right to:
Access and view the logs stored on your device.
Clear your entire testing history through the App's internal settings menu.
Revoke the App's access to your camera or location services via your phone's main settings panel at any time.

7. Contact Us
If you have any questions or suggestions regarding this Privacy Policy, please contact us at: aflalert.support@gmail.com.
''';
