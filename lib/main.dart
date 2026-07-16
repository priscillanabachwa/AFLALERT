import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:aflalert/screens/home_screen.dart';

import 'firebase_options.dart';

import 'package:aflalert/screens/splash_screen.dart';
import 'package:aflalert/screens/welcomepage.dart';
import 'package:aflalert/screens/login_screen.dart';
import 'package:aflalert/screens/analysis_screen.dart';
import 'package:aflalert/screens/registration_screen.dart';
import 'package:aflalert/screens/camera_screen.dart';
import 'package:aflalert/screens/downloaded_reports_screen.dart';
import 'package:aflalert/screens/settings_screen.dart';
import 'package:aflalert/screens/result_screen.dart';
import 'package:aflalert/services/local_notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await LocalNotificationService.instance.init();

  runApp(const AflAlert());
}

class AflAlert extends StatefulWidget {
  const AflAlert({super.key});

  static void setLocale(BuildContext context, Locale locale) {
    context.findAncestorStateOfType<_AflAlertState>()?.setLocale(locale);
  }

  @override
  State<AflAlert> createState() => _AflAlertState();
}

class _AflAlertState extends State<AflAlert> {
  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('en');

  @override
  void initState() {
    super.initState();
    _loadTheme();
    _loadLocale();
  }
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _themeMode = (prefs.getBool('darkModeEnabled') ?? false)
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String languageCode = prefs.getString('languageCode') ?? 'en';
    setState(() => _locale = Locale(languageCode));
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        _MaterialLocalizationsLgDelegate(),
        _CupertinoLocalizationsLgDelegate(),
        _WidgetsLocalizationsLgDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,

  
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
            disabledBackgroundColor: const Color(0xFF00462D).withValues(alpha: 0.4),
            minimumSize: const Size(double.infinity, 56),
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
            borderSide: const BorderSide(
              color: Color(0xFFD1D5DB),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFD1D5DB),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF00462D),
              width: 2,
            ),
          ),
        ),
      ),
       darkTheme: ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF00462D),
      brightness: Brightness.dark,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(
      ThemeData.dark().textTheme,
    ),
  ),


      // First screen shown when the app starts (serves as '/')
      home: const SplashScreen(),

      routes: {
        '/welcome': (context) {
          debugPrint('ROUTE_TRACE: building /welcome');
          return const OnboardingScreen();
        },

        '/login': (context) => const LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/analysis': (context) => const AnalysisScreen(),
        '/results': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as ResultsScreenArgs;
          return ResultsScreen(
            isSafe: args.isSafe,
            confidence: args.confidence,
            analysisLabel: args.analysisLabel,
            imagePath: args.imagePath,
          );
        },
        '/register': (context) => const RegistrationScreen(),
        '/downloadedReports': (context) => const DownloadedReportsScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/camera': (context) {
          debugPrint('ROUTE_TRACE: building /camera');
          return CameraCaptureScreen();
        },
      },
    );
  }
}

// Flutter's built-in Material/Cupertino/Widgets localizations don't ship
// Luganda translations, so without these, switching to 'lg' leaves
// MaterialLocalizations.of(context) null and crashes every AppBar/Scaffold.
// These delegates claim support for 'lg' and just borrow the English
// framework strings (Back button tooltips, etc.) — only AppLocalizations
// (our own arb-generated strings) actually renders in Luganda.
class _MaterialLocalizationsLgDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const _MaterialLocalizationsLgDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'lg';

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      GlobalMaterialLocalizations.delegate.load(const Locale('en'));

  @override
  bool shouldReload(_MaterialLocalizationsLgDelegate old) => false;
}

class _CupertinoLocalizationsLgDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const _CupertinoLocalizationsLgDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'lg';

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      GlobalCupertinoLocalizations.delegate.load(const Locale('en'));

  @override
  bool shouldReload(_CupertinoLocalizationsLgDelegate old) => false;
}

class _WidgetsLocalizationsLgDelegate extends LocalizationsDelegate<WidgetsLocalizations> {
  const _WidgetsLocalizationsLgDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'lg';

  @override
  Future<WidgetsLocalizations> load(Locale locale) =>
      GlobalWidgetsLocalizations.delegate.load(const Locale('en'));

  @override
  bool shouldReload(_WidgetsLocalizationsLgDelegate old) => false;
}