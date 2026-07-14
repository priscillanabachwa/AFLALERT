import 'package:aflalert/screens/result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the actual analysis label instead of placeholder result text', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ResultsScreen(
          isSafe: false,
          confidence: 0.91,
          analysisLabel: 'Mold detected',
        ),
      ),
    );

    expect(find.text('Mold detected'), findsOneWidget);
    expect(find.text('Unsafe for Human Consumption'), findsNothing);
    expect(
      find.text('The model flagged this sample as Mold detected and recommends review before use.'),
      findsOneWidget,
    );
  });
}
