/// Content for the urgent "rain incoming" alert (see rain_alert_service.dart)
/// — separate from the once-daily morning summary (morning_alert_tips.dart)
/// because it needs to fire the moment rain becomes imminent, not wait for
/// the next 7am check. Kept as plain Dart constants for the same reason as
/// morning_alert_tips.dart: the background isolate that can trigger this has
/// no BuildContext to read localizations from.
library;

String _hourWord(int hoursUntilRain) => hoursUntilRain == 1 ? 'hour' : 'hours';

String rainAlertTitle(String languageCode, int hoursUntilRain) {
  final bool lg = languageCode == 'lg';
  return lg
      ? 'Enkuba Mu Ssaawa $hoursUntilRain'
      : 'Rain Alert — $hoursUntilRain ${_hourWord(hoursUntilRain)}';
}

String rainAlertBody(String languageCode, int hoursUntilRain, bool isTrader) {
  final bool lg = languageCode == 'lg';
  final String hourWord = _hourWord(hoursUntilRain);
  return isTrader
      ? (lg
            ? 'Enkuba esuubirwa okutonnya mu ssaawa $hoursUntilRain. Kebera akasolya k\'olusaawo era ositule ebibinja okuva ku ntobo kaakano.'
            : 'Rain in $hoursUntilRain $hourWord, check the warehouse roof and move bags off the floor now.')
      : (lg
            ? 'Enkuba esuubirwa okutonnya mu ssaawa $hoursUntilRain. Bikka oba sengula emmere gy\'oyanjuluza kaakano.'
            : 'Rain in $hoursUntilRain $hourWord, cover or move drying grain now.');
}
