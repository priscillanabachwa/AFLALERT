import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  // Create a reference to the firebase storage instance
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads a maize image to Firebase Storage and returns its secure download URL.
  Future<String?> uploadMaizeImage(File file) async {
    try {
      // 1. Create a unique filename using the current timestamp
      String fileName = 'maize_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // 2. Point to the destination path in your Storage bucket (e.g., a folder named 'maize_images')
      Reference ref = _storage.ref().child('maize_images/$fileName');

      // 3. Start the upload task
      UploadTask uploadTask = ref.putFile(file);

      // 4. Wait until the upload completes entirely
      TaskSnapshot snapshot = await uploadTask;

      // 5. Retrieve and return the permanent download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
      
    } catch (e) {
      print('Error uploading to Firebase Storage: $e');
      return null;
    }
  }
}