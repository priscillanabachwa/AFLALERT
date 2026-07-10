import 'dart:async';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../services/firestore_service.dart';
import '../services/location_service.dart';
import '../services/weather_service.dart';
import '../widgets/custom_bottom_nav.dart';
import 'analysis_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Weather can change quickly, so keep it fresh instead of only fetching
  // once when the screen first mounts.
  static const Duration _refreshInterval = Duration(minutes: 5);

  LocationResult? _location;
  WeatherInfo? _weather;
  bool _weatherLoading = true;
  Timer? _weatherRefreshTimer;

  @override
  void initState() {
    super.initState();
    _loadWeather();
    _weatherRefreshTimer = Timer.periodic(_refreshInterval, (_) => _loadWeather());
  }

  @override
  void dispose() {
    _weatherRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadWeather() async {
    // Always request a fresh GPS fix rather than reusing a cached one, so a
    // move to a new location is reflected immediately.
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
      backgroundColor: AppColors.t95,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _loadWeather,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                _buildHeader(context),
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
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            'lib/assets/images/aflalert_logo.png',
            width: 36,
            height: 36,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.shield_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'AflAlert',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          ),
          child: const CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.secondary,
            child: Icon(Icons.person_outline, color: AppColors.primary, size: 20),
          ),
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
            color: AppColors.primary,
          ),
        ),
        Text(
          name,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
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
                    color: AppColors.primary,
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
                Icon(_weather?.icon ?? Icons.cloud_off, color: AppColors.secondary, size: 28),
              ],
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.lightbulb_outline, color: AppColors.secondary, size: 20),
                SizedBox(height: 8),
                Text(
                  'DAILY TIP',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
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
            color: AppColors.primary,
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
          _buildStatItem('$healthy', 'HEALTHY', AppColors.primaryContainer),
          _buildDivider(),
          _buildStatItem('$risky', 'RISKY', AppColors.error),
          _buildDivider(),
          _buildStatItem(lastScanLabel, 'LAST SCAN', AppColors.primary),
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
    final Color statusColor = isMoldy ? AppColors.error : AppColors.primaryContainer;

    return _buildScanTile(
      icon: isMoldy ? Icons.warning_amber_rounded : Icons.eco,
      iconColor: statusColor,
      title: label,
      subtitle: subtitle,
      badgeText: isMoldy ? 'AT RISK' : 'SAFE',
      badgeColor: isMoldy ? AppColors.errorLight : const Color(0xFFE8F5E9),
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
            color: AppColors.primary,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: const Text(
            'See All',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.secondary,
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
                    color: AppColors.primary,
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

}