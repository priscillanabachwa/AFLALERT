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
import '../services/api_service.dart';
import '../services/firebase_storage.dart';
import '../services/firestore_service.dart';
import '../services/location_service.dart';

// ---------------------------------------------------------------------------
// Colors — matches the AflAlert dark theme
// ---------------------------------------------------------------------------
class _AflColors {
  static const bg = Color(0xFF0D1410);
  static const good = Color(0xFF97C459); // green ramp
  static const goodText = Color(0xFFEAF3DE);
  static const warn = Color(0xFFFAC775); // amber ramp
  static const warnText = Color(0xFFFAEEDA);
  static const danger = Color(0xFFF09595); // red ramp
  static const dangerText = Color(0xFFF7C1C1);
  static const amberCta = Color(0xFFFAC775);
  static const amberCtaText = Color(0xFF412402);
}

enum _LightQuality { good, low }

enum _FocusQuality { adjusting, sharp, blurry }

class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
  CameraController? _controller;
  Future<void>? _initFuture;

  bool _flashOn = false;
  _LightQuality _light = _LightQuality.good;
  _FocusQuality _focus = _FocusQuality.adjusting;

  Timer? _focusSettleTimer;
  bool _isStreamingForBrightness = false;

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
  void _startBrightnessMonitoring() {
    if (_controller == null || _isStreamingForBrightness) return;
    _isStreamingForBrightness = true;

    _controller!.startImageStream((CameraImage image) {
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
    // Hook up image_picker here if you want a gallery fallback:
    //   final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    //   if (picked != null && mounted) Navigator.pop(context, picked);
  }

  Future<void> _onCapture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_controller!.value.isTakingPicture) return;

    try {
      if (_isStreamingForBrightness) {
        await _controller!.stopImageStream();
        _isStreamingForBrightness = false;
      }
      final XFile file = await _controller!.takePicture();
      if (!mounted) return;

      final result = await Navigator.push<_ReviewResult>(
        context,
        MaterialPageRoute(
          builder: (_) => _ReviewScreen(
            imageFile: file,
            lightGood: _light == _LightQuality.good,
            focusGood: _focus == _FocusQuality.sharp,
          ),
        ),
      );

      if (result == _ReviewResult.retake) {
        // Resume live view for another attempt.
        _startBrightnessMonitoring();
        _simulateFocusSettle();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not capture photo: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _focusSettleTimer?.cancel();
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
              return const Center(
                child: CircularProgressIndicator(color: _AflColors.good),
              );
            }
            return LayoutBuilder(
              builder: (context, constraints) => Stack(
                fit: StackFit.expand,
                children: [
                  GestureDetector(
                    onTapUp: (d) => _onTapToFocus(d, constraints),
                    child: CameraPreview(_controller!),
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
            label: 'Close',
            onTap: () => Navigator.of(context).maybePop(),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text(
              'Scan maize',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          _iconButtonWithLabel(
            icon: _flashOn ? Icons.flash_on : Icons.flash_off,
            label: _flashOn ? 'Flash on' : 'Flash off',
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
            label: lightIsGood ? 'Lighting good' : 'Too dark',
            good: lightIsGood,
            warn: false,
          ),
          const SizedBox(width: 8),
          _qualityPill(
            icon: Icons.center_focus_strong,
            label: focusIsAdjusting
                ? 'Adjusting focus'
                : (focusIsSharp ? 'Focus sharp' : 'Blurry, hold steady'),
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
    final bool allGood =
        _light == _LightQuality.good && _focus == _FocusQuality.sharp;
    final bracketColor = allGood ? Colors.white : _AflColors.danger;

    final String mainGuidance = _light == _LightQuality.low
        ? 'Move to a brighter, well-lit area'
        : (_focus == _FocusQuality.blurry
            ? 'Hold the phone steady before capturing'
            : 'Spread the kernel(s) flat in the frame');
    final String subGuidance = allGood
        ? 'Hold phone about 20cm above the sample'
        : 'Adjust and the frame will turn white when ready';

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomPaint(
              size: const Size(210, 210),
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
                'Gallery',
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
enum _ReviewResult { retake }

class _ReviewScreen extends StatefulWidget {
  final XFile imageFile;
  final bool lightGood;
  final bool focusGood;

  const _ReviewScreen({
    required this.imageFile,
    required this.lightGood,
    required this.focusGood,
  });

  @override
  State<_ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<_ReviewScreen> {
  final StorageService _storageService = StorageService();
  final ApiService _apiService = ApiService();
  final FirestoreService _firestoreService = FirestoreService();
  final LocationService _locationService = LocationService();

  bool _isProcessing = false;

  Future<void> _useThisPhoto() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    // Kick off location resolution alongside the upload/analysis network
    // calls so it doesn't add extra wait time on top of them.
    final Future<String?> locationFuture = _locationService.getCurrentPlaceName();

    try {
      final String? imageUrl =
          await _storageService.uploadMaizeImage(File(widget.imageFile.path));
      if (imageUrl == null) {
        _showError('Failed to upload photo. Please try again.');
        return;
      }

      final Map<String, dynamic>? analysis =
          await _apiService.analyzeMaizeImage(imageUrl);
      if (analysis == null) {
        _showError('The AI engine failed to analyze this crop sample.');
        return;
      }

      // Best-effort history log — the diagnosis already succeeded, so a
      // logging failure (e.g. no signed-in user, no location fix) shouldn't
      // block the flow.
      final num confidenceRaw = (analysis['confidence'] ??
          analysis['score'] ??
          analysis['probability'] ??
          0) as num;
      final String? location = await locationFuture;
      await _firestoreService.saveScanRecord(
        imageUrl: imageUrl,
        classificationLabel:
            (analysis['label'] ?? analysis['prediction'] ?? analysis['result'] ?? 'Unknown')
                .toString(),
        confidenceScore: confidenceRaw.toDouble(),
        location: location,
      );

      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/analysis',
        ModalRoute.withName('/home'),
        arguments: analysis,
      );
    } catch (_) {
      _showError('An unexpected error occurred. Please try again.');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: _AflColors.danger),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool allGood = widget.lightGood && widget.focusGood;
    final String qualityLabel = allGood
        ? 'Sharp and well lit'
        : (!widget.lightGood ? 'Photo may be too dark' : 'Photo may be blurry');

    return Scaffold(
      backgroundColor: _AflColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            const Text(
              'Review photo',
              style: TextStyle(
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
                  child: Image.file(File(widget.imageFile.path), fit: BoxFit.cover),
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
                      onPressed: _isProcessing
                          ? null
                          : () => Navigator.pop(context, _ReviewResult.retake),
                      icon: const Icon(Icons.refresh, color: Colors.white, size: 16),
                      label: const Text('Retake',
                          style: TextStyle(color: Colors.white)),
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
                      onPressed: _isProcessing ? null : _useThisPhoto,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: _AflColors.amberCta,
                        foregroundColor: _AflColors.amberCtaText,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _AflColors.amberCtaText,
                              ),
                            )
                          : const Text(
                              'Use photo',
                              style: TextStyle(fontWeight: FontWeight.w500),
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
