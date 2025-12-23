import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:wiih/src/features/cellar/presentation/state/wine_list.dart';
import 'package:wiih/src/features/cellar/domain/models/wine.dart';
import 'package:wiih/src/features/home/presentation/pages/home_page.dart';

Wine createWine({
  required int id,
  required String type,
  required int bottleCount,
  required int price,
}) {
  return Wine(
    id: id,
    name: 'Wine$id',
    type: type,
    winery: 'Winery$id',
    country: 'Country$id',
    grapeVariety: 'Grape$id',
    year: 2000 + id,
    price: price,
    imageUrl: null,
    bottleCount: bottleCount,
  );
}

void main() {
  testWidgets('HomePage statistics show totals regardless of active filter',
      (tester) async {
    final wineList = WineList();

    wineList.addWine(createWine(id: 1, type: 'Red', bottleCount: 2, price: 10));
    wineList
        .addWine(createWine(id: 2, type: 'White', bottleCount: 3, price: 15));

    wineList.filterWinesByType('Red');

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<WineList>.value(value: wineList),
        ],
        child: const MaterialApp(home: HomePage()),
      ),
    );

    await tester.pump();

    expect(find.text('5'), findsOneWidget);
    expect(find.text('65'), findsOneWidget);
  });
}
