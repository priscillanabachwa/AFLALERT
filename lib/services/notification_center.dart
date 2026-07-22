import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_notification.dart';

/// App-wide list of notifications shown on the Notifications screen,
/// persisted locally so it survives app restarts. Notifications only ever
/// leave this list when the user explicitly deletes them (or marks one
/// read) — nothing here auto-expires or auto-clears.
class NotificationCenter extends ChangeNotifier {
  NotificationCenter._internal() {
    _loaded = _load();
  }
  static final NotificationCenter instance = NotificationCenter._internal();

  static const String _prefsKey = 'notifications';

  final List<AppNotification> _notifications = [];

  // Guards _persist() so it can never write to disk before the initial
  // _load() has merged in whatever was already there — otherwise a
  // same-tick add() (as happens the moment a fresh isolate first touches
  // .instance, e.g. from a background task) can win the race and overwrite
  // the on-disk history with just the one new entry.
  late final Future<void> _loaded;

  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  Future<void> _load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> stored = prefs.getStringList(_prefsKey) ?? [];
    final List<AppNotification> loaded = stored
        .map((raw) => AppNotification.fromJson(jsonDecode(raw) as Map<String, dynamic>))
        .toList();

    // Merge rather than overwrite, in case add() was called while this
    // async load was still in flight.
    final Set<String> existingIds = _notifications.map((n) => n.id).toSet();
    _notifications.addAll(loaded.where((n) => !existingIds.contains(n.id)));
    _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();
  }

  Future<void> _persist() async {
    await _loaded;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _prefsKey,
      _notifications.map((n) => jsonEncode(n.toJson())).toList(),
    );
  }

  void add(AppNotification notification) {
    _notifications.insert(0, notification);
    notifyListeners();
    _persist();
  }

  void markRead(AppNotification notification) {
    notification.unread = false;
    notifyListeners();
    _persist();
  }

  void remove(AppNotification notification) {
    _notifications.removeWhere((n) => n.id == notification.id);
    notifyListeners();
    _persist();
  }
}
