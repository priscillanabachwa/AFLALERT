import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

// Runs the bundled maize classification model (lib/assets/best.tflite)
// entirely on-device. The model is an Ultralytics/YOLOv8 classification
// export: input [1, 3, 224, 224] float32 (NCHW, values scaled to 0-1),
// output [1, 2] float32 already softmaxed — index 0 is "healthy", index 1
// is the "moldy / aflatoxin risk" class (confirmed against the training
// export; there is no embedded label metadata to read this from).
class TfliteService {
  static const int _inputSize = 224;
  static const String _modelAsset = 'lib/assets/best.tflite';

  static final TfliteService _instance = TfliteService._internal();
  factory TfliteService() => _instance;
  TfliteService._internal();

  Interpreter? _interpreter;

  Future<void> _ensureLoaded() async {
    _interpreter ??= await Interpreter.fromAsset(_modelAsset);
  }

  /// Classifies [imageFile] and returns a map compatible with the app's
  /// existing analysis pipeline, or null if inference fails.
  Future<Map<String, dynamic>?> classifyMaize(File imageFile) async {
    try {
      await _ensureLoaded();
      final interpreter = _interpreter!;

      final bytes = await imageFile.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return null;

      final resized = img.copyResize(
        decoded,
        width: _inputSize,
        height: _inputSize,
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
      final output = [List<double>.filled(2, 0.0)];

      interpreter.run(inputTensor, output);

      final double healthyProb = output[0][0];
      final double moldyProb = output[0][1];
      final bool isMoldy = moldyProb > healthyProb;
      final double confidence = isMoldy ? moldyProb : healthyProb;

      return {
        'label': isMoldy ? 'Aflatoxin contamination detected' : 'Healthy — no mold detected',
        'confidence': confidence,
        'mold_detected': isMoldy,
      };
    } catch (_) {
      return null;
    }
  }
}
