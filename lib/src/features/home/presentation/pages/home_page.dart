import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wiih/src/features/cellar/presentation/state/wine_list.dart';
import 'package:wiih/src/features/cellar/domain/models/wine.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, this.onCellarTap});

  final VoidCallback? onCellarTap;

  @override
  Widget build(BuildContext context) {
    return homeScreen(context);
  }

  Widget homeScreen(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            welcomeText(),
            cellarStatistics(),
            priceStatistics(),
          ],
        ),
      ),
    );
  }

  Widget welcomeText() {
    return const Padding(
      padding: EdgeInsets.all(20.0),
      child: Text(
        'Hi there!',
        style: TextStyle(
            fontSize: 25, letterSpacing: 3, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget cellarStatistics() {
    final borderRadius = BorderRadius.circular(12);
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onCellarTap,
          borderRadius: borderRadius,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Consumer<WineList>(
              builder: (context, wineList, child) {
                int wineCount = calculateSumOfWines(wineList.allWines);
                return Row(
                  children: [
                    Text(
                      '$wineCount',
                      style: const TextStyle(
                          fontSize: 48, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    const Expanded(
                      child: Text(
                        'wines in your cellar',
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget priceStatistics() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Consumer<WineList>(
            builder: (context, wineList, child) {
              int priceCount = calculateSumOfPrices(wineList.allWines);
              return Row(
                children: [
                  Text(
                    '$priceCount',
                    style: const TextStyle(
                        fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  const Expanded(
                      child: Text(
                    'CHF of value',
                    style: TextStyle(fontSize: 24),
                  )),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  int calculateSumOfPrices(List<Wine> wines) {
    int sum = 0;

    for (var wine in wines) {
      sum += (wine.price.toInt() * wine.bottleCount.toInt());
    }

    return sum;
  }

  int calculateSumOfWines(List<Wine> wines) {
    int sum = 0;

    for (var wine in wines) {
      sum += wine.bottleCount.toInt();
    }

    return sum;
  }
}
