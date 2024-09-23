import 'package:flutter/material.dart';

class CountryIcon {
  final String country;
  final IconData icon;

  CountryIcon({required this.country, required this.icon});
}

class CountryIcons {
  static final List<CountryIcon> icons = [
    CountryIcon(country: 'France', icon: Icons.wine_bar),
    CountryIcon(country: 'Italy', icon: Icons.local_pizza),
    CountryIcon(country: 'Spain', icon: Icons.beach_access),
    CountryIcon(country: 'USA', icon: Icons.star),
    CountryIcon(country: 'Australia', icon: Icons.sunny),
    CountryIcon(country: 'Germany', icon: Icons.flag),
    // Add more country-icon pairs here
  ];

  static Icon getIconForCountry(String country, {double size = 50}) {
    final iconData = icons.firstWhere(
      (element) => element.country == country,
      orElse: () => CountryIcon(country: 'default', icon: defaultIcon),
    ).icon;
    return Icon(iconData, size: size);
  }

  static const IconData defaultIcon = Icons.language;
}
