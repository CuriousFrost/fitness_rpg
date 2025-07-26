import 'package:fitness_rpg/models/visionary_class.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_rpg/main.dart';  // make sure this matches your project name

void main() {
  testWidgets('FitnessRPGApp has a dropdown to select class', (WidgetTester tester) async {
    await tester.pumpWidget(const FitnessRPGApp());

    // Verify dropdown exists
    expect(find.text('Select Your Class'), findsOneWidget);

    // Tap the dropdown and select a class
    await tester.tap(find.byType(DropdownButton<VisionaryClass>));
    await tester.pumpAndSettle();

    expect(find.text('saboteur'), findsOneWidget);
  });
}
