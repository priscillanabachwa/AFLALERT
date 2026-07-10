// ml_service.dart

abstract class MyMlService {
  void initialize();
  void predict(dynamic input);
  Future<Map<String, dynamic>?> classifyMaize(String filePath);
}

// This factory trick dynamically swaps out the implementation at runtime
MyMlService getMlService() => throw UnsupportedError('Cannot create service');

class NotMaizeException implements Exception {
  const NotMaizeException();
}





