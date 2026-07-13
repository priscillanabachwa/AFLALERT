import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

// Thrown when the photo is rejected before/after inference because it
// doesn't look like maize — either its color palette doesn't resemble
// kernels/husks, or the model itself classified it as the "non_maize" class,
// or the model isn't confident in any class.
class NotMaizeException implements Exception {
  const NotMaizeException();
}

// Runs the bundled maize classification model (lib/assets/best.tflite)
// entirely on-device. The model is an Ultralytics/YOLOv8 classification
// export: input [1, 3, 224, 224] float32 (NCHW, values scaled to 0-1),
// output [1, 3] float32 already softmaxed. Class folders were fed to
// training in alphabetical order (Ultralytics' default), so the output
// indices are: 0 = "healthy", 1 = "moldy" (aflatoxin risk), 2 = "non_maize"
// (confirmed against the training export; there is no embedded label
// metadata to read this from).
class TfliteService {
  static const int _inputSize = 224;
  static const String _modelAsset = 'lib/assets/best.tflite';
  static const int _numClasses = 3;
  static const int _moldyIndex = 1;
  static const int _nonMaizeIndex = 2;

  // Fraction of sampled pixels that must fall within the maize color
  // palette (yellow/tan/brown/green kernels and husks, or pale/cream
  // kernels) before we even bother running inference.
  static const double _minMaizeColorRatio = 0.35;

  // The model always picks a side even on unrelated photos, so a low top
  // probability is itself a signal the input isn't something it recognizes.
  static const double _minConfidence = 0.6;

  static final TfliteService _instance = TfliteService._internal();
  factory TfliteService() => _instance;
  TfliteService._internal();

  Interpreter? _interpreter;

  Future<void> _ensureLoaded() async {
    _interpreter ??= await Interpreter.fromAsset(_modelAsset);
  }

  /// Classifies [imageFile] and returns a map compatible with the app's
  /// existing analysis pipeline, or null if inference fails.
  ///
  /// Throws [NotMaizeException] if the photo doesn't look like maize — the
  /// caller should show a distinct "take a photo of maize" message rather
  /// than a generic failure in that case.
  Future<Map<String, dynamic>?> classifyMaize(File imageFile) async {
    await _ensureLoaded();
    final interpreter = _interpreter!;

    final bytes = await imageFile.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return null;

    if (!_looksLikeMaize(decoded)) {
      throw const NotMaizeException();
    }

    try {
      // Resize the shorter side to fit then center-crop to a square, instead
      // of squashing the whole frame into a square. This mirrors Ultralytics'
      // classify_transforms (Resize + CenterCrop) used during training/
      // validation — a plain squash-resize distorts kernel shape/spacing in
      // ways the model never saw, which hurts real-world accuracy even when
      // validation accuracy looks great.
      final resized = img.copyResizeCropSquare(
        decoded,
        size: _inputSize,
        interpolation: img.Interpolation.linear,
      );

      final input = Float32List(1 * 3 * _inputSize * _inputSize);
      int i = 0;
      for (int c = 0; c < 3; c++) {
        for (int y = 0; y < _inputSize; y++) {
          for (int x = 0; x < _inputSize; x++) {
            final pixel = resized.getPixel(x, y);
            final num channelValue = c == 0 ? pixel.r : (c == 1 ? pixel.g : pixel.b);
            input[i++] = channelValue / 255.0;
          }
        }
      }

      final inputTensor = input.reshape([1, 3, _inputSize, _inputSize]);
      final output = [List<double>.filled(_numClasses, 0.0)];

      interpreter.run(inputTensor, output);

      final List<double> probs = output[0];
      int predictedIndex = 0;
      for (int c = 1; c < probs.length; c++) {
        if (probs[c] > probs[predictedIndex]) predictedIndex = c;
      }
      final double confidence = probs[predictedIndex];

      if (predictedIndex == _nonMaizeIndex || confidence < _minConfidence) {
        throw const NotMaizeException();
      }

      final bool isMoldy = predictedIndex == _moldyIndex;

      return {
        'label': isMoldy ? 'Aflatoxin contamination detected' : 'Healthy — no mold detected',
        'confidence': confidence,
        'mold_detected': isMoldy,
      };
    } on NotMaizeException {
      rethrow;
    } catch (_) {
      return null;
    }
  }

  /// Quick color-palette sanity check run before inference: maize kernels
  /// and husks are yellow, cream, tan/brown, or green. Photos dominated by
  /// other colors (skin tones vary, but portraits/scenes/objects usually
  /// pull in blues, strong reds, or near-black/white regions maize doesn't
  /// have) are rejected without wasting a model run — and more importantly,
  /// without producing a confident-but-meaningless "healthy"/"moldy" label.
  bool _looksLikeMaize(img.Image image) {
    final int stepX = (image.width / 64).ceil().clamp(1, 100);
    final int stepY = (image.height / 64).ceil().clamp(1, 100);

    int sampled = 0;
    int maizeLike = 0;

    for (int y = 0; y < image.height; y += stepY) {
      for (int x = 0; x < image.width; x += stepX) {
        final pixel = image.getPixel(x, y);
        final double r = pixel.r / 255.0;
        final double g = pixel.g / 255.0;
        final double b = pixel.b / 255.0;

        final double maxC = r > g ? (r > b ? r : b) : (g > b ? g : b);
        final double minC = r < g ? (r < b ? r : b) : (g < b ? g : b);
        final double value = maxC;
        final double delta = maxC - minC;
        final double saturation = maxC == 0 ? 0.0 : delta / maxC;

        double hue = 0;
        if (delta != 0) {
          if (maxC == r) {
            hue = 60 * (((g - b) / delta) % 6);
          } else if (maxC == g) {
            hue = 60 * (((b - r) / delta) + 2);
          } else {
            hue = 60 * (((r - g) / delta) + 4);
          }
          if (hue < 0) hue += 360;
        }

        sampled++;

        // Yellow/olive/brown/green hues with visible color (ripe kernels,
        // dried husks, green husk leaves) ...
        final bool colorfulMaizeHue =
            saturation >= 0.12 && hue >= 15 && hue <= 100 && value >= 0.15 && value <= 0.95;
        // ... or pale/cream kernels (low saturation, bright but not blown out).
        final bool creamKernel = saturation < 0.12 && value >= 0.55 && value <= 0.98;

        if (colorfulMaizeHue || creamKernel) {
          maizeLike++;
        }
      }
    }

    if (sampled == 0) return false;
    return (maizeLike / sampled) >= _minMaizeColorRatio;
  }
}
