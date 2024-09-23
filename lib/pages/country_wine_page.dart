import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wiih/classes/change_notifier.dart';
import 'package:wiih/classes/wine.dart';

class CountryWinePage extends StatelessWidget {
  final String country;

  const CountryWinePage({super.key, required this.country});

  @override
  Widget build(BuildContext context) {
    final wineList = Provider.of<WineList>(context);
    final winesFromCountry =
        wineList.wines.where((wine) => wine.country == country).toList();

    return Scaffold(
      appBar: AppBar(title: Text('Wines from $country')),
      body: ListView.builder(
        itemCount: winesFromCountry.length,
        itemBuilder: (context, index) {
          return _buildWineCard(context, winesFromCountry[index]);
        },
      ),
    );
  }

  Widget _buildWineCard(BuildContext context, Wine wine) {
    return Card(
      child: ListTile(
        title: Text('${wine.name} (${wine.year})'),
        subtitle: Text('${wine.type} - ${wine.winery} - ${wine.price} CHF'),
        trailing: Text('Bottles: ${wine.bottleCount}'),
      ),
    );
  }
}
