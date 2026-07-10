// ml_service_web.dart
import 'ml_service.dart';

class WebMlService implements MyMlService {
  @override
  void initialize() {
    print("ML not supported natively on web or uses a Web alternative");
  }

  @override
  void predict(dynamic input) {
    // Provide a placeholder response or call a web-safe REST API instead
  }

  
  @override
  Future<Map<String, dynamic>?> classifyMaize(String filePath) async {
    print("TensorFlow Lite is not directly supported on the Web platform.");
    
    // Return a mock map so your UI doesn't crash on the web browser
    return {
      'result': 'Web Placeholder',
      'confidence': 0.0,
      'message': 'Image analysis is only supported when running on a mobile device.'
    };
  }

}

MyMlService getMlService() => WebMlService();
// Return the web service

