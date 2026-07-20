import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../constants/morning_alert_tips.dart';
import '../models/app_notification.dart';
import 'local_notification_service.dart';
import 'notification_center.dart';
import 'weather_service.dart';

const String _uniqueName = 'morningWeatherAlert';
const String _taskName = 'morningWeatherAlertTask';

const String _prefLat = 'morningAlert.lat';
const String _prefLon = 'morningAlert.lon';
const String _prefUserType = 'morningAlert.userType';

const int _alertHour = 7;

/// Schedules (and re-schedules) a once-daily, live-fetched weather alert —
/// "Rain Likely Today" / "Sunny Skies Today" plus role-specific advice —
/// delivered via Android's WorkManager so it fires even if the app isn't
/// open. Android-only: iOS background execution timing can't be guaranteed
/// by any plugin, so this isn't wired up for iOS.
class MorningAlertService {
  MorningAlertService._();

  /// Call once from main() after the app starts. Registers the background
  /// callback dispatcher and, if no alert is currently scheduled, kicks off
  /// the first one for the next occurrence of [_alertHour].
  static Future<void> initializeAndSchedule() async {
    await Workmanager().initialize(callbackDispatcher);
    final bool alreadyScheduled = await Workmanager().isScheduledByUniqueName(_uniqueName);
    if (!alreadyScheduled) {
      await _scheduleNext();
    }
  }

  /// Caches the last known location so the background task has somewhere to
  /// fetch weather for without needing a fresh (and background-restricted)
  /// GPS fix of its own. Call this whenever the app successfully loads
  /// weather in the foreground.
  static Future<void> cacheLocation(double latitude, double longitude) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_prefLat, latitude);
    await prefs.setDouble(_prefLon, longitude);
  }

  /// Caches the signed-in user's role so the background task can pick
  /// farmer- vs trader-specific advice.
  static Future<void> cacheUserType(String userType) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefUserType, userType);
  }

  /// Runs the exact same fetch/classify/notify logic as the scheduled
  /// background task, but immediately in the calling isolate — for manually
  /// verifying the alert content without waiting for the next 7am. Debug
  /// use only; see the "Test Morning Alert Now" tile in Settings.
  static Future<void> testNow() => _runMorningAlert();

  static Future<void> _scheduleNext() async {
    await Workmanager().registerOneOffTask(
      _uniqueName,
      _taskName,
      initialDelay: _delayUntilNextAlertHour(),
      existingWorkPolicy: ExistingWorkPolicy.replace,
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  static Duration _delayUntilNextAlertHour() {
    final DateTime now = DateTime.now();
    DateTime next = DateTime(now.year, now.month, now.day, _alertHour);
    if (!next.isAfter(now)) {
      next = next.add(const Duration(days: 1));
    }
    return next.difference(now);
  }
}

/// Runs in a separate background isolate with no access to the running
/// app's state, so everything it needs (location, user type, language) is
/// read back out of SharedPreferences rather than passed in memory.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == _taskName) {
      await _runMorningAlert();
    }
    // Always reschedule, even if this run found nothing to alert on, so the
    // daily chain keeps going.
    await MorningAlertService._scheduleNext();
    return true;
  });
}

Future<void> _runMorningAlert() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final double? latitude = prefs.getDouble(_prefLat);
  final double? longitude = prefs.getDouble(_prefLon);
  if (latitude == null || longitude == null) return;

  final MorningWeatherSummary? forecast =
      await WeatherService().getMorningWeatherSummary(latitude, longitude);
  if (forecast == null) return;

  final MorningWeatherKind kind = classifyMorningWeather(
    weatherCode: forecast.weatherCode,
    precipitationProbabilityMax: forecast.precipitationProbabilityMax,
  );
  final String userType = prefs.getString(_prefUserType) ?? '';
  final bool isTrader = userType.trim().toLowerCase() == 'trader';
  final String languageCode = prefs.getString('languageCode') ?? 'en';

  final String title = morningAlertTitle(languageCode, kind);
  final String body = morningAlertAdvice(languageCode, kind, isTrader);
  final String notificationId = DateTime.now().microsecondsSinceEpoch.toString();

  NotificationCenter.instance.add(
    AppNotification(
      id: notificationId,
      title: title,
      description: body,
      icon: switch (kind) {
        MorningWeatherKind.rain => Icons.water_drop,
        MorningWeatherKind.sunny => Icons.wb_sunny,
        MorningWeatherKind.mixed => Icons.cloud,
      },
      iconColor: const Color(0xFF2A7DE0),
      iconBackground: const Color(0xFFCBE0FB),
      category: NotificationCategory.alert,
      unread: true,
    ),
  );

  await LocalNotificationService.instance.show(
    title: title,
    body: body,
    notificationId: notificationId,
  );
}
