import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../models/app_notification.dart';
import '../services/notification_center.dart';
import '../widgets/custom_bottom_nav.dart';

/// Standalone demo entry point.
///
/// Run this file as-is (`flutter run`) to preview the screen on its own,
/// or skip straight to copying the `NotificationsScreen` widget (and the
/// model/helper classes below it) into your own project and push it like
/// any other route:
///
///   Navigator.push(
///     context,
///     MaterialPageRoute(builder: (_) => const NotificationsScreen()),
///   );
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notifications ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: kBackground,
        colorScheme: ColorScheme.fromSeed(seedColor: kDarkGreen),
      ),
      home: const NotificationsScreen(),
    );
  }
}

// ---------------------------------------------------------------------------
// Palette — tweak these three values to re-theme the whole screen
// ---------------------------------------------------------------------------

const Color kBackground = Color(0xFFF3F1EC);
const Color kDarkGreen = Color(0xFF1B4332);
const Color kAmber = Color(0xFFF5B942);

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const List<String> _filters = ['All', 'Alerts', 'Updates'];
  String _selectedFilter = 'All';

  // Id of the notification to scroll to and highlight, passed in as the
  // route argument when the user taps a device notification. Cleared once
  // the highlight has faded, so it only applies to the initial landing.
  String? _highlightId;
  bool _scrolledToHighlight = false;
  final Map<String, GlobalKey> _itemKeys = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_highlightId == null && !_scrolledToHighlight) {
      final Object? args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        _highlightId = args;
        // Force "All" so the targeted notification can't be hidden by
        // whatever filter happened to be selected.
        _selectedFilter = 'All';
      }
    }
  }

  void _scrollToHighlightIfReady() {
    if (_highlightId == null || _scrolledToHighlight) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final BuildContext? itemContext = _itemKeys[_highlightId]?.currentContext;
      if (itemContext == null) return;
      _scrolledToHighlight = true;
      Scrollable.ensureVisible(
        itemContext,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        alignment: 0.1,
      );
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _highlightId = null);
      });
    });
  }

  List<AppNotification> _filteredNotifications(List<AppNotification> notifications) {
    switch (_selectedFilter) {
      case 'Alerts':
        return notifications.where((n) => n.category == NotificationCategory.alert).toList();
      case 'Updates':
        return notifications.where((n) => n.category == NotificationCategory.update).toList();
      case 'All':
      default:
        return notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: NotificationCenter.instance,
      builder: (context, _) {
        final filtered = _filteredNotifications(NotificationCenter.instance.notifications);
        _scrollToHighlightIfReady();

        return Scaffold(
          backgroundColor: kBackground,
          appBar: AppBar(
            backgroundColor: kBackground,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primaryContainer),
              onPressed: () => Navigator.maybePop(context),
            ),
            title: Text(
              AppLocalizations.of(context)!.notifications,
              style: const TextStyle(
                color: AppColors.primaryContainer,
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
            ),
          ),
          body: Column(
            children: [
              _FilterRow(
                filters: _filters,
                selected: _selectedFilter,
                onSelected: (filter) => setState(() => _selectedFilter = filter),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: filtered.isEmpty
                    ? _EmptyState(filter: _selectedFilter)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final notification = filtered[index];
                          final GlobalKey itemKey =
                              _itemKeys.putIfAbsent(notification.id, () => GlobalKey());
                          return Dismissible(
                            key: ValueKey(notification.id),
                            direction: DismissDirection.endToStart,
                            background: _DeleteBackground(),
                            onDismissed: (_) =>
                                NotificationCenter.instance.remove(notification),
                            child: KeyedSubtree(
                              key: itemKey,
                              child: _NotificationCard(
                                notification: notification,
                                highlighted: notification.id == _highlightId,
                                onTap: () => NotificationCenter.instance.markRead(notification),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          bottomNavigationBar: const CustomBottomNav(currentIndex: 2),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Filter chip row (All / Alerts / Tips / Updates)
// ---------------------------------------------------------------------------

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.filters,
    required this.selected,
    required this.onSelected,
  });

  final List<String> filters;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (int i = 0; i < filters.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(child: _buildChip(context, filters[i])),
          ],
        ],
      ),
    );
  }

  String _filterLabel(AppLocalizations l10n, String filter) {
    switch (filter) {
      case 'Alerts':
        return l10n.alertsFilter;
      case 'Updates':
        return l10n.updatesFilter;
      default:
        return l10n.allFilter;
    }
  }

  Widget _buildChip(BuildContext context, String filter) {
    final bool isSelected = filter == selected;
    return ChoiceChip(
      label: Center(child: Text(_filterLabel(AppLocalizations.of(context)!, filter))),
      selected: isSelected,
      showCheckmark: false,
      onSelected: (_) => onSelected(filter),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: FontWeight.w600,
      ),
      selectedColor: kDarkGreen,
      backgroundColor: const Color(0xFFE7E3DA),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}

// ---------------------------------------------------------------------------
// Swipe-to-delete background
// ---------------------------------------------------------------------------

class _DeleteBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(
        color: Colors.red.shade400,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Icon(Icons.delete_outline, color: Colors.white),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state (shown when a filter has no matching notifications)
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filter});

  final String filter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final String message = switch (filter) {
      'Alerts' => l10n.noAlertsMessage,
      'Updates' => l10n.noUpdatesMessage,
      _ => l10n.allCaughtUp,
    };
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Notification card
// ---------------------------------------------------------------------------

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.onTap,
    this.highlighted = false,
  });

  final AppNotification notification;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18);

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: highlighted ? kAmber.withValues(alpha: 0.22) : Colors.white,
        borderRadius: radius,
        border: highlighted ? Border.all(color: kAmber, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _IconBadge(notification: notification),
                  const SizedBox(width: 14),
                  Expanded(child: _CardBody(notification: notification)),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (!notification.highPriority) {
      return Padding(padding: const EdgeInsets.only(bottom: 14), child: card);
    }

    // High-priority notifications get a red accent bar down the left edge.
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.only(left: 12),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: Colors.red.shade400, width: 4),
          ),
        ),
        child: card,
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: notification.iconBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(notification.icon, color: notification.iconColor),
    );
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            if (notification.unread)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(left: 8, top: 6),
                decoration: const BoxDecoration(
                  color: kDarkGreen,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          notification.description,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13.5,
            height: 1.4,
          ),
        ),
        if (notification.actionLabel != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEDEBE5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              notification.actionLabel!,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 11.5,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
        const SizedBox(height: 10),
        Text(
          notification.relativeTime,
          style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
        ),
      ],
    );
  }
}