import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wiih/classes/animated_wine_bottle.dart';

void main() {
  testWidgets('AnimatedWineBottleIcon displays wine bottle icon',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: AnimatedWineBottleIcon()));
    await tester.pumpAndSettle(); // Wait for the animation to complete

    expect(find.byIcon(Icons.wine_bar), findsOneWidget);
    expect(find.byType(Center), findsOneWidget);
  });

  testWidgets('AnimatedWineBottleIcon animates wine bottle icon continuously',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: AnimatedWineBottleIcon()));

    // Wait for the animation to complete
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Check if the icon is animated continuously
    expect(find.byIcon(Icons.wine_bar), findsOneWidget);
    expect(find.byType(Center), findsOneWidget);
    expect(find.byType(RotationTransition), findsOneWidget);
  });
}
