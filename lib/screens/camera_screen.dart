// camera_capture_screen.dart
//
// AflAlert — maize scan camera capture screen.
//
// Dependencies (add to pubspec.yaml):
//   camera: ^0.10.5+9
//
// Also add camera permissions:
//   iOS: NSCameraUsageDescription in ios/Runner/Info.plist
//   Android: <uses-permission android:name="android.permission.CAMERA"/>
//            in android/app/src/main/AndroidManifest.xml
//
// Usage:
//   final XFile? photo = await Navigator.push(
//     context,
//     MaterialPageRoute(builder: (_) => const CameraCaptureScreen()),
//   );
//   if (photo != null) {
//     // photo.path -> send to your mold-detection model
//   }

import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import '../constants/app_colors.dart';
import '../l10n/app_localizations.dart';


class _AflColors {
  static const bg = Color(0xFF0D1410);

  static final good = HSLColor.fromColor(AppColors.primaryContainer)
      .withLightness(0.50)
      .withSaturation(0.55)
      .toColor();
  static final goodText = HSLColor.fromColor(AppColors.primaryContainer)
      .withLightness(0.92)
      .withSaturation(0.35)
      .toColor();
  static const warn = Color(0xFFFAC775); // amber ramp
  static const warnText = Color(0xFFFAEEDA);
  static const danger = Color(0xFFF09595); // red ramp
  static const dangerText = Color(0xFFF7C1C1);
  static const amberCta = Color(0xFFFAC775);
  static const amberCtaText = Color(0xFF412402);
}

enum _LightQuality { good, low }

enum _FocusQuality { adjusting, sharp, blurry }

Future<File> cropImageToSquareFrame(File imageFile, {int maxDimension = 1080}) async {
  final bytes = await imageFile.readAsBytes();
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    return imageFile;
  }

  final side = decoded.width < decoded.height ? decoded.width : decoded.height;
  final x = (decoded.width - side) ~/ 2;
  final y = (decoded.height - side) ~/ 2;
  final cropped = img.copyCrop(decoded, x: x, y: y, width: side, height: side);
  final resized = img.copyResize(cropped, width: maxDimension, height: maxDimension);

  final tempDir = await Directory.systemTemp.createTemp('aflalert_crop');
  final outputPath = '${tempDir.path}/capture_${DateTime.now().microsecondsSinceEpoch}.jpg';
  final outputFile = File(outputPath);
  await outputFile.writeAsBytes(img.encodeJpg(resized, quality: 92));
  return outputFile;
}

// Crops the captured photo down to exactly the area covered by the on-screen
// guide frame, rather than a generic center square of the whole sensor image.
// [previewSize] is the rendered size (in logical pixels) of the live
// CameraPreview widget, and [frameSize] is the side length of the guide
// frame drawn on top of it — both share the same screen center, so the
// crop rectangle in raw image pixels is the frame's fraction of the preview,
// scaled up by the ratio between the full-resolution photo and the preview.
Future<File> cropImageToViewfinderFrame(
  File imageFile, {
  required Size previewSize,
  required double frameSize,
  int maxDimension = 1080,
}) async {
  final bytes = await imageFile.readAsBytes();
  final rawDecoded = img.decodeImage(bytes);
  if (rawDecoded == null) {
    return imageFile;
  }
  // Normalize pixel data to match the upright orientation the preview and
  // final photo are displayed in, so width/height line up with previewSize.
  final decoded = img.bakeOrientation(rawDecoded);

  final shortestSide =
      decoded.width < decoded.height ? decoded.width : decoded.height;
  if (previewSize.width <= 0 || previewSize.height <= 0) {
    return cropImageToSquareFrame(imageFile, maxDimension: maxDimension);
  }

  final scale = decoded.width / previewSize.width;
  final side = (frameSize * scale).round().clamp(1, shortestSide).toInt();
  final x = (decoded.width - side) ~/ 2;
  final y = (decoded.height - side) ~/ 2;
  final cropped = img.copyCrop(decoded, x: x, y: y, width: side, height: side);
  final resized = img.copyResize(cropped, width: maxDimension, height: maxDimension);

  final tempDir = await Directory.systemTemp.createTemp('aflalert_crop');
  final outputPath = '${tempDir.path}/capture_${DateTime.now().microsecondsSinceEpoch}.jpg';
  final outputFile = File(outputPath);
  await outputFile.writeAsBytes(img.encodeJpg(resized, quality: 92));
  return outputFile;
}

class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
  static const double _frameSize = 210;

  final GlobalKey _previewBoxKey = GlobalKey();

  CameraController? _controller;
  Future<void>? _initFuture;

  bool _flashOn = false;
  _LightQuality _light = _LightQuality.good;
  _FocusQuality _focus = _FocusQuality.adjusting;

  Timer? _focusSettleTimer;
  bool _brightnessMonitoringEnabled = false;
  bool _imageStreamOpen = false;
  Timer? _brightnessCycleTimer;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final backCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      backCamera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    _initFuture = _controller!.initialize().then((_) {
      if (!mounted) return;
      _startBrightnessMonitoring();
      _simulateFocusSettle();
      setState(() {});
    });
  }

  // Basic real-time lighting check: samples average luma from the camera's
  // Y-plane. Swap this out for a more sophisticated check if you have one.
  //
  // This deliberately keeps the image stream closed most of the time. Early
  // versions left startImageStream running continuously for as long as the
  // camera screen was open — the plugin marshals every full-resolution frame
  // (~30/s) across the platform channel regardless of whether the Dart side
  // does anything with it, so the longer the screen stayed open before a
  // capture, the more GC pressure built up and the janker the UI got. Instead
  // we open the stream just long enough to grab a single frame, close it
  // immediately, then wait before sampling again.
  void _startBrightnessMonitoring() {
    if (_controller == null || _brightnessMonitoringEnabled) return;
    _brightnessMonitoringEnabled = true;
    _sampleBrightnessOnce();
  }

  void _stopBrightnessMonitoring() {
    _brightnessMonitoringEnabled = false;
    _brightnessCycleTimer?.cancel();
    _brightnessCycleTimer = null;
    if (_imageStreamOpen) {
      _imageStreamOpen = false;
      _controller?.stopImageStream();
    }
  }

  void _sampleBrightnessOnce() {
    if (_controller == null || !mounted || !_brightnessMonitoringEnabled) {
      return;
    }

    _imageStreamOpen = true;
    _controller!.startImageStream((CameraImage image) async {
      _imageStreamOpen = false;
      await _controller?.stopImageStream();

      try {
        final yPlane = image.planes[0].bytes;
        int sum = 0;
        const sampleStep = 97; // sparse sampling keeps this cheap
        int count = 0;
        for (int i = 0; i < yPlane.length; i += sampleStep) {
          sum += yPlane[i];
          count++;
        }
        final avgLuma = count == 0 ? 128 : sum / count;

        final newLight =
            avgLuma < 70 ? _LightQuality.low : _LightQuality.good;
        if (newLight != _light && mounted) {
          setState(() => _light = newLight);
        }
      } catch (_) {
        // Ignore malformed frames.
      }

      if (mounted && _brightnessMonitoringEnabled) {
        _brightnessCycleTimer =
            Timer(const Duration(milliseconds: 400), _sampleBrightnessOnce);
      }
    });
  }

  // Placeholder focus-quality flow: shows "adjusting" briefly after camera
  // init or a tap-to-focus, then settles to "sharp". Replace with a real
  // sharpness estimate (e.g. edge/variance analysis or your model's signal)
  // if you need more than an autofocus-timing heuristic.
  void _simulateFocusSettle() {
    _focusSettleTimer?.cancel();
    setState(() => _focus = _FocusQuality.adjusting);
    _focusSettleTimer = Timer(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _focus = _FocusQuality.sharp);
    });
  }

  Future<void> _onTapToFocus(TapUpDetails details, BoxConstraints box) async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final x = details.localPosition.dx / box.maxWidth;
    final y = details.localPosition.dy / box.maxHeight;
    await _controller!.setFocusPoint(Offset(x, y));
    await _controller!.setExposurePoint(Offset(x, y));
    _simulateFocusSettle();
  }

  Future<void> _toggleFlash() async {
    if (_controller == null) return;
    final newMode = _flashOn ? FlashMode.off : FlashMode.torch;
    await _controller!.setFlashMode(newMode);
    setState(() => _flashOn = !_flashOn);
  }

  Future<void> _pickFromGallery() async {
    final XFile? picked =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null || !mounted) return;

    final croppedFile = await cropImageToSquareFrame(File(picked.path));
    final croppedPick = XFile(croppedFile.path);

    if (!mounted) return;

    final result = await Navigator.push<_ReviewResult>(
      context,
      MaterialPageRoute(
        builder: (_) => _ReviewScreen(
          imageFile: croppedPick,
          lightGood: true,
          focusGood: true,
        ),
      ),
    );

    if (result == _ReviewResult.usePhoto && mounted) {
      Navigator.pop(context, croppedPick);
    }
  }

  Future<void> _onCapture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_controller!.value.isTakingPicture) return;

    try {
      _stopBrightnessMonitoring();
      final XFile file = await _controller!.takePicture();
      if (!mounted) return;

      final previewBox =
          _previewBoxKey.currentContext?.findRenderObject() as RenderBox?;
      final File croppedFile = (previewBox != null && previewBox.hasSize)
          ? await cropImageToViewfinderFrame(
              File(file.path),
              previewSize: previewBox.size,
              frameSize: _frameSize,
            )
          : await cropImageToSquareFrame(File(file.path));
      final croppedXFile = XFile(croppedFile.path);
      if (!mounted) return;

      final result = await Navigator.push<_ReviewResult>(
        context,
        MaterialPageRoute(
          builder: (_) => _ReviewScreen(
            imageFile: croppedXFile,
            lightGood: _light == _LightQuality.good,
            focusGood: _focus == _FocusQuality.sharp,
          ),
        ),
      );

      if (result == _ReviewResult.retake) {
        // Resume live view for another attempt.
        _startBrightnessMonitoring();
        _simulateFocusSettle();
      } else if (result == _ReviewResult.usePhoto && mounted) {
        Navigator.pop(context, croppedXFile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.couldNotCapturePhoto('$e'))),
        );
      }
    }
  }

  @override
  void dispose() {
    _focusSettleTimer?.cancel();
    _stopBrightnessMonitoring();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AflColors.bg,
      body: SafeArea(
        child: FutureBuilder<void>(
          future: _initFuture,
          builder: (context, snapshot) {
            if (_controller == null ||
                snapshot.connectionState != ConnectionState.done ||
                !_controller!.value.isInitialized) {
              return Center(
                child: CircularProgressIndicator(color: _AflColors.good),
              );
            }
            return LayoutBuilder(
              builder: (context, constraints) => Stack(
                fit: StackFit.expand,
                children: [
                  Center(
                    child: GestureDetector(
                      key: _previewBoxKey,
                      onTapUp: (d) => _onTapToFocus(d, constraints),
                      child: CameraPreview(_controller!),
                    ),
                  ),
                  _buildTopBar(),
                  _buildQualityPills(),
                  _buildFrameAndGuidance(),
                  _buildBottomControls(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Positioned(
      top: 8,
      left: 8,
      right: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _iconButtonWithLabel(
            icon: Icons.close,
            label: l10n.close,
            onTap: () => Navigator.of(context).maybePop(),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              l10n.scanMaize,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          _iconButtonWithLabel(
            icon: _flashOn ? Icons.flash_on : Icons.flash_off,
            label: _flashOn ? l10n.flashOn : l10n.flashOff,
            onTap: _toggleFlash,
          ),
        ],
      ),
    );
  }

  Widget _iconButtonWithLabel({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(17),
          onTap: onTap,
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.65),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildQualityPills() {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final lightIsGood = _light == _LightQuality.good;
    final focusIsSharp = _focus == _FocusQuality.sharp;
    final focusIsAdjusting = _focus == _FocusQuality.adjusting;

    return Positioned(
      top: 78,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _qualityPill(
            icon: lightIsGood ? Icons.wb_sunny : Icons.wb_twilight,
            label: lightIsGood ? l10n.lightingGood : l10n.tooDark,
            good: lightIsGood,
            warn: false,
          ),
          const SizedBox(width: 8),
          _qualityPill(
            icon: Icons.center_focus_strong,
            label: focusIsAdjusting
                ? l10n.adjustingFocus
                : (focusIsSharp ? l10n.focusSharp : l10n.blurryHoldSteady),
            good: focusIsSharp,
            warn: focusIsAdjusting || !focusIsSharp,
          ),
        ],
      ),
    );
  }

  Widget _qualityPill({
    required IconData icon,
    required String label,
    required bool good,
    required bool warn,
  }) {
    final Color bg;
    final Color iconColor;
    final Color textColor;
    if (good) {
      bg = Colors.black.withValues(alpha: 0.5);
      iconColor = _AflColors.good;
      textColor = _AflColors.goodText;
    } else if (warn) {
      bg = _AflColors.warn.withValues(alpha: 0.18);
      iconColor = _AflColors.warn;
      textColor = _AflColors.warnText;
    } else {
      bg = _AflColors.danger.withValues(alpha: 0.18);
      iconColor = _AflColors.danger;
      textColor = _AflColors.dangerText;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrameAndGuidance() {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final bool allGood =
        _light == _LightQuality.good && _focus == _FocusQuality.sharp;
    final bracketColor = allGood ? Colors.white : _AflColors.danger;

    final String mainGuidance = _light == _LightQuality.low
        ? l10n.moveToBrighterArea
        : (_focus == _FocusQuality.blurry
            ? l10n.holdPhoneSteady
            : '');
    final String subGuidance = allGood
        ? l10n.holdPhone20cm
        : l10n.adjustFrameWillTurnWhite;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomPaint(
            size: const Size(_frameSize, _frameSize),
            painter: _CornerBracketsPainter(color: bracketColor),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                Text(
                  mainGuidance,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subGuidance,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 22,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: _pickFromGallery,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo, color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                AppLocalizations.of(context)!.gallery,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 10),
              ),
            ],
          ),
          const SizedBox(width: 30),
          InkWell(
            borderRadius: BorderRadius.circular(34),
            onTap: _onCapture,
            child: Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35),
                  width: 4,
                ),
              ),
            ),
          ),
          const SizedBox(width: 30),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class _CornerBracketsPainter extends CustomPainter {
  final Color color;
  _CornerBracketsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const r = 8.0; // corner radius
    const len = 36.0; // bracket arm length

    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(0, len)
        ..lineTo(0, r)
        ..quadraticBezierTo(0, 0, r, 0)
        ..lineTo(len, 0),
      paint,
    );
    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - len, 0)
        ..lineTo(size.width - r, 0)
        ..quadraticBezierTo(size.width, 0, size.width, r)
        ..lineTo(size.width, len),
      paint,
    );
    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(size.width, size.height - len)
        ..lineTo(size.width, size.height - r)
        ..quadraticBezierTo(
            size.width, size.height, size.width - r, size.height)
        ..lineTo(size.width - len, size.height),
      paint,
    );
    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(len, size.height)
        ..lineTo(r, size.height)
        ..quadraticBezierTo(0, size.height, 0, size.height - r)
        ..lineTo(0, size.height - len),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CornerBracketsPainter oldDelegate) =>
      oldDelegate.color != color;
}

// ---------------------------------------------------------------------------
// Review screen — shown after capture, with retake / use photo
// ---------------------------------------------------------------------------
enum _ReviewResult { retake, usePhoto }

class _ReviewScreen extends StatelessWidget {
  final XFile imageFile;
  final bool lightGood;
  final bool focusGood;

  const _ReviewScreen({
    required this.imageFile,
    required this.lightGood,
    required this.focusGood,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final bool allGood = lightGood && focusGood;
    final String qualityLabel = allGood
        ? l10n.sharpAndWellLit
        : (!lightGood ? l10n.photoMayBeTooDark : l10n.photoMayBeBlurry);

    return Scaffold(
      backgroundColor: _AflColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Text(
              l10n.reviewPhoto,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.file(File(imageFile.path), fit: BoxFit.cover),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: (allGood ? _AflColors.good : _AflColors.warn)
                    .withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: allGood ? _AflColors.good : _AflColors.warn,
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    allGood ? Icons.check : Icons.error_outline,
                    size: 14,
                    color: allGood ? _AflColors.good : _AflColors.warn,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    qualityLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: allGood
                          ? _AflColors.goodText
                          : _AflColors.warnText,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          Navigator.pop(context, _ReviewResult.retake),
                      icon: const Icon(Icons.refresh, color: Colors.white, size: 16),
                      label: Text(l10n.retake,
                          style: const TextStyle(color: Colors.white)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.pop(context, _ReviewResult.usePhoto),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: _AflColors.amberCta,
                        foregroundColor: _AflColors.amberCtaText,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        l10n.usePhoto,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
