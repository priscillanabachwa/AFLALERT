import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_lg.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('lg'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'AflAlert'**
  String get appName;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @aiScan.
  ///
  /// In en, this message translates to:
  /// **'AI SCAN'**
  String get aiScan;

  /// No description provided for @tapToScan.
  ///
  /// In en, this message translates to:
  /// **'Tap to scan crops'**
  String get tapToScan;

  /// No description provided for @recentScans.
  ///
  /// In en, this message translates to:
  /// **'Recent Scans'**
  String get recentScans;

  /// No description provided for @healthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get healthy;

  /// No description provided for @moldDetected.
  ///
  /// In en, this message translates to:
  /// **'Mold Detected'**
  String get moldDetected;

  /// No description provided for @highRisk.
  ///
  /// In en, this message translates to:
  /// **'HIGH RISK'**
  String get highRisk;

  /// No description provided for @veryLow.
  ///
  /// In en, this message translates to:
  /// **'Very Low'**
  String get veryLow;

  /// No description provided for @confidenceScore.
  ///
  /// In en, this message translates to:
  /// **'Confidence Score'**
  String get confidenceScore;

  /// No description provided for @riskLevel.
  ///
  /// In en, this message translates to:
  /// **'Risk Level'**
  String get riskLevel;

  /// No description provided for @recommendations.
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get recommendations;

  /// No description provided for @saveReport.
  ///
  /// In en, this message translates to:
  /// **'Save Report'**
  String get saveReport;

  /// No description provided for @scanAgain.
  ///
  /// In en, this message translates to:
  /// **'Scan Again'**
  String get scanAgain;

  /// No description provided for @exportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get exportPdf;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout from AflAlert?'**
  String get logoutConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @deleteScan.
  ///
  /// In en, this message translates to:
  /// **'Delete Scan'**
  String get deleteScan;

  /// No description provided for @deleteScanConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this scan record? This cannot be undone.'**
  String get deleteScanConfirm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @scanDeleted.
  ///
  /// In en, this message translates to:
  /// **'Scan deleted.'**
  String get scanDeleted;

  /// No description provided for @couldNotDeleteScan.
  ///
  /// In en, this message translates to:
  /// **'Could not delete scan. Please try again.'**
  String get couldNotDeleteScan;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @selectScans.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get selectScans;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// No description provided for @deselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect All'**
  String get deselectAll;

  /// No description provided for @scansSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String scansSelectedCount(int count);

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @deleteSelectedScans.
  ///
  /// In en, this message translates to:
  /// **'Delete Scans'**
  String get deleteSelectedScans;

  /// No description provided for @deleteSelectedScansConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {count} scan records? This cannot be undone.'**
  String deleteSelectedScansConfirm(int count);

  /// No description provided for @scansDeletedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} scans deleted.'**
  String scansDeletedCount(int count);

  /// No description provided for @scanDetails.
  ///
  /// In en, this message translates to:
  /// **'Maize Scan Details'**
  String get scanDetails;

  /// No description provided for @totalScans.
  ///
  /// In en, this message translates to:
  /// **'Total Scans'**
  String get totalScans;

  /// No description provided for @healthyScans.
  ///
  /// In en, this message translates to:
  /// **'Healthy Scans'**
  String get healthyScans;

  /// No description provided for @detectedScans.
  ///
  /// In en, this message translates to:
  /// **'Detected Scans'**
  String get detectedScans;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @searchCrop.
  ///
  /// In en, this message translates to:
  /// **'Search by crop, location...'**
  String get searchCrop;

  /// No description provided for @analysingImage.
  ///
  /// In en, this message translates to:
  /// **'Analysing your sample...'**
  String get analysingImage;

  /// No description provided for @placeMaize.
  ///
  /// In en, this message translates to:
  /// **'Place maize inside the frame'**
  String get placeMaize;

  /// No description provided for @safeStorage.
  ///
  /// In en, this message translates to:
  /// **'Safe for storage and immediate human consumption'**
  String get safeStorage;

  /// No description provided for @shareReport.
  ///
  /// In en, this message translates to:
  /// **'Share Report'**
  String get shareReport;

  /// No description provided for @downloadPdf.
  ///
  /// In en, this message translates to:
  /// **'Download PDF'**
  String get downloadPdf;

  /// No description provided for @whatIsAflatoxin.
  ///
  /// In en, this message translates to:
  /// **'What is Aflatoxin?'**
  String get whatIsAflatoxin;

  /// No description provided for @healthRisks.
  ///
  /// In en, this message translates to:
  /// **'Health Risks of Exposure'**
  String get healthRisks;

  /// No description provided for @storageGuide.
  ///
  /// In en, this message translates to:
  /// **'Safe Storage Practices'**
  String get storageGuide;

  /// No description provided for @seekHelp.
  ///
  /// In en, this message translates to:
  /// **'When to Seek Medical Help'**
  String get seekHelp;

  /// No description provided for @englishLanguageName.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishLanguageName;

  /// No description provided for @lugandaLanguageName.
  ///
  /// In en, this message translates to:
  /// **'Luganda'**
  String get lugandaLanguageName;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @onboardTitle1.
  ///
  /// In en, this message translates to:
  /// **'Protect Your Harvest'**
  String get onboardTitle1;

  /// No description provided for @onboardDesc1.
  ///
  /// In en, this message translates to:
  /// **'Detect aflatoxin risks in maize using AI-powered image analysis.'**
  String get onboardDesc1;

  /// No description provided for @onboardTitle2.
  ///
  /// In en, this message translates to:
  /// **'Instant Results'**
  String get onboardTitle2;

  /// No description provided for @onboardDesc2.
  ///
  /// In en, this message translates to:
  /// **'Scan maize samples and receive fast, reliable assessments.'**
  String get onboardDesc2;

  /// No description provided for @onboardTitle3.
  ///
  /// In en, this message translates to:
  /// **'Stay Safe & Informed'**
  String get onboardTitle3;

  /// No description provided for @onboardDesc3.
  ///
  /// In en, this message translates to:
  /// **'Get recommendations and improve food safety for your harvest.'**
  String get onboardDesc3;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'AI Powered Aflatoxin Detection'**
  String get splashTagline;

  /// No description provided for @splashMotto.
  ///
  /// In en, this message translates to:
  /// **'VIGILANT • INTELLIGENT • NURTURING'**
  String get splashMotto;

  /// No description provided for @loginTagline.
  ///
  /// In en, this message translates to:
  /// **'Precision diagnostics for a safer harvest.'**
  String get loginTagline;

  /// No description provided for @savedAccounts.
  ///
  /// In en, this message translates to:
  /// **'Saved accounts'**
  String get savedAccounts;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'example@gmail.com'**
  String get emailHint;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'••••••••'**
  String get passwordHint;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'OR CONTINUE WITH'**
  String get orContinueWith;

  /// No description provided for @googleButton.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get googleButton;

  /// No description provided for @newToAflalert.
  ///
  /// In en, this message translates to:
  /// **'New to AflAlert? '**
  String get newToAflalert;

  /// No description provided for @registerHere.
  ///
  /// In en, this message translates to:
  /// **'Register here'**
  String get registerHere;

  /// No description provided for @pleaseAgreeToTerms.
  ///
  /// In en, this message translates to:
  /// **'Please agree to the Terms of Service'**
  String get pleaseAgreeToTerms;

  /// No description provided for @accountCreatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Account Created'**
  String get accountCreatedTitle;

  /// No description provided for @accountCreatedBody.
  ///
  /// In en, this message translates to:
  /// **'Your AflAlert account was created with {email}.'**
  String accountCreatedBody(String email);

  /// No description provided for @registrationSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Registration successful!'**
  String get registrationSuccessful;

  /// No description provided for @join.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join;

  /// No description provided for @registerTagline.
  ///
  /// In en, this message translates to:
  /// **'Empowering agriculture with intelligent analysis.'**
  String get registerTagline;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'John Doe'**
  String get fullNameHint;

  /// No description provided for @pleaseEnterFullName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get pleaseEnterFullName;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'+256 700 000 000'**
  String get phoneHint;

  /// No description provided for @pleaseEnterPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get pleaseEnterPhone;

  /// No description provided for @pleaseEnterValidPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get pleaseEnterValidPhone;

  /// No description provided for @userType.
  ///
  /// In en, this message translates to:
  /// **'User Type'**
  String get userType;

  /// No description provided for @selectYourRole.
  ///
  /// In en, this message translates to:
  /// **'Select your role'**
  String get selectYourRole;

  /// No description provided for @farmer.
  ///
  /// In en, this message translates to:
  /// **'Farmer'**
  String get farmer;

  /// No description provided for @trader.
  ///
  /// In en, this message translates to:
  /// **'Trader'**
  String get trader;

  /// No description provided for @pleaseSelectUserType.
  ///
  /// In en, this message translates to:
  /// **'Please select a user type'**
  String get pleaseSelectUserType;

  /// No description provided for @district.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get district;

  /// No description provided for @selectYourDistrict.
  ///
  /// In en, this message translates to:
  /// **'Select your district'**
  String get selectYourDistrict;

  /// No description provided for @pleaseSelectDistrict.
  ///
  /// In en, this message translates to:
  /// **'Please select a district'**
  String get pleaseSelectDistrict;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMinLength;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @pleaseConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @agreeToOurPrefix.
  ///
  /// In en, this message translates to:
  /// **'By signing up, you agree to our '**
  String get agreeToOurPrefix;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @andWord.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get andWord;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @loginHere.
  ///
  /// In en, this message translates to:
  /// **'Login here'**
  String get loginHere;

  /// No description provided for @heatAlertTitle.
  ///
  /// In en, this message translates to:
  /// **'Heat Alert'**
  String get heatAlertTitle;

  /// No description provided for @heatAlertNotifTitle.
  ///
  /// In en, this message translates to:
  /// **'Heat Alert — {temp}°C'**
  String heatAlertNotifTitle(int temp);

  /// No description provided for @humidityAlertNotifTitle.
  ///
  /// In en, this message translates to:
  /// **'Humidity is at {humidity}%'**
  String humidityAlertNotifTitle(int humidity);

  /// No description provided for @guidelines.
  ///
  /// In en, this message translates to:
  /// **'Guidelines'**
  String get guidelines;

  /// No description provided for @homeSubGreeting.
  ///
  /// In en, this message translates to:
  /// **'Ready to secure your harvest today?'**
  String get homeSubGreeting;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// No description provided for @goodNight.
  ///
  /// In en, this message translates to:
  /// **'Good Night'**
  String get goodNight;

  /// No description provided for @defaultGreetingName.
  ///
  /// In en, this message translates to:
  /// **'there'**
  String get defaultGreetingName;

  /// No description provided for @locating.
  ///
  /// In en, this message translates to:
  /// **'LOCATING...'**
  String get locating;

  /// No description provided for @locationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'LOCATION UNAVAILABLE'**
  String get locationUnavailable;

  /// No description provided for @fetchingWeather.
  ///
  /// In en, this message translates to:
  /// **'Fetching weather...'**
  String get fetchingWeather;

  /// No description provided for @unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailable;

  /// No description provided for @heatAlertBadge.
  ///
  /// In en, this message translates to:
  /// **'HEAT ALERT'**
  String get heatAlertBadge;

  /// No description provided for @humidityAlertBadge.
  ///
  /// In en, this message translates to:
  /// **'HUMIDITY ALERT'**
  String get humidityAlertBadge;

  /// No description provided for @dailyTip.
  ///
  /// In en, this message translates to:
  /// **'DAILY TIP'**
  String get dailyTip;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @noScansYetHome.
  ///
  /// In en, this message translates to:
  /// **'No scans yet — tap \"AI Scan\" above to check your first batch.'**
  String get noScansYetHome;

  /// No description provided for @healthyCaps.
  ///
  /// In en, this message translates to:
  /// **'HEALTHY'**
  String get healthyCaps;

  /// No description provided for @riskyCaps.
  ///
  /// In en, this message translates to:
  /// **'RISKY'**
  String get riskyCaps;

  /// No description provided for @lastScanCaps.
  ///
  /// In en, this message translates to:
  /// **'LAST SCAN'**
  String get lastScanCaps;

  /// No description provided for @atRiskBadge.
  ///
  /// In en, this message translates to:
  /// **'AT RISK'**
  String get atRiskBadge;

  /// No description provided for @safeBadge.
  ///
  /// In en, this message translates to:
  /// **'SAFE'**
  String get safeBadge;

  /// No description provided for @matchPercentLabel.
  ///
  /// In en, this message translates to:
  /// **'{percent}% Match'**
  String matchPercentLabel(int percent);

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} min ago'**
  String minAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String hoursAgo(int count);

  /// No description provided for @yesterdayAt.
  ///
  /// In en, this message translates to:
  /// **'Yesterday, {time}'**
  String yesterdayAt(String time);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String daysAgo(int count);

  /// No description provided for @couldNotAnalyzePhoto.
  ///
  /// In en, this message translates to:
  /// **'Could not analyze this photo. Please try again.'**
  String get couldNotAnalyzePhoto;

  /// No description provided for @notMaizeColorMismatch.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t recognize this as raw maize. This can happen if the maize is roasted or cooked, if the photo isn\'t of maize at all, or if the lighting made the colors hard to read. Please retake a clear photo of raw maize kernels in good light.'**
  String get notMaizeColorMismatch;

  /// No description provided for @notMaizeModelRejected.
  ///
  /// In en, this message translates to:
  /// **'Our AI doesn\'t recognize this as maize kernels. If this is roasted or cooked maize, we can only assess raw kernels — please retake a photo of raw, unprocessed maize.'**
  String get notMaizeModelRejected;

  /// No description provided for @notMaizeLowConfidence.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t get a clear enough reading from this photo. Try retaking in brighter, even lighting and hold the camera steady.'**
  String get notMaizeLowConfidence;

  /// No description provided for @analyzingImageTitle.
  ///
  /// In en, this message translates to:
  /// **'Analyzing Image...'**
  String get analyzingImageTitle;

  /// No description provided for @aiDetectingMold.
  ///
  /// In en, this message translates to:
  /// **'Our AI model is detecting visible mold associated with aflatoxin contamination.'**
  String get aiDetectingMold;

  /// No description provided for @analysisFailed.
  ///
  /// In en, this message translates to:
  /// **'Analysis failed'**
  String get analysisFailed;

  /// No description provided for @noScanResultFound.
  ///
  /// In en, this message translates to:
  /// **'No scan result found'**
  String get noScanResultFound;

  /// No description provided for @scanMaizeSampleHint.
  ///
  /// In en, this message translates to:
  /// **'Scan a maize sample to see its diagnosis here.'**
  String get scanMaizeSampleHint;

  /// No description provided for @scanASample.
  ///
  /// In en, this message translates to:
  /// **'Scan a sample'**
  String get scanASample;

  /// No description provided for @couldNotCapturePhoto.
  ///
  /// In en, this message translates to:
  /// **'Could not capture photo: {error}'**
  String couldNotCapturePhoto(String error);

  /// No description provided for @scanMaize.
  ///
  /// In en, this message translates to:
  /// **'Scan Kernels'**
  String get scanMaize;

  /// No description provided for @flashOn.
  ///
  /// In en, this message translates to:
  /// **'Flash on'**
  String get flashOn;

  /// No description provided for @flashOff.
  ///
  /// In en, this message translates to:
  /// **'Flash off'**
  String get flashOff;

  /// No description provided for @lightingGood.
  ///
  /// In en, this message translates to:
  /// **'Lighting good'**
  String get lightingGood;

  /// No description provided for @tooDark.
  ///
  /// In en, this message translates to:
  /// **'Too dark'**
  String get tooDark;

  /// No description provided for @adjustingFocus.
  ///
  /// In en, this message translates to:
  /// **'Adjusting focus'**
  String get adjustingFocus;

  /// No description provided for @focusSharp.
  ///
  /// In en, this message translates to:
  /// **'Focus sharp'**
  String get focusSharp;

  /// No description provided for @blurryHoldSteady.
  ///
  /// In en, this message translates to:
  /// **'Blurry, hold steady'**
  String get blurryHoldSteady;

  /// No description provided for @moveToBrighterArea.
  ///
  /// In en, this message translates to:
  /// **'Move to a brighter, well-lit area'**
  String get moveToBrighterArea;

  /// No description provided for @holdPhoneSteady.
  ///
  /// In en, this message translates to:
  /// **'Hold the phone steady before capturing'**
  String get holdPhoneSteady;

  /// No description provided for @holdPhone20cm.
  ///
  /// In en, this message translates to:
  /// **'Hold phone about 20cm above the sample'**
  String get holdPhone20cm;

  /// No description provided for @adjustFrameWillTurnWhite.
  ///
  /// In en, this message translates to:
  /// **'Adjust and the frame will turn white when ready'**
  String get adjustFrameWillTurnWhite;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @reviewPhoto.
  ///
  /// In en, this message translates to:
  /// **'Review photo'**
  String get reviewPhoto;

  /// No description provided for @sharpAndWellLit.
  ///
  /// In en, this message translates to:
  /// **'Sharp and well lit'**
  String get sharpAndWellLit;

  /// No description provided for @photoMayBeTooDark.
  ///
  /// In en, this message translates to:
  /// **'Photo may be too dark'**
  String get photoMayBeTooDark;

  /// No description provided for @photoMayBeBlurry.
  ///
  /// In en, this message translates to:
  /// **'Photo may be blurry'**
  String get photoMayBeBlurry;

  /// No description provided for @retake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get retake;

  /// No description provided for @usePhoto.
  ///
  /// In en, this message translates to:
  /// **'Use photo'**
  String get usePhoto;

  /// No description provided for @aflatoxinDetector.
  ///
  /// In en, this message translates to:
  /// **'Aflatoxin Detector'**
  String get aflatoxinDetector;

  /// No description provided for @healthyMaize.
  ///
  /// In en, this message translates to:
  /// **'Healthy Maize'**
  String get healthyMaize;

  /// No description provided for @unsafeForConsumption.
  ///
  /// In en, this message translates to:
  /// **'Unsafe for Human Consumption'**
  String get unsafeForConsumption;

  /// No description provided for @diagnosisCompletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis completed successfully'**
  String get diagnosisCompletedSuccessfully;

  /// No description provided for @analysisFlaggedForReview.
  ///
  /// In en, this message translates to:
  /// **'Analysis flagged this sample for review'**
  String get analysisFlaggedForReview;

  /// No description provided for @generatingPdfReport.
  ///
  /// In en, this message translates to:
  /// **'Generating PDF report...'**
  String get generatingPdfReport;

  /// No description provided for @couldNotSavePdfReport.
  ///
  /// In en, this message translates to:
  /// **'Could not save PDF report'**
  String get couldNotSavePdfReport;

  /// No description provided for @recommendationsAndDirectives.
  ///
  /// In en, this message translates to:
  /// **'Recommendations & Directives'**
  String get recommendationsAndDirectives;

  /// No description provided for @confidencePercentLabel.
  ///
  /// In en, this message translates to:
  /// **'{percent}% confidence'**
  String confidencePercentLabel(int percent);

  /// No description provided for @scanAnotherBatch.
  ///
  /// In en, this message translates to:
  /// **'Scan Another Batch'**
  String get scanAnotherBatch;

  /// No description provided for @allFilter.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allFilter;

  /// No description provided for @locationFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationFilterLabel;

  /// No description provided for @showingResultsCount.
  ///
  /// In en, this message translates to:
  /// **'Showing {count} results'**
  String showingResultsCount(int count);

  /// No description provided for @forCurrentFilters.
  ///
  /// In en, this message translates to:
  /// **' for current filters'**
  String get forCurrentFilters;

  /// No description provided for @clearAllFiltersX.
  ///
  /// In en, this message translates to:
  /// **'Clear all filters ×'**
  String get clearAllFiltersX;

  /// No description provided for @noScansFound.
  ///
  /// In en, this message translates to:
  /// **'No scans found'**
  String get noScansFound;

  /// No description provided for @tryAdjustingFilters.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters\nor scan a new maize sample.'**
  String get tryAdjustingFilters;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @couldNotLoadScanHistory.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load scan history'**
  String get couldNotLoadScanHistory;

  /// No description provided for @checkConnectionTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get checkConnectionTryAgain;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location: {location}'**
  String locationLabel(String location);

  /// No description provided for @notRecorded.
  ///
  /// In en, this message translates to:
  /// **'Not recorded'**
  String get notRecorded;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String dateLabel(String date);

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String statusLabel(String status);

  /// No description provided for @matchConfidenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Match confidence: {percent}%'**
  String matchConfidenceLabel(int percent);

  /// No description provided for @couldNotGeneratePdfReport.
  ///
  /// In en, this message translates to:
  /// **'Could not generate PDF report'**
  String get couldNotGeneratePdfReport;

  /// No description provided for @filterByLocation.
  ///
  /// In en, this message translates to:
  /// **'Filter by Location'**
  String get filterByLocation;

  /// No description provided for @allLocations.
  ///
  /// In en, this message translates to:
  /// **'All Locations'**
  String get allLocations;

  /// No description provided for @scanHistoryExportLabel.
  ///
  /// In en, this message translates to:
  /// **'Scan history export ({count} scans, {healthy} healthy)'**
  String scanHistoryExportLabel(int count, int healthy);

  /// No description provided for @alertsFilter.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alertsFilter;

  /// No description provided for @updatesFilter.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get updatesFilter;

  /// No description provided for @allCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get allCaughtUp;

  /// No description provided for @noAlertsMessage.
  ///
  /// In en, this message translates to:
  /// **'No alerts right now'**
  String get noAlertsMessage;

  /// No description provided for @noUpdatesMessage.
  ///
  /// In en, this message translates to:
  /// **'No updates yet'**
  String get noUpdatesMessage;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @takeAPhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takeAPhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @cameraAccessDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera access was denied. Enable it in Settings to take a photo.'**
  String get cameraAccessDenied;

  /// No description provided for @photoLibraryAccessDenied.
  ///
  /// In en, this message translates to:
  /// **'Photo library access was denied. Enable it in Settings to choose a photo.'**
  String get photoLibraryAccessDenied;

  /// No description provided for @fullNameCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Full name cannot be empty'**
  String get fullNameCannotBeEmpty;

  /// No description provided for @couldNotUploadProfilePicture.
  ///
  /// In en, this message translates to:
  /// **'Could not upload profile picture. Please try again.'**
  String get couldNotUploadProfilePicture;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @couldNotUpdateProfile.
  ///
  /// In en, this message translates to:
  /// **'Could not update profile. Please try again.'**
  String get couldNotUpdateProfile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @locationField.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationField;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordTitle;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @enterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password'**
  String get enterCurrentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @passwordMin6Chars.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMin6Chars;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePassword;

  /// No description provided for @passwordChangedTitle.
  ///
  /// In en, this message translates to:
  /// **'Password Changed'**
  String get passwordChangedTitle;

  /// No description provided for @passwordChangedBody.
  ///
  /// In en, this message translates to:
  /// **'Your account password was changed successfully.'**
  String get passwordChangedBody;

  /// No description provided for @passwordUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully'**
  String get passwordUpdatedSuccessfully;

  /// No description provided for @couldNotChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Could not change password. Please try again.'**
  String get couldNotChangePassword;

  /// No description provided for @currentPasswordIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Current password is incorrect.'**
  String get currentPasswordIncorrect;

  /// No description provided for @newPasswordTooWeak.
  ///
  /// In en, this message translates to:
  /// **'New password is too weak.'**
  String get newPasswordTooWeak;

  /// No description provided for @pleaseLogOutAndBackIn.
  ///
  /// In en, this message translates to:
  /// **'Please log out and log back in, then try again.'**
  String get pleaseLogOutAndBackIn;

  /// No description provided for @errorOccurredTryAgain.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get errorOccurredTryAgain;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @resetPasswordInstructions.
  ///
  /// In en, this message translates to:
  /// **'Enter your registered email address below. We will send you a 6-digit code to reset your password and keep your account secure.'**
  String get resetPasswordInstructions;

  /// No description provided for @pleaseEnterValidEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get pleaseEnterValidEmailAddress;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get sendResetLink;

  /// No description provided for @otpScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter Code'**
  String get otpScreenTitle;

  /// No description provided for @otpInstructions.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code we sent to {email}.'**
  String otpInstructions(String email);

  /// No description provided for @otpLabel.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get otpLabel;

  /// No description provided for @pleaseEnterOtp.
  ///
  /// In en, this message translates to:
  /// **'Please enter the code'**
  String get pleaseEnterOtp;

  /// No description provided for @otpInvalidLength.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code'**
  String get otpInvalidLength;

  /// No description provided for @verifyAndReset.
  ///
  /// In en, this message translates to:
  /// **'Verify & Reset Password'**
  String get verifyAndReset;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendCode;

  /// No description provided for @resendCodeIn.
  ///
  /// In en, this message translates to:
  /// **'Resend code in {seconds}s'**
  String resendCodeIn(int seconds);

  /// No description provided for @pleaseWaitBeforeResend.
  ///
  /// In en, this message translates to:
  /// **'Please wait before requesting another code.'**
  String get pleaseWaitBeforeResend;

  /// No description provided for @codeExpired.
  ///
  /// In en, this message translates to:
  /// **'This code has expired. Please request a new one.'**
  String get codeExpired;

  /// No description provided for @tooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many incorrect attempts. Please request a new code.'**
  String get tooManyAttempts;

  /// No description provided for @incorrectCode.
  ///
  /// In en, this message translates to:
  /// **'Incorrect code. Please try again.'**
  String get incorrectCode;

  /// No description provided for @downloadedReports.
  ///
  /// In en, this message translates to:
  /// **'Downloaded Reports'**
  String get downloadedReports;

  /// No description provided for @noDownloadedReports.
  ///
  /// In en, this message translates to:
  /// **'No downloaded reports'**
  String get noDownloadedReports;

  /// No description provided for @legal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legal;

  /// No description provided for @reportSaved.
  ///
  /// In en, this message translates to:
  /// **'Report saved'**
  String get reportSaved;

  /// No description provided for @pdfSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your PDF report has been saved to this device. You can open it now or find it later in Downloaded Reports.'**
  String get pdfSavedMessage;

  /// No description provided for @viewAllReports.
  ///
  /// In en, this message translates to:
  /// **'View All Reports'**
  String get viewAllReports;

  /// No description provided for @openPdf.
  ///
  /// In en, this message translates to:
  /// **'Open PDF'**
  String get openPdf;

  /// No description provided for @processingPipeline.
  ///
  /// In en, this message translates to:
  /// **'Processing Pipeline'**
  String get processingPipeline;

  /// No description provided for @estimatedWait.
  ///
  /// In en, this message translates to:
  /// **'Estimated wait: 3–5 seconds'**
  String get estimatedWait;

  /// No description provided for @neuralEngineActive.
  ///
  /// In en, this message translates to:
  /// **'Neural Engine Active'**
  String get neuralEngineActive;

  /// No description provided for @scanningAspergillus.
  ///
  /// In en, this message translates to:
  /// **'Scanning for Aspergillus flavus patterns.'**
  String get scanningAspergillus;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @appPreferences.
  ///
  /// In en, this message translates to:
  /// **'App preferences'**
  String get appPreferences;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Alerts about scan results and batch status'**
  String get notificationsSubtitle;

  /// No description provided for @helpSupportSection.
  ///
  /// In en, this message translates to:
  /// **'Help & support'**
  String get helpSupportSection;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get contactSupport;

  /// No description provided for @couldNotOpenEmailApp.
  ///
  /// In en, this message translates to:
  /// **'Could not open email app. Please email us at aflalert.support@gmail.com'**
  String get couldNotOpenEmailApp;

  /// No description provided for @aboutAflAlert.
  ///
  /// In en, this message translates to:
  /// **'About AflAlert'**
  String get aboutAflAlert;

  /// No description provided for @recommendationsSourced.
  ///
  /// In en, this message translates to:
  /// **'Recommendations sourced from UNBS and MAAIF guidance.'**
  String get recommendationsSourced;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'AflAlert helps farmers and grain handlers spot aflatoxin risk in maize before it reaches the market. Snap a photo of maize kernels or a test strip and get an instant, AI-powered risk assessment — right on your phone, even without a lab.'**
  String get aboutDescription;

  /// No description provided for @aboutFeaturesTitle.
  ///
  /// In en, this message translates to:
  /// **'What AflAlert does'**
  String get aboutFeaturesTitle;

  /// No description provided for @aboutFeatureScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Kernel & strip scanning'**
  String get aboutFeatureScanTitle;

  /// No description provided for @aboutFeatureScanDesc.
  ///
  /// In en, this message translates to:
  /// **'AI-powered image analysis flags visible mold and aflatoxin risk in maize kernels or test strips.'**
  String get aboutFeatureScanDesc;

  /// No description provided for @aboutFeatureRecommendationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Guided recommendations'**
  String get aboutFeatureRecommendationsTitle;

  /// No description provided for @aboutFeatureRecommendationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Every result comes with next-step guidance sourced from UNBS and MAAIF standards.'**
  String get aboutFeatureRecommendationsDesc;

  /// No description provided for @aboutFeatureRainAlertsTitle.
  ///
  /// In en, this message translates to:
  /// **'Rain alerts'**
  String get aboutFeatureRainAlertsTitle;

  /// No description provided for @aboutFeatureRainAlertsDesc.
  ///
  /// In en, this message translates to:
  /// **'Get warned before rain hits so drying grain can be covered in time, reducing mold and aflatoxin risk.'**
  String get aboutFeatureRainAlertsDesc;

  /// No description provided for @aboutFeatureVoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice assistant'**
  String get aboutFeatureVoiceTitle;

  /// No description provided for @aboutFeatureVoiceDesc.
  ///
  /// In en, this message translates to:
  /// **'Run scans and ask questions hands-free.'**
  String get aboutFeatureVoiceDesc;

  /// No description provided for @aboutFeatureReportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan history & reports'**
  String get aboutFeatureReportsTitle;

  /// No description provided for @aboutFeatureReportsDesc.
  ///
  /// In en, this message translates to:
  /// **'Review past scans and download PDF reports to share or keep for your records.'**
  String get aboutFeatureReportsDesc;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0'**
  String get aboutVersion;

  /// No description provided for @aboutCopyright.
  ///
  /// In en, this message translates to:
  /// **'© 2026 AflAlert. All rights reserved.'**
  String get aboutCopyright;

  /// No description provided for @contactSupportScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get contactSupportScreenTitle;

  /// No description provided for @contactSupportIntro.
  ///
  /// In en, this message translates to:
  /// **'Tell us what\'s going on and we\'ll get back to you by email.'**
  String get contactSupportIntro;

  /// No description provided for @contactSupportCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'What\'s this about?'**
  String get contactSupportCategoryLabel;

  /// No description provided for @contactSupportCategoryBug.
  ///
  /// In en, this message translates to:
  /// **'Bug report'**
  String get contactSupportCategoryBug;

  /// No description provided for @contactSupportCategoryScan.
  ///
  /// In en, this message translates to:
  /// **'Scan or result issue'**
  String get contactSupportCategoryScan;

  /// No description provided for @contactSupportCategoryAccount.
  ///
  /// In en, this message translates to:
  /// **'Account issue'**
  String get contactSupportCategoryAccount;

  /// No description provided for @contactSupportCategoryFeedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get contactSupportCategoryFeedback;

  /// No description provided for @contactSupportCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get contactSupportCategoryOther;

  /// No description provided for @contactSupportEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Your email'**
  String get contactSupportEmailLabel;

  /// No description provided for @contactSupportEmailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get contactSupportEmailHint;

  /// No description provided for @contactSupportEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter an email so we can reply'**
  String get contactSupportEmailRequired;

  /// No description provided for @contactSupportEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get contactSupportEmailInvalid;

  /// No description provided for @contactSupportMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get contactSupportMessageLabel;

  /// No description provided for @contactSupportMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the issue or share your feedback...'**
  String get contactSupportMessageHint;

  /// No description provided for @contactSupportMessageRequired.
  ///
  /// In en, this message translates to:
  /// **'Please describe your issue before submitting'**
  String get contactSupportMessageRequired;

  /// No description provided for @contactSupportSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get contactSupportSubmit;

  /// No description provided for @contactSupportSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get contactSupportSubmitting;

  /// No description provided for @contactSupportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Thanks! Your message has been sent. We\'ll get back to you by email.'**
  String get contactSupportSuccess;

  /// No description provided for @contactSupportError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong sending your message. Please try emailing us directly.'**
  String get contactSupportError;

  /// No description provided for @contactSupportEmailDirectly.
  ///
  /// In en, this message translates to:
  /// **'For any further inquiries, reach out to us at'**
  String get contactSupportEmailDirectly;

  /// No description provided for @maizeScanLabel.
  ///
  /// In en, this message translates to:
  /// **'Maize Scan'**
  String get maizeScanLabel;

  /// No description provided for @stripScanLabel.
  ///
  /// In en, this message translates to:
  /// **'Strip Scan'**
  String get stripScanLabel;

  /// No description provided for @coachMarkSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get coachMarkSkip;

  /// No description provided for @coachMarkNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get coachMarkNext;

  /// No description provided for @coachMarkGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get coachMarkGotIt;

  /// No description provided for @coachMarkMaizeTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan your maize'**
  String get coachMarkMaizeTitle;

  /// No description provided for @coachMarkMaizeDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap here to photograph maize kernels and check for visible mold.'**
  String get coachMarkMaizeDesc;

  /// No description provided for @coachMarkStripTitle.
  ///
  /// In en, this message translates to:
  /// **'Test a chemical strip'**
  String get coachMarkStripTitle;

  /// No description provided for @coachMarkStripDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap here after the strip\'s reaction time to check aflatoxin levels.'**
  String get coachMarkStripDesc;

  /// No description provided for @coachMarkWeatherTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s weather'**
  String get coachMarkWeatherTitle;

  /// No description provided for @coachMarkWeatherDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap this card anytime to see the full hourly forecast.'**
  String get coachMarkWeatherDesc;

  /// No description provided for @coachMarkVoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Try the voice assistant'**
  String get coachMarkVoiceTitle;

  /// No description provided for @coachMarkVoiceDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap here and just talk — ask it to scan your maize, check the weather, or answer a question.'**
  String get coachMarkVoiceDesc;

  /// No description provided for @chemicalStripScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Chemical Strip Scan'**
  String get chemicalStripScanTitle;

  /// No description provided for @scanTestStrip.
  ///
  /// In en, this message translates to:
  /// **'Scan Test Strip'**
  String get scanTestStrip;

  /// No description provided for @cropTypeMaize.
  ///
  /// In en, this message translates to:
  /// **'Maize'**
  String get cropTypeMaize;

  /// No description provided for @positionStripInFrame.
  ///
  /// In en, this message translates to:
  /// **'Position strip in frame after the 10-minute reaction time'**
  String get positionStripInFrame;

  /// No description provided for @cropStripPhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Fit the strip in the frame'**
  String get cropStripPhotoTitle;

  /// No description provided for @cropStripPhotoHint.
  ///
  /// In en, this message translates to:
  /// **'Pinch to zoom and drag until the strip fills the frame edge to edge'**
  String get cropStripPhotoHint;

  /// No description provided for @scanAnotherStrip.
  ///
  /// In en, this message translates to:
  /// **'Scan Another Strip'**
  String get scanAnotherStrip;

  /// No description provided for @scanTestStripHint.
  ///
  /// In en, this message translates to:
  /// **'Scan a reacted test strip to check aflatoxin levels'**
  String get scanTestStripHint;

  /// No description provided for @analyzingStripTitle.
  ///
  /// In en, this message translates to:
  /// **'Analyzing Strip...'**
  String get analyzingStripTitle;

  /// No description provided for @readingTestControlLines.
  ///
  /// In en, this message translates to:
  /// **'Reading the test and control lines'**
  String get readingTestControlLines;

  /// No description provided for @stripNotDetectedMessage.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t detect a test strip in this photo. Make sure the whole strip is inside the frame and well lit, then try again.'**
  String get stripNotDetectedMessage;

  /// No description provided for @controlLineNotDetectedMessage.
  ///
  /// In en, this message translates to:
  /// **'Control line not detected — this test may be invalid. Repeat the test with a new strip.'**
  String get controlLineNotDetectedMessage;

  /// No description provided for @testBatchLabel.
  ///
  /// In en, this message translates to:
  /// **'TEST BATCH'**
  String get testBatchLabel;

  /// No description provided for @toxicLoadLabel.
  ///
  /// In en, this message translates to:
  /// **'TOXIC LOAD'**
  String get toxicLoadLabel;

  /// No description provided for @regulatoryScaleLabel.
  ///
  /// In en, this message translates to:
  /// **'REGULATORY SCALE'**
  String get regulatoryScaleLabel;

  /// No description provided for @actionRequiredLabel.
  ///
  /// In en, this message translates to:
  /// **'ACTION REQUIRED'**
  String get actionRequiredLabel;

  /// No description provided for @diagnosticBreakdownLabel.
  ///
  /// In en, this message translates to:
  /// **'DIAGNOSTIC BREAKDOWN'**
  String get diagnosticBreakdownLabel;

  /// No description provided for @chemicalLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Chemical level'**
  String get chemicalLevelLabel;

  /// No description provided for @testLineOdLabel.
  ///
  /// In en, this message translates to:
  /// **'Test line (T) optical density'**
  String get testLineOdLabel;

  /// No description provided for @controlLineOdLabel.
  ///
  /// In en, this message translates to:
  /// **'Control line (C) optical density'**
  String get controlLineOdLabel;

  /// No description provided for @odRatioLabel.
  ///
  /// In en, this message translates to:
  /// **'T/C ratio'**
  String get odRatioLabel;

  /// No description provided for @scanLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Scan location'**
  String get scanLocationLabel;

  /// No description provided for @withinSafeLimit.
  ///
  /// In en, this message translates to:
  /// **'Within Safe Limit'**
  String get withinSafeLimit;

  /// No description provided for @exceedsSafeLimit.
  ///
  /// In en, this message translates to:
  /// **'Exceeds Safe Limit'**
  String get exceedsSafeLimit;

  /// No description provided for @wasThisDiagnosisAccurate.
  ///
  /// In en, this message translates to:
  /// **'Was this diagnosis accurate?'**
  String get wasThisDiagnosisAccurate;

  /// No description provided for @feedbackThanks.
  ///
  /// In en, this message translates to:
  /// **'Thanks — your feedback helps improve future scans.'**
  String get feedbackThanks;

  /// No description provided for @feedbackYesTooltip.
  ///
  /// In en, this message translates to:
  /// **'Yes, accurate'**
  String get feedbackYesTooltip;

  /// No description provided for @feedbackNoTooltip.
  ///
  /// In en, this message translates to:
  /// **'No, inaccurate'**
  String get feedbackNoTooltip;

  /// No description provided for @safeLimitTick.
  ///
  /// In en, this message translates to:
  /// **'{limit} ppb limit'**
  String safeLimitTick(String limit);

  /// No description provided for @exceedsSafeLimitMessage.
  ///
  /// In en, this message translates to:
  /// **'This sample exceeds the regulatory safe limit of {limit} ppb for human food.'**
  String exceedsSafeLimitMessage(String limit);

  /// No description provided for @ppbValueLabel.
  ///
  /// In en, this message translates to:
  /// **'{value} ppb'**
  String ppbValueLabel(String value);

  /// No description provided for @chemicalLevelValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Chemical level: {value} ppb'**
  String chemicalLevelValueLabel(String value);

  /// No description provided for @todayHighLowLabel.
  ///
  /// In en, this message translates to:
  /// **'Today: H:{high}° L:{low}°'**
  String todayHighLowLabel(String high, String low);

  /// No description provided for @nowLabel.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get nowLabel;

  /// No description provided for @voiceAssistantEntryTooltip.
  ///
  /// In en, this message translates to:
  /// **'Voice assistant'**
  String get voiceAssistantEntryTooltip;

  /// No description provided for @voiceAssistantTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice Assistant'**
  String get voiceAssistantTitle;

  /// No description provided for @voiceAssistantEnglishOnlyNotice.
  ///
  /// In en, this message translates to:
  /// **'Voice commands currently work in English only.'**
  String get voiceAssistantEnglishOnlyNotice;

  /// No description provided for @voiceAssistantHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the mic and try something like \"scan this maize\" or \"what\'s the weather?\"'**
  String get voiceAssistantHint;

  /// No description provided for @voiceAssistantVoiceFemale.
  ///
  /// In en, this message translates to:
  /// **'Female voice — tap to switch to male'**
  String get voiceAssistantVoiceFemale;

  /// No description provided for @voiceAssistantVoiceMale.
  ///
  /// In en, this message translates to:
  /// **'Male voice — tap to switch to female'**
  String get voiceAssistantVoiceMale;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'lg'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'lg':
      return AppLocalizationsLg();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
