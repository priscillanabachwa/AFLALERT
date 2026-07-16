// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'AflAlert';

  @override
  String get login => 'Login';

  @override
  String get register => 'Create Account';

  @override
  String get email => 'Email Address';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get home => 'Home';

  @override
  String get history => 'History';

  @override
  String get notifications => 'Notifications';

  @override
  String get profile => 'Profile';

  @override
  String get aiScan => 'AI SCAN';

  @override
  String get tapToScan => 'Tap to scan crops';

  @override
  String get recentScans => 'Recent Scans';

  @override
  String get healthy => 'Healthy';

  @override
  String get moldDetected => 'Mold Detected';

  @override
  String get highRisk => 'HIGH RISK';

  @override
  String get veryLow => 'Very Low';

  @override
  String get confidenceScore => 'Confidence Score';

  @override
  String get riskLevel => 'Risk Level';

  @override
  String get recommendations => 'Recommendations';

  @override
  String get saveReport => 'Save Report';

  @override
  String get scanAgain => 'Scan Again';

  @override
  String get exportPdf => 'Export PDF';

  @override
  String get language => 'Language';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get privacy => 'Privacy';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirm => 'Are you sure you want to logout from AflAlert?';

  @override
  String get cancel => 'Cancel';

  @override
  String get deleteScan => 'Delete Scan';

  @override
  String get deleteScanConfirm =>
      'Are you sure you want to delete this scan record? This cannot be undone.';

  @override
  String get delete => 'Delete';

  @override
  String get scanDeleted => 'Scan deleted.';

  @override
  String get couldNotDeleteScan => 'Could not delete scan. Please try again.';

  @override
  String get undo => 'Undo';

  @override
  String get scanDetails => 'Scan Details';

  @override
  String get totalScans => 'Total Scans';

  @override
  String get healthyScans => 'Healthy Scans';

  @override
  String get detectedScans => 'Detected Scans';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get searchCrop => 'Search by crop, location...';

  @override
  String get analysingImage => 'Analysing your sample...';

  @override
  String get placeMaize => 'Place maize inside the frame';

  @override
  String get safeStorage => 'Safe for storage and immediate human consumption';

  @override
  String get shareReport => 'Share Report';

  @override
  String get downloadPdf => 'Download PDF';

  @override
  String get whatIsAflatoxin => 'What is Aflatoxin?';

  @override
  String get healthRisks => 'Health Risks of Exposure';

  @override
  String get storageGuide => 'Safe Storage Practices';

  @override
  String get seekHelp => 'When to Seek Medical Help';

  @override
  String get englishLanguageName => 'English';

  @override
  String get lugandaLanguageName => 'Luganda';

  @override
  String get close => 'Close';

  @override
  String get tryAgain => 'Try again';

  @override
  String get onboardTitle1 => 'Protect Your Harvest';

  @override
  String get onboardDesc1 =>
      'Detect aflatoxin risks in maize using AI-powered image analysis.';

  @override
  String get onboardTitle2 => 'Instant Results';

  @override
  String get onboardDesc2 =>
      'Scan maize samples and receive fast, reliable assessments.';

  @override
  String get onboardTitle3 => 'Stay Safe & Informed';

  @override
  String get onboardDesc3 =>
      'Get recommendations and improve food safety for your harvest.';

  @override
  String get skip => 'Skip';

  @override
  String get splashTagline => 'AI Powered Aflatoxin Detection';

  @override
  String get splashMotto => 'VIGILANT • INTELLIGENT • NURTURING';

  @override
  String get loginTagline => 'Precision diagnostics for a safer harvest.';

  @override
  String get savedAccounts => 'Saved accounts';

  @override
  String get emailHint => 'example@gmail.com';

  @override
  String get pleaseEnterEmail => 'Please enter your email';

  @override
  String get passwordHint => '••••••••';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get orContinueWith => 'OR CONTINUE WITH';

  @override
  String get googleButton => 'Google';

  @override
  String get newToAflalert => 'New to AflAlert? ';

  @override
  String get registerHere => 'Register here';

  @override
  String get pleaseAgreeToTerms => 'Please agree to the Terms of Service';

  @override
  String get accountCreatedTitle => 'Account Created';

  @override
  String accountCreatedBody(String email) {
    return 'Your AflAlert account was created with $email.';
  }

  @override
  String get registrationSuccessful => 'Registration successful!';

  @override
  String get join => 'Join';

  @override
  String get registerTagline =>
      'Empowering agriculture with intelligent analysis.';

  @override
  String get fullName => 'Full Name';

  @override
  String get fullNameHint => 'John Doe';

  @override
  String get pleaseEnterFullName => 'Please enter your full name';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get phoneHint => '+256 700 000 000';

  @override
  String get pleaseEnterPhone => 'Please enter your phone number';

  @override
  String get pleaseEnterValidPhone => 'Please enter a valid phone number';

  @override
  String get userType => 'User Type';

  @override
  String get selectYourRole => 'Select your role';

  @override
  String get farmer => 'Farmer';

  @override
  String get trader => 'Trader';

  @override
  String get pleaseSelectUserType => 'Please select a user type';

  @override
  String get district => 'District';

  @override
  String get selectYourDistrict => 'Select your district';

  @override
  String get pleaseSelectDistrict => 'Please select a district';

  @override
  String get passwordMinLength => 'Password must be at least 8 characters';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get pleaseConfirmPassword => 'Please confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get agreeToOurPrefix => 'By signing up, you agree to our ';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get andWord => ' and ';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get loginHere => 'Login here';

  @override
  String get heatAlertTitle => 'Heat Alert';

  @override
  String heatAlertNotifTitle(int temp) {
    return 'Heat Alert — $temp°C';
  }

  @override
  String get guidelines => 'Guidelines';

  @override
  String get homeSubGreeting => 'Ready to secure your harvest today?';

  @override
  String get goodMorning => 'Good Morning';

  @override
  String get goodAfternoon => 'Good Afternoon';

  @override
  String get goodEvening => 'Good Evening';

  @override
  String get goodNight => 'Good Night';

  @override
  String get defaultGreetingName => 'there';

  @override
  String get locating => 'LOCATING...';

  @override
  String get locationUnavailable => 'LOCATION UNAVAILABLE';

  @override
  String get fetchingWeather => 'Fetching weather...';

  @override
  String get unavailable => 'Unavailable';

  @override
  String get heatAlertBadge => 'HEAT ALERT';

  @override
  String get dailyTip => 'DAILY TIP';

  @override
  String get seeAll => 'See All';

  @override
  String get noScansYetHome =>
      'No scans yet — tap \"AI Scan\" above to check your first batch.';

  @override
  String get healthyCaps => 'HEALTHY';

  @override
  String get riskyCaps => 'RISKY';

  @override
  String get lastScanCaps => 'LAST SCAN';

  @override
  String get atRiskBadge => 'AT RISK';

  @override
  String get safeBadge => 'SAFE';

  @override
  String matchPercentLabel(int percent) {
    return '$percent% Match';
  }

  @override
  String get justNow => 'Just now';

  @override
  String minAgo(int count) {
    return '$count min ago';
  }

  @override
  String hoursAgo(int count) {
    return '${count}h ago';
  }

  @override
  String yesterdayAt(String time) {
    return 'Yesterday, $time';
  }

  @override
  String daysAgo(int count) {
    return '$count days ago';
  }

  @override
  String get couldNotAnalyzePhoto =>
      'Could not analyze this photo. Please try again.';

  @override
  String get notMaizeColorMismatch =>
      'We couldn\'t recognize this as raw maize. This can happen if the maize is roasted or cooked, if the photo isn\'t of maize at all, or if the lighting made the colors hard to read. Please retake a clear photo of raw maize kernels in good light.';

  @override
  String get notMaizeModelRejected =>
      'Our AI doesn\'t recognize this as maize kernels. If this is roasted or cooked maize, we can only assess raw kernels — please retake a photo of raw, unprocessed maize.';

  @override
  String get notMaizeLowConfidence =>
      'We couldn\'t get a clear enough reading from this photo. Try retaking in brighter, even lighting and hold the camera steady.';

  @override
  String get analyzingImageTitle => 'Analyzing Image...';

  @override
  String get aiDetectingMold =>
      'Our AI model is detecting visible mold associated with aflatoxin contamination.';

  @override
  String get analysisFailed => 'Analysis failed';

  @override
  String get noScanResultFound => 'No scan result found';

  @override
  String get scanMaizeSampleHint =>
      'Scan a maize sample to see its diagnosis here.';

  @override
  String get scanASample => 'Scan a sample';

  @override
  String couldNotCapturePhoto(String error) {
    return 'Could not capture photo: $error';
  }

  @override
  String get scanMaize => 'Scan maize';

  @override
  String get flashOn => 'Flash on';

  @override
  String get flashOff => 'Flash off';

  @override
  String get lightingGood => 'Lighting good';

  @override
  String get tooDark => 'Too dark';

  @override
  String get adjustingFocus => 'Adjusting focus';

  @override
  String get focusSharp => 'Focus sharp';

  @override
  String get blurryHoldSteady => 'Blurry, hold steady';

  @override
  String get moveToBrighterArea => 'Move to a brighter, well-lit area';

  @override
  String get holdPhoneSteady => 'Hold the phone steady before capturing';

  @override
  String get holdPhone20cm => 'Hold phone about 20cm above the sample';

  @override
  String get adjustFrameWillTurnWhite =>
      'Adjust and the frame will turn white when ready';

  @override
  String get gallery => 'Gallery';

  @override
  String get reviewPhoto => 'Review photo';

  @override
  String get sharpAndWellLit => 'Sharp and well lit';

  @override
  String get photoMayBeTooDark => 'Photo may be too dark';

  @override
  String get photoMayBeBlurry => 'Photo may be blurry';

  @override
  String get retake => 'Retake';

  @override
  String get usePhoto => 'Use photo';

  @override
  String get aflatoxinDetector => 'Aflatoxin Detector';

  @override
  String get healthyMaize => 'Healthy Maize';

  @override
  String get unsafeForConsumption => 'Unsafe for Human Consumption';

  @override
  String get diagnosisCompletedSuccessfully =>
      'Diagnosis completed successfully';

  @override
  String get analysisFlaggedForReview =>
      'Analysis flagged this sample for review';

  @override
  String get generatingPdfReport => 'Generating PDF report...';

  @override
  String get couldNotSavePdfReport => 'Could not save PDF report';

  @override
  String get recommendationsAndDirectives => 'Recommendations & Directives';

  @override
  String confidencePercentLabel(int percent) {
    return '$percent% confidence';
  }

  @override
  String get scanAnotherBatch => 'Scan Another Batch';

  @override
  String get allFilter => 'All';

  @override
  String get locationFilterLabel => 'Location';

  @override
  String showingResultsCount(int count) {
    return 'Showing $count results';
  }

  @override
  String get forCurrentFilters => ' for current filters';

  @override
  String get clearAllFiltersX => 'Clear all filters ×';

  @override
  String get noScansFound => 'No scans found';

  @override
  String get tryAdjustingFilters =>
      'Try adjusting your filters\nor scan a new maize sample.';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get couldNotLoadScanHistory => 'Couldn\'t load scan history';

  @override
  String get checkConnectionTryAgain => 'Check your connection and try again.';

  @override
  String locationLabel(String location) {
    return 'Location: $location';
  }

  @override
  String get notRecorded => 'Not recorded';

  @override
  String dateLabel(String date) {
    return 'Date: $date';
  }

  @override
  String statusLabel(String status) {
    return 'Status: $status';
  }

  @override
  String matchConfidenceLabel(int percent) {
    return 'Match confidence: $percent%';
  }

  @override
  String get couldNotGeneratePdfReport => 'Could not generate PDF report';

  @override
  String get filterByLocation => 'Filter by Location';

  @override
  String get allLocations => 'All Locations';

  @override
  String scanHistoryExportLabel(int count, int healthy) {
    return 'Scan history export ($count scans, $healthy healthy)';
  }

  @override
  String get alertsFilter => 'Alerts';

  @override
  String get updatesFilter => 'Updates';

  @override
  String get allCaughtUp => 'You\'re all caught up';

  @override
  String get changePassword => 'Change password';

  @override
  String get takeAPhoto => 'Take a photo';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get cameraAccessDenied =>
      'Camera access was denied. Enable it in Settings to take a photo.';

  @override
  String get photoLibraryAccessDenied =>
      'Photo library access was denied. Enable it in Settings to choose a photo.';

  @override
  String get fullNameCannotBeEmpty => 'Full name cannot be empty';

  @override
  String get couldNotUploadProfilePicture =>
      'Could not upload profile picture. Please try again.';

  @override
  String get profileUpdatedSuccessfully => 'Profile updated successfully';

  @override
  String get couldNotUpdateProfile =>
      'Could not update profile. Please try again.';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get locationField => 'Location';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get changePasswordTitle => 'Change Password';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get enterCurrentPassword => 'Enter your current password';

  @override
  String get newPassword => 'New Password';

  @override
  String get passwordMin6Chars => 'Password must be at least 6 characters';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get updatePassword => 'Update Password';

  @override
  String get passwordChangedTitle => 'Password Changed';

  @override
  String get passwordChangedBody =>
      'Your account password was changed successfully.';

  @override
  String get passwordUpdatedSuccessfully => 'Password updated successfully';

  @override
  String get couldNotChangePassword =>
      'Could not change password. Please try again.';

  @override
  String get currentPasswordIncorrect => 'Current password is incorrect.';

  @override
  String get newPasswordTooWeak => 'New password is too weak.';

  @override
  String get pleaseLogOutAndBackIn =>
      'Please log out and log back in, then try again.';

  @override
  String get errorOccurredTryAgain => 'An error occurred. Please try again.';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get resetPasswordInstructions =>
      'Enter your registered email address below. We will send you a 6-digit code to reset your password and keep your account secure.';

  @override
  String get pleaseEnterValidEmailAddress =>
      'Please enter a valid email address';

  @override
  String get sendResetLink => 'Send Code';

  @override
  String get otpScreenTitle => 'Enter Code';

  @override
  String otpInstructions(String email) {
    return 'Enter the 6-digit code we sent to $email.';
  }

  @override
  String get otpLabel => 'Verification Code';

  @override
  String get pleaseEnterOtp => 'Please enter the code';

  @override
  String get otpInvalidLength => 'Enter the 6-digit code';

  @override
  String get verifyAndReset => 'Verify & Reset Password';

  @override
  String get resendCode => 'Resend Code';

  @override
  String resendCodeIn(int seconds) {
    return 'Resend code in ${seconds}s';
  }

  @override
  String get pleaseWaitBeforeResend =>
      'Please wait before requesting another code.';

  @override
  String get codeExpired => 'This code has expired. Please request a new one.';

  @override
  String get tooManyAttempts =>
      'Too many incorrect attempts. Please request a new code.';

  @override
  String get incorrectCode => 'Incorrect code. Please try again.';

  @override
  String get downloadedReports => 'Downloaded Reports';

  @override
  String get noDownloadedReports => 'No downloaded reports';

  @override
  String get legal => 'Legal';

  @override
  String get reportSaved => 'Report saved';

  @override
  String get pdfSavedMessage =>
      'Your PDF report has been saved to this device. You can open it now or find it later in Downloaded Reports.';

  @override
  String get viewAllReports => 'View All Reports';

  @override
  String get openPdf => 'Open PDF';

  @override
  String get processingPipeline => 'Processing Pipeline';

  @override
  String get estimatedWait => 'Estimated wait: 3–5 seconds';

  @override
  String get neuralEngineActive => 'Neural Engine Active';

  @override
  String get scanningAspergillus => 'Scanning for Aspergillus flavus patterns.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get appPreferences => 'App preferences';

  @override
  String get notificationsSubtitle =>
      'Alerts about scan results and batch status';

  @override
  String get helpSupportSection => 'Help & support';

  @override
  String get contactSupport => 'Contact support';

  @override
  String get aboutAflAlert => 'About AflAlert';

  @override
  String get recommendationsSourced =>
      'Recommendations sourced from UNBS and MAAIF guidance.';

  @override
  String get startNewTest => 'Start a New Test';

  @override
  String get tier1Title => 'Tier 1 · Visual AI Scan';

  @override
  String get tier1Subtitle => 'Check loose maize or groundnuts for mold';

  @override
  String get tier2Title => 'Tier 2 · Chemical Strip Scan';

  @override
  String get tier2Subtitle => 'Read a test strip for an exact ppb level';

  @override
  String get chemicalStripScanTitle => 'Chemical Strip Scan';

  @override
  String get scanTestStrip => 'Scan Test Strip';

  @override
  String get cropTypeMaize => 'Maize';

  @override
  String get cropTypeGroundnut => 'Groundnut';

  @override
  String get positionStripInFrame =>
      'Position strip in frame after the 10-minute reaction time';

  @override
  String get scanAnotherStrip => 'Scan Another Strip';

  @override
  String get scanTestStripHint =>
      'Scan a reacted test strip to check aflatoxin levels';

  @override
  String get analyzingStripTitle => 'Analyzing Strip...';

  @override
  String get readingTestControlLines => 'Reading the test and control lines';

  @override
  String get stripNotDetectedMessage =>
      'Couldn\'t detect a test strip in this photo. Make sure the whole strip is inside the frame and well lit, then try again.';

  @override
  String get controlLineNotDetectedMessage =>
      'Control line not detected — this test may be invalid. Repeat the test with a new strip.';

  @override
  String get testBatchLabel => 'TEST BATCH';

  @override
  String get toxicLoadLabel => 'TOXIC LOAD';

  @override
  String get regulatoryScaleLabel => 'REGULATORY SCALE';

  @override
  String get actionRequiredLabel => 'ACTION REQUIRED';

  @override
  String get diagnosticBreakdownLabel => 'DIAGNOSTIC BREAKDOWN';

  @override
  String get chemicalLevelLabel => 'Chemical level';

  @override
  String get testLineOdLabel => 'Test line (T) optical density';

  @override
  String get controlLineOdLabel => 'Control line (C) optical density';

  @override
  String get odRatioLabel => 'T/C ratio';

  @override
  String get scanLocationLabel => 'Scan location';

  @override
  String get withinSafeLimit => 'Within Safe Limit';

  @override
  String get exceedsSafeLimit => 'Exceeds Safe Limit';

  @override
  String safeLimitTick(String limit) {
    return '$limit ppb limit';
  }

  @override
  String exceedsSafeLimitMessage(String limit) {
    return 'This sample exceeds the regulatory safe limit of $limit ppb for human food.';
  }

  @override
  String ppbValueLabel(String value) {
    return '$value ppb';
  }

  @override
  String chemicalLevelValueLabel(String value) {
    return 'Chemical level: $value ppb';
  }
}
