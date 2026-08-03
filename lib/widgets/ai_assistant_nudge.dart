import 'dart:async';

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// A brief, non-blocking reminder bubble that points at the voice assistant
/// entry point. Unlike [CoachMarkOverlay] it doesn't dim the screen or wait
/// for a tap — it fades in, sits for a few seconds, then fades itself out,
/// so it can safely resurface on every app open without blocking the UI.
class AiAssistantNudge extends StatefulWidget {
  final GlobalKey targetKey;
  final String message;
  final VoidCallback onFinished;
  final Duration visibleDuration;

  const AiAssistantNudge({
    super.key,
    required this.targetKey,
    required this.message,
    required this.onFinished,
    this.visibleDuration = const Duration(seconds: 4),
  });

  @override
  State<AiAssistantNudge> createState() => _AiAssistantNudgeState();
}

class _AiAssistantNudgeState extends State<AiAssistantNudge> {
  bool _visible = false;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    // Wait for the first real frame so the target has a laid-out RenderBox
    // to measure, then fade in.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _visible = true);
    });
    _hideTimer = Timer(widget.visibleDuration, () {
      if (!mounted) return;
      setState(() => _visible = false);
      Future.delayed(const Duration(milliseconds: 250), () {
        if (mounted) widget.onFinished();
      });
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  Rect? _targetRect() {
    final BuildContext? ctx = widget.targetKey.currentContext;
    if (ctx == null) return null;
    final RenderObject? renderObject = ctx.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return null;
    final Offset topLeft = renderObject.localToGlobal(Offset.zero);
    return topLeft & renderObject.size;
  }

  @override
  Widget build(BuildContext context) {
    final Rect? target = _targetRect();
    if (target == null) return const SizedBox.shrink();
    final Size screen = MediaQuery.of(context).size;

    return Positioned(
      right: screen.width - target.right,
      bottom: screen.height - target.top + 16,
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: _visible ? 1 : 0,
          duration: const Duration(milliseconds: 250),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 220),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              widget.message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                height: 1.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
