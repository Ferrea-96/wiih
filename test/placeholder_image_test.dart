import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wiih/classes/placeholder_image.dart';
import 'package:wiih/classes/wine/wine.dart';

Wine buildWine({
  required String type,
}) {
  return Wine(
    id: 1,
    name: 'Test',
    type: type,
    winery: 'Winery',
    country: 'Country',
    grapeVariety: 'Grape',
    year: 2020,
    price: 10,
    imageUrl: null,
    bottleCount: 1,
  );
}

void main() {
  testWidgets('Rosé wines use dedicated placeholder image', (tester) async {
    final wine = buildWine(type: 'Rosé');

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return PlaceholderImage(
              context: context,
              wine: wine,
            );
          },
        ),
      ),
    );

    await tester.pump();

    final image = tester.widget<Image>(find.byType(Image));
    final asset = image.image as AssetImage;

    expect(asset.assetName, 'assets/placeholder_rose_image.jpg');
  });
}
