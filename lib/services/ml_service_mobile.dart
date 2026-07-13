// ml_service_mobile.dart
import 'package:tflite_flutter/tflite_flutter.dart';
import 'ml_service.dart';
import 'tflite_service.dart';
class MobileMlService implements MyMlService {
  late Interpreter _interpreter;
  final TfliteService _tfliteService = TfliteService();
  @override
  void initialize() async {
    _interpreter = await Interpreter.fromAsset('model.tflite');
  }

  @override
  void predict(dynamic input) {
  }

  @override
  Future<Map<String, dynamic>?> classifyMaize(String filePath) async {
    
    return await _tfliteService.classifyMaize(filePath);
  }
}

// Return the mobile service
MyMlService getMlService() => MobileMlService();