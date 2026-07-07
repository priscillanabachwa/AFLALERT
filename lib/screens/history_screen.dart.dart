import 'package:flutter/material.dart';

import 'login_screen.dart';

// ─────────────────────────────────────────
//  DESIGN TOKENS  (match your app palette)
// ─────────────────────────────────────────
const kPrimaryGreen = Color(0xFF1B4332);
const kAccentGold = Color(0xFFF5C518);
const kDangerRed = Color(0xFFD32F2F);
const kSafeGreen = Color(0xFF2E7D32);
const kCardBg = Color(0xFFFFFFFF);
const kPageBg = Color(0xFFF5F6F5);
const kSubtitle = Color(0xFF78909C);
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
  final String imagePath; // use AssetImage or NetworkImage in production

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
//  DUMMY DATA  (replace with Firestore)
// ─────────────────────────────────────────
final List<ScanRecord> _allScans = [
  ScanRecord(
    id: 'MZ-0012',
    title: 'Yellow Maize Sample',
    location: 'Store Lot 1',
    date: 'Oct 24, 2023',
    status: ScanStatus.healthy,
    matchPercent: 98,
    imagePath: '',
  ),
  ScanRecord(
    id: 'MZ-0011',
    title: 'Stockpile 402B',
    location: 'North Field',
    date: 'Oct 22, 2023',
    status: ScanStatus.moldDetected,
    matchPercent: 85,
    imagePath: '',
  ),
  ScanRecord(
    id: 'MZ-0010',
    title: 'Post-Dry Testing',
    location: 'Drying Bay 2',
    date: 'Oct 20, 2023',
    status: ScanStatus.healthy,
    matchPercent: 94,
    imagePath: '',
  ),
  ScanRecord(
    id: 'MZ-0009',
    title: 'Warehouse A – Lot 12',
    location: 'Main Warehouse',
    date: 'Oct 18, 2023',
    status: ScanStatus.healthy,
    matchPercent: 97,
    imagePath: '',
  ),
  ScanRecord(
    id: 'MZ-0008',
    title: 'Field North – Sec 3',
    location: 'North Section',
    date: 'Oct 16, 2023',
    status: ScanStatus.moldDetected,
    matchPercent: 91,
    imagePath: '',
  ),
];

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
  ScanStatus? _activeFilter; // null = show all
  String _query = '';

  List<ScanRecord> get _filtered {
    return _allScans.where((s) {
      final matchesQuery =
          _query.isEmpty ||
          s.title.toLowerCase().contains(_query.toLowerCase()) ||
          s.location.toLowerCase().contains(_query.toLowerCase());
      final matchesFilter = _activeFilter == null || s.status == _activeFilter;
      return matchesQuery && matchesFilter;
    }).toList();
  }

  void _clearFilters() {
    setState(() {
      _activeFilter = null;
      _query = '';
      _searchCtrl.clear();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = _filtered;

    return Scaffold(
      backgroundColor: kPageBg,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          const SizedBox(height: 4),
          Expanded(
            child: results.isEmpty
                ? _buildEmptyState()
                : _buildScanList(results),
          ),
          _buildBottomBar(results),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
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
      title: const Text(
        'History',
        style: TextStyle(
          color: kPrimaryGreen,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
      centerTitle: false,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: kPrimaryGreen.withOpacity(0.15),
            child: const Icon(Icons.person, color: kPrimaryGreen, size: 20),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: kDivider),
      ),
    );
  }

  // ── SEARCH BAR ───────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: kCardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kDivider, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            const Icon(Icons.search, color: kSubtitle, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v),
                style: const TextStyle(fontSize: 14, color: Color(0xFF263238)),
                decoration: const InputDecoration(
                  hintText: 'Search by crop, location...',
                  hintStyle: TextStyle(color: kSubtitle, fontSize: 14),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            // Filter icon button
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: _showFilterSheet,
              child: Container(
                margin: const EdgeInsets.all(6),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: kPrimaryGreen.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.tune, color: kPrimaryGreen, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── FILTER CHIPS ─────────────────────────
  Widget _buildFilterChips() {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _chip('All', null),
          const SizedBox(width: 8),
          _chip('Healthy', ScanStatus.healthy),
          const SizedBox(width: 8),
          _chip('Mold Detected', ScanStatus.moldDetected),
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

  // ── SCAN LIST ────────────────────────────
  Widget _buildScanList(List<ScanRecord> records) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      itemCount: records.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) =>
          _ScanCard(record: records[i], onTap: () => _openDetail(records[i])),
    );
  }

  // ── BOTTOM INFO BAR ──────────────────────
  Widget _buildBottomBar(List<ScanRecord> results) {
    if (results.isEmpty) return const SizedBox.shrink();
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
                  'Showing ${results.length} result${results.length == 1 ? '' : 's'}'
                  '${_activeFilter != null || _query.isNotEmpty ? ' for current filters' : ''}.',
                  style: const TextStyle(fontSize: 12, color: kSubtitle),
                ),
                if (_activeFilter != null || _query.isNotEmpty)
                  GestureDetector(
                    onTap: _clearFilters,
                    child: const Text(
                      'Clear all filters ×',
                      style: TextStyle(
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
          // Export PDF button
          ElevatedButton.icon(
            onPressed: _exportPDF,
            icon: const Icon(Icons.picture_as_pdf, size: 16),
            label: const Text(
              'Export PDF',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: kAccentGold,
              foregroundColor: kPrimaryGreen,
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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.history_toggle_off,
            size: 64,
            color: kPrimaryGreen.withOpacity(0.25),
          ),
          const SizedBox(height: 16),
          const Text(
            'No scans found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: kPrimaryGreen,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try adjusting your filters\nor scan a new maize sample.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: kSubtitle, height: 1.5),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: _clearFilters,
            child: const Text(
              'Clear filters',
              style: TextStyle(
                color: kPrimaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── BOTTOM NAV ───────────────────────────
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: kCardBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: 1, // History tab selected
        backgroundColor: kCardBg,
        selectedItemColor: kPrimaryGreen,
        unselectedItemColor: kSubtitle,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.of(
              context,
            ).pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
          } else if (index == 1) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('You are already on History')),
            );
          } else if (index == 2) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notifications coming soon')),
            );
          } else if (index == 3) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile coming soon')),
            );
          }
        },
      ),
    );
  }

  // ── ACTIONS ──────────────────────────────
  void _openDetail(ScanRecord record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: kDivider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                record.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: kPrimaryGreen,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Location: ${record.location}',
                style: const TextStyle(fontSize: 14, color: Color(0xFF263238)),
              ),
              const SizedBox(height: 4),
              Text(
                'Date: ${record.date}',
                style: const TextStyle(fontSize: 14, color: Color(0xFF263238)),
              ),
              const SizedBox(height: 12),
              Text(
                'Status: ${record.status == ScanStatus.moldDetected ? 'Mold Detected' : 'Healthy'}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: record.status == ScanStatus.moldDetected
                      ? kDangerRed
                      : kSafeGreen,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Match confidence: ${record.matchPercent}%',
                style: const TextStyle(fontSize: 14, color: Color(0xFF263238)),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _exportPDF() {
    // TODO: implement PDF export using pdf package
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generating PDF report…'),
        backgroundColor: kPrimaryGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _FilterSheet(
        current: _activeFilter,
        onApply: (f) {
          setState(() => _activeFilter = f);
          Navigator.pop(context);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────
//  SCAN CARD WIDGET
// ─────────────────────────────────────────
class _ScanCard extends StatelessWidget {
  final ScanRecord record;
  final VoidCallback onTap;

  const _ScanCard({required this.record, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isMoldy = record.status == ScanStatus.moldDetected;
    final statusColor = isMoldy ? kDangerRed : kSafeGreen;
    final statusLabel = isMoldy ? 'Mold Detected' : 'Healthy';
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
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Thumbnail ──
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(14),
              ),
              child: Container(
                width: 88,
                height: 88,
                color: kPrimaryGreen.withOpacity(0.08),
                child: record.imagePath.isNotEmpty
                    ? Image.asset(record.imagePath, fit: BoxFit.cover)
                    : Icon(
                        Icons.grain,
                        size: 36,
                        color: kPrimaryGreen.withOpacity(0.3),
                      ),
              ),
            ),

            // ── Content ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + match badge
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
                        // Match % badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
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

                    // Date
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
                    ),

                    const SizedBox(height: 8),

                    // Status badge
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: statusColor.withOpacity(0.3),
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
                        Icon(
                          Icons.chevron_right,
                          color: kSubtitle.withOpacity(0.5),
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
//  FILTER BOTTOM SHEET
// ─────────────────────────────────────────
class _FilterSheet extends StatefulWidget {
  final ScanStatus? current;
  final ValueChanged<ScanStatus?> onApply;

  const _FilterSheet({required this.current, required this.onApply});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  ScanStatus? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.current;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
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
          const Text(
            'Filter Scans',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: kPrimaryGreen,
            ),
          ),
          const SizedBox(height: 16),
          _filterTile('All Scans', null),
          _filterTile('Healthy Only', ScanStatus.healthy),
          _filterTile('Mold Detected Only', ScanStatus.moldDetected),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onApply(_selected),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Apply Filter',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterTile(String label, ScanStatus? value) {
    final selected = _selected == value;
    return GestureDetector(
      onTap: () => setState(() => _selected = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? kPrimaryGreen.withOpacity(0.08) : kCardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? kPrimaryGreen : kDivider,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: selected ? kPrimaryGreen : const Color(0xFF263238),
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: kPrimaryGreen, size: 20),
          ],
        ),
      ),
    );
  }
}
