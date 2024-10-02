// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wiih/classes/change_notifier.dart';
import 'package:wiih/classes/wine_country_image.dart';
import 'package:wiih/pages/country_wine_page.dart';

class CountryPage extends StatelessWidget {
  const CountryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final wineList = Provider.of<WineList>(context);

    // Get unique countries from wine list
    final countries =
        wineList.wines.map((wine) => wine.country).toSet().toList();

    return Center(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: countries.length,
              itemBuilder: (context, index) {
                final country = countries[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CountryWinePage(country: country),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch the content to fill the card width
                      children: [
                        // Expanded image container at the top
                        Flexible(
                          flex: 3,
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                            child: CountryIcons.getImageForCountry(
                              country,
                              size: double.infinity, 
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        // Country name at the bottom
                        Padding(
                          padding: const EdgeInsets.fromLTRB(6, 4, 6, 8),
                          child: Text(
                            country,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center, // Center the text
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
