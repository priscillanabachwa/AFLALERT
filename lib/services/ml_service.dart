// ml_service.dart
import 'dart:io';

import 'package:aflalert/services/tflite_service.dart';

// Re-export so analysis_screen's existing
// `on NotMaizeException` catch matches the exact class TfliteService throws.
export 'package:aflalert/services/tflite_service.dart' show NotMaizeException;

abstract class MyMlService {
  void initialize() {}
  void predict(dynamic input) {}
  Future<Map<String, dynamic>?> classifyMaize(String filePath);
}

class _TfliteMlService implements MyMlService {
  @override
  void initialize() {}

  @override
  void predict(dynamic input) {}

  @override
  Future<Map<String, dynamic>?> classifyMaize(String filePath) {
    // Adapter: analysis_screen passes a String path;
    // TfliteService needs a File. NotMaizeException propagates untouched.
    return TfliteService().classifyMaize(File(filePath));
  }
}

MyMlService getMlService() => _TfliteMlService();