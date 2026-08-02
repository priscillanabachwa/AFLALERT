# AflAlert

AI-powered aflatoxin risk detection for maize — built for farmers and grain handlers who need a fast risk read without lab access.

Snap a photo of maize kernels or a reacted lateral-flow test strip and get an instant, on-device risk assessment, paired with guided next steps sourced from UNBS and MAAIF standards.

## Features

- **Kernel scan (Tier 1)** — photograph a sample of maize kernels; a bundled TFLite image classification model (`lib/assets/best.tflite`) flags visible mold/discoloration risk. See [tflite_service_io.dart](lib/services/tflite_service_io.dart).
- **Test strip reader (Tier 2)** — after an on-site liquid extraction, photograph the reacted lateral-flow strip. The app isolates the Test (T) and Control (C) lines from the image, computes their optical density ratio, and estimates a contamination reading in ppb. See [strip_analysis_service.dart](lib/services/strip_analysis_service.dart).
  > **Calibration status:** the ppb figure currently comes from a placeholder monotonic curve, not a lab-fitted calibration. It's useful as a relative/qualitative signal (safe vs. not, roughly how severe) but shouldn't be presented as a validated quantitative assay result until it's calibrated against certified reference strips (a dilution series of known concentrations, read through the same pipeline, fitted to a dose-response curve).
- **Guided recommendations** — every scan result comes with next-step guidance.
- **Weather & rain alerts** — daily morning weather summary plus urgent rain-incoming alerts so drying grain can be covered in time, reducing mold/aflatoxin risk. Runs via WorkManager so it still fires with the app closed (Android only — no background scheduler guarantee on iOS). See [rain_alert_service.dart](lib/services/rain_alert_service.dart), [morning_alert_service.dart](lib/services/morning_alert_service.dart).
- **Voice assistant** — run scans and ask questions hands-free. See [voice_assistant_service.dart](lib/services/voice_assistant_service.dart).
- **Scan history & PDF reports** — review past scans and export/share PDF reports. See [firestore_service.dart](lib/services/firestore_service.dart), [pdf_service.dart](lib/services/pdf_service.dart).
- **Accounts** — email/Google sign-in, OTP verification, password reset, biometric unlock (`local_auth`).
- **Localization** — English and Luganda (`lib/l10n`).

## Tech stack

- Flutter / Dart
- Firebase: Auth, Cloud Firestore, Storage, Cloud Functions, App Check, Firebase AI
- `tflite_flutter` for on-device kernel classification
- `package:image` for the strip-reading pixel pipeline (no ML model — deterministic image processing)
- `camera`, `image_picker`, `geolocator`/`geocoding`, `flutter_local_notifications`, `workmanager`
- `pdf` / `printing` / `share_plus` for report generation and export

## Getting started

1. Install [Flutter](https://docs.flutter.dev/get-started/install) (SDK ^3.12.2) and run `flutter doctor` to confirm your setup.
2. Install dependencies:
   ```
   flutter pub get
   ```
3. Firebase is already configured via [lib/firebase_options.dart](lib/firebase_options.dart) (generated with FlutterFire CLI). If you're standing up your own Firebase project, run `flutterfire configure` to regenerate it, and register a debug token in **Firebase Console > App Check > Manage debug tokens** (the app activates App Check debug providers on Android/iOS at startup).
4. Cloud Functions backend lives in [functions/](functions/) (Node.js) — see that folder for its own setup if you need to deploy changes.
5. Run the app:
   ```
   flutter run
   ```

## Project structure

```
lib/
  screens/     UI screens (auth, home, camera/strip capture, results, history, settings, ...)
  services/    Business logic (TFLite classification, strip analysis, Firebase, weather/alerts, PDF, ...)
  l10n/        Localization (English, Luganda)
  constants/   Shared design tokens (colors, etc.)
  assets/      TFLite model + images
functions/     Firebase Cloud Functions backend
android/ ios/  Platform projects
```

## Known limitations

- Strip-reader ppb values are estimates from a placeholder curve pending real calibration data (see above).
- Background rain/weather alerts are best-effort on Android only.
