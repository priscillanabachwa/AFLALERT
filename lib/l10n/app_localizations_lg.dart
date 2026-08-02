// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ganda Luganda (`lg`).
class AppLocalizationsLg extends AppLocalizations {
  AppLocalizationsLg([String locale = 'lg']) : super(locale);

  @override
  String get appName => 'AflAlert';

  @override
  String get login => 'Yingira';

  @override
  String get register => 'Wandiisa Akawunti';

  @override
  String get email => 'Endagiriro ya Email';

  @override
  String get password => 'Ekigambo ky\'ekyama';

  @override
  String get forgotPassword => 'Weerabidde Ekigambo ky\'ekyama?';

  @override
  String get continueWithGoogle => 'Weeyongereyo ne Google';

  @override
  String get home => 'Awaka';

  @override
  String get history => 'Ebyafaayo';

  @override
  String get notifications => 'Obubaka';

  @override
  String get profile => 'Ebinkwatako';

  @override
  String get aiScan => 'SCAN ya AI';

  @override
  String get tapToScan => 'Nyiga scan yebirime';

  @override
  String get recentScans => 'Scan Ezaakakoleddwa';

  @override
  String get healthy => 'Bilamu';

  @override
  String get moldDetected => 'Obukuku bulabiddwamu';

  @override
  String get highRisk => 'Akabi kasukirivu';

  @override
  String get veryLow => 'Akabi kakigero';

  @override
  String get confidenceScore => 'Omuwendo ogwesigibwa';

  @override
  String get riskLevel => 'Ekitundutundu ky\'Akabi';

  @override
  String get recommendations => 'Okuteesa n\'okuwabula ';

  @override
  String get saveReport => 'Tereka alipoota';

  @override
  String get scanAgain => 'Scan Neera';

  @override
  String get exportPdf => 'Fulumya PDF';

  @override
  String get language => 'Olulimi';

  @override
  String get darkMode => 'Mmoodi enzikivu';

  @override
  String get privacy => 'Eby\'ekyama';

  @override
  String get helpSupport => 'Okuyambibwa';

  @override
  String get logout => 'Okufuluma akawunti';

  @override
  String get logoutConfirm => 'Oli mukakafu nti oyagala okufuluma ku AflAlert?';

  @override
  String get cancel => 'okusazaamu';

  @override
  String get deleteScan => 'Sazaamu Scan';

  @override
  String get deleteScanConfirm =>
      'Oli mukakafu nti oyagala okusazaamu ekiwandiiko kino? Tekisobola kuddizibwa.';

  @override
  String get delete => 'Sazaamu';

  @override
  String get scanDeleted => 'Scan esaziddwamu.';

  @override
  String get couldNotDeleteScan =>
      'Tetusobodde kusazaamu scan. Ddamu ogezeeko.';

  @override
  String get undo => 'Zzaawo';

  @override
  String get selectScans => 'Londa';

  @override
  String get selectAll => 'Londa Zonna';

  @override
  String get deselectAll => 'Ggyawo Okulonda';

  @override
  String scansSelectedCount(int count) {
    return '$count zirondeddwa';
  }

  @override
  String get share => 'Gabana';

  @override
  String get deleteSelectedScans => 'Sazaamu Scan';

  @override
  String deleteSelectedScansConfirm(int count) {
    return 'Oli mukakafu nti oyagala okusazaamu ebiwandiiko $count? Tekisobola kuddizibwa.';
  }

  @override
  String scansDeletedCount(int count) {
    return 'Scan $count zisaziddwamu.';
  }

  @override
  String get scanDetails => 'Ebikwata ku Scan ya Kasooli';

  @override
  String get totalScans => 'Scan Zonna';

  @override
  String get healthyScans => 'Scan Ezirungi';

  @override
  String get detectedScans => 'Scan Ezalabika';

  @override
  String get selectLanguage => 'Londa Olulimi';

  @override
  String get searchCrop => 'Noonya nga okozesa ekirime, ekifo...';

  @override
  String get analysingImage => 'Twekenneenya ekifananyi kyekilime kyo...';

  @override
  String get placeMaize => 'Teeka kasooli mu nsengeka';

  @override
  String get safeStorage => 'Kirungi okuterekebwa era n\'okuliibwa butereevu';

  @override
  String get shareReport => 'Gabana Report';

  @override
  String get downloadPdf => 'wanula PDF';

  @override
  String get whatIsAflatoxin => 'Aflatoxin kye ki?';

  @override
  String get healthRisks => 'Obulabe ku byobulamu obuva ';

  @override
  String get storageGuide => 'Engeri entuufu ez\'okutereka';

  @override
  String get seekHelp => 'Okunoonya Obuyambi bw\'Abasawo';

  @override
  String get englishLanguageName => 'Lungereza';

  @override
  String get lugandaLanguageName => 'Luganda';

  @override
  String get close => 'Ggalawo';

  @override
  String get tryAgain => 'Gezaako nera';

  @override
  String get onboardTitle1 => 'Kuuma Amakungula Go';

  @override
  String get onboardDesc1 =>
      'Zuula obulabe bwa Aflatoxin mu kasooli nga okozesa AI okwekenneenya ebifaananyi.';

  @override
  String get onboardTitle2 => 'Ebivudde Mangu';

  @override
  String get onboardDesc2 =>
      'Scan ebyokulabirako bya kasooli olyoke ofune ebiripoota mangu era ebyesigika.';

  @override
  String get onboardTitle3 => 'Beera Mukakafu era Otegeere';

  @override
  String get onboardDesc3 =>
      'Funa ebiteesebwa era otumbule obukuumi bw\'emmere mu makungula go.';

  @override
  String get skip => 'Buuka';

  @override
  String get splashTagline => 'Okuzuula Aflatoxin nga Kozesa AI';

  @override
  String get splashMotto => 'OKWEGENDEREZA • OBUGEZI • OKULABIRIRA';

  @override
  String get loginTagline =>
      'Okwekenneenya okutuufu okulaba amakungula agali obulungi.';

  @override
  String get savedAccounts => 'Akawunti ezaterekeddwa';

  @override
  String get emailHint => 'example@gmail.com';

  @override
  String get pleaseEnterEmail => 'Yingiza email yo';

  @override
  String get passwordHint => '••••••••';

  @override
  String get pleaseEnterPassword => 'Yingiza ekigambo kyo eky\'ekyama';

  @override
  String get rememberMe => 'Onjjukire';

  @override
  String get orContinueWith => 'OYINZA N\'OKUWEYONGERAYO NE';

  @override
  String get googleButton => 'Google';

  @override
  String get newToAflalert => 'Oli mupya ku AflAlert? ';

  @override
  String get registerHere => 'Weewandiise wano';

  @override
  String get pleaseAgreeToTerms => 'Kkiriza Ebiragiro by\'Obuweereza';

  @override
  String get accountCreatedTitle => 'Akaunti Etondeddwa';

  @override
  String accountCreatedBody(String email) {
    return 'Akaunti yo eya AflAlert etondeddwa ne $email.';
  }

  @override
  String get registrationSuccessful => 'Okwewandiisa kuwedde bulungi!';

  @override
  String get join => 'Weegatte ku';

  @override
  String get registerTagline =>
      'Okutumbula eby\'obulimi n\'okwekenneenya okw\'amagezi.';

  @override
  String get fullName => 'Amannya Gonna';

  @override
  String get fullNameHint => 'John Doe';

  @override
  String get pleaseEnterFullName => 'Yingiza amannya go gonna';

  @override
  String get pleaseEnterValidEmail => 'Yingiza email entuufu';

  @override
  String get phoneNumber => 'Ennamba ya Ssimu';

  @override
  String get phoneHint => '+256 700 000 000';

  @override
  String get pleaseEnterPhone => 'Yingiza ennamba yo eya ssimu';

  @override
  String get pleaseEnterValidPhone => 'Yingiza ennamba ya ssimu entuufu';

  @override
  String get userType => 'Ekika ky\'Omukozesa';

  @override
  String get selectYourRole => 'Londa omulimu gwo';

  @override
  String get farmer => 'Omulimi';

  @override
  String get trader => 'Omusuubuzi';

  @override
  String get pleaseSelectUserType => 'Londa ekika ky\'omukozesa';

  @override
  String get district => 'Disitulikiti';

  @override
  String get selectYourDistrict => 'Londa disitulikiti yo';

  @override
  String get pleaseSelectDistrict => 'Londa disitulikiti';

  @override
  String get passwordMinLength =>
      'Ekigambo ky\'ekyama kirina okuba n\'obumanyirwa obutasingwa mu 8';

  @override
  String get confirmPassword => 'Kakasa Ekigambo ky\'ekyama';

  @override
  String get pleaseConfirmPassword => 'Kakasa ekigambo kyo eky\'ekyama';

  @override
  String get passwordsDoNotMatch => 'Ebigambo by\'ekyama tebikwatagana';

  @override
  String get agreeToOurPrefix => 'Bw\'oweewandiisa, okkiriza ';

  @override
  String get termsOfService => 'Ebiragiro by\'Obuweereza';

  @override
  String get andWord => ' ne ';

  @override
  String get privacyPolicy => 'Etteeka ly\'Eby\'ekyama';

  @override
  String get alreadyHaveAccount => 'Olina Akaunti dda? ';

  @override
  String get loginHere => 'Yingira wano';

  @override
  String get heatAlertTitle => 'Okulabula kw\'Obwokya';

  @override
  String heatAlertNotifTitle(int temp) {
    return 'Okulabula kw\'Obwokya — $temp°C';
  }

  @override
  String humidityAlertNotifTitle(int humidity) {
    return 'Obunnyogovu buli ku $humidity%';
  }

  @override
  String get guidelines => 'Ebiragiro';

  @override
  String get homeSubGreeting => 'Weetegeke okukuuma amakungula go leero?';

  @override
  String get goodMorning => 'Wasuze Otya';

  @override
  String get goodAfternoon => 'Osiibye Otya';

  @override
  String get goodEvening => 'Ekiro Kirungi';

  @override
  String get goodNight => 'Wasula Bulungi';

  @override
  String get defaultGreetingName => 'ggwe';

  @override
  String get locating => 'TULI KUNONYA EKIFO...';

  @override
  String get locationUnavailable => 'EKIFO TEKIRABIKA';

  @override
  String get fetchingWeather => 'Tuleeta embeera y\'obudde...';

  @override
  String get unavailable => 'Tekiriwo';

  @override
  String get heatAlertBadge => 'OKULABULA KW\'OBWOKYA';

  @override
  String get humidityAlertBadge => 'OKULABULA KW\'OBUNNYOGOVU';

  @override
  String get dailyTip => 'AMAGEZI AG\'OLUNAKU';

  @override
  String get seeAll => 'Laba Byonna';

  @override
  String get noScansYetHome =>
      'Tewali scan a bimu — nyiga \"AI Scan\" waggulu okukebera ekibinja kyo ekisooka.';

  @override
  String get healthyCaps => 'BULUNGI';

  @override
  String get riskyCaps => 'AKABI';

  @override
  String get lastScanCaps => 'SCAN EY\'OLUVANNYUMA';

  @override
  String get atRiskBadge => 'MU KABI';

  @override
  String get safeBadge => 'BULUNGI';

  @override
  String matchPercentLabel(int percent) {
    return '$percent% Ekikwatagana';
  }

  @override
  String get justNow => 'Kaakano';

  @override
  String minAgo(int count) {
    return 'eddakiika $count eziyise';
  }

  @override
  String hoursAgo(int count) {
    return 'essaawa $count eziyise';
  }

  @override
  String yesterdayAt(String time) {
    return 'Eggulo, $time';
  }

  @override
  String daysAgo(int count) {
    return 'ennaku $count eziyise';
  }

  @override
  String get couldNotAnalyzePhoto =>
      'Tetusobodde kwekenneenya kifananyi kino. Ddamu ogezeeko.';

  @override
  String get notMaizeColorMismatch =>
      'Tetusobodde kukizuula nga kasooli mubisi. Kino kiyinza kubaawo kasooli ng\'ayokeddwa oba afumbiddwa, ekifananyi nga si kya kasooli, oba omusana nga tegumanyiddwa bulungi. Ddamu okwate ekifananyi ekirongoofu eky\'empeke za kasooli mubisi mu musana omulungi.';

  @override
  String get notMaizeModelRejected =>
      'AI yaffe tekizuula nga mpeke za kasooli. Bwe kiba kasooli ayokeddwa oba afumbiddwa, tusobola kwekenneenya mpeke za kasooli mubisi zokka — ddamu okwate ekifananyi kya kasooli mubisi.';

  @override
  String get notMaizeLowConfidence =>
      'Tetufunye kizuula kirongoofu okuva mu kifananyi kino. Gezaako okukwata nate mu musana omulungi era onyweeze ssimu bulungi.';

  @override
  String get analyzingImageTitle => 'Twekenneenya Ekifananyi...';

  @override
  String get aiDetectingMold =>
      'AI yaffe eronda obukuku obulabika obukwatagana ne Aflatoxin.';

  @override
  String get analysisFailed => 'Okwekenneenya Kulemye';

  @override
  String get noScanResultFound => 'Tewali kivudde mu scan';

  @override
  String get scanMaizeSampleHint =>
      'Scan ekyokulabirako kya kasooli olabe ebiva mu kwekenneenya wano.';

  @override
  String get scanASample => 'Scan Ekyokulabirako';

  @override
  String couldNotCapturePhoto(String error) {
    return 'Tetusobodde kukwata kifananyi: $error';
  }

  @override
  String get scanMaize => 'Scan Kernels';

  @override
  String get flashOn => 'Ttoowa Ekiri';

  @override
  String get flashOff => 'Ttoowa Kizikidde';

  @override
  String get lightingGood => 'Omusana Mulungi';

  @override
  String get tooDark => 'Kizikiza Nnyo';

  @override
  String get adjustingFocus => 'Tukyakyusa Focus';

  @override
  String get focusSharp => 'Focus Nnungi';

  @override
  String get blurryHoldSteady => 'Kifuufuggirivu, Nyweeza Ssimu';

  @override
  String get moveToBrighterArea => 'Genda mu kifo ekirimu omusana omulungi';

  @override
  String get holdPhoneSteady => 'Nyweeza ssimu nga tonnakwata kifananyi';

  @override
  String get holdPhone20cm =>
      'Kwata ssimu obukiikanyi bwa 20cm okuva ku kyokulabirako';

  @override
  String get adjustFrameWillTurnWhite =>
      'Kyusa, ensengeka eneefuuka njeru bw\'eneetegeka';

  @override
  String get gallery => 'Ebifananyi';

  @override
  String get reviewPhoto => 'Kebera Ekifananyi';

  @override
  String get sharpAndWellLit => 'Kirongoofu era Kirimu Omusana Omulungi';

  @override
  String get photoMayBeTooDark => 'Ekifananyi kiyinza okuba nga kizikiza nnyo';

  @override
  String get photoMayBeBlurry => 'Ekifananyi kiyinza okuba nga kifuufuggirivu';

  @override
  String get retake => 'Ddamu Okwate';

  @override
  String get usePhoto => 'Kozesa Ekifananyi';

  @override
  String get aflatoxinDetector => 'Ekizuula Aflatoxin';

  @override
  String get healthyMaize => 'Kasooli Alungi';

  @override
  String get unsafeForConsumption => 'Tasaanidde Kuliibwa Bantu';

  @override
  String get diagnosisCompletedSuccessfully => 'Okwekenneenya kuwedde bulungi';

  @override
  String get analysisFlaggedForReview =>
      'Ekyokulabirako kino kyalondeddwa okwongera okukebera';

  @override
  String get generatingPdfReport => 'Tukola Report ya PDF...';

  @override
  String get couldNotSavePdfReport => 'Tetusobodde kutereka Report ya PDF';

  @override
  String get recommendationsAndDirectives => 'Ebiteesebwa n\'Ebiragiro';

  @override
  String confidencePercentLabel(int percent) {
    return '$percent% obwesigwa';
  }

  @override
  String get scanAnotherBatch => 'Scan Ekibinja Ekirala';

  @override
  String get allFilter => 'Byonna';

  @override
  String get locationFilterLabel => 'Ekifo';

  @override
  String showingResultsCount(int count) {
    return 'Tulaga ebiva mu $count';
  }

  @override
  String get forCurrentFilters => ' ku ebisengejje kaakati';

  @override
  String get clearAllFiltersX => 'Ggyawo Ebisengejje Byonna ×';

  @override
  String get noScansFound => 'Tewali Scan Ezaalabika';

  @override
  String get tryAdjustingFilters =>
      'Gezaako okukyusa ebisengejje\noba oscan ekyokulabirako kya kasooli ekipya.';

  @override
  String get clearFilters => 'Ggyawo Ebisengejje';

  @override
  String get couldNotLoadScanHistory =>
      'Tetusobodde kuleeta ebyafaayo bya scan';

  @override
  String get checkConnectionTryAgain => 'Kebera network yo oddemu ogezeeko.';

  @override
  String locationLabel(String location) {
    return 'Ekifo: $location';
  }

  @override
  String get notRecorded => 'Tewaterekeddwa';

  @override
  String dateLabel(String date) {
    return 'Olunaku: $date';
  }

  @override
  String statusLabel(String status) {
    return 'Embeera: $status';
  }

  @override
  String matchConfidenceLabel(int percent) {
    return 'Obwesigwa bw\'okukwatagana: $percent%';
  }

  @override
  String get couldNotGeneratePdfReport => 'Tetusobodde kukola Report ya PDF';

  @override
  String get filterByLocation => 'Sengejja n\'Ekifo';

  @override
  String get allLocations => 'Ebifo Byonna';

  @override
  String scanHistoryExportLabel(int count, int healthy) {
    return 'Report ya byafaayo bya scan ($count scans, $healthy birungi)';
  }

  @override
  String get alertsFilter => 'Okulabula';

  @override
  String get updatesFilter => 'Amawulire';

  @override
  String get allCaughtUp => 'Tewali kimu kaakati';

  @override
  String get noAlertsMessage => 'Tewali kulabula kaakati';

  @override
  String get noUpdatesMessage => 'Tewali mawulire kaakati';

  @override
  String get changePassword => 'Kyusa ekigambo ky\'ekyama';

  @override
  String get takeAPhoto => 'Kwata Ekifananyi';

  @override
  String get chooseFromGallery => 'Londa mu Bifananyi';

  @override
  String get cameraAccessDenied =>
      'Okuyingira mu kamera kugaanibwa. Kikkirize mu Settings okukwata ekifananyi.';

  @override
  String get photoLibraryAccessDenied =>
      'Okuyingira mu bifananyi kugaanibwa. Kikkirize mu Settings okulonda ekifananyi.';

  @override
  String get fullNameCannotBeEmpty =>
      'Amannya gonna tegasobola kuba awatali kimu';

  @override
  String get couldNotUploadProfilePicture =>
      'Tetusobodde kussaayo ekifananyi kyo. Ddamu ogezeeko.';

  @override
  String get profileUpdatedSuccessfully => 'Profayiro ekyusiddwa bulungi';

  @override
  String get couldNotUpdateProfile =>
      'Tetusobodde kukyusa Profayiro. Ddamu ogezeeko.';

  @override
  String get editProfile => 'Kyusa Profayiro';

  @override
  String get locationField => 'Ekifo';

  @override
  String get saveChanges => 'Tereka Enkyukakyuka';

  @override
  String get changePasswordTitle => 'Kyusa Ekigambo ky\'ekyama';

  @override
  String get currentPassword => 'Ekigambo ky\'ekyama Ekiriwo';

  @override
  String get enterCurrentPassword => 'Yingiza ekigambo kyo ekiriwo eky\'ekyama';

  @override
  String get newPassword => 'Ekigambo ky\'ekyama Ekipya';

  @override
  String get passwordMin6Chars =>
      'Ekigambo ky\'ekyama kirina okuba n\'obumanyirwa obutasingwa mu 6';

  @override
  String get confirmNewPassword => 'Kakasa Ekigambo ky\'ekyama Ekipya';

  @override
  String get updatePassword => 'Kyusa Ekigambo ky\'ekyama';

  @override
  String get passwordChangedTitle => 'Ekigambo ky\'ekyama Kikyusiddwa';

  @override
  String get passwordChangedBody =>
      'Ekigambo ky\'akaunti yo eky\'ekyama kikyusiddwa bulungi.';

  @override
  String get passwordUpdatedSuccessfully =>
      'Ekigambo ky\'ekyama kikyusiddwa bulungi';

  @override
  String get couldNotChangePassword =>
      'Tetusobodde kukyusa kigambo ky\'ekyama. Ddamu ogezeeko.';

  @override
  String get currentPasswordIncorrect =>
      'Ekigambo ky\'ekyama ekiriwo si kituufu.';

  @override
  String get newPasswordTooWeak => 'Ekigambo ky\'ekyama ekipya kinafu nnyo.';

  @override
  String get pleaseLogOutAndBackIn => 'Fuluma oyingire nate, ate ogezeeko.';

  @override
  String get errorOccurredTryAgain => 'Wabaddewo ekisobyo. Ddamu ogezeeko.';

  @override
  String get resetPassword => 'Zza Ekigambo ky\'ekyama';

  @override
  String get resetPasswordInstructions =>
      'Yingiza endagiriro yo eya email eyewandiisibbwa waggulu. Tujja kukuweereza nampeya ya nnamba mukaaga okuzza ekigambo kyo eky\'ekyama era n\'okukuuma akaunti yo obulungi.';

  @override
  String get pleaseEnterValidEmailAddress =>
      'Yingiza endagiriro ya email entuufu';

  @override
  String get sendResetLink => 'Weereza Nampeya';

  @override
  String get otpScreenTitle => 'Yingiza Nampeya';

  @override
  String otpInstructions(String email) {
    return 'Yingiza nampeya ya nnamba mukaaga gye twaweereza ku $email.';
  }

  @override
  String get otpLabel => 'Nampeya y\'Okukakasa';

  @override
  String get pleaseEnterOtp => 'Yingiza nampeya';

  @override
  String get otpInvalidLength => 'Yingiza nampeya ya nnamba mukaaga';

  @override
  String get verifyAndReset => 'Kakasa & Zza Ekigambo ky\'ekyama';

  @override
  String get resendCode => 'Weereza Nampeya Nate';

  @override
  String resendCodeIn(int seconds) {
    return 'Weereza nampeya nate mu ${seconds}s';
  }

  @override
  String get pleaseWaitBeforeResend => 'Linda okumala okusaba nampeya endala.';

  @override
  String get codeExpired => 'Nampeya eno ewedde ekiseera. Saba endala.';

  @override
  String get tooManyAttempts =>
      'Ogezezzaako emirundi mingi ne kiremererwa. Saba nampeya empya.';

  @override
  String get incorrectCode => 'Nampeya si ntuufu. Ddamu ogezeeko.';

  @override
  String get downloadedReports => 'Report Ezawanguddwa';

  @override
  String get noDownloadedReports => 'Tewali Report Zawanguddwa';

  @override
  String get legal => 'Amateeka';

  @override
  String get reportSaved => 'Report Etekeddwa';

  @override
  String get pdfSavedMessage =>
      'Report yo eya PDF ereseddwa ku ssimu eno. Osobola okugizzaawo kaakati oba okugizuula oluvannyuma mu Report Ezawanguddwa.';

  @override
  String get viewAllReports => 'Laba Report Zonna';

  @override
  String get openPdf => 'Zzaawo PDF';

  @override
  String get processingPipeline => 'Enkola y\'Okukola';

  @override
  String get estimatedWait => 'Obudde bw\'okulinda: emiseseganya 3–5';

  @override
  String get neuralEngineActive => 'Neural Engine Ekola';

  @override
  String get scanningAspergillus => 'Tunoonya ensengeka za Aspergillus flavus.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get appPreferences => 'Ebisaanyizibwa mu App';

  @override
  String get notificationsSubtitle =>
      'Obubaka ku biva mu scan n\'embeera y\'ebibinja';

  @override
  String get helpSupportSection => 'Obuyambi n\'obuwagizi';

  @override
  String get contactSupport => 'Tukwatagane n\'Obuyambi';

  @override
  String get couldNotOpenEmailApp =>
      'Tetusobodde kuggulawo app ya email. Tukwatagane ku aflalert.support@gmail.com';

  @override
  String get aboutAflAlert => 'Ebikwata ku AflAlert';

  @override
  String get recommendationsSourced =>
      'Ebiteesebwa biva mu buwabuzi bwa UNBS ne MAAIF.';

  @override
  String get aboutDescription =>
      'AflAlert eyamba abalimi n\'abakwatirira empeke okuzuula obulabe bwa Aflatoxin mu kasooli nga tekinnatuuka ku katale. Kuba ekifaananyi ky\'empeke za kasooli oba strip ey\'okugezesa, olyoke ofune ekiwandiiko ky\'obulabe mu bwangu nga bikoleddwa AI — ku ssimu yo, wadde nga tewali laabu.';

  @override
  String get aboutFeaturesTitle => 'AflAlert ky\'ekola';

  @override
  String get aboutFeatureScanTitle => 'Okukebera empeke ne strip';

  @override
  String get aboutFeatureScanDesc =>
      'Okwekenneenya ebifaananyi nga kozesa AI kizuula obukuku n\'obulabe bwa Aflatoxin mu mpeke za kasooli oba strip.';

  @override
  String get aboutFeatureRecommendationsTitle => 'Obuwabuzi obulambulukufu';

  @override
  String get aboutFeatureRecommendationsDesc =>
      'Buli kiva mu kukebera kijjirako obuwabuzi obuva mu bipimo bya UNBS ne MAAIF.';

  @override
  String get aboutFeatureRainAlertsTitle => 'Obubaka bw\'enkuba';

  @override
  String get aboutFeatureRainAlertsDesc =>
      'Tukutegeeza nga enkuba tennagwa oyinza okubikka kasooli akayanika mangu, ekikendeeza obulabe bw\'obukuku ne Aflatoxin.';

  @override
  String get aboutFeatureVoiceTitle => 'Omuyambi w\'eddoboozi';

  @override
  String get aboutFeatureVoiceDesc =>
      'Kola scan era obuuze ebibuuzo nga tokwatako ku ssimu.';

  @override
  String get aboutFeatureReportsTitle => 'Ebyafaayo n\'lipoota';

  @override
  String get aboutFeatureReportsDesc =>
      'Laba ebyafaayo by\'okukebera era osobole okuggya lipoota za PDF okugabana oba okuzikuuma.';

  @override
  String get aboutVersion => 'Version 1.0.0';

  @override
  String get aboutCopyright => '© 2026 AflAlert. Eddembe lyonna likuumiddwa.';

  @override
  String get contactSupportScreenTitle => 'Tukwatagane n\'Obuyambi';

  @override
  String get contactSupportIntro =>
      'Tubuulire ekikuteganya naffe tunaakuddamu ku email.';

  @override
  String get contactSupportCategoryLabel => 'Kino kikwata ku ki?';

  @override
  String get contactSupportCategoryBug => 'Ekiremya app';

  @override
  String get contactSupportCategoryScan => 'Ekizibu ku scan oba ebiva mu kyo';

  @override
  String get contactSupportCategoryAccount => 'Ekizibu ku akaunti';

  @override
  String get contactSupportCategoryFeedback => 'Ebirowoozo';

  @override
  String get contactSupportCategoryOther => 'Ekirala';

  @override
  String get contactSupportEmailLabel => 'Email yo';

  @override
  String get contactSupportEmailHint => 'you@example.com';

  @override
  String get contactSupportEmailRequired => 'Wandiika email tulyoke tukuddemu';

  @override
  String get contactSupportEmailInvalid => 'Wandiika email entuufu';

  @override
  String get contactSupportMessageLabel => 'Obubaka';

  @override
  String get contactSupportMessageHint =>
      'Nnyonnyola ekizibu oba ebirowoozo byo...';

  @override
  String get contactSupportMessageRequired =>
      'Nnyonnyola ekikuteganya nga tonnaweereza';

  @override
  String get contactSupportSubmit => 'Weereza';

  @override
  String get contactSupportSubmitting => 'Tuweereza...';

  @override
  String get contactSupportSuccess =>
      'Weebale! Obubaka bwo buweereddwa. Tujja kukuddamu ku email.';

  @override
  String get contactSupportError =>
      'Wabaddewo ekizibu okuweereza obubaka bwo. Tukusaba otutumire email butereevu.';

  @override
  String get contactSupportEmailDirectly =>
      'Bwoba weetaaga obuyambi obulala, tutuukirire ku';

  @override
  String get maizeScanLabel => 'Maize Scan';

  @override
  String get stripScanLabel => 'Strip Scan';

  @override
  String get coachMarkSkip => 'Skip';

  @override
  String get coachMarkNext => 'Next';

  @override
  String get coachMarkGotIt => 'Got it';

  @override
  String get coachMarkMaizeTitle => 'Scan your maize';

  @override
  String get coachMarkMaizeDesc =>
      'Tap here to photograph maize kernels and check for visible mold.';

  @override
  String get coachMarkStripTitle => 'Test a chemical strip';

  @override
  String get coachMarkStripDesc =>
      'Tap here after the strip\'s reaction time to check aflatoxin levels.';

  @override
  String get coachMarkWeatherTitle => 'Today\'s weather';

  @override
  String get coachMarkWeatherDesc =>
      'Tap this card anytime to see the full hourly forecast.';

  @override
  String get coachMarkVoiceTitle => 'Gezaako Omuyambi w\'Eddoboozi';

  @override
  String get coachMarkVoiceDesc =>
      'Nyiga wano oyogere — mugambe okuscan kasooli yo, akebere embeera y\'obudde, oba okumubuuza ekibuuzo.';

  @override
  String get chemicalStripScanTitle => 'Chemical Strip Scan';

  @override
  String get scanTestStrip => 'Kebera Test Strip';

  @override
  String get cropTypeMaize => 'Kasooli';

  @override
  String get positionStripInFrame =>
      'Teeka strip mu bbokisi oluvannyuma lw\'eddakiika kkumi ez\'okulinda';

  @override
  String get scanAnotherStrip => 'Kebera Strip Endala';

  @override
  String get scanTestStripHint =>
      'Kebera test strip okumanya obungi bw\'obutwa mu bulimi';

  @override
  String get analyzingStripTitle => 'Nkebera Strip...';

  @override
  String get readingTestControlLines => 'Nsoma emiggo gya Test ne Control';

  @override
  String get stripNotDetectedMessage =>
      'Tetuzudde strip mu kifaananyi kino. Kakasa nti strip yonna eri mu bbokisi era nga waliwo ekitangaala ekimala, oluvannyuma ddamu ogezeeko.';

  @override
  String get controlLineNotDetectedMessage =>
      'Omuggo gwa Control tegulabise — ekigezo kino kiyinza obutaba kituufu. Ddamu okole ekigezo ne strip empya.';

  @override
  String get testBatchLabel => 'EKIBINJA KY\'EKIGEZO';

  @override
  String get toxicLoadLabel => 'OBUNGI BW\'OBUTWA';

  @override
  String get regulatoryScaleLabel => 'EMITENDERO GY\'AMATEEKA';

  @override
  String get actionRequiredLabel => 'EKIKOLWA KYETAAGISA';

  @override
  String get diagnosticBreakdownLabel => 'EBIKWATA KU KIGEZO';

  @override
  String get chemicalLevelLabel => 'Ekigero ky\'obutwa';

  @override
  String get testLineOdLabel => 'Ekizimba ky\'omuggo gwa Test (T)';

  @override
  String get controlLineOdLabel => 'Ekizimba ky\'omuggo gwa Control (C)';

  @override
  String get odRatioLabel => 'Enkigero ya T/C';

  @override
  String get scanLocationLabel => 'Ekifo ekyakeberebwa';

  @override
  String get withinSafeLimit => 'Kiri mu Ekigero Ekikkirizibwa';

  @override
  String get exceedsSafeLimit => 'Kisukiddeko Ekigero Ekikkirizibwa';

  @override
  String get wasThisDiagnosisAccurate => 'Ekizuuliddwa kino kituufu?';

  @override
  String get feedbackThanks =>
      'Weebale — endowooza yo eyamba okulongoosa scan ez\'omu maaso.';

  @override
  String get feedbackYesTooltip => 'Yee, kituufu';

  @override
  String get feedbackNoTooltip => 'Nedda, si kituufu';

  @override
  String safeLimitTick(String limit) {
    return 'Ekigero kya $limit ppb';
  }

  @override
  String exceedsSafeLimitMessage(String limit) {
    return 'Ekyokulabirako kino kisukiddeko ekigero ky\'amateeka ekya $limit ppb mu mmere y\'abantu.';
  }

  @override
  String ppbValueLabel(String value) {
    return '$value ppb';
  }

  @override
  String chemicalLevelValueLabel(String value) {
    return 'Ekigero ky\'obutwa: $value ppb';
  }

  @override
  String todayHighLowLabel(String high, String low) {
    return 'Leero: Ekya waggulu $high° Ekya wansi $low°';
  }

  @override
  String get nowLabel => 'Kaakano';

  @override
  String get voiceAssistantEntryTooltip => 'Omuyambi w\'eddoboozi';

  @override
  String get voiceAssistantTitle => 'Omuyambi w\'Eddoboozi';

  @override
  String get voiceAssistantEnglishOnlyNotice =>
      'Ebiragiro by\'eddoboozi kati bikola mu Lungereza lwokka.';

  @override
  String get voiceAssistantHint =>
      'Nyiga ku kabonero k\'eddoboozi ate ogezeeko okwogera nti \"scan this maize\" oba \"what\'s the weather?\"';

  @override
  String get voiceAssistantVoiceFemale =>
      'Eddoboozi ery\'omukazi — nyiga okukyusa okuba ery\'omusajja';

  @override
  String get voiceAssistantVoiceMale =>
      'Eddoboozi ery\'omusajja — nyiga okukyusa okuba ery\'omukazi';

  @override
  String maizeFindingSafeHighConfidence(int percent) {
    return 'Tewali bubonero bwa bukuku oba Aflatoxin bwazuuliddwa mu kyokulabirako kino ($percent% obwesigwa).';
  }

  @override
  String maizeFindingSafeLowConfidence(int percent) {
    return 'Tewali bubonero bwa bukuku bwazuuliddwa, naye obwesigwa bwa $percent% bwokka. Ddamu oscan mu musana omulungi era ogumatiziganya okukakasa nga tonnesigama ku kivuddemu kino.';
  }

  @override
  String maizeFindingUnsafeHighConfidence(int percent) {
    return 'Obukuku obulabika obukwatagana ne Aflatoxin bwazuuliddwa ($percent% obwesigwa).';
  }

  @override
  String maizeFindingUnsafeLowConfidence(int percent) {
    return 'Obukuku obuyinza okubaawo bwazuuliddwa, naye obwesigwa bwa $percent% bwokka. Ekibinja kino kikwate nga kiri mu kabi akasukirivu era oddemu oscan mu musana omulungi okukakasa.';
  }

  @override
  String get maizeStorageTip =>
      'Kuuma obunnyogovu bw\'empeke wansi wa 13% era otereke mu kifo ekinyogovu, ekikalu era ekirimu empewo, nga kisitiddwa waggulu okuva ku ttaka okuziyiza obukuku okulabika oluvannyuma lwa scan eno.';

  @override
  String get maizeRecheckTip =>
      'Ddamu okebere ebibinja ebiterekeddwa buli kiseera — akabi ka Aflatoxin kayinza okweyongera oluvannyuma lw\'okutereka wadde ng\'empeke zaali nnungi ku lubereberye.';

  @override
  String get maizeIsolateTip =>
      'Tosuubuza wadde okulya ekibinja kino. Kyawule mangu era onoonye okwekenneenya kwa laabu ekakasiddwa nga tonnakozesa mu ngeri endala.';

  @override
  String get maizeLivestockTip =>
      'Towaayo ekibinja kino n\'eri ebisolo — Aflatoxin asobola okuyingira mu mata n\'ennyama, ekiyinza okuleeta akabi eri ebisolo n\'abo abagalya.';

  @override
  String stripFindingSafe(String ppb, String limit) {
    return 'Enkigero y\'omuggo gwa Test elaga obungi obwesigika obwa $ppb ppb, nga kiri mu kigero ekikkirizibwa ekya $limit ppb ku mmere y\'abantu.';
  }

  @override
  String stripFindingUnsafe(String ppb, String limit) {
    return 'Enkigero y\'omuggo gwa Test elaga obungi obwesigika obwa $ppb ppb, nga kisukiddeko ekigero ekikkirizibwa ekya $limit ppb ku mmere y\'abantu.';
  }

  @override
  String get stripStorageTip =>
      'Kuuma obunnyogovu bw\'empeke wansi wa 13% era otereke mu kifo ekinyogovu, ekikalu era ekirimu empewo, nga kisitiddwa waggulu okuva ku ttaka.';

  @override
  String get stripRecheckTip =>
      'Ddamu okebere ebibinja ebiterekeddwa buli kiseera — obungi bwa Aflatoxin busobola okweyongera nga bikyaterekeddwa wadde ng\'ekibinja kyali kirungi ku lubereberye.';

  @override
  String get stripIsolateTip =>
      'Totabulanya kibinja kino n\'empeke ennungi. Kyawule mangu era onoonye okwekenneenya kwa laabu ekakasiddwa nga tonnakozesa mu ngeri endala.';

  @override
  String get stripDisposalTip =>
      'Ekibinja kino kifulumye oba kikozesebwe mu bikolwa by\'obwannannyini ebikkirizibwa — tokiwaayo n\'eri bisolo, kubanga Aflatoxin ayingira mu mata n\'ennyama.';

  @override
  String get profileUpdatedNotifTitle => 'Profayiro Ekyusiddwa';

  @override
  String get profileUpdatedNotifBody =>
      'Ebikwata ku akaunti yo bikyusiddwa bulungi.';
}
