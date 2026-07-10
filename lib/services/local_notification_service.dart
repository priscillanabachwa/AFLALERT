import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
      );
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      _initialized = true;
    } catch (error) {
      debugPrint('LocalNotificationService init error: $error');
    }
  }

  Future<void> show({required String title, required String body}) async {
    if (!_initialized) await init();
    try {
      await _plugin.show(
        _nextId++,
        title,
        body,
        const NotificationDetails(android: _androidDetails),
      );
    } catch (error) {
      debugPrint('LocalNotificationService show error: $error');
    }
  }
}
