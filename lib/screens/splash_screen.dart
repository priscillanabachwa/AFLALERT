import 'dart:async';
import 'package:flutter/material.dart';
import 'package:aflalert/screens/welcomepage.dart';
import 'package:aflalert/screens/home_screen.dart';
import 'package:aflalert/services/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: -5,
      end: 5,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _redirect();
  }

  // Show the splash animation for at least 3 seconds while checking
  // whether a Firebase session already exists, then route accordingly.
  Future<void> _redirect() async {
    final results = await Future.wait([
      _authService.userStream.first,
      Future.delayed(const Duration(seconds: 3)),
    ]);
    if (!mounted) return;

    final user = results[0];
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            user != null ? const HomeScreen() : const OnboardingScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget buildDot(int delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return AnimatedOpacity(
          duration: Duration(milliseconds: 600 + delay),
          opacity: value,
          child: child,
        );
      },
      child: Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          color: Color(0xFFFFDF94),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              Color(0xFF1F5E43),
              Color(0xFF00462D),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),

              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_animation.value, 0),
                    child: child,
                  );
                },
                child: Image.asset(
                  'lib/assets/images/aflalert_logo.png',
                  width: 180,
                  height: 180,
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "AflAlert",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "AI Powered Aflatoxin Detection",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFB0F1CD),
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                ),
              ),

              const Spacer(),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildDot(0),
                  const SizedBox(width: 10),
                  buildDot(200),
                  const SizedBox(width: 10),
                  buildDot(400),
                ],
              ),

              const SizedBox(height: 30),

              const Text(
                "VIGILANT • INTELLIGENT • NURTURING",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  letterSpacing: 3,
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}