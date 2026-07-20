import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'navigation_service.dart';

/// Thin wrapper around `flutter_local_notifications` for firing real
/// device notifications (e.g. a heat-risk alert) alongside the in-app
/// Notifications screen entries.
class LocalNotificationService {
  LocalNotificationService._internal();
  static final LocalNotificationService instance = LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  int _nextId = 0;

  static const AndroidNotificationDetails _androidDetails = AndroidNotificationDetails(
    'aflalert_alerts',
    'AflAlert Alerts',
    channelDescription: 'Weather and storage risk alerts from AflAlert',
    importance: Importance.high,
    priority: Priority.high,
  );

  Future<void> init() async {
    if (_initialized) return;

    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    try {
      await _plugin.initialize(
        const InitializationSettings(android: androidInit, iOS: iosInit),
        onDidReceiveNotificationResponse: (response) =>
            _openNotifications(response.payload),
      );
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      _initialized = true;

      // App was launched (cold start) by tapping a notification, rather than
      // resumed from background — the tap response above only fires for the
      // latter, so this covers the former.
      final NotificationAppLaunchDetails? launchDetails =
          await _plugin.getNotificationAppLaunchDetails();
      if (launchDetails?.didNotificationLaunchApp ?? false) {
        final String? payload = launchDetails?.notificationResponse?.payload;
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _openNotifications(payload),
        );
      }
    } catch (error) {
      debugPrint('LocalNotificationService init error: $error');
    }
  }

  void _openNotifications([String? notificationId]) {
    navigatorKey.currentState?.pushNamed(
      '/notifications',
      arguments: notificationId,
    );
  }

  /// Shows a device notification. [notificationId] should match the id of
  /// the corresponding [AppNotification] added to [NotificationCenter] (see
  /// home_screen.dart), so tapping this notification can scroll straight to
  /// it on the Notifications screen.
  Future<void> show({
    required String title,
    required String body,
    String? notificationId,
  }) async {
    if (!_initialized) await init();
    try {
      await _plugin.show(
        _nextId++,
        title,
        body,
        const NotificationDetails(android: _androidDetails),
        payload: notificationId,
      );
    } catch (error) {
      debugPrint('LocalNotificationService show error: $error');
    }
  }
}
