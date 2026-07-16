import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

import '../l10n/app_localizations.dart';
import '../models/report_model.dart';
import '../services/report_storage_service.dart';

class DownloadedReportsScreen extends StatefulWidget {
  const DownloadedReportsScreen({super.key});

  @override
  State<DownloadedReportsScreen> createState() =>
      _DownloadedReportsScreenState();
}

class _DownloadedReportsScreenState
    extends State<DownloadedReportsScreen> {
  final ReportStorageService _storage = ReportStorageService();

  List<ReportModel> reports = [];

  @override
  void initState() {
    super.initState();
    loadReports();
  }

  Future<void> loadReports() async {
    reports = await _storage.getReports();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> deleteReport(ReportModel report) async {
    final file = File(report.pdfPath);

    if (await file.exists()) {
      await file.delete();
    }

    await _storage.deleteReport(report.id);

    loadReports();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.downloadedReports),
      ),
      body: reports.isEmpty
          ? Center(
              child: Text(
                l10n.noDownloadedReports,
                style: const TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: const Icon(
                      Icons.picture_as_pdf,
                      color: Colors.red,
                    ),
                    title: Text(report.result),
                    subtitle: Text(
                      report.date.toString(),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        deleteReport(report);
                      },
                    ),
                    onTap: () {
                      OpenFilex.open(report.pdfPath);
                    },
                  ),
                );
              },
            ),
    );
  }
}                             