import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomBottomNav extends StatefulWidget {
  const CustomBottomNav({super.key});

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav> {

  int selectedIndex = 1;

  Widget navItem(
      IconData icon,
      String label,
      int index,
      ) {

    bool selected = selectedIndex == index;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          setState(() {
            selectedIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primaryContainer
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Icon(
                icon,
                color: selected
                    ? Colors.white
                    : Colors.grey.shade600,
              ),

              const SizedBox(height: 4),

              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected
                      ? FontWeight.bold
                      : FontWeight.w500,
                  color: selected
                      ? Colors.white
                      : Colors.grey.shade600,
                ),
              )
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [

            navItem(Icons.home_outlined, "Home", 0),

            navItem(Icons.history, "History", 1),

            navItem(Icons.notifications_none, "Alerts", 2),

            navItem(Icons.person_outline, "Profile", 3),

          ],
        ),
      ),
    );
  }
}