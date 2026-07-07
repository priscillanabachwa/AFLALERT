import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aflalert/main.dart';
import 'package:aflalert/screens/history_screen.dart';
import 'package:aflalert/screens/login_screen.dart';

void main() {
<<<<<<< HEAD
  testWidgets('login screen shows the main UI', (WidgetTester tester) async {
    await tester.pumpWidget(const AflAlertApp(home: LoginScreen()));
=======
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AflAlert());
>>>>>>> 2e517459d3be714620c36b41cdf85d6d2aea065c

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
  });

  testWidgets('tapping login navigates to the history screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('History'), findsOneWidget);
    expect(find.byType(HistoryScreen), findsOneWidget);
  });
}
