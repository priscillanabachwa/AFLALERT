import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherInfo {
  final double temperatureC;
  final String condition;
  final IconData icon;

  const WeatherInfo({
    required this.temperatureC,
    required this.condition,
    required this.icon,
  });

  /// Maps the WMO weather codes returned by Open-Meteo to a short label and icon.
  /// https://open-meteo.com/en/docs#weathervariables
  factory WeatherInfo.fromCode(double temperatureC, int code) {
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

    return WeatherInfo(temperatureC: temperatureC, condition: condition, icon: icon);
  }
}

/// Trailing rainfall total for a location, used to tell whether the rains
/// have actually started/stopped rather than assuming a fixed calendar date.
class RainfallSummary {
  final double totalMm;
  final int windowDays;

  const RainfallSummary({required this.totalMm, required this.windowDays});
}

class WeatherService {
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  /// Fetches the current temperature and condition for the given coordinates.
  /// Returns `null` if the request fails for any reason.
  Future<WeatherInfo?> getCurrentWeather(double latitude, double longitude) async {
    final Uri url = Uri.parse(
      '$_baseUrl?latitude=$latitude&longitude=$longitude&current=temperature_2m,weather_code',
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
      final num? weatherCode = current['weather_code'] as num?;
      if (temperature == null || weatherCode == null) return null;

      return WeatherInfo.fromCode(temperature.toDouble(), weatherCode.toInt());
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
      '&daily=precipitation_sum&past_days=$days&forecast_days=1&timezone=auto',
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
}
