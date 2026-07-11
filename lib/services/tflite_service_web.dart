import 'dart:typed_data';

class NotMaizeException implements Exception {
  const NotMaizeException();
}

/// Web stub: tflite_flutter and dart:ffi are not available on the web, so
/// return `null` to indicate analysis is unavailable in browser builds.
class TfliteService {
  static final TfliteService _instance = TfliteService._internal();
  factory TfliteService() => _instance;
  TfliteService._internal();

  Future<Map<String, dynamic>?> classifyMaize(dynamic imageFile) async {
    // Analysis isn't supported in the browser build.
    return null;
  }

  Future<Map<String, dynamic>?> classifyMaizeFromBytes(Uint8List bytes) async {
    // Analysis isn't supported in the browser build.
    return null;
  }
}
