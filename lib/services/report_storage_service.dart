import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/report_model.dart';

class ReportStorageService {
  static const String _key = "downloaded_reports";

  Future<void> saveReport(ReportModel report) async {
    final prefs = await SharedPreferences.getInstance();

    final reports = await getReports();

    reports.insert(0, report);

    final jsonList =
        reports.map((report) => jsonEncode(report.toJson())).toList();

    await prefs.setStringList(_key, jsonList);
  }

  Future<List<ReportModel>> getReports() async {
    final prefs = await SharedPreferences.getInstance();

    final jsonList = prefs.getStringList(_key) ?? [];

    return jsonList
        .map(
          (e) => ReportModel.fromJson(
            jsonDecode(e),
          ),
        )
        .toList();
  }

  Future<void> deleteReport(String id) async {
    final reports = await getReports();

    reports.removeWhere((report) => report.id == id);

    final prefs = await SharedPreferences.getInstance();

    final jsonList =
        reports.map((report) => jsonEncode(report.toJson())).toList();

    await prefs.setStringList(_key, jsonList);
  }

  Future<void> clearReports() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_key);
  }
}