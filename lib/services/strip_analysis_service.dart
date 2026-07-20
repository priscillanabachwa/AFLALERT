// strip_analysis_service.dart
//
// AflAlert — Tier 2 chemical strip reader.
//
// Reads a photographed lateral-flow test strip and estimates an aflatoxin
// ppb figure from the relative darkness of its Test (T) and Control (C)
// lines. This is deterministic image processing (no trained model, no
// training dataset) — mirrors the decode/pixel-sampling approach already
// used in tflite_service_io.dart and camera_screen.dart via package:image.

import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

enum InvalidStripReason { stripNotDetected, controlLineNotDetected }

class InvalidStripException implements Exception {
  final InvalidStripReason reason;
  const InvalidStripException(this.reason);
}

class StripAnalysisResult {
  final double ppbValue;
  final double tLineOD;
  final double cLineOD;
  final double odRatio;
  final double safeLimitPpb;

  const StripAnalysisResult({
    required this.ppbValue,
    required this.tLineOD,
    required this.cLineOD,
    required this.odRatio,
    required this.safeLimitPpb,
  });

  bool get isSafe => ppbValue <= safeLimitPpb;
}

class StripAnalysisService {
  // --- Calibration constants -------------------------------------------
  // No manufacturer/lab calibration curve is available for this prototype,
  // so ppb is derived from a monotonic placeholder formula rather than a
  // real standard curve. Swap these out (and the formula in _ppbFromRatio)
  // once real calibration data exists.
  static const double safeLimitPpb = 20;
  static const double maxDetectionPpb = 100;
  static const double _ppbCurveGamma = 1.6;

  // A strip cassette + nitrocellulose membrane reads as a mostly bright,
  // low-saturation ("pale") surface. Photos of unrelated subjects (faces,
  // rooms, produce, ...) rarely clear this bar, so it's used as an early,
  // cheap rejection before spending time on line detection.
  static const double _paleBrightnessFloor = 0.55;
  static const double _paleSaturationCeiling = 0.28;
  static const double _minPaleRatio = 0.45;

  // A line band must be at least this much darker than its local
  // background to count as a real line rather than sensor/paper noise.
  static const double _minLineProminence = 0.10;
  // Candidate bands wider than this fraction of the strip are treated as
  // shadows/edges/objects rather than a printed line.
  static const double _maxBandWidthFraction = 0.22;
  // The control line must clear this absolute darkness (as a fraction of
  // local background luminance lost) to count as a valid, developed line —
  // a faint/missing C line means the strip run itself failed (standard
  // lateral-flow QC), not a low ppb reading.
  static const double _minControlDarkness = 0.12;

  static final StripAnalysisService _instance =
      StripAnalysisService._internal();
  factory StripAnalysisService() => _instance;
  StripAnalysisService._internal();

  Future<StripAnalysisResult> analyzeStrip(File imageFile) async {
    return analyzeStripBytes(await imageFile.readAsBytes());
  }

  Future<StripAnalysisResult> analyzeStripBytes(Uint8List bytes) async {
    final img.Image? decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw const InvalidStripException(InvalidStripReason.stripNotDetected);
    }

    if (!_looksLikeStrip(decoded)) {
      throw const InvalidStripException(InvalidStripReason.stripNotDetected);
    }

    // The capture screen constrains the photo to a fixed portrait
    // orientation with the strip filling the frame top-to-bottom, so the
    // T/C lines run horizontally — average luminance row by row, sampling
    // only the central column band to avoid strip-edge glare/shadow.
    final List<double> profile = _rowLuminanceProfile(decoded);
    if (profile.length < 20) {
      throw const InvalidStripException(InvalidStripReason.stripNotDetected);
    }

    // A rolling-max envelope tracks the local background brightness even
    // where a line dips below it, so line strength is judged against the
    // membrane right around it rather than a single strip-wide value —
    // this keeps detection reliable under uneven lighting (a torch held to
    // one side, a shadow across part of the frame, etc.).
    final List<double> baseline = _localBaseline(profile);
    final List<_LineBand> bands = _findLineBands(profile, baseline);

    if (bands.length < 2) {
      throw const InvalidStripException(InvalidStripReason.stripNotDetected);
    }

    // Flow-direction convention: the capture guide places the Control (C)
    // line label near the top of the frame and Test (T) near the bottom,
    // so scanning top-to-bottom the first line encountered is Control.
    bands.sort((a, b) => a.rowIndex.compareTo(b.rowIndex));
    final _LineBand cBand = bands.first;
    final _LineBand tBand = bands[1];

    final double cLineOD = _opticalDensity(cBand.luminance, cBand.baseline);
    final double tLineOD = _opticalDensity(tBand.luminance, tBand.baseline);

    if (cLineOD < _minControlDarkness) {
      throw const InvalidStripException(
        InvalidStripReason.controlLineNotDetected,
      );
    }

    final double odRatio = (tLineOD / cLineOD).clamp(0.0, 1.2);
    final double ppb = _ppbFromRatio(odRatio);

    return StripAnalysisResult(
      ppbValue: ppb,
      tLineOD: tLineOD,
      cLineOD: cLineOD,
      odRatio: odRatio,
      safeLimitPpb: safeLimitPpb,
    );
  }

  // Competitive lateral-flow assay: more aflatoxin in the sample means
  // less conjugate binds at the Test line, so the T line fades as
  // contamination rises. odRatio == 1 (T as dark as C) -> ~0ppb; odRatio
  // -> 0 (T line washed out) -> approaches the upper detection ceiling.
  double _ppbFromRatio(double odRatio) {
    final double fade = (1 - odRatio).clamp(0.0, 1.0);
    final double ppb = maxDetectionPpb * math.pow(fade, _ppbCurveGamma);
    return ppb.clamp(0.0, maxDetectionPpb);
  }

  double _opticalDensity(double lineLuminance, double background) {
    if (background <= 0 || lineLuminance <= 0) return 0;
    final double ratio = (lineLuminance / background).clamp(0.001, 1.0);
    return math.max(0, -math.log(ratio) / math.ln10);
  }

  // Cheap plausibility gate run before line detection: a strip cassette and
  // its membrane are predominantly bright and low-saturation, so a photo
  // that's mostly dark and/or richly colored throughout is very unlikely
  // to actually be a test strip.
  bool _looksLikeStrip(img.Image image) {
    final int stepX = (image.width / 40).ceil().clamp(1, 200);
    final int stepY = (image.height / 80).ceil().clamp(1, 200);

    int sampled = 0;
    int paleCount = 0;
    for (int y = 0; y < image.height; y += stepY) {
      for (int x = 0; x < image.width; x += stepX) {
        final pixel = image.getPixel(x, y);
        final double r = pixel.r / 255.0;
        final double g = pixel.g / 255.0;
        final double b = pixel.b / 255.0;
        final double maxC = math.max(r, math.max(g, b));
        final double minC = math.min(r, math.min(g, b));
        final double saturation = maxC == 0 ? 0.0 : (maxC - minC) / maxC;

        sampled++;
        if (maxC >= _paleBrightnessFloor && saturation <= _paleSaturationCeiling) {
          paleCount++;
        }
      }
    }

    if (sampled == 0) return false;
    return (paleCount / sampled) >= _minPaleRatio;
  }

  List<double> _rowLuminanceProfile(img.Image image) {
    final int centerX = image.width ~/ 2;
    final int bandHalfWidth = (image.width * 0.15).round().clamp(1, centerX);
    final int xStart = (centerX - bandHalfWidth).clamp(0, image.width - 1);
    final int xEnd = (centerX + bandHalfWidth).clamp(0, image.width - 1);

    final List<double> profile = List<double>.filled(image.height, 0);
    for (int y = 0; y < image.height; y++) {
      double sum = 0;
      int count = 0;
      for (int x = xStart; x <= xEnd; x++) {
        final pixel = image.getPixel(x, y);
        // Standard luma weighting.
        sum += 0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b;
        count++;
      }
      profile[y] = count == 0 ? 0 : sum / count;
    }
    return profile;
  }

  // Rolling-max envelope: within each window, the brightest sample is what
  // the membrane would read at that position if no line dipped into it —
  // lines are always local minima, so as long as the window is wider than
  // any single line, the max recovers the surrounding background even
  // directly over a line. This is what lets detection tolerate a lighting
  // gradient across the strip instead of relying on one global background
  // value.
  List<double> _localBaseline(List<double> profile) {
    final int window = (profile.length * 0.18).round().clamp(
      5,
      profile.length,
    );
    final int half = window ~/ 2;
    final List<double> baseline = List<double>.filled(profile.length, 0);
    for (int y = 0; y < profile.length; y++) {
      final int start = (y - half).clamp(0, profile.length - 1);
      final int end = (y + half).clamp(0, profile.length - 1);
      double maxV = 0;
      for (int k = start; k <= end; k++) {
        if (profile[k] > maxV) maxV = profile[k];
      }
      baseline[y] = maxV;
    }
    return baseline;
  }

  List<_LineBand> _findLineBands(List<double> profile, List<double> baseline) {
    final int n = profile.length;
    final int maxBandWidth = (n * _maxBandWidthFraction).round().clamp(2, n);
    // Rows right at the crop edge are prone to border/vignette artifacts
    // from the capture frame itself, not real strip content.
    final int edgeMargin = (n * 0.03).round();
    final int end = (n - edgeMargin).clamp(edgeMargin, n);

    final List<_LineBand> candidates = [];
    int i = edgeMargin;
    while (i < end) {
      final double localBg = baseline[i];
      final double threshold = localBg * (1 - _minLineProminence);
      if (localBg > 0 && profile[i] <= threshold) {
        final int start = i;
        double minLuminance = profile[i];
        int minIndex = i;
        double minBaseline = localBg;
        while (i < end && profile[i] <= baseline[i] * (1 - _minLineProminence)) {
          if (profile[i] < minLuminance) {
            minLuminance = profile[i];
            minIndex = i;
            minBaseline = baseline[i];
          }
          i++;
        }
        final int width = i - start;
        // Ignore hairline noise spikes and overly broad dark regions
        // (shadows, cassette edges, foreign objects).
        if (width >= 2 && width <= maxBandWidth) {
          candidates.add(
            _LineBand(rowIndex: minIndex, luminance: minLuminance, baseline: minBaseline),
          );
        }
      } else {
        i++;
      }
    }

    // Strongest (darkest relative to local background) first, then drop
    // any candidate that sits within one band-width of an already-kept,
    // stronger candidate — guards against the same physical line being
    // split into two nearby detections by a momentary noise blip.
    candidates.sort(
      (a, b) => (a.luminance / a.baseline).compareTo(b.luminance / b.baseline),
    );
    final List<_LineBand> kept = [];
    for (final candidate in candidates) {
      final bool tooClose = kept.any(
        (b) => (b.rowIndex - candidate.rowIndex).abs() < maxBandWidth,
      );
      if (!tooClose) kept.add(candidate);
    }
    return kept.take(4).toList();
  }
}

class _LineBand {
  final int rowIndex;
  final double luminance;
  final double baseline;

  const _LineBand({
    required this.rowIndex,
    required this.luminance,
    required this.baseline,
  });
}
