import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../l10n/app_localizations.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Container(
        height: 70,
        color: AppColors.background,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [

            // Back Button
            InkWell(
              borderRadius: BorderRadius.circular(25),
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(21),
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: AppColors.primary,
                ),
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Text(
                l10n.aflatoxinDetector,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}