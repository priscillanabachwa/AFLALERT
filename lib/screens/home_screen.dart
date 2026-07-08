import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/firestore_service.dart';
import '../services/location_service.dart';
import '../services/weather_service.dart';
import 'analysis_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const Color darkGreen = Color(0xFF1E3A24);
  static const Color primaryGreen = Color(0xFF355E3B);
  static const Color gold = Color(0xFFD9A520);
  static const Color background = Color(0xFFF8F6F0);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color darkGreen = HomeScreen.darkGreen;
  static const Color primaryGreen = HomeScreen.primaryGreen;
  static const Color gold = HomeScreen.gold;
  static const Color background = HomeScreen.background;

  LocationResult? _location;
  WeatherInfo? _weather;
  bool _weatherLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    final LocationResult? location = await LocationService().getCurrentLocation();
    if (location == null) {
      if (mounted) setState(() => _weatherLoading = false);
      return;
    }

    final WeatherInfo? weather =
        await WeatherService().getCurrentWeather(location.latitude, location.longitude);

    if (!mounted) return;
    setState(() {
      _location = location;
      _weather = weather;
      _weatherLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              _buildHeader(),
              const SizedBox(height: 24),
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirestoreService().getUserProfile(),
                builder: (context, snapshot) {
                  final String? fullName = snapshot.data?.data()?['fullName'] as String?;
                  final String firstName = (fullName != null && fullName.trim().isNotEmpty)
                      ? fullName.trim().split(' ').first
                      : 'there';
                  return _buildGreeting(firstName);
                },
              ),
              const SizedBox(height: 20),
              _buildInfoCards(),
              const SizedBox(height: 32),
              _buildScanButton(context),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'Tap to scan crops',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              StreamBuilder<QuerySnapshot>(
                stream: FirestoreService().getUserScanHistory(),
                builder: (context, snapshot) {
                  final docs = snapshot.data?.docs ?? [];
                  final recentDocs = docs.take(2).toList();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatsRow(docs),
                      const SizedBox(height: 28),
                      _buildRecentScansHeader(),
                      const SizedBox(height: 16),
                      if (recentDocs.isEmpty)
                        _buildNoScansYet()
                      else
                        for (int i = 0; i < recentDocs.length; i++)
                          Padding(
                            padding: EdgeInsets.only(bottom: i == recentDocs.length - 1 ? 0 : 12),
                            child: _buildScanTileFromDoc(recentDocs[i]),
                          ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 88),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: darkGreen,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.shield_outlined,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'Aflatoxin Detector',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: darkGreen,
          ),
        ),
        const Spacer(),
        const CircleAvatar(
          radius: 20,
          backgroundColor: gold,
          child: Icon(Icons.person, color: Colors.white),
        ),
      ],
    );
  }

  static String _greetingForHour(int hour) {
    if (hour >= 5 && hour < 12) return 'Good Morning';
    if (hour >= 12 && hour < 17) return 'Good Afternoon';
    if (hour >= 17 && hour < 21) return 'Good Evening';
    return 'Good Night';
  }

  Widget _buildGreeting(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_greetingForHour(DateTime.now().hour)},',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w400,
            color: darkGreen,
          ),
        ),
        Text(
          name,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: darkGreen,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Ready to secure your harvest today?',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCards() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (_location?.placeName?.toUpperCase()) ??
                      (_weatherLoading ? 'LOCATING...' : 'LOCATION UNAVAILABLE'),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _weather != null ? '${_weather!.temperatureC.round()}°C' : '--°C',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: darkGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _weather?.condition ?? (_weatherLoading ? 'Fetching weather...' : 'Unavailable'),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),
                Icon(_weather?.icon ?? Icons.cloud_off, color: gold, size: 28),
              ],
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryGreen,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.lightbulb_outline, color: gold, size: 20),
                SizedBox(height: 8),
                Text(
                  'DAILY TIP',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: gold,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Keep corn moisture below 13.5% to prevent mold growth.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _onScanTap(BuildContext context) async {
    // Reuse the location already resolved for the weather card when
    // possible, falling back to a fresh lookup if that hasn't landed yet.
    final String? location =
        _location?.placeName ?? await LocationService().getCurrentPlaceName();
    if (!context.mounted) return;

    final Object? photo = await Navigator.pushNamed(context, '/camera');
    if (photo is! XFile || !context.mounted) return;

    Navigator.pushNamed(
      context,
      '/analysis',
      arguments: AnalysisScreenArgs(photo: photo, location: location),
    );
  }

  Widget _buildScanButton(BuildContext context) {
    return Center(
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300, width: 8),
        ),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: darkGreen,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => _onScanTap(context),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.camera_alt, color: Colors.white, size: 36),
                  SizedBox(height: 8),
                  Text(
                    'AI SCAN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static const List<String> _monthAbbrev = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static bool _isMoldyLabel(String label) {
    return RegExp(r'mold|aflatox|contamin|infect|positive', caseSensitive: false).hasMatch(label) &&
        !RegExp(r'no mold|healthy|clean|safe|negative', caseSensitive: false).hasMatch(label);
  }

  static String _formatScanDate(DateTime dt) => '${_monthAbbrev[dt.month - 1]} ${dt.day}';

  static String _formatTime(DateTime dt) {
    final int hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final String minute = dt.minute.toString().padLeft(2, '0');
    final String period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  static String _relativeTime(DateTime dt) {
    final Duration diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    if (diff.inDays == 1) return 'Yesterday, ${_formatTime(dt)}';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return _formatScanDate(dt);
  }

  Widget _buildStatsRow(List<QueryDocumentSnapshot> docs) {
    int healthy = 0;
    int risky = 0;
    String lastScanLabel = '--';

    if (docs.isNotEmpty) {
      for (final doc in docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (_isMoldyLabel((data['label'] ?? '').toString())) {
          risky++;
        } else {
          healthy++;
        }
      }
      final Timestamp? latest = (docs.first.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
      if (latest != null) lastScanLabel = _formatScanDate(latest.toDate());
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatItem('$healthy', 'HEALTHY', primaryGreen),
          _buildDivider(),
          _buildStatItem('$risky', 'RISKY', const Color(0xFFC62828)),
          _buildDivider(),
          _buildStatItem(lastScanLabel, 'LAST SCAN', darkGreen),
        ],
      ),
    );
  }

  Widget _buildNoScansYet() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28),
      alignment: Alignment.center,
      child: const Text(
        'No scans yet — tap "AI Scan" above to check your first batch.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey, fontSize: 13),
      ),
    );
  }

  Widget _buildScanTileFromDoc(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final String label = (data['label'] ?? 'Unknown').toString();
    final String location = (data['location'] ?? '').toString();
    final num confidenceRaw = (data['confidence'] ?? 0) as num;
    final int matchPercent =
        (confidenceRaw <= 1 ? confidenceRaw * 100 : confidenceRaw).round().clamp(0, 100);
    final bool isMoldy = _isMoldyLabel(label);
    final Timestamp? timestamp = data['timestamp'] as Timestamp?;
    final String timeText = timestamp != null ? _relativeTime(timestamp.toDate()) : 'Just now';
    final String subtitle = location.isNotEmpty ? '$location · $timeText' : timeText;
    final Color statusColor = isMoldy ? const Color(0xFFC62828) : primaryGreen;

    return _buildScanTile(
      icon: isMoldy ? Icons.warning_amber_rounded : Icons.eco,
      iconColor: statusColor,
      title: label,
      subtitle: subtitle,
      badgeText: isMoldy ? 'AT RISK' : 'SAFE',
      badgeColor: isMoldy ? const Color(0xFFFDECEA) : const Color(0xFFE8F5E9),
      badgeTextColor: statusColor,
      trailingText: '$matchPercent% Match',
      trailingColor: statusColor,
    );
  }

  Widget _buildStatItem(String value, String label, Color valueColor) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 32,
      color: Colors.grey.shade200,
    );
  }

  Widget _buildRecentScansHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Recent Scans',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: darkGreen,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: const Text(
            'See All',
            style: TextStyle(
              fontSize: 13,
              color: gold,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScanTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeColor,
    required Color badgeTextColor,
    required String trailingText,
    required Color trailingColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: darkGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: badgeTextColor,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                trailingText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: trailingColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: darkGreen,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home, 'Home', true),
          _buildNavItem(Icons.history, 'History', false),
          _buildNavItem(Icons.notifications_none, 'Notifications', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive ? gold : Colors.white70,
          size: 24,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? gold : Colors.white70,
          ),
        ),
      ],
    );
  }
}