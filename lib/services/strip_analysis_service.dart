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

import 'package:flutter/foundation.dart' show compute, debugPrint;
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
  // low-saturation ("pale") surface. But plenty of non-strip subjects
  // (walls, paper, skin, sky, tables) are just as pale, so this brightness
  // check alone can't tell them apart — it only serves as an early, cheap
  // rejection of clearly-wrong photos (dark/richly colored scenes) before
  // spending time on line detection. Actually distinguishing a strip from
  // another pale surface is left to the line-band thresholds below, which
  // is why those need to be strict rather than this ratio.
  static const double _paleBrightnessFloor = 0.55;
  static const double _paleSaturationCeiling = 0.28;
  static const double _minPaleRatio = 0.50;

  // A line band must be at least this much darker than its local
  // background to count as a real line rather than sensor/paper noise or
  // the soft shading/gradient of a blank pale surface (wall, paper, skin)
  // that isn't a strip at all. Pulled back down from 0.16 after that value
  // was found to reject real, correctly-run strip photos under everyday
  // (non-lab) lighting.
  static const double _minLineProminence = 0.12;
  // Candidate bands wider than this fraction of the strip are treated as
  // shadows/edges/objects rather than a printed line.
  static const double _maxBandWidthFraction = 0.22;
  // The control line must clear this absolute darkness (as a fraction of
  // local background luminance lost) to count as a valid, developed line —
  // a faint/missing C line means the strip run itself failed (standard
  // lateral-flow QC), not a low ppb reading. 0.22 (see git history) was too
  // strict in practice and flagged genuine control lines as missing on
  // real-world photos; 0.16 is still well above the noise floor of a
  // non-strip pale surface but leaves headroom for normal lighting/camera
  // variance on an actual developed line.
  static const double _minControlDarkness = 0.16;

  static final StripAnalysisService _instance =
      StripAnalysisService._internal();
  factory StripAnalysisService() => _instance;
  StripAnalysisService._internal();

  Future<StripAnalysisResult> analyzeStrip(File imageFile) async {
    return analyzeStripBytes(await imageFile.readAsBytes());
  }

  // Decoding the source photo and the row-by-row luminance/line-detection
  // loops below are heavy enough (especially on unresized gallery picks) to
  // visibly stall the analysis screen's animation if run inline on the UI
  // isolate, so the whole pipeline runs on a worker isolate via compute().
  Future<StripAnalysisResult> analyzeStripBytes(Uint8List bytes) {
    return compute(_analyzeStripSync, bytes);
  }

  static StripAnalysisResult _analyzeStripSync(Uint8List bytes) {
    final img.Image? decoded = img.decodeImage(bytes);
    if (decoded == null) {
      debugPrint('[StripAnalysis] decodeImage failed (${bytes.length} bytes)');
      throw const InvalidStripException(InvalidStripReason.stripNotDetected);
    }
    debugPrint('[StripAnalysis] decoded ${decoded.width}x${decoded.height}');

    final double paleRatio = _paleRatio(decoded);
    debugPrint(
      '[StripAnalysis] paleRatio=${paleRatio.toStringAsFixed(3)} '
      '(need >= $_minPaleRatio)',
    );
    if (paleRatio < _minPaleRatio) {
      throw const InvalidStripException(InvalidStripReason.stripNotDetected);
    }

    // The capture screen constrains the photo to a fixed portrait
    // orientation with the strip filling the frame top-to-bottom, so the
    // T/C lines run horizontally — average luminance row by row, sampling
    // only the central column band to avoid strip-edge glare/shadow.
    final List<double> profile = _rowLuminanceProfile(decoded);
    if (profile.length < 20) {
      debugPrint('[StripAnalysis] profile too short: ${profile.length}');
      throw const InvalidStripException(InvalidStripReason.stripNotDetected);
    }

    // A rolling-max envelope tracks the local background brightness even
    // where a line dips below it, so line strength is judged against the
    // membrane right around it rather than a single strip-wide value —
    // this keeps detection reliable under uneven lighting (a torch held to
    // one side, a shadow across part of the frame, etc.).
    final List<double> baseline = _localBaseline(profile);
    final List<_LineBand> bands = _findLineBands(profile, baseline);
    debugPrint(
      '[StripAnalysis] found ${bands.length} candidate band(s): '
      '${bands.map((b) => 'row=${b.rowIndex} lum=${b.luminance.toStringAsFixed(1)} bg=${b.baseline.toStringAsFixed(1)}').join(', ')}',
    );

    if (bands.length < 2) {
      throw const InvalidStripException(InvalidStripReason.stripNotDetected);
    }

    // Control line = the strongest (darkest) candidate, not just the
    // topmost one. A lateral-flow control line is designed to always
    // develop fully regardless of the test outcome, so on a validly-run
    // strip it's reliably the most prominent real line. Real strip photos
    // can register a faint extra "band" above the true C line (a
    // sample-pad/membrane seam, a shadow, a crease) that isn't ink at
    // all — taking the topmost candidate let that artifact stand in for
    // Control and bumped the real (strong) control line into the Test
    // slot, discarding the actual reading.
    bands.sort(
      (a, b) => (a.luminance / a.baseline).compareTo(b.luminance / b.baseline),
    );
    final _LineBand cBand = bands.first;

    // Test stays position-based: the capture guide places Control near the
    // top of the frame and Test near the bottom, so once Control is
    // pinned down, Test is whichever remaining candidate comes right after
    // it top-to-bottom (falling back to the closest remaining one if none
    // happen to sit below it).
    final List<_LineBand> others = bands.skip(1).toList()
      ..sort((a, b) => a.rowIndex.compareTo(b.rowIndex));
    final _LineBand tBand = others.firstWhere(
      (b) => b.rowIndex > cBand.rowIndex,
      orElse: () => others.first,
    );

    final double cLineOD = _opticalDensity(cBand.luminance, cBand.baseline);
    final double tLineOD = _opticalDensity(tBand.luminance, tBand.baseline);
    debugPrint(
      '[StripAnalysis] cLineOD=${cLineOD.toStringAsFixed(3)} '
      '(need >= $_minControlDarkness), tLineOD=${tLineOD.toStringAsFixed(3)}',
    );

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
  static double _ppbFromRatio(double odRatio) {
    final double fade = (1 - odRatio).clamp(0.0, 1.0);
    final double ppb = maxDetectionPpb * math.pow(fade, _ppbCurveGamma);
    return ppb.clamp(0.0, maxDetectionPpb);
  }

  static double _opticalDensity(double lineLuminance, double background) {
    if (background <= 0 || lineLuminance <= 0) return 0;
    final double ratio = (lineLuminance / background).clamp(0.001, 1.0);
    return math.max(0, -math.log(ratio) / math.ln10);
  }

  // Cheap plausibility gate run before line detection: a strip cassette and
  // its membrane are predominantly bright and low-saturation, so a photo
  // that's mostly dark and/or richly colored throughout is very unlikely
  // to actually be a test strip.
  static double _paleRatio(img.Image image) {
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

    if (sampled == 0) return 0;
    return paleCount / sampled;
  }

  static List<double> _rowLuminanceProfile(img.Image image) {
    // Sample almost the full width rather than assuming the strip sits
    // dead-center: a gallery crop is user-positioned (unlike the in-app
    // camera capture, which is centered by construction), and even a
    // modest horizontal offset would put a narrow fixed center column over
    // blank background next to the strip instead of the strip itself.
    final int margin = (image.width * 0.05).round();
    final int xStart = margin.clamp(0, image.width - 1);
    final int xEnd = (image.width - margin).clamp(xStart + 1, image.width - 1);

    final List<double> rowValues = [];
    final List<double> profile = List<double>.filled(image.height, 0);
    for (int y = 0; y < image.height; y++) {
      rowValues.clear();
      for (int x = xStart; x <= xEnd; x++) {
        final pixel = image.getPixel(x, y);
        // T/C lines on this strip type develop in red/magenta dye, which
        // barely touches the red channel — it mainly knocks down green and
        // blue. Standard luma (0.299R+0.587G+0.114B) still weights red
        // highly, so a line that looks bold to the eye can register as
        // only a shallow dip in luma and slip under the detection
        // threshold entirely. Green+blue average reacts far more strongly
        // to red/magenta ink while a pale membrane background (high on
        // all three channels) stays close to unchanged.
        rowValues.add(0.5 * pixel.g + 0.5 * pixel.b);
      }
      // Average the darkest ~20% of the row instead of the row mean: a
      // line — wherever it sits horizontally — is the darkest content in
      // its row, so this finds it regardless of the strip's horizontal
      // position, while still averaging over enough pixels to ignore
      // single-pixel sensor/compression noise.
      rowValues.sort();
      final int sampleCount = math.max(1, (rowValues.length * 0.2).round());
      double sum = 0;
      for (int i = 0; i < sampleCount; i++) {
        sum += rowValues[i];
      }
      profile[y] = sum / sampleCount;
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
  static List<double> _localBaseline(List<double> profile) {
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

  static List<_LineBand> _findLineBands(List<double> profile, List<double> baseline) {
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
        while (i < end && profile[i] <= baseline[i] * (1 - _minLineProminence)) {
          i++;
        }
        final int width = i - start;
        // Ignore hairline noise spikes and overly broad dark regions
        // (shadows, cassette edges, foreign objects).
        if (width >= 2 && width <= maxBandWidth) {
          // A real strip's C and T lines can sit close enough together
          // that the profile never rises back above threshold between
          // them (no fully-recovered background in the gap) — without
          // this, the whole span above would collapse into a single band
          // at just its darkest point, silently discarding the other
          // line entirely. Splitting on local minima recovers each line
          // separately instead.
          candidates.addAll(_splitIntoBands(profile, baseline, start, i));
        }
      } else {
        i++;
      }
    }

    // Strongest (darkest relative to local background) first, then drop
    // any candidate within a few rows of an already-kept, stronger
    // candidate — guards against the same physical line being split into
    // two adjacent detections by a momentary noise blip. This must stay
    // small: it's a duplicate-detection guard for one line, not a minimum
    // spacing between distinct C/T lines (which can legitimately sit far
    // closer together than maxBandWidth).
    candidates.sort(
      (a, b) => (a.luminance / a.baseline).compareTo(b.luminance / b.baseline),
    );
    final int dedupDistance = math.max(3, (n * 0.01).round());
    final List<_LineBand> kept = [];
    for (final candidate in candidates) {
      final bool tooClose = kept.any(
        (b) => (b.rowIndex - candidate.rowIndex).abs() < dedupDistance,
      );
      if (!tooClose) kept.add(candidate);
    }
    return kept.take(4).toList();
  }

  // Splits a contiguous below-threshold run [start, end) into one band per
  // local minimum, rather than reporting only the single darkest point in
  // the whole run. Minima within a couple of rows of each other are
  // collapsed to the deepest one (noise on what's really one line's dip);
  // anything further apart is treated as a genuinely separate line.
  static List<_LineBand> _splitIntoBands(
    List<double> profile,
    List<double> baseline,
    int start,
    int end,
  ) {
    final List<int> minima = [];
    for (int j = start; j < end; j++) {
      final double v = profile[j];
      final double prev = j > start ? profile[j - 1] : v;
      final double next = j < end - 1 ? profile[j + 1] : v;
      if (v <= prev && v <= next) {
        minima.add(j);
      }
    }

    if (minima.isEmpty) {
      final int mid = (start + end) ~/ 2;
      return [
        _LineBand(rowIndex: mid, luminance: profile[mid], baseline: baseline[mid]),
      ];
    }

    final List<int> merged = [];
    for (final idx in minima) {
      if (merged.isNotEmpty && idx - merged.last <= 3) {
        if (profile[idx] < profile[merged.last]) {
          merged[merged.length - 1] = idx;
        }
      } else {
        merged.add(idx);
      }
    }

    return merged
        .map(
          (idx) => _LineBand(
            rowIndex: idx,
            luminance: profile[idx],
            baseline: baseline[idx],
          ),
        )
        .toList();
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
