import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aflalert/screens/homescreen.dart';
import 'package:aflalert/screens/notifications_screen.dart'; 
import 'firebase_options.dart';

import 'package:aflalert/screens/splash_screen.dart';
import 'package:aflalert/screens/welcomepage.dart';
import 'package:aflalert/screens/login_screen.dart';
import 'package:aflalert/screens/analysis_screen.dart';
import 'package:aflalert/screens/registration_screen.dart';
import 'package:aflalert/screens/camerascreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const AflAlert());
}

class AflAlert extends StatelessWidget {
  const AflAlert({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AflAlert',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00462D),
          primary: const Color(0xFF00462D),
          secondary: const Color(0xFFFECE4B),
          surface: const Color(0xFFF8F9FA),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        textTheme: GoogleFonts.poppinsTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF00462D),
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00462D),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          hintStyle: TextStyle(color: Colors.grey.shade500),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00462D), width: 2),
          ),
        ),
      ),

      // Start the app at the root route
      initialRoute: '/',

      routes: {
        // --- TEMPORARY CHANGE FOR TESTING ---
        // I have pointed the starting route ('/') directly to NotificationsScreen.
        '/': (context) => const NotificationsScreen(),
        
        // I have commented out your SplashScreen temporarily. 
        // When you are done testing, just swap these two lines back!
        // '/': (context) { debugPrint('ROUTE_TRACE: building /'); return const SplashScreen(); },
        // ------------------------------------

        '/welcome': (context) { debugPrint('ROUTE_TRACE: building /welcome'); return const OnboardingScreen(); },
        '/login': (context) => const LoginScreen(),
        '/analysis': (context) => const AnalysisScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/camera': (context) { debugPrint('ROUTE_TRACE: building /camera'); return const CameraCaptureScreen(); },
        '/home': (context) => const HomeScreen(),
        '/notifications': (context) => const NotificationsScreen(), 
      },
    );
  }
}