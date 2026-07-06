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

      body: SafeArea(

        child: SingleChildScrollView(

          child: Padding(

            padding: const EdgeInsets.all(20),

            child: Column(

              children: const [

                SizedBox(height:30),

                AIAnimation(),

                SizedBox(height:40),

                Text(

                  "Analyzing Image...",

                  style: TextStyle(

                    fontSize:30,

                    fontWeight: FontWeight.bold,

                    color: AppColors.primary,

                  ),

                ),

                SizedBox(height:15),

                Text(

                  "Our AI model is detecting visible mold associated with aflatoxin contamination.",

                  textAlign: TextAlign.center,

                ),

                SizedBox(height:40),

                ProgressSection(),

                SizedBox(height:40),


              ],

            ),

          ),

        ),

      ),

      bottomNavigationBar: const CustomBottomNav(),

    );

  }

}