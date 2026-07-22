import 'package:flutter/material.dart';

import '../constants/temp_humidity_alert_tips.dart';
import '../models/app_notification.dart';
import 'local_notification_service.dart';
import 'notification_center.dart';
import 'weather_service.dart';

/// Runs as part of the same once-daily 7am background task as the morning
/// rain/sunny alert (see morning_alert_service.dart), rather than being
/// scheduled separately, so it also fires exactly once a day. Sends its own,
/// separate notification when conditions at that moment are risky on both
/// fronts at once — temperature 25-35°C *and* humidity above 70%.
Future<void> runTempHumidityAlert({
  required double latitude,
  required double longitude,
  required String userType,
  required String languageCode,
}) async {
  final WeatherInfo? weather = await WeatherService().getCurrentWeather(latitude, longitude);
  if (weather == null) return;

  final bool alert = shouldSendTempHumidityAlert(
    temperatureC: weather.temperatureC,
    humidityPercent: weather.humidityPercent,
  );
  if (!alert) return;

  final bool isTrader = userType.trim().toLowerCase() == 'trader';
  final int tempRounded = weather.temperatureC.round();
  final int humidityRounded = weather.humidityPercent!.round();

  final String title = tempHumidityAlertTitle(languageCode);
  final String body = tempHumidityAlertBody(languageCode, tempRounded, humidityRounded, isTrader);
  final String notificationId = DateTime.now().microsecondsSinceEpoch.toString();

  NotificationCenter.instance.add(
    AppNotification(
      id: notificationId,
      title: title,
      description: body,
      icon: Icons.thermostat,
      iconColor: const Color(0xFFE0562A),
      iconBackground: const Color(0xFFFBDCCB),
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
