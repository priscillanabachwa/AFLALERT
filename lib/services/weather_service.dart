import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherInfo {
  final double temperatureC;
  final double? humidityPercent;
  final String condition;
  final IconData icon;

  const WeatherInfo({
    required this.temperatureC,
    this.humidityPercent,
    required this.condition,
    required this.icon,
  });

  /// Maps the WMO weather codes returned by Open-Meteo to a short label and icon.
  /// https://open-meteo.com/en/docs#weathervariables
  factory WeatherInfo.fromCode(
    double temperatureC,
    int code, {
    double? humidityPercent,
    // Codes 0-2 describe sky/cloud cover, not light level, so a "clear" or
    // "partly cloudy" reading after sunset would otherwise still show a sun
    // icon. Open-Meteo's `is_day` flag lets us swap in a night icon instead.
    bool isDay = true,
  }) {
    String condition;
    IconData icon;

    if (code == 0) {
      condition = 'Clear sky';
      icon = isDay ? Icons.wb_sunny : Icons.nights_stay;
    } else if (code <= 2) {
      condition = 'Partly cloudy';
      icon = isDay ? Icons.wb_cloudy : Icons.cloud;
    } else if (code == 3) {
      condition = 'Cloudy';
      icon = Icons.cloud;
    } else if (code == 45 || code == 48) {
      condition = 'Foggy';
      icon = Icons.foggy;
    } else if (code >= 51 && code <= 57) {
      condition = 'Drizzle';
      icon = Icons.grain;
    } else if (code >= 61 && code <= 67) {
      condition = 'Rain';
      icon = Icons.water_drop;
    } else if (code >= 71 && code <= 77) {
      condition = 'Snow';
      icon = Icons.ac_unit;
    } else if (code >= 80 && code <= 82) {
      condition = 'Rain showers';
      icon = Icons.water_drop;
    } else if (code >= 95) {
      condition = 'Thunderstorm';
      icon = Icons.thunderstorm;
    } else {
      condition = 'Cloudy';
      icon = Icons.cloud;
    }

    return WeatherInfo(
      temperatureC: temperatureC,
      humidityPercent: humidityPercent,
      condition: condition,
      icon: icon,
    );
  }
}

/// Trailing rainfall total for a location, used to tell whether the rains
/// have actually started/stopped rather than assuming a fixed calendar date.
class RainfallSummary {
  final double totalMm;
  final int windowDays;

  const RainfallSummary({required this.totalMm, required this.windowDays});
}

/// Today's forecast summary, used to decide the wording of the morning
/// weather alert (see morning_alert_service.dart).
class DailyAlertForecast {
  final int weatherCode;
  final double? precipitationProbabilityMax;

  const DailyAlertForecast({
    required this.weatherCode,
    this.precipitationProbabilityMax,
  });
}

class HourlyForecastEntry {
  final DateTime time;
  final double temperatureC;
  final String condition;
  final IconData icon;
  final bool isDay;

  const HourlyForecastEntry({
    required this.time,
    required this.temperatureC,
    required this.condition,
    required this.icon,
    required this.isDay,
  });
}

/// Today's forecast — trailing off the hourly array from Open-Meteo's
/// forecast endpoint (same source as [WeatherService.getCurrentWeather], so
/// no separate API/key setup) so the expanded weather card has something to
/// show beyond the single current reading.
class DailyForecast {
  final double minC;
  final double maxC;
  final List<HourlyForecastEntry> hours;

  const DailyForecast({
    required this.minC,
    required this.maxC,
    required this.hours,
  });
}

/// Lightweight today's-forecast summary used only to decide the wording of
/// the morning weather alert (see morning_alert_service.dart) — distinct
/// from [DailyForecast], which backs the full hour-by-hour forecast sheet.
class MorningWeatherSummary {
  final int weatherCode;
  final double? precipitationProbabilityMax;

  const MorningWeatherSummary({
    required this.weatherCode,
    this.precipitationProbabilityMax,
  });
}

/// Result of scanning the near-term hourly forecast for incoming rain (see
/// [WeatherService.getImminentRain]) — powers the urgent "rain in X hours"
/// alert, distinct from [MorningWeatherSummary]'s once-daily summary.
class ImminentRainForecast {
  final DateTime rainStartsAt;

  const ImminentRainForecast({required this.rainStartsAt});

  /// Hours from now until [rainStartsAt], rounded up and floored at 1 so the
  /// alert never reads "Rain in 0 hours".
  int get hoursUntilRain {
    final int minutes = rainStartsAt.difference(DateTime.now()).inMinutes;
    final int hours = (minutes / 60).ceil();
    return hours < 1 ? 1 : hours;
  }
}

class WeatherService {
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  // Open-Meteo's auto-picked "best_match" model disagreed with real
  // conditions in Kampala by a wide margin (84% vs an actual ~63% relative
  // humidity), while GFS matched the observed temperature almost exactly in
  // the same check. Pinning the model keeps results consistent instead of
  // silently switching between models Open-Meteo considers "best" per query.
  static const String _model = 'gfs_seamless';

  /// Fetches the current temperature and condition for the given coordinates.
  /// Returns `null` if the request fails for any reason.
  Future<WeatherInfo?> getCurrentWeather(double latitude, double longitude) async {
    final Uri url = Uri.parse(
      '$_baseUrl?latitude=$latitude&longitude=$longitude'
      '&current=temperature_2m,relative_humidity_2m,weather_code,is_day'
      '&models=$_model',
    );

    try {
      final http.Response response =
          await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        debugPrint('WeatherService Failure: Server returned status code ${response.statusCode}');
        return null;
      }

      final Map<String, dynamic> data = jsonDecode(response.body);
      final Map<String, dynamic>? current = data['current'] as Map<String, dynamic>?;
      if (current == null) return null;

      final num? temperature = current['temperature_2m'] as num?;
      final num? humidity = current['relative_humidity_2m'] as num?;
      final num? weatherCode = current['weather_code'] as num?;
      final num? isDay = current['is_day'] as num?;
      if (temperature == null || weatherCode == null) return null;

      return WeatherInfo.fromCode(
        temperature.toDouble(),
        weatherCode.toInt(),
        humidityPercent: humidity?.toDouble(),
        isDay: isDay != 0,
      );
    } catch (error) {
      debugPrint('WeatherService Error fetching current weather: $error');
      return null;
    }
  }

  /// Fetches the hour-by-hour forecast plus today's min/max for the given
  /// coordinates. Returns `null` if the request fails for any reason.
  Future<DailyForecast?> getTodayForecast(double latitude, double longitude) async {
    final Uri url = Uri.parse(
      '$_baseUrl?latitude=$latitude&longitude=$longitude'
      '&hourly=temperature_2m,weather_code,is_day'
      '&daily=temperature_2m_max,temperature_2m_min'
      '&forecast_days=1&timezone=auto'
      '&models=$_model',
    );

    try {
      final http.Response response =
          await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        debugPrint('WeatherService Failure: Server returned status code ${response.statusCode}');
        return null;
      }

      final Map<String, dynamic> data = jsonDecode(response.body);

      final Map<String, dynamic>? daily = data['daily'] as Map<String, dynamic>?;
      final List<dynamic>? maxList = daily?['temperature_2m_max'] as List<dynamic>?;
      final List<dynamic>? minList = daily?['temperature_2m_min'] as List<dynamic>?;
      final num? maxC = maxList != null && maxList.isNotEmpty ? maxList.first as num? : null;
      final num? minC = minList != null && minList.isNotEmpty ? minList.first as num? : null;
      if (maxC == null || minC == null) return null;

      final Map<String, dynamic>? hourly = data['hourly'] as Map<String, dynamic>?;
      final List<dynamic>? times = hourly?['time'] as List<dynamic>?;
      final List<dynamic>? temps = hourly?['temperature_2m'] as List<dynamic>?;
      final List<dynamic>? codes = hourly?['weather_code'] as List<dynamic>?;
      final List<dynamic>? isDayFlags = hourly?['is_day'] as List<dynamic>?;
      if (times == null || temps == null || codes == null) return null;

      final DateTime now = DateTime.now();
      final List<HourlyForecastEntry> hours = [];
      for (int i = 0; i < times.length && i < temps.length && i < codes.length; i++) {
        final DateTime? time = DateTime.tryParse(times[i] as String);
        final num? temp = temps[i] as num?;
        final num? code = codes[i] as num?;
        if (time == null || temp == null || code == null) continue;
        // Only the remaining hours of today are useful in a "today's
        // forecast" view — earlier hours have already passed.
        if (time.isBefore(now.subtract(const Duration(hours: 1)))) continue;

        final num? isDay = isDayFlags != null && i < isDayFlags.length
            ? isDayFlags[i] as num?
            : null;
        final WeatherInfo info = WeatherInfo.fromCode(
          temp.toDouble(),
          code.toInt(),
          isDay: isDay != 0,
        );
        hours.add(HourlyForecastEntry(
          time: time,
          temperatureC: info.temperatureC,
          condition: info.condition,
          icon: info.icon,
          isDay: isDay != 0,
        ));
      }

      return DailyForecast(minC: minC.toDouble(), maxC: maxC.toDouble(), hours: hours);
    } catch (error) {
      debugPrint('WeatherService Error fetching today\'s forecast: $error');
      return null;
    }
  }

  /// Fetches total rainfall over the trailing [days] (including today) for
  /// the given coordinates, using Open-Meteo's `past_days` window on the
  /// same forecast endpoint. Returns `null` if the request fails for any
  /// reason.
  Future<RainfallSummary?> getRecentRainfall(
    double latitude,
    double longitude, {
    int days = 14,
  }) async {
    final Uri url = Uri.parse(
      '$_baseUrl?latitude=$latitude&longitude=$longitude'
      '&daily=precipitation_sum&past_days=$days&forecast_days=1&timezone=auto'
      '&models=$_model',
    );

    try {
      final http.Response response =
          await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        debugPrint('WeatherService Failure: Server returned status code ${response.statusCode}');
        return null;
      }

      final Map<String, dynamic> data = jsonDecode(response.body);
      final Map<String, dynamic>? daily = data['daily'] as Map<String, dynamic>?;
      final List<dynamic>? precipitation = daily?['precipitation_sum'] as List<dynamic>?;
      if (precipitation == null) return null;

      final double total = precipitation
          .whereType<num>()
          .fold(0.0, (double sum, num value) => sum + value.toDouble());

      return RainfallSummary(totalMm: total, windowDays: days);
    } catch (error) {
      debugPrint('WeatherService Error fetching recent rainfall: $error');
      return null;
    }
  }

  /// Fetches today's forecast summary (expected weather and max chance of
  /// rain) for the given coordinates, used to decide the wording of the
  /// morning weather alert. Returns `null` if the request fails for any
  /// reason.
  Future<DailyAlertForecast?> getDailyAlertForecast(double latitude, double longitude) async {
    final Uri url = Uri.parse(
      '$_baseUrl?latitude=$latitude&longitude=$longitude'
      '&daily=weather_code,precipitation_probability_max&forecast_days=1&timezone=auto'
      '&models=$_model',
    );

    try {
      final http.Response response =
          await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        debugPrint('WeatherService Failure: Server returned status code ${response.statusCode}');
        return null;
      }

      final Map<String, dynamic> data = jsonDecode(response.body);
      final Map<String, dynamic>? daily = data['daily'] as Map<String, dynamic>?;
      final List<dynamic>? weatherCodes = daily?['weather_code'] as List<dynamic>?;
      final List<dynamic>? precipProbabilities =
          daily?['precipitation_probability_max'] as List<dynamic>?;
      final num? weatherCode = weatherCodes?.isNotEmpty == true
          ? weatherCodes!.first as num?
          : null;
      if (weatherCode == null) return null;

      final num? precipProbability = precipProbabilities?.isNotEmpty == true
          ? precipProbabilities!.first as num?
          : null;

      return DailyAlertForecast(
        weatherCode: weatherCode.toInt(),
        precipitationProbabilityMax: precipProbability?.toDouble(),
      );
    } catch (error) {
      debugPrint('WeatherService Error fetching morning forecast: $error');
      return null;
    }
  }

  /// Scans the next [windowHours] of hourly forecast for the earliest hour
  /// where rain becomes likely (same threshold as the morning summary: 50%+
  /// precipitation probability, or a rain/showers/thunderstorm weather
  /// code). Returns `null` if no rain is expected within the window, or if
  /// the request fails for any reason.
  Future<ImminentRainForecast?> getImminentRain(
    double latitude,
    double longitude, {
    int windowHours = 2,
  }) async {
    final Uri url = Uri.parse(
      '$_baseUrl?latitude=$latitude&longitude=$longitude'
      '&hourly=precipitation_probability,weather_code'
      '&forecast_days=2&timezone=auto'
      '&models=$_model',
    );

    try {
      final http.Response response =
          await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        debugPrint('WeatherService Failure: Server returned status code ${response.statusCode}');
        return null;
      }

      final Map<String, dynamic> data = jsonDecode(response.body);
      final Map<String, dynamic>? hourly = data['hourly'] as Map<String, dynamic>?;
      final List<dynamic>? times = hourly?['time'] as List<dynamic>?;
      final List<dynamic>? precipProbabilities =
          hourly?['precipitation_probability'] as List<dynamic>?;
      final List<dynamic>? codes = hourly?['weather_code'] as List<dynamic>?;
      if (times == null || precipProbabilities == null || codes == null) return null;

      final DateTime now = DateTime.now();
      final DateTime windowEnd = now.add(Duration(hours: windowHours));

      for (int i = 0; i < times.length && i < precipProbabilities.length && i < codes.length; i++) {
        final DateTime? time = DateTime.tryParse(times[i] as String);
        if (time == null || time.isBefore(now) || time.isAfter(windowEnd)) continue;

        final num? precipProbability = precipProbabilities[i] as num?;
        final num? code = codes[i] as num?;
        if (code == null) continue;

        final bool rainLikely =
            (precipProbability != null && precipProbability >= 50) ||
            (code >= 51 && code <= 99);
        if (rainLikely) {
          return ImminentRainForecast(rainStartsAt: time);
        }
      }

      return null;
    } catch (error) {
      debugPrint('WeatherService Error fetching imminent rain forecast: $error');
      return null;
    }
  }
}
