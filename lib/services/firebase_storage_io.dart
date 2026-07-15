import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadMaizeImage(File file) async {
    if (!await file.exists()) {
      debugPrint('StorageService Error: The local file does not exist.');
      return null;
    }

    try {
      String uniqueFileName =
          'maize_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference destinationRef = _storage.ref().child(
        'maize_images/$uniqueFileName',
      );
      SettableMetadata metadata = SettableMetadata(contentType: 'image/jpeg');
      UploadTask uploadTask = destinationRef.putFile(file, metadata);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (firebaseError) {
      debugPrint(
        'Firebase Storage specific error occurred: ${firebaseError.code} - ${firebaseError.message}',
      );
      return null;
    } catch (genericError) {
      debugPrint(
        'An unexpected error occurred during image upload: $genericError',
      );
      return null;
    }
  }

  Future<String?> uploadMaizeImageFromBytes(Uint8List bytes) async {
    try {
      String uniqueFileName =
          'maize_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference destinationRef = _storage.ref().child(
        'maize_images/$uniqueFileName',
      );
      SettableMetadata metadata = SettableMetadata(contentType: 'image/jpeg');
      UploadTask uploadTask = destinationRef.putData(bytes, metadata);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Upload from bytes failed: $e');
      return null;
    }
  }
}
