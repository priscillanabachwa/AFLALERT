import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
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

            const Expanded(
              child: Text(
                "Aflatoxin Detector",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),

            // Profile Avatar
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(21),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(21),
                child: Image.network(
                  "https://lh3.googleusercontent.com/aida-public/AB6AXuAwRSiGzZwcA1aTsiHtmoqcxCgC1WcwHRBlAUvXD5pFzt2UrQBm74MtCOmacUEqbeIkNnED_TgaeuynSeir6wTgT_JIL0aaODP7aqYWNi-r6eW4rOQcgx2C8q3PvjySxdtGvZeV1i2907_BZ-CcYNMQRt-sinaxxcUoEM23F3Th3f1RLaqtjXxyEi1MhsrQV2v7ZGB4rG7rA2NflW4G1G5vpHzg9xXI_V8HdYDVztUvEFLAjtqlNJg-fA",
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}