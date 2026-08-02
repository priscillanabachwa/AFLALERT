import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute, debugPrint;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

enum NotMaizeReason { colorMismatch, modelRejected, lowConfidence }

class NotMaizeException implements Exception {
  final NotMaizeReason reason;
  const NotMaizeException(this.reason);
}

class TfliteService {
  static const int _inputSize = 224;
  static const String _modelAsset = 'lib/assets/best.tflite';
  static const int _numClasses = 3;
  static const int _moldyIndex = 1;
  static const int _nonMaizeIndex = 2;

  static const double _minMaizeColorRatio = 0.35;
  static const double _minConfidence = 0.6;

  static final TfliteService _instance = TfliteService._internal();
  factory TfliteService() => _instance;
  TfliteService._internal();

  Interpreter? _interpreter;

  Future<void> _ensureLoaded() async {
    _interpreter ??= await Interpreter.fromAsset(_modelAsset);
  }

  Future<Map<String, dynamic>?> classifyMaize(File imageFile) async {
    return classifyMaizeFromBytes(await imageFile.readAsBytes());
  }

  Future<Map<String, dynamic>?> classifyMaizeFromBytes(Uint8List bytes) async {
    await _ensureLoaded();
    final interpreter = _interpreter!;

    // Decoding the source photo (up to 1080x1080) and the maize-color and
    // tensor-building pixel loops are heavy enough to visibly stall the
    // analysis screen's animation if run inline on the UI isolate, so they
    // run on a worker isolate; only the native interpreter call stays here.
    final Float32List input;
    try {
      input = await compute(_prepareMaizeTensor, bytes);
    } on NotMaizeException {
      rethrow;
    } catch (_) {
      return null;
    }

    try {
      final inputTensor = input.reshape([1, 3, _inputSize, _inputSize]);
      final output = [List<double>.filled(_numClasses, 0.0)];

      interpreter.run(inputTensor, output);

      final List<double> probs = output[0];
      int predictedIndex = 0;
      for (int c = 1; c < probs.length; c++) {
        if (probs[c] > probs[predictedIndex]) predictedIndex = c;
      }
      final double confidence = probs[predictedIndex];

      if (predictedIndex == _nonMaizeIndex) {
        debugPrint('TfliteService: rejected as non-maize (probs=$probs)');
        throw const NotMaizeException(NotMaizeReason.modelRejected);
      }
      if (confidence < _minConfidence) {
        debugPrint('TfliteService: rejected for low confidence (probs=$probs)');
        throw const NotMaizeException(NotMaizeReason.lowConfidence);
      }

      final bool isMoldy = predictedIndex == _moldyIndex;

      return {
        'label': isMoldy
            ? 'Aflatoxin contamination detected'
            : 'Healthy ',
        'confidence': confidence,
        'mold_detected': isMoldy,
      };
    } on NotMaizeException {
      rethrow;
    } catch (_) {
      return null;
    }
  }

}

// Top-level so it can run on a background isolate via compute() — decoding
// the source photo and the per-pixel color/tensor loops below are heavy
// enough to visibly stall the UI isolate if run inline.
Float32List _prepareMaizeTensor(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    debugPrint('TfliteService: could not decode photo bytes');
    throw const NotMaizeException(NotMaizeReason.colorMismatch);
  }
  if (!_looksLikeMaize(decoded)) {
    debugPrint('TfliteService: rejected by color heuristic before the model ran');
    throw const NotMaizeException(NotMaizeReason.colorMismatch);
  }

  const int inputSize = TfliteService._inputSize;
  final resized = img.copyResize(decoded, width: inputSize, height: inputSize);

  final input = Float32List(1 * 3 * inputSize * inputSize);
  int i = 0;
  for (int c = 0; c < 3; c++) {
    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = resized.getPixel(x, y);
        final num channelValue = c == 0
            ? pixel.r
            : (c == 1 ? pixel.g : pixel.b);
        input[i++] = channelValue / 255.0;
      }
    }
  }
  return input;
}

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

      // Healthy raw maize: golden/yellow/orange kernels.
      final bool healthyHue =
          saturation >= 0.10 &&
          hue >= 0 &&
          hue <= 150 &&
          value >= 0.10 &&
          value <= 0.98;
      // Pale/whitish kernels, and pale gray mold — both healthy cream
      // kernels and gray/white fungal growth land in low-saturation,
      // low-to-mid value territory, so contaminated grain needs to pass
      // this too, not just the bright end a purely "healthy" check would
      // allow. Aflatoxin-contaminated kernels are duller, grayer, or
      // darker than a bright healthy kernel; without this wider band a
      // moldy sample gets rejected as "not maize" before the classifier
      // model ever sees it.
      final bool paleOrGrayKernel =
          saturation < 0.15 && value >= 0.10 && value <= 0.98;

      if (healthyHue || paleOrGrayKernel) {
        maizeLike++;
      }
    }
  }

  if (sampled == 0) return false;
  return (maizeLike / sampled) >= TfliteService._minMaizeColorRatio;
}
