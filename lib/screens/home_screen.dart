import 'dart:async';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_colors.dart';
import '../constants/daily_tips.dart';
import '../constants/seasonal_guidelines.dart';
import '../l10n/app_localizations.dart';
import '../services/firestore_service.dart';
import '../services/location_service.dart';
import '../services/morning_alert_service.dart';
import '../services/rain_alert_service.dart';
import '../services/weather_service.dart';
import '../utils/user_initials.dart';
import '../widgets/coach_mark_overlay.dart';
import '../widgets/custom_bottom_nav.dart';
import 'analysis_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'strip_camera_screen.dart';
import 'strip_analysis_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Applied to text that sits directly on the background photo (rather than
  // inside an opaque card) so it stays legible regardless of image content.
  static const List<Shadow> _onImageShadow = [
    Shadow(color: Colors.black87, blurRadius: 8, offset: Offset(0, 1)),
  ];

  // Weather can change quickly, so keep it fresh instead of only fetching
  // once when the screen first mounts.
  static const Duration _refreshInterval = Duration(minutes: 2);

  LocationResult? _location;
  WeatherInfo? _weather;
  RainfallSummary? _rainfall;
  bool _weatherLoading = true;
  Timer? _weatherRefreshTimer;

  String _userType = '';
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _profileSub;

  // Hoisted so every StreamBuilder below shares one live subscription
  // instead of each creating (and re-creating on every rebuild) its own
  // separate Firestore listener on the same document.
  final Stream<DocumentSnapshot<Map<String, dynamic>>> _profileStream =
      FirestoreService().getUserProfile();

  // Hoisted for the same reason — both the stats bar (near the greeting)
  // and the Recent Scans list (further down) read from this one stream.
  final Stream<QuerySnapshot> _scanHistoryStream =
      FirestoreService().getUserScanHistory();

  // Edge-triggered so the alert fires once when it becomes hot, not on
  // every 5-minute refresh while it stays hot.
  bool _heatAlertNotified = false;
  bool _humidityAlertNotified = false;
  // First-launch walkthrough pointing out the scan buttons and weather card.
  static const String _prefCoachMarksSeen = 'home_coach_marks_seen';
  final GlobalKey _maizeScanKey = GlobalKey();
  final GlobalKey _stripScanKey = GlobalKey();
  final GlobalKey _weatherChipKey = GlobalKey();
  bool _showCoachMarks = false;

  @override
  void initState() {
    super.initState();
    _loadWeather();
    _weatherRefreshTimer = Timer.periodic(
      _refreshInterval,
      (_) => _loadWeather(),
    );
    _profileSub = _profileStream.listen((doc) {
      final String userType = doc.data()?['userType'] as String? ?? '';
      if (userType == _userType) return;
      setState(() => _userType = userType);
      MorningAlertService.cacheUserType(userType);
    });
    _maybeShowCoachMarks();
  }

  Future<void> _maybeShowCoachMarks() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_prefCoachMarksSeen) ?? false) return;
    if (!mounted) return;
    // Wait for the first real frame so the target widgets have a laid-out
    // RenderBox for the overlay to measure and spotlight.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _showCoachMarks = true);
    });
  }

  void _dismissCoachMarks() {
    setState(() => _showCoachMarks = false);
    SharedPreferences.getInstance().then(
      (prefs) => prefs.setBool(_prefCoachMarksSeen, true),
    );
  }

  @override
  void dispose() {
    _weatherRefreshTimer?.cancel();
    _profileSub?.cancel();
    super.dispose();
  }

  Future<void> _loadWeather() async {
    // Always request a fresh GPS fix rather than reusing a cached one, so a
    // move to a new location is reflected immediately.
    final LocationResult? location = await LocationService()
        .getCurrentLocation();
    if (location == null) {
      if (mounted) setState(() => _weatherLoading = false);
      return;
    }

    final WeatherService weatherService = WeatherService();
    final List<Object?> results = await Future.wait([
      weatherService.getCurrentWeather(location.latitude, location.longitude),
      weatherService.getRecentRainfall(location.latitude, location.longitude),
    ]);

    if (!mounted) return;
    setState(() {
      _location = location;
      _weather = results[0] as WeatherInfo?;
      _rainfall = results[1] as RainfallSummary?;
      _weatherLoading = false;
    });
    MorningAlertService.cacheLocation(location.latitude, location.longitude);
    RainAlertService.checkNow(latitude: location.latitude, longitude: location.longitude);
  }

  // Depends only on the calendar and rainfall, not on user type, so it can
  // be shared by both the Daily Tip card and the Guidelines card to keep
  // their content in sync.
  SeasonStage get _currentSeasonStage =>
      currentSeasonalGuideline(recentRainfallMm: _rainfall?.totalMm).stage;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.t95,
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/assets/images/homescreen.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    Colors.black.withValues(alpha: 0.35),
                    Colors.black.withValues(alpha: 0.45),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
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
                      stream: _profileStream,
                      builder: (context, snapshot) {
                        final Map<String, dynamic>? profile = snapshot.data
                            ?.data();
                        final String? fullName =
                            profile?['fullName'] as String?;
                        final String firstName =
                            (fullName != null && fullName.trim().isNotEmpty)
                            ? fullName.trim().split(' ').first
                            : l10n.defaultGreetingName;
                        final String userType =
                            profile?['userType'] as String? ?? '';
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildGreeting(firstName)),
                                const SizedBox(width: 12),
                                _buildCompactWeatherChip(context),
                              ],
                            ),
                            const SizedBox(height: 20),
                            StreamBuilder<QuerySnapshot>(
                              stream: _scanHistoryStream,
                              builder: (context, snapshot) {
                                final docs = snapshot.data?.docs ?? [];
                                return _buildStatsRow(docs);
                              },
                            ),
                            const SizedBox(height: 24),
                            _buildScanPicker(context),
                            const SizedBox(height: 24),
                            _buildTipCard(
                              tipForConditions(
                                userType,
                                _weather?.temperatureC,
                                humidityPercent: _weather?.humidityPercent,
                                currentStage: _currentSeasonStage,
                              ),
                              alertKindFor(
                                _weather?.temperatureC,
                                _weather?.humidityPercent,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 28),
                    Text(
                      l10n.guidelines,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: _onImageShadow,
                      ),
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream: _profileStream,
                      builder: (context, snapshot) {
                        final String userType =
                            snapshot.data?.data()?['userType'] as String? ?? '';
                        return _buildSeasonalGuidelineCard(userType);
                      },
                    ),
                    const SizedBox(height: 28),
                    StreamBuilder<QuerySnapshot>(
                      stream: _scanHistoryStream,
                      builder: (context, snapshot) {
                        final docs = snapshot.data?.docs ?? [];
                        final recentDocs = docs.take(2).toList();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildRecentScansHeader(),
                            const SizedBox(height: 16),
                            if (recentDocs.isEmpty)
                              _buildNoScansYet()
                            else
                              for (int i = 0; i < recentDocs.length; i++)
                                Padding(
                                  padding: EdgeInsets.only(
                                    bottom: i == recentDocs.length - 1 ? 0 : 12,
                                  ),
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
          if (_showCoachMarks)
            CoachMarkOverlay(
              steps: [
                CoachMarkStep(
                  targetKey: _maizeScanKey,
                  shape: CoachMarkShape.circle,
                  title: l10n.coachMarkMaizeTitle,
                  description: l10n.coachMarkMaizeDesc,
                ),
                CoachMarkStep(
                  targetKey: _stripScanKey,
                  shape: CoachMarkShape.circle,
                  title: l10n.coachMarkStripTitle,
                  description: l10n.coachMarkStripDesc,
                ),
                CoachMarkStep(
                  targetKey: _weatherChipKey,
                  title: l10n.coachMarkWeatherTitle,
                  description: l10n.coachMarkWeatherDesc,
                ),
              ],
              onFinished: _dismissCoachMarks,
            ),
        ],
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
            width: 50,
            height: 50,
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
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: _onImageShadow,
            ),
          ),
        ),
        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: _profileStream,
          builder: (context, snapshot) {
            final user = FirebaseAuth.instance.currentUser;
            final profile = snapshot.data?.data();
            final String name =
                profile?['fullName'] as String? ?? user?.displayName ?? '';
            final String photoUrl =
                profile?['photoUrl'] as String? ?? user?.photoURL ?? '';

            return InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.fromBorderSide(
                    BorderSide(color: AppColors.secondary, width: 2),
                  ),
                ),
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primaryContainer,
                  backgroundImage: photoUrl.isNotEmpty
                      ? NetworkImage(photoUrl)
                      : null,
                  child: photoUrl.isEmpty
                      ? Text(
                          getInitials(name).isNotEmpty
                              ? getInitials(name)
                              : '?',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  String _greetingForHour(AppLocalizations l10n, int hour) {
    if (hour >= 5 && hour < 12) return l10n.goodMorning;
    if (hour >= 12 && hour < 17) return l10n.goodAfternoon;
    if (hour >= 17 && hour < 21) return l10n.goodEvening;
    return l10n.goodNight;
  }

  Widget _buildGreeting(String name) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_greetingForHour(l10n, DateTime.now().hour)},',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w400,
            color: Colors.white,
            shadows: _onImageShadow,
          ),
        ),
        Text(
          name,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: _onImageShadow,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.homeSubGreeting,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
            shadows: _onImageShadow,
          ),
        ),
      ],
    );
  }

Widget _buildTipCard(String dailyTip, WeatherAlertKind alertKind) {
  final AppLocalizations l10n = AppLocalizations.of(context)!;

  final IconData icon = switch (alertKind) {
    WeatherAlertKind.heat => Icons.whatshot,
    WeatherAlertKind.humidity => Icons.water_drop,
    WeatherAlertKind.none => Icons.lightbulb_outline,
  };

  final String badgeLabel = switch (alertKind) {
    WeatherAlertKind.heat => l10n.heatAlertBadge,
    WeatherAlertKind.humidity => l10n.humidityAlertBadge,
    WeatherAlertKind.none => l10n.dailyTip,
  };

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.primaryContainer,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.secondary, size: 20),
        const SizedBox(height: 8),
        Text(
          badgeLabel,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.secondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          dailyTip,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            height: 1.4,
          ),
        ),
      ],
    ),
  );
}

  // Compact "location + degrees" chip that sits opposite the greeting.
  // Tapping it opens the full forecast rather than cluttering the home
  // screen with hourly detail up front.
  Widget _buildCompactWeatherChip(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () => _showWeatherForecast(context),
      child: Container(
        key: _weatherChipKey,
        constraints: const BoxConstraints(maxWidth: 90),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.successLight,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              (_location?.placeName?.toUpperCase()) ??
                  (_weatherLoading ? l10n.locating : l10n.locationUnavailable),
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
                letterSpacing: 0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              _weather != null ? '${_weather!.temperatureC.round()}°C' : '--°C',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWeatherForecast(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _WeatherForecastSheet(
        location: _location?.placeName,
        current: _weather,
        latitude: _location?.latitude,
        longitude: _location?.longitude,
      ),
    );
  }

  Widget _buildSeasonalGuidelineCard(String userType) {
    final double? recentRainfallMm = _rainfall?.totalMm;
    final SeasonalGuideline guideline = currentSeasonalGuideline(
      recentRainfallMm: recentRainfallMm,
    );
    final String advice = seasonalAdviceFor(guideline, userType);
    final String? caution = weatherCautionFor(
      guideline.stage,
      recentRainfallMm,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(guideline.icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  guideline.seasonLabel.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  guideline.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  advice,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary.withValues(alpha: 0.85),
                    height: 1.4,
                  ),
                ),
                if (caution != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.water_drop,
                        color: AppColors.error,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          caution,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.error,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onMaizeScanTap(BuildContext context) async {
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

  Future<void> _onStripTestTap(BuildContext context) async {
    final String? location =
        _location?.placeName ?? await LocationService().getCurrentPlaceName();
    if (!context.mounted) return;

    final Object? result = await Navigator.pushNamed(context, '/stripCamera');
    if (result is! StripCaptureResult || !context.mounted) return;

    Navigator.pushNamed(
      context,
      '/stripAnalysis',
      arguments: StripAnalysisScreenArgs(
        photo: result.photo,
        cropType: result.cropType,
        location: location,
      ),
    );
  }

  // Two circular start-a-test buttons, mirrored on opposite sides of the
  // row (maize scan left, strip test right) rather than the earlier stacked
  // rectangular cards.
  Widget _buildScanPicker(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildScanCircle(
          key: _maizeScanKey,
          // No Material icon depicts a maize cob, so the emoji glyph
          // reads more accurately than a generic agriculture/tractor icon.
          icon: const Text('🌽', style: TextStyle(fontSize: 34)),
          label: l10n.maizeScanLabel,
          gradientColors: const [
            AppColors.successLight,
            AppColors.successLight,
          ],
          contentColor: AppColors.primaryContainer,
          ringColor: AppColors.secondary,
          onTap: () => _onMaizeScanTap(context),
        ),
        _buildScanCircle(
          key: _stripScanKey,
          icon: const Icon(Icons.biotech_outlined, color: AppColors.primaryContainer, size: 36),
          label: l10n.stripScanLabel,
          gradientColors: const [
            AppColors.successLight,
            AppColors.successLight,
          ],
          contentColor: AppColors.primaryContainer,
          ringColor: AppColors.primaryContainer,
          onTap: () => _onStripTestTap(context),
        ),
      ],
    );
  }

  Widget _buildScanCircle({
    Key? key,
    required Widget icon,
    required String label,
    required List<Color> gradientColors,
    required Color contentColor,
    required Color ringColor,
    required VoidCallback onTap,
  }) {
    return Container(
      key: key,
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        shape: CircleBorder(
          side: BorderSide(color: ringColor, width: 4),
        ),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: contentColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static const List<String> _monthAbbrev = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static bool _isMoldyLabel(String label) {
    return RegExp(
          r'mold|aflatox|contamin|infect|positive',
          caseSensitive: false,
        ).hasMatch(label) &&
        !RegExp(
          r'ld|healthy|clean|safe|negative',
          caseSensitive: false,
        ).hasMatch(label);
  }

  // Docs saved before Tier 2 shipped have no `testType` field and keep
  // using the Tier 1 regex classifier; chemical scans compare ppb against
  // the safe limit stored alongside the reading instead.
  static bool _isRiskyDoc(Map<String, dynamic> data) {
    if (data['testType'] == 'chemical') {
      final num ppb = (data['ppbValue'] ?? 0) as num;
      final num limit = (data['safeLimitPpb'] ?? 0) as num;
      return ppb > limit;
    }
    return _isMoldyLabel((data['label'] ?? '').toString());
  }

  static String _formatScanDate(DateTime dt) =>
      '${_monthAbbrev[dt.month - 1]} ${dt.day}';

  static String _formatTime(DateTime dt) {
    final int hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final String minute = dt.minute.toString().padLeft(2, '0');
    final String period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _relativeTime(DateTime dt) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final Duration diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return l10n.justNow;
    if (diff.inMinutes < 60) return l10n.minAgo(diff.inMinutes);
    if (diff.inHours < 24) {
      return l10n.hoursAgo(diff.inHours);
    }
    if (diff.inDays == 1) return l10n.yesterdayAt(_formatTime(dt));
    if (diff.inDays < 7) return l10n.daysAgo(diff.inDays);
    return _formatScanDate(dt);
  }

  Widget _buildStatsRow(List<QueryDocumentSnapshot> docs) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    int healthy = 0;
    int risky = 0;
    String lastScanLabel = '--';

    if (docs.isNotEmpty) {
      for (final doc in docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (_isRiskyDoc(data)) {
          risky++;
        } else {
          healthy++;
        }
      }
      final Timestamp? latest =
          (docs.first.data() as Map<String, dynamic>)['timestamp']
              as Timestamp?;
      if (latest != null) lastScanLabel = _formatScanDate(latest.toDate());
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.successLight,
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
          _buildStatItem(
            '$healthy',
            l10n.healthyCaps,
            AppColors.primaryContainer,
          ),
          _buildDivider(),
          _buildStatItem('$risky', l10n.riskyCaps, AppColors.error),
          _buildDivider(),
          _buildStatItem(lastScanLabel, l10n.lastScanCaps, AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildNoScansYet() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        AppLocalizations.of(context)!.noScansYetHome,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.grey, fontSize: 13),
      ),
    );
  }

  Widget _buildScanTileFromDoc(QueryDocumentSnapshot doc) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final data = doc.data() as Map<String, dynamic>;
    final bool isChemical = data['testType'] == 'chemical';
    final String location = (data['location'] ?? '').toString();
    final bool isRisky = _isRiskyDoc(data);
    final Timestamp? timestamp = data['timestamp'] as Timestamp?;
    final String timeText = timestamp != null
        ? _relativeTime(timestamp.toDate())
        : l10n.justNow;
    final String subtitle = location.isNotEmpty
        ? '$location · $timeText'
        : timeText;
    final Color statusColor = isRisky
        ? AppColors.error
        : AppColors.primaryContainer;

    final String title;
    final String trailingText;
    if (isChemical) {
      final num ppb = (data['ppbValue'] ?? 0) as num;
      title = l10n.chemicalStripScanTitle;
      trailingText = l10n.ppbValueLabel(ppb.toStringAsFixed(1));
    } else {
      final String label = (data['label'] ?? 'Unknown').toString();
      final num confidenceRaw = (data['confidence'] ?? 0) as num;
      final int matchPercent =
          (confidenceRaw <= 1 ? confidenceRaw * 100 : confidenceRaw)
              .round()
              .clamp(0, 100);
      title = label;
      trailingText = l10n.matchPercentLabel(matchPercent);
    }

    return _buildScanTile(
      icon: isChemical
          ? Icons.science_outlined
          : (isRisky ? Icons.warning_amber_rounded : Icons.eco),
      iconColor: statusColor,
      title: title,
      subtitle: subtitle,
      badgeText: isRisky ? l10n.atRiskBadge : l10n.safeBadge,
      badgeColor: isRisky ? AppColors.errorLight : const Color(0xFFE8F5E9),
      badgeTextColor: statusColor,
      trailingText: trailingText,
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
    return Container(width: 1, height: 32, color: Colors.grey.shade200);
  }

  Widget _buildRecentScansHeader() {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l10n.recentScans,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: _onImageShadow,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HistoryScreen()),
          ),
          child: Text(
            l10n.seeAll,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.secondary,
              fontWeight: FontWeight.w600,
              shadows: _onImageShadow,
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
        color: AppColors.successLight,
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
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
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

// ─────────────────────────────────────────
//  WEATHER FORECAST SHEET
// ─────────────────────────────────────────
// Fetched on demand (not alongside the compact chip) since most visits to
// Home don't need the hour-by-hour breakdown — only pay for it when the
// user actually taps through.
class _WeatherForecastSheet extends StatefulWidget {
  final String? location;
  final WeatherInfo? current;
  final double? latitude;
  final double? longitude;

  const _WeatherForecastSheet({
    required this.location,
    required this.current,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<_WeatherForecastSheet> createState() => _WeatherForecastSheetState();
}

class _WeatherForecastSheetState extends State<_WeatherForecastSheet> {
  Future<DailyForecast?>? _forecastFuture;

  @override
  void initState() {
    super.initState();
    if (widget.latitude != null && widget.longitude != null) {
      _forecastFuture =
          WeatherService().getTodayForecast(widget.latitude!, widget.longitude!);
    }
  }

  static String _formatHour(DateTime time) {
    final int hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final String period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour$period';
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
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
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              widget.location?.toUpperCase() ?? l10n.locationUnavailable,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(widget.current?.icon ?? Icons.cloud_off, color: AppColors.secondary, size: 32),
                const SizedBox(width: 10),
                Text(
                  widget.current != null ? '${widget.current!.temperatureC.round()}°C' : '--°C',
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    widget.current?.condition ?? l10n.unavailable,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_forecastFuture == null)
              Text(l10n.locationUnavailable, style: const TextStyle(color: Colors.grey))
            else
              FutureBuilder<DailyForecast?>(
                future: _forecastFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                    );
                  }
                  final DailyForecast? forecast = snapshot.data;
                  if (forecast == null) {
                    return Text(
                      l10n.fetchingWeather,
                      style: const TextStyle(color: Colors.grey),
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            l10n.todayHighLowLabel(
                              forecast.maxC.round().toString(),
                              forecast.minC.round().toString(),
                            ),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 96,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: forecast.hours.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 18),
                          itemBuilder: (context, index) {
                            final HourlyForecastEntry hour = forecast.hours[index];
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  index == 0 ? l10n.nowLabel : _formatHour(hour.time),
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                                const SizedBox(height: 8),
                                Icon(
                                  hour.icon,
                                  // A single accent color made every hour
                                  // read as "daytime" regardless of the
                                  // icon shape, which is what made the
                                  // moon at 9PM look like an outlier
                                  // instead of the start of a night run.
                                  color: hour.isDay
                                      ? AppColors.secondary
                                      : const Color(0xFF7C8DB5),
                                  size: 22,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${hour.temperatureC.round()}°',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
