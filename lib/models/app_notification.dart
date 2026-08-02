import 'package:flutter/material.dart';

enum NotificationCategory { alert, update }

/// Named keys for every icon a notification can use, mapped to the actual
/// `Icons.x` constant. Persisting this key (instead of a raw codePoint) keeps
/// every IconData reference in the app a compile-time constant, which is
/// required for Flutter's icon font tree-shaking to keep the right glyphs.
const Map<String, IconData> _iconRegistry = {
  'whatshot': Icons.whatshot,
  'person_add_alt_1': Icons.person_add_alt_1,
  'lock_reset': Icons.lock_reset,
  'water_drop': Icons.water_drop,
  'wb_sunny': Icons.wb_sunny,
  'cloud': Icons.cloud,
};
const String _defaultIconKey = 'whatshot';

String iconKeyFor(IconData icon) => _iconRegistry.entries
    .firstWhere(
      (entry) => entry.value.codePoint == icon.codePoint,
      orElse: () => _iconRegistry.entries.first,
    )
    .key;

class AppNotification {
  AppNotification({
    String? id,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.category,
    this.unread = false,
    this.highPriority = false,
    this.actionLabel,
    DateTime? createdAt,
  }) : id = id ?? '${DateTime.now().microsecondsSinceEpoch}',
       createdAt = createdAt ?? DateTime.now();

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final NotificationCategory category;
  final String? actionLabel;
  final bool highPriority;
  final DateTime createdAt;
  bool unread; // mutable so tapping a card can mark it as read

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'iconKey': iconKeyFor(icon),
    'iconColor': iconColor.toARGB32(),
    'iconBackground': iconBackground.toARGB32(),
    'category': category.name,
    'actionLabel': actionLabel,
    'highPriority': highPriority,
    'unread': unread,
    'createdAt': createdAt.toIso8601String(),
  };

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final String iconKey = json['iconKey'] as String? ?? _defaultIconKey;
    return AppNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: _iconRegistry[iconKey] ?? _iconRegistry[_defaultIconKey]!,
      iconColor: Color(json['iconColor'] as int),
      iconBackground: Color(json['iconBackground'] as int),
      category: NotificationCategory.values.byName(json['category'] as String),
      actionLabel: json['actionLabel'] as String?,
      highPriority: json['highPriority'] as bool? ?? false,
      unread: json['unread'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
