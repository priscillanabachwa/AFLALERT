import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// On web we don't accept `dart:io` File; prefer bytes upload.
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
      return null;
    }
  }

  // Keep a compatible signature for native-only callers; returns null on web.
  Future<String?> uploadMaizeImage(dynamic /* File */ file) async {
    return null;
  }
}
