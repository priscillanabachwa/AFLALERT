import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../l10n/app_localizations.dart';

enum CoachMarkShape { circle, rect }

class CoachMarkStep {
  final GlobalKey targetKey;
  final String title;
  final String description;
  final CoachMarkShape shape;

  const CoachMarkStep({
    required this.targetKey,
    required this.title,
    required this.description,
    this.shape = CoachMarkShape.rect,
  });
}

/// A one-time, first-launch walkthrough that dims the screen and cuts a
/// spotlight hole around each step's target widget in turn, with a tooltip
/// explaining what it does. Positions itself using the target's real
/// on-screen [RenderBox], so it stays accurate regardless of screen size.
class CoachMarkOverlay extends StatefulWidget {
  final List<CoachMarkStep> steps;
  final VoidCallback onFinished;

  const CoachMarkOverlay({
    super.key,
    required this.steps,
    required this.onFinished,
  });

  @override
  State<CoachMarkOverlay> createState() => _CoachMarkOverlayState();
}

class _CoachMarkOverlayState extends State<CoachMarkOverlay> {
  int _stepIndex = 0;

  Rect? _targetRect(GlobalKey key) {
    final BuildContext? ctx = key.currentContext;
    if (ctx == null) return null;
    final RenderObject? renderObject = ctx.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return null;
    final Offset topLeft = renderObject.localToGlobal(Offset.zero);
    return topLeft & renderObject.size;
  }

  void _next() {
    if (_stepIndex == widget.steps.length - 1) {
      widget.onFinished();
      return;
    }
    setState(() => _stepIndex++);
  }

  @override
  Widget build(BuildContext context) {
    final CoachMarkStep step = widget.steps[_stepIndex];
    final Rect? target = _targetRect(step.targetKey);
    final Size screen = MediaQuery.of(context).size;
    final bool isLastStep = _stepIndex == widget.steps.length - 1;

    // Target isn't laid out yet (e.g. still loading) — skip drawing this
    // frame rather than spotlighting the wrong spot.
    if (target == null) return const SizedBox.shrink();

    final bool roomBelow = target.bottom + 180 < screen.height;

    return Positioned.fill(
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _next,
              child: CustomPaint(
                painter: _SpotlightPainter(target: target, shape: step.shape),
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: roomBelow ? target.bottom + 16 : null,
            bottom: roomBelow ? null : screen.height - target.top + 16,
            child: SizedBox(
              width: screen.width - 48,
              child: _CoachMarkTooltip(
                step: step,
                stepIndex: _stepIndex,
                stepCount: widget.steps.length,
                isLastStep: isLastStep,
                onNext: _next,
                onSkip: widget.onFinished,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoachMarkTooltip extends StatelessWidget {
  final CoachMarkStep step;
  final int stepIndex;
  final int stepCount;
  final bool isLastStep;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _CoachMarkTooltip({
    required this.step,
    required this.stepIndex,
    required this.stepCount,
    required this.isLastStep,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            step.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            step.description,
            style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 40,
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      stepCount,
                      (i) => Container(
                        margin: const EdgeInsets.only(right: 5),
                        width: i == stepIndex ? 16 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: i == stepIndex
                              ? AppColors.primaryContainer
                              : AppColors.outline,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),
                if (!isLastStep)
                  TextButton(
                    onPressed: onSkip,
                    child: Text(l10n.coachMarkSkip, style: const TextStyle(color: AppColors.grey)),
                  ),
                ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    // Overrides the app's global ElevatedButtonTheme, which
                    // defaults minimumSize to Size(double.infinity, 56) for
                    // full-width buttons elsewhere — that forced this
                    // button's Row parent into an infinite-width layout.
                    minimumSize: Size.zero,
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(isLastStep ? l10n.coachMarkGotIt : l10n.coachMarkNext),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final Rect target;
  final CoachMarkShape shape;

  _SpotlightPainter({required this.target, required this.shape});

  @override
  void paint(Canvas canvas, Size size) {
    final Path scrim = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final Rect hole = target.inflate(8);
    final Path holePath = shape == CoachMarkShape.circle
        ? (Path()..addOval(hole))
        : (Path()..addRRect(RRect.fromRectAndRadius(hole, const Radius.circular(16))));

    final Path combined = Path.combine(PathOperation.difference, scrim, holePath);
    canvas.drawPath(combined, Paint()..color = Colors.black.withValues(alpha: 0.7));
    canvas.drawPath(
      holePath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) =>
      oldDelegate.target != target || oldDelegate.shape != shape;
}
