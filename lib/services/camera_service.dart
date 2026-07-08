import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class CameraService {
  // Instantiate the ImagePicker instance
  final ImagePicker _picker = ImagePicker();

  /// Opens the device camera to take a fresh photo of the maize.
  /// Returns a [File] if successful, or [null] if the user backed out.
  Future<File?> snapMaizePhoto() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85, // Compresses the image slightly to save bandwidth on uploads
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      debugPrint('CameraService: User canceled taking a photo.');
      return null;
    } catch (e) {
      debugPrint('CameraService Error capturing photo: $e');
      return null;
    }
  }

  /// Opens the device gallery for the user to select an existing maize image.
  /// Returns a [File] if successful, or [null] if canceled.
  Future<File?> pickMaizeFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      debugPrint('CameraService: User canceled gallery selection.');
      return null;
    } catch (e) {
      debugPrint('CameraService Error picking gallery image: $e');
      return null;
    }
  }
}