import 'package:flutter_test/flutter_test.dart';
import 'package:wiih/src/features/cellar/domain/models/wine.dart';

void main() {
  group('Wine', () {
    test('clamps negative bottleCount to zero in constructor', () {
      final wine = Wine(
        id: 1,
        name: 'Test',
        type: 'Red',
        winery: 'Winery',
        country: 'France',
        grapeVariety: 'Merlot',
        year: 2020,
        price: 12,
        imageUrl: null,
        bottleCount: -3,
      );

      expect(wine.bottleCount, 0);
    });

    test('clamps negative bottleCount via setter', () {
      final wine = Wine(
        id: 1,
        name: 'Test',
        type: 'Red',
        winery: 'Winery',
        country: 'France',
        grapeVariety: 'Merlot',
        year: 2020,
        price: 12,
        imageUrl: null,
        bottleCount: 2,
      );

      wine.bottleCount = -5;
      expect(wine.bottleCount, 0);
    });

    test('serializes and deserializes consistently', () {
      final wine = Wine(
        id: 7,
        name: 'Reserve',
        type: 'White',
        winery: 'Winery',
        country: 'Italy',
        grapeVariety: 'Pinot',
        year: 2018,
        price: 42,
        imageUrl: 'https://example.com/wine.jpg',
        bottleCount: 4,
      );

      final json = wine.toJson();
      final restored = Wine.fromJson(json);

      expect(restored.id, wine.id);
      expect(restored.name, wine.name);
      expect(restored.type, wine.type);
      expect(restored.winery, wine.winery);
      expect(restored.country, wine.country);
      expect(restored.grapeVariety, wine.grapeVariety);
      expect(restored.year, wine.year);
      expect(restored.price, wine.price);
      expect(restored.imageUrl, wine.imageUrl);
      expect(restored.bottleCount, wine.bottleCount);
    });
  });
}
