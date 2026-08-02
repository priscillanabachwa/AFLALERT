// strip_camera_screen.dart
//
// AflAlert — Tier 2 chemical strip capture screen.
//
// Structurally a trimmed copy of camera_screen.dart's capture flow
// (CameraController + gallery fallback + tap-to-focus + flash + quality
// pills + retake/use-photo review), adapted for a tall rectangular strip
// cassette instead of a square crop sample. Maize-only for now.

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import '../constants/app_colors.dart';
import '../l10n/app_localizations.dart';

enum StripCropType { maize }

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
  static const warn = Color(0xFFFAC775);
  static const warnText = Color(0xFFFAEEDA);
  static const danger = Color(0xFFF09595);
  static const dangerText = Color(0xFFF7C1C1);
  static const amberCta = Color(0xFFFAC775);
  static const amberCtaText = Color(0xFF412402);
}

enum _LightQuality { good, low }

enum _FocusQuality { adjusting, sharp, blurry }

Future<File> cropImageToViewfinderRect(
  File imageFile, {
  required Size previewSize,
  required Size frameSize,
  int maxWidth = 720,
}) async {
  final bytes = await imageFile.readAsBytes();
  final rawDecoded = img.decodeImage(bytes);
  if (rawDecoded == null) {
    return imageFile;
  }
  final decoded = img.bakeOrientation(rawDecoded);

  if (previewSize.width <= 0 || previewSize.height <= 0) {
    return imageFile;
  }

  final scaleX = decoded.width / previewSize.width;
  final scaleY = decoded.height / previewSize.height;
  final width = (frameSize.width * scaleX).round().clamp(1, decoded.width);
  final height = (frameSize.height * scaleY).round().clamp(1, decoded.height);
  final x = ((decoded.width - width) ~/ 2).clamp(0, decoded.width - width);
  final y = ((decoded.height - height) ~/ 2).clamp(0, decoded.height - height);

  final cropped = img.copyCrop(decoded, x: x, y: y, width: width, height: height);
  final resized = cropped.width > maxWidth
      ? img.copyResize(cropped, width: maxWidth)
      : cropped;

  final tempDir = await Directory.systemTemp.createTemp('aflalert_strip_crop');
  final outputPath =
      '${tempDir.path}/strip_${DateTime.now().microsecondsSinceEpoch}.jpg';
  final outputFile = File(outputPath);
  await outputFile.writeAsBytes(img.encodeJpg(resized, quality: 92));
  return outputFile;
}


class StripCameraScreen extends StatefulWidget {
  const StripCameraScreen({super.key});

  @override
  State<StripCameraScreen> createState() => _StripCameraScreenState();
}

class StripCaptureResult {
  final XFile photo;
  final StripCropType cropType;

  const StripCaptureResult({required this.photo, required this.cropType});
}

class _StripCameraScreenState extends State<StripCameraScreen> {
  static const Size _frameSize = Size(140, 320);

  final GlobalKey _previewBoxKey = GlobalKey();

  CameraController? _controller;
  Future<void>? _initFuture;

  bool _flashOn = false;
  final StripCropType _cropType = StripCropType.maize;
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
        const sampleStep = 97;
        int count = 0;
        for (int i = 0; i < yPlane.length; i += sampleStep) {
          sum += yPlane[i];
          count++;
        }
        final avgLuma = count == 0 ? 128 : sum / count;

        final newLight = avgLuma < 70 ? _LightQuality.low : _LightQuality.good;
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

    // Analysis assumes the strip fills the whole photo top-to-bottom (true
    // by construction for a camera capture, which is always cropped to the
    // viewfinder frame — see cropImageToViewfinderRect). A raw gallery pick
    // usually has the strip sitting in a larger scene, so it needs the same
    // crop before analysis can find the T/C lines at all.
    final File? cropped = await Navigator.push<File>(
      context,
      MaterialPageRoute(
        builder: (_) => _StripGalleryCropScreen(imageFile: File(picked.path)),
      ),
    );
    if (cropped == null || !mounted) return;
    final XFile croppedXFile = XFile(cropped.path);

    final result = await Navigator.push<_ReviewResult>(
      context,
      MaterialPageRoute(
        builder: (_) => _StripReviewScreen(
          imageFile: croppedXFile,
          lightGood: true,
          focusGood: true,
        ),
      ),
    );

    if (result == _ReviewResult.usePhoto && mounted) {
      Navigator.pop(
        context,
        StripCaptureResult(photo: croppedXFile, cropType: _cropType),
      );
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
          ? await cropImageToViewfinderRect(
              File(file.path),
              previewSize: previewBox.size,
              frameSize: _frameSize,
            )
          : File(file.path);
      final croppedXFile = XFile(croppedFile.path);
      if (!mounted) return;

      final result = await Navigator.push<_ReviewResult>(
        context,
        MaterialPageRoute(
          builder: (_) => _StripReviewScreen(
            imageFile: croppedXFile,
            lightGood: _light == _LightQuality.good,
            focusGood: _focus == _FocusQuality.sharp,
          ),
        ),
      );

      if (result == _ReviewResult.retake) {
        _startBrightnessMonitoring();
        _simulateFocusSettle();
      } else if (result == _ReviewResult.usePhoto && mounted) {
        Navigator.pop(
          context,
          StripCaptureResult(photo: croppedXFile, cropType: _cropType),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context)!.couldNotCapturePhoto('$e')),
          ),
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
              l10n.scanTestStrip,
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
          style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 10),
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
      top: 100,
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
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textColor),
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

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: _StripCameraScreenState._frameSize.width,
            height: _StripCameraScreenState._frameSize.height,
            child: CustomPaint(
              painter: _StripFramePainter(color: bracketColor),
              child: Stack(
                children: [
                  Positioned(
                    top: 8,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        'C',
                        style: TextStyle(
                          color: bracketColor.withValues(alpha: 0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        'T',
                        style: TextStyle(
                          color: bracketColor.withValues(alpha: 0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              _focus == _FocusQuality.blurry ? l10n.holdPhoneSteady : l10n.positionStripInFrame,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
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
                border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 4),
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

class _StripFramePainter extends CustomPainter {
  final Color color;
  _StripFramePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(10),
    );
    canvas.drawRRect(rrect, paint..color = color.withValues(alpha: 0.9));

    final dashPaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = 1.5;
    const dashWidth = 6.0;
    const gap = 5.0;
    double startX = 0;
    final y = size.height / 2;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, y),
        Offset((startX + dashWidth).clamp(0, size.width), y),
        dashPaint,
      );
      startX += dashWidth + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _StripFramePainter oldDelegate) =>
      oldDelegate.color != color;
}

// Lets the user pinch/pan a gallery-picked photo so the strip fills the
// frame edge to edge, same as the in-app camera capture guarantees via
// cropImageToViewfinderRect. Renders whatever is inside the frame overlay
// straight off the widget tree (via RenderRepaintBoundary) rather than
// computing a crop rect from the pan/zoom transform — simpler and avoids a
// whole class of matrix-math bugs.
class _StripGalleryCropScreen extends StatefulWidget {
  final File imageFile;

  const _StripGalleryCropScreen({required this.imageFile});

  @override
  State<_StripGalleryCropScreen> createState() =>
      _StripGalleryCropScreenState();
}

class _StripGalleryCropScreenState extends State<_StripGalleryCropScreen> {
  static const double _frameWidth = 220;
  static const double _frameHeight = _frameWidth * 320 / 140;
  // Matches the ~720px-wide output the camera-capture path already
  // produces, so both paths hand the analyzer comparably detailed photos.
  static const double _outputWidth = 720;

  final GlobalKey _boundaryKey = GlobalKey();
  bool _isCropping = false;

  Future<void> _confirmCrop() async {
    if (_isCropping) return;
    setState(() => _isCropping = true);

    try {
      final RenderRepaintBoundary boundary = _boundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      final ui.Image rendered = await boundary.toImage(
        pixelRatio: _outputWidth / _frameWidth,
      );
      final ByteData? pngBytes =
          await rendered.toByteData(format: ui.ImageByteFormat.png);
      rendered.dispose();
      if (pngBytes == null) {
        if (mounted) setState(() => _isCropping = false);
        return;
      }

      final img.Image? decoded =
          img.decodePng(pngBytes.buffer.asUint8List());
      if (decoded == null) {
        if (mounted) setState(() => _isCropping = false);
        return;
      }

      final tempDir =
          await Directory.systemTemp.createTemp('aflalert_strip_gallery_crop');
      final outputFile = File(
        '${tempDir.path}/strip_${DateTime.now().microsecondsSinceEpoch}.jpg',
      );
      await outputFile.writeAsBytes(img.encodeJpg(decoded, quality: 92));

      if (!mounted) return;
      Navigator.pop(context, outputFile);
    } catch (_) {
      if (mounted) setState(() => _isCropping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: _AflColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Text(
              l10n.cropStripPhotoTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                l10n.cropStripPhotoHint,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 12,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Container(
                  width: _frameWidth,
                  height: _frameHeight,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: RepaintBoundary(
                    key: _boundaryKey,
                    child: InteractiveViewer(
                      minScale: 1,
                      maxScale: 6,
                      boundaryMargin: EdgeInsets.zero,
                      child: SizedBox(
                        width: _frameWidth,
                        height: _frameHeight,
                        child: Image.file(widget.imageFile, fit: BoxFit.contain),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          _isCropping ? null : () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white, size: 16),
                      label:
                          Text(l10n.close, style: const TextStyle(color: Colors.white)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isCropping ? null : _confirmCrop,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: _AflColors.amberCta,
                        foregroundColor: _AflColors.amberCtaText,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: _isCropping
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _AflColors.amberCtaText,
                              ),
                            )
                          : Text(
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

enum _ReviewResult { retake, usePhoto }

class _StripReviewScreen extends StatelessWidget {
  final XFile imageFile;
  final bool lightGood;
  final bool focusGood;

  const _StripReviewScreen({
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
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: Container(
                  width: 200,
                  height: 320,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
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
                color: (allGood ? _AflColors.good : _AflColors.warn).withValues(alpha: 0.18),
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
                      color: allGood ? _AflColors.goodText : _AflColors.warnText,
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
                      onPressed: () => Navigator.pop(context, _ReviewResult.retake),
                      icon: const Icon(Icons.refresh, color: Colors.white, size: 16),
                      label: Text(l10n.retake, style: const TextStyle(color: Colors.white)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, _ReviewResult.usePhoto),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: _AflColors.amberCta,
                        foregroundColor: _AflColors.amberCtaText,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(l10n.usePhoto, style: const TextStyle(fontWeight: FontWeight.w500)),
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
