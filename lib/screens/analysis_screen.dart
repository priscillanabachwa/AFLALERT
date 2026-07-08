import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

import '../widgets/custom_app_bar.dart';
import '../widgets/ai_animation.dart';
import '../widgets/progress_section.dart';
import '../widgets/custom_bottom_nav.dart';

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
  bool _showResult = false;

  @override
  void initState() {
    super.initState();
    // The scan result already arrived from the camera screen by the time we
    // get here — this delay just lets the processing animation play instead
    // of jumping straight to the result.
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _showResult = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Object? args = ModalRoute.of(context)?.settings.arguments;
    final Map<String, dynamic>? rawResult =
        args is Map<String, dynamic> ? args : null;

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
                child: !_showResult
                    ? _buildLoading()
                    : (rawResult == null
                        ? _buildNoResult(context)
                        : _buildResult(context, _MaizeAnalysis.fromResponse(rawResult))),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(),
    );
  }

  Widget _buildLoading() {
    return Column(
      children: const [
        SizedBox(height: 20),
        AIAnimation(),
        SizedBox(height: 40),
        Text(
          "Analyzing Image...",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 12),
        Text(
          "Our AI model is detecting visible mold associated with aflatoxin contamination.",
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 40),
        ProgressSection(),
      ],
    );
  }

  Widget _buildNoResult(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 60),
        Icon(Icons.search_off, size: 64, color: AppColors.grey),
        const SizedBox(height: 20),
        const Text(
          "No scan result found",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Scan a maize sample to see its diagnosis here.",
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.grey),
        ),
        const SizedBox(height: 28),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pushNamed('/camera'),
          child: const Text('Scan a sample'),
        ),
      ],
    );
  }

  Widget _buildResult(BuildContext context, _MaizeAnalysis result) {
    final Color statusColor =
        result.isMoldy ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32);
    final IconData statusIcon =
        result.isMoldy ? Icons.warning_amber_rounded : Icons.check_circle;
    final String statusHeadline =
        result.isMoldy ? 'Aflatoxin risk detected' : 'Looks healthy';

    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: statusColor.withValues(alpha: .1),
          ),
          child: Icon(statusIcon, size: 52, color: statusColor),
        ),
        const SizedBox(height: 20),
        Text(
          statusHeadline,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: statusColor,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          result.label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: AppColors.text),
        ),
        const SizedBox(height: 28),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.outline.withValues(alpha: .4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Confidence",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    "${result.confidencePercent.toStringAsFixed(0)}%",
                    style: const TextStyle(
                      color: Color(0xFF765B00),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: result.confidencePercent / 100,
                  minHeight: 14,
                  backgroundColor: const Color(0xFFE7E0EB),
                  valueColor: AlwaysStoppedAnimation(statusColor),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pushNamed('/camera'),
            child: const Text('Scan another sample'),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () =>
                Navigator.of(context).pushNamedAndRemoveUntil('/home', (r) => false),
            child: const Text('Back to home'),
          ),
        ),
      ],
    );
  }
}
