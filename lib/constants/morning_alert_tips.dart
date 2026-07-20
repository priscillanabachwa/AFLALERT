/// Content for the once-a-day morning weather alert (see
/// morning_alert_service.dart). Kept as plain Dart constants, like
/// daily_tips.dart and seasonal_guidelines.dart, rather than going through
/// AppLocalizations — the background isolate that builds this notification
/// has no BuildContext to read localizations from.
library;

enum MorningWeatherKind { rain, sunny, mixed }

/// Classifies today's forecast into a simple, alert-worthy bucket. Rain
/// takes priority whenever it's a real possibility, since it drives the more
/// urgent advice (cover drying grain); a clear, low-rain-chance forecast is
/// called out as sunny (good drying weather); anything else is "mixed" so
/// the alert still has something useful to say every morning.
MorningWeatherKind classifyMorningWeather({
  required int weatherCode,
  double? precipitationProbabilityMax,
}) {
  final bool rainLikely =
      (precipitationProbabilityMax != null && precipitationProbabilityMax >= 50) ||
      (weatherCode >= 51 && weatherCode <= 99);
  if (rainLikely) return MorningWeatherKind.rain;

  final bool clearSky = weatherCode <= 1;
  final bool lowRainChance =
      precipitationProbabilityMax == null || precipitationProbabilityMax < 20;
  if (clearSky && lowRainChance) return MorningWeatherKind.sunny;

  return MorningWeatherKind.mixed;
}

String morningAlertTitle(String languageCode, MorningWeatherKind kind) {
  final bool lg = languageCode == 'lg';
  switch (kind) {
    case MorningWeatherKind.rain:
      return lg ? 'Enkuba Esuubirwa Leero' : 'Rain Likely Today';
    case MorningWeatherKind.sunny:
      return lg ? 'Enjuba Nnyingi Leero' : 'Sunny Skies Today';
    case MorningWeatherKind.mixed:
      return lg ? "Embeera y'Obudde Leero" : "Today's Weather";
  }
}

String morningAlertAdvice(String languageCode, MorningWeatherKind kind, bool isTrader) {
  final bool lg = languageCode == 'lg';
  switch (kind) {
    case MorningWeatherKind.rain:
      return isTrader
          ? (lg
                ? 'Enkuba esuubirwa leero. Bikke ebibinja by\'emmere waggulu era obiteeke ku ntobo ez\'ekyuma, era kebera akasolya k\'olusaawo lwo obanga tekaayoloka.'
                : 'It looks like it will rain today. Keep stored bags covered and off the floor, and check your warehouse roof for leaks.')
          : (lg
                ? 'Enkuba esuubirwa leero. Bikka emmere gy\'oyanjuluza era lwana okukungula obanga kisoboka — emmere ennyoze yeesobola okuvunda mangu.'
                : 'It looks like it will rain today. Cover any drying grain and delay harvest if you can — wet grain molds fast.');
    case MorningWeatherKind.sunny:
      return isTrader
          ? (lg
                ? 'Enjuba nnyingi esuubirwa leero. Olunaku olulungi okuggulawo olusaawo, naye teeka ebibinja mu kisiikirize, ku bbugumu.'
                : 'Sunny skies expected today. Good day to air out the warehouse, but keep bags out of direct sun and heat.')
          : (lg
                ? 'Enjuba nnyingi esuubirwa leero. Olunaku olulungi okuyanjuluza emmere — naye tobirekayo nga zaakala.'
                : "Sunny skies expected today. A good day for drying grain — just don't leave it out once it's dry.");
    case MorningWeatherKind.mixed:
      return isTrader
          ? (lg
                ? 'Embeera y\'obudde tokimanyi leero. Kino kye kiseera ekirungi okukebera obunnyogovu mu bibinja by\'omu masitoowa.'
                : 'Weather looks mixed today. A good day to check moisture on your stored batches.')
          : (lg
                ? 'Embeera y\'obudde tokimanyi leero. Weekesse ku kimera kyo n\'emmere gy\'oterese nga bulijjo.'
                : 'Weather looks mixed today. Keep an eye on your crop and stored grain as usual.');
  }
}
