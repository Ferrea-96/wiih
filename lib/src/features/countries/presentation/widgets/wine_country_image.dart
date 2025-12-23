import 'package:flutter/material.dart';

class CountryImage {
  final String country;
  final String imagePath; // Path to the image

  CountryImage({required this.country, required this.imagePath});
}

class CountryIcons {
  static final List<CountryImage> images = [
    CountryImage(country: 'France', imagePath: 'assets/images/france.png'),
    CountryImage(country: 'Italy', imagePath: 'assets/images/italy.png'),
    CountryImage(country: 'Spain', imagePath: 'assets/images/spain.png'),
    CountryImage(
        country: 'Switzerland', imagePath: 'assets/images/switzerland.png'),
    CountryImage(country: 'USA', imagePath: 'assets/images/usa.png'),
    CountryImage(country: 'Germany', imagePath: 'assets/images/germany.png'),
    CountryImage(country: 'Austria', imagePath: 'assets/images/austria.png'),
    CountryImage(
        country: 'Australia', imagePath: 'assets/images/australia.png'),
    CountryImage(country: 'Portugal', imagePath: 'assets/images/portugal.png'),
    CountryImage(
        country: 'Argentina', imagePath: 'assets/images/argentina.png'),
    CountryImage(country: 'Georgia', imagePath: 'assets/images/georgia.png'),
    CountryImage(country: 'Chile', imagePath: 'assets/images/chile.png'),
    CountryImage(
        country: 'South Africa', imagePath: 'assets/images/south_africa.png'),
    CountryImage(
        country: 'New Zealand', imagePath: 'assets/images/new_zealand.png'),
  ];

  static Widget getImageForCountry(String country, {double size = 50}) {
    final imagePath = images
        .firstWhere(
          (element) => element.country == country,
          orElse: () =>
              CountryImage(country: 'default', imagePath: defaultImagePath),
        )
        .imagePath;

    return Image.asset(
      imagePath,
      height: size,
      width: size,
      fit: BoxFit.fill, // Fills the tile
    );
  }

  static const String defaultImagePath =
      'assets/images/default.png'; // Default image if country not found
}
