import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../l10n/app_localizations.dart';

import '../widgets/custom_app_bar.dart';
import '../widgets/ai_animation.dart';
import '../widgets/progress_section.dart';
import 'strip_camera_screen.dart';
import 'strip_result_screen.dart';
import '../services/firebase_storage.dart';
import '../services/firestore_service.dart';
import '../services/strip_analysis_service.dart';

class StripAnalysisScreenArgs {
  final XFile photo;
  final StripCropType cropType;
  final String? location;

  const StripAnalysisScreenArgs({
    required this.photo,
    required this.cropType,
    this.location,
  });
}

class StripAnalysisScreen extends StatefulWidget {
  const StripAnalysisScreen({super.key});

  @override
  State<StripAnalysisScreen> createState() => _StripAnalysisScreenState();
}

class _StripAnalysisScreenState extends State<StripAnalysisScreen> {
  bool _isProcessing = true;
  String? _errorMessage;
  bool _started = false;
  StripAnalysisScreenArgs? _args;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;

    final Object? args = ModalRoute.of(context)?.settings.arguments;
    if (args is StripAnalysisScreenArgs) {
      _args = args;
      _runAnalysis(args);
    } else {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _retakeAndAnalyze() async {
    final Object? result = await Navigator.of(context).pushNamed('/stripCamera');
    if (result is! StripCaptureResult || !mounted) return;

    final StripAnalysisScreenArgs newArgs = StripAnalysisScreenArgs(
      photo: result.photo,
      cropType: result.cropType,
      location: _args?.location,
    );
    setState(() {
      _args = newArgs;
      _isProcessing = true;
      _errorMessage = null;
    });
    _runAnalysis(newArgs);
  }

  Future<void> _runAnalysis(StripAnalysisScreenArgs args) async {
    try {
      final results = await Future.wait([
        _analyzeStrip(args),
        Future.delayed(const Duration(milliseconds: 1400)),
      ]);
      final resultsArgs = results[0] as StripResultsScreenArgs?;

      if (!mounted) return;
      final AppLocalizations l10n = AppLocalizations.of(context)!;
      if (resultsArgs == null) {
        setState(() {
          _isProcessing = false;
          _errorMessage = l10n.couldNotAnalyzePhoto;
        });
        return;
      }
      Navigator.pushReplacementNamed(context, '/stripResults', arguments: resultsArgs);
    } on InvalidStripException catch (e) {
      if (!mounted) return;
      final AppLocalizations l10n = AppLocalizations.of(context)!;
      setState(() {
        _isProcessing = false;
        _errorMessage = switch (e.reason) {
          InvalidStripReason.stripNotDetected => l10n.stripNotDetectedMessage,
          InvalidStripReason.controlLineNotDetected =>
            l10n.controlLineNotDetectedMessage,
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

  Future<StripResultsScreenArgs?> _analyzeStrip(
    StripAnalysisScreenArgs args,
  ) async {
    final File photoFile = File(args.photo.path);

    final StripAnalysisResult analysis =
        await StripAnalysisService().analyzeStripBytes(await photoFile.readAsBytes());

    final String? imageUrl = await StorageService().uploadStripImage(photoFile);
    await FirestoreService().saveStripScanRecord(
      imageUrl: imageUrl ?? '',
      cropType: args.cropType.name,
      ppbValue: analysis.ppbValue,
      tLineOD: analysis.tLineOD,
      cLineOD: analysis.cLineOD,
      odRatio: analysis.odRatio,
      safeLimitPpb: analysis.safeLimitPpb,
      location: args.location,
    );

    return StripResultsScreenArgs(
      ppbValue: analysis.ppbValue,
      tLineOD: analysis.tLineOD,
      cLineOD: analysis.cLineOD,
      odRatio: analysis.odRatio,
      safeLimitPpb: analysis.safeLimitPpb,
      cropType: args.cropType,
      imagePath: photoFile.path,
      location: args.location,
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
          l10n.analyzingStripTitle,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.readingTestControlLines,
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
          _errorMessage ?? l10n.scanTestStripHint,
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
