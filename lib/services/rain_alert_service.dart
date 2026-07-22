import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../constants/rain_alert_tips.dart';
import '../models/app_notification.dart';
import 'local_notification_service.dart';
import 'notification_center.dart';
import 'weather_service.dart';

/// Dispatched to from MorningAlertService's single callbackDispatcher —
/// Workmanager only supports one registered callback per app, so the daily
/// morning alert and this periodic rain check share it.
const String rainAlertTaskName = 'imminentRainAlertTask';
const String _uniqueName = 'imminentRainAlert';

// Matches the keys MorningAlertService caches on every foreground weather
// load (see home_screen.dart), so this reuses that cache instead of
// maintaining a second copy of the same location/user-type.
const String _prefLat = 'morningAlert.lat';
const String _prefLon = 'morningAlert.lon';
const String _prefUserType = 'morningAlert.userType';

const String _prefNotifiedRainStart = 'imminentRain.notifiedRainStart';

// How far ahead the forecast is scanned for incoming rain.
const int _windowHours = 2;

/// Fires an urgent alert ("Rain in 2 hours, cover or move drying grain now")
/// the moment rain becomes imminent, independent of the once-daily 7am
/// morning summary (see morning_alert_service.dart). Runs on a periodic
/// Android WorkManager task (15 min is the platform minimum, so it still
/// fires with the app closed) and is also called after every foreground
/// weather refresh for a faster response while the app is open.
class RainAlertService {
  RainAlertService._();

  /// Call once from main(), after MorningAlertService has initialized
  /// Workmanager — its single callback dispatcher handles both task types.
  static Future<void> initializeAndSchedule() async {
    await Workmanager().registerPeriodicTask(
      _uniqueName,
      rainAlertTaskName,
      frequency: const Duration(minutes: 15),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  /// Checks for imminent rain and notifies if found. Pass [latitude]/
  /// [longitude] when calling from the foreground (a fresh GPS fix is
  /// already in hand); omit to fall back to the cached location, which is
  /// what the background task does.
  static Future<void> checkNow({double? latitude, double? longitude}) =>
      runImminentRainCheck(latitude: latitude, longitude: longitude);
}

/// Runs in the shared background isolate (see morning_alert_service.dart's
/// callbackDispatcher) as well as directly from the foreground, so — like
/// _runMorningAlert — it reads everything it needs from SharedPreferences or
/// its params rather than in-memory app state.
Future<void> runImminentRainCheck({double? latitude, double? longitude}) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final double? lat = latitude ?? prefs.getDouble(_prefLat);
  final double? lon = longitude ?? prefs.getDouble(_prefLon);
  if (lat == null || lon == null) return;

  final ImminentRainForecast? forecast =
      await WeatherService().getImminentRain(lat, lon, windowHours: _windowHours);

  if (forecast == null) {
    // Nothing imminent right now — clear so a later, genuinely new rain
    // event is free to notify again.
    await prefs.remove(_prefNotifiedRainStart);
    return;
  }

  // Edge-triggered: the same rain event gets (re-)detected on every check
  // until it arrives, so only notify the first time it's seen.
  final String eventKey = forecast.rainStartsAt.toIso8601String();
  if (prefs.getString(_prefNotifiedRainStart) == eventKey) return;
  await prefs.setString(_prefNotifiedRainStart, eventKey);

  final String userType = prefs.getString(_prefUserType) ?? '';
  final bool isTrader = userType.trim().toLowerCase() == 'trader';
  final String languageCode = prefs.getString('languageCode') ?? 'en';
  final int hoursUntilRain = forecast.hoursUntilRain;

  final String title = rainAlertTitle(languageCode, hoursUntilRain);
  final String body = rainAlertBody(languageCode, hoursUntilRain, isTrader);
  final String notificationId = DateTime.now().microsecondsSinceEpoch.toString();

  NotificationCenter.instance.add(
    AppNotification(
      id: notificationId,
      title: title,
      description: body,
      icon: Icons.umbrella,
      iconColor: const Color(0xFF2A7DE0),
      iconBackground: const Color(0xFFCBE0FB),
      category: NotificationCategory.alert,
      unread: true,
      highPriority: true,
    ),
  );

  await LocalNotificationService.instance.show(
    title: title,
    body: body,
    notificationId: notificationId,
  );
}
