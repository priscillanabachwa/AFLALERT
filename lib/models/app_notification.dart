import 'package:flutter/material.dart';

enum NotificationCategory { alert, update }

class AppNotification {
  AppNotification({
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.category,
    this.unread = false,
    this.highPriority = false,
    this.actionLabel,
  });

  final String title;
  final String description;
  final String time;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final NotificationCategory category;
  final String? actionLabel;
  final bool highPriority;
  bool unread; // mutable so tapping a card can mark it as read
}
