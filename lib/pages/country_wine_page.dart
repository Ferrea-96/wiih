import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wiih/classes/change_notifier.dart';
import 'package:wiih/classes/placeholder_image.dart';
import 'package:wiih/classes/wine/wine.dart';

class CountryWinePage extends StatelessWidget {
  final String country;

  const CountryWinePage({super.key, required this.country});

  @override
  Widget build(BuildContext context) {
    final wineList = Provider.of<WineList>(context);
    final winesFromCountry =
        wineList.wines.where((wine) => wine.country == country).toList();

    final pageController = PageController(viewportFraction: 0.95);

    return Scaffold(
      appBar: AppBar(title: Text('Wines from $country')),
      body: SafeArea(
        child: winesFromCountry.isEmpty
            ? Center(child: Text('No wines available from $country'))
            : PageView.builder(
                controller: pageController,
                itemCount: winesFromCountry.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: WineCard(wine: winesFromCountry[index]),
                  );
                },
              ),
      ),
    );
  }
}

class WineCard extends StatelessWidget {
  final Wine wine;

  const WineCard({super.key, required this.wine});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: wine.imageUrl != null
                      ? Image.network(
                          wine.imageUrl!,
                          width: double.infinity,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              PlaceholderImage(context: context, wine: wine),
                        )
                      : PlaceholderImage(context: context, wine: wine),
                ),
              ),
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        '${wine.name} (${wine.year})',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${wine.type} - ${wine.winery}',
                        style: const TextStyle(fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        wine.grapeVariety,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${wine.price} CHF',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Bottles: ${wine.bottleCount}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
