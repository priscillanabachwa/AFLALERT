import 'package:aflalert/l10n/app_localizations.dart';
import 'package:aflalert/screens/result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );

void main() {
  testWidgets('shows the localized result text for the current locale, not a raw model string', (
    WidgetTester tester,
  ) async {
    // The classifier only ever distinguishes healthy vs. moldy — there's no
    // richer per-scan text to preserve — so the screen must always render
    // the localized copy for isSafe rather than a stored/raw label (which
    // is always English, straight from the on-device model).
    await tester.pumpWidget(
      _wrap(const ResultsScreen(isSafe: false, confidence: 0.91)),
    );

    expect(find.text('Unsafe for Human Consumption'), findsOneWidget);
  });

  testWidgets('shows the localized healthy text when safe', (WidgetTester tester) async {
    await tester.pumpWidget(
      _wrap(const ResultsScreen(isSafe: true, confidence: 0.97)),
    );

    expect(find.text('Healthy Maize'), findsOneWidget);
  });
}
