import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../screens/home_screen.dart';
import '../screens/history_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/profile_screen.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNav({super.key, this.currentIndex = 0});

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    final Widget destination = switch (index) {
      0 => const HomeScreen(),
      1 => const HistoryScreen(),
      2 => const NotificationsScreen(),
      _ => const ProfileScreen(),
    };

    Navigator.push(context, MaterialPageRoute(builder: (_) => destination));
  }

  Widget _navItem(
    BuildContext context,
    IconData icon,
    String label,
    int index,
  ) {
    final bool selected = currentIndex == index;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _onTap(context, index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.secondary : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: selected ? AppColors.primary : Colors.white70,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  color: selected ? AppColors.primary : Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 72,
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .18),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _navItem(context, Icons.home_outlined, "Home", 0),
            _navItem(context, Icons.history, "History", 1),
            _navItem(context, Icons.notifications_none, "Notifications", 2),
            _navItem(context, Icons.person_outline, "Profile", 3),
          ],
        ),
      ),
    );
  }
}
