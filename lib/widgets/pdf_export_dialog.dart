import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

import '../constants/app_colors.dart';
import '../screens/downloaded_reports_screen.dart';

// Shown after a PDF report has been generated and saved, offering a way to
// open it immediately or jump to the full Downloaded Reports list. Every
// "Export PDF" button uses this so the confirmation flow looks the same
// wherever it's triggered from.
Future<void> showPdfExportDialog(BuildContext context, File pdfFile) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.primaryContainer),
          SizedBox(width: 8),
          Text('Report saved'),
        ],
      ),
      content: const Text(
        'Your PDF report has been saved to this device. You can open it now '
        'or find it later in Downloaded Reports.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Close', style: TextStyle(color: AppColors.grey)),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(dialogContext);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DownloadedReportsScreen()),
            );
          },
          child: const Text('View All Reports'),
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
          child: const Text('Open PDF'),
        ),
      ],
    ),
  );
}
