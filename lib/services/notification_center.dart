import 'package:flutter/material.dart';

import '../models/app_notification.dart';

/// In-memory, app-wide list of notifications shown on the Notifications
/// screen. Starts empty; screens/services that detect real events (e.g. a
/// heat-risk alert on Home) call [add] to prepend a new one.
class NotificationCenter extends ChangeNotifier {
  NotificationCenter._internal();
  static final NotificationCenter instance = NotificationCenter._internal();

  final List<AppNotification> _notifications = [];

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
