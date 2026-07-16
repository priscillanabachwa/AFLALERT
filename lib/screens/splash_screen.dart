import 'dart:async';
import 'package:flutter/material.dart';
import 'package:aflalert/screens/welcomepage.dart';
import 'package:aflalert/screens/home_screen.dart';
import 'package:aflalert/services/firebase_auth.dart';
import '../l10n/app_localizations.dart';

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


  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
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

              Text(
                l10n.splashTagline,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFB0F1CD),
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                ),
              ),

              const Spacer(),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _LoadingDot(delayMs: 0),
                  SizedBox(width: 10),
                  _LoadingDot(delayMs: 200),
                  SizedBox(width: 10),
                  _LoadingDot(delayMs: 400),
                ],
              ),

              const SizedBox(height: 30),

              Text(
                l10n.splashMotto,
                style: const TextStyle(
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

// A dot that fades in, then pulses in a continuous loop (staggered by
// [delayMs]) to read as an active loading indicator rather than a
// one-shot fade-in.
class _LoadingDot extends StatefulWidget {
  final int delayMs;

  const _LoadingDot({required this.delayMs});

  @override
  State<_LoadingDot> createState() => _LoadingDotState();
}

class _LoadingDotState extends State<_LoadingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _opacity = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
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
}