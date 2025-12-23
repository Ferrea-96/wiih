import 'package:flutter_test/flutter_test.dart';
import 'package:wiih/src/features/cellar/presentation/state/wine_list.dart';
import 'package:wiih/src/features/cellar/domain/models/wine.dart';

Wine buildWine({
  required int id,
  required String type,
  String? name,
  String? winery,
  String? country,
  String? grapeVariety,
  int? year,
  int? price,
  int? bottleCount,
  String? imageUrl,
}) {
  return Wine(
    id: id,
    name: name ?? 'Wine$id',
    type: type,
    winery: winery ?? 'Winery$id',
    country: country ?? 'Country$id',
    grapeVariety: grapeVariety ?? 'Grape$id',
    year: year ?? (2000 + id),
    price: price ?? (10 * id),
    imageUrl: imageUrl,
    bottleCount: bottleCount ?? 1,
  );
}

void main() {
  group('WineList', () {
    test('add/update/delete keep filtered list in sync', () {
      final wineList = WineList();
      wineList.addWine(buildWine(id: 1, type: 'Red'));
      wineList.addWine(buildWine(id: 2, type: 'White'));

      wineList.filterWinesByType('Red');
      expect(wineList.wines.map((wine) => wine.id), [1]);

      wineList.updateWine(buildWine(id: 1, type: 'White'));
      expect(wineList.wines, isEmpty);
      expect(wineList.allWines.map((wine) => wine.id), [1, 2]);

      wineList.deleteWine(1);
      expect(wineList.allWines.map((wine) => wine.id), [2]);
    });

    test('clearFilter restores full list', () {
      final wineList = WineList();
      wineList.addWine(buildWine(id: 1, type: 'Red'));
      wineList.addWine(buildWine(id: 2, type: 'White'));

      wineList.filterWinesByType('Red');
      expect(wineList.wines.map((wine) => wine.id), [1]);

      wineList.clearFilter();
      expect(wineList.wines.map((wine) => wine.id), [1, 2]);
    });

    test('sort methods order wines by field', () {
      final wineList = WineList();
      wineList.loadWines([
        buildWine(
          id: 1,
          type: 'White',
          name: 'C',
          country: 'Spain',
          year: 2021,
          price: 30,
        ),
        buildWine(
          id: 2,
          type: 'Red',
          name: 'A',
          country: 'France',
          year: 2019,
          price: 20,
        ),
        buildWine(
          id: 3,
          type: 'Rose',
          name: 'B',
          country: 'Italy',
          year: 2020,
          price: 10,
        ),
      ]);

      wineList.sortWinesByPrice();
      expect(wineList.wines.map((wine) => wine.id), [3, 2, 1]);

      wineList.sortWinesByType();
      expect(wineList.wines.map((wine) => wine.type), ['Red', 'Rose', 'White']);

      wineList.sortWinesByCountry();
      expect(wineList.wines.map((wine) => wine.country), ['France', 'Italy', 'Spain']);

      wineList.sortWinesByYear();
      expect(wineList.wines.map((wine) => wine.year), [2019, 2020, 2021]);

      wineList.sortWinesByName();
      expect(wineList.wines.map((wine) => wine.name), ['A', 'B', 'C']);
    });

    test('loadWines copies the list instance', () {
      final wineList = WineList();
      final original = [
        buildWine(id: 1, type: 'Red'),
        buildWine(id: 2, type: 'White'),
      ];

      wineList.loadWines(original);
      original.add(buildWine(id: 3, type: 'Rose'));

      expect(wineList.allWines.length, 2);
    });

    test('allWines exposes the complete collection when filtered', () {
      final wineList = WineList();
      wineList.addWine(buildWine(id: 1, type: 'Red'));
      wineList.addWine(buildWine(id: 2, type: 'White'));

      wineList.filterWinesByType('Red');

      expect(wineList.wines.length, 1);
      expect(wineList.allWines.length, 2);
      expect(wineList.allWines.map((wine) => wine.id), containsAll([1, 2]));
    });
  });
}
