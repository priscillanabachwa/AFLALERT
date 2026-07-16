import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

import '../constants/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../screens/downloaded_reports_screen.dart';

// Shown after a PDF report has been generated and saved, offering a way to
// open it immediately or jump to the full Downloaded Reports list. Every
// "Export PDF" button uses this so the confirmation flow looks the same
// wherever it's triggered from.
Future<void> showPdfExportDialog(BuildContext context, File pdfFile) {
  final AppLocalizations l10n = AppLocalizations.of(context)!;
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.primaryContainer),
          const SizedBox(width: 8),
          Text(l10n.reportSaved),
        ],
      ),
      content: Text(l10n.pdfSavedMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(l10n.close, style: const TextStyle(color: AppColors.grey)),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(dialogContext);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DownloadedReportsScreen()),
            );
          },
          child: Text(l10n.viewAllReports),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(dialogContext);
            OpenFilex.open(pdfFile.path);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryContainer,
            foregroundColor: Colors.white,
          ),
          child: Text(l10n.openPdf),
        ),
      ],
    ),
  );
}
