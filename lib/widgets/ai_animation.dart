import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AIAnimation extends StatefulWidget {
  const AIAnimation({super.key});

  @override
  State<AIAnimation> createState() => _AIAnimationState();
}

class _AIAnimationState extends State<AIAnimation>
    with TickerProviderStateMixin {

  late AnimationController _pulseController;
  late AnimationController _floatController;
  late AnimationController _orbitController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _floatController.dispose();
    _orbitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [

          AnimatedBuilder(
            animation: _pulseController,
            builder: (_, _) {
              return _PulseRing(
                progress: _pulseController.value,
                size: 170,
              );
            },
          ),

          AnimatedBuilder(
            animation: _pulseController,
            builder: (_, _) {
              return _PulseRing(
                progress: (_pulseController.value + .4) % 1,
                size: 230,
              );
            },
          ),

          AnimatedBuilder(
            animation: _orbitController,
            builder: (_, _) {

              double angle = _orbitController.value * 2 * pi;

              return Stack(
                children: [

                  Positioned(
                    left: 140 + cos(angle) * 100 - 6,
                    top: 140 + sin(angle) * 100 - 6,
                    child: _particle(
                      12,
                      const Color(0xFFFECE4B),
                    ),
                  ),

                  Positioned(
                    left: 140 + cos(angle + pi) * 85 - 5,
                    top: 140 + sin(angle + pi) * 85 - 5,
                    child: _particle(
                      10,
                      AppColors.primaryContainer,
                    ),
                  ),
                ],
              );
            },
          ),

          AnimatedBuilder(
            animation: _floatController,
            builder: (_, child) {

              double y = sin(_floatController.value * pi * 2) * 10;

              return Transform.translate(
                offset: Offset(0, y),
                child: child,
              );
            },
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: .18),
                    blurRadius: 25,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Image.asset(
                  "lib/assets/images/aflalert_logo.png",
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _particle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: .7),
            blurRadius: 10,
          ),
        ],
      ),
    );
  }
}

class _PulseRing extends StatelessWidget {

  final double progress;
  final double size;

  const _PulseRing({
    required this.progress,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {

    return Opacity(
      opacity: 1 - progress,
      child: Transform.scale(
        scale: 1 + progress * .45,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: .5),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}