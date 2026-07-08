import 'package:flutter/material.dart';

/// Standalone demo entry point.
///
/// Run this file as-is (`flutter run`) to preview the screen on its own,
/// or skip straight to copying the `NotificationsScreen` widget (and the
/// model/helper classes below it) into your own project and push it like
/// any other route:
///
///   Navigator.push(
///     context,
///     MaterialPageRoute(builder: (_) => const NotificationsScreen()),
///   );
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notifications ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: kBackground,
        colorScheme: ColorScheme.fromSeed(seedColor: kDarkGreen),
      ),
      home: const NotificationsScreen(),
    );
  }
}

// ---------------------------------------------------------------------------
// Palette — tweak these three values to re-theme the whole screen
// ---------------------------------------------------------------------------

const Color kBackground = Color(0xFFF3F1EC);
const Color kDarkGreen = Color(0xFF1B4332);
const Color kAmber = Color(0xFFF5B942);

// ---------------------------------------------------------------------------
// Model
// ---------------------------------------------------------------------------

enum NotificationCategory { alert, tip, update }

class AppNotification {
  AppNotification({
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.category,
    this.unread = false,
    this.highPriority = false,
    this.actionLabel,
  });

  final String title;
  final String description;
  final String time;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final NotificationCategory category;
  final String? actionLabel;
  final bool highPriority;
  bool unread; // mutable so tapping a card can mark it as read
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const List<String> _filters = ['All', 'Alerts', 'Tips', 'Updates'];
  String _selectedFilter = 'All';

  final List<AppNotification> _notifications = [
    AppNotification(
      title: 'Storage Issue Detected',
      description:
          'High humidity levels detected in the silo. Risk of fungal '
          'growth is increasing — immediate ventilation is recommended.',
      time: '2 hours ago',
      icon: Icons.warning_amber_rounded,
      iconColor: const Color(0xFFE0562A),
      iconBackground: const Color(0xFFFBDCCB),
      category: NotificationCategory.alert,
      unread: true,
      highPriority: true,
    ),
    AppNotification(
      title: 'AI Scan Completed',
      description:
          'Your recent batch analysis for Field A is ready. Soil quality '
          'and nutrient levels were successfully detected.',
      time: '4 hours ago',
      icon: Icons.check_circle_rounded,
      iconColor: kDarkGreen,
      iconBackground: const Color(0xFFCDE7D8),
      category: NotificationCategory.update,
      unread: true,
      actionLabel: 'VIEW',
    ),
    AppNotification(
      title: 'Task Running Slow',
      description:
          'Cover-crop irrigation is taking longer than expected. Check '
          'soil drainage and hose connections in Field C before the '
          'pre-harvest window closes.',
      time: '3 hours ago',
      icon: Icons.hourglass_bottom_rounded,
      iconColor: const Color(0xFFB07D0A),
      iconBackground: const Color(0xFFFBE7B8),
      category: NotificationCategory.alert,
      unread: true,
    ),
    AppNotification(
      title: 'System Update',
      description:
          'Data-sync accuracy improved for real-time content across all '
          'connected devices.',
      time: 'Yesterday',
      icon: Icons.sync_rounded,
      iconColor: const Color(0xFF6B7280),
      iconBackground: const Color(0xFFE5E7EB),
      category: NotificationCategory.update,
    ),
  ];

  List<AppNotification> get _filteredNotifications {
    switch (_selectedFilter) {
      case 'Alerts':
        return _notifications
            .where((n) => n.category == NotificationCategory.alert)
            .toList();
      case 'Tips':
        return _notifications
            .where((n) => n.category == NotificationCategory.tip)
            .toList();
      case 'Updates':
        return _notifications
            .where((n) => n.category == NotificationCategory.update)
            .toList();
      case 'All':
      default:
        return _notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredNotifications;

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xFFD9D3C7),
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _FilterRow(
                filters: _filters,
                selected: _selectedFilter,
                onSelected: (filter) =>
                    setState(() => _selectedFilter = filter),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: filtered.isEmpty
                    ? const _EmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 170),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final notification = filtered[index];
                          return _NotificationCard(
                            notification: notification,
                            onTap: () =>
                                setState(() => notification.unread = false),
                          );
                        },
                      ),
              ),
            ],
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: _TipBanner(
              onReadGuide: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Opening ventilation guide…'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter chip row (All / Alerts / Tips / Updates)
// ---------------------------------------------------------------------------

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.filters,
    required this.selected,
    required this.onSelected,
  });

  final List<String> filters;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = filter == selected;
          return ChoiceChip(
            label: Text(filter),
            selected: isSelected,
            showCheckmark: false,
            onSelected: (_) => onSelected(filter),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            selectedColor: kDarkGreen,
            backgroundColor: const Color(0xFFE7E3DA),
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Floating "tip" banner docked to the bottom of the screen
// ---------------------------------------------------------------------------

class _TipBanner extends StatelessWidget {
  const _TipBanner({required this.onReadGuide});

  final VoidCallback onReadGuide;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kDarkGreen,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Did you know?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Proper ventilation can reduce moisture buildup by up to '
            '40%, lowering the risk of fungal growth.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton(
              onPressed: onReadGuide,
              style: ElevatedButton.styleFrom(
                backgroundColor: kAmber,
                foregroundColor: Colors.black87,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              child: const Text(
                'Read Guide',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state (shown when a filter has no matching notifications)
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              "You're all caught up",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Notification card
// ---------------------------------------------------------------------------

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18);

    final card = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _IconBadge(notification: notification),
                  const SizedBox(width: 14),
                  Expanded(child: _CardBody(notification: notification)),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (!notification.highPriority) {
      return Padding(padding: const EdgeInsets.only(bottom: 14), child: card);
    }

    // High-priority notifications get a red accent bar down the left edge.
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.only(left: 12),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: Colors.red.shade400, width: 4),
          ),
        ),
        child: card,
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: notification.iconBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(notification.icon, color: notification.iconColor),
    );
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            if (notification.unread)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(left: 8, top: 6),
                decoration: const BoxDecoration(
                  color: kDarkGreen,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          notification.description,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13.5,
            height: 1.4,
          ),
        ),
        if (notification.actionLabel != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEDEBE5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              notification.actionLabel!,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 11.5,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
        const SizedBox(height: 10),
        Text(
          notification.time,
          style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
        ),
      ],
    );
  }
}