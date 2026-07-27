import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/contact_info.dart';
import '../l10n/app_localizations.dart';

export '../constants/contact_info.dart' show supportEmail;

// Shared by the Settings and About screens so both "Contact support" entry
// points open the same mailto: flow and fall back to the same message.
Future<void> launchSupportEmail(BuildContext context) async {
  final AppLocalizations l10n = AppLocalizations.of(context)!;
  final Uri emailUri = Uri(
    scheme: 'mailto',
    path: supportEmail,
    query: 'subject=${Uri.encodeComponent('AflAlert Support Request')}',
  );

  final bool launched = await launchUrl(emailUri);
  if (!launched && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.couldNotOpenEmailApp)),
    );
  }
}
