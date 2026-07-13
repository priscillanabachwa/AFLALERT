import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show debugPrint;
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
// output [1, 3] float32 already softmaxed. Class folders were fed to
// training in alphabetical order (Ultralytics' default), so the output
// indices are: 0 = "healthy", 1 = "moldy" (aflatoxin risk), 2 = "non_maize"
// (confirmed against the training export; there is no embedded label
// metadata to read this from).
class TfliteService {
  static const int _inputSize = 224;
  static const int _numClasses = 3;
  static const int _moldyIndex = 1;
  static const int _nonMaizeIndex = 2;

  static const double _minMaizeColorRatio = 0.35;
  static const double _minConfidence = 0.6;

  static final TfliteService _instance = TfliteService._internal();
  factory TfliteService() => _instance;
  TfliteService._internal();

  Interpreter? _interpreter;
  bool _inputIsNchw = true; // detected at load time

  Future<void> _ensureLoaded() async {
    if (_interpreter != null) return;
    _interpreter = await Interpreter.fromAsset(_modelAsset);

    final inputShape = _interpreter!.getInputTensor(0).shape;
    final outputShape = _interpreter!.getOutputTensor(0).shape;
    debugPrint('TFLite input shape: $inputShape, output shape: $outputShape');

    // [1, 3, 224, 224] => NCHW; [1, 224, 224, 3] => NHWC
    _inputIsNchw = inputShape.length == 4 && inputShape[1] == 3;
  }

  Future<Map<String, dynamic>?> classifyMaize(File imageFile) async {
    await _ensureLoaded();
    final interpreter = _interpreter!;

    final bytes = await imageFile.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return null;

    // ---- Check 1: is it maize? (color gate) ----
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

      if (_inputIsNchw) {
        for (int c = 0; c < 3; c++) {
          for (int y = 0; y < _inputSize; y++) {
            for (int x = 0; x < _inputSize; x++) {
              final p = resized.getPixel(x, y);
              final num v = c == 0 ? p.r : (c == 1 ? p.g : p.b);
              input[i++] = v / 255.0;
            }
          }
        }
      } else {
        for (int y = 0; y < _inputSize; y++) {
          for (int x = 0; x < _inputSize; x++) {
            final p = resized.getPixel(x, y);
            input[i++] = p.r / 255.0;
            input[i++] = p.g / 255.0;
            input[i++] = p.b / 255.0;
          }
        }
      }

      final inputTensor = input.reshape([1, 3, _inputSize, _inputSize]);
      final output = [List<double>.filled(_numClasses, 0.0)];

      final output = [List<double>.filled(2, 0.0)];
      interpreter.run(inputTensor, output);


      List<double> probs = List<double>.from(output[0]);

      // If outputs are raw logits (don't sum to ~1), apply softmax.
      final double sum = probs[0] + probs[1];
      final bool looksLikeProbs =

      if (predictedIndex == _nonMaizeIndex || confidence < _minConfidence) {
        throw const NotMaizeException();
      }

      final bool isMoldy = predictedIndex == _moldyIndex;

      return {
        'label': isMoldy
            ? 'Aflatoxin contamination detected'
            : 'Healthy — no mold detected',
        'confidence': confidence,
      };
    } on NotMaizeException {
      rethrow;
    } catch (e) {
      debugPrint('TFLite inference failed: $e');
      return null;
    }
  }

  List<double> _softmax(List<double> logits) {
    final double maxLogit = logits.reduce(math.max);
    final exps = logits.map((v) => math.exp(v - maxLogit)).toList();
    final double sumExp = exps.reduce((a, b) => a + b);
    return exps.map((v) => v / sumExp).toList();
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

        final double maxC = math.max(r, math.max(g, b));
        final double minC = math.min(r, math.min(g, b));
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

        final bool colorfulMaizeHue = saturation >= 0.12 &&
            hue >= 15 &&
            hue <= 100 &&
            value >= 0.15 &&
            value <= 0.95;
        final bool creamKernel =
            saturation < 0.12 && value >= 0.55 && value <= 0.98;

        if (colorfulMaizeHue || creamKernel) {
          maizeLike++;
        }
      }
    }

    if (sampled == 0) return false;
    return (maizeLike / sampled) >= _minMaizeColorRatio;
  }
}