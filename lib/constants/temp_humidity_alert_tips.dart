/// Content and trigger condition for the once-daily 7am heat + humidity
/// alert (see temp_humidity_alert_service.dart) — a single notification that
/// reports both readings together, since it's the combination (warm and
/// humid at once) that most accelerates aflatoxin growth, not either
/// reading alone. Kept as plain Dart constants like morning_alert_tips.dart:
/// the background isolate that fires this has no BuildContext to read
/// localizations from.
library;

const double tempHumidityAlertMinC = 25.0;
const double tempHumidityAlertMaxC = 35.0;
const double tempHumidityAlertHumidityThreshold = 70.0;

/// True only when both conditions hold at once: temperature within
/// [tempHumidityAlertMinC, tempHumidityAlertMaxC] and humidity above
/// [tempHumidityAlertHumidityThreshold].
bool shouldSendTempHumidityAlert({
  required double? temperatureC,
  required double? humidityPercent,
}) {
  if (temperatureC == null || humidityPercent == null) return false;
  final bool tempInRange =
      temperatureC >= tempHumidityAlertMinC && temperatureC <= tempHumidityAlertMaxC;
  final bool humidityHigh = humidityPercent > tempHumidityAlertHumidityThreshold;
  return tempInRange && humidityHigh;
}

String tempHumidityAlertTitle(String languageCode) {
  final bool lg = languageCode == 'lg';
  return lg ? "Okulabula kw'Ebbugumu n'Obunnyogovu" : 'Heat & Humidity Alert';
}

String tempHumidityAlertBody(
  String languageCode,
  int tempRounded,
  int humidityRounded,
  bool isTrader,
) {
  final bool lg = languageCode == 'lg';
  return isTrader
      ? (lg
            ? 'Ebbugumu buli ku $tempRounded°C n\'obunnyogovu ku $humidityRounded%. Embeera eno eyamba obulwadde okukula mangu — kebera ebibinja by\'omu masitoowa kaakano.'
            : 'Temperature is $tempRounded°C with humidity at $humidityRounded% — conditions that speed up mold growth. Check your stored batches now.')
      : (lg
            ? 'Ebbugumu buli ku $tempRounded°C n\'obunnyogovu ku $humidityRounded%. Embeera eno eyamba obulwadde okukula mangu — kebera emmere gy\'oyanjuluza n\'eterese kaakano.'
            : 'Temperature is $tempRounded°C with humidity at $humidityRounded% — conditions that speed up mold growth. Check your drying and stored grain now.');
}
