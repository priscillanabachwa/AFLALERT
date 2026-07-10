import 'dart:io';

import 'package:aflalert/screens/camera_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  test('crops a photo to a centered square frame', () async {
    final sourceImage = img.Image(width: 400, height: 300);
    for (int y = 0; y < sourceImage.height; y++) {
      for (int x = 0; x < sourceImage.width; x++) {
        sourceImage.setPixelRgb(x, y, x, y, 255);
      }
    }

    final tempDir = await Directory.systemTemp.createTemp('camera_crop_test');
    final sourceFile = File('${tempDir.path}/source.png');
    await sourceFile.writeAsBytes(img.encodePng(sourceImage));

    final croppedFile = await cropImageToSquareFrame(sourceFile, maxDimension: 200);
    final decoded = img.decodeImage(await croppedFile.readAsBytes())!;

    expect(decoded.width, 200);
    expect(decoded.height, 200);

    await tempDir.delete(recursive: true);
  });
}
