import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  // Create a single, reusable reference to the Firebase Storage instance
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads a raw maize image file to Firebase Storage.
  /// 
  /// Returns the secure, permanent [String] download URL if successful.
  /// Returns [null] if the upload fails or is canceled.
  Future<String?> uploadMaizeImage(File file) async {
    // 1. Edge case check: Ensure the file actually exists on the device before proceeding
    if (!await file.exists()) {
      debugPrint('StorageService Error: The local file does not exist.');
      return null;
    }

    try {
      // 2. Generate a completely unique file name using a timestamp.
      // This prevents User B from overwriting User A's file if they happen to name it the same thing.
      String uniqueFileName = 'maize_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // 3. Define the storage location pathway bucket.
      // This creates a virtual folder named 'maize_images' at the root of your Firebase console.
      Reference destinationRef = _storage.ref().child('maize_images/$uniqueFileName');

      // 4. Configure metadata (Optional but highly recommended)
      // This explicitly tells the cloud browser/database that it's looking at a JPEG image.
      SettableMetadata metadata = SettableMetadata(contentType: 'image/jpeg');

      // 5. Start the upload task execution
      UploadTask uploadTask = destinationRef.putFile(file, metadata);

      // --- Optional: Listen to upload progress here if needed later ---
      // uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      //   double progress = 100.0 * (snapshot.bytesTransferred / snapshot.totalBytes);
      //   debugPrint('Upload progress: $progress%');
      // });

      // 6. Await completion of the upload task execution
      TaskSnapshot snapshot = await uploadTask;

      // 7. Request the secure, public HTTPS download link from the finalized storage reference
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      debugPrint('StorageService Success: File uploaded to path: ${snapshot.ref.fullPath}');
      debugPrint('StorageService Success: Public URL obtained: $downloadUrl');

      return downloadUrl;

    } on FirebaseException catch (firebaseError) {
      // Catch specific Firebase issues (e.g., Permission Denied, Quota Exceeded)
      debugPrint('Firebase Storage specific error occurred: ${firebaseError.code} - ${firebaseError.message}');
      return null;
    } catch (genericError) {
      // Catch any other standard Dart/system errors (e.g., out of memory, unexpected disruptions)
      debugPrint('An unexpected error occurred during image upload: $genericError');
      return null;
    }
  }

  /// Uploads a user's profile picture, keyed by [uid] so re-uploading
  /// replaces the previous picture instead of leaving orphaned files behind.
  ///
  /// Returns the secure, permanent download URL if successful, or [null].
  Future<String?> uploadProfileImage(File file, String uid) async {
    if (!await file.exists()) {
      debugPrint('StorageService Error: The local file does not exist.');
      return null;
    }

    try {
      Reference destinationRef = _storage.ref().child('profile_images/$uid.jpg');
      SettableMetadata metadata = SettableMetadata(contentType: 'image/jpeg');

      UploadTask uploadTask = destinationRef.putFile(file, metadata);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      debugPrint('StorageService Success: Profile image uploaded to path: ${snapshot.ref.fullPath}');
      return downloadUrl;
    } on FirebaseException catch (firebaseError) {
      debugPrint('Firebase Storage specific error occurred: ${firebaseError.code} - ${firebaseError.message}');
      return null;
    } catch (genericError) {
      debugPrint('An unexpected error occurred during profile image upload: $genericError');
      return null;
    }
  }
}
