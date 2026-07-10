import 'package:flutter/material.dart';

import '../models/app_notification.dart';

/// In-memory, app-wide list of notifications shown on the Notifications
/// screen. Seeded with sample data; screens/services that detect real
/// events (e.g. a heat-risk alert on Home) call [add] to prepend a new one.
class NotificationCenter extends ChangeNotifier {
  NotificationCenter._internal();
  static final NotificationCenter instance = NotificationCenter._internal();

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
      iconColor: const Color(0xFF1B4332),
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

  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  void add(AppNotification notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  void markRead(AppNotification notification) {
    notification.unread = false;
    notifyListeners();
  }
}
