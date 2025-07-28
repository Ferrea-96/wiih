import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wiih/classes/change_notifier.dart';
import 'package:wiih/classes/wine/wine.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return homeScreen();
  }

  Widget homeScreen() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            welcomeText(),
            cellarStatistics(),
            priceStatistics(),
            notesStatistics(),
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
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Consumer<WineList>(
            builder: (context, wineList, child) {
              int wineCount = calculateSumOfWines(wineList.wines);
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
                  )),
                ],
              );
            },
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
              int priceCount = calculateSumOfPrices(wineList.wines);
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

  Widget notesStatistics() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Consumer<NotesList>(
            builder: (context, notesList, child) {
              int notesCount = notesList.wineNotes.length;
              return Row(
                children: [
                  Text(
                    '$notesCount',
                    style: const TextStyle(
                        fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  const Expanded(
                    child: Text(
                      'notes in your inventory',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
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
