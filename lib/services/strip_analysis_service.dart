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

  // A line band must be at least this much darker than the local
  // background to count as a real line rather than sensor/paper noise.
  static const double _minLineProminence = 0.06;
  // The control line must clear this absolute darkness (as a fraction of
  // background luminance lost) to count as a valid, developed line — a
  // faint/missing C line means the strip run itself failed (standard
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

    // The capture screen constrains the photo to a fixed portrait
    // orientation with the strip filling the frame top-to-bottom, so the
    // T/C lines run horizontally — average luminance row by row, sampling
    // only the central column band to avoid strip-edge glare/shadow.
    final List<double> profile = _rowLuminanceProfile(decoded);
    if (profile.isEmpty) {
      throw const InvalidStripException(InvalidStripReason.stripNotDetected);
    }

    final double background = _estimateBackground(profile);
    final List<_LineBand> bands = _findLineBands(profile, background);

    if (bands.length < 2) {
      throw const InvalidStripException(InvalidStripReason.stripNotDetected);
    }

    // Flow-direction convention: the capture guide fixes the strip so the
    // sample end (and therefore the Test line) is encountered first,
    // followed by the Control line closer to the wicking/absorbent end.
    bands.sort((a, b) => a.rowIndex.compareTo(b.rowIndex));
    final _LineBand tBand = bands.first;
    final _LineBand cBand = bands[1];

    final double tLineOD = _opticalDensity(tBand.luminance, background);
    final double cLineOD = _opticalDensity(cBand.luminance, background);

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

  // Background = the brightest typical region of the strip (the plain
  // membrane, not a line), approximated as a high percentile of the
  // luminance profile so a couple of dark line rows don't drag it down.
  double _estimateBackground(List<double> profile) {
    final List<double> sorted = List<double>.from(profile)..sort();
    final int index = (sorted.length * 0.85).floor().clamp(
      0,
      sorted.length - 1,
    );
    return sorted[index];
  }

  List<_LineBand> _findLineBands(List<double> profile, double background) {
    if (background <= 0) return [];
    final double threshold = background * (1 - _minLineProminence);

    final List<_LineBand> bands = [];
    int i = 0;
    while (i < profile.length) {
      if (profile[i] <= threshold) {
        int start = i;
        double minLuminance = profile[i];
        int minIndex = i;
        while (i < profile.length && profile[i] <= threshold) {
          if (profile[i] < minLuminance) {
            minLuminance = profile[i];
            minIndex = i;
          }
          i++;
        }
        // Ignore hairline noise spikes narrower than a couple of rows.
        if (i - start >= 2) {
          bands.add(_LineBand(rowIndex: minIndex, luminance: minLuminance));
        }
      } else {
        i++;
      }
    }
    // Strongest (darkest) bands first, then keep at most a handful of
    // candidates before re-sorting by position for flow-direction order.
    bands.sort((a, b) => a.luminance.compareTo(b.luminance));
    return bands.take(4).toList();
  }
}

class _LineBand {
  final int rowIndex;
  final double luminance;

  const _LineBand({required this.rowIndex, required this.luminance});
}
