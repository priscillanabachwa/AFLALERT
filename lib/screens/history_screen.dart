import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../models/report_model.dart';
import '../services/firestore_service.dart';
import '../services/pdf_service.dart';
import '../services/report_storage_service.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/pdf_export_dialog.dart';
import 'result_screen.dart';

// ─────────────────────────────────────────
//  DESIGN TOKENS — aliased to the shared AppColors palette
//  (same theme as the registration screen)
// ─────────────────────────────────────────
const kPrimaryGreen = AppColors.primaryContainer;
const kAccentGold = AppColors.secondary;
const kDangerRed = AppColors.error;
const kSafeGreen = AppColors.primaryContainer;
const kCardBg = AppColors.surface;
const kPageBg = AppColors.t95;
const kSubtitle = AppColors.grey;
const kDivider = Color(0xFFECEFF1);

// ─────────────────────────────────────────
//  DATA MODEL
// ─────────────────────────────────────────
enum ScanStatus { healthy, moldDetected }

class ScanRecord {
  final String id;
  final String title;
  final String location;
  final String date;
  final ScanStatus status;
  final int matchPercent;
  final String imagePath;

  const ScanRecord({
    required this.id,
    required this.title,
    required this.location,
    required this.date,
    required this.status,
    required this.matchPercent,
    required this.imagePath,
  });
}

// ─────────────────────────────────────────
//  FIRESTORE MAPPING
// ─────────────────────────────────────────
const List<String> _kMonthAbbrev = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _formatScanDate(DateTime dt) =>
    '${_kMonthAbbrev[dt.month - 1]} ${dt.day}, ${dt.year}';

ScanRecord? _scanRecordFromDoc(QueryDocumentSnapshot doc) {
  final rawData = doc.data();
  if (rawData is! Map<String, dynamic>) return null;
  final data = rawData;

  final String label = (data['label'] ?? 'Unknown').toString();
  final num confidenceRaw = switch (data['confidence']) {
    num n => n,
    String s => num.tryParse(s) ?? 0,
    _ => 0,
  };
  final int matchPercent =
      (confidenceRaw <= 1 ? confidenceRaw * 100 : confidenceRaw).round().clamp(0, 100);

  final bool isMoldy = RegExp(r'mold|aflatox|contamin|infect|positive', caseSensitive: false)
          .hasMatch(label) &&
      !RegExp(r'no mold|healthy|clean|safe|negative', caseSensitive: false).hasMatch(label);

  final Timestamp? timestamp = data['timestamp'] as Timestamp?;

  return ScanRecord(
    id: doc.id,
    title: label,
    location: (data['location'] ?? '').toString(),
    date: timestamp != null ? _formatScanDate(timestamp.toDate()) : 'Just now',
    status: isMoldy ? ScanStatus.moldDetected : ScanStatus.healthy,
    matchPercent: matchPercent,
    imagePath: (data['imageUrl'] ?? '').toString(),
  );
}

// ─────────────────────────────────────────
//  HISTORY SCREEN
// ─────────────────────────────────────────
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  late final Stream<QuerySnapshot> _scanHistoryStream = _firestoreService.getUserScanHistory();
  
  // State variables - ALL INSIDE THE CLASS
  ScanStatus? _activeFilter;
  String _query = '';
  String? _selectedLocation;

  // Scans hidden immediately on delete, with the actual Firestore delete
  // deferred until the undo window (below) expires without being cancelled.
  static const Duration _undoWindow = Duration(seconds: 4);
  final Set<String> _pendingDeleteIds = {};
  final Map<String, Timer> _pendingDeleteTimers = {};

  List<ScanRecord> _filterRecords(List<ScanRecord> source) {
    return source.where((s) {
      final matchesQuery =
          _query.isEmpty ||
          s.title.toLowerCase().contains(_query.toLowerCase()) ||
          s.location.toLowerCase().contains(_query.toLowerCase());
      final matchesFilter = _activeFilter == null || s.status == _activeFilter;
      final matchesLocation = _selectedLocation == null || s.location == _selectedLocation;
      return matchesQuery && matchesFilter && matchesLocation;
    }).toList();
  }

  void _clearFilters() {
    setState(() {
      _activeFilter = null;
      _selectedLocation = null;
      _query = '';
      _searchCtrl.clear();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    for (final timer in _pendingDeleteTimers.values) {
      timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPageBg,
      appBar: _buildAppBar(),
      body: StreamBuilder<QuerySnapshot>(
        stream: _scanHistoryStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorState();
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: kPrimaryGreen),
            );
          }

          final allScans = (snapshot.data?.docs ?? [])
              .map(_scanRecordFromDoc)
              .whereType<ScanRecord>()
              .where((s) => !_pendingDeleteIds.contains(s.id))
              .toList();
          final results = _filterRecords(allScans);

          return Column(
            children: [
              _buildFilterChips(allScans),
              const SizedBox(height: 4),
              Expanded(
                child: results.isEmpty
                    ? _buildEmptyState()
                    : _buildScanList(results),
              ),
              _buildBottomBar(results),
            ],
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
    );
  }

  // ── APP BAR ──────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: kCardBg,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: kPrimaryGreen),
        onPressed: () => Navigator.maybePop(context),
      ),
      title: Text(
        AppLocalizations.of(context)!.history,
        style: const TextStyle(
          color: kPrimaryGreen,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
      centerTitle: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: kDivider),
      ),
    );
  }

  // ── FILTER CHIPS ─────────────────────────
  Widget _buildFilterChips(List<ScanRecord> records) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    // Extract unique locations from records
    final locations = records
        .map((r) => r.location)
        .where((l) => l.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _chip(l10n.allFilter, null),
          const SizedBox(width: 8),
          _chip(l10n.healthy, ScanStatus.healthy),
          const SizedBox(width: 8),
          _chip(l10n.moldDetected, ScanStatus.moldDetected),
          const SizedBox(width: 8),
          _locationFilterChip(locations),
        ],
      ),
    );
  }

  Widget _chip(String label, ScanStatus? filter) {
    final selected = _activeFilter == filter;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? kPrimaryGreen : kCardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? kPrimaryGreen : kDivider,
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : kSubtitle,
          ),
        ),
      ),
    );
  }

  Widget _locationFilterChip(List<String> locations) {
    final bool isActive = _selectedLocation != null;
    final String displayText = _selectedLocation ?? AppLocalizations.of(context)!.locationFilterLabel;

    return GestureDetector(
      onTap: locations.isEmpty ? null : () => _showLocationPicker(locations),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? kPrimaryGreen : kCardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? kPrimaryGreen : kDivider,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              displayText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : kSubtitle,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              isActive ? Icons.close : Icons.keyboard_arrow_down,
              size: 16,
              color: isActive ? Colors.white : kSubtitle,
            ),
          ],
        ),
      ),
    );
  }

  void _showLocationPicker(List<String> locations) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _LocationPickerSheet(
        locations: locations,
        selectedLocation: _selectedLocation,
        onSelect: (location) {
          setState(() => _selectedLocation = location);
          Navigator.pop(context);
        },
      ),
    );
  }

  // ── SCAN LIST ────────────────────────────
  Widget _buildScanList(List<ScanRecord> records) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      itemCount: records.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final record = records[i];
        return Dismissible(
          key: ValueKey(record.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: kDangerRed,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.delete_outline, color: Colors.white),
          ),
          confirmDismiss: (_) => _confirmDeleteScan(record),
          onDismissed: (_) => _scheduleDelete(record),
          child: _ScanCard(
            record: record,
            onTap: () => _openDetail(record),
            onDelete: () => _confirmAndDeleteScan(record),
          ),
        );
      },
    );
  }

  // ── BOTTOM INFO BAR ──────────────────────
  Widget _buildBottomBar(List<ScanRecord> results) {
    if (results.isEmpty) return const SizedBox.shrink();

    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final bool hasActiveFilters = _activeFilter != null || _selectedLocation != null || _query.isNotEmpty;

    return Container(
      color: kCardBg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${l10n.showingResultsCount(results.length)}'
                  '${hasActiveFilters ? l10n.forCurrentFilters : ''}.',
                  style: const TextStyle(fontSize: 12, color: kSubtitle),
                ),
                if (hasActiveFilters)
                  GestureDetector(
                    onTap: _clearFilters,
                    child: Text(
                      l10n.clearAllFiltersX,
                      style: const TextStyle(
                        fontSize: 12,
                        color: kDangerRed,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () => _exportPDF(results),
            icon: const Icon(Icons.picture_as_pdf, size: 16),
            label: Text(
              l10n.exportPdf,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: kAccentGold,
              foregroundColor: kPrimaryGreen,
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  // ── EMPTY STATE ──────────────────────────
  Widget _buildEmptyState() {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.history_toggle_off,
            size: 64,
            color: kPrimaryGreen.withAlpha((0.25 * 255).round()),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noScansFound,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: kPrimaryGreen,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.tryAdjustingFilters,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: kSubtitle, height: 1.5),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: _clearFilters,
            child: Text(
              l10n.clearFilters,
              style: const TextStyle(
                color: kPrimaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── ERROR STATE ──────────────────────────
  Widget _buildErrorState() {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off,
            size: 64,
            color: kDangerRed.withAlpha((0.4 * 255).round()),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.couldNotLoadScanHistory,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: kPrimaryGreen,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.checkConnectionTryAgain,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: kSubtitle, height: 1.5),
          ),
        ],
      ),
    );
  }

  // ── ACTIONS ──────────────────────────────
  void _openDetail(ScanRecord record) {
    Navigator.pushNamed(
      context,
      '/results',
      arguments: ResultsScreenArgs(
        isSafe: record.status == ScanStatus.healthy,
        confidence: record.matchPercent / 100,
        analysisLabel: record.title,
        imagePath: record.imagePath.isNotEmpty ? record.imagePath : null,
      ),
    );
  }

  Future<bool> _confirmDeleteScan(ScanRecord record) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteScan),
        content: Text(l10n.deleteScanConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.delete, style: const TextStyle(color: kDangerRed)),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _confirmAndDeleteScan(ScanRecord record) async {
    final bool confirmed = await _confirmDeleteScan(record);
    if (!confirmed || !mounted) return;
    _scheduleDelete(record);
  }

  // Hides the scan immediately and shows an Undo snackbar; the Firestore
  // delete only actually happens once the undo window elapses uncancelled.
  void _scheduleDelete(ScanRecord record) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    setState(() => _pendingDeleteIds.add(record.id));

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.scanDeleted),
        backgroundColor: kPrimaryGreen,
        behavior: SnackBarBehavior.floating,
        duration: _undoWindow,
        action: SnackBarAction(
          label: l10n.undo,
          textColor: Colors.white,
          onPressed: () => _undoDelete(record.id),
        ),
      ),
    );

    _pendingDeleteTimers[record.id]?.cancel();
    _pendingDeleteTimers[record.id] = Timer(_undoWindow, () {
      _pendingDeleteTimers.remove(record.id);
      _commitDelete(record.id);
    });
  }

  void _undoDelete(String id) {
    _pendingDeleteTimers.remove(id)?.cancel();
    if (!mounted) return;
    setState(() => _pendingDeleteIds.remove(id));
  }

  Future<void> _commitDelete(String id) async {
    final bool success = await _firestoreService.deleteScanRecord(id);
    if (!mounted) return;
    if (!success) {
      final AppLocalizations l10n = AppLocalizations.of(context)!;
      setState(() => _pendingDeleteIds.remove(id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.couldNotDeleteScan),
          backgroundColor: kDangerRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _exportPDF(List<ScanRecord> records) async {
    if (records.isEmpty) return;
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.generatingPdfReport),
        backgroundColor: kPrimaryGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );

    try {
      final entries = records
          .map((r) => PdfReportEntry(
                title: r.title,
                isSafe: r.status == ScanStatus.healthy,
                confidence: r.matchPercent / 100,
                date: r.date,
                location: r.location,
              ))
          .toList();

      final file = await PdfService().generateBulkReport(entries);

      final healthyCount = records.where((r) => r.status == ScanStatus.healthy).length;
      await ReportStorageService().saveReport(
        ReportModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          result: l10n.scanHistoryExportLabel(records.length, healthyCount),
          confidence: healthyCount / records.length,
          date: DateTime.now(),
          pdfPath: file.path,
        ),
      );

      if (!mounted) return;
      await showPdfExportDialog(context, file);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.couldNotGeneratePdfReport),
          backgroundColor: kDangerRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

}

// ─────────────────────────────────────────
//  SCAN CARD WIDGET
// ─────────────────────────────────────────
class _ScanCard extends StatelessWidget {
  final ScanRecord record;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ScanCard({required this.record, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final isMoldy = record.status == ScanStatus.moldDetected;
    final statusColor = isMoldy ? kDangerRed : kSafeGreen;
    final statusLabel = isMoldy ? l10n.moldDetected : l10n.healthy;
    final statusIcon = isMoldy
        ? Icons.warning_amber_rounded
        : Icons.check_circle;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: kCardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kDivider, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.04 * 255).round()),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(14),
              ),
              child: Container(
                width: 88,
                height: 88,
                color: kPrimaryGreen.withAlpha((0.08 * 255).round()),
                child: record.imagePath.isEmpty
                    ? Icon(
                        Icons.grain,
                        size: 36,
                        color: kPrimaryGreen.withAlpha((0.3 * 255).round()),
                      )
                    : (record.imagePath.startsWith('http')
                        ? Image.network(
                            record.imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Icon(
                              Icons.grain,
                              size: 36,
                              color: kPrimaryGreen.withAlpha((0.3 * 255).round()),
                            ),
                          )
                        : Image.file(
                            File(record.imagePath),
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Icon(
                              Icons.grain,
                              size: 36,
                              color: kPrimaryGreen.withAlpha((0.3 * 255).round()),
                            ),
                          )),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            record.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A2A1A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withAlpha((0.1 * 255).round()),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${record.matchPercent}%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 12,
                          color: kSubtitle,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          record.date,
                          style: const TextStyle(
                            fontSize: 12,
                            color: kSubtitle,
                          ),
                        ),
                        if (record.location.isNotEmpty) ...[
                          const SizedBox(width: 10),
                          Icon(
                            Icons.location_on_outlined,
                            size: 12,
                            color: kSubtitle,
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              record.location,
                              style: const TextStyle(
                                fontSize: 12,
                                color: kSubtitle,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withAlpha((0.1 * 255).round()),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: statusColor.withAlpha((0.3 * 255).round()),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, size: 12, color: statusColor),
                              const SizedBox(width: 4),
                              Text(
                                statusLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete_outline),
                          iconSize: 18,
                          color: kDangerRed.withAlpha((0.7 * 255).round()),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          splashRadius: 18,
                          tooltip: AppLocalizations.of(context)!.delete,
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: kSubtitle.withAlpha((0.5 * 255).round()),
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  LOCATION PICKER SHEET
// ─────────────────────────────────────────
class _LocationPickerSheet extends StatelessWidget {
  final List<String> locations;
  final String? selectedLocation;
  final ValueChanged<String?> onSelect;

  const _LocationPickerSheet({
    required this.locations,
    required this.selectedLocation,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: kDivider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              l10n.filterByLocation,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: kPrimaryGreen,
              ),
            ),
            const SizedBox(height: 16),
            _locationTile(l10n.allLocations, null),
            const Divider(height: 1),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: locations.length,
                itemBuilder: (context, index) {
                  return _locationTile(locations[index], locations[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _locationTile(String label, String? value) {
    final bool isSelected = selectedLocation == value;
    return ListTile(
      onTap: () => onSelect(value),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isSelected ? kPrimaryGreen : const Color(0xFF263238),
        ),
      ),
      trailing: isSelected 
          ? const Icon(Icons.check_circle, color: kPrimaryGreen, size: 20) 
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
    );
  }
}