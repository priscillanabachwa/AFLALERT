import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide light/dark mode state, kept in sync with the persisted
/// 'darkModeEnabled' preference. MaterialApp listens to this so the
/// Settings toggle takes effect immediately, without an app restart.
class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController._internal() : super(ThemeMode.light) {
    _load();
  }

  static final ThemeController instance = ThemeController._internal();

  Future<void> _load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    value = (prefs.getBool('darkModeEnabled') ?? false)
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  Future<void> setDarkMode(bool enabled) async {
    value = enabled ? ThemeMode.dark : ThemeMode.light;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkModeEnabled', enabled);
  }
}
