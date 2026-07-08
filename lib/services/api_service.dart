import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Replace this base URL with your local machine's IP (e.g., 'http://10.0.2.2:8000') 
  // during development or your live deployed hosting domain (e.g., Render/Heroku)
  final String _baseUrl = 'https://your-ml-api-domain.com/api';

  /// Sends the uploaded maize image URL to the machine learning endpoint for diagnostic processing.
  /// Returns a Map containing the prediction results, or [null] if the request fails.
  Future<Map<String, dynamic>?> analyzeMaizeImage(String imageUrl) async {
    final Uri url = Uri.parse('$_baseUrl/classify-maize/');

    try {
      // 1. Fire a secure POST request matching standard JSON formatting requirements
      final http.Response response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'image_url': imageUrl,
        }),
      ).timeout(const Duration(seconds: 15)); // Prevents the app hanging indefinitely on bad network connections

      // 2. Evaluate if the backend returned a successful 200/201 HTTP status code
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        debugPrint('ApiService: Diagnostic data received successfully: $responseData');
        return responseData;
      } else {
        debugPrint('ApiService Failure: Server returned status code ${response.statusCode}');
        return null;
      }
    } catch (error) {
      debugPrint('ApiService Error during model prediction connection: $error');
      return null;
    }
  }
}