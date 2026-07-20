import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../l10n/app_localizations.dart';

import '../widgets/custom_app_bar.dart';
import '../widgets/ai_animation.dart';
import '../widgets/progress_section.dart';
import 'result_screen.dart';
import '../services/firebase_storage.dart';
import '../services/firestore_service.dart';
import '../services/tflite_service.dart';

class AnalysisScreenArgs {
  final XFile photo;
  final String? location;

  const AnalysisScreenArgs({required this.photo, this.location});
}

class _MaizeAnalysis {
  final String label;
  final double confidencePercent;
  final bool isMoldy;

  const _MaizeAnalysis({
    required this.label,
    required this.confidencePercent,
    required this.isMoldy,
  });

  factory _MaizeAnalysis.fromResponse(Map<String, dynamic> data) {
    final String label =
        (data['label'] ?? data['prediction'] ?? data['result'] ?? 'Unknown')
            .toString();

    final num rawConfidence =
        (data['confidence'] ?? data['score'] ?? data['probability'] ?? 0) as num;
    final double confidencePercent =
        rawConfidence <= 1 ? rawConfidence * 100 : rawConfidence.toDouble();

    final dynamic moldFlag =
        data['mold_detected'] ?? data['aflatoxin_detected'] ?? data['is_moldy'];
    final bool isMoldy = moldFlag is bool
        ? moldFlag
        : RegExp(r'mold|aflatox|contamin|infect|positive', caseSensitive: false)
                .hasMatch(label) &&
            !RegExp(r'no mold|healthy|clean|safe|negative', caseSensitive: false)
                .hasMatch(label);

    return _MaizeAnalysis(
      label: label,
      confidencePercent: confidencePercent.clamp(0, 100),
      isMoldy: isMoldy,
    );
  }
}

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  bool _isProcessing = true;
  String? _errorMessage;
  bool _started = false;
  AnalysisScreenArgs? _args;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;

    final Object? args = ModalRoute.of(context)?.settings.arguments;
    if (args is AnalysisScreenArgs) {
      _args = args;
      _runAnalysis(args);
    } else {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _retakeAndAnalyze() async {
    final Object? photo = await Navigator.of(context).pushNamed('/camera');
    if (photo is! XFile || !mounted) return;

    final AnalysisScreenArgs newArgs =
        AnalysisScreenArgs(photo: photo, location: _args?.location);
    setState(() {
      _args = newArgs;
      _isProcessing = true;
      _errorMessage = null;
    });
    _runAnalysis(newArgs);
  }

  Future<void> _runAnalysis(AnalysisScreenArgs args) async {
    try {
      // Run the real work alongside a minimum delay so the processing
      // animation always gets a chance to play instead of flashing by.
      final results = await Future.wait([
        _analyzePhoto(args),
        Future.delayed(const Duration(milliseconds: 1400)),
      ]);
      final resultsArgs = results[0] as ResultsScreenArgs?;

      if (!mounted) return;
      final AppLocalizations l10n = AppLocalizations.of(context)!;
      if (resultsArgs == null) {
        setState(() {
          _isProcessing = false;
          _errorMessage = l10n.couldNotAnalyzePhoto;
        });
        return;
      }
      Navigator.pushReplacementNamed(context, '/results', arguments: resultsArgs);
    } on NotMaizeException catch (e) {
      if (!mounted) return;
      final AppLocalizations l10n = AppLocalizations.of(context)!;
      setState(() {
        _isProcessing = false;
        _errorMessage = switch (e.reason) {
          NotMaizeReason.colorMismatch => l10n.notMaizeColorMismatch,
          NotMaizeReason.modelRejected => l10n.notMaizeModelRejected,
          NotMaizeReason.lowConfidence => l10n.notMaizeLowConfidence,
        };
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _errorMessage = AppLocalizations.of(context)!.couldNotAnalyzePhoto;
      });
    }
  }

  Future<ResultsScreenArgs?> _analyzePhoto(AnalysisScreenArgs args) async {
    final File photoFile = File(args.photo.path);

    // Classification runs entirely on-device, so it doesn't depend on
    // network/storage availability.
    final Map<String, dynamic>? raw = await TfliteService().classifyMaize(photoFile);
    if (raw == null) return null;

    final _MaizeAnalysis analysis = _MaizeAnalysis.fromResponse(raw);

    // Best-effort: upload the photo and log the scan record. A failure here
    // shouldn't block showing the user their on-device diagnosis.
    final String? imageUrl = await StorageService().uploadMaizeImage(photoFile);
    final String? scanId = await FirestoreService().saveScanRecord(
      imageUrl: imageUrl ?? '',
      classificationLabel: analysis.label,
      confidenceScore: analysis.confidencePercent / 100,
      location: args.location,
    );

    return ResultsScreenArgs(
      isSafe: !analysis.isMoldy,
      confidence: analysis.confidencePercent / 100,
      analysisLabel: analysis.label,
      imagePath: photoFile.path,
      scanId: scanId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: CustomAppBar(),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFDFDFD),
              Color(0xFFF4F8F5),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background Glow
            Positioned(
              top: -120,
              left: -100,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: .05),
                ),
              ),
            ),
            Positioned(
              bottom: -120,
              right: -80,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFECE4B).withValues(alpha: .05),
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _isProcessing
                    ? _buildLoading(context)
                    : _buildFallback(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        const SizedBox(height: 20),
        const AIAnimation(),
        const SizedBox(height: 40),
        Text(
          l10n.analyzingImageTitle,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.aiDetectingMold,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        const ProgressSection(),
      ],
    );
  }

  Widget _buildFallback(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final bool isError = _errorMessage != null;

    return Column(
      children: [
        const SizedBox(height: 60),
        Icon(
          isError ? Icons.error_outline : Icons.search_off,
          size: 64,
          color: AppColors.grey,
        ),
        const SizedBox(height: 20),
        Text(
          isError ? l10n.analysisFailed : l10n.noScanResultFound,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _errorMessage ?? l10n.scanMaizeSampleHint,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.grey),
        ),
        const SizedBox(height: 28),
        ElevatedButton(
          onPressed: _retakeAndAnalyze,
          child: Text(isError ? l10n.tryAgain : l10n.scanASample),
        ),
      ],
    );
  }
}
