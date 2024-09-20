import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wiih/classes/animated_wine_bottle.dart';

void main() {
 testWidgets('AnimatedWineBottleIcon displays wine bottle icon',
    (WidgetTester tester) async {
  // Build the widget
  await tester.pumpWidget(MaterialApp(home: AnimatedWineBottleIcon()));

  // Check that the wine bottle icon is present
  expect(find.byIcon(Icons.wine_bar), findsOneWidget);

  // Verify that the icon is within a Center widget in the AnimatedWineBottleIcon
  final centerWidget = find.ancestor(
    of: find.byIcon(Icons.wine_bar),
    matching: find.byType(Center),
  );
  expect(centerWidget, findsOneWidget);
});


  testWidgets('AnimatedWineBottleIcon animates wine bottle icon continuously',
      (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(MaterialApp(home: AnimatedWineBottleIcon()));

    // Initially, check for the icon and RotationTransition
    expect(find.byIcon(Icons.wine_bar), findsOneWidget);
    expect(find.byType(RotationTransition), findsOneWidget);

    // Simulate the animation after 1 second
    await tester.pump(const Duration(seconds: 1));

    // The icon should still be present, and animation should continue
    expect(find.byIcon(Icons.wine_bar), findsOneWidget);
    expect(find.byType(RotationTransition), findsOneWidget);

    // Simulate the animation after another 2 seconds
    await tester.pump(const Duration(seconds: 2));

    // Again, verify that the animation is still active
    expect(find.byType(RotationTransition), findsOneWidget);
  });
}
