import 'package:flutter_test/flutter_test.dart';
import 'package:wiih/src/features/cellar/presentation/state/wine_list.dart';
import 'package:wiih/src/features/cellar/domain/models/wine.dart';

Wine buildWine({
  required int id,
  required String type,
}) {
  return Wine(
    id: id,
    name: 'Wine$id',
    type: type,
    winery: 'Winery$id',
    country: 'Country$id',
    grapeVariety: 'Grape$id',
    year: 2000 + id,
    price: 10 * id,
    imageUrl: null,
    bottleCount: 1,
  );
}

void main() {
  group('WineList', () {
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
