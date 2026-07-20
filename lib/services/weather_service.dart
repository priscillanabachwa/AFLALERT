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
  }) {
    String condition;
    IconData icon;

    if (code == 0) {
      condition = 'Clear sky';
      icon = Icons.wb_sunny;
    } else if (code <= 2) {
      condition = 'Partly cloudy';
      icon = Icons.wb_cloudy;
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
class DailyForecast {
  final int weatherCode;
  final double? precipitationProbabilityMax;

  const DailyForecast({
    required this.weatherCode,
    this.precipitationProbabilityMax,
  });
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
      '&current=temperature_2m,relative_humidity_2m,weather_code'
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
      if (temperature == null || weatherCode == null) return null;

      return WeatherInfo.fromCode(
        temperature.toDouble(),
        weatherCode.toInt(),
        humidityPercent: humidity?.toDouble(),
      );
    } catch (error) {
      debugPrint('WeatherService Error fetching current weather: $error');
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
  Future<DailyForecast?> getTodayForecast(double latitude, double longitude) async {
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

      return DailyForecast(
        weatherCode: weatherCode.toInt(),
        precipitationProbabilityMax: precipProbability?.toDouble(),
      );
    } catch (error) {
      debugPrint('WeatherService Error fetching today\'s forecast: $error');
      return null;
    }
  }
}
