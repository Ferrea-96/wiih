import 'package:flutter/material.dart';
import 'package:wiih/classes/wine/wine.dart';

class PlaceholderImage extends StatelessWidget {
  const PlaceholderImage({
    super.key,
    required this.context,
    required this.wine,
  });

  final BuildContext context;
  final Wine wine;

  @override
  Widget build(BuildContext context) {
    switch (wine.type) {
      case 'Red':
        return Image.asset(
          'assets/placeholder_red_image.jpg',
          fit: BoxFit.fill,
        );
      case 'White':
        return Image.asset(
          'assets/placeholder_white_image.jpg',
          fit: BoxFit.fill,
        );
      case 'Rosé':
        return Image.asset(
          'assets/placeholder_rose_image.jpg',
          fit: BoxFit.fill,
        );
      case 'Sparkling':
        return Image.asset(
          'assets/placeholder_sparkling_image.jpg',
          fit: BoxFit.fill,
        );
      case 'Orange':
        return Image.asset(
          'assets/placeholder_orange_image.jpg',
          fit: BoxFit.fill,
        );
      default:
        return Image.asset(
          'assets/placeholder_red_image.jpg', // Default placeholder image
          fit: BoxFit.fill,
        );
    }
  }
}