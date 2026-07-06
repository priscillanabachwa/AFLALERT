import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

import '../widgets/custom_app_bar.dart';
import '../widgets/ai_animation.dart';
import '../widgets/progress_section.dart';
import '../widgets/custom_bottom_nav.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: AppColors.background,

      appBar: const PreferredSize(

        preferredSize: Size.fromHeight(70),

        child: CustomAppBar(),

      ),

      body: Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFDFDFD),
            Color(0xFFF4F8F5),
          ],
        ),
      ),
      child: Stack(
        children: [

          // Background Glow
          Positioned(
            top: -120,
            left: -100,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(.05),
              ),
            ),
          ),

          Positioned(
            bottom: -120,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFECE4B).withOpacity(.05),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: const [

                  SizedBox(height: 20),

                  AIAnimation(),

                  SizedBox(height: 40),

                  Text(
                    "Analyzing Image...",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),

                  SizedBox(height: 12),

                  Text(
                    "Our AI model is detecting visible mold associated with aflatoxin contamination.",
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 40),

                  ProgressSection(),

                ],
              ),
            ),
          ),

        ],
      ),
    ),

      bottomNavigationBar: const CustomBottomNav(),

    );

  }

}